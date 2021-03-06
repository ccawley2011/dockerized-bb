import os

from twisted.cred import strcred

from buildbot.plugins import util
from buildbot.plugins import reporters

import config

www = {
    'plugins': dict(waterfall_view={}, console_view={}, grid_view={}),
# TODO:
#    order_console_by_time: True,
    'change_hook_dialects': {
    },
}
services = []

if hasattr(config, 'github_webhook_secret'):
    www['change_hook_dialects']['github'] = {
	'secret': config.github_webhook_secret,
        # Only be strict when secret is provided
        # When not strict, if no signature is returned, check isn't done
        'strict': bool(config.github_webhook_secret),
    }

if hasattr(config, 'ht_auth_file') and config.ht_auth_file:
    ht_auth_file = os.path.join(config.buildbot_base_dir, config.ht_auth_file)
    www['auth'] = util.HTPasswdAuth(ht_auth_file)
    # When using htpasswd file, we don't have any group information nor email information
    www['authz'] = util.Authz(
        stringsMatcher=util.fnmatchStrMatcher,  # simple matcher with '*' glob character
        allowRules=[
            # admins can do anything,
            # defaultDeny=False: if user does not have the admin role, we continue parsing rules
            util.AnyEndpointMatcher(role="admin", defaultDeny=False),
            # if future Buildbot implement new control, we are safe with this last rule
            util.AnyControlEndpointMatcher(role="admin")
        ],
        roleMatchers=[
            util.RolesFromUsername(roles=['admin'], usernames=config.ht_auth_admins),
        ]
    )
elif hasattr(config, 'github_auth_clientid') and config.github_auth_clientid:
    www['auth'] = util.GitHubAuth(
            config.github_auth_clientid, config.github_auth_clientsecret,
            apiVersion=4, getTeamsMembership=True)
    # When using Github authentication, we can use group membership information
    www['authz'] = util.Authz(
        stringsMatcher=util.fnmatchStrMatcher,  # simple matcher with '*' glob character
        # stringsMatcher = util.reStrMatcher,   # if you prefer regular expressions
        allowRules=[
            # admins can do anything,
            # defaultDeny=False: if user does not have the admin role, we continue parsing rules
            util.AnyEndpointMatcher(role=config.github_admin_group, defaultDeny=False),
            # Let owner stop its build
            util.StopBuildEndpointMatcher(role="owner"),
            # if future Buildbot implement new control, we are safe with this last rule
            util.AnyControlEndpointMatcher(role=config.github_admin_group)
        ],
        roleMatchers=[
            util.RolesFromGroups(groupPrefix="{0}/".format(config.github_organisation)),
            # role owner is granted when property owner matches the email of the user
            util.RolesFromOwner(role="owner")
        ]
    )

try:
    if len(config.www_port) == 2:
        www['port'] = "tcp:{1}:interface={0}".format(*config.www_port)
    elif len(config.www_port) == 1:
        www['port'] = "tcp:{0}".format(*config.www_port)
    else:
        raise Exception("www_port hasn't length 2")
except TypeError:
    www['port'] = "tcp:{0}".format(config.www_port)

if hasattr(config, 'irc') and config.irc:
    services.append(reporters.IRC(
        host=config.irc['server'],
        port=config.irc.get('port', 6667),
        useSSL=config.irc.get('ssl', False),
        nick=config.irc['nick'],
        password=config.irc.get('password', None),
        channels=config.irc.get('channels', []),
        pm_to_nicks=config.irc.get('nicks', []),
        useColors=True,
        authz={
            # Order of match is 'command', '*', ''/'!'
            # Operation restricted to bot administrators
            '': config.irc.get('admins', False),
            # No dangerous command can be issued on IRC (real authentication required)
            '!': False,
        },
        notify_events=[
            'exception',
            'problem',
            'recovery',
            'worker'
        ]
    ))
