Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 86E816B0255
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 18:50:34 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id tt10so78413448pab.3
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 15:50:34 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id vb6si9227591pac.158.2016.03.10.15.50.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Mar 2016 15:50:33 -0800 (PST)
Date: Thu, 10 Mar 2016 15:50:31 -0800
From: akpm@linux-foundation.org
Subject: mmotm 2016-03-10-15-49 uploaded
Message-ID: <56e20847.47UiVE84pUiaPhWi%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2016-03-10-15-49 has been uploaded to

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


This mmotm tree contains the following patches against 4.5-rc7:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  drivers-gpu-drm-i915-intel_spritec-fix-build.patch
  drivers-gpu-drm-i915-intel_tvc-fix-build.patch
* mm-mempool-avoid-kasan-marking-mempool-posion-checks-as-use-after-free.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* tags-fix-define_per_cpu-expansions.patch
* m32r-mm-fix-build-warning.patch
* blackfin-define-dummy-pgprot_writecombine-for-mmu.patch
* fs-ext4-fsyncc-generic_file_fsync-call-based-on-barrier-flag.patch
* ocfs2-cluster-replace-the-interrupt-safe-spinlocks-with-common-ones.patch
* ocfs2-use-spinlock-irqsave-for-downconvert-lock-in-ocfs2_osb_dump.patch
* ocfs2-dlm-fix-a-typo-in-dlmcommonh.patch
* ocfs2-dlm-add-deref_done-message.patch
* ocfs2-dlm-return-in-progress-if-master-can-not-clear-the-refmap-bit-right-now.patch
* ocfs2-dlm-clear-dropping_ref-flag-when-the-master-goes-down.patch
* ocfs2-dlm-return-einval-when-the-lockres-on-migration-target-is-in-dropping_ref-state.patch
* ocfs2-fix-a-tiny-race-that-leads-file-system-read-only.patch
* ocfs2-add-ocfs2_write_type_t-type-to-identify-the-caller-of-write.patch
* ocfs2-use-c_new-to-indicate-newly-allocated-extents.patch
* ocfs2-test-target-page-before-change-it.patch
* ocfs2-do-not-change-i_size-in-write_end-for-direct-io.patch
* ocfs2-return-the-physical-address-in-ocfs2_write_cluster.patch
* ocfs2-record-unwritten-extents-when-populate-write-desc.patch
* ocfs2-fix-sparse-file-data-ordering-issue-in-direct-io.patch
* ocfs2-code-clean-up-for-direct-io.patch
* ocfs2-code-clean-up-for-direct-io-fix.patch
* ocfs2-fix-ip_unaligned_aio-deadlock-with-dio-work-queue.patch
* ocfs2-fix-ip_unaligned_aio-deadlock-with-dio-work-queue-fix.patch
* ocfs2-take-ip_alloc_sem-in-ocfs2_dio_get_block-ocfs2_dio_end_io_write.patch
* ocfs2-fix-disk-file-size-and-memory-file-size-mismatch.patch
* ocfs2-fix-a-deadlock-issue-in-ocfs2_dio_end_io_write.patch
* ocfs2-dlm-fix-race-between-convert-and-recovery.patch
* ocfs2-dlm-fix-race-between-convert-and-recovery-v2.patch
* ocfs2-dlm-fix-race-between-convert-and-recovery-v3.patch
* ocfs2-dlm-fix-bug-in-dlm_move_lockres_to_recovery_list.patch
* ocfs2-extend-transaction-for-ocfs2_remove_rightmost_path-and-ocfs2_update_edge_lengths-before-to-avoid-inconsistency-between-inode-and-et.patch
* extend-enough-credits-for-freeing-one-truncate-record-while-replaying-truncate-records.patch
* ocfs2-avoid-occurring-deadlock-by-changing-ocfs2_wq-from-global-to-local.patch
* ocfs2-solve-a-problem-of-crossing-the-boundary-in-updating-backups.patch
* ocfs2-export-ocfs2_kset-for-online-file-check.patch
* ocfs2-sysfile-interfaces-for-online-file-check.patch
* ocfs2-sysfile-interfaces-for-online-file-check-v4.patch
* ocfs2-create-remove-sysfile-for-online-file-check.patch
* ocfs2-check-fix-inode-block-for-online-file-check.patch
* ocfs2-check-fix-inode-block-for-online-file-check-v4.patch
* ocfs2-add-feature-document-for-online-file-check.patch
* ocfs2-o2hb-add-negotiate-timer.patch
* ocfs2-o2hb-add-nego_timeout-message.patch
* ocfs2-o2hb-add-negotiate_approve-message.patch
* ocfs2-o2hb-add-some-user-debug-log.patch
* ocfs2-o2hb-dont-negotiate-if-last-hb-fail.patch
* ocfs2-o2hb-fix-hb-hung-time.patch
* ocfs2-dlm-move-lock-to-the-tail-of-grant-queue-while-doing-in-place-convert.patch
* ocfs2-dlm-move-lock-to-the-tail-of-grant-queue-while-doing-in-place-convert-fix.patch
* block-partition-add-partition-specific-uevent-callbacks-for-partition-info.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
  mm.patch
