Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4CFFF6B0036
	for <linux-mm@kvack.org>; Wed, 21 May 2014 19:58:53 -0400 (EDT)
Received: by mail-ob0-f180.google.com with SMTP id va2so3003590obc.39
        for <linux-mm@kvack.org>; Wed, 21 May 2014 16:58:53 -0700 (PDT)
Received: from mail-ob0-f201.google.com (mail-ob0-f201.google.com [209.85.214.201])
        by mx.google.com with ESMTPS id gu3si36850613obc.18.2014.05.21.16.58.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 21 May 2014 16:58:52 -0700 (PDT)
Received: by mail-ob0-f201.google.com with SMTP id wn1so580364obc.0
        for <linux-mm@kvack.org>; Wed, 21 May 2014 16:58:52 -0700 (PDT)
Subject: mmotm 2014-05-21-16-57 uploaded
From: akpm@linux-foundation.org
Date: Wed, 21 May 2014 16:58:51 -0700
Message-Id: <20140521235851.5F9F05A4228@corp2gmr1-2.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

The mm-of-the-moment snapshot 2014-05-21-16-57 has been uploaded to

   http://www.ozlabs.org/~akpm/mmotm/

mmotm-readme.txt says

README for mm-of-the-moment:

http://www.ozlabs.org/~akpm/mmotm/

This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
more than once a week.

