Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9BE6E6B025E
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 19:09:53 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ez1so10053046pab.0
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 16:09:53 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w64si4458047pfb.137.2016.07.13.16.09.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 16:09:52 -0700 (PDT)
Date: Wed, 13 Jul 2016 16:09:51 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2016-07-13-16-09 uploaded
Message-ID: <5786ca3f.b2lRkftGPEpj1W28%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2016-07-13-16-09 has been uploaded to

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


This mmotm tree contains the following patches against 4.7-rc7:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
* mm-compaction-prevent-vm_bug_on-when-terminating-freeing-scanner.patch
* mm-compaction-prevent-vm_bug_on-when-terminating-freeing-scanner-fix.patch
* kasan-add-newline-to-messages.patch
* scripts-gdb-silence-nothing-to-do-message.patch
* scripts-gdb-rebuild-constantspy-on-dependancy-change.patch
* scripts-gdb-add-constantspy-to-gitignore.patch
* scripts-gdb-perform-path-expansion-to-lx-symbols-arguments.patch
* revert-scripts-gdb-add-a-radix-tree-parser.patch
* revert-scripts-gdb-add-documentation-example-for-radix-tree.patch
* madvise_free-thp-fix-madvise_free_huge_pmd-return-value-after-splitting.patch
* uapi-export-lirch-header.patch
* kasan-quarantine-fix-bugs-on-qlist_move_cache.patch
* mm-meminit-always-return-a-valid-node-from-early_pfn_to_nid.patch
* mm-meminit-ensure-node-is-online-before-checking-whether-pages-are-uninitialised.patch
* added-support-for-gcc-version-=-6.patch
* vmlinuxlds-account-for-destructor-sections.patch
* mm-thp-move-pmd-check-inside-ptl-for-freeze_page.patch
* mm-rmap-call-page_check_address-with-sync-enabled-to-avoid-racy-check.patch
* mm-thp-refix-false-positive-bug-in-page_move_anon_rmap.patch
* mm-workingset-printk-missing-log-level-use-pr_info.patch
* m32r-fix-build-warning-about-putc.patch
* arm-get-rid-of-superfluous-__gfp_repeat.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* dma-debug-track-bucket-lock-state-for-static-checkers.patch
* cflags-add-wunused-but-set-parameter.patch
* kbuild-simpler-generation-of-assembly-constants.patch
* scripts-bloat-o-meter-fix-percent-on-1%-changes.patch
* m32r-add-__ucmpdi2-to-fix-build-failure.patch
* debugobjectsh-fix-trivial-kernel-doc-warning.patch
* ocfs2-fix-a-redundant-re-initialization.patch
* ocfs2-improve-recovery-performance.patch
* ocfs2-improve-recovery-performance-v2.patch
* ocfs2-improve-recovery-performance-v2-fix.patch
* ocfs2-cleanup-unneeded-goto-in-ocfs2_create_new_inode_locks.patch
* ocfs2-dlm-fix-memory-leak-of-dlm_debug_ctxt.patch
* ocfs2-cleanup-implemented-prototypes.patch
* ocfs2-remove-obscure-bug_on-in-dlmglue.patch
* ocfs2-insure-dlm-lockspace-is-created-by-kernel-module.patch
* ocfs2-retry-on-enospc-if-sufficient-space-in-truncate-log.patch
* ocfs2-retry-on-enospc-if-sufficient-space-in-truncate-log-v3.patch
* ocfs2-dlm-disable-bug_on-when-dlm_lock_res_dropping_ref-is-cleared-before-dlm_deref_lockres_done_handler.patch
* ocfs2-dlm-disable-bug_on-when-dlm_lock_res_dropping_ref-is-cleared-before-dlm_deref_lockres_done_handler-fix.patch
* ocfs2-dlm-solve-a-bug-when-deref-failed-in-dlm_drop_lockres_ref.patch
* ocfs2-dlm-continue-to-purge-recovery-lockres-when-recovery-master-goes-down.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* sb-add-a-new-writeback-list-for-sync.patch
* wb-inode-writeback-list-tracking-tracepoints.patch
* kernel-watchdog-use-nmi-registers-snapshot-in-hardlockup-handler.patch
  mm.patch
