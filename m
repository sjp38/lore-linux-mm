Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id D800B6B0006
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 16:48:21 -0400 (EDT)
Received: by mail-qc0-f201.google.com with SMTP id o22so183835qcr.4
        for <linux-mm@kvack.org>; Thu, 11 Apr 2013 13:48:20 -0700 (PDT)
Subject: [folded-merged] mm-reinititalise-user-and-admin-reserves-if-memory-is-added-or-removed-fix.patch removed from -mm tree
From: akpm@linux-foundation.org
Date: Thu, 11 Apr 2013 13:48:20 -0700
Message-Id: <20130411204820.5119E31C27F@corp2gmr1-1.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, agshew@gmail.com, linux-mm@kvack.org, mm-commits@vger.kernel.org


The patch titled
     Subject: mm-reinititalise-user-and-admin-reserves-if-memory-is-added-or-removed-fix
has been removed from the -mm tree.  Its filename was
     mm-reinititalise-user-and-admin-reserves-if-memory-is-added-or-removed-fix.patch

This patch was dropped because it was folded into mm-reinititalise-user-and-admin-reserves-if-memory-is-added-or-removed.patch

------------------------------------------------------
From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-reinititalise-user-and-admin-reserves-if-memory-is-added-or-removed-fix

use register_hotmemory_notifier()

