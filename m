Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 477F06B04D7
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 19:57:18 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id o201so541381wmg.3
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 16:57:18 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y39si27553479wrb.0.2017.07.31.16.57.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Jul 2017 16:57:16 -0700 (PDT)
Date: Mon, 31 Jul 2017 16:57:14 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2017-07-31-16-56 uploaded
Message-ID: <597fc3da.4tconouVEWUea8Sl%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2017-07-31-16-56 has been uploaded to

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


This mmotm tree contains the following patches against 4.13-rc3:
(patches marked "*" will be included in linux-next)

  i-need-old-gcc.patch
* mm-hugetlb-__get_user_pages-ignores-certain-follow_hugetlb_page-errors.patch
* pid-kill-pidhash_size-in-pidhash_init.patch
* mm-mprotect-flush-tlb-if-potentially-racing-with-a-parallel-reclaim-leaving-stale-tlb-entries.patch
* mm-mprotect-flush-tlb-if-potentially-racing-with-a-parallel-reclaim-leaving-stale-tlb-entries-fix.patch
* mm-mprotect-flush-tlb-if-potentially-racing-with-a-parallel-reclaim-leaving-stale-tlb-entries-fix-fix.patch
* userfaultfd-non-cooperative-notify-about-unmap-of-destination-during-mremap.patch
* kasan-avoid-wmaybe-uninitialized-warning-v3.patch
* kthread-fix-documentation-build-warning.patch
* zram-do-not-free-pool-size_class.patch
* fortify-use-warn-instead-of-bug-for-now.patch
* fortify-use-warn-instead-of-bug-for-now-fix.patch
* swap-fix-oops-during-block-io-poll-in-swapin-path.patch
* swap-fix-oops-during-block-io-poll-in-swapin-path-fix.patch
* mm-take-memory-hotplug-lock-within-numa_zonelist_order_handler.patch
* userfaultfd_zeropage-return-enospc-in-case-mm-has-gone.patch
* mm-skip-hwpoisoned-pages-when-onlining-pages.patch
* cpuset-fix-a-deadlock-due-to-incomplete-patching-of-cpusets_enabled.patch
* ipc-add-missing-container_ofs-for-randstruct.patch
* userfaultfd-non-cooperative-flush-event_wqh-at-release-time.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* metag-numa-remove-the-unused-parent_node-macro.patch
* mm-add-vm_insert_mixed_mkwrite.patch
* dax-relocate-some-dax-functions.patch
* dax-use-common-4k-zero-page-for-dax-mmap-reads.patch
* dax-remove-dax-code-from-page_cache_tree_insert.patch
* dax-move-all-dax-radix-tree-defs-to-fs-daxc.patch
* ocfs2-get-rid-of-ocfs2_is_o2cb_active-function.patch
* ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called.patch
* ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called-fix.patch
* ocfs2-dlm-optimization-of-code-while-free-dead-node-locks.patch
* ocfs2-dlm-optimization-of-code-while-free-dead-node-locks-checkpatch-fixes.patch
* ocfs2-give-an-obvious-tip-for-dismatch-cluster-names.patch
* ocfs2-give-an-obvious-tip-for-dismatch-cluster-names-v2.patch
* ocfs2-move-some-definitions-to-header-file.patch
* ocfs2-fix-some-small-problems.patch
* ocfs2-add-kobject-for-online-file-check.patch
* ocfs2-add-duplicative-ino-number-check.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
  mm.patch