You will need quilt to apply these patches to the latest Linus release (3.x
or 3.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
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

http://git.cmpxchg.org/?p=linux-mmotm.git;a=summary

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

	http://git.cmpxchg.org/?p=linux-mmots.git;a=summary

and use of this tree is similar to
http://git.cmpxchg.org/?p=linux-mmotm.git, described above.


This mmotm tree contains the following patches against 3.15-rc5:
(patches marked "*" will be included in linux-next)

  origin.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  i-need-old-gcc.patch
  maintainers-akpm-maintenance.patch
* hwposion-hugetlb-lock_page-unlock_page-does-not-match-for-handling-a-free-hugepage.patch
* mm-filemapc-avoid-always-dirtying-mapping-flags-on-o_direct.patch
* mm-madvise-fix-madv_willneed-on-shmem-swapouts.patch
* memcg-fix-swapcache-charge-from-kernel-thread-context.patch
* mm-memory-failurec-fix-memory-leak-by-race-between-poison-and-unpoison.patch
* ocfs2-fix-double-kmem_cache_destroy-in-dlm_init.patch
* documentation-fix-docbooks=-building.patch
* maintainers-add-closing-angle-bracket-to-vince-bridgers-email-address.patch
* tools-vm-page-typesc-catch-sigbus-if-raced-with-truncate.patch
* x86-require-x86-64-for-automatic-numa-balancing.patch
* x86-define-_page_numa-by-reusing-software-bits-on-the-pmd-and-pte-levels.patch
* x86-define-_page_numa-by-reusing-software-bits-on-the-pmd-and-pte-levels-fix-2.patch
* x86-mm-probe-memory-block-size-for-generic-x86-64bit.patch
* fs-ceph-replace-pr_warning-by-pr_warn.patch
* fs-ceph-debugfsc-replace-seq_printf-by-seq_puts.patch
* fs-cifs-remove-obsolete-__constant.patch
* fs-jfs-jfs_logmgrc-remove-null-assignment-on-static.patch
* fs-jfs-superc-remove-0-assignement-to-static-code-clean-up.patch
* fs-fscache-convert-printk-to-pr_foo.patch
* fs-fscache-replace-seq_printf-by-seq_puts.patch
* fanotify-fan_mark_flush-avoid-having-to-provide-a-fake-invalid-fd-and-path.patch
* fanotify-create-fan_access-event-for-readdir.patch
* fs-notify-markc-trivial-cleanup.patch
* fs-notify-fanotify-fanotify_userc-fix-fan_mark_flush-flag-checking.patch
* fanotify-check-file-flags-passed-in-fanotify_init.patch
* kernel-posix-timersc-code-clean-up.patch
* kernel-posix-timersc-code-clean-up-checkpatch-fixes.patch
* kernel-time-ntpc-convert-simple_strtol-to-kstrtol.patch
* sched_clock-document-4mhz-vs-1mhz-decision.patch
* input-route-kbd-leds-through-the-generic-leds-layer.patch
* input-route-kbd-leds-through-the-generic-leds-layer-fix.patch
* ntfs-remove-null-value-assignments.patch
* sh-replace-__get_cpu_var-uses.patch
* fs-squashfs-squashfsh-replace-pr_warning-by-pr_warn.patch
* arch-unicore32-mm-ioremapc-convert-printk-warn_on-to-warn1.patch
* arch-unicore32-mm-ioremapc-convert-printk-warn_on-to-warn1-fix.patch
* arch-unicore32-mm-ioremapc-return-null-on-invalid-pfn.patch
* fs-configs-itemc-kernel-doc-fixes-clean-up.patch
* fs-configfs-convert-printk-to-pr_foo.patch
* fs-configfs-use-pr_fmt.patch
* drivers-net-irda-donauboe-convert-to-module_pci_driver.patch
* ocfs2-remove-null-assignments-on-static.patch
* fs-ocfs2-superc-use-ocfs2_max_vol_label_len-and-strlcpy.patch
* ocfs2-remove-some-redundant-casting.patch
* ocfs2-limit-printk-when-journal-is-aborted.patch
* ocfs2-limit-printk-when-journal-is-aborted-fix.patch
* ocfs2-should-add-inode-into-orphan-dir-after-updating-entry-in-ocfs2_rename.patch
* ocfs2-dlm-fix-possible-convertion-deadlock.patch
* ocfs2-fix-umount-hang-while-shutting-down-truncate-log.patch
* deadlock-when-two-nodes-are-converting-same-lock-from-pr-to-ex-and-idletimeout-closes-conn.patch
* ocfs2-o2net-incorrect-to-terminate-accepting-connections-loop-upon-rejecting-an-invalid-one.patch
* ocfs2-o2net-incorrect-to-terminate-accepting-connections-loop-upon-rejecting-an-ivalid-one-orabug-17489469.patch
* ocfs2-fix-a-tiny-race-when-running-dirop_fileop_racer.patch
* ocfs2-do-not-return-dlm_migrate_response_mastery_ref-to-avoid-endlessloop-during-umount.patch
* ocfs2-manually-do-the-iput-once-ocfs2_add_entry-failed-in-ocfs2_symlink-and-ocfs2_mknod.patch
* maintainers-update-ibm-serveraid-raid-info.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* fs-9p-v9fsc-add-__init-to-v9fs_sysfs_init.patch
* fs-9p-kerneldoc-fixes.patch
* fs-add-generic-data-flush-to-fsync.patch
* fs-add-generic-data-flush-to-fsync-fix.patch
* fs-add-generic-data-flush-to-fsync-fix-fix.patch
* fs-ext4-fsyncc-generic_file_fsync-call-based-on-barrier-flag.patch
* mm-slubc-convert-printk-to-pr_foo.patch
* mm-slubc-convert-vnsprintf-static-to-va_format.patch
* mm-slab-suppress-out-of-memory-warning-unless-debug-is-enabled.patch
* mm-slab-suppress-out-of-memory-warning-unless-debug-is-enabled-fix-2.patch
* mm-slub-fix-alloc_slowpath-stat.patch
* mm-fix-some-indenting-in-cmpxchg_double_slab.patch
  mm.patch
* slb-charge-slabs-to-kmemcg-explicitly.patch
* mm-get-rid-of-__gfp_kmemcg.patch
* mm-get-rid-of-__gfp_kmemcg-fix.patch
* mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff.patch
* mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff-v2.patch
* mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff-v3.patch
* mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff-v3-fix.patch
* pagewalk-update-page-table-walker-core.patch
* pagewalk-update-page-table-walker-core-fix-end-address-calculation-in-walk_page_range.patch
* pagewalk-update-page-table-walker-core-fix-end-address-calculation-in-walk_page_range-fix.patch
* pagewalk-add-walk_page_vma.patch
* smaps-redefine-callback-functions-for-page-table-walker.patch
* clear_refs-redefine-callback-functions-for-page-table-walker.patch
* pagemap-redefine-callback-functions-for-page-table-walker.patch
* pagemap-redefine-callback-functions-for-page-table-walker-fix.patch
* numa_maps-redefine-callback-functions-for-page-table-walker.patch
* memcg-redefine-callback-functions-for-page-table-walker.patch
* arch-powerpc-mm-subpage-protc-use-walk_page_vma-instead-of-walk_page_range.patch
* pagewalk-remove-argument-hmask-from-hugetlb_entry.patch
* pagewalk-remove-argument-hmask-from-hugetlb_entry-fix.patch
* pagewalk-remove-argument-hmask-from-hugetlb_entry-fix-fix.patch
* mempolicy-apply-page-table-walker-on-queue_pages_range.patch
* mm-add-pte_present-check-on-existing-hugetlb_entry-callbacks.patch
* mm-pagewalkc-move-pte-null-check.patch
* mm-softdirty-make-freshly-remapped-file-pages-being-softdirty-unconditionally.patch
* mm-softdirty-dont-forget-to-save-file-map-softdiry-bit-on-unmap.patch
* mm-softdirty-clear-vm_softdirty-flag-inside-clear_refs_write-instead-of-clear_soft_dirty.patch
* mm-introduce-do_shared_fault-and-drop-do_fault-fix-fix.patch
* mm-compactionc-isolate_freepages_block-small-tuneup.patch
* fs-mpagec-forgotten-write_sync-in-case-of-data-integrity-write.patch
* mm-only-force-scan-in-reclaim-when-none-of-the-lrus-are-big-enough.patch
* mmvmacache-add-debug-data.patch
* mmvmacache-optimize-overflow-system-wide-flushing.patch
* x86-make-dma_alloc_coherent-return-zeroed-memory-if-cma-is-enabled.patch
* x86-make-dma_alloc_coherent-return-zeroed-memory-if-cma-is-enabled-fix.patch
* x86-enable-dma-cma-with-swiotlb.patch
* intel-iommu-integrate-dma-cma.patch
* intel-iommu-integrate-dma-cma-fix.patch
* memblock-introduce-memblock_alloc_range.patch
* cma-add-placement-specifier-for-cma=-kernel-parameter.patch
* arch-x86-kernel-pci-dmac-fix-dma_generic_alloc_coherent-when-config_dma_cma-is-enabled.patch
* thp-consolidate-assert-checks-in-__split_huge_page.patch
* mm-huge_memoryc-complete-conversion-to-pr_foo.patch
* include-linux-mmdebugh-add-vm_warn_on-and-vm_warn_on_once.patch
* mm-mempool-warn-about-__gfp_zero-usage.patch
* mm-mempool-warn-about-__gfp_zero-usage-fix.patch
* mm-memcontrol-remove-hierarchy-restrictions-for-swappiness-and-oom_control.patch
* mm-memcontrol-remove-hierarchy-restrictions-for-swappiness-and-oom_control-fix.patch
* mm-pass-vm_bug_on-reason-to-dump_page.patch
* mm-pass-vm_bug_on-reason-to-dump_page-fix.patch
* memory-hotplug-update-documentation-to-hide-information-about-sections-and-remove-end_phys_index.patch
* slab-document-kmalloc_order.patch
* mm-mmapc-replace-is_err-and-ptr_err-with-ptr_err_or_zero.patch
* hugetlb-prep_compound_gigantic_page-drop-__init-marker.patch
* hugetlb-add-hstate_is_gigantic.patch
* hugetlb-update_and_free_page-dont-clear-pg_reserved-bit.patch
* hugetlb-move-helpers-up-in-the-file.patch
* hugetlb-add-support-for-gigantic-page-allocation-at-runtime.patch
* hugetlb-add-support-for-gigantic-page-allocation-at-runtime-checkpatch-fixes.patch
* mm-disable-zone_reclaim_mode-by-default.patch
* mm-page_alloc-do-not-cache-reclaim-distances.patch
* mm-page_alloc-do-not-cache-reclaim-distances-fix.patch
* memcg-un-export-__memcg_kmem_get_cache.patch
* mem-hotplug-implement-get-put_online_mems.patch
* slab-get_online_mems-for-kmem_cache_createdestroyshrink.patch
* fs-hugetlbfs-inodec-complete-conversion-to-pr_foo.patch
* mm-page_alloc-prevent-migrate_reserve-pages-from-being-misplaced.patch
* mm-compaction-clean-up-unused-code-lines.patch
* mm-compaction-cleanup-isolate_freepages.patch
* mm-compaction-cleanup-isolate_freepages-fix.patch
* mm-compaction-cleanup-isolate_freepages-fix-2.patch
* mm-compaction-cleanup-isolate_freepages-fix3.patch
* mm-debug-make-bad_range-output-more-usable-and-readable.patch
* documentation-memcg-warn-about-incomplete-kmemcg-state.patch
* m68k-call-find_vma-with-the-mmap_sem-held-in-sys_cacheflush.patch
* mips-call-find_vma-with-the-mmap_sem-held.patch
* arc-call-find_vma-with-the-mmap_sem-held.patch
* arc-call-find_vma-with-the-mmap_sem-held-fix.patch
* drm-exynos-call-find_vma-with-the-mmap_sem-held.patch
* mm-swapc-clean-up-lru_cache_add-functions.patch
* mm-mmap-remove-the-first-mapping-check.patch
* memcg-kill-config_mm_owner.patch
* mm-vmscan-do-not-throttle-based-on-pfmemalloc-reserves-if-node-has-no-zone_normal.patch
* mm-vmscan-do-not-throttle-based-on-pfmemalloc-reserves-if-node-has-no-zone_normal-checkpatch-fixes.patch
* mm-vmscan-do-not-throttle-based-on-pfmemalloc-reserves-if-node-has-no-zone_normal-fix.patch
* memcg-do-not-hang-on-oom-when-killed-by-userspace-oom-access-to-memory-reserves.patch
* memcg-slab-do-not-schedule-cache-destruction-when-last-page-goes-away.patch
* memcg-slab-merge-memcg_bindrelease_pages-to-memcg_uncharge_slab.patch
* memcg-slab-simplify-synchronization-scheme.patch
* mm-numa-add-migrated-transhuge-pages-to-lru-the-same-way-as-base-pages.patch
* mm-avoid-throttling-reclaim-for-loop-back-nfsd-threads.patch
* fs-bufferc-remove-block_write_full_page_endio.patch
* fs-mpagec-factor-clean_buffers-out-of-__mpage_writepage.patch
* fs-mpagec-factor-page_endio-out-of-mpage_end_io.patch
* fs-block_devc-add-bdev_read_page-and-bdev_write_page.patch
* swap-use-bdev_read_page-bdev_write_page.patch
* swap-use-bdev_read_page-bdev_write_page-fix.patch
* brd-add-support-for-rw_page.patch
* brd-return-enospc-rather-than-enomem-on-page-allocation-failure.patch
* mm-memory_hotplugc-use-pfn_down.patch
* mm-memblockc-use-pfn_down.patch
* memcg-mm_update_next_owner-should-skip-kthreads.patch
* memcg-optimize-the-search-everything-else-loop-in-mm_update_next_owner.patch
* memcg-kill-start_kernel-mm_init_ownerinit_mm.patch
* mm-replace-__get_cpu_var-uses-with-this_cpu_ptr.patch
* mm-constify-nmask-argument-to-mbind.patch
* mm-constify-nmask-argument-to-set_mempolicy.patch
* mm-swapc-introduce-put_refcounted_compound_page-helpers-for-spliting-put_compound_page.patch
* mm-swapc-split-put_compound_page-function.patch
* mm-introdule-compound_head_by_tail.patch
* include-linux-bootmemh-cleanup-the-comment-for-bootmem_-flags.patch
* mm-dmapoolc-remove-redundant-null-check-for-dev-in-dma_pool_create.patch
* mm-shrinker-trace-points-fix-negatives.patch
* mm-shrinker-add-nid-to-tracepoint-output.patch
* mm-memcontrolc-remove-null-assignment-on-static.patch
* mm-vmallocc-replace-seq_printf-by-seq_puts.patch
* mm-move-get_user_pages-related-code-to-separate-file.patch
* mm-extract-in_gate_area-case-from-__get_user_pages.patch
* mm-cleanup-follow_page_mask.patch
* mm-extract-code-to-fault-in-a-page-from-__get_user_pages.patch
* mm-cleanup-__get_user_pages.patch
* mm-x86-pgtable-drop-unneeded-preprocessor-ifdef.patch
* mm-x86-pgtable-require-x86_64-for-soft-dirty-tracker.patch
* mm-x86-pgtable-require-x86_64-for-soft-dirty-tracker-v2.patch
* mm-rmapc-make-page_referenced_one-and-try_to_unmap_one-static.patch
* mm-mempolicyc-parameter-doc-uniformization.patch
* arch-x86-mm-numac-use-for_each_memblock.patch
* mm-update-comment-for-default_max_map_count.patch
* mm-update-comment-for-default_max_map_count-fix.patch
* memcg-fold-mem_cgroup_stolen.patch
* memcg-fold-mem_cgroup_stolen-fix.patch
* memcg-correct-comments-for-__mem_cgroup_begin_update_page_stat.patch
* memcg-get-rid-of-memcg_create_cache_name.patch
* memcg-memcg_kmem_create_cache-make-memcg_name_buf.patch
* mm-migration-add-destination-page-freeing-callback.patch
* mm-compaction-return-failed-migration-target-pages-back-to-freelist.patch
* mm-compaction-add-per-zone-migration-pfn-cache-for-async-compaction.patch
* mm-compaction-embed-migration-mode-in-compact_control.patch
* mm-compaction-embed-migration-mode-in-compact_control-fix.patch
* mm-thp-avoid-excessive-compaction-latency-during-fault.patch
* mm-thp-avoid-excessive-compaction-latency-during-fault-fix.patch
* mm-compaction-terminate-async-compaction-when-rescheduling.patch
* mm-compaction-do-not-count-migratepages-when-unnecessary.patch
* mm-compaction-do-not-count-migratepages-when-unnecessary-fix.patch
* mm-compaction-avoid-rescanning-pageblocks-in-isolate_freepages.patch
* mm-compaction-avoid-rescanning-pageblocks-in-isolate_freepages-fix.patch
* mm-add-comment-for-__mod_zone_page_stat.patch
* mm-add-comment-for-__mod_zone_page_stat-checkpatch-fixes.patch
* mm-fold-mlocked_vma_newpage-into-its-only-call-site.patch
* mm-fold-mlocked_vma_newpage-into-its-only-call-site-checkpatch-fixes.patch
* swap-change-swap_info-singly-linked-list-to-list_head.patch
* plist-add-helper-functions.patch
* plist-add-plist_requeue.patch
* swap-change-swap_list_head-to-plist-add-swap_avail_head.patch
* cma-increase-cma_alignment-upper-limit-to-12.patch
* mm-dmapoolc-reuse-devres_release-to-free-resources.patch
* memcg-cleanup-kmem-cache-creation-destruction-functions-naming.patch
* slab-delete-cache-from-list-after-__kmem_cache_shutdown-succeeds.patch
* mm-page_alloc-do-not-update-zlc-unless-the-zlc-is-active.patch
* mm-page_alloc-do-not-treat-a-zone-that-cannot-be-used-for-dirty-pages-as-full.patch
* jump_label-expose-the-reference-count.patch
* mm-page_alloc-use-jump-labels-to-avoid-checking-number_of_cpusets.patch
* mm-page_alloc-use-jump-labels-to-avoid-checking-number_of_cpusets-fix.patch
* mm-page_alloc-only-check-the-zone-id-check-if-pages-are-buddies.patch
* mm-page_alloc-only-check-the-alloc-flags-and-gfp_mask-for-dirty-once.patch
* mm-page_alloc-take-the-alloc_no_watermark-check-out-of-the-fast-path.patch
* mm-page_alloc-use-word-based-accesses-for-get-set-pageblock-bitmaps.patch
* mm-page_alloc-reduce-number-of-times-page_to_pfn-is-called.patch
* mm-page_alloc-lookup-pageblock-migratetype-with-irqs-enabled-during-free.patch
* mm-page_alloc-use-unsigned-int-for-order-in-more-places.patch
* mm-page_alloc-convert-hot-cold-parameter-and-immediate-callers-to-bool.patch
* mm-shmem-avoid-atomic-operation-during-shmem_getpage_gfp.patch
* mm-do-not-use-atomic-operations-when-releasing-pages.patch
* mm-do-not-use-unnecessary-atomic-operations-when-adding-pages-to-the-lru.patch
* fs-buffer-do-not-use-unnecessary-atomic-operations-when-discarding-buffers.patch
* fs-buffer-do-not-use-unnecessary-atomic-operations-when-discarding-buffers-fix.patch
* mm-non-atomically-mark-page-accessed-during-page-cache-allocation-where-possible.patch
* mm-non-atomically-mark-page-accessed-during-page-cache-allocation-where-possiblefix-2.patch
* mm-non-atomically-mark-page-accessed-during-page-cache-allocation-where-possible-fix.patch
* mm-page_alloc-calculate-classzone_idx-once-from-the-zonelist-ref.patch
* mm-page_alloc-calculate-classzone_idx-once-from-the-zonelist-ref-fix.patch
* mm-avoid-unnecessary-atomic-operations-during-end_page_writeback.patch
* mm-memory-failurec-move-comment.patch
* mm-hugetlb-move-the-error-handle-logic-out-of-normal-code-path.patch
* mm-exclude-duplicate-header.patch
* mm-vmscanc-use-div_round_up-for-calculation-of-zones-balance_gap-and-correct-comments.patch
* fs-hugetlbfs-inodec-add-static-to-hugetlbfs_i_mmap_mutex_key.patch
* fs-hugetlbfs-inodec-use-static-const-for-dentry_operations.patch
* fs-hugetlbfs-inodec-remove-null-test-before-kfree.patch
* mm-compaction-properly-signal-and-act-upon-lock-and-need_sched-contention.patch
* mm-compaction-properly-signal-and-act-upon-lock-and-need_sched-contention-fix.patch
* hwpoison-remove-unused-global-variable-in-do_machine_check.patch
* sync-only-the-requested-range-in-msync.patch
* mm-fix-typo-in-comment-in-do_fault_around.patch
* zram-correct-offset-usage-in-zram_bio_discard.patch
* mm-zbudc-make-size-unsigned-like-unique-callsite.patch
* zsmalloc-fixup-trivial-zs-size-classes-value-in-comments.patch
* mm-export-unmap_kernel_range.patch
* zsmalloc-make-zsmalloc-module-buildable.patch
* do_shared_fault-check-that-mmap_sem-is-held.patch
* sys_sgetmask-sys_ssetmask-add-config_sgetmask_syscall.patch
* fs-efivarfs-superc-use-static-const-for-dentry_operations.patch
* fs-exportfs-expfsc-kernel-doc-warning-fixes.patch
* compilerh-avoid-sparse-errors-in-__compiletime_error_fallback.patch
* kernel-cpuc-convert-printk-to-pr_foo.patch
* kernel-backtracetestc-replace-no-level-printk-by-pr_info.patch
* kernel-capabilityc-code-clean-up.patch
* kernel-exec_domainc-code-clean-up.patch
* kernel-latencytopc-convert-seq_printf-to-seq_puts.patch
* kernel-stop_machinec-kernel-doc-warning-fix.patch
* kernel-tracepointc-kernel-doc-fixes.patch
* kernel-res_counterc-replace-simple_strtoull-by-kstrtoull.patch
* kernel-res_counterc-replace-simple_strtoull-by-kstrtoull-fix.patch
* kernel-rebootc-convert-simple_strtoul-to-kstrtoint.patch
* kernel-utsname_sysctlc-replace-obsolete-__initcall-by-device_initcall.patch
* kernel-hung_taskc-convert-simple_strtoul-to-kstrtouint.patch
* kernel-userc-drop-unused-field-files-from-user_struct.patch
* drivers-misc-ti-st-st_corec-fix-null-dereference-on-protocol-type-check.patch
* printk-split-code-for-making-free-space-in-the-log-buffer.patch
* printk-ignore-too-long-messages.patch
* printk-split-message-size-computation.patch
* printk-shrink-too-long-messages.patch
* printk-return-really-stored-message-length.patch
* printk-remove-outdated-comment.patch
* printk-release-lockbuf_lock-before-calling-console_trylock_for_printk.patch
* printk-release-lockbuf_lock-before-calling-console_trylock_for_printk-fix.patch
* printk-fix-lockdep-instrumentation-of-console_sem.patch
* printk-enable-interrupts-before-calling-console_trylock_for_printk.patch
* printk-remove-separate-printk_sched-buffers-and-use-printk-buf-instead.patch
* printk-disable-preemption-for-printk_sched.patch
* printk-rename-printk_sched-to-printk_deferred.patch
* printk-add-printk_deferred_once.patch
* timekeeping-use-printk_deferred-when-holding-timekeeping-seqlock.patch
* documentation-expand-clarify-debug-documentation.patch
* printk-report-dropping-of-messages-from-logbuf.patch
* printk-use-symbolic-defines-for-console-loglevels.patch
* lib-vsprintf-add-%pt-format-specifier.patch
* drivers-video-backlight-backlightc-remove-backlight-sysfs-uevent.patch
* lib-stringc-use-the-name-c-string-in-comments.patch
* lib-xz-add-comments-for-the-intentionally-missing-break-statements.patch
* lib-plistc-replace-pr_debug-with-printk-in-plist_test.patch
* lib-xz-enable-all-filters-by-default-in-kconfig.patch
* lib-libcrc32cc-use-ptr_err_or_zero.patch
* lib-vsprintfc-fix-comparison-to-bool.patch
* lib-btreec-fix-leak-of-whole-btree-nodes.patch
* lib-btreec-fix-leak-of-whole-btree-nodes-fix.patch
* lib-plistc-make-config_debug_pi_list-selectable.patch
* lib-radix-treec-kernel-doc-warning-fix.patch
* lib-crc32c-remove-unnecessary-__constant.patch
* mm-utilc-add-kstrimdup.patch
* lib-add-crc64-ecma-module.patch
* kernel-compatc-use-sizeof-instead-of-sizeof.patch
* checkpatch-fix-wildcard-dt-compatible-string-checking.patch
* checkpatch-always-warn-on-missing-blank-line-after-variable-declaration-block.patch
* checkpatch-improve-missing-blank-line-after-declarations-test.patch
* checkpatch-make-strict-a-default-for-files-in-drivers-net-and-net.patch
* checkpatch-warn-on-defines-ending-in-semicolon.patch
* checkpatch-add-warning-for-kmalloc-kzalloc-with-multiply.patch
* fs-efs-convert-printk-to-pr_foo.patch
* fs-efs-add-pr_fmt-use-__func__.patch
* fs-efs-convert-printkkern_debug-to-pr_debug.patch
* fs-binfmt_elfc-fix-bool-assignements.patch
* fs-binfmt_flatc-make-old_reloc-static.patch
* binfmt_elfc-use-get_random_int-to-fix-entropy-depleting.patch
* init-mainc-dont-use-pr_debug.patch
* init-mainc-add-initcall_blacklist-kernel-parameter.patch
* init-mainc-add-initcall_blacklist-kernel-parameter-fix.patch
* kthreads-kill-clone_kernel-change-kernel_threadkernel_init-to-avoid-clone_sighand.patch
* init-mainc-remove-an-ifdef.patch
* fs-autofs4-dev-ioctlc-add-__init-to-autofs_dev_ioctl_init.patch
* drivers-rtc-interfacec-fix-infinite-loop-in-initializing-the-alarm.patch
* drivers-rtc-interfacec-fix-infinite-loop-in-initializing-the-alarm-fix.patch
* documentation-devicetree-bindings-add-documentation-for-the-apm-x-gene-soc-rtc-dts-binding.patch
* drivers-rtc-add-apm-x-gene-soc-rtc-driver.patch
* arm64-add-apm-x-gene-soc-rtc-dts-entry.patch
* rtc-m41t80-remove-drv_version-macro.patch
* rtc-m41t80-clean-up-error-paths.patch
* rtc-m41t80-propagate-error-value-from-smbus-functions.patch
* rtc-m41t80-add-support-for-microcrystal-rv4162.patch
* drivers-rtc-rtc-efic-avoid-subtracting-day-twice-when-computing-year-days.patch
* rtc-rtc-cmos-drivers-char-rtcc-features-for-decstation-support.patch
* rtc-rtc-cmos-drivers-char-rtcc-features-for-decstation-support-fix.patch
* dec-switch-decstation-systems-to-rtc-cmos.patch
* drivers-rtc-rtc-88pm860xc-use-of_get_child_by_name.patch
* drivers-rtc-rtc-88pm860xc-add-missing-of_node_put.patch
* drivers-rtc-rtc-da9052c-alarm-causes-interrupt-storm.patch
* rtc-rtc-ds1742-make-of_device_id-array-const.patch
* rtc-rtc-hym8563-make-of_device_id-array-const.patch
* rtc-isl12057-make-of_device_id-array-const.patch
* rtc-rtc-mv-make-of_device_id-array-const.patch
* rtc-rtc-palmas-make-of_device_id-array-const.patch
* drivers-rtc-add-support-for-maxim-dallas-rtc-ds1343-and-ds1344.patch
* rtc-fix-potential-race-condition-and-remove-build-errors.patch
* drivers-rtc-rtc-ds1343c-fix-potential-race-condition.patch
* drivers-rtc-add-support-for-microchip-mcp795.patch
* rtc-da9063-rtc-driver.patch
* rtc-da9063-rtc-driver-fix.patch
* drivers-rtc-rtc-omapc-remove-multiple-device-id-checks.patch
* drivers-rtc-rtc-omapc-use-bit-macro.patch
* drivers-rtc-rtc-omapc-add-support-for-enabling-32khz-clock.patch
* drivers-rtc-rtc-bfinc-do-not-abort-when-requesting-irq-fails.patch
* rtc-hym8563-add-optional-clock-output-names-property.patch
* rtc-rtc-at91rm9200-fix-infinite-wait-for-ackupd-irq.patch
* fs-befs-linuxvfsc-replace-strncpy-by-strlcpy.patch
* fs-befs-btreec-replace-strncpy-by-strlcpy-coding-style-fixing.patch
* fs-befs-linuxvfsc-remove-positive-test-on-sector_t.patch
* fs-befs-kernel-doc-fixes.patch
* fs-isofs-logging-clean-up.patch
* fs-coda-replace-printk-by-pr_foo.patch
* fs-coda-logging-prefix-uniformization.patch
* fs-coda-use-__func__.patch
* hfsplus-fixes-worst-case-unicode-to-char-conversion-of-file-names-and-attributes.patch
* hfsplus-fixes-worst-case-unicode-to-char-conversion-of-file-names-and-attributes-fix.patch
* hfsplus-correct-usage-of-hfsplus_attr_max_strlen-for-non-english-attributes.patch
* hfsplus-correct-usage-of-hfsplus_attr_max_strlen-for-non-english-attributes-fix.patch
* hfsplus-correct-usage-of-hfsplus_attr_max_strlen-for-non-english-attributes-fix-2.patch
* hfsplus-remove-unused-routine-hfsplus_attr_build_key_uni.patch
* hfsplus-emit-proper-file-type-from-readdir.patch
* fs-hfsplus-bnodec-replace-min-casting-by-min_t.patch
* fs-hfsplus-optionsc-replace-seq_printf-by-seq_puts.patch
* fs-hfsplus-wrapperc-replace-min-casting-by-min_t.patch
* hfsplus-fix-unused-node-is-not-erased-error.patch
* fs-hfsplus-wrapperc-replace-shift-loop-by-ilog2.patch
* hfsplus-fix-longname-handling.patch
* fs-ufs-ballocc-remove-err-parameter-in-ufs_add_fragments.patch
* fs-hpfs-convert-printk-to-pr_foo.patch
* fs-hpfs-use-pr_fmt-for-logging.patch
* fs-hpfs-use-__func__-for-logging.patch
* fs-fat-add-support-for-dos-1x-formatted-volumes.patch
* fs-fat-cleanup-string-initializations-char-instead-of-char.patch
* documentation-submittingpatches-describe-the-fixes-tag.patch
* ptrace-fix-fork-event-messages-across-pid-namespaces.patch
* ptrace-task_clear_jobctl_trapping-wake_up_bit-needs-mb.patch
* signals-kill-sigfindinword.patch
* signals-s-siginitset-sigemptyset-in-do_sigtimedwait.patch
* signals-kill-rm_from_queue-change-prepare_signal-to-use-for_each_thread.patch
* signals-rename-rm_from_queue_full-to-flush_sigqueue_mask.patch
* signals-cleanup-the-usage-of-t-current-in-do_sigaction.patch
* signals-mv-disallow_signal-from-schedh-exitc-to-signal.patch
* signals-jffs2-fix-the-wrong-usage-of-disallow_signal.patch
* signals-kill-the-obsolete-sigdelset-and-recalc_sigpending-in-allow_signal.patch
* signals-disallow_signal-should-flush-the-potentially-pending-signal.patch
* signals-introduce-kernel_sigaction.patch
* signals-change-wait_for_helper-to-use-kernel_sigaction.patch
* smp-print-more-useful-debug-info-upon-receiving-ipi-on-an-offline-cpu.patch
* smp-print-more-useful-debug-info-upon-receiving-ipi-on-an-offline-cpu-fix.patch
* smp-print-more-useful-debug-info-upon-receiving-ipi-on-an-offline-cpu-v5.patch
* cpu-hotplug-stop-machine-plug-race-window-that-leads-to-ipi-to-offline-cpu.patch
* cpu-hotplug-stop-machine-plug-race-window-that-leads-to-ipi-to-offline-cpu-v3.patch
* cpu-hotplug-stop-machine-plug-race-window-that-leads-to-ipi-to-offline-cpu-v5.patch
* cpu-hotplug-smp-flush-any-pending-ipi-callbacks-before-cpu-offline-v5.patch
* cpu-hotplug-smp-flush-any-pending-ipi-callbacks-before-cpu-offline-v5-checkpatch-fixes.patch
* kernel-panicc-add-crash_kexec_post_notifiers-option-for-kdump-after-panic_notifers.patch
* kernel-kexecc-convert-printk-to-pr_foo.patch
* kexec-save-pg_head_mask-in-vmcoreinfo.patch
* idr-fix-overflow-bug-during-maximum-id-calculation-at-maximum-height.patch
* idr-fix-unexpected-id-removal-when-idr_removeunallocated_id.patch
* idr-fix-null-pointer-dereference-when-ida_removeunallocated_id.patch
* idr-fix-idr_replaces-returned-error-code.patch
* idr-dont-need-to-shink-the-free-list-when-idr_remove.patch
* idr-reduce-the-unneeded-check-in-free_layer.patch
* idr-reorder-the-fields.patch
* rapidio-tsi721-use-pci_enable_msix_exact-instead-of-pci_enable_msix.patch
* sysctl-clean-up-char-buffer-arguments.patch
* sysctl-refactor-sysctl-string-writing-logic.patch
* sysctl-allow-for-strict-write-position-handling.patch
* sysctl-allow-for-strict-write-position-handling-fix-2.patch
* sysctl-allow-for-strict-write-position-handling-fix.patch
* sysctl-allow-for-strict-write-position-handling-fix-3.patch
* tools-testing-selftests-sysctl-validate-sysctl_writes_strict.patch
* kernel-user_namespacec-kernel-doc-checkpatch-fixes.patch
* fix-_ioc_typecheck-sparse-error.patch
* gcov-add-support-for-gcc-49.patch
* fs-affs-filec-remove-unnecessary-function-parameters.patch
* fs-affs-convert-printk-to-pr_foo.patch
* fs-affs-pr_debug-cleanup.patch
* kernel-profilec-convert-printk-to-pr_foo.patch
* kernel-profilec-use-static-const-char-instead-of-static-char.patch
* fs-pstore-logging-clean-up.patch
* fs-pstore-logging-clean-up-fix.patch
* fs-cachefiles-convert-printk-to-pr_foo.patch
* fs-cachefiles-replace-kerror-by-pr_err.patch
* fs-devpts-inodec-convert-printk-to-pr_foo.patch
* fs-devpts-inodec-convert-printk-to-pr_foo-fix.patch
* initramfs-remove-compression-mode-choice.patch
* ipc-constify-ipc_ops.patch
* ipc-kernel-use-linux-headers.patch
* ipc-kernel-clear-whitespace.patch
* ipc-shmc-check-for-ulong-overflows-in-shmat.patch
* ipc-shmc-check-for-overflows-of-shm_tot.patch
* ipc-shmc-check-for-integer-overflow-during-shmget.patch
* ipc-shmc-increase-the-defaults-for-shmall-shmmax.patch
* ipcshm-document-new-limits-in-the-uapi-header.patch
* ipcshm-document-new-limits-in-the-uapi-header-v2.patch
* ipcshm-document-new-limits-in-the-uapi-header-v3.patch
* ipcmsg-use-current-state-helpers.patch
* ipcmsg-move-some-msgq-ns-code-around.patch
* ipcmsg-document-volatile-r_msg.patch
* ipc-semc-bugfix-for-semctlgetzcnt.patch
* ipc-semc-remove-code-duplication.patch
* ipc-semc-change-perform_atomic_semop-parameters.patch
* ipc-semc-store-which-operation-blocks-in-perform_atomic_semop.patch
* ipc-semc-make-semctlgetncntgetzcnt-standard-compliant.patch
* lib-scatterlist-make-arch_has_sg_chain-an-actual-kconfig.patch
* lib-scatterlist-make-arch_has_sg_chain-an-actual-kconfig-fix.patch
* lib-scatterlist-make-arch_has_sg_chain-an-actual-kconfig-fix-2.patch
* lib-scatterlist-make-arch_has_sg_chain-an-actual-kconfig-fix-3.patch
* lib-scatterlist-clean-up-useless-architecture-versions-of-scatterlisth.patch
* kernel-seccompc-kernel-doc-warning-fix.patch
  linux-next.patch
  linux-next-rejects.patch
  linux-next-git-rejects.patch
* drivers-gpio-gpio-zevioc-fix-build.patch
* mm-page_ioc-work-around-gcc-bug.patch
* lib-test_bpfc-dont-use-gcc-union-shortcut.patch
* arm-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* ia64-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* tile-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* cdrom-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* random-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* parport-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* scsi-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* coda-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* fscache-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* lockd-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* nfs-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* inotify-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* ntfs-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* fs-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* key-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* ipc-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* sysctl-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* mm-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* mfd-rtc-sec-s5m-rename-sec-symbols-to-s5m.patch
* rtc-s5m-remove-undocumented-time-init-on-first-boot.patch
* rtc-s5m-use-shorter-time-of-register-update.patch
* rtc-s5m-support-different-register-layout.patch
* rtc-s5m-add-support-for-s2mps14-rtc.patch
* rtc-s5m-consolidate-two-device-type-switch-statements.patch
* blackfin-ptrace-call-find_vma-with-the-mmap_sem-held.patch
* kernel-watchdogc-print-traces-for-all-cpus-on-lockup-detection.patch
* kernel-watchdogc-print-traces-for-all-cpus-on-lockup-detection-fix.patch
* kernel-watchdogc-print-traces-for-all-cpus-on-lockup-detection-fix-2.patch
* kernel-watchdogc-convert-printk-pr_warning-to-pr_foo.patch
* init-mainc-code-clean-up.patch
* fs-reiserfs-bitmapc-coding-style-fixes.patch
* fs-reiserfs-streec-remove-obsolete-__constant.patch
* rwsem-support-optimistic-spinning.patch
* rwsem-support-optimistic-spinning-checkpatch-fixes.patch
* rwsem-support-optimistic-spinning-fix.patch
* x86vdso-fix-an-oops-accessing-the-hpet-mapping-w-o-an-hpet.patch
* kernel-kprobesc-convert-printk-to-pr_foo.patch
* sysrq-rcu-ify-__handle_sysrq.patch
* sysrqrcu-suppress-rcu-stall-warnings-while-sysrq-runs.patch
* memcg-mm-introduce-lowlimit-reclaim.patch
* memcg-mm-introduce-lowlimit-reclaim-fix.patch
* memcg-allow-setting-low_limit.patch
* memcg-doc-clarify-global-vs-limit-reclaims.patch
* memcg-doc-clarify-global-vs-limit-reclaims-fix.patch
* memcg-document-memorylow_limit_in_bytes.patch
* vmscan-memcg-check-whether-the-low-limit-should-be-ignored.patch
* vmscan-memcg-always-use-swappiness-of-the-reclaimed-memcg-swappiness-and-oom_control.patch
* mm-kmemleakc-use-%u-to-print-checksum.patch
* mm-introduce-kmemleak_update_trace.patch
* lib-update-the-kmemleak-stack-trace-for-radix-tree-allocations.patch
* mm-update-the-kmemleak-stack-trace-for-mempool-allocations.patch
* mm-call-kmemleak-directly-from-memblock_allocfree.patch
* mm-memcontrol-clean-up-memcg-zoneinfo-lookup.patch
* mm-memcontrol-remove-unnecessary-memcg-argument-from-soft-limit-functions.patch
* mm-mark-remap_file_pages-syscall-as-deprecated.patch
* mm-mark-remap_file_pages-syscall-as-deprecated-fix.patch
* mm-replace-remap_file_pages-syscall-with-emulation.patch
* mm-replace-remap_file_pages-syscall-with-emulation-fix.patch
* mm-replace-remap_file_pages-syscall-with-emulation-fix-2.patch
* mm-replace-remap_file_pages-syscall-with-emulation-fix-3.patch
* memcg-deprecate-memoryforce_empty-knob.patch
* memcg-deprecate-memoryforce_empty-knob-fix.patch
* fat-add-i_disksize-to-represent-uninitialized-size-v4.patch
* fat-add-fat_fallocate-operation-v4.patch
* fat-zero-out-seek-range-on-_fat_get_block-v4.patch
* fat-fallback-to-buffered-write-in-case-of-fallocated-region-on-direct-io-v4.patch
* fat-permit-to-return-phy-block-number-by-fibmap-in-fallocated-region-v4.patch
* documentation-filesystems-vfattxt-update-the-limitation-for-fat-fallocate-v4.patch
* nmi-provide-the-option-to-issue-an-nmi-back-trace-to-every-cpu-but-current.patch
* nmi-provide-the-option-to-issue-an-nmi-back-trace-to-every-cpu-but-current-fix.patch
* fs-dlm-configc-convert-simple_str-to-kstr.patch
* fs-dlm-lockspacec-convert-simple_str-to-kstr.patch
* fs-dlm-debug_fsc-replace-seq_printf-by-seq_puts.patch
* mm-kmemleak-testc-use-pr_fmt-for-logging.patch
* bio-modify-__bio_add_page-to-accept-pages-that-dont-start-a-new-segment.patch
* bio-modify-__bio_add_page-to-accept-pages-that-dont-start-a-new-segment-v3.patch
* maintainers-add-linux-api-for-review-of-api-abi-changes.patch
* maintainers-adi-buildroot-devel-is-moderated.patch
* mm-convert-some-level-less-printks-to-pr_.patch
* w1-call-put_device-if-device_register-fails.patch
* ufs-sb-mutex-merge-mutex_destroy.patch
* mm-add-strictlimit-knob-v2.patch
  debugging-keep-track-of-page-owners.patch
  page-owners-correct-page-order-when-to-free-page.patch
  make-sure-nobodys-leaking-resources.patch
  journal_add_journal_head-debug.patch
  journal_add_journal_head-debug-fix.patch
  releasing-resources-with-children.patch
  make-frame_pointer-default=y.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  mutex-subsystem-synchro-test-module.patch
  slab-leaks3-default-y.patch
  put_bh-debug.patch
  add-debugging-aid-for-memory-initialisation-problems.patch
  workaround-for-a-pci-restoring-bug.patch
  single_open-seq_release-leak-diagnostics.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