* mm-reorganize-slab-freelist-randomization.patch
* mm-reorganize-slab-freelist-randomization-fix.patch
* mm-slub-freelist-randomization.patch
* slab-make-gfp_slab_bug_mask-information-more-human-readable.patch
* slab-do-not-panic-on-invalid-gfp_mask.patch
* mm-faster-kmalloc_array-kcalloc.patch
* mm-memcontrol-remove-the-useless-parameter-for-mc_handle_swap_pte.patch
* mm-init-fix-zone-boundary-creation.patch
* memory-hotplug-add-move_pfn_range.patch
* memory-hotplug-more-general-validation-of-zone-during-online.patch
* memory-hotplug-use-zone_can_shift-for-sysfs-valid_zones-attribute.patch
* mm-zap-zone_oom_locked.patch
* mm-oom-add-memcg-to-oom_control.patch
* mm-debug-add-vm_warn-which-maps-to-warn.patch
* powerpc-mm-check-for-irq-disabled-only-if-debug_vm-is-enabled.patch
* zram-rename-zstrm-find-release-functions.patch
* zram-switch-to-crypto-compress-api.patch
* zram-use-crypto-api-to-check-alg-availability.patch
* zram-use-crypto-api-to-check-alg-availability-v3.patch
* zram-cosmetic-cleanup-documentation.patch
* zram-delete-custom-lzo-lz4.patch
* zram-delete-custom-lzo-lz4-v3.patch
* zram-add-more-compression-algorithms.patch
* zram-add-more-compression-algorithms-v3.patch
* zram-drop-gfp_t-from-zcomp_strm_alloc.patch
* mm-use-put_page-to-free-page-instead-of-putback_lru_page.patch
* mm-migrate-support-non-lru-movable-page-migration.patch
* mm-migrate-support-non-lru-movable-page-migration-fix.patch
* mm-balloon-use-general-non-lru-movable-page-feature.patch
* mm-balloon-use-general-non-lru-movable-page-feature-fix.patch
* zsmalloc-keep-max_object-in-size_class.patch
* zsmalloc-use-bit_spin_lock.patch
* zsmalloc-use-accessor.patch
* zsmalloc-factor-page-chain-functionality-out.patch
* zsmalloc-introduce-zspage-structure.patch
* zsmalloc-separate-free_zspage-from-putback_zspage.patch
* zsmalloc-use-freeobj-for-index.patch
* zsmalloc-page-migration-support.patch
* zsmalloc-page-migration-support-fix.patch
* zsmalloc-page-migration-support-fix-2.patch
* zram-use-__gfp_movable-for-memory-allocation.patch
* zsmalloc-use-obj_tag_bit-for-bit-shifter.patch
* mm-compaction-split-freepages-without-holding-the-zone-lock.patch
* mm-compaction-split-freepages-without-holding-the-zone-lock-fix.patch
* mm-compaction-split-freepages-without-holding-the-zone-lock-fix-2.patch
* mm-page_owner-initialize-page-owner-without-holding-the-zone-lock.patch
* mm-page_owner-copy-last_migrate_reason-in-copy_page_owner.patch
* mm-page_owner-introduce-split_page_owner-and-replace-manual-handling.patch
* tools-vm-page_owner-increase-temporary-buffer-size.patch
* mm-page_owner-use-stackdepot-to-store-stacktrace.patch
* mm-page_owner-use-stackdepot-to-store-stacktrace-v3.patch
* mm-page_alloc-introduce-post-allocation-processing-on-page-allocator.patch
* mm-page_alloc-introduce-post-allocation-processing-on-page-allocator-v3.patch
* mm-page_isolation-clean-up-confused-code.patch
* mm-thp-check-pmd_trans_unstable-after-split_huge_pmd.patch
* mm-hugetlb-simplify-hugetlb-unmap.patch
* mm-change-the-interface-for-__tlb_remove_page.patch
* mm-change-the-interface-for-__tlb_remove_page-v3.patch
* mm-mmu_gather-track-page-size-with-mmu-gather-and-force-flush-if-page-size-change.patch
* mm-remove-pointless-struct-in-struct-page-definition.patch
* mm-clean-up-non-standard-page-_mapcount-users.patch
* mm-memcontrol-cleanup-kmem-charge-functions.patch
* mm-charge-uncharge-kmemcg-from-generic-page-allocator-paths.patch
* mm-memcontrol-teach-uncharge_list-to-deal-with-kmem-pages.patch
* arch-x86-charge-page-tables-to-kmemcg.patch
* pipe-account-to-kmemcg.patch
* af_unix-charge-buffers-to-kmemcg.patch
* mmoom-remove-unused-argument-from-oom_scan_process_thread.patch
* mm-frontswap-convert-frontswap_enabled-to-static-key.patch
* mm-frontswap-convert-frontswap_enabled-to-static-key-checkpatch-fixes.patch
* mm-add-nr_zsmalloc-to-vmstat.patch
* mm-add-nr_zsmalloc-to-vmstat-fix.patch
* mm-add-nr_zsmalloc-to-vmstat-fix-2.patch
* include-linux-memblockh-clean-up-code-for-several-trivial-details.patch
* mm-oom_reaper-make-sure-that-mmput_async-is-called-only-when-memory-was-reaped.patch
* mm-memcg-use-consistent-gfp-flags-during-readahead.patch
* mm-memcg-use-consistent-gfp-flags-during-readahead-fix.patch
* mm-memcg-use-consistent-gfp-flags-during-readahead-checkpatch-fixes.patch
* mm-memblock-if-nr_new-is-0-just-return.patch
* mm-make-optimistic-check-for-swapin-readahead.patch
* mm-make-optimistic-check-for-swapin-readahead-fix-2.patch
* mm-make-optimistic-check-for-swapin-readahead-fix-3.patch
* mm-make-optimistic-check-for-swapin-readahead-fix-4.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-2.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-3.patch
* mm-thp-make-swapin-readahead-under-down_read-of-mmap_sem-ks.patch
* mm-thp-make-swapin-readahead-under-down_read-of-mmap_sem-fix.patch
* mm-thp-fix-locking-inconsistency-in-collapse_huge_page.patch
* mm-thp-make-swapin-readahead-under-down_read-of-mmap_sem-fix-2-fix.patch
* khugepaged-recheck-pmd-after-mmap_sem-re-acquired.patch
* thp-mlock-update-unevictable-lrutxt.patch
* mm-do-not-pass-mm_struct-into-handle_mm_fault.patch
* mm-introduce-fault_env.patch
* mm-postpone-page-table-allocation-until-we-have-page-to-map.patch
* rmap-support-file-thp.patch
* mm-introduce-do_set_pmd.patch
* thp-vmstats-add-counters-for-huge-file-pages.patch
* thp-support-file-pages-in-zap_huge_pmd.patch
* thp-handle-file-pages-in-split_huge_pmd.patch
* thp-handle-file-cow-faults.patch
* thp-skip-file-huge-pmd-on-copy_huge_pmd.patch
* thp-prepare-change_huge_pmd-for-file-thp.patch
* thp-run-vma_adjust_trans_huge-outside-i_mmap_rwsem.patch
* thp-file-pages-support-for-split_huge_page.patch
* thp-mlock-do-not-mlock-pte-mapped-file-huge-pages.patch
* vmscan-split-file-huge-pages-before-paging-them-out.patch
* page-flags-relax-policy-for-pg_mappedtodisk-and-pg_reclaim.patch
* radix-tree-implement-radix_tree_maybe_preload_order.patch
* filemap-prepare-find-and-delete-operations-for-huge-pages.patch
* truncate-handle-file-thp.patch
* mm-rmap-account-shmem-thp-pages.patch
* shmem-prepare-huge=-mount-option-and-sysfs-knob.patch
* shmem-get_unmapped_area-align-huge-page.patch
* shmem-add-huge-pages-support.patch
* shmem-thp-respect-madv_nohugepage-for-file-mappings.patch
* thp-extract-khugepaged-from-mm-huge_memoryc.patch
* khugepaged-move-up_readmmap_sem-out-of-khugepaged_alloc_page.patch
* shmem-make-shmem_inode_info-lock-irq-safe.patch
* khugepaged-add-support-of-collapse-for-tmpfs-shmem-pages.patch
* thp-introduce-config_transparent_huge_pagecache.patch
* shmem-split-huge-pages-beyond-i_size-under-memory-pressure.patch
* thp-update-documentation-vm-transhugefilesystems-proctxt.patch
* mm-zsmalloc-add-trace-events-for-zs_compact.patch
* mm-fix-build-warnings-in-linux-compactionh.patch
* mm-fix-build-warnings-in-linux-compactionh-fix.patch
* mm-memcontrol-remove-bug_on-in-uncharge_list.patch
* mm-memcontrol-fix-documentation-for-compound-parameter.patch
* cgroup-fix-idr-leak-for-the-first-cgroup-root.patch
* cgroup-remove-unnecessary-0-check-from-css_from_id.patch
* mm-memcontrol-fix-cgroup-creation-failure-after-many-small-jobs.patch
* mm-memcontrol-fix-cgroup-creation-failure-after-many-small-jobs-fix.patch
* thp-fix-comments-of-__pmd_trans_huge_lock.patch
* proc-oom-drop-bogus-task_lock-and-mm-check.patch
* proc-oom-drop-bogus-sighand-lock.patch
* proc-oom_adj-extract-oom_score_adj-setting-into-a-helper.patch
* mm-oom_adj-make-sure-processes-sharing-mm-have-same-view-of-oom_score_adj.patch
* mm-oom-skip-vforked-tasks-from-being-selected.patch
* mm-oom-kill-all-tasks-sharing-the-mm.patch
* mm-oom-fortify-task_will_free_mem.patch
* mm-oom-task_will_free_mem-should-skip-oom_reaped-tasks.patch
* mm-oom_reaper-do-not-attempt-to-reap-a-task-more-than-twice.patch
* mm-oom-hide-mm-which-is-shared-with-kthread-or-global-init.patch
* mm-oom-fortify-task_will_free_mem-fix.patch
* mm-update-the-comment-in-__isolate_free_page.patch
* mm-update-the-comment-in-__isolate_free_page-checkpatch-fixes.patch
* ksm-set-anon_vma-of-first-rmap_item-of-ksm-page-to-pages-anon_vma-other-than-vmas-anon_vma.patch
* mm-fix-vm-scalability-regression-in-cgroup-aware-workingset-code.patch
* mm-fix-vm-scalability-regression-in-cgroup-aware-workingset-code-fix.patch
* mm-compaction-remove-unnecessary-order-check-in-try_to_compact_pages.patch
* freezer-oom-check-tif_memdie-on-the-correct-task.patch
* cpuset-mm-fix-tif_memdie-check-in-cpuset_change_task_nodemask.patch
* mm-meminit-remove-early_page_nid_uninitialised.patch
* mm-vmstat-add-infrastructure-for-per-node-vmstats.patch
* mm-vmscan-move-lru_lock-to-the-node.patch
* mm-vmscan-move-lru-lists-to-node.patch
* mm-mmzone-clarify-the-usage-of-zone-padding.patch
* mm-vmscan-begin-reclaiming-pages-on-a-per-node-basis.patch
* mm-vmscan-have-kswapd-only-scan-based-on-the-highest-requested-zone.patch
* mm-vmscan-make-kswapd-reclaim-in-terms-of-nodes.patch
* mm-vmscan-remove-balance-gap.patch
* mm-vmscan-simplify-the-logic-deciding-whether-kswapd-sleeps.patch
* mm-vmscan-by-default-have-direct-reclaim-only-shrink-once-per-node.patch
* mm-vmscan-remove-duplicate-logic-clearing-node-congestion-and-dirty-state.patch
* mm-vmscan-do-not-reclaim-from-kswapd-if-there-is-any-eligible-zone.patch
* mm-vmscan-make-shrink_node-decisions-more-node-centric.patch
* mm-memcg-move-memcg-limit-enforcement-from-zones-to-nodes.patch
* mm-workingset-make-working-set-detection-node-aware.patch
* mm-page_alloc-consider-dirtyable-memory-in-terms-of-nodes.patch
* mm-move-page-mapped-accounting-to-the-node.patch
* mm-rename-nr_anon_pages-to-nr_anon_mapped.patch
* mm-move-most-file-based-accounting-to-the-node.patch
* mm-move-most-file-based-accounting-to-the-node-fix.patch
* mm-move-vmscan-writes-and-file-write-accounting-to-the-node.patch
* mm-vmscan-only-wakeup-kswapd-once-per-node-for-the-requested-classzone.patch
* mm-page_alloc-wake-kswapd-based-on-the-highest-eligible-zone.patch
* mm-convert-zone_reclaim-to-node_reclaim.patch
* mm-vmscan-avoid-passing-in-classzone_idx-unnecessarily-to-shrink_node.patch
* mm-vmscan-avoid-passing-in-classzone_idx-unnecessarily-to-compaction_ready.patch
* mm-vmscan-avoid-passing-in-remaining-unnecessarily-to-prepare_kswapd_sleep.patch
* mm-vmscan-have-kswapd-reclaim-from-all-zones-if-reclaiming-and-buffer_heads_over_limit.patch
* mm-vmscan-have-kswapd-reclaim-from-all-zones-if-reclaiming-and-buffer_heads_over_limit-fix.patch
* mm-vmscan-add-classzone-information-to-tracepoints.patch
* mm-page_alloc-remove-fair-zone-allocation-policy.patch
* mm-page_alloc-cache-the-last-node-whose-dirty-limit-is-reached.patch
* mm-vmstat-replace-__count_zone_vm_events-with-a-zone-id-equivalent.patch
* mm-vmstat-account-per-zone-stalls-and-pages-skipped-during-reclaim.patch
* mm-vmstat-account-per-zone-stalls-and-pages-skipped-during-reclaim-fix.patch
* mm-vmstat-print-node-based-stats-in-zoneinfo-file.patch
* mm-vmstat-remove-zone-and-node-double-accounting-by-approximating-retries.patch
* mm-page_alloc-fix-dirtyable-highmem-calculation.patch
* mm-zsmalloc-use-obj_index-to-keep-consistent-with-others.patch
* mm-zsmalloc-take-obj-index-back-from-find_alloced_obj.patch
* mm-zsmalloc-use-class-objs_per_zspage-to-get-num-of-max-objects.patch
* mm-zsmalloc-avoid-calculate-max-objects-of-zspage-twice.patch
* mm-zsmalloc-keep-comments-consistent-with-code.patch
* mm-zsmalloc-add-__init__exit-attribute.patch
* mm-zsmalloc-use-helper-to-clear-page-flags-bit.patch
* mm-zsmalloc-add-per-class-compact-trace-event.patch
* mm-zsmalloc-add-per-class-compact-trace-event-checkpatch-fixes.patch
* mm-thp-clean-up-return-value-of-madvise_free_huge_pmd.patch
* memblock-include-asm-sectionsh-instead-of-asm-generic-sectionsh.patch
* mm-config_zone_device-stop-depending-on-config_expert.patch
* mm-cleanup-ifdef-guards-for-vmem_altmap.patch
* mm-kasan-account-for-object-redzone-in-slubs-nearest_obj.patch
* mm-kasan-switch-slub-to-stackdepot-enable-memory-quarantine-for-slub.patch
* proc_oom_score-remove-tasklist_lock-and-pid_alive.patch
* procfs-avoid-32-bit-time_t-in-proc-stat.patch
* make-compile_test-depend-on-uml.patch
* memstick-dont-allocate-unused-major-for-ms_block.patch
* treewide-replace-obsolete-_refok-by-__ref.patch
* treewide-replace-obsolete-_refok-by-__ref-checkpatch-fixes.patch
* mailmap-add-linus-lussing.patch
* task_work-use-read_once-lockless_dereference-avoid-pi_lock-if-task_works.patch
* dynamic_debug-only-add-header-when-used.patch
* dynamic_debug-only-add-header-when-used-fix.patch
* printk-do-not-include-interrupth.patch
* printk-create-pr_level-functions.patch
* printk-create-pr_level-functions-fix.patch
* printk-introduce-suppress_message_printing.patch
* printk-include-asm-sectionsh-instead-of-asm-generic-sectionsh.patch
* lib-switch-config_printk_time-to-int.patch
* printk-allow-different-timestamps-for-printktime.patch
* lib-iommu-helper-skip-to-next-segment.patch
* crc32-use-ktime_get_ns-for-measurement.patch
* lib-add-crc64-ecma-module.patch
* compat-remove-compat_printk.patch
* firmware-consolidate-kmap-read-write-logic.patch
* firmware-provide-infrastructure-to-make-fw-caching-optional.patch
* firmware-support-loading-into-a-pre-allocated-buffer.patch
* firmware-support-loading-into-a-pre-allocated-buffer-fix.patch
* checkpatch-skip-long-lines-that-use-an-efi_guid-macro.patch
* checkpatch-allow-c99-style-comments.patch
* binfmt_elf-fix-calculations-for-bss-padding.patch
* mm-refuse-wrapped-vm_brk-requests.patch
* samples-kprobe-convert-the-printk-to-pr_info-pr_err.patch
* samples-jprobe-convert-the-printk-to-pr_info-pr_err.patch
* samples-kretprobe-convert-the-printk-to-pr_info-pr_err.patch
* samples-kretprobe-fix-the-wrong-type.patch
* fs-befs-move-useless-assignment.patch
* fs-befs-check-silent-flag-before-logging-errors.patch
* fs-befs-remove-useless-pr_err.patch
* fs-befs-remove-useless-befs_error.patch
* fs-befs-remove-useless-pr_err-in-befs_init_inodecache.patch
* befs-check-return-of-sb_min_blocksize.patch
* befs-fix-function-name-in-documentation.patch
* befs-remove-unused-functions.patch
* fs-befs-replace-befs_bread-by-sb_bread.patch
* nilfs2-hide-function-name-argument-from-nilfs_error.patch
* nilfs2-add-nilfs_msg-message-interface.patch
* nilfs2-embed-a-back-pointer-to-super-block-instance-in-nilfs-object.patch
* nilfs2-reduce-bare-use-of-printk-with-nilfs_msg.patch
* nilfs2-replace-nilfs_warning-with-nilfs_msg.patch
* nilfs2-replace-nilfs_warning-with-nilfs_msg-fix.patch
* nilfs2-emit-error-message-when-i-o-error-is-detected.patch
* nilfs2-do-not-use-yield.patch
* nilfs2-refactor-parser-of-snapshot-mount-option.patch
* nilfs2-fix-misuse-of-a-semaphore-in-sysfs-code.patch
* nilfs2-use-bit-macro.patch
* nilfs2-move-ioctl-interface-and-disk-layout-to-uapi-separately.patch
* reiserfs-fix-new_insert_key-may-be-used-uninitialized.patch
* exit-quieten-greatest-stack-depth-printk.patch
* cpumask-fix-code-comment.patch
* kexec-return-error-number-directly.patch
* arm-kdump-advertise-boot-aliased-crash-kernel-resource.patch
* arm-kexec-advertise-location-of-bootable-ram.patch
* kexec-dont-invoke-oom-killer-for-control-page-allocation.patch
* kexec-ensure-user-memory-sizes-do-not-wrap.patch
* kexec-ensure-user-memory-sizes-do-not-wrap-fix.patch
* kdump-arrange-for-paddr_vmcoreinfo_note-to-return-phys_addr_t.patch
* kexec-allow-architectures-to-override-boot-mapping.patch
* kexec-allow-architectures-to-override-boot-mapping-fix.patch
* arm-keystone-dts-add-psci-command-definition.patch
* arm-kexec-fix-kexec-for-keystone-2.patch
* x86-panic-replace-smp_send_stop-with-kdump-friendly-version.patch
* kexec-use-core_param-for-crash_kexec_post_notifiers-boot-option.patch
* add-a-kexec_crash_loaded-function.patch
* allow-kdump-with-crash_kexec_post_notifiers.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* futex-fix-shared-futex-operations-on-nommu.patch
* w1-remove-need-for-ida-and-use-platform_devid_auto.patch
* w1-add-helper-macro-module_w1_family.patch
* init-allow-blacklisting-of-module_init-functions.patch
* module-do-a-warn_on_once-for-assert-module-mutex-not-held.patch
* relay-add-global-mode-support-for-buffer-only-channels.patch
* ban-config_localversion_auto-with-allmodconfig.patch
* kcov-allow-more-fine-grained-coverage-instrumentation.patch
* ipc-delete-nr_ipc_ns.patch
* ipc-msgc-msgsnd-use-freezable-blocking-call.patch
* msgrcv-use-freezable-blocking-call.patch
  linux-next.patch
  linux-next-rejects.patch