Cc: <linux-mm@kvack.org>
Cc: Andrew Shewmaker <agshew@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/mmap.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN mm/mmap.c~mm-reinititalise-user-and-admin-reserves-if-memory-is-added-or-removed-fix mm/mmap.c
--- a/mm/mmap.c~mm-reinititalise-user-and-admin-reserves-if-memory-is-added-or-removed-fix
+++ a/mm/mmap.c
@@ -3198,7 +3198,7 @@ static struct notifier_block reserve_mem
 
 int __meminit init_reserve_notifier(void)
 {
-	if (register_memory_notifier(&reserve_mem_nb))
+	if (register_hotmemory_notifier(&reserve_mem_nb))
 		printk("Failed registering memory add/remove notifier for admin reserve");
 
 	return 0;
_

Patches currently in -mm which might be from akpm@linux-foundation.org are

linux-next.patch
arch-alpha-kernel-systblss-remove-debug-check.patch
i-need-old-gcc.patch
revert-ipc-dont-allocate-a-copy-larger-than-max.patch
mips-define-kvm_user_mem_slots.patch
auditsc-use-kzalloc-instead-of-kmallocmemset-fix.patch
drivers-video-implement-a-simple-framebuffer-driver-fix.patch
timer_list-convert-timer-list-to-be-a-proper-seq_file.patch
posix-timers-correctly-get-dying-task-time-sample-in-posix_cpu_timer_schedule.patch
mm.patch
mm-shmemc-remove-an-ifdef.patch
xen-tmem-enable-xen-tmem-shim-to-be-built-loaded-as-a-module-fix.patch
memcg-relax-memcg-iter-caching-checkpatch-fixes.patch
mm-make-snapshotting-pages-for-stable-writes-a-per-bio-operation.patch
kexec-vmalloc-export-additional-vmalloc-layer-information-fix.patch
mm-hugetlb-include-hugepages-in-meminfo-checkpatch-fixes.patch
mm-speedup-in-__early_pfn_to_nid.patch
mm-speedup-in-__early_pfn_to_nid-fix.patch
include-linux-memoryh-implement-register_hotmemory_notifier.patch
ipc-utilc-use-register_hotmemory_notifier.patch
mm-slubc-use-register_hotmemory_notifier.patch
drivers-base-nodec-switch-to-register_hotmemory_notifier.patch
fs-proc-kcorec-use-register_hotmemory_notifier.patch
kernel-cpusetc-use-register_hotmemory_notifier.patch
mm-limit-growth-of-3%-hardcoded-other-user-reserve.patch
mm-replace-hardcoded-3%-with-admin_reserve_pages-knob.patch
mm-reinititalise-user-and-admin-reserves-if-memory-is-added-or-removed.patch
mm-reinititalise-user-and-admin-reserves-if-memory-is-added-or-removed-fix-fix.patch
resource-add-release_mem_region_adjustable-fix.patch
resource-add-release_mem_region_adjustable-fix-fix.patch
mm-madvise-complete-input-validation-before-taking-lock-fix.patch
include-linux-mmzoneh-cleanups.patch
include-linux-mmzoneh-cleanups-fix.patch
drop_caches-add-some-documentation-and-info-messsge.patch
memcg-debugging-facility-to-access-dangling-memcgs-fix.patch
genalloc-add-devres-support-allow-to-find-a-managed-pool-by-device-fix.patch
genalloc-add-devres-support-allow-to-find-a-managed-pool-by-device-fix-fix.patch
misc-generic-on-chip-sram-allocation-driver-fix.patch
kernel-smpc-cleanups.patch
early_printk-consolidate-random-copies-of-identical-code-v3-fix.patch
include-linux-printkh-include-stdargh.patch
get_maintainer-use-filename-only-regex-match-for-tegra-fix.patch
argv_split-teach-it-to-handle-mutable-strings-fix.patch
kernel-timerc-ove-some-non-timer-related-syscalls-to-kernel-sysc-checkpatch-fixes.patch
epoll-trim-epitem-by-one-cache-line-on-x86_64-fix.patch
binfmt_elfc-use-get_random_int-to-fix-entropy-depleting.patch
init-mainc-convert-to-pr_foo.patch
rtc-ds1307-long-block-operations-bugfix.patch
hfsplus-fix-warnings-in-fs-hfsplus-bfindc-in-function-hfs_find_1st_rec_by_cnid-fix.patch
usermodehelper-export-_exec-and-_setup-functions-fix.patch
kexec-use-min_t-to-simplify-logic-fix.patch
ipc-introduce-obtaining-a-lockless-ipc-object-fix.patch
ipcsem-open-code-and-rename-sem_lock-fix.patch
ipc-sysv-shared-memory-limited-to-8tib-fix.patch
kernel-pidc-improve-flow-of-a-loop-inside-alloc_pidmap-fix.patch
pid_namespacec-h-simplify-defines-fix.patch
drivers-net-rename-random32-to-prandom_u32-fix.patch
gadget-remove-only-user-of-aio-retry-checkpatch-fixes.patch
aio-remove-retry-based-aio-checkpatch-fixes.patch
aio-add-kiocb_cancel.patch
aio-make-aio_put_req-lockless-checkpatch-fixes.patch
aio-refcounting-cleanup-checkpatch-fixes.patch
wait-add-wait_event_hrtimeout.patch
aio-make-aio_read_evt-more-efficient-convert-to-hrtimers-checkpatch-fixes.patch
aio-use-cancellation-list-lazily.patch
aio-give-shared-kioctx-fields-their-own-cachelines.patch
generic-dynamic-per-cpu-refcounting.patch
generic-dynamic-per-cpu-refcounting-checkpatch-fixes.patch
aio-dont-include-aioh-in-schedh.patch
aio-dont-include-aioh-in-schedh-fix.patch
aio-kill-ki_retry.patch
aio-kill-ki_retry-fix.patch
aio-kill-ki_retry-checkpatch-fixes.patch
block-prep-work-for-batch-completion-checkpatch-fixes.patch
block-prep-work-for-batch-completion-fix-2.patch
block-prep-work-for-batch-completion-fix-3.patch
block-prep-work-for-batch-completion-fix-3-fix.patch
block-aio-batch-completion-for-bios-kiocbs.patch
block-aio-batch-completion-for-bios-kiocbs-checkpatch-fixes.patch
block-aio-batch-completion-for-bios-kiocbs-fix.patch
lib-add-lz4-compressor-module-fix.patch
crypto-add-lz4-cryptographic-api-fix.patch
debugging-keep-track-of-page-owners-fix-2-fix.patch
debugging-keep-track-of-page-owners-fix-2-fix-fix-fix.patch
journal_add_journal_head-debug.patch
kernel-forkc-export-kernel_thread-to-modules.patch
mutex-subsystem-synchro-test-module.patch
slab-leaks3-default-y.patch
put_bh-debug.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
