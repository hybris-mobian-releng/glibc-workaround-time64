ifeq (,$(filter stage1 stage2, $(DEB_BUILD_PROFILES)))
# We use -mno-tls-direct-seg-refs to not wrap-around segments, as it
# greatly increase the speed when running under the 32bit Xen hypervisor.
GLIBC_PASSES += xen
DEB_ARCH_REGULAR_PACKAGES += libc0.3-xen
xen_extra_cflags = -mno-tls-direct-seg-refs
xen_slibdir = /lib/$(DEB_HOST_MULTIARCH)/i686/nosegneg
xen_add-ons = $(libc_add-ons)

define libc0.3-dev_extra_pkg_install
mkdir -p debian/libc0.3-dev/$(libdir)/xen
cp -af debian/tmp-xen/$(libdir)/*.a \
	debian/libc0.3-dev/$(libdir)/xen
endef
endif

# Glibc should really do this ld.so link for us.
define libc_extra_install
mkdir -p debian/tmp-$(curpass)/lib
ln -s ld.so.1 debian/tmp-$(curpass)/lib/ld.so
mkdir -p debian/tmp-$(curpass)/usr/include/$(DEB_HOST_MULTIARCH)/mach
mv debian/tmp-$(curpass)/usr/include/mach/i386 debian/tmp-$(curpass)/usr/include/$(DEB_HOST_MULTIARCH)/mach/
ln -s ../$(DEB_HOST_MULTIARCH)/mach/i386 debian/tmp-$(curpass)/usr/include/mach/i386
endef

# FIXME: We are having runtime issues with ifunc...
# e.g. calling memset from a statically-linked program
#
# http://www.gnu.org/software/hurd/open_issues/ifunc.html
#
# For now we are just disabling ifunc:
export libc_cv_ld_gnu_indirect_function=no
