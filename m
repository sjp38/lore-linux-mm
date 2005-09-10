Message-Id: <200509100848.j8A8mtwf007883@shell0.pdx.osdl.net>
Subject: mm-try-to-allocate-higher-order-pages-in-rmqueue_bulk-fix.patch added to -mm tree
From: akpm@osdl.org
Date: Sat, 10 Sep 2005 01:48:31 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, linux-mm@kvack.org, rohit.seth@intel.com, mm-commits@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The patch titled

     mm-try-to-allocate-higher-order-pages-in-rmqueue_bulk fix

has been added to the -mm tree.  Its filename is

     mm-try-to-allocate-higher-order-pages-in-rmqueue_bulk-fix.patch

ntfs-build-fix.patch
timeh-remove-ifdefs.patch
seclvl-use-securityfs-tidy.patch
git-ia64-fixup.patch
git-input-fixup.patch
git-jfs-fixup.patch
git-ocfs2-prep.patch
pci-block-config-access-during-bist-fix-42.patch
x86_64-msr-merge-fix.patch
mm-try-to-allocate-higher-order-pages-in-rmqueue_bulk-fix.patch
memory-hotplug-i386-addition-functions-warning-fix.patch
pcnet32-set_ringparam-implementation-tidy.patch
s2io-warning-fixes.patch
acx1xx-wireless-driver-usb-is-bust.patch
acx1xx-allow-modular-build.patch
acx1xx-wireless-driver-spy_offset-went-away.patch
x86-cache-pollution-aware-__copy_from_user_ll-tidy.patch
x86-cache-pollution-aware-__copy_from_user_ll-build-fix.patch
x86-cache-pollution-aware-__copy_from_user_ll-build-fix-2.patch
x86_64-div-by-zero-fix.patch
serial-console-touch-nmi-watchdog.patch
ide-scsi-highmem-cleanup.patch
free-initrd-mem-adjustment-fix.patch
parport-constification-fix.patch
dlm-use-configfs-fix.patch
pcmcia-new-suspend-core-dev_to_instance-fix.patch
ingo-nfs-stuff-fix.patch
nr_blockdev_pages-in_interrupt-warning.patch
sysfs-crash-debugging.patch
device-suspend-debug.patch
add-stack-field-to-task_struct-ia64-fix.patch
reiser4-swsusp-build-fix.patch
reiser4-printk-warning-fix.patch
reiser4-mm-remove-pg_highmem-fix.patch



From: Andrew Morton <akpm@osdl.org>

It was wrong for (order > 0).

Signed-off-by: Rohit Seth <rohit.seth@intel.com>
Cc: <linux-mm@kvack.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 mm/page_alloc.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN mm/page_alloc.c~mm-try-to-allocate-higher-order-pages-in-rmqueue_bulk-fix mm/page_alloc.c
--- devel/mm/page_alloc.c~mm-try-to-allocate-higher-order-pages-in-rmqueue_bulk-fix	2005-09-10 01:47:24.000000000 -0700
+++ devel-akpm/mm/page_alloc.c	2005-09-10 01:47:24.000000000 -0700
@@ -520,7 +520,7 @@ static int rmqueue_bulk(struct zone *zon
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
