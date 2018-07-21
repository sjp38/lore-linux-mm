Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 037F76B0003
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 20:50:10 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id g5-v6so6969800pgq.5
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 17:50:09 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y23-v6si3164794pfb.284.2018.07.20.17.50.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 17:50:07 -0700 (PDT)
Date: Fri, 20 Jul 2018 17:50:06 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2018-07-20-17-49 uploaded
Message-ID: <20180721005006.nIFCx%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org

The mm-of-the-moment snapshot 2018-07-20-17-49 has been uploaded to

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


This mmotm tree contains the following patches against 4.18-rc5:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
* mm-memblock-add-missing-include-linux-bootmemh.patch
* mm-fix-vma_is_anonymous-false-positives.patch
* mm-fix-vma_is_anonymous-false-positives-fix.patch
* mm-fix-vma_is_anonymous-false-positives-v2.patch
* mm-fix-vma_is_anonymous-false-positives-v2-fix.patch
* maintainers-update-e-mail-address.patch
* fat-fix-memory-allocation-failure-handling-of-match_strdup.patch
* thp-fix-data-loss-when-splitting-a-file-pmd.patch
* mm-memcg-fix-use-after-free-in-mem_cgroup_iter.patch
* kvm-mm-account-shadow-page-tables-to-kmemcg.patch
* memcg-remove-memcg_cgroup-id-from-idr-on-mem_cgroup_css_alloc-failure.patch
* slub-track-number-of-slabs-irrespective-of-config_slub_debug.patch
* kasan-only-select-slub_debug-with-sysfs=y.patch
* mm-disallow-mapping-that-conflict-for-devm_memremap_pages.patch
* ipc-sem-prevent-queuestatus-tearing-in-semop.patch
* mm-fix-exports-that-inadvertently-make-put_page-export_symbol_gpl.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* dax-remove-vm_mixedmap-for-fsdax-and-device-dax.patch
* prctl-add-pr_et_pdeathsig_proc.patch
* firewire-use-64-bit-time_t-based-interfaces.patch
* ufs-use-ktime_get_real_seconds-for-sb-and-cg-timestamps.patch
* ntfs-use-timespec64-directly-for-timestamp-conversion.patch
* hpfs-extend-gmt_to_local-conversion-to-64-bit-times.patch
* spdxcheck-work-with-current-head-licenses-directory.patch
* scripts-add-python-3-compatibility-to-spdxcheckpy.patch
* ntfs-dont-disable-interrupts-during-kmap_atomic.patch
* ntfs-aops-remove-vla-usage.patch
* ntfs-decompress-remove-vla-usage.patch
* ntfs-mft-remove-vla-usage.patch
* sh-make-use-of-for_each_node_by_type.patch
* h8300-correct-signature-of-test_bit.patch
* ocfs2-return-erofs-when-filesystem-becomes-read-only.patch
* ocfs2-return-erofs-when-filesystem-becomes-read-only-checkpatch-fixes.patch
* ocfs2-clean-up-some-unnecessary-code.patch
* ocfs2-make-several-functions-and-variables-static-and-some-const.patch
* ocfs2-get-rid-of-ocfs2_is_o2cb_active-function.patch
* ocfs2-without-quota-support-try-to-avoid-calling-quota-recovery.patch
* ocfs2-dont-use-iocb-when-eiocbqueued-returns.patch
* ocfs2-fix-a-misuse-a-of-brelse-after-failing-ocfs2_check_dir_entry.patch
* ocfs2-dont-put-and-assigning-null-to-bh-allocated-outside.patch
* ocfs2-dlmglue-clean-up-timestamp-handling.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* dentry-fix-kmemcheck-splat-at-take_dentry_name_snapshot.patch
* namei-allow-restricted-o_creat-of-fifos-and-regular-files.patch
* vfs-discard-attr_attr_flag.patch
* vfs-simplify-seq_file-iteration-code-and-interface.patch
* vfs-simplify-seq_file-iteration-code-and-interface-fix.patch
  mm.patch
