Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id EF92D6B0257
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 17:42:23 -0400 (EDT)
Received: by iodv82 with SMTP id v82so72272438iod.0
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 14:42:23 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id lq6si3770890igb.39.2015.10.21.14.42.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 14:42:22 -0700 (PDT)
Date: Wed, 21 Oct 2015 14:42:21 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2015-10-21-14-41 uploaded
Message-ID: <562806bd.3YN3KM4szvM4jHAV%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz

The mm-of-the-moment snapshot 2015-10-21-14-41 has been uploaded to

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


This mmotm tree contains the following patches against 4.3-rc6:
(patches marked "*" will be included in linux-next)

  origin.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  drivers-gpu-drm-i915-intel_spritec-fix-build.patch
  drivers-gpu-drm-i915-intel_tvc-fix-build.patch
  arm-mm-do-not-use-virt_to_idmap-for-nommu-systems.patch
* kmod-dont-run-async-usermode-helper-as-a-child-of-kworker-thread.patch
* mm-cma-fix-incorrect-type-conversion-for-size-during-dma-allocation.patch
* maintainers-add-myself-as-zsmalloc-reviewer.patch
* mailmap-update-javier-martinez-canillas-email.patch
* thp-use-is_zero_pfn-only-after-pte_present-check.patch
* mm-make-sendfile2-killable.patch
* disable-wframe-larger-than-warnings-with-kasan=y.patch
* fault-inject-fix-inverted-interval-probability-values-in-printk.patch
* ocfs2-dlm-unlock-lockres-spinlock-before-dlm_lockres_put.patch
* inotify-hide-internal-kernel-bits-from-fdinfo.patch
* inotify-actually-check-for-invalid-bits-in-sys_inotify_add_watch.patch
* inotify-actually-check-for-invalid-bits-in-sys_inotify_add_watch-v2.patch
* logfs-fix-build-warning.patch
* fs-ext4-fsyncc-generic_file_fsync-call-based-on-barrier-flag.patch
* ocfs2_direct_io_write-misses-ocfs2_is_overwrite-error-code.patch
* ocfs2-fill-in-the-unused-portion-of-the-block-with-zeros-by-dio_zero_block.patch
* ocfs2-improve-performance-for-localalloc.patch
* ocfs2-do-not-include-dio-entry-in-case-of-orphan-scan.patch
* ocfs2-only-take-lock-if-dio-entry-when-recover-orphans.patch
* ocfs2-fix-race-between-mount-and-delete-node-cluster.patch
* ocfs2-should-reclaim-the-inode-if-__ocfs2_mknod_locked-returns-an-error.patch
* ocfs2-add-ocfs2_write_type_t-type-to-identify-the-caller-of-write.patch
* ocfs2-use-c_new-to-indicate-newly-allocated-extents.patch
* ocfs2-test-target-page-before-change-it.patch
* ocfs2-do-not-change-i_size-in-write_end-for-direct-io.patch
* ocfs2-return-the-physical-address-in-ocfs2_write_cluster.patch
* ocfs2-record-unwritten-extents-when-populate-write-desc.patch
* ocfs2-fix-sparse-file-data-ordering-issue-in-direct-io.patch
* ocfs2-code-clean-up-for-direct-io.patch
* ocfs2-dlm-fix-race-between-convert-and-recovery.patch
* ocfs2-dlm-fix-race-between-convert-and-recovery-v2.patch
* ocfs2-dlm-fix-race-between-convert-and-recovery-v3.patch
* ocfs2-dlm-fix-bug-in-dlm_move_lockres_to_recovery_list.patch
* ocfs2-extend-transaction-for-ocfs2_remove_rightmost_path-and-ocfs2_update_edge_lengths-before-to-avoid-inconsistency-between-inode-and-et.patch
* extend-enough-credits-for-freeing-one-truncate-record-while-replaying-truncate-records.patch
* ocfs2-avoid-occurring-deadlock-by-changing-ocfs2_wq-from-global-to-local.patch
* ocfs2-solve-a-problem-of-crossing-the-boundary-in-updating-backups.patch
* rcu-force-alignment-on-struct-callback_head-rcu_head.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* 9p-do-not-overwrite-return-code-when-locking-fails.patch
* kernel-watchdog-is_hardlockup-can-be-boolean.patch
* watchdog-fix-error-handling-in-proc_watchdog_thresh.patch
* watchdog-move-watchdog_disable_all_cpus-outside-of-ifdef.patch
* watchdog-implement-error-handling-in-update_watchdog_all_cpus-and-callers.patch
* watchdog-implement-error-handling-in-lockup_detector_suspend.patch
* watchdog-do-not-unpark-threads-in-watchdog_park_threads-on-error.patch
* watchdog-perform-all-cpu-backtrace-in-case-of-hard-lockup.patch
* watchdog-add-sysctl-knob-hardlockup_panic.patch
  mm.patch
