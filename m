Message-Id: <200509241824.j8OIOsIn021216@shell0.pdx.osdl.net>
Subject: - mm-try-to-allocate-higher-order-pages-in-rmqueue_bulk-fix.patch removed from -mm tree
From: akpm@osdl.org
Date: Sat, 24 Sep 2005 11:24:14 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, linux-mm@kvack.org, rohit.seth@intel.com, mm-commits@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The patch titled

     mm-try-to-allocate-higher-order-pages-in-rmqueue_bulk fix

has been removed from the -mm tree.  Its filename is

     mm-try-to-allocate-higher-order-pages-in-rmqueue_bulk-fix.patch

This patch was probably dropped from -mm because
it has already been merged into a subsystem tree
or into Linus's tree


From: Andrew Morton <akpm@osdl.org>

It was wrong for (order > 0).

Signed-off-by: Rohit Seth <rohit.seth@intel.com>
Cc: <linux-mm@kvack.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 mm/page_alloc.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN mm/page_alloc.c~mm-try-to-allocate-higher-order-pages-in-rmqueue_bulk-fix mm/page_alloc.c
--- devel/mm/page_alloc.c~mm-try-to-allocate-higher-order-pages-in-rmqueue_bulk-fix	2005-09-22 22:52:19.000000000 -0700
+++ devel-akpm/mm/page_alloc.c	2005-09-22 22:52:19.000000000 -0700
@@ -521,7 +521,7 @@ static int rmqueue_bulk(struct zone *zon
 		page = __rmqueue(zone, norder);
 		if (page != NULL) {
 			allocated += (1 << norder);
-			for (i = 0; i < (1 << norder); i++)
+			for (i = 0; i < (1 << norder); i += (1 << order))
 				list_add_tail(&page[i].lru, list);
 			norder++;
 		}
_

Patches currently in -mm which might be from akpm@osdl.org are

atyfb-c99-fix.patch
revert-oversized-kmalloc-check.patch
posix-timers-smp-race-condition-tidy.patch
increase-maximum-kmalloc-size-to-256k-fix.patch
git-acpi-pciehprm_acpi-fix.patch
git-acpi-build-fix-2.patch
pnpacpi-handle-address-descriptors-in-_prs-fix-for-git-acpi-change.patch
drm_addmap_ioctl-warning-fix.patch
sisusb-warning-fix.patch
gregkh-usb-usb-power-state-03-fix.patch
gregkh-usb-usb-handoff-merge-usb-Makefile-fix.patch
x86_64-no-idle-tick-fix.patch
x86_64-no-idle-tick-fix-2.patch
x86_64-mce-thresh-fix.patch
x86_64-mce-thresh-fix-2.patch
mm-try-to-allocate-higher-order-pages-in-rmqueue_bulk.patch
mm-try-to-allocate-higher-order-pages-in-rmqueue_bulk-fix.patch
memory-hotplug-i386-addition-functions-warning-fix.patch
3c59x-support-ethtool_gpermaddr-fix.patch
acx1xx-wireless-driver-usb-is-bust.patch
acx1xx-allow-modular-build.patch
acx1xx-wireless-driver-spy_offset-went-away.patch
selinux-canonicalize-getxattr-fix.patch
x86-cache-pollution-aware-__copy_from_user_ll-tidy.patch
x86-cache-pollution-aware-__copy_from_user_ll-build-fix.patch
x86-cache-pollution-aware-__copy_from_user_ll-build-fix-2.patch
x86-gdt-page-isolation-fix.patch
x86_64-div-by-zero-fix.patch
convert-proc-devices-to-use-seq_file-interface-tidy.patch
serial-console-touch-nmi-watchdog.patch
ide-scsi-highmem-cleanup.patch
new-omnikey-cardman-4040-driver-fixes.patch
cm4040-min-fix.patch
cm4040-fixes.patch
new-omnikey-cardman-4000-driver-fixes.patch
clear_buffer_uptodate-in-discard_buffer-check.patch
introduce-setup_timer-helper-x86_64-fix.patch
switch-sibyte-profiling-driver-to-compat_ioctl-fix.patch
use-alloc_percpu-to-allocate-workqueues-locally-fix.patch
remove-timer-debug-fields.patch
bioscalls-cleanup.patch
as-cooperating-processes-cant-spel.patch
as-tidy.patch
parport-constification-fix.patch
dlm-use-configfs-fix.patch
pcmcia-new-suspend-core-dev_to_instance-fix.patch
page-owner-tracking-leak-detector-fix.patch
page-owner-tracking-leak-detector-oops-fix-tidy.patch
nr_blockdev_pages-in_interrupt-warning.patch
sysfs-crash-debugging.patch
device-suspend-debug.patch
add-stack-field-to-task_struct-ia64-fix.patch
reiser4-only.patch
reiser4-swsusp-build-fix.patch
reiser4-printk-warning-fix.patch
reiser4-mm-remove-pg_highmem-fix.patch
reiser4-big-update-div64-fix.patch
reiser4-remove-c99isms.patch
tty-layer-buffering-revamp-pmac_zilog-warning-fix.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