* mm-convert-return-type-of-handle_mm_fault-caller-to-vm_fault_t.patch
* mm-skip-invalid-pages-block-at-a-time-in-zero_resv_unresv.patch
* thp-use-mm_file_counter-to-determine-update-which-rss-counter.patch
* tools-modifying-page-types-to-include-shared-map-counts.patch
* tools-modifying-page-types-to-include-shared-map-counts-checkpatch-fixes.patch
* tools-modifying-page-types-to-include-shared-map-counts-fix.patch
* tools-modifying-page-types-to-include-shared-map-counts-fix-checkpatch-fixes.patch
* tools-adding-support-for-idle-page-tracking-to-tool.patch
* tools-adding-support-for-idle-page-tracking-to-tool-fix.patch
* tools-adding-support-for-idle-page-tracking-to-tool-fix-2.patch
* mm-page_alloc-actually-ignore-mempolicies-for-high-priority-allocations.patch
* shmem-use-monotonic-time-for-i_generation.patch
* mm-page_ext-drop-definition-of-unused-page_ext_debug_poison.patch
* mm-page_ext-constify-lookup_page_ext-argument.patch
* mm-condense-scan_control.patch
* mm-mempool-remove-unused-argument-in-kasan_unpoison_element-and-remove_element.patch
* mm-thp-register-mm-for-khugepaged-when-merging-vma-for-shmem-v3.patch
* mm-thp-inc-counter-for-collapsed-shmem-thp.patch
* mpage-add-argument-structure-for-do_mpage_readpage.patch
* mpage-mpage_readpages-should-submit-io-as-read-ahead.patch
* btrfs-readpages-should-submit-io-as-read-ahead.patch
* ext4-readpages-should-submit-io-as-read-ahead.patch
* mm-clear_huge_page-move-order-algorithm-into-a-separate-function.patch
* mm-huge-page-copy-target-sub-page-last-when-copy-huge-page.patch
* mm-hugetlbfs-rename-address-to-haddr-in-hugetlb_cow.patch
* mm-hugetlbfs-pass-fault-address-to-cow-handler.patch
* mm-drop-vm_bug_on-from-__get_free_pages.patch
* mm-drop-vm_bug_on-from-__get_free_pages-fix.patch
* mm-workingset-remove-local_irq_disable-from-count_shadow_nodes.patch
* mm-workingset-make-shadow_lru_isolate-use-locking-suffix.patch
* mm-list_lruc-fold-__list_lru_count_one-into-its-caller.patch
* mm-memory_hotplug-make-add_memory_resource-use-__try_online_node.patch
* mm-memory_hotplug-call-register_mem_sect_under_node.patch
* mm-memory_hotplug-make-register_mem_sect_under_node-a-cb-of-walk_memory_range.patch
* mm-memory_hotplug-drop-unnecessary-checks-from-register_mem_sect_under_node.patch
* mm-provide-a-fallback-for-page_kernel_ro-for-architectures.patch
* mm-provide-a-fallback-for-page_kernel_exec-for-architectures.patch
* mm-introduce-mem_cgroup_put-helper.patch
* fs-fsnotify-account-fsnotify-metadata-to-kmemcg.patch
* fs-fsnotify-account-fsnotify-metadata-to-kmemcg-fix.patch
* fs-mm-account-buffer_head-to-kmemcg.patch
* fs-mm-account-buffer_head-to-kmemcgpatchfix.patch
* writeback-update-stale-account_page_redirty-comment.patch
* mm-zsmalloc-make-several-functions-and-a-struct-static.patch
* mm-zsmalloc-make-several-functions-and-a-struct-static-fix.patch
* mm-swap-make-swap_slots_cache_mutex-and-swap_slots_cache_enable_mutex-static.patch
* mm-fadvise-fix-signed-overflow-ubsan-complaint.patch
* mm-fadvise-fix-signed-overflow-ubsan-complaint-fix.patch
* mm-thp-passing-correct-vm_flags-to-hugepage_vma_check.patch
* kernel-memremap-kasan-make-zone_device-with-work-with-kasan.patch
* mm-make-deferred_struct_page_init-explicitly-depend-on-sparsemem.patch
* memcg-oom-move-out_of_memory-back-to-the-charge-path.patch
* mm-sparse-make-sparse_init_one_section-void-and-remove-check.patch
* mm-sparse-make-sparse_init_one_section-void-and-remove-check-fix.patch
* mm-sparse-make-sparse_init_one_section-void-and-remove-check-fix-2.patch
* mm-memblock-replace-u64-with-phys_addr_t-where-appropriate.patch
* list_lru-combine-code-under-the-same-define.patch
* mm-introduce-config_memcg_kmem-as-combination-of-config_memcg-config_slob.patch
* mm-assign-id-to-every-memcg-aware-shrinker.patch
* mm-assign-id-to-every-memcg-aware-shrinker-v9.patch
* memcg-move-up-for_each_mem_cgroup-_tree-defines.patch
* mm-assign-memcg-aware-shrinkers-bitmap-to-memcg.patch
* mm-assign-memcg-aware-shrinkers-bitmap-to-memcg-v9.patch
* mm-refactoring-in-workingset_init.patch
* mm-refactoring-in-workingset_init-v9.patch
* fs-refactoring-in-alloc_super.patch
* fs-propagate-shrinker-id-to-list_lru.patch
* list_lru-add-memcg-argument-to-list_lru_from_kmem.patch
* list_lru-pass-dst_memcg-argument-to-memcg_drain_list_lru_node.patch
* list_lru-pass-lru-argument-to-memcg_drain_list_lru_node.patch
* mm-export-mem_cgroup_is_root.patch
* mm-set-bit-in-memcg-shrinker-bitmap-on-first-list_lru-item-apearance.patch
* mm-set-bit-in-memcg-shrinker-bitmap-on-first-list_lru-item-apearance-v9.patch
* mm-iterate-only-over-charged-shrinkers-during-memcg-shrink_slab.patch
* mm-iterate-only-over-charged-shrinkers-during-memcg-shrink_slab-v9.patch
* mm-generalize-shrink_slab-calls-in-shrink_node.patch
* mm-add-shrink_empty-shrinker-methods-return-value.patch
* mm-clear-shrinker-bit-if-there-are-no-objects-related-to-memcg.patch
* mm-clear-shrinker-bit-if-there-are-no-objects-related-to-memcg-v9.patch
* mm-sparse-add-a-static-variable-nr_present_sections.patch
* mm-sparsemem-defer-the-ms-section_mem_map-clearing.patch
* mm-sparsemem-defer-the-ms-section_mem_map-clearing-fix.patch
* mm-sparse-add-a-new-parameter-data_unit_size-for-alloc_usemap_and_memmap.patch
* mm-sparse-optimize-memmap-allocation-during-sparse_init.patch
* mm-sparse-optimize-memmap-allocation-during-sparse_init-checkpatch-fixes.patch
* revert-mm-always-flush-vma-ranges-affected-by-zap_page_range.patch
* arm-arm64-introduce-config_have_memblock_pfn_valid.patch
* mm-page_alloc-remain-memblock_next_valid_pfn-on-arm-arm64.patch
* mm-page_alloc-reduce-unnecessary-binary-search-in-memblock_next_valid_pfn.patch
* mm-memblock-introduce-memblock_search_pfn_regions.patch
* mm-memblock-introduce-pfn_valid_region.patch
* mm-page_alloc-reduce-unnecessary-binary-search-in-early_pfn_valid.patch
* z3fold-fix-wrong-handling-of-headless-pages.patch
* mm-cma-remove-unsupported-gfp_mask-parameter-from-cma_alloc.patch
* dma-remove-unsupported-gfp_mask-parameter-from-dma_alloc_from_contiguous.patch
* mm-oom-remove-sleep-from-under-oom_lock.patch
* mm-hugetlb-remove-gigantic-page-support-for-highmem.patch
* mm-oom-document-oom_lock.patch
* mm-page_alloc-double-zones-batchsize.patch
* mm-hugetlb-dont-zero-1gib-bootmem-pages.patch
* mm-sparse-abstract-sparse-buffer-allocations.patch
* mm-sparse-abstract-sparse-buffer-allocations-fix.patch
* mm-sparse-abstract-sparse-buffer-allocations-fix-fix.patch
* mm-sparse-use-the-new-sparse-buffer-functions-in-non-vmemmap.patch
* mm-sparse-move-buffer-init-fini-to-the-common-place.patch
* mm-sparse-add-new-sparse_init_nid-and-sparse_init.patch
* mm-sparse-delete-old-sprase_init-and-enable-new-one.patch
* mm-sparse-delete-old-sparse_init-and-enable-new-one-v6.patch
* mm-fix-race-on-soft-offlining-free-huge-pages.patch
* mm-soft-offline-close-the-race-against-page-allocation.patch
* mm-soft-offline-close-the-race-against-page-allocation-fix.patch
* mm-swap-make-config_thp_swap-depends-on-config_swap.patch
* mm-drop-unneeded-vm_ops-checks-v2.patch
* mm-list_lru-use-list_lru_walk_one-in-list_lru_walk_node.patch
* mm-list_lru-move-locking-from-__list_lru_walk_one-to-its-caller.patch
* mm-list_lru-pass-struct-list_lru_node-as-an-argument-__list_lru_walk_one.patch
* mm-list_lru-introduce-list_lru_shrink_walk_irq.patch
* reorganize-the-oom-report-in-dump_header.patch
* add-oom-victims-memcg-to-the-oom-context-information.patch
* add-oom-victims-memcg-to-the-oom-context-information-fix.patch
* mm-vmacache-hash-addresses-based-on-pmd.patch
* userfaultfd-remove-redundant-pointer-uwq.patch
* mm-hmmc-remove-unused-variables-align_start-and-align_end.patch
* mm-keep-int-fields-in-struct-shrink_control-together.patch
* mm-make-flags-of-unsigned-type-in-struct-shrinker.patch
* mm-clarify-semantics-of-reserved-pages.patch
* kdump-include-pg_reserved-value-in-vmcoreinfo.patch
* swap-add-comments-to-lock_cluster_or_swap_info.patch
* mm-swapfilec-replace-some-ifdef-with-is_enabled.patch
* swap-use-swap_count-in-swap_page_trans_huge_swapped.patch
* swap-unify-normal-huge-code-path-in-swap_page_trans_huge_swapped.patch
* swap-unify-normal-huge-code-path-in-put_swap_page.patch
* swap-get_swap_pages-use-entry_size-instead-of-cluster-in-parameter.patch
* swap-add-__swap_entry_free_locked.patch
* swap-put_swap_page-share-more-between-huge-normal-code-path.patch
* mm-oom-distinguish-blockable-mode-for-mmu-notifiers.patch
* mm-oom-distinguish-blockable-mode-for-mmu-notifiers-checkpatch-fixes.patch
* mm-oom-distinguish-blockable-mode-for-mmu-notifiers-fix.patch
* mm-adjust-max-read-count-in-generic_file_buffered_read.patch
* mm-oom-remove-oom_lock-from-oom_reaper.patch
* mm-oom-describe-task-memory-unit-larger-pid-pad.patch
* mm-swap-fix-race-between-swapoff-and-some-swap-operations.patch
* mm-swap-fix-race-between-swapoff-and-some-swap-operations-v6.patch
* mm-fix-race-between-swapoff-and-mincore.patch
* list_lru-prefetch-neighboring-list-entries-before-acquiring-lock.patch
* list_lru-prefetch-neighboring-list-entries-before-acquiring-lock-fix.patch
* mm-oom-refactor-the-oom_kill_process-function.patch
* mm-implement-mem_cgroup_scan_tasks-for-the-root-memory-cgroup.patch
* mm-oom-cgroup-aware-oom-killer.patch
* mm-oom-cgroup-aware-oom-killer-fix.patch
* mm-oom-cgroup-aware-oom-killer-fix-2.patch
* mm-oom-cgroup-aware-oom-killer-fix-3.patch
* mm-oom-introduce-memoryoom_group.patch
* mm-oom-introduce-memoryoom_group-fix.patch
* mm-oom-add-cgroup-v2-mount-option-for-cgroup-aware-oom-killer.patch
* mm-oom-docs-describe-the-cgroup-aware-oom-killer.patch
* mm-oom-docs-describe-the-cgroup-aware-oom-killer-fix.patch
* mm-oom-docs-describe-the-cgroup-aware-oom-killer-fix-2.patch
* mm-oom-docs-describe-the-cgroup-aware-oom-killer-fix-2-fix.patch
* cgroup-list-groupoom-in-cgroup-features.patch
* mm-add-strictlimit-knob-v2.patch
* mm-dont-expose-page-to-fast-gup-before-its-ready.patch
* mm-page_owner-align-with-pageblock_nr_pages.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* info-task-hung-in-generic_file_write_iter.patch
* proc-fixup-pde-allocation-bloat.patch
* proc-fixup-pde-allocation-bloat-fix.patch
* procfs-uptime-use-ktime_get_boottime_ts64.patch
* proc-test-proc-self-symlink.patch
* proc-test-proc-thread-self-symlink.patch
* proc-smaller-readlock-section-in-readdir-proc.patch
* proc-put-task-earlier-in-proc-fail-nth.patch
* proc-save-2-atomic-ops-on-write-to-proc-attr.patch
* proc-use-macro-in-proc-latency-hook.patch
* proc-spread-const-a-bit.patch
* proc-use-unsigned-int-in-proc-stat-hook.patch
* fs-proc-adding-new-typedef-vm_fault_t.patch
* proc-kcore-use-__pa_symbol-for-kcore_text-list-entries.patch
* proc-kcore-dont-grab-lock-for-kclist_add.patch
* proc-kcore-dont-grab-lock-for-memory-hotplug-notifier.patch
* proc-kcore-replace-kclist_lock-rwlock-with-rwsem.patch
* proc-kcore-fix-memory-hotplug-vs-multiple-opens-race.patch
* proc-kcore-hold-lock-during-read.patch
* proc-kcore-clean-up-elf-header-generation.patch
* proc-kcore-optimize-multiple-page-reads.patch
* proc-kcore-add-vmcoreinfo-note-to-proc-kcore.patch
* documentation-proctxt-adding-hardwarecorrupted-field-and-description.patch
* include-asm-generic-bugh-clarify-valid-uses-of-warn.patch
* kernelh-documentation-for-roundup-vs-round_up.patch
* bdi-use-refcount_t-for-reference-counting-instead-atomic_t.patch
* bdi-use-irqsave-variant-of-refcount_dec_and_lock.patch
* userns-use-refcount_t-for-reference-counting-instead-atomic_t.patch
* userns-use-irqsave-variant-of-refcount_dec_and_lock.patch
* crash-print-timestamp-using-time64_t.patch
* kernel-hung_taskc-allow-to-set-checking-interval-separately-from-timeout.patch
* kernel-hung_taskc-allow-to-set-checking-interval-separately-from-timeout-fix.patch
* spellingtxt-add-more-spellings-to-spellingtxt.patch
* arch-enable-relative-relocations-for-arm64-power-and-x86.patch
* module-allow-symbol-exports-to-be-disabled.patch
* module-use-relative-references-for-__ksymtab-entries.patch
* init-allow-initcall-tables-to-be-emitted-using-relative-references.patch
* pci-add-support-for-relative-addressing-in-quirk-tables.patch
* kernel-tracepoints-add-support-for-relative-references.patch
* epoll-use-the-waitqueue-lock-to-protect-ep-wq.patch
* userfaultfd-use-fault_wqh-lock.patch
* sched-wait-assert-the-wait_queue_head-lock-is-held-in-__wake_up_common.patch
* fs-epoll-loosen-irq-safety-in-ep_scan_ready_list.patch
* fs-epoll-loosen-irq-safety-in-epoll_insert-and-epoll_remove.patch
* bitmap-drop-unnecessary-0-check-for-u32-array-operations.patch
* bitops-introduce-bits_per_type.patch
* lib-make-struct-pointer-foo-static.patch
* lib-add-crc64-calculation-routines.patch
* bcache-use-routines-from-lib-crc64c-for-crc64-calculation.patch
* lib-test_crc-add-test-cases-for-crc-calculation.patch
* lib-test_crc-add-test-cases-for-crc-calculation-fix.patch
* lib-remove-default-n-in-kconfig-for-tests.patch
* checkpatch-add-a-strict-test-for-structs-with-bool-member-definitions.patch
* checkpatch-add-fix-for-concatenated_string-and-string_fragments.patch
* checkpatch-improve-runtime-execution-speed-a-little.patch
* checkpatch-update-section-keywords.patch
* checkpatch-warn-if-missing-author-signed-off-by.patch
* checkpatch-warn-if-missing-author-signed-off-by-fix.patch
* checkpatch-fix-macro-argument-reuse-test.patch
* sparse-remove-uneffective-sparse-disabling.patch
* kprobes-kprobes-maintainer-change.patch
* autofs-fix-directory-and-symlink-access.patch
* autofs-fix-inconsistent-use-of-now-variable.patch
* autofs-fix-clearing-autofs_exp_leaves-in-autofs_expire_indirect.patch
* autofs-make-autofs_expire_direct-static.patch
* autofs-make-autofs_expire_indirect-static.patch
* autofs-make-expire-flags-usage-consistent-with-v5-params.patch
* autofs-add-autofs_exp_forced-flag.patch
* nilfs2-use-64-bit-superblock-timstamps.patch
* fs-nilfs2-adding-new-return-type-vm_fault_t.patch
* hfsplus-dont-return-0-when-fill_super-failed.patch
* hfsplus-prevent-crash-on-exit-from-failed-search.patch
* hfs-prevent-crash-on-exit-from-failed-search.patch
* hfsplus-avoid-deadlock-on-file-truncation.patch
* hfs-hfsplus-follow-macos-time-behavior.patch
* hfs-hfsplus-follow-macos-time-behavior-checkpatch-fixes.patch
* hfs-hfsplus-stop-using-timespec-based-interfaces.patch
* hfsplus-fix-decomposition-of-hangul-characters.patch
* hfsplus-fix-null-dereference-in-hfsplus_lookup.patch
* reiserfs-use-monotonic-time-for-j_trans_start_time.patch
* reiserfs-remove-obsolete-print_time-function.patch
* reiserfs-change-j_timestamp-type-to-time64_t.patch
* fat-add-fitrim-ioctl-for-fat-file-system.patch
* fat-add-fitrim-ioctl-for-fat-file-system-fix.patch
* fat-validate-i_start-before-using.patch
* fat-propagate-64-bit-inode-timestamps.patch
* signal-make-force_sigsegv-void.patch
* signal-make-kill_as_cred_perm-return-bool.patch
* signal-make-may_ptrace_stop-return-bool.patch
* signal-make-do_sigpending-void.patch
* signal-simplify-rt_sigaction.patch
* signal-make-kill_ok_by_cred-return-bool.patch
* signal-make-sig_handler_ignored-return-bool.patch
* signal-make-sig_task_ignored-return-bool.patch
* signal-make-sig_ignored-return-bool.patch
* signal-make-has_pending_signals-return-bool.patch
* signal-make-recalc_sigpending_tsk-return-bool.patch
* signal-make-unhandled_signal-return-bool.patch
* signal-make-flush_sigqueue_mask-void.patch
* signal-make-wants_signal-return-bool.patch
* signal-make-legacy_queue-return-bool.patch
* signal-make-sigkill_pending-return-bool.patch
* signal-make-get_signal-return-bool.patch
* fork-dont-copy-inconsistent-signal-handler-state-to-child.patch
* rapidio-remove-redundant-pointer-md.patch
* sysctl-fix-typos-in-comments.patch
* adfs-use-timespec64-for-time-conversion.patch
* bfs-add-sanity-check-at-bfs_fill_super.patch
* sysvfs-use-ktime_get_real_seconds-for-superblock-stamp.patch
* kconfig-remove-expert-from-checkpoint_restore.patch
* ipc-ipc-compute-kern_ipc_permid-under-the-ipc-lock.patch
* ipc-reorganize-initialization-of-kern_ipc_permseq.patch
* ipc-utilc-use-ipc_rcu_putref-for-failues-in-ipc_addid.patch
* ipc-rename-ipcctl_pre_down_nolock.patch
* ipc-utilc-correct-comment-in-ipc_obtain_object_check.patch
* ipc-drop-ipc_lock.patch
* lib-rhashtable-simplify-bucket_table_alloc.patch
* lib-rhashtable-guarantee-initial-hashtable-allocation.patch
* ipc-get-rid-of-ids-tables_initialized-hack.patch
* ipc-simplify-ipc-initialization.patch
* ipc-utilc-further-variable-name-cleanups.patch
* ipc-utilc-update-return-value-of-ipc_getref-from-int-to-bool.patch
  linux-next.patch
  linux-next-rejects.patch
* hwtracing-intel_th-change-return-type-to-vm_fault_t.patch
* fs-nfs-adding-new-return-type-vm_fault_t.patch
* fs-afs-adding-new-return-type-vm_fault_t.patch
* treewide-correct-differenciate-and-instanciate-typos.patch
* vmcore-hide-vmcoredd_mmap_dumps-for-nommu-builds.patch
* gpu-drm-gma500-change-return-type-to-vm_fault_t.patch
* fix-read-buffer-overflow-in-delta-ipc.patch
  make-sure-nobodys-leaking-resources.patch
  releasing-resources-with-children.patch
  mutex-subsystem-synchro-test-module.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  slab-leaks3-default-y.patch
  workaround-for-a-pci-restoring-bug.patch
