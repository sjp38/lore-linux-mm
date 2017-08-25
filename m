Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id DA9F96810D7
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 18:51:02 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p14so1559817wrg.6
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 15:51:02 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z39si132970wrz.317.2017.08.25.15.50.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 15:51:00 -0700 (PDT)
Date: Fri, 25 Aug 2017 15:50:57 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2017-08-25-15-50 uploaded
Message-ID: <59a0a9d1.jzOblYrHfdIDuDZw%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2017-08-25-15-50 has been uploaded to

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


This mmotm tree contains the following patches against 4.13-rc6:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
* pm-hibernate-feed-the-wathdog-when-creating-snapshot.patch
* pm-hibernate-feed-the-wathdog-when-creating-snapshot-v2.patch
* pm-hibernate-feed-the-wathdog-when-creating-snapshot-v3.patch
* mm-shmem-fix-handling-sys-kernel-mm-transparent_hugepage-shmem_enabled.patch
* dax-fix-deadlock-due-to-misaligned-pmd-faults.patch
* mm-madvise-fix-freeing-of-locked-page-with-madv_free.patch
* fork-fix-incorrect-fput-of-exe_file-causing-use-after-free.patch
* mm-reversed-logic-in-memblock_discard.patch
* mm-skip-hwpoisoned-pages-when-onlining-pages.patch
* fortify-use-warn-instead-of-bug-for-now.patch
* adfs-use-unsigned-types-for-memcpy-length.patch
* mmpage_alloc-dont-call-__node_reclaim-with-oom_lock-held.patch
* kthread_worker-dont-hog-the-cpu.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* metag-numa-remove-the-unused-parent_node-macro.patch
* mm-add-vm_insert_mixed_mkwrite.patch
* dax-relocate-some-dax-functions.patch
* dax-use-common-4k-zero-page-for-dax-mmap-reads.patch
* dax-remove-dax-code-from-page_cache_tree_insert.patch
* dax-move-all-dax-radix-tree-defs-to-fs-daxc.patch
* dax-explain-how-read2-write2-addresses-are-validated.patch
* dax-use-pg_pmd_colour-instead-of-open-coding.patch
* modpost-simplify-sec_name.patch
* ocfs2-make-ocfs2_set_acl-static.patch
* ocfs2-re-queue-ast-or-bast-if-sending-is-failed-to-improve-the-reliability.patch
* ocfs2-re-queue-ast-or-bast-if-sending-is-failed-to-improve-the-reliability-fix.patch
* ocfs2-clean-up-some-dead-code.patch
* ocfs2-get-rid-of-ocfs2_is_o2cb_active-function.patch
* ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called.patch
* ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called-fix.patch
* ocfs2-give-an-obvious-tip-for-dismatch-cluster-names.patch
* ocfs2-give-an-obvious-tip-for-dismatch-cluster-names-v2.patch
* ocfs2-move-some-definitions-to-header-file.patch
* ocfs2-fix-some-small-problems.patch
* ocfs2-add-kobject-for-online-file-check.patch
* ocfs2-add-duplicative-ino-number-check.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
  mm.patch