* mm-slab-convert-slab_is_available-to-boolean.patch
* slub-create-new-___slab_alloc-function-that-can-be-called-with-irqs-disabled.patch
* slub-avoid-irqoff-on-in-bulk-allocation.patch
* slub-mark-the-dangling-ifdef-else-of-config_slub_debug.patch
* slab-implement-bulking-for-slab-allocator.patch
* slub-support-for-bulk-free-with-slub-freelists.patch
* slub-optimize-bulk-slowpath-free-by-detached-freelist.patch
* slub-optimize-bulk-slowpath-free-by-detached-freelist-fix.patch
* compilerh-add-support-for-function-attribute-assume_aligned.patch
* include-linux-compiler-gcch-hide-assume_aligned-attribute-from-sparse.patch
* slabh-sprinkle-__assume_aligned-attributes.patch
* slab_common-rename-cache-create-destroy-helpers.patch
* slab_common-clear-pointers-to-per-memcg-caches-on-destroy.patch
* slab_common-do-not-warn-that-cache-is-busy-on-destroy-more-than-once.patch
* tools-vm-slabinfo-use-getopt-no_argument-optional_argument.patch
* tools-vm-slabinfo-limit-the-number-of-reported-slabs.patch
* tools-vm-slabinfo-sort-slabs-by-loss.patch
* tools-vm-slabinfo-fix-alternate-opts-names.patch
* tools-vm-slabinfo-introduce-extended-totals-mode.patch
* tools-vm-slabinfo-output-sizes-in-bytes.patch
* tools-vm-slabinfo-cosmetic-globals-cleanup.patch
* tools-vm-slabinfo-gnuplot-slabifo-extended-stat.patch
* mm-initialize-kmem_cache-pointer-to-null.patch
* mm-slub-correct-the-comment-in-calculate_order.patch
* mm-slub-use-get_order-instead-of-fls.patch
* mm-slub-calculate-start-order-with-reserved-in-consideration.patch
* mm-kmemleak-remove-unneeded-initialization-of-object-to-null.patch
* syscall-mlockall-reorganize-return-values-and-remove-goto-out-label.patch
* x86-numa-acpi-online-node-earlier-when-doing-cpu-hot-addition.patch
* kernel-profilec-replace-cpu_to_mem-with-cpu_to_node.patch
* sgi-xp-replace-cpu_to_node-with-cpu_to_mem-to-support-memoryless-node.patch
* openvswitch-replace-cpu_to_node-with-cpu_to_mem-to-support-memoryless-node.patch
* x86-numa-kill-useless-code-to-improve-code-readability.patch
* mm-update-_mem_id_-for-every-possible-cpu-when-memory-configuration-changes.patch
* mm-x86-enable-memoryless-node-support-to-better-support-cpu-memory-hotplug.patch
* uaccess-reimplement-probe_kernel_address-using-probe_kernel_read.patch
* uaccess-reimplement-probe_kernel_address-using-probe_kernel_read-fix.patch
* uaccess-reimplement-probe_kernel_address-using-probe_kernel_read-fix-fix.patch
* mm-mmapc-remove-useless-statement-vma-=-null-in-find_vma.patch
* memcg-flatten-task_struct-memcg_oom.patch
* memcg-punt-high-overage-reclaim-to-return-to-userland-path.patch
* memcg-collect-kmem-bypass-conditions-into-__memcg_kmem_bypass.patch
* memcg-ratify-and-consolidate-over-charge-handling.patch
* memcg-drop-unnecessary-cold-path-tests-from-__memcg_kmem_bypass.patch
* mm-fix-docbook-comment-for-get_vaddr_frames.patch
* mm-add-tracepoint-for-scanning-pages.patch
* mm-add-tracepoint-for-scanning-pages-fix.patch
* mm-make-optimistic-check-for-swapin-readahead.patch
* mm-make-optimistic-check-for-swapin-readahead-fix.patch
* mm-make-optimistic-check-for-swapin-readahead-fix-2.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-2.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-3.patch
* mm-replace-nr_node_ids-for-loop-with-for_each_node-in-list-lru.patch
* powerpc-numa-do-not-allocate-bootmem-memory-for-non-existing-nodes.patch
* mm-msync-use-offset_in_page-macro.patch
* mm-nommu-use-offset_in_page-macro.patch
* mm-mincore-use-offset_in_page-macro.patch
* mm-early_ioremap-use-offset_in_page-macro.patch
* mm-percpu-use-offset_in_page-macro.patch
* mm-util-use-offset_in_page-macro.patch
* mm-mlock-use-offset_in_page-macro.patch
* mm-vmalloc-use-offset_in_page-macro.patch
* mm-mmap-use-offset_in_page-macro.patch
* mm-mremap-use-offset_in_page-macro.patch
* mm-memblock-make-memblock_remove_range-static.patch
* mm-migrate-count-pages-failing-all-retries-in-vmstat-and-tracepoint.patch
* mm-page_alloc-remove-unused-parameter-in-init_currently_empty_zone.patch
* mm-use-only-per-device-readahead-limit.patch
* mm-hugetlb-proc-add-hugetlb-related-fields-to-proc-pid-smaps.patch
* mm-hugetlb-proc-add-hugetlbpages-field-to-proc-pid-status.patch
* mm-vmscan-make-inactive_anon_is_low_global-return-directly.patch
* mm-oom_kill-introduce-is_sysrq_oom-helper.patch
* mm-compaction-add-an-is_via_compact_memory-helper-function.patch
* fs-global-sync-to-not-clear-error-status-of-individual-inodes.patch
* mm-hwpoison-ratelimit-messages-from-unpoison_memory.patch
* mm-memcontrol-fix-order-calculation-in-try_charge.patch
* doc-add-information-about-max_ptes_swap.patch
* mm-vmscan-make-inactive_anon-file_is_low-return-bool.patch
* mm-memcontrol-make-mem_cgroup_inactive_anon_is_low-return-bool.patch
* mmoom-reverse-the-order-of-setting-tif_memdie-and-sending-sigkill.patch
* mmoom-reverse-the-order-of-setting-tif_memdie-and-sending-sigkill-v2.patch
* mmoom-fix-potentially-killing-unrelated-process.patch
* mmoom-fix-potentially-killing-unrelated-process-fix.patch
* mmoom-suppress-unnecessary-sharing-same-memory-message.patch
* mm-compaction-export-tracepoints-status-strings-to-userspace.patch
* mm-compaction-export-tracepoints-zone-names-to-userspace.patch
* mm-compaction-export-tracepoints-zone-names-to-userspace-fix.patch
* mm-compaction-disginguish-contended-status-in-tracepoints.patch
* mm-oom-remove-task_lock-protecting-comm-printing.patch
* mm-page_alloc-remove-unnecessary-parameter-from-zone_watermark_ok_safe.patch
* mm-page_alloc-remove-unnecessary-recalculations-for-dirty-zone-balancing.patch
* mm-page_alloc-remove-unnecessary-taking-of-a-seqlock-when-cpusets-are-disabled.patch
* mm-page_alloc-use-masks-and-shifts-when-converting-gfp-flags-to-migrate-types.patch
* mm-page_alloc-distinguish-between-being-unable-to-sleep-unwilling-to-sleep-and-avoiding-waking-kswapd.patch
* mm-page_alloc-rename-__gfp_wait-to-__gfp_reclaim.patch
* mm-page_alloc-rename-__gfp_wait-to-__gfp_reclaim-fix.patch
* mm-page_alloc-rename-__gfp_wait-to-__gfp_reclaim-checkpatch-fixes.patch
* mm-page_alloc-delete-the-zonelist_cache.patch
* mm-page_alloc-remove-migrate_reserve.patch
* mm-page_alloc-reserve-pageblocks-for-high-order-atomic-allocations-on-demand.patch
* mm-page_alloc-reserve-pageblocks-for-high-order-atomic-allocations-on-demand-fix.patch
* mm-page_alloc-reserve-pageblocks-for-high-order-atomic-allocations-on-demand-fix-2.patch
* mm-page_alloc-only-enforce-watermarks-for-order-0-allocations.patch
* mm-page_alloc-only-enforce-watermarks-for-order-0-allocations-fix.patch
* mm-page_alloc-only-enforce-watermarks-for-order-0-allocations-fix-fix.patch
* mm-page_alloc-hide-some-GFP-internals-and-document-the-bit-and-flag-combinations.patch
* mm-page_alloc-hide-some-gfp-internals-and-document-the-bit-and-flag-combinations-fix.patch
* mm-fix-declarations-of-nr-delta-and-nr_pagecache_reclaimable.patch
* mm-fix-declarations-of-nr-delta-and-nr_pagecache_reclaimable-fix.patch
* mm-fix-overflow-in-find_zone_movable_pfns_for_nodes.patch
* mm-fix-the-racy-mm-locked_vm-change-in.patch
* mm-add-the-struct-mm_struct-mm-local-into.patch
* mm-oom_kill-remove-the-wrong-fatal_signal_pending-check-in-oom_kill_process.patch
* mm-oom_kill-cleanup-the-kill-sharing-same-memory-loop.patch
* mm-oom_kill-fix-the-wrong-task-mm-==-mm-checks-in-oom_kill_process.patch
* mm-oom_kill-fix-the-wrong-task-mm-==-mm-checks-in-oom_kill_process-fix.patch
* mm-optimize-pagehighmem-check.patch
* include-linux-mmzoneh-reflow-comment.patch
* mm-fs-introduce-mapping_gfp_constraint.patch
* mm-fs-introduce-mapping_gfp_constraint-checkpatch-fixes.patch
* mm-mmapc-remove-redundant-statement-error-=-enomem.patch
* mm-mmapc-do-not-initialize-retval-in-mmap_pgoff.patch
* mm-nommu-drop-unlikely-behind-bug_on.patch
* mm-mmapc-change-static-function-__install_special_mapping-args-order.patch
* mm-vmstatc-uninline-node_page_state.patch
* mm-vmstatc-uninline-node_page_state-fix.patch
* mm-dont-offset-memmap-for-flatmem.patch
* mm-change-highmem_zone-macro-definition.patch
* mm-vmacache-inline-vmacache_valid_mm.patch
* mm-skip-if-required_kernelcore-is-larger-than-totalpages.patch
* memcg-simplify-charging-kmem-pages.patch
* memcg-unify-slab-and-other-kmem-pages-charging.patch
* memcg-unify-slab-and-other-kmem-pages-charging-fix.patch
* memcg-simplify-and-inline-__mem_cgroup_from_kmem.patch
* memcg-simplify-and-inline-__mem_cgroup_from_kmem-fix-2.patch
* ksm-fix-rmap_item-anon_vma-memory-corruption-and-vma-user-after-free.patch
* ksm-add-cond_resched-to-the-rmap_walks.patch
* ksm-dont-fail-stable-tree-lookups-if-walking-over-stale-stable_nodes.patch
* ksm-use-the-helper-method-to-do-the-hlist_empty-check.patch
* ksm-use-find_mergeable_vma-in-try_to_merge_with_ksm_page.patch
* ksm-unstable_tree_search_insert-error-checking-cleanup.patch
* mm-clearing-pte-in-clear_soft_dirty.patch
* mm-clear_soft_dirty_pmd-requires-thp.patch
* mm-do-not-inc-nr_pagetable-if-ptlock_init-failed.patch
* mm-documentation-undoc-non-linear-vmas.patch
* mm-rmap-use-pte-lock-not-mmap_sem-to-set-pagemlocked.patch
* mm-page-migration-fix-pagemlocked-on-migrated-pages.patch
* mm-rename-mem_cgroup_migrate-to-mem_cgroup_replace_page.patch
* mm-correct-a-couple-of-page-migration-comments.patch
* mm-page-migration-use-the-put_new_page-whenever-necessary.patch
* mm-page-migration-trylock-newpage-at-same-level-as-oldpage.patch
* mm-page-migration-remove_migration_ptes-at-lockunlock-level.patch
* mm-simplify-page-migrations-anon_vma-comment-and-flow.patch
* mm-page-migration-use-migration-entry-for-swapcache-too.patch
* mm-page-migration-avoid-touching-newpage-until-no-going-back.patch
* mm-migrate-dirty-page-without-clear_page_dirty_for_io-etc.patch
* mm-cmac-suppress-warning.patch
* mm-maccessc-actually-return-efault-from-strncpy_from_unsafe.patch
* mm-hugetlb-make-node_hstates-array-static.patch
* mm-hugetlb-use-memory-policy-when-available.patch
* mm-hugetlbfs-optimize-when-numa=n.patch
* mm-hugetlb-define-hugetlb_falloc-structure-for-hole-punch-race.patch
* mm-hugetlb-setup-hugetlb_falloc-during-fallocate-hole-punch.patch
* mm-hugetlb-page-faults-check-for-fallocate-hole-punch-in-progress-and-wait.patch
* mm-hugetlb-unmap-pages-to-remove-if-page-fault-raced-with-hole-punch.patch
* mm-memcontrol-eliminate-root-memorycurrent.patch
* mm-kasan-rename-kasan_enabled-to-kasan_report_enabled.patch
* mm-kasan-module_vaddr-is-not-available-on-all-archs.patch
* mm-kasan-dont-use-kasan-shadow-pointer-in-generic-functions.patch
* mm-kasan-prevent-deadlock-in-kasan-reporting.patch
* kasan-update-reported-bug-types-for-not-user-nor-kernel-memory-accesses.patch
* kasan-update-reported-bug-types-for-kernel-memory-accesses.patch
* kasan-accurately-determine-the-type-of-the-bad-access.patch
* kasan-update-log-messages.patch
* kasan-various-fixes-in-documentation.patch
* kasan-various-fixes-in-documentation-checkpatch-fixes.patch
* kasan-move-kasan_sanitize-in-arch-x86-boot-makefile.patch
* kasan-update-reference-to-kasan-prototype-repo.patch
* lib-test_kasan-add-some-testcases.patch
* kasan-fix-a-type-conversion-error.patch
* kasan-use-is_aligned-in-memory_is_poisoned_8.patch
* mm-slub-kasan-enable-user-tracking-by-default-with-kasan=y.patch
* mm-slub-kasan-enable-user-tracking-by-default-with-kasan=y-fix.patch
* kasan-always-taint-kernel-on-report.patch
* mm-mlock-refactor-mlock-munlock-and-munlockall-code.patch
* mm-mlock-add-new-mlock-system-call.patch
* mm-introduce-vm_lockonfault.patch
* mm-introduce-vm_lockonfault-v9.patch
* mm-mlock-add-mlock-flags-to-enable-vm_lockonfault-usage.patch
* mm-mlock-add-mlock-flags-to-enable-vm_lockonfault-usage-v9.patch
* selftests-vm-add-tests-for-lock-on-fault.patch
* selftests-vm-add-tests-for-lock-on-fault-v9.patch
* zram-introduce-comp-algorithm-fallback-functionality.patch
* zram-keep-the-exact-overcommited-value-in-mem_used_max.patch
* zram-make-is_partial_io-valid_io_request-page_zero_filled-return-boolean.patch
* mm-zswap-remove-unneeded-initialization-to-null-in-zswap_entry_find_get.patch
* module-export-param_free_charp.patch
* zswap-use-charp-for-zswap-param-strings.patch
* zpool-remove-redundant-zpool-type-string-const-ify-zpool_get_type.patch
* mm-zsmalloc-constify-struct-zs_pool-name.patch
* zsmalloc-add-comments-for-inuse-to-zspage.patch
* zsmalloc-add-comments-for-inuse-to-zspage-v2-fix.patch
* zsmalloc-fix-obj_to_head-use-page_privatepage-as-value-but-not-pointer.patch
* zsmalloc-use-preempth-for-in_interrupt.patch
* zsmalloc-dont-test-shrinker_enabled-in-zs_shrinker_count.patch
* zsmalloc-remove-unless-line-in-obj_free.patch
* zsmalloc-reduce-size_class-memory-usage.patch
* mm-drop-page-slab_page.patch
* slab-slub-use-page-rcu_head-instead-of-page-lru-plus-cast.patch
* zsmalloc-use-page-private-instead-of-page-first_page.patch
* mm-pack-compound_dtor-and-compound_order-into-one-word-in-struct-page.patch
* mm-make-compound_head-robust.patch
* mm-make-compound_head-robust-fix.patch
* mm-use-unsigned-int-for-page-order.patch
* mm-use-unsigned-int-for-page-order-fix.patch
* mm-use-unsigned-int-for-page-order-fix-2.patch
* mm-use-unsigned-int-for-compound_dtor-compound_order-on-64bit.patch
* page-flags-trivial-cleanup-for-pagetrans-helpers.patch
* page-flags-move-code-around.patch
* page-flags-introduce-page-flags-policies-wrt-compound-pages.patch
* page-flags-introduce-page-flags-policies-wrt-compound-pages-fix.patch
* page-flags-introduce-page-flags-policies-wrt-compound-pages-fix-fix.patch
* page-flags-introduce-page-flags-policies-wrt-compound-pages-fix-3.patch
* page-flags-define-pg_locked-behavior-on-compound-pages.patch
* page-flags-define-pg_locked-behavior-on-compound-pages-fix.patch
* page-flags-define-behavior-of-fs-io-related-flags-on-compound-pages.patch
* page-flags-define-behavior-of-lru-related-flags-on-compound-pages.patch
* page-flags-define-behavior-slb-related-flags-on-compound-pages.patch
* page-flags-define-behavior-of-xen-related-flags-on-compound-pages.patch
* page-flags-define-pg_reserved-behavior-on-compound-pages.patch
* page-flags-define-pg_reserved-behavior-on-compound-pages-fix.patch
* page-flags-define-pg_swapbacked-behavior-on-compound-pages.patch
* page-flags-define-pg_swapcache-behavior-on-compound-pages.patch
* page-flags-define-pg_mlocked-behavior-on-compound-pages.patch
* page-flags-define-pg_uncached-behavior-on-compound-pages.patch
* page-flags-define-pg_uptodate-behavior-on-compound-pages.patch
* page-flags-look-at-head-page-if-the-flag-is-encoded-in-page-mapping.patch
* mm-sanitize-page-mapping-for-tail-pages.patch
* mm-proc-adjust-pss-calculation.patch
* rmap-add-argument-to-charge-compound-page.patch
* memcg-adjust-to-support-new-thp-refcounting.patch
* mm-thp-adjust-conditions-when-we-can-reuse-the-page-on-wp-fault.patch
* mm-adjust-foll_split-for-new-refcounting.patch
* mm-handle-pte-mapped-tail-pages-in-gerneric-fast-gup-implementaiton.patch
* thp-mlock-do-not-allow-huge-pages-in-mlocked-area.patch
* khugepaged-ignore-pmd-tables-with-thp-mapped-with-ptes.patch
* thp-rename-split_huge_page_pmd-to-split_huge_pmd.patch
* mm-vmstats-new-thp-splitting-event.patch
* mm-temporally-mark-thp-broken.patch
* thp-drop-all-split_huge_page-related-code.patch
* mm-drop-tail-page-refcounting.patch
* futex-thp-remove-special-case-for-thp-in-get_futex_key.patch
* ksm-prepare-to-new-thp-semantics.patch
* mm-thp-remove-compound_lock.patch
* arm64-thp-remove-infrastructure-for-handling-splitting-pmds.patch
* arm-thp-remove-infrastructure-for-handling-splitting-pmds.patch
* arm-thp-remove-infrastructure-for-handling-splitting-pmds-fix.patch
* mips-thp-remove-infrastructure-for-handling-splitting-pmds.patch
* powerpc-thp-remove-infrastructure-for-handling-splitting-pmds.patch
* s390-thp-remove-infrastructure-for-handling-splitting-pmds.patch
* sparc-thp-remove-infrastructure-for-handling-splitting-pmds.patch
* tile-thp-remove-infrastructure-for-handling-splitting-pmds.patch
* x86-thp-remove-infrastructure-for-handling-splitting-pmds.patch
* mm-thp-remove-infrastructure-for-handling-splitting-pmds.patch
* mm-thp-remove-infrastructure-for-handling-splitting-pmds-fix.patch
* mm-rework-mapcount-accounting-to-enable-4k-mapping-of-thps.patch
* mm-differentiate-page_mapped-from-page_mapcount-for-compound-pages.patch
* mm-numa-skip-pte-mapped-thp-on-numa-fault.patch
* thp-implement-split_huge_pmd.patch
* thp-add-option-to-setup-migration-entries-during-pmd-split.patch
* thp-mm-split_huge_page-caller-need-to-lock-page.patch
* thp-reintroduce-split_huge_page.patch
* thp-reintroduce-split_huge_page-fix-2.patch
* migrate_pages-try-to-split-pages-on-qeueuing.patch
* thp-introduce-deferred_split_huge_page.patch
* mm-re-enable-thp.patch
* thp-update-documentation.patch
* thp-allow-mlocked-thp-again.patch
* mm-increase-swap_cluster_max-to-batch-tlb-flushes.patch
* mm-increase-swap_cluster_max-to-batch-tlb-flushes-fix.patch
* mm-increase-swap_cluster_max-to-batch-tlb-flushes-fix-fix.patch
* x86-add-pmd_-for-thp.patch
* x86-add-pmd_-for-thp-fix.patch
* sparc-add-pmd_-for-thp.patch
* sparc-add-pmd_-for-thp-fix.patch
* powerpc-add-pmd_-for-thp.patch
* arm-add-pmd_mkclean-for-thp.patch
* arm64-add-pmd_-for-thp.patch
* mm-support-madvisemadv_free.patch
* mm-support-madvisemadv_free-fix.patch
* mm-support-madvisemadv_free-fix-2.patch
* mm-support-madvisemadv_free-fix-3.patch
* mm-support-madvisemadv_free-vs-thp-rename-split_huge_page_pmd-to-split_huge_pmd.patch
* mm-support-madvisemadv_free-fix-5.patch
* mm-support-madvisemadv_free-fix-6.patch
* mm-mark-stable-page-dirty-in-ksm.patch
* mm-dont-split-thp-page-when-syscall-is-called.patch
* mm-dont-split-thp-page-when-syscall-is-called-fix.patch
* mm-dont-split-thp-page-when-syscall-is-called-fix-2.patch
* mm-dont-split-thp-page-when-syscall-is-called-fix-3.patch
* mm-dont-split-thp-page-when-syscall-is-called-fix-4.patch
* mm-dont-split-thp-page-when-syscall-is-called-fix-5.patch
* mm-dont-split-thp-page-when-syscall-is-called-fix-6.patch
* mm-dont-split-thp-page-when-syscall-is-called-fix-6-fix.patch
* mm-free-swp_entry-in-madvise_free.patch
* mm-move-lazy-free-pages-to-inactive-list.patch
* mm-move-lazy-free-pages-to-inactive-list-fix.patch
* mm-move-lazy-free-pages-to-inactive-list-fix-fix.patch
* mm-move-lazy-free-pages-to-inactive-list-fix-fix-fix.patch
* fs-proc-arrayc-set-overflow-flag-in-case-of-error.patch
* use-poison_pointer_delta-for-poison-pointers.patch
* include-linux-compiler-gcch-improve-__visible-documentation.patch
* fs-jffs2-wbufc-remove-stray-semicolon.patch
* lib-dynamic_debugc-use-kstrdup_const.patch
* lib-documentation-synchronize-%p-formatting-documentation.patch
* lib-documentation-synchronize-%p-formatting-documentation-fix.patch
* lib-documentation-synchronize-%p-formatting-documentation-fix-fix.patch
* lib-vsprintfc-handle-invalid-format-specifiers-more-robustly.patch
* lib-vsprintfc-also-improve-sanity-check-in-bstr_printf.patch
* lib-vsprintfc-remove-special-handling-in-pointer.patch
* test_printf-test-printf-family-at-runtime.patch
* selftests-run-test_printf-module.patch
* lib-vsprintfc-update-documentation.patch
* bitopsh-improve-sign_extend32s-documentation.patch
* bitopsh-add-sign_extend64.patch
* arch-sh-use-sign_extend64-for-sign-extension.patch
* arch-sh-use-sign_extend64-for-sign-extension-2.patch
* arch-x86-use-sign_extend64-for-sign-extension.patch
* lib-halfmd4-use-rol32-inline-function-in-the-round-macro.patch
* lib-test-string_helpersc-add-string_get_size-tests.patch
* lib-test-string_helpersc-add-string_get_size-tests-v5.patch
* lib-fix-data-race-in-llist_del_first.patch
* lib-introduce-kvasprintf_const.patch
* kobject-use-kvasprintf_const-for-formatting-name.patch
* change-current_is_single_threaded-to-use-for_each_thread.patch
* rbtree-clarify-documentation-of-rbtree_postorder_for_each_entry_safe.patch
* rbtree-clarify-documentation-of-rbtree_postorder_for_each_entry_safe-fix.patch
* mm-utilc-add-kstrimdup.patch
* lib-add-crc64-ecma-module.patch
* checkpatch-improve-tests-for-fixes-long-lines-and-stack-dumps-in-commit-log.patch
* nilfs2-drop-null-test-before-destroy-functions.patch
* nilfs2-use-nilfs_warning-in-allocator-implementation.patch
* nilfs2-do-not-call-nilfs_mdt_bgl_lock-needlessly.patch
* nilfs2-refactor-nilfs_palloc_find_available_slot.patch
* nilfs2-get-rid-of-nilfs_palloc_group_is_in.patch
* nilfs2-add-helper-functions-to-delete-blocks-from-dat-file.patch
* nilfs2-free-unused-dat-file-blocks-during-garbage-collection.patch
* nilfs2-add-a-tracepoint-for-tracking-stage-transition-of-segment-construction.patch
* nilfs2-add-a-tracepoint-for-transaction-events.patch
* nilfs2-add-tracepoints-for-analyzing-sufile-manipulation.patch
* nilfs2-add-tracepoints-for-analyzing-reading-and-writing-metadata-files.patch
* maintainers-nilfs2-add-header-file-for-tracing.patch
* nilfs2-fix-gcc-unused-but-set-variable-warnings.patch
* nilfs2-fix-gcc-uninitialized-variable-warnings-in-powerpc-build.patch
* fat-add-fat_fallocate-operation.patch
* fat-skip-cluster-allocation-on-fallocated-region.patch
* fat-permit-to-return-phy-block-number-by-fibmap-in-fallocated-region.patch
* documentation-filesystems-vfattxt-update-the-limitation-for-fat-fallocate.patch
* signals-kill-block_all_signals-and-unblock_all_signals.patch
* signal-turn-dequeue_signal_lock-into-kernel_dequeue_signal.patch
* signal-introduce-kernel_signal_stop-to-fix-jffs2_garbage_collect_thread.patch
* signal-remove-jffs2_garbage_collect_thread-allow_signalsigcont.patch
* coredump-ensure-all-coredumping-tasks-have-signal_group_coredump.patch
* coredump-change-zap_threads-and-zap_process-to-use-for_each_thread.patch
* fs-seq_file-use-seq_-helpers-in-seq_hex_dump.patch
* seq_file-re-use-string_escape_str.patch
* fs-seqfile-always-allow-oom-killer.patch
* kexec-use-file-name-as-the-output-message-prefix.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* pidns-fix-set-getpriority-and-ioprio_set-get-in-prio_user-mode.patch
* dma-mapping-tidy-up-dma_parms-default-handling.patch
* dma-mapping-tidy-up-dma_parms-default-handling-fix.patch
* dma-debug-check-nents-in-dma_sync_sg.patch
* dma-debug-allow-poisoning-nonzero-allocations.patch
* panic-release-stale-console-lock-to-always-get-the-logbuf-printed-out.patch
* panic-release-stale-console-lock-to-always-get-the-logbuf-printed-out-fix.patch
* zlib-fix-usage-example-of-zlib_adler32.patch
* ipcmsg-drop-dst-nil-validation-in-copy_msg.patch
* ipc-msgc-msgsnd-use-freezable-blocking-call.patch
* msgrcv-use-freezable-blocking-call.patch
  linux-next.patch
  linux-next-rejects.patch