* slub-cleanup-code-for-kmem-cgroup-support-to-kmem_cache_free_bulk.patch
* mm-slab-move-slub-alloc-hooks-to-common-mm-slabh.patch
* mm-fault-inject-take-over-bootstrap-kmem_cache-check.patch
* mm-fault-inject-take-over-bootstrap-kmem_cache-check-fix.patch
* slab-use-slab_pre_alloc_hook-in-slab-allocator-shared-with-slub.patch
* slab-use-slab_pre_alloc_hook-in-slab-allocator-shared-with-slub-fix.patch
* mm-kmemcheck-skip-object-if-slab-allocation-failed.patch
* slab-use-slab_post_alloc_hook-in-slab-allocator-shared-with-slub.patch
* slab-implement-bulk-alloc-in-slab-allocator.patch
* slab-avoid-running-debug-slab-code-with-irqs-disabled-for-alloc_bulk.patch
* slab-implement-bulk-free-in-slab-allocator.patch
* mm-new-api-kfree_bulk-for-slabslub-allocators.patch
* mm-fix-some-spelling.patch
* mm-slab-fix-stale-code-comment.patch
* mm-slab-remove-useless-structure-define.patch
* mm-slab-remove-the-checks-for-slab-implementation-bug.patch
* mm-slab-activate-debug_pagealloc-in-slab-when-it-is-actually-enabled.patch
* mm-slab-use-more-appropriate-condition-check-for-debug_pagealloc.patch
* mm-slab-clean-up-debug_pagealloc-processing-code.patch
* mm-slab-clean-up-debug_pagealloc-processing-code-fix.patch
* mm-slab-alternative-implementation-for-debug_slab_leak.patch
* mm-slab-remove-object-status-buffer-for-debug_slab_leak.patch
* mm-slab-put-the-freelist-at-the-end-of-slab-page.patch
* mm-slab-put-the-freelist-at-the-end-of-slab-page-fix.patch
* mm-slab-align-cache-size-first-before-determination-of-off_slab-candidate.patch
* mm-slab-clean-up-cache-type-determination.patch
* mm-slab-do-not-change-cache-size-if-debug-pagealloc-isnt-possible.patch
* mm-slab-make-criteria-for-off-slab-determination-robust-and-simple.patch
* mm-slab-factor-out-slab-list-fixup-code.patch
* mm-slab-factor-out-debugging-initialization-in-cache_init_objs.patch
* mm-slab-introduce-new-slab-management-type-objfreelist_slab.patch
* mm-slab-introduce-new-slab-management-type-objfreelist_slab-fix.patch
* mm-slab-avoid-returning-values-by-reference.patch
* mm-slab-re-implement-pfmemalloc-support.patch
* mm-slab-re-implement-pfmemalloc-support-v2.patch
* slub-drop-lock-at-the-end-of-free_debug_processing.patch
* slub-drop-lock-at-the-end-of-free_debug_processing-fix.patch
* slub-fix-clean-free_debug_processing-return-paths.patch
* slub-convert-slab_debug_free-to-slab_consistency_checks.patch
* slub-relax-cmpxchg-consistency-restrictions.patch
* mm-slub-support-left-red-zone.patch
* mm-slub-support-left-red-zone-fix.patch
* fs-mpagec-mpage_readpages-use-lru_to_page-helper.patch
* mm-page_allocc-calculate-zone_start_pfn-at-zone_spanned_pages_in_node.patch
* mm-page_allocc-introduce-kernelcore=mirror-option.patch
* mm-page_allocc-introduce-kernelcore=mirror-option-fix.patch
* mm-page_allocc-rework-code-layout-in-memmap_init_zone.patch
* mm-page-writeback-fix-dirty_ratelimit-calculation.patch
* mm-debug_pagealloc-ask-users-for-default-setting-of-debug_pagealloc.patch
* mm-debug_pagealloc-ask-users-for-default-setting-of-debug_pagealloc-v3.patch
* mm-fix-two-typos-in-comments-for-to_vmem_altmap.patch
* mm-filemap-remove-redundant-code-in-do_read_cache_page.patch
* mm-filemap-avoid-unnecessary-calls-to-lock_page-when-waiting-for-io-to-complete-during-a-read.patch
* tracepoints-move-trace_print_flags-definitions-to-tracepoint-defsh.patch
* mm-tracing-make-show_gfp_flags-up-to-date.patch
* tools-perf-make-gfp_compact_table-up-to-date.patch
* mm-tracing-unify-mm-flags-handling-in-tracepoints-and-printk.patch
* mm-printk-introduce-new-format-string-for-flags.patch
* mm-printk-introduce-new-format-string-for-flags-fix.patch
* mm-debug-replace-dump_flags-with-the-new-printk-formats.patch
* mm-page_alloc-print-symbolic-gfp_flags-on-allocation-failure.patch
* mm-oom-print-symbolic-gfp_flags-in-oom-warning.patch
* mm-page_owner-print-migratetype-of-page-and-pageblock-symbolic-flags.patch
* mm-page_owner-convert-page_owner_inited-to-static-key.patch
* mm-page_owner-copy-page-owner-info-during-migration.patch
* mm-page_owner-track-and-print-last-migrate-reason.patch
* mm-page_owner-dump-page-owner-info-from-dump_page.patch
* mm-debug-move-bad-flags-printing-to-bad_page.patch
* mm-page_poisonc-enable-page_poisoning-as-a-separate-option.patch
* mm-page_poisoningc-allow-for-zero-poisoning.patch
* mm-slb-print-gfp_flags-as-strings-in-slab_out_of_memory.patch
* mm-madvise-pass-return-code-of-memory_failure-to-userspace.patch
* mm-memory-failurec-remove-the-useless-undefs.patch
* mm-mempolicy-skip-vm_hugetlb-and-vm_mixedmap-vma-for-lazy-mbind.patch
* make-apply_to_page_range-more-robust.patch
* memory-hotplug-add-automatic-onlining-policy-for-the-newly-added-memory.patch
* xen_balloon-support-memory-auto-onlining-policy.patch
* mm-vmscan-do-not-clear-shrinker_numa_aware-if-nr_node_ids-==-1.patch
* mm-madvise-update-comment-on-sys_madvise.patch
* mm-madvise-update-comment-on-sys_madvise-fix.patch
* mm-vmscan-make-zone_reclaimable_pages-more-precise.patch
* mm-memcontrol-generalize-locking-for-the-page-mem_cgroup-binding.patch
* mm-workingset-define-radix-entry-eviction-mask.patch
* mm-workingset-separate-shadow-unpacking-and-refault-calculation.patch
* mm-workingset-eviction-buckets-for-bigmem-lowbit-machines.patch
* mm-workingset-per-cgroup-cache-thrash-detection.patch
* mm-workingset-per-cgroup-cache-thrash-detection-fix.patch
* mm-migrate-do-not-touch-page-mem_cgroup-of-live-pages.patch
* mm-migrate-do-not-touch-page-mem_cgroup-of-live-pages-fix.patch
* mm-migrate-do-not-touch-page-mem_cgroup-of-live-pages-fix-2.patch
* mm-simplify-lock_page_memcg.patch
* mm-simplify-lock_page_memcg-fix.patch
* mm-remove-unnecessary-uses-of-lock_page_memcg.patch
* mm-use-linear_page_index-in-do_fault.patch
* thp-cleanup-split_huge_page.patch
* x86-query-dynamic-debug_pagealloc-setting.patch
* s390-query-dynamic-debug_pagealloc-setting.patch
* x86-also-use-debug_pagealloc_enabled-for-free_init_pages.patch
* sched-add-schedule_timeout_idle.patch
* mm-oom-introduce-oom-reaper.patch
* oom-reaper-handle-mlocked-pages.patch
* oom-clear-tif_memdie-after-oom_reaper-managed-to-unmap-the-address-space.patch
* oom-clear-tif_memdie-after-oom_reaper-managed-to-unmap-the-address-space-fix-2.patch
* mm-oom_reaper-report-success-failure.patch
* mm-oom_reaper-report-success-failure-fix.patch
* mm-oom_reaper-report-success-failure-fix-2.patch
* mm-oom_reaper-report-success-failure-fix-fix.patch
* mm-oom_reaper-implement-oom-victims-queuing.patch
* mm-oom_reaper-implement-oom-victims-queuing-fix.patch
* oom-make-oom_reaper-freezable.patch
* oom-oom_reaper-disable-oom_reaper-for-oom_kill_allocating_task.patch
* mm-oom_kill-dont-ignore-oom-score-on-exiting-tasks.patch
* mm-memblock-remove-unnecessary-memblock_type-variable.patch
* mm-compaction-fix-invalid-free_pfn-and-compact_cached_free_pfn.patch
* mm-compaction-pass-only-pageblock-aligned-range-to-pageblock_pfn_to_page.patch
* mm-compaction-speed-up-pageblock_pfn_to_page-when-zone-is-contiguous.patch
* mm-compaction-speed-up-pageblock_pfn_to_page-when-zone-is-contiguous-v3.patch
* mm-compaction-speed-up-pageblock_pfn_to_page-when-zone-is-contiguous-fix.patch
* mm-migrate-consolidate-mem_cgroup_migrate-calls.patch
* mm-memcontrol-drop-unnecessary-lru-locking-from-mem_cgroup_migrate.patch
* mm-memcontrol-do-not-bypass-slab-charge-if-memcg-is-offline.patch
* mm-memcontrol-make-tree_statevents-fetch-all-stats.patch
* mm-memcontrol-make-tree_statevents-fetch-all-stats-fix.patch
* mm-memcontrol-report-slab-usage-in-cgroup2-memorystat.patch
* mm-memcontrol-report-kernel-stack-usage-in-cgroup2-memorystat.patch
* mm-memcontrol-report-kernel-stack-usage-in-cgroup2-memorystat-v2.patch
* proc-kpageflags-return-kpf_buddy-for-tail-buddy-pages.patch
* proc-kpageflags-return-kpf_buddy-for-tail-buddy-pages-fix.patch
* proc-kpageflags-return-kpf_buddy-for-tail-buddy-pages-fix-fix.patch
* proc-kpageflags-return-kpf_slab-for-slab-tail-pages.patch
* tools-vm-page-typesc-support-swap-entry.patch
* mm-vmalloc-query-dynamic-debug_pagealloc-setting.patch
* mm-vmalloc-query-dynamic-debug_pagealloc-setting-fix.patch
* mm-slub-query-dynamic-debug_pagealloc-setting.patch
* mm-slub-query-dynamic-debug_pagealloc-setting-fix.patch
* mm-slub-query-dynamic-debug_pagealloc-setting-v2.patch
* sound-query-dynamic-debug_pagealloc-setting.patch
* sound-query-dynamic-debug_pagealloc-setting-fix.patch
* powerpc-query-dynamic-debug_pagealloc-setting.patch
* tile-query-dynamic-debug_pagealloc-setting.patch
* mm-kswapd-remove-bogus-check-of-balance_classzone_idx.patch
* mm-compaction-introduce-kcompactd.patch
* mm-compaction-introduce-kcompactd-fix.patch
* mm-compaction-introduce-kcompactd-fix-2.patch
* mm-compaction-introduce-kcompactd-fix-3.patch
* mm-compaction-introduce-kcompactd-fix-4.patch
* mm-memory-hotplug-small-cleanup-in-online_pages.patch
* mm-kswapd-replace-kswapd-compaction-with-waking-up-kcompactd.patch
* tools-vm-page-typesc-add-memory-cgroup-dumping-and-filtering.patch
* tools-vm-page-typesc-add-memory-cgroup-dumping-and-filtering-fix.patch
* bufferhead-force-inlining-of-buffer-head-flag-operations.patch
* force-inlining-of-selected-page-flag-modifications.patch
* mm-memcontrol-enable-kmem-accounting-for-all-cgroups-in-the-legacy-hierarchy.patch
* mm-vmscan-pass-root_mem_cgroup-instead-of-null-to-memcg-aware-shrinker.patch
* mm-memcontrol-zap-memcg_kmem_online-helper.patch
* radix-tree-account-radix_tree_node-to-memory-cgroup.patch
* mm-workingset-size-shadow-nodes-lru-basing-on-file-cache-size.patch
* mm-workingset-make-shadow-node-shrinker-memcg-aware.patch
* thp-vmstats-count-deferred-split-events.patch
* thp-vmstats-count-deferred-split-events-v2.patch
* mm-move-max_map_count-bits-into-mmh.patch
* mm-dedupclicate-memory-overcommitment-code.patch
* mm-tracing-refresh-__def_vmaflag_names.patch
* mm-tracing-refresh-__def_vmaflag_names-fix.patch
* mm-thp-migration-switch-from-flush_tlb_range-to-flush_pmd_tlb_range.patch
* arc-thp-remove-infrastructure-for-handling-splitting-pmds.patch
* mm-kconfig-remove-redundant-arch-depend-for-memory-hotplug.patch
* calculate-available-memory-in-the-separate-function.patch
* virtio_balloon-export-available-memory-to-balloon-statistics.patch
* mm-cleanup-pte_alloc-interfaces.patch
* mm-cleanup-pte_alloc-interfaces-fix.patch
* mm-cleanup-pte_alloc-interfaces-fix-2.patch
* mm-scale-kswapd-watermarks-in-proportion-to-memory.patch
* mm-scale-kswapd-watermarks-in-proportion-to-memory-v3.patch
* mm-remove-unnecessary-description-about-a-non-exist-gfp-flag.patch
* mm-mempool-only-set-__gfp_nomemalloc-if-there-are-free-elements.patch
* mm-thp-set-thp-defrag-by-default-to-madvise-and-add-a-stall-free-defrag-option.patch
* mm-thp-set-thp-defrag-by-default-to-madvise-and-add-a-stall-free-defrag-option-fix.patch
* mm-introduce-page-reference-manipulation-functions.patch
* mm-page_ref-add-tracepoint-to-track-down-page-reference-manipulation.patch
* mm-page_ref-add-tracepoint-to-track-down-page-reference-manipulation-fix-2.patch
* mm-page_ref-add-tracepoint-to-track-down-page-reference-manipulation-fix-3.patch
* mm-page_ref-add-tracepoint-to-track-down-page-reference-manipulation-fix-3-fix.patch
* mm-remove-__gfp_nofail-is-deprecated-comment.patch
* mm-memory-hotplug-print-debug-message-in-the-proper-way-for-online_pages.patch
* mm-memcontrol-cleanup-css_reset-callback.patch
* mm-exclude-zone_device-from-gfp_zone_table.patch
* mm-convert-pr_warning-to-pr_warn.patch
* mm-coalesce-split-strings.patch
* mm-convert-printkkern_level-to-pr_level.patch
* mm-percpu-use-pr_fmt-to-prefix-output.patch
* mm-remove-vm_fault_minor.patch
* mm-zone_device-depends-on-sparsemem_vmemmap.patch
* rmap-introduce-rmap_walk_locked.patch
* rmap-extend-try_to_unmap-to-be-usable-by-split_huge_page.patch
* mm-make-remove_migration_ptes-beyond-mm-migrationc.patch
* thp-rewrite-freeze_page-unfreeze_page-with-generic-rmap-walkers.patch
* thp-fix-deadlock-in-split_huge_pmd.patch
* mm-meminit-initialise-more-memory-for-inode-dentry-hash-tables-in-early-boot.patch
* powerpc-mm-enable-page-parallel-initialisation.patch
* tools-vm-page-typesc-avoid-memset-in-walk_pfn-when-count-==-1.patch
* mm-memcontrol-reclaim-when-shrinking-memoryhigh-below-usage.patch
* mm-memcontrol-reclaim-and-oom-kill-when-shrinking-memorymax-below-usage.patch
* mm-memcontrol-clarify-the-uncharge_list-loop.patch
* ksm-introduce-ksm_max_page_sharing-per-page-deduplication-limit.patch
* ksm-introduce-ksm_max_page_sharing-per-page-deduplication-limit-fix-2.patch
* ksm-introduce-ksm_max_page_sharing-per-page-deduplication-limit-fix-3.patch
* mm-make-optimistic-check-for-swapin-readahead.patch
* mm-make-optimistic-check-for-swapin-readahead-fix-2.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-2.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-3.patch
* kasan-modify-kmalloc_large_oob_right-add-kmalloc_pagealloc_oob_right.patch
* mm-kasan-slab-support.patch
* mm-kasan-added-gfp-flags-to-kasan-api.patch
* arch-ftrace-for-kasan-put-hard-soft-irq-entries-into-separate-sections.patch
* mm-kasan-stackdepot-implementation-enable-stackdepot-for-slab.patch
* mm-kasan-stackdepot-implementation-enable-stackdepot-for-slab-fix.patch
* kasan-test-fix-warn-if-the-uaf-could-not-be-detected-in-kmalloc_uaf2.patch
* mm-kasan-initial-memory-quarantine-implementation.patch
* zsmalloc-drop-unused-member-mapping_area-huge.patch
* zram-export-the-number-of-available-comp-streams.patch
* zram-export-the-number-of-available-comp-streams-fix.patch
* mm-zsmalloc-add-freeable-column-to-pool-stat.patch
* mm-zsmalloc-add-freeable-column-to-pool-stat-fix.patch
* mmoom-make-oom_killer_disable-killable.patch
* mmoom-do-not-loop-__gfp_fs-allocation-if-the-oom-killer-is-disabled.patch
* mm-oom-rework-oom-detection.patch
* mm-oom-rework-oom-detection-checkpatch-fixes.patch
* mm-throttle-on-io-only-when-there-are-too-many-dirty-and-writeback-pages.patch
* mm-use-watermak-checks-for-__gfp_repeat-high-order-allocations.patch
* mm-use-watermak-checks-for-__gfp_repeat-high-order-allocations-checkpatch-fixes.patch
* mm-memblock-if-nr_new-is-0-just-return.patch
* timer-convert-timer_slack_ns-from-unsigned-long-to-u64.patch
* proc-add-proc-pid-timerslack_ns-interface.patch
* proc-add-proc-pid-timerslack_ns-interface-fix.patch
* procfs-add-conditional-compilation-check.patch
* proc-base-make-prompt-shell-start-from-new-line-after-executing-cat-proc-pid-wchan.patch
* mn10300-c6x-config_generic_bug-must-depend-on-config_bug.patch
* arch-mn10300-kernel-fpu-nofpuc-needs-asm-elfh.patch
* bug-set-warn-variable-before-calling-warn.patch
* fix-my-email-addresses.patch
* kernel-hung_taskc-use-timeout-diff-when-timeout-is-updated.patch
* printk-nmi-generic-solution-for-safe-printk-in-nmi.patch
* printk-nmi-use-irq-work-only-when-ready.patch
* printk-nmi-warn-when-some-message-has-been-lost-in-nmi-context.patch
* printk-nmi-increase-the-size-of-nmi-buffer-and-make-it-configurable.patch
* printk-move-can_use_console-out-of-console_trylock_for_printk.patch
* printk-set-may_schedule-for-some-of-console_trylock-callers.patch
* printk-check-con_enabled-in-have_callable_console.patch
* maintainers-update-s-par-driver-maintainer-list.patch
* include-linux-list_blh-use-bool-instead-of-int-for-boolean-functions.patch
* lib-bug-make-panic_on_warn-available-for-all-architectures.patch
* radix-tree-add-an-explicit-include-of-bitopsh.patch
* radix-tree-test-harness.patch
* radix-tree-test-harness-fix.patch
* radix_tree-tag-all-internal-tree-nodes-as-indirect-pointers.patch
* radix_tree-loop-based-on-shift-count-not-height.patch
* radix_tree-add-support-for-multi-order-entries.patch
* radix_tree-add-radix_tree_dump.patch
* btrfs-use-radix_tree_iter_retry.patch
* btrfs-use-radix_tree_iter_retry-fix.patch
* mm-use-radix_tree_iter_retry.patch
* mm-use-radix_tree_iter_retry-fix.patch
* radix-treeshmem-introduce-radix_tree_iter_next.patch
* radix-treeshmem-introduce-radix_tree_iter_next-fix.patch
* radix-tree-tests-add-regression3-test.patch
* radix-tree-tests-add-test-for-radix_tree_iter_next.patch
* lib-string-introduce-match_string-helper.patch
* lib-string-introduce-match_string-helper-fix.patch
* device-property-convert-to-use-match_string-helper.patch
* device-property-convert-to-use-match_string-helper-fix.patch
* pinctrl-convert-to-use-match_string-helper.patch
* drm-edid-convert-to-use-match_string-helper.patch
* power-charger_manager-convert-to-use-match_string-helper.patch
* power-ab8500-convert-to-use-match_string-helper.patch
* ata-hpt366-convert-to-use-match_string-helper.patch
* ide-hpt366-convert-to-use-match_string-helper.patch
* usb-common-convert-to-use-match_string-helper.patch
* asm-generic-force-inlining-of-some-atomic_long-operations.patch
* force-inlining-of-some-byteswap-operations.patch
* force-inlining-of-unaligned-byteswap-operations.patch
* lib-move-strtobool-to-kstrtobool.patch
* lib-update-single-char-callers-of-strtobool.patch
* lib-add-on-off-support-to-kstrtobool.patch
* param-convert-some-on-off-users-to-strtobool.patch
* param-convert-some-on-off-users-to-strtobool-fix.patch
* lib-bugc-use-common-warn-helper.patch
* sscanf-implement-basic-character-sets.patch
* sscanf-implement-basic-character-sets-fix.patch
* mm-utilc-add-kstrimdup.patch
* lib-add-crc64-ecma-module.patch
* compat-add-in_compat_syscall-to-ask-whether-were-in-a-compat-syscall.patch
* sparc-compat-provide-an-accurate-in_compat_syscall-implementation.patch
* sparc-compat-provide-an-accurate-in_compat_syscall-implementation-fix.patch
* sparc-compat-provide-an-accurate-in_compat_syscall-implementation-fix-fix.patch
* sparc-syscall-fix-syscall_get_arch.patch
* seccomp-check-in_compat_syscall-not-is_compat_task-in-strict-mode.patch
* ptrace-in-peek_siginfo-check-syscall-bitness-not-task-bitness.patch
* auditsc-for-seccomp-events-log-syscall-compat-state-using-in_compat_syscall.patch
* staging-lustre-switch-from-is_compat_task-to-in_compat_syscall.patch
* ext4-in-ext4_dir_llseek-check-syscall-bitness-directly.patch
* net-sctp-use-in_compat_syscall-for-sctp_getsockopt_connectx3.patch
* net-xfrm_user-use-in_compat_syscall-to-deny-compat-syscalls.patch
* firewire-use-in_compat_syscall-to-check-ioctl-compatness.patch
* efivars-use-in_compat_syscall-to-check-for-compat-callers.patch
* amdkfd-use-in_compat_syscall-to-check-open-caller-type.patch
* input-redefine-input_compat_test-as-in_compat_syscall.patch
* uhid-check-write-bitness-using-in_compat_syscall.patch
* x86-compat-remove-is_compat_task.patch
* checkpatch-exclude-asm-volatile-from-complex-macro-check.patch
* checkpatch-warn-on-bare-unsigned-or-signed-declarations-without-int.patch
* x86-kallsyms-disable-absolute-percpu-symbols-on-smp.patch
* x86-kallsyms-disable-absolute-percpu-symbols-on-smp-v5.patch
* kallsyms-dont-overload-absolute-symbol-type-for-percpu-symbols.patch
* kallsyms-add-support-for-relative-offsets-in-kallsyms-address-table.patch
* kallsyms-add-support-for-relative-offsets-in-kallsyms-address-table-v5.patch
* init-mainc-use-list_for_each_entry.patch
* autofs-show-pipe-inode-in-mount-options.patch
* autofs4-coding-style-fixes.patch
* autofs4-fix-coding-style-problem-in-autofs4_get_set_timeout.patch
* autofs4-fix-coding-style-line-length-in-autofs4_wait.patch
* autofs4-fix-invalid-ioctl-return-in-autofs4_root_ioctl_unlocked.patch
* autofs4-fix-some-white-space-errors.patch
* autofs4-make-autofs-log-prints-consistent.patch
* autofs4-change-log-print-macros-to-not-insert-newline.patch
* autofs4-use-pr_xxx-macros-directly-for-logging.patch
* autofs4-fix-stringh-include-in-auto_dev-ioctlh.patch
* fat-add-config-option-to-set-utf-8-mount-option-by-default.patch
* fs-coredump-prevent-fsuid=0-dumps-into-user-controlled-directories.patch
* cpumask-remove-incorrect-information-from-comment.patch
* kexec-introduce-a-protection-mechanism-for-the-crashkernel-reserved-memory.patch
* kexec-introduce-a-protection-mechanism-for-the-crashkernel-reserved-memory-v4.patch
* kexec-provide-arch_kexec_protectunprotect_crashkres.patch
* kexec-provide-arch_kexec_protectunprotect_crashkres-v4.patch
* kexec-make-a-pair-of-map-unmap-reserved-pages-in-error-path.patch
* kexec-do-a-cleanup-for-function-kexec_load.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* rapidio-rionet-fix-deadlock-on-smp.patch
* rapidio-rionet-add-capability-to-change-mtu.patch
* rapidio-tsi721-fix-hardcoded-mrrs-setting.patch
* rapidio-tsi721-add-check-for-overlapped-ib-window-mappings.patch
* rapidio-tsi721-add-option-to-configure-direct-mapping-of-ib-window.patch
* rapidio-tsi721_dma-fix-pending-transaction-queue-handling.patch
* rapidio-add-query_mport-operation.patch
* rapidio-tsi721-add-query_mport-callback.patch
* rapidio-add-shutdown-notification-for-rapidio-devices.patch
* rapidio-tsi721-add-shutdown-notification-callback.patch
* rapidio-rionet-add-shutdown-event-handling.patch
* rapidio-rework-common-rio-device-add-delete-routines.patch
* rapidio-move-net-allocation-into-core-code.patch
* rapidio-move-net-allocation-into-core-code-fix.patch
* rapidio-add-core-mport-removal-support.patch
* rapidio-tsi721-add-hw-specific-mport-removal.patch
* powerpc-fsl_rio-changes-to-mport-registration.patch
* rapidio-rionet-add-locking-into-add-remove-device.patch
* rapidio-rionet-add-mport-removal-handling.patch
* rapidio-add-lock-protection-for-doorbell-list.patch
* rapidio-add-lock-protection-for-doorbell-list-fix.patch
* rapidio-move-rio_local_set_device_id-function-to-the-common-core.patch
* rapidio-move-rio_pw_enable-into-core-code.patch
* rapidio-move-rio_pw_enable-into-core-code-fix.patch
* rapidio-add-global-inbound-port-write-interfaces.patch
* rapidio-add-global-inbound-port-write-interfaces-fix.patch
* rapidio-tsi721-fix-locking-in-ob_msg-processing.patch
* rapidio-add-outbound-window-support.patch
* rapidio-tsi721-add-outbound-windows-mapping-support.patch
* rapidio-tsi721-add-filtered-debug-output.patch
* rapidio-tsi721_dma-update-error-reporting-from-prep_sg-callback.patch
* rapidio-tsi721_dma-fix-synchronization-issues.patch
* rapidio-tsi721_dma-fix-hardware-error-handling.patch
* rapidio-add-mport-char-device-driver.patch
* rapidio-add-mport-char-device-driver-fix.patch
* rapidio-add-mport-char-device-driver-fix-2.patch
* rapidio-add-mport-char-device-driver-fix-3.patch
* rapidio-add-mport-char-device-driver-fix-4.patch
* eventfd-document-lockless-access-in-eventfd_poll.patch
* panic-change-nmi_panic-from-macro-to-function.patch
* ipmi-watchdog-use-nmi_panic-when-kernel-panics-in-nmi-handler.patch
* hpwdt-use-nmi_panic-when-kernel-panics-in-nmi-handler.patch
* profile-hide-unused-functions-when-config_proc_fs.patch
* kernel-add-kcov-code-coverage.patch
* kernel-add-kcov-code-coverage-fix.patch
* kernel-add-kcov-code-coverage-fix-2.patch
* kernel-add-kcov-code-coverage-clean-up-code.patch
* kernel-add-kcov-code-coverage-makefile-tweaks.patch
* scripts-gdb-add-version-command.patch
* scripts-gdb-add-cmdline-reader-command.patch
* kfifo-fix-sparse-complains.patch
* ubsan-fix-tree-wide-wmaybe-uninitialized-false-positives.patch
* ipc-sem-make-semctl-setting-sempid-consistent.patch
* ipc-semc-fix-complex_count-vs-simple-op-race.patch
* ipc-msgc-msgsnd-use-freezable-blocking-call.patch
* msgrcv-use-freezable-blocking-call.patch
  linux-next.patch
  linux-next-rejects.patch
  linux-next-git-rejects.patch
* drivers-net-wireless-intel-iwlwifi-dvm-calibc-fix-min-warning.patch
* staging-goldfish-use-6-arg-get_user_pages.patch
* mm-mprotectc-dont-imply-prot_exec-on-non-exec-fs.patch
* add-compile-time-check-for-__arch_si_preamble_size.patch
* memremap-dont-modify-flags.patch
* memremap-add-memremap_wc-flag.patch
* drivers-dma-coherent-use-memremap_wc-for-dma_memory_map.patch
* drivers-dma-coherent-use-memset_io-for-dma_memory_io-mappings.patch
* kernel-convert-pr_warning-to-pr_warn.patch
* dma-rename-dma__writecombine-to-dma__wc-checkpatch-fixes.patch
* alpha-extable-use-generic-search-and-sort-routines.patch
* s390-extable-use-generic-search-and-sort-routines.patch
* x86-extable-use-generic-search-and-sort-routines.patch
* ia64-extable-use-generic-search-and-sort-routines.patch
  mm-add-strictlimit-knob-v2.patch
  do_shared_fault-check-that-mmap_sem-is-held.patch
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