* slub-make-sure-struct-kmem_cache_node-is-initialized-before-publication.patch
* mm-add-slub-free-list-pointer-obfuscation.patch
* mm-slubc-add-a-naive-detection-of-double-free-or-corruption.patch
* mm-track-actual-nr_scanned-during-shrink_slab.patch
* drm-i915-wire-up-shrinkctl-nr_scanned.patch
* mm-memory_hotplug-just-build-zonelist-for-new-added-node.patch
* mm-memory_hotplug-just-build-zonelist-for-new-added-node-fix.patch
* mm-memory_hotplug-just-build-zonelist-for-new-added-node-fix-fix.patch
* mm-mempolicy-add-queue_pages_required.patch
* mm-x86-move-_page_swp_soft_dirty-from-bit-7-to-bit-1.patch
* mm-thp-introduce-separate-ttu-flag-for-thp-freezing.patch
* mm-thp-introduce-config_arch_enable_thp_migration.patch
* mm-thp-enable-thp-migration-in-generic-path.patch
* mm-thp-enable-thp-migration-in-generic-path-fix.patch
* mm-thp-enable-thp-migration-in-generic-path-fix-fix.patch
* mm-thp-check-pmd-migration-entry-in-common-path.patch
* mm-soft-dirty-keep-soft-dirty-bits-over-thp-migration.patch
* mm-mempolicy-mbind-and-migrate_pages-support-thp-migration.patch
* mm-migrate-move_pages-supports-thp-migration.patch
* mm-memory_hotplug-memory-hotremove-supports-thp-migration.patch
* mm-memory_hotplug-display-allowed-zones-in-the-preferred-ordering.patch
* mm-memory_hotplug-remove-zone-restrictions.patch
* zram-clean-up-duplicated-codes-in-__zram_bvec_write.patch
* zram-clean-up-duplicated-codes-in-__zram_bvec_write-fix.patch
* zram-inlining-zram_compress.patch
* zram-rename-zram_decompress_page-with-__zram_bvec_read.patch
* zram-add-interface-to-specify-backing-device.patch
* zram-add-free-space-management-in-backing-device.patch
* zram-identify-asynchronous-ios-return-value.patch
* zram-write-incompressible-pages-to-backing-device.patch
* zram-write-incompressible-pages-to-backing-device-fix.patch
* zram-read-page-from-backing-device.patch
* zram-read-page-from-backing-device-fix.patch
* zram-add-config-and-doc-file-for-writeback-feature.patch
* mm-page_alloc-rip-out-zonelist_order_zone.patch
* mm-page_alloc-rip-out-zonelist_order_zone-fix.patch
* mm-page_alloc-remove-boot-pageset-initialization-from-memory-hotplug.patch
* mm-page_alloc-do-not-set_cpu_numa_mem-on-empty-nodes-initialization.patch
* mm-memory_hotplug-drop-zone-from-build_all_zonelists.patch
* mm-memory_hotplug-remove-explicit-build_all_zonelists-from-try_online_node.patch
* mm-page_alloc-simplify-zonelist-initialization.patch
* mm-page_alloc-remove-stop_machine-from-build_all_zonelists.patch
* mm-memory_hotplug-get-rid-of-zonelists_mutex.patch
* mm-sparse-page_ext-drop-ugly-n_high_memory-branches-for-allocations.patch
* mm-page_owner-make-init_pages_in_zone-faster.patch
* mm-page_owner-make-init_pages_in_zone-faster-fix.patch
* mm-page_owner-make-init_pages_in_zone-faster-fix-checkpatch-fixes.patch
* mm-page_ext-periodically-reschedule-during-page_ext_init.patch
* mm-page_owner-dont-grab-zone-lock-for-init_pages_in_zone.patch
* mm-mremap-fail-map-duplication-attempts-for-private-mappings.patch
* mm-gup-make-__gup_device_-require-thp.patch
* mm-hugetlb-make-huge_pte_offset-consistent-and-document-behaviour.patch
* mm-hugetlbc-make-huge_pte_offset-consistent-and-document-behaviour-v2.patch
* mm-always-flush-vma-ranges-affected-by-zap_page_range-v2.patch
* zsmalloc-zs_page_migrate-skip-unnecessary-loops-but-not-return-ebusy-if-zspage-is-not-inuse.patch
* zsmalloc-zs_page_migrate-skip-unnecessary-loops-but-not-return-ebusy-if-zspage-is-not-inuse-fix.patch
* mm-vmscan-do-not-loop-on-too_many_isolated-for-ever.patch
* mm-vmscan-do-not-loop-on-too_many_isolated-for-ever-fix.patch
* fscache-remove-unused-now_uncached-callback.patch
* mm-make-pagevec_lookup-update-index.patch
* mm-implement-find_get_pages_range.patch
* fs-fix-performance-regression-in-clean_bdev_aliases.patch
* ext4-use-pagevec_lookup_range-in-ext4_find_unwritten_pgoff.patch
* ext4-use-pagevec_lookup_range-in-writeback-code.patch
* hugetlbfs-use-pagevec_lookup_range-in-remove_inode_hugepages.patch
* fs-use-pagevec_lookup_range-in-page_cache_seek_hole_data.patch
* mm-use-find_get_pages_range-in-filemap_range_has_page.patch
* mm-remove-nr_pages-argument-from-pagevec_lookup_range.patch
* mm-memcg-reset-memorylow-during-memcg-offlining.patch
* cgroup-revert-fa06235b8eb0-cgroup-reset-css-on-destruction.patch
* mm-ksm-constify-attribute_group-structures.patch
* mm-slub-constify-attribute_group-structures.patch
* mm-page_idle-constify-attribute_group-structures.patch
* mm-huge_memory-constify-attribute_group-structures.patch
* mm-hugetlb-constify-attribute_group-structures.patch
* mm-memcontrol-use-int-for-event-state-parameter-in-several-functions.patch
* mm-memcontrol-use-int-for-event-state-parameter-in-several-functions-v2.patch
* mm-thp-swap-support-to-clear-swap-cache-flag-for-thp-swapped-out.patch
* mm-thp-swap-support-to-reclaim-swap-space-for-thp-swapped-out.patch
* mm-thp-swap-support-to-reclaim-swap-space-for-thp-swapped-out-fix.patch
* mm-thp-swap-make-reuse_swap_page-works-for-thp-swapped-out.patch
* mm-thp-swap-make-reuse_swap_page-works-for-thp-swapped-out-fix.patch
* mm-thp-swap-dont-allocate-huge-cluster-for-file-backed-swap-device.patch
* block-thp-make-block_device_operationsrw_page-support-thp.patch
* test-code-to-write-thp-to-swap-device-as-a-whole.patch
* mm-thp-swap-support-to-split-thp-for-thp-swapped-out.patch
* memcg-thp-swap-support-move-mem-cgroup-charge-for-thp-swapped-out.patch
* memcg-thp-swap-avoid-to-duplicated-charge-thp-in-swap-cache.patch
* memcg-thp-swap-make-mem_cgroup_swapout-support-thp.patch
* mm-thp-swap-delay-splitting-thp-after-swapped-out.patch
* mm-thp-swap-add-thp-swapping-out-fallback-counting.patch
* shmem-shmem_charge-verify-max_block-is-not-exceeded-before-inode-update.patch
* shmem-introduce-shmem_inode_acct_block.patch
* userfaultfd-shmem-add-shmem_mfill_zeropage_pte-for-userfaultfd-support.patch
* userfaultfd-mcopy_atomic-introduce-mfill_atomic_pte-helper.patch
* userfaultfd-shmem-wire-up-shmem_mfill_zeropage_pte.patch
* userfaultfd-report-uffdio_zeropage-as-available-for-shmem-vmas.patch
* userfaultfd-selftest-enable-testing-of-uffdio_zeropage-for-shmem.patch
* fs-remove-unnecessary-null-f_mapping-check-in-sync_file_range.patch
* fs-remove-unneeded-forward-definition-of-mm_struct-from-fsh.patch
* mm-hugetlb-define-system-call-hugetlb-size-encodings-in-single-file.patch
* mm-arch-consolidate-mmap-hugetlb-size-encodings.patch
* mm-shm-use-new-hugetlb-size-encoding-definitions.patch
* mm-rename-global_page_state-to-global_zone_page_state.patch
* userfaultfd-add-feature-to-request-for-a-signal-delivery.patch
* userfaultfd-selftest-add-tests-for-uffd_feature_sigbus-feature.patch
* userfaultfd-selftest-exercise-uffdio_copy-zeropage-eexist.patch
* userfaultfd-selftest-exercise-uffdio_copy-zeropage-eexist-fix.patch
* userfaultfd-selftest-explicit-failure-if-the-sigbus-test-failed.patch
* userfaultfd-call-userfaultfd_unmap_prep-only-if-__split_vma-succeeds.patch
* userfaultfd-provide-pid-in-userfault-msg.patch
* userfaultfd-provide-pid-in-userfault-msg-add-feat-union.patch
* mm-hugetlb-do-not-allocate-non-migrateable-gigantic-pages-from-movable-zones.patch
* mm-vmstat-fix-divide-error-at-__fragmentation_index.patch
* mm-vmalloc-reduce-half-comparison-during-pcpu_get_vm_areas.patch
* mm-devm_memremap_pages-use-multi-order-radix-for-zone_device-lookups.patch
* mm-shmem-add-hugetlbfs-support-to-memfd_create.patch
* selftests-memfd-add-memfd_create-hugetlbfs-selftest.patch
* vmstat-fix-wrong-comment.patch
* mm-dont-reinvent-the-wheel-but-use-existing-llist-api.patch
* mm-swap-add-swap-readahead-hit-statistics.patch
* mm-swap-add-swap-readahead-hit-statistics-fix.patch
* mm-swap-fix-swap-readahead-marking.patch
* mm-swap-vma-based-swap-readahead.patch
* mm-swap-add-sysfs-interface-for-vma-based-swap-readahead.patch
* mm-swap-dont-use-vma-based-swap-readahead-if-hdd-is-used-as-swap.patch
* z3fold-use-per-cpu-unbuddied-lists.patch
* mm-oom-do-not-rely-on-tif_memdie-for-memory-reserves-access.patch
* mm-replace-tif_memdie-checks-by-tsk_is_oom_victim.patch
* swap-choose-swap-device-according-to-numa-node.patch
* swap-choose-swap-device-according-to-numa-node-v2.patch
* swap-choose-swap-device-according-to-numa-node-v2-fix.patch
* mm-oom-let-oom_reap_task-and-exit_mmap-to-run-concurrently.patch
* mm-oom-let-oom_reap_task-and-exit_mmap-to-run-concurrently-fix.patch
* mm-oom-let-oom_reap_task-and-exit_mmap-to-run-concurrently-fix-2.patch
* mm-oom-let-oom_reap_task-and-exit_mmap-to-run-concurrently-fix-3.patch
* mm-clear-to-access-sub-page-last-when-clearing-huge-page.patch
* add-proc-pid-smaps_rollup.patch
* x86mpx-make-mpx-depend-on-x86-64-to-free-up-vma-flag.patch
* mmfork-introduce-madv_wipeonfork.patch
* hmm-heterogeneous-memory-management-documentation-v3.patch
* mm-hmm-heterogeneous-memory-management-hmm-for-short-v5.patch
* mm-hmm-mirror-mirror-process-address-space-on-device-with-hmm-helpers-v3.patch
* mm-hmm-mirror-helper-to-snapshot-cpu-page-table-v4.patch
* mm-hmm-mirror-device-page-fault-handler.patch
* mm-memory_hotplug-introduce-add_pages.patch
* mm-zone_device-new-type-of-zone_device-for-unaddressable-memory-v5.patch
* mm-zone_device-new-type-of-zone_device-for-unaddressable-memory-fix.patch
* mm-zone_device-special-case-put_page-for-device-private-pages-v4.patch
* mm-memcontrol-allow-to-uncharge-page-without-using-page-lru-field.patch
* mm-memcontrol-support-memory_device_private-v4.patch
* mm-hmm-devmem-device-memory-hotplug-using-zone_device-v7.patch
* mm-hmm-devmem-dummy-hmm-device-for-zone_device-memory-v3.patch
* mm-migrate-new-migrate-mode-migrate_sync_no_copy.patch
* mm-migrate-new-memory-migration-helper-for-use-with-device-memory-v5.patch
* mm-migrate-migrate_vma-unmap-page-from-vma-while-collecting-pages.patch
* mm-migrate-support-un-addressable-zone_device-page-in-migration-v3.patch
* mm-migrate-allow-migrate_vma-to-alloc-new-page-on-empty-entry-v4.patch
* mm-device-public-memory-device-memory-cache-coherent-with-cpu-v5.patch
* mm-hmm-add-new-helper-to-hotplug-cdm-memory-region-v3.patch
* mm-hmm-avoid-bloating-arch-that-do-not-make-use-of-hmm.patch
* mm-hmm-struct-hmm-is-only-use-by-hmm-mirror-functionality-v2.patch
* mm-remove-useless-vma-parameter-to-offset_il_node.patch
* mm-compaction-kcompactd-should-not-ignore-pageblock-skip.patch
* mm-compaction-persistently-skip-hugetlbfs-pageblocks.patch
* mm-compaction-persistently-skip-hugetlbfs-pageblocks-fix.patch
* userfaultfd-non-cooperative-closing-the-uffd-without-triggering-sigbus.patch
* mm-page_fault-remove-reduntant-check-for-write-access.patch
* mm-change-the-call-sites-of-numa-statistics-items.patch
* mm-change-the-call-sites-of-numa-statistics-items-checkpatch-fixes.patch
* mm-update-numa-counter-threshold-size.patch
* mm-consider-the-number-in-local-cpus-when-reads-numa-stats.patch
* mm-mlock-use-page_zone-instead-of-page_zone_id.patch
* mm-zsmalloc-change-stat-type-parameter-to-int.patch
* mm-fadvise-avoid-fadvise-for-fs-without-backing-device.patch
* mm-page_alloc-return-0-in-case-this-node-has-no-page-within-the-zone.patch
* mm-vmscan-do-not-pass-reclaimed-slab-to-vmpressure.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* mm-walk-the-zone-in-pageblock_nr_pages-steps.patch
* fs-proc-remove-priv-argument-from-is_stack.patch
* fs-proc-remove-priv-argument-from-is_stack-fix.patch
* proc-uninline-proc_create.patch
* fs-proc-unconditional-cond_resched-when-reading-smaps.patch
* linux-kernelh-move-div_round_down_ull-macro.patch
* add-multibyte-memset-functions.patch
* add-testcases-for-memset16-32-64.patch
* add-testcases-for-memset16-32-64-fix.patch
* x86-implement-memset16-memset32-memset64.patch
* arm-implement-memset32-memset64.patch
* alpha-add-support-for-memset16.patch
* zram-convert-to-using-memset_l.patch
* sym53c8xx_2-convert-to-use-memset32.patch
* vga-optimise-console-scrolling.patch
* vga-optimise-console-scrolling-fix.patch
* parse-maintainers-add-ability-to-specify-filenames.patch
* make-nr_cpu_ids-unsigned.patch
* bitops-avoid-integer-overflow-in-genmask_ull.patch
* rbtree-cache-leftmost-node-internally.patch
* rbtree-optimize-root-check-during-rebalancing-loop.patch
* rbtree-add-some-additional-comments-for-rebalancing-cases.patch
* lib-rbtree_testc-make-input-module-parameters.patch
* lib-rbtree_testc-add-inorder-traversal-test.patch
* lib-rbtree_testc-support-rb_root_cached.patch
* sched-fair-replace-cfs_rq-rb_leftmost.patch
* sched-deadline-replace-earliest-dl-and-rq-leftmost-caching.patch
* locking-rtmutex-replace-top-waiter-and-pi_waiters-leftmost-caching.patch
* block-cfq-replace-cfq_rb_root-leftmost-caching.patch
* lib-interval_tree-fast-overlap-detection.patch
* lib-interval_tree-fast-overlap-detection-fix.patch
* lib-interval-tree-correct-comment-wrt-generic-flavor.patch
* procfs-use-faster-rb_first_cached.patch
* fs-epoll-use-faster-rb_first_cached.patch
* mem-memcg-cache-rightmost-node.patch
* mem-memcg-cache-rightmost-node-fix.patch
* block-cfq-cache-rightmost-rb_node.patch
* block-cfq-cache-rightmost-rb_node-fix.patch
* lib-hexdump-return-einval-in-case-of-error-in-hex2bin.patch
* lib-add-test-module-for-config_debug_virtual.patch
* lib-make-bitmap_parselist-thread-safe-and-much-faster.patch
* lib-add-test-for-bitmap_parselist.patch
* lib-add-test-for-bitmap_parselist-fix.patch
* bitmap-introduce-bitmap_from_u64.patch
* bitmap-introduce-bitmap_from_u64-checkpatch-fixes.patch
* bitmap-introduce-bitmap_from_u64-checkpatch-fixes-fix.patch
* lib-rhashtable-fix-comment-on-locks_mul-default-value.patch
* lib-stringc-check-for-kmalloc-failure.patch
* lib-cmldinec-clean-up-the-meaningless-comment.patch
* checkpatch-add-strict-check-for-ifs-with-unnecessary-parentheses.patch
* init-move-stack-canary-initialization-after-setup_arch.patch
* extract-early-boot-entropy-from-the-passed-cmdline.patch
* autofs-fix-at_no_automount-not-being-honored.patch
* autofs-make-disc-device-user-accessible.patch
* autofs-make-dev-ioctl-version-and-ismountpoint-user-accessible.patch
* autofs-remove-unused-autofs_ioc_expire_direct-indirect.patch
* autofs-non-functional-header-inclusion-cleanup.patch
* autofs-use-autofs_dev_ioctl_size.patch
* autofs-drop-wrong-comment.patch
* autofs-use-unsigned-int-long-instead-of-uint-ulong-for-ioctl-args.patch
* vfat-deduplicate-hex2bin.patch
* test_kmod-remove-paranoid-uint_max-check-on-uint-range-processing.patch
* test_kmod-flip-int-checks-to-be-consistent.patch
* kmod-split-out-umh-code-into-its-own-file.patch
* maintainers-clarify-kmod-is-just-a-kernel-module-loader.patch
* kmod-split-off-umh-headers-into-its-own-file.patch
* kmod-move-ifdef-config_modules-wrapper-to-makefile.patch
* seq_file-delete-small-value-optimization.patch
* cpumask-make-cpumask_next-out-of-line.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* rapidio-remove-global-irq-spinlocks-from-the-subsystem.patch
* uapi-fix-linux-sysctlh-userspace-compilation-errors.patch
* m32r-defconfig-cleanup-from-old-kconfig-options.patch
* mn10300-defconfig-cleanup-from-old-kconfig-options.patch
* sh-defconfig-cleanup-from-old-kconfig-options.patch
* kcov-support-compat-processes.patch
* kernel-reboot-add-devm_register_reboot_notifier.patch
* kernel-reboot-add-devm_register_reboot_notifier-fix.patch
* ipc-convert-ipc_namespacecount-from-atomic_t-to-refcount_t.patch
* ipc-convert-sem_undo_listrefcnt-from-atomic_t-to-refcount_t.patch
* ipc-convert-kern_ipc_permrefcount-from-atomic_t-to-refcount_t.patch
* ipc-sem-drop-sem_checkid-helper.patch
* ipc-sem-play-nicer-with-large-nsops-allocations.patch
* ipc-optimize-semget-shmget-msgget-for-lots-of-keys.patch
  linux-next.patch
  linux-next-rejects.patch
  linux-next-rejects-2.patch
  linux-next-git-rejects.patch