* drivers-net-wireless-intel-iwlwifi-dvm-calibc-fix-min-warning.patch
* drivers-leds-leds-lp3952c-work-around-gcc-444-union-initializer-bug.patch
* fpga-zynq-fpga-fix-build-failure.patch
* tree-wide-replace-config_enabled-with-is_enabled.patch
* bitmap-bitmap_equal-memcmp-optimization-fix.patch
* powerpc-add-explicit-include-asm-asm-compath-for-jump-label.patch
* sparc-support-static_key-usage-in-non-module-__exit-sections.patch
* tile-support-static_key-usage-in-non-module-__exit-sections.patch
* arm-jump-label-may-reference-text-in-__exit.patch
* jump_label-remove-bugh-atomich-dependencies-for-have_jump_label.patch
* dynamic_debug-add-jump-label-support.patch
* ipc-semc-fix-complex_count-vs-simple-op-race.patch
* ipc-semc-fix-complex_count-vs-simple-op-race-update.patch
* ipc-semc-remove-duplicated-memory-barriers.patch
* ipc-sem-sem_lock-with-hysteresis.patch
* nvme-dont-allocate-unused-nvme_major.patch
* media-mtk-vcodec-remove-unused-dma_attrs.patch
* dma-mapping-use-unsigned-long-for-dma_attrs.patch
* alpha-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* arc-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* arm-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* arm64-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* avr32-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* blackfin-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* c6x-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* cris-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* frv-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* drm-exynos-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* drm-mediatek-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* drm-msm-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* drm-nouveau-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* drm-rockship-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* infiniband-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* iommu-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* media-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* xen-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* swiotlb-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* powerpc-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* video-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* x86-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* iommu-intel-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* h8300-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* hexagon-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* ia64-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* m68k-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* metag-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* microblaze-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* mips-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* mn10300-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* nios2-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* openrisc-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* parisc-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* misc-mic-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* s390-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* sh-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* sparc-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* tile-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* unicore32-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* xtensa-dma-mapping-use-unsigned-long-for-dma_attrs.patch
* remoteproc-qcom-use-unsigned-long-for-dma_attrs.patch
* dma-mapping-remove-dma_get_attr.patch
* dma-mapping-document-the-dma-attributes-next-to-the-declaration.patch
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
