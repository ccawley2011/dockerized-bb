m4_define(`TOOLCHAIN',macosx-x86_64)m4_dnl
m4_dnl These settings must be kept in sync between toolchain and worker
m4_define(`DEBIAN_CLANG',-14)m4_dnl
m4_define(`MACOSX_SDK_VERSION',13.3)m4_dnl
m4_define(`MACOSX_TARGET_ARCH',x86_64)m4_dnl
m4_define(`MACOSX_TARGET_VERSION',22.4)m4_dnl
m4_define(`MACOSX_DEPLOYMENT_TARGET',10.9)m4_dnl
m4_define(`MACOSX_ARCHITECTURES',`x86_64')m4_dnl
m4_define(`MACOSX_PORTS_ARCH_ARG',`')m4_dnl
m4_dnl m4_define(`PATCH_OSXCROSS',`')m4_dnl
m4_include(`apple/macosx.m4')m4_dnl
