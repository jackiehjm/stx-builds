# How to debug ARM build

## Investigate logs:

* $STX_BUILD_HOME/localdisk/builder.log
* $STX_BUILD_HOME/localdisk/pkgbuilder.log
* $STX_BUILD_HOME/prj-stx-deb/std/<pkg_name>/*.build
* $STX_BUILD_HOME/prj-stx-deb/std/<pkg_name>/*.log

## Debug with sbuild and chroot

### Source environment variables

```
source env.prj-stx-deb

cd $STX_REPO_ROOT/stx-tools
source import-stx
```

### Enter the stx-pkgbuilder pod
```
stx shell --container pkgbuilder
```

### Modify the sbuild.conf to keep the build env when failed

* reference: https://manpages.debian.org/testing/sbuild/sbuild.conf.5.en.html

```
sed -i 's/always/successful/' /etc/sbuild/sbuild.conf
```
or
```
sed -i 's/always/never/' /etc/sbuild/sbuild.conf
```

Results: e.g.

```
root@prj-stx-deb-stx-pkgbuilder-f9bdb8c89-mmfnk:~# grep purge /etc/sbuild/sbuild.conf
$purge_build_deps = 'successful';
$purge_build_directory = 'successful';
```

### Get the build command for specific pkg in stx-pkgbuilder and re-run:

```
grep 'Build command' $STX_BUILD_HOME/localdisk/pkgbuilder.log|grep <pkg_name>
```

e.g. for crictl

```
jackie@gigabyte-3:~/stx-arm-build-2023/ws-stx-arm64-20230202$ grep 'Build command' $STX_BUILD_HOME/localdisk/pkgbuilder.log|grep crictl
2023-02-02 13:15:23,385 - DEBUG: Build command: sbuild -d bullseye -j6 -c chroot:bullseye-arm64-jackie-3 --extra-repository='deb [trusted=yes] http://prj-stx-deb-stx-repomgr:80/deb-local-build-3 bullseye main' --build-dir /localdisk/loadbuild/jackie/prj-stx-deb/std/crictl /localdisk/loadbuild/jackie/prj-stx-deb/std/crictl/crictl_1.0-1.stx.3.dsc
```

You will get the CHROOT_NAME is "bullseye-arm64-jackie-3".

### Enter the sbuild shell to debug

```
sbuild-shell <CHROOT_NAME>
bash
cd /build/<pkg_build_dir>

# run any step that previously failed
```

#### Example 1. For crictl

```
sbuild-shell bullseye-arm64-jackie-3
bash
cd /build/crictl-gNLiaY

cd crictl-1.0
dpkg-buildpackage --sanitize-env -us -uc -rfakeroot -j6
```

failed output:

```
dwz: debian/crictl/usr/bin/crictl: .debug_info section not present
   dh_strip -a
dh_strip: warning: Could not find the BuildID in debian/crictl/usr/bin/crictl
strip: Unable to recognise the format of the input file `debian/crictl/usr/bin/crictl'
dh_strip: error: strip --remove-section=.comment --remove-section=.note debian/crictl/usr/bin/crictl returned exit code 1
dh_strip: error: Aborting due to earlier error
make: *** [debian/rules:4: binary] Error 2
dpkg-buildpackage: error: fakeroot debian/rules binary subprocess returned exit status 2
```

```
(bullseye-arm64-jackie-3)root@prj-stx-deb-stx-pkgbuilder-f9bdb8c89-mmfnk:/build/crictl-gNLiaY/crictl-1.0# strip --remove-section=.comment --remove-section=.note debian/crictl/usr/bin/crictl
strip: Unable to recognise the format of the input file `debian/crictl/usr/bin/crictl'
(bullseye-arm64-jackie-3)root@prj-stx-deb-stx-pkgbuilder-f9bdb8c89-mmfnk:/build/crictl-gNLiaY/crictl-1.0# dh_strip
dh_strip: warning: Could not find the BuildID in debian/crictl/usr/bin/crictl
strip: Unable to recognise the format of the input file `debian/crictl/usr/bin/crictl'
dh_strip: error: strip --remove-section=.comment --remove-section=.note debian/crictl/usr/bin/crictl returned exit code 1
dh_strip: error: Aborting due to earlier error
(bullseye-arm64-jackie-3)root@prj-stx-deb-stx-pkgbuilder-f9bdb8c89-mmfnk:/build/crictl-gNLiaY/crictl-1.0# strip --remove-section=.comment --remove-section=.note debian/crictl/usr/bin/crictl
strip: Unable to recognise the format of the input file `debian/crictl/usr/bin/crictl'
(bullseye-arm64-jackie-3)root@prj-stx-deb-stx-pkgbuilder-f9bdb8c89-mmfnk:/build/crictl-gNLiaY/crictl-1.0# file debian/crictl/usr/bin/crictl
debian/crictl/usr/bin/crictl: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, Go BuildID=tFwPZe6fjhblEDhw5HLj/NdGox5eAy4J4TMBhHqQH/L-4qCzRiGThV_SFw2o4K/Kkv7Qb2SjDiyo7c88FLD, not stripped
```

#### Example 2. For sm-common:

* Error in log:
```
g++ -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include -I. -I/usr/lib/aarch64-linux-gnu/glib-2.0/include -fPIC -g -O2 -Wall -Werror -Wno-restrict -Wno-format-truncation -std=c++11 -D__STDC_FORMAT_MACROS -DSW_VERSION=\"\" -Wformat -Wformat-security -c sm_trap.c -o sm_trap.o
g++ -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include -I. -I/usr/lib/aarch64-linux-gnu/glib-2.0/include -fPIC -g -O2 -Wall -Werror -Wno-restrict -Wno-format-truncation -std=c++11 -D__STDC_FORMAT_MACROS -DSW_VERSION=\"\" -Wformat -Wformat-security -c sm_trap_thread.c -o sm_trap_thread.o
sm_trap_thread.c: In function ‘void sm_trap_thread_log(SmTrapThreadMsgT*)’:
sm_trap_thread.c:282:17: error: unused variable ‘ucontext’ [-Werror=unused-variable]
  282 |     ucontext_t* ucontext = &(msg->user_context);
      |                 ^~~~~~~~
cc1plus: all warnings being treated as errors
make[2]: *** [Makefile:40: sm_trap_thread.o] Error 1
make[2]: Leaving directory '/<<PKGBUILDDIR>>/src'
make[1]: *** [Makefile:10: build] Error 2
make[1]: Leaving directory '/<<PKGBUILDDIR>>'
dh_auto_build: error: make -j6 returned exit code 2
make: *** [debian/rules:11: build] Error 25
dpkg-buildpackage: error: debian/rules build subprocess returned exit status 2
```

* debug:

```
(bullseye-arm64-jackie-1)root@prj-stx-deb-stx-pkgbuilder-f9bdb8c89-mmfnk:/build/sm-common-tFMyLj/sm-common-1.0.0/src# g++ -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include -I. -I/usr/lib/aarch64-linux-gnu/glib-2.0/include -fPIC -g -O2 -Wall -Werror -Wno-restrict -Wno-format-truncation -std=c++11 -D__STDC_FORMAT_MACROS -DSW_VERSION=\"\" -Wformat -Wformat-security -c sm_trap_thread.c -o sm_trap_thread.o

sm_trap_thread.c: In function ‘void sm_trap_thread_log(SmTrapThreadMsgT*)’:
sm_trap_thread.c:282:17: error: unused variable ‘ucontext’ [-Werror=unused-variable]
  282 |     ucontext_t* ucontext = &(msg->user_context);
      |                 ^~~~~~~~
cc1plus: all warnings being treated as errors


g++ -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include -I. -I/usr/lib/aarch64-linux-gnu/glib-2.0/include -fPIC -g -O2 -Wall -Wno-restrict -Wno-format-truncation -std=c++11 -D__STDC_FORMAT_MACROS -DSW_VERSION=\"\" -Wformat -Wformat-security -c sm_trap_thread.c -o sm_trap_thread.o
```

ref: 
  * https://opensource.apple.com/source/clang/clang-700.1.81/src/projects/compiler-rt/lib/asan/asan_linux.cc
  * https://elixir.bootlin.com/linux/v3.14/source/arch/arm64/include/uapi/asm/sigcontext.h#L25


### Fix and re-build

e.g. fix for crictl
https://github.com/jackiehjm/stx-integ/commit/a2bbf1b72c082507d984662523026de9dd94c688

```
$ git show dd67a23edbd63375cb8c5b85690c8c866ccb1710
commit dd67a23edbd63375cb8c5b85690c8c866ccb1710
Author: Jackie Huang <jackie.huang@windriver.com>
Date:   Tue Feb 7 23:43:08 2023 -0500

    crictl: fix dl_path for arm64

    Signed-off-by: Jackie Huang <jackie.huang@windriver.com>

diff --git a/kubernetes/crictl/debian/meta_data.yaml b/kubernetes/crictl/debian/meta_data.yaml
index 1cd5fd04..881fb932 100644
--- a/kubernetes/crictl/debian/meta_data.yaml
+++ b/kubernetes/crictl/debian/meta_data.yaml
@@ -2,10 +2,10 @@
 debname: crictl
 debver: 1.0-1
 dl_path:
-  name: crictl-v1.21.0-linux-amd64.tar.gz
-  url: https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.21.0/crictl-v1.21.0-linux-amd64.tar.gz
-  md5sum: 671e173f96f87aab18a4f9f8111cd4e6
-  sha256sum: 85c78a35584971625bf1c3bcd46e5404a90396f979d7586f18b11119cb623e24
+  name: crictl-v1.21.0-linux-arm64.tar.gz
+  url: https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.21.0/crictl-v1.21.0-linux-arm64.tar.gz
+  md5sum: 5ca26d26d254fb59b776c63d8523b175
+  sha256sum: 454eecd29fe636282339af5b73c60234a7d10e4b11b9e18937e33056763d72cf
 revision:
   dist: $STX_DIST
   PKG_GITREVCOUNT: true
```

* In stx-builder pod
```
cd $STX_BUILD_HOME

# re-download the source pkg
downloader -s

# re-build
build-pkgs -c -p crictl
```