* mm-page_alloc-rename-__gfp_wait-to-__gfp_reclaim-nvem-fix.patch
* mm-page_alloc-rename-__gfp_wait-to-__gfp_reclaim-arm-fix.patch
* mm-page_alloc-rename-__gfp_wait-to-__gfp_reclaim-arm-fix-fix.patch
* net-ipv4-routec-prevent-oops.patch
* drivers-rtc-rtc-pcf2127c-hack.patch
* mips-add-entry-for-new-mlock2-syscall.patch
* sparc-sparc64-allocate-sys_membarrier-system-call-number.patch
* kernelh-make-abs-work-with-64-bit-types.patch
* remove-abs64.patch
* remove-abs64-fix.patch
* remove-abs64-fix-fix.patch
* mm-doc-fix-misleading-code-reference-of-overcommit_memory.patch
* pcnet32-use-pci_set_dma_mask-insted-of-pci_dma_supported.patch
* tw68-core-use-pci_set_dma_mask-insted-of-pci_dma_supported.patch
* saa7164-use-pci_set_dma_mask-insted-of-pci_dma_supported.patch
* saa7134-use-pci_set_dma_mask-insted-of-pci_dma_supported.patch
* cx88-use-pci_set_dma_mask-insted-of-pci_dma_supported.patch
* cx25821-use-pci_set_dma_mask-insted-of-pci_dma_supported.patch
* cx23885-use-pci_set_dma_mask-insted-of-pci_dma_supported.patch
* netup_unidvb-use-pci_set_dma_mask-insted-of-pci_dma_supported.patch
* nouveau-dont-call-pci_dma_supported.patch
* sfc-dont-call-dma_supported.patch
* kaweth-remove-ifdefed-out-call-to-dma_supported.patch
* usbnet-remove-ifdefed-out-call-to-dma_supported.patch
* pci-remove-pci_dma_supported.patch
* dma-remove-external-references-to-dma_supported.patch
* modpost-add-flag-e-for-making-section-mismatches-fatal.patch
* cxgbi-fix-build-with-extra_cflags.patch
* kmap_atomic_to_page-has-no-users-remove-it.patch
* fs-kdev_t-remove-unused-huge_valid_dev-function.patch
* fs-kdev_t-old-new_valid_dev-can-be-boolean.patch
* fs-vfs-remove-unnecessary-new_valid_dev-check.patch
* fs-btrfs-remove-unnecessary-new_valid_dev-check.patch
* fs-exofs-remove-unnecessary-new_valid_dev-check.patch
* fs-ext2-remove-unnecessary-new_valid_dev-check.patch
* fs-ext4-remove-unnecessary-new_valid_dev-check.patch
* fs-f2fs-remove-unnecessary-new_valid_dev-check.patch
* fs-hpfs-remove-unnecessary-new_valid_dev-check.patch
* fs-jfs-remove-unnecessary-new_valid_dev-check.patch
* fs-ncpfs-remove-unnecessary-new_valid_dev-check.patch
* fs-nfs-remove-unnecessary-new_valid_dev-check.patch
* fs-nilfs2-remove-unnecessary-new_valid_dev-check.patch
* fs-reiserfs-remove-unnecessary-new_valid_dev-check.patch
* fs-stat-remove-unnecessary-new_valid_dev-check.patch
* fs-ubifs-remove-unnecessary-new_valid_dev-check.patch
* fs-binfmt_elf_fdpicc-provide-nommu-loader-for-regular-elf-binaries.patch
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