* slub-make-sure-struct-kmem_cache_node-is-initialized-before-publication.patch
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
* zram-inlining-zram_compress.patch
* zram-rename-zram_decompress_page-with-__zram_bvec_read.patch
* zram-add-interface-to-specify-backing-device.patch
* zram-add-free-space-management-in-backing-device.patch
* zram-identify-asynchronous-ios-return-value.patch
* zram-write-incompressible-pages-to-backing-device.patch
* zram-read-page-from-backing-device.patch
* zram-add-config-and-doc-file-for-writeback-feature.patch
* mm-page_alloc-rip-out-zonelist_order_zone.patch
* mm-page_alloc-remove-boot-pageset-initialization-from-memory-hotplug.patch
* mm-page_alloc-do-not-set_cpu_numa_mem-on-empty-nodes-initialization.patch
* mm-memory_hotplug-drop-zone-from-build_all_zonelists.patch
* mm-memory_hotplug-remove-explicit-build_all_zonelists-from-try_online_node.patch
* mm-page_alloc-simplify-zonelist-initialization.patch
* mm-page_alloc-remove-stop_machine-from-build_all_zonelists.patch
* mm-memory_hotplug-get-rid-of-zonelists_mutex.patch
* mm-sparse-page_ext-drop-ugly-n_high_memory-branches-for-allocations.patch
* mm-page_owner-make-init_pages_in_zone-faster.patch
* mm-page_ext-periodically-reschedule-during-page_ext_init.patch
* mm-page_owner-dont-grab-zone-lock-for-init_pages_in_zone.patch
* mm-page_ext-move-page_ext_init-after-page_alloc_init_late.patch
* mm-mremap-fail-map-duplication-attempts-for-private-mappings.patch
* mm-gup-make-__gup_device_-require-thp.patch
* mm-hugetlb-make-huge_pte_offset-consistent-and-document-behaviour.patch
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
* mm-thp-swap-make-reuse_swap_page-works-for-thp-swapped-out.patch
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
* btt-remove-btt_rw_page.patch
* pmem-remove-pmem_rw_page.patch
* brd-remove-brd_rw_page.patch
* treewide-remove-gfp_temporary-allocation-flag.patch
* treewide-remove-gfp_temporary-allocation-flag-checkpatch-fixes.patch
* mm-hugetlb-define-system-call-hugetlb-size-encodings-in-single-file.patch
* mm-arch-consolidate-mmap-hugetlb-size-encodings.patch
* mm-shm-use-new-hugetlb-size-encoding-definitions.patch
* mm-page_alloc-return-0-in-case-this-node-has-no-page-within-the-zone.patch
* mm-vmscan-do-not-pass-reclaimed-slab-to-vmpressure.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* mm-walk-the-zone-in-pageblock_nr_pages-steps.patch
* fs-proc-remove-priv-argument-from-is_stack.patch
* linux-kernelh-move-div_round_down_ull-macro.patch
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
* lib-interval-tree-correct-comment-wrt-generic-flavor.patch
* procfs-use-faster-rb_first_cached.patch
* fs-epoll-use-faster-rb_first_cached.patch
* mem-memcg-cache-rightmost-node.patch
* mem-memcg-cache-rightmost-node-fix.patch
* block-cfq-cache-rightmost-rb_node.patch
* block-cfq-cache-rightmost-rb_node-fix.patch
* lib-hexdump-return-einval-in-case-of-error-in-hex2bin.patch
* vfat-deduplicate-hex2bin.patch
* seq_file-delete-small-value-optimization.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* uapi-fix-linux-sysctlh-userspace-compilation-errors.patch
* m32r-defconfig-cleanup-from-old-kconfig-options.patch
* mn10300-defconfig-cleanup-from-old-kconfig-options.patch
* sh-defconfig-cleanup-from-old-kconfig-options.patch
* kernel-reboot-add-devm_register_reboot_notifier.patch
* kernel-reboot-add-devm_register_reboot_notifier-fix.patch
* ipc-convert-ipc_namespacecount-from-atomic_t-to-refcount_t.patch
* ipc-convert-sem_undo_listrefcnt-from-atomic_t-to-refcount_t.patch
* ipc-convert-kern_ipc_permrefcount-from-atomic_t-to-refcount_t.patch
  linux-next.patch
  linux-next-rejects.patch
* mm-remove-optimizations-based-on-i_size-in-mapping-writeback-waits.patch
* fscache-fix-fscache_objlist_show-format-processing.patch
* ib-mlx4-fix-sprintf-format-warning.patch
* iopoll-avoid-wint-in-bool-context-warning.patch
* kbuild-use-fshort-wchar-globally.patch
* sparc64-ng4-memset-32-bits-overflow.patch
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
