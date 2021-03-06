#! /usr/bin/env python3
import fnmatch
import concurrent.futures
import operator
import os
import os.path
import re
import sys
import traceback

import checkers

# Change directory before importing configuration, this could be useful
os.chdir(os.path.dirname(os.path.realpath(__file__)))

import config

DEBUG = False

# Precompile pattern and regexps
FILE_PATTERNS = [
    re.compile(
        fnmatch.translate(
            os.path.normcase(pattern)))
    for pattern in config.FILE_PATTERNS
]
VERSIONS_REGEXPS = [
    re.compile(regexp)
    for regexp in config.VERSIONS_REGEXPS
]

# Normalize case and tag
VERSIONS = {
    (os.path.normcase(path), tag.upper()) : checker
    for (path, tag), checker in config.VERSIONS.items()
}

class Status:
    def __init__(self):
        self.queue = list()
        self.seen_tags = set()
        self.missing_versions = list()
        self.new_versions = list()
        self.ok_versions = list()
        self.err_versions = list()

    def queue_work(self, path, tag, version):
        self.queue.append((path, tag, version))

    def do_work(self):
        # Prepare all checks
        checks_queue = (self.__pre_handle_version(*q) for q in self.queue)
        checks_queue = filter(None, checks_queue)

        # Use 10 threads to have 10 concurrent connections
        with concurrent.futures.ThreadPoolExecutor(max_workers=10) as pool:
            results = pool.map(Status.handle_version, checks_queue)
        #results = map(Status.handle_version, checks_queue)

        for result in results:
            self.__post_handle_version(*result)

    def __pre_handle_version(self, path, tag, version):
        tag = tag.upper()
        checker = VERSIONS.get((path, tag), None)
        if checker is None:
            self.__missing_version(path, tag)
            return

        try:
            checker, args = checkers.lookup(checker)
        except checkers.BadConfigException as e:
            raise Exception("Error in configuration with {0!r}".format((path, tag))) from e
        return path, tag, version, checker, args

    @staticmethod
    def handle_version(all_args):
        path, tag, version, checker, args = all_args
        try:
            result, online_version, extra_infos = checker(version, **args)
        except Exception as e:
            return path, tag, version, e, None, None
        return path, tag, version, result, online_version, extra_infos

    def __post_handle_version(self, path, tag, version, result, online_version, extra_infos):
        if isinstance(result, Exception):
            self.__err_version(path, tag, result)

        if not result:
            self.__new_version(path, tag, version, online_version, extra_infos)
            return

        self.__ok_version(path, tag, version, online_version, extra_infos)

    def __missing_version(self, path, tag):
        self.seen_tags.add((path, tag))
        self.missing_versions.append((path, tag))

    def print_missing_versions(self):
        if not self.missing_versions:
            return

        self.missing_versions.sort(key=operator.itemgetter(0))

        print("Missing version lines, add following lines to config VERSIONS:")
        for v in self.missing_versions:
            print("({0!r}, {1!r}): <check configuration>,".format(*v))

    def __new_version(self, path, tag, version, online_version, extra_infos):
        self.seen_tags.add((path, tag))
        self.new_versions.append((path, tag or 'Unknown', version, online_version, extra_infos))

    def print_new_versions(self):
        if not self.new_versions:
            return

        self.new_versions.sort(key=operator.itemgetter(0))

        print("New versions:")
        for v in self.new_versions:
            print("{1} in {0}: version {3} ({2} in file{5}{4})".format(*v, ', ' if v[4] else ''))

    def __ok_version(self, path, tag, version, online_version, extra_infos):
        self.seen_tags.add((path, tag))
        self.ok_versions.append((path, tag or 'Unknown', version, online_version, extra_infos))

    def print_ok_versions(self):
        if not self.ok_versions:
            return

        self.ok_versions.sort(key=operator.itemgetter(0))

        print("Same versions:")
        for v in self.ok_versions:
            print("{1} in {0}: version {3} ({2} in file{5}{4})".format(*v, ', ' if v[4] else ''))

    def __err_version(self, path, tag, error):
        self.seen_tags.add((path, tag))
        self.err_versions.append((path, tag or 'Unknown', error))

    def print_err_versions(self):
        if not self.err_versions:
            return

        self.err_versions.sort(key=operator.itemgetter(0))

        print("Query errors:")
        for v in self.err_versions:
            exc = v[2]
            etype, value, tb = type(exc), exc, exc.__traceback__
            msg = ''.join(traceback.format_exception(etype, value, tb))
            print("{1} in {0}:\n{2}".format(v[0], v[1], msg))

    def print_obsolete_versions(self):
        config_tags = set(VERSIONS.keys())

        config_tags.difference_update(self.seen_tags)

        if not config_tags:
            return

        config_tags = sorted(config_tags)
        print("Obsolete versions present in configuration:")
        for v in config_tags:
            print("({0!r}, {1!r})".format(*v))


def handle_file(status, path):
    with open(path, "r") as f:
        for line in f:
            line = line.rstrip('\r\n')
            for regexp in VERSIONS_REGEXPS:
                match = regexp.search(line)
                if match:
                    status.queue_work(path, match.group('package'), match.group('version'))
                    break

def handle_dir(status, path):
    for dirpath, dirnames, filenames in os.walk(path):
        filenames = [os.path.normcase(f) for f in filenames]
        filtered = set()
        for filename in filenames:
            filepath = os.path.join(dirpath, filename)
            for pattern in FILE_PATTERNS:
                if pattern.match(filepath):
                    filtered.add(filepath)
        for filepath in filtered:
            handle_file(status, filepath)

def handle_path(status, path):
    if not os.path.exists(path):
        print("WARNING: Invalid path in configuration: {0}".format(path), file=sys.stderr)
        return

    if os.path.isdir(path):
        handle_dir(status, path)
    else:
        handle_file(status, path)

def main():
    # We already changed directory to ours
    # ROOT is relative to us so we can chdir here
    if hasattr(config, 'ROOT') and config.ROOT:
        os.chdir(config.ROOT)

    status = Status()
    print("Looking for version tags...")
    for path in config.PATHS:
        handle_path(status, path)

    print("Requesting versions online...")
    status.do_work()

    if DEBUG:
        checkers.stats()
        status.print_ok_versions()
    status.print_new_versions()
    status.print_obsolete_versions()
    status.print_missing_versions()
    status.print_err_versions()

if __name__ == "__main__":
    main()