* zram-mm-vs-block.patch
* fs-select-fix-memory-corruption-in-compat_get_fd_set.patch
* nfit-use-init_completion-in-acpi_nfit_flush_probe.patch
* completion-avoid-unnecessary-stack-allocation-for-completion_initializer_onstack.patch
* drivers-media-cec-cec-adapc-fix-build-with-gcc-444.patch
* fscache-fix-fscache_objlist_show-format-processing.patch
* ib-mlx4-fix-sprintf-format-warning.patch
* iopoll-avoid-wint-in-bool-context-warning.patch
* select-use-get-put_timespec64.patch
* io_getevents-use-timespec64-to-represent-timeouts.patch
* sparc64-ng4-memset-32-bits-overflow.patch
* treewide-remove-gfp_temporary-allocation-flag.patch
* treewide-remove-gfp_temporary-allocation-flag-fix.patch
* treewide-remove-gfp_temporary-allocation-flag-checkpatch-fixes.patch
* treewide-remove-gfp_temporary-allocation-flag-fix-2.patch
* lib-crc-ccitt-add-ccitt-false-crc16-variant.patch
  mm-add-strictlimit-knob-v2.patch
  make-sure-nobodys-leaking-resources.patch
  releasing-resources-with-children.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  mutex-subsystem-synchro-test-module.patch
  slab-leaks3-default-y.patch
  workaround-for-a-pci-restoring-bug.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
