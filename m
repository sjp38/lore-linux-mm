Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6F97A6B0253
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 18:30:29 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id le9so14053696pab.0
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 15:30:29 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a16si5263463pfj.8.2016.08.11.15.30.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Aug 2016 15:30:28 -0700 (PDT)
Date: Thu, 11 Aug 2016 15:30:27 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2016-08-11-15-29 uploaded
Message-ID: <57acfc83.m1jfhXlimbkvzxCS%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2016-08-11-15-29 has been uploaded to

   http://www.ozlabs.org/~akpm/mmotm/

mmotm-readme.txt says

README for mm-of-the-moment:

http://www.ozlabs.org/~akpm/mmotm/

This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
more than once a week.

You will need quilt to apply these patches to the latest Linus release (4.x
or 4.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
http://ozlabs.org/~akpm/mmotm/series

The file broken-out.tar.gz contains two datestamp files: .DATE and
.DATE-yyyy-mm-dd-hh-mm-ss.  Both contain the string yyyy-mm-dd-hh-mm-ss,
followed by the base kernel version against which this patch series is to
be applied.

This tree is partially included in linux-next.  To see which patches are
included in linux-next, consult the `series' file.  Only the patches
within the #NEXT_PATCHES_START/#NEXT_PATCHES_END markers are included in
linux-next.

A git tree which contains the memory management portion of this tree is
maintained at git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
by Michal Hocko.  It contains the patches which are between the
"#NEXT_PATCHES_START mm" and "#NEXT_PATCHES_END" markers, from the series
file, http://www.ozlabs.org/~akpm/mmotm/series.


A full copy of the full kernel tree with the linux-next and mmotm patches
already applied is available through git within an hour of the mmotm
release.  Individual mmotm releases are tagged.  The master branch always
points to the latest release, so it's constantly rebasing.

http://git.cmpxchg.org/cgit.cgi/linux-mmotm.git/

To develop on top of mmotm git:

  $ git remote add mmotm git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
  $ git remote update mmotm
  $ git checkout -b topic mmotm/master
  <make changes, commit>
  $ git send-email mmotm/master.. [...]

To rebase a branch with older patches to a new mmotm release:

  $ git remote update mmotm
  $ git rebase --onto mmotm/master <topic base> topic




The directory http://www.ozlabs.org/~akpm/mmots/ (mm-of-the-second)
contains daily snapshots of the -mm tree.  It is updated more frequently
than mmotm, and is untested.

A git copy of this tree is available at

	http://git.cmpxchg.org/cgit.cgi/linux-mmots.git/

and use of this tree is similar to
http://git.cmpxchg.org/cgit.cgi/linux-mmotm.git/, described above.


This mmotm tree contains the following patches against 4.8-rc1:
(patches marked "*" will be included in linux-next)

  origin.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  i-need-old-gcc.patch
* mm-fix-the-incorrect-hugepages-count.patch
* proc-meminfo-use-correct-helpers-for-calculating-lru-sizes-in-meminfo.patch
* mm-memcontrol-fix-swap-counter-leak-on-swapout-from-offline-cgroup.patch
* mm-memcontrol-fix-swap-counter-leak-on-swapout-from-offline-cgroup-fix.patch
* mm-memcontrol-fix-memcg-id-ref-counter-on-swap-charge-move.patch
* kasan-remove-the-unnecessary-warn_once-from-quarantinec.patch
* mm-oom-fix-uninitialized-ret-in-task_will_free_mem.patch
* mm-initialize-per_cpu_nodestats-for-hotadded-pgdats.patch
* byteswap-dont-use-__builtin_bswap-with-sparse.patch
* mm-page_alloc-replace-set_dma_reserve-to-set_memory_reserve.patch
* fadump-register-the-memory-reserved-by-fadump.patch
* mm-slab-improve-performance-of-gathering-slabinfo-stats.patch
* kthread-rename-probe_kthread_data-to-kthread_probe_data.patch
* kthread-kthread-worker-api-cleanup.patch
* kthread-smpboot-do-not-park-in-kthread_create_on_cpu.patch
* kthread-allow-to-call-__kthread_create_on_node-with-va_list-args.patch
* kthread-add-kthread_create_worker.patch
* kthread-add-kthread_destroy_worker.patch
* kthread-detect-when-a-kthread-work-is-used-by-more-workers.patch
* kthread-initial-support-for-delayed-kthread-work.patch
* kthread-allow-to-cancel-kthread-work.patch
* kthread-allow-to-modify-delayed-kthread-work.patch
* kthread-better-support-freezable-kthread-workers.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* kbuild-simpler-generation-of-assembly-constants.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* kernel-watchdog-use-nmi-registers-snapshot-in-hardlockup-handler.patch
  mm.patch
* mm-oom-deduplicate-victim-selection-code-for-memcg-and-global-oom.patch
* mm-zsmalloc-add-trace-events-for-zs_compact.patch
* mm-zsmalloc-add-per-class-compact-trace-event.patch
* mm-vmalloc-fix-align-value-calculation-error.patch
* mm-vmalloc-fix-align-value-calculation-error-fix.patch
* mm-vmalloc-fix-align-value-calculation-error-v2.patch
* mm-vmalloc-fix-align-value-calculation-error-v2-fix.patch
* mm-vmalloc-fix-align-value-calculation-error-v2-fix-fix.patch
* mm-memcontrol-add-sanity-checks-for-memcg-idref-on-get-put.patch
* mm-oom_killc-fix-task_will_free_mem-comment.patch
* mm-compaction-make-whole_zone-flag-ignore-cached-scanner-positions.patch
* mm-compaction-make-whole_zone-flag-ignore-cached-scanner-positions-checkpatch-fixes.patch
* mm-compaction-cleanup-unused-functions.patch
* mm-compaction-rename-compact_partial-to-compact_success.patch
* mm-compaction-dont-recheck-watermarks-after-compact_success.patch
* mm-compaction-add-the-ultimate-direct-compaction-priority.patch
* mm-compaction-more-reliably-increase-direct-compaction-priority.patch
* mm-compaction-use-correct-watermark-when-checking-compaction-success.patch
* mm-compaction-create-compact_gap-wrapper.patch
* mm-compaction-use-proper-alloc_flags-in-__compaction_suitable.patch
* mm-compaction-require-only-min-watermarks-for-non-costly-orders.patch
* mm-vmscan-make-compaction_ready-more-accurate-and-readable.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* mm-walk-the-zone-in-pageblock_nr_pages-steps.patch
* proc-much-faster-proc-vmstat.patch
* proc-faster-proc-status.patch
* seq-proc-modify-seq_put_decimal_ll-to-take-a-const-char-not-char.patch
* seq-proc-modify-seq_put_decimal_ll-to-take-a-const-char-not-char-fix.patch
* meminfo-break-apart-a-very-long-seq_printf-with-ifdefs.patch
* proc-relax-proc-tid-timerslack_ns-capability-requirements.patch
* proc-add-lsm-hook-checks-to-proc-tid-timerslack_ns.patch
* console-dont-prefer-first-registered-if-dt-specifies-stdout-path.patch
* lib-add-crc64-ecma-module.patch
* compat-remove-compat_printk.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* rapidio-rio_cm-use-memdup_user-instead-of-duplicating-code.patch
* random-simplify-api-for-random-address-requests.patch
* random-simplify-api-for-random-address-requests-v2.patch
* x86-use-simpler-api-for-random-address-requests.patch
* x86-use-simpler-api-for-random-address-requests-v2.patch
* arm-use-simpler-api-for-random-address-requests.patch
* arm-use-simpler-api-for-random-address-requests-v2.patch
* arm64-use-simpler-api-for-random-address-requests.patch
* arm64-use-simpler-api-for-random-address-requests-v2.patch
* tile-use-simpler-api-for-random-address-requests.patch
* tile-use-simpler-api-for-random-address-requests-v2.patch
* unicore32-use-simpler-api-for-random-address-requests.patch
* unicore32-use-simpler-api-for-random-address-requests-v2.patch
* random-remove-unused-randomize_range.patch
* dma-mapping-introduce-the-dma_attr_no_warn-attribute.patch
* powerpc-implement-the-dma_attr_no_warn-attribute.patch
* nvme-use-the-dma_attr_no_warn-attribute.patch
* x86-panic-replace-smp_send_stop-with-kdump-friendly-version-in-panic-path.patch
* mips-panic-replace-smp_send_stop-with-kdump-friendly-version-in-panic-path.patch
* relay-use-per-cpu-constructs-for-the-relay-channel-buffer-pointers.patch
* config-android-remove-config_ipv6_privacy.patch
* ipc-semc-fix-complex_count-vs-simple-op-race.patch
* ipc-msg-implement-lockless-pipelined-wakeups.patch
* ipc-msg-batch-queue-sender-wakeups.patch
* ipc-msg-make-ss_wakeup-kill-arg-boolean.patch
* ipc-msg-lockless-security-checks-for-msgsnd.patch
* ipc-msg-avoid-waking-sender-upon-full-queue.patch
* ipc-msg-avoid-waking-sender-upon-full-queue-checkpatch-fixes.patch
  linux-next.patch
* drivers-net-wireless-intel-iwlwifi-dvm-calibc-fix-min-warning.patch
* mm-writeback-flush-plugged-io-in-wakeup_flusher_threads.patch
  mm-add-strictlimit-knob-v2.patch
  make-sure-nobodys-leaking-resources.patch
  releasing-resources-with-children.patch
  make-frame_pointer-default=y.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  mutex-subsystem-synchro-test-module.patch
  slab-leaks3-default-y.patch
  add-debugging-aid-for-memory-initialisation-problems.patch
  workaround-for-a-pci-restoring-bug.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
