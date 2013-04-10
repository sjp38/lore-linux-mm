Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 808D36B0037
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 18:15:30 -0400 (EDT)
Received: by mail-ie0-f201.google.com with SMTP id a11so235905iee.0
        for <linux-mm@kvack.org>; Wed, 10 Apr 2013 15:15:29 -0700 (PDT)
Subject: + mm-reinititalise-user-and-admin-reserves-if-memory-is-added-or-removed-fix-fix.patch added to -mm tree
From: akpm@linux-foundation.org
Date: Wed, 10 Apr 2013 15:15:28 -0700
Message-Id: <20130410221528.D866F31C107@corp2gmr1-1.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org
Cc: akpm@linux-foundation.org, agshew@gmail.com, linux-mm@kvack.org


The patch titled
     Subject: mm-reinititalise-user-and-admin-reserves-if-memory-is-added-or-removed-fix-fix
has been added to the -mm tree.  Its filename is
     mm-reinititalise-user-and-admin-reserves-if-memory-is-added-or-removed-fix-fix.patch

Before you just go and hit "reply", please:
   a) Consider who else should be cc'ed
   b) Prefer to cc a suitable mailing list as well
   c) Ideally: find the original patch on the mailing list and do a
      reply-to-all to that, adding suitable additional cc's

*** Remember to use Documentation/SubmitChecklist when testing your code ***

The -mm tree is included into linux-next and is updated
there every 3-4 working days

------------------------------------------------------
From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-reinititalise-user-and-admin-reserves-if-memory-is-added-or-removed-fix-fix

init_user_reserve() and init_admin_reserve can no longer be __meminit

Cc: <linux-mm@kvack.org>
Cc: Andrew Shewmaker <agshew@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/mmap.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN mm/mmap.c~mm-reinititalise-user-and-admin-reserves-if-memory-is-added-or-removed-fix-fix mm/mmap.c
--- a/mm/mmap.c~mm-reinititalise-user-and-admin-reserves-if-memory-is-added-or-removed-fix-fix
+++ a/mm/mmap.c
@@ -3112,7 +3112,7 @@ void __init mmap_init(void)
  * The default value is min(3% of free memory, 128MB)
  * 128MB is enough to recover with sshd/login, bash, and top/kill.
  */
-static int __meminit init_user_reserve(void)
+static int init_user_reserve(void)
 {
 	unsigned long free_kbytes;
 
@@ -3133,7 +3133,7 @@ module_init(init_user_reserve)
  * with sshd, bash, and top in OVERCOMMIT_GUESS. Smaller systems will
  * only reserve 3% of free pages by default.
  */
-static int __meminit init_admin_reserve(void)
+static int init_admin_reserve(void)
 {
 	unsigned long free_kbytes;
 
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
mm-limit-growth-of-3%-hardcoded-other-user-reserve.patch
mm-limit-growth-of-3%-hardcoded-other-user-reserve-fix.patch
mm-replace-hardcoded-3%-with-admin_reserve_pages-knob.patch
mm-replace-hardcoded-3%-with-admin_reserve_pages-knob-fix.patch
mm-reinititalise-user-and-admin-reserves-if-memory-is-added-or-removed-fix.patch
mm-reinititalise-user-and-admin-reserves-if-memory-is-added-or-removed-fix-fix.patch
resource-add-release_mem_region_adjustable-fix.patch
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
