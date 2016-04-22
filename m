Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 26DC26B007E
	for <linux-mm@kvack.org>; Fri, 22 Apr 2016 18:49:52 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id dx6so173274334pad.0
        for <linux-mm@kvack.org>; Fri, 22 Apr 2016 15:49:52 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h9si9974640pap.227.2016.04.22.15.49.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Apr 2016 15:49:50 -0700 (PDT)
Date: Fri, 22 Apr 2016 15:49:50 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2016-04-22-15-49 uploaded
Message-ID: <571aaa8e.Vc7B9hv+p+eHaLrq%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2016-04-22-15-49 has been uploaded to

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


This mmotm tree contains the following patches against 4.6-rc4:
(patches marked "*" will be included in linux-next)

  origin.patch
* ksm-introduce-ksm_max_page_sharing-per-page-deduplication-limit.patch
  i-need-old-gcc.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
* kexec-update-vmcoreinfo-for-compound_order-dtor.patch
* kexec-export-offsetpagecompound_head-to-find-out-compound-tail-page.patch
* mm-exclude-hugetlb-pages-from-thp-page_mapped-logic.patch
* thp-keep-huge-zero-page-pinned-until-tlb-flush.patch
* mailmap-fix-krzysztof-kozlowskis-misspelled-name.patch
* mm-huge_memory-replace-vm_no_thp-vm_bug_on-with-actual-vma-check.patch
* numa-fix-proc-pid-numa_maps-for-thp.patch
* mm-vmscan-reclaim-highmem-zone-if-buffer_heads-is-over-limit.patch
* mm-call-swap_slot_free_notify-with-holding-page-lock.patch
* mm-hwpoison-fix-wrong-num_poisoned_pages-account.patch
* mailmap-add-frank-rowand.patch
* mm-wake-kcompactd-before-kswapds-short-sleep.patch
* kcov-dont-trace-the-code-coverage-code.patch
* kcov-dont-profile-branches-in-kcov.patch
* update-email-address.patch
* ocfs2-dlm-return-zero-if-deref_done-message-is-successfully-handled.patch
* mm-memory-failure-fix-race-with-compound-page-split-merge.patch
* rapidio-fix-potential-null-pointer-dereference.patch
* lib-stackdepotc-allow-the-stack-trace-hash-to-be-zero.patch
* kprobes-add-the-tls-argument-for-j_do_fork.patch
* mm-fix-incorrect-pfn-passed-to-untrack_pfn-in-remap_pfn_range.patch
* mm-thp-correct-split_huge_pages-file-permission.patch
* mm-memcontrol-let-v2-cgroups-follow-changes-in-system-swappiness.patch
* rapidio-mport_cdev-fix-uapi-type-definitions.patch
* huge-pagecache-mmap_sem-is-unlocked-when-truncation-splits-pmd.patch
* mm-update-min_free_kbytes-from-khugepaged-after-core-initialization.patch
* dax-add-dax_get_unmapped_area-for-pmd-mappings.patch
* ext2-4-xfs-blk-call-dax_get_unmapped_area-for-dax-pmd-mappings.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* debugobjects-make-fixup-functions-return-bool-instead-of-int.patch
* debugobjects-correct-the-usage-of-fixup-call-results.patch
* workqueue-update-debugobjects-fixup-callbacks-return-type.patch
* timer-update-debugobjects-fixup-callbacks-return-type.patch
* rcu-update-debugobjects-fixup-callbacks-return-type.patch
* percpu_counter-update-debugobjects-fixup-callbacks-return-type.patch
* documentation-update-debugobjects-doc.patch
* fs-ext4-fsyncc-generic_file_fsync-call-based-on-barrier-flag.patch
* ocfs2-error-code-comments-and-amendments-the-comment-of-ocfs2_extended_slot-should-be-0x08.patch
* ocfs2-clean-up-an-unused-variable-wants_rotate-in-ocfs2_truncate_rec.patch
* ocfs2-clean-up-unused-parameter-count-in-o2hb_read_block_input.patch
* ocfs2-o2hb-add-negotiate-timer.patch
* ocfs2-o2hb-add-negotiate-timer-v2.patch
* ocfs2-o2hb-add-nego_timeout-message.patch
* ocfs2-o2hb-add-nego_timeout-message-v2.patch
* ocfs2-o2hb-add-negotiate_approve-message.patch
* ocfs2-o2hb-add-negotiate_approve-message-v2.patch
* ocfs2-o2hb-add-some-user-debug-log.patch
* ocfs2-o2hb-add-some-user-debug-log-v2.patch
* ocfs2-o2hb-dont-negotiate-if-last-hb-fail.patch
* ocfs2-o2hb-fix-hb-hung-time.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* padata-removed-unused-code.patch
* kernel-padata-hide-unused-functions.patch
* kernel-padata-hide-unused-functions-checkpatch-fixes.patch
  mm.patch
* mm-slab-fix-the-theoretical-race-by-holding-proper-lock.patch
* mm-slab-remove-bad_alien_magic-again.patch
* mm-slab-drain-the-free-slab-as-much-as-possible.patch
* mm-slab-factor-out-kmem_cache_node-initialization-code.patch
* mm-slab-clean-up-kmem_cache_node-setup.patch
* mm-slab-dont-keep-free-slabs-if-free_objects-exceeds-free_limit.patch
* mm-slab-racy-access-modify-the-slab-color.patch
* mm-slab-make-cache_grow-handle-the-page-allocated-on-arbitrary-node.patch
* mm-slab-separate-cache_grow-to-two-parts.patch
* mm-slab-refill-cpu-cache-through-a-new-slab-without-holding-a-node-lock.patch
* mm-slab-lockless-decision-to-grow-cache.patch
* mm-slub-replace-kick_all_cpus_sync-with-synchronize_sched-in-kmem_cache_shrink.patch
* mm-page_ref-use-page_ref-helper-instead-of-direct-modification-of-_count.patch
* mm-rename-_count-field-of-the-struct-page-to-_refcount.patch
* mm-rename-_count-field-of-the-struct-page-to-_refcount-fix.patch
* mm-rename-_count-field-of-the-struct-page-to-_refcount-fix-fix.patch
* mm-rename-_count-field-of-the-struct-page-to-_refcount-fix-fix-fix.patch
* compilerh-add-support-for-malloc-attribute.patch
* include-linux-apply-__malloc-attribute.patch
* include-linux-apply-__malloc-attribute-checkpatch-fixes.patch
* include-linux-nodemaskh-create-next_node_in-helper.patch
* include-linux-nodemaskh-create-next_node_in-helper-fix.patch
* include-linux-nodemaskh-create-next_node_in-helper-fix-fix.patch
* mm-hugetlb-optimize-minimum-size-min_size-accounting.patch
* mm-hugetlb-introduce-hugetlb_bad_size.patch
* arm64-mm-use-hugetlb_bad_size.patch
* metag-mm-use-hugetlb_bad_size.patch
* powerpc-mm-use-hugetlb_bad_size.patch
* tile-mm-use-hugetlb_bad_size.patch
* x86-mm-use-hugetlb_bad_size.patch
* mm-hugetlb-is_vm_hugetlb_page-can-be-boolean.patch
* mm-memory_hotplug-is_mem_section_removable-can-be-boolean.patch
* mm-vmalloc-is_vmalloc_addr-can-be-boolean.patch
* mm-mempolicy-vma_migratable-can-be-boolean.patch
* mm-memcontrolc-mem_cgroup_select_victim_node-clarify-comment.patch
* mm-page_alloc-remove-useless-parameter-of-__free_pages_boot_core.patch
* zsmalloc-use-first_page-rather-than-page.patch
* zsmalloc-clean-up-many-bug_on.patch
* zsmalloc-reordering-function-parameter.patch
* zsmalloc-remove-unused-pool-param-in-obj_free.patch
* mm-hugetlbc-use-first_memory_node.patch
* mm-mempolicyc-offset_il_node-document-and-clarify.patch
* mm-rmap-replace-bug_onanon_vma-degree-with-vm_warn_on.patch
* mm-compaction-wrap-calculating-first-and-last-pfn-of-pageblock.patch
* mm-compaction-reduce-spurious-pcplist-drains.patch
* mm-compaction-skip-blocks-where-isolation-fails-in-async-direct-compaction.patch
* mm-compaction-direct-freepage-allocation-for-async-direct-compaction.patch
* mm-compaction-direct-freepage-allocation-for-async-direct-compaction-checkpatch-fixes.patch
* mm-highmem-simplify-is_highmem.patch
* mm-uninline-page_mapped.patch
* mm-uninline-page_mapped-checkpatch-fixes.patch
* mm-hugetlb-add-same-zone-check-in-pfn_range_valid_gigantic.patch
* mm-memory_hotplug-add-comment-to-some-functions-related-to-memory-hotplug.patch
* mm-vmstat-add-zone-range-overlapping-check.patch
* mm-page_owner-add-zone-range-overlapping-check.patch
* power-add-zone-range-overlapping-check.patch
* mm-workingset-only-do-workingset-activations-on-reads.patch
* mm-filemap-only-do-access-activations-on-reads.patch
* mm-vmscan-reduce-size-of-inactive-file-list.patch
* mm-writeback-correct-dirty-page-calculation-for-highmem.patch
* mm-page_alloc-correct-highmem-memory-statistics.patch
* mm-highmem-make-nr_free_highpages-handles-all-highmem-zones-by-itself.patch
* mm-vmstat-make-node_page_state-handles-all-zones-by-itself.patch
* mm-mmap-kill-hook-arch_rebalance_pgtables.patch
* mm-update_lru_size-warn-and-reset-bad-lru_size.patch
* mm-update_lru_size-do-the-__mod_zone_page_state.patch
* mm-use-__setpageswapbacked-and-dont-clearpageswapbacked.patch
* tmpfs-preliminary-minor-tidyups.patch
* tmpfs-mem_cgroup-charge-fault-to-vm_mm-not-current-mm.patch
* mm-proc-sys-vm-stat_refresh-to-force-vmstat-update.patch
* huge-mm-move_huge_pmd-does-not-need-new_vma.patch
* huge-pagecache-extend-mremap-pmd-rmap-lockout-to-files.patch
* arch-fix-has_transparent_hugepage.patch
* memory_hotplug-introduce-config_memory_hotplug_default_online.patch
* memory_hotplug-introduce-config_memory_hotplug_default_online-fix.patch
* memory_hotplug-introduce-memhp_default_state=-command-line-parameter.patch
* mm-oom-move-gfp_nofs-check-to-out_of_memory.patch
* oom-oom_reaper-try-to-reap-tasks-which-skip-regular-oom-killer-path.patch
* oom-oom_reaper-try-to-reap-tasks-which-skip-regular-oom-killer-path-try-to-reap-tasks-which-skip-regular-memcg-oom-killer-path.patch
* oom-oom_reaper-try-to-reap-tasks-which-skip-regular-oom-killer-path-try-to-reap-tasks-which-skip-regular-memcg-oom-killer-path-fix.patch
* mm-oom_reaper-clear-tif_memdie-for-all-tasks-queued-for-oom_reaper.patch
* mm-oom_reaper-clear-tif_memdie-for-all-tasks-queued-for-oom_reaper-clear-oom_reaper_list-before-clearing-tif_memdie.patch
* mm-page_alloc-only-check-pagecompound-for-high-order-pages.patch
* mm-page_alloc-use-new-pageanonhead-helper-in-the-free-page-fast-path.patch
* mm-page_alloc-reduce-branches-in-zone_statistics.patch
* mm-page_alloc-inline-zone_statistics.patch
* mm-page_alloc-inline-the-fast-path-of-the-zonelist-iterator.patch
* mm-page_alloc-use-__dec_zone_state-for-order-0-page-allocation.patch
* mm-page_alloc-avoid-unnecessary-zone-lookups-during-pageblock-operations.patch
* mm-page_alloc-convert-alloc_flags-to-unsigned.patch
* mm-page_alloc-convert-nr_fair_skipped-to-bool.patch
* mm-page_alloc-remove-unnecessary-local-variable-in-get_page_from_freelist.patch
* mm-page_alloc-remove-unnecessary-initialisation-in-get_page_from_freelist.patch
* mm-page_alloc-remove-unnecessary-initialisation-from-__alloc_pages_nodemask.patch
* mm-page_alloc-remove-redundant-check-for-empty-zonelist.patch
* mm-page_alloc-simplify-last-cpupid-reset.patch
* mm-page_alloc-move-might_sleep_if-check-to-the-allocator-slowpath.patch
* mm-page_alloc-move-__gfp_hardwall-modifications-out-of-the-fastpath.patch
* mm-page_alloc-check-once-if-a-zone-has-isolated-pageblocks.patch
* mm-page_alloc-shorten-the-page-allocator-fast-path.patch
* mm-page_alloc-reduce-cost-of-fair-zone-allocation-policy-retry.patch
* mm-page_alloc-shortcut-watermark-checks-for-order-0-pages.patch
* mm-page_alloc-avoid-looking-up-the-first-zone-in-a-zonelist-twice.patch
* mm-page_alloc-remove-field-from-alloc_context.patch
* mm-page_alloc-check-multiple-page-fields-with-a-single-branch.patch
* mm-page_alloc-remove-unnecessary-variable-from-free_pcppages_bulk.patch
* mm-page_alloc-inline-pageblock-lookup-in-page-free-fast-paths.patch
* cpuset-use-static-key-better-and-convert-to-new-api.patch
* mm-page_alloc-defer-debugging-checks-of-freed-pages-until-a-pcp-drain.patch
* mm-page_alloc-defer-debugging-checks-of-pages-allocated-from-the-pcp.patch
* vmscan-consider-classzone_idx-in-compaction_ready.patch
* mm-compaction-change-compact_-constants-into-enum.patch
* mm-compaction-cover-all-compaction-mode-in-compact_zone.patch
* mm-compaction-distinguish-compact_deferred-from-compact_skipped.patch
* mm-compaction-distinguish-between-full-and-partial-compact_complete.patch
* mm-compaction-update-compaction_result-ordering.patch
* mm-compaction-simplify-__alloc_pages_direct_compact-feedback-interface.patch
* mm-compaction-abstract-compaction-feedback-to-helpers.patch
* mm-compaction-abstract-compaction-feedback-to-helpers-fix.patch
* mm-use-compaction-feedback-for-thp-backoff-conditions.patch
* mm-oom-rework-oom-detection.patch
* mm-throttle-on-io-only-when-there-are-too-many-dirty-and-writeback-pages.patch
* mm-oom-protect-costly-allocations-some-more.patch
* mm-consider-compaction-feedback-also-for-costly-allocation.patch
* mm-oom-compaction-prevent-from-should_compact_retry-looping-for-ever-for-costly-orders.patch
* mm-oom-compaction-prevent-from-should_compact_retry-looping-for-ever-for-costly-orders-fix.patch
* z3fold-the-3-fold-allocator-for-compressed-pages.patch
* mm-thp-simplify-the-implementation-of-mk_huge_pmd.patch
* memory-failure-replace-mce-with-memory-failure.patch
* mm-memblock-move-memblock_addreserve_region-into-memblock_addreserve.patch
* mm-vmalloc-keep-a-separate-lazy-free-list.patch
* mm-make-optimistic-check-for-swapin-readahead.patch
* mm-make-optimistic-check-for-swapin-readahead-fix-2.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-2.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-3.patch
* mm-kasan-initial-memory-quarantine-implementation.patch
* mm-kasan-initial-memory-quarantine-implementation-v8.patch
* mm-kasan-initial-memory-quarantine-implementation-v8-fix.patch
* mm-kasan-dont-call-kasan_krealloc-from-ksize.patch
* mm-kasan-add-a-ksize-test.patch
* mm-memblock-if-nr_new-is-0-just-return.patch
* procfs-expose-umask-in-proc-pid-status.patch
* mn10300-let-exit_fpu-accept-a-task.patch
* exit_thread-remove-empty-bodies.patch
* exit_thread-remove-empty-bodies-fix.patch
* exit_thread-accept-a-task-parameter-to-be-exited.patch
* exit_thread-accept-a-task-parameter-to-be-exited-checkpatch-fixes.patch
* fork-free-thread-in-copy_process-on-failure.patch
* printk-nmi-generic-solution-for-safe-printk-in-nmi.patch
* printk-nmi-warn-when-some-message-has-been-lost-in-nmi-context.patch
* printk-nmi-increase-the-size-of-nmi-buffer-and-make-it-configurable.patch
* printk-nmi-flush-nmi-messages-on-the-system-panic.patch
* lib-switch-config_printk_time-to-int.patch
* printk-allow-different-timestamps-for-printktime.patch
* maintainers-remove-linux-listsopenriscnet.patch
* lib-vsprintf-simplify-uuid-printing.patch
* ima-use-%pu-to-output-uuid-in-printable-format.patch
* lib-uuid-move-generate_random_uuid-to-uuidc.patch
* lib-uuid-introduce-few-more-generic-helpers-for-uuid.patch
* lib-uuid-introduce-few-more-generic-helpers-for-uuid-fix.patch
* lib-uuid-remove-fsf-address.patch
* sysctl-use-generic-uuid-library.patch
* efi-redefine-type-constant-macro-from-generic-code.patch
* efivars-use-generic-uuid-library.patch
* genhd-move-to-use-generic-uuid-library.patch
* radix-tree-introduce-radix_tree_empty.patch
* radix-tree-test-suite-fix-build.patch
* radix-tree-test-suite-add-tests-for-radix_tree_locate_item.patch
* radix-tree-test-suite-allow-testing-other-fan-out-values.patch
* radix-tree-test-suite-keep-regression-test-runs-short.patch
* radix-tree-test-suite-rebuild-when-headers-change.patch
* radix-tree-remove-unused-looping-macros.patch
* introduce-config_radix_tree_multiorder.patch
* radix-tree-add-missing-sibling-entry-functionality.patch
* radix-tree-fix-sibling-entry-insertion.patch
* radix-tree-fix-deleting-a-multi-order-entry-through-an-alias.patch
* radix-tree-remove-restriction-on-multi-order-entries.patch
* radix-tree-introduce-radix_tree_load_root.patch
* radix-tree-fix-extending-the-tree-for-multi-order-entries-at-offset-0.patch
* radix-tree-test-suite-start-adding-multiorder-tests.patch
* radix-tree-fix-several-shrinking-bugs-with-multiorder-entries.patch
* radix-tree-rewrite-__radix_tree_lookup.patch
* radix-tree-fix-multiorder-bug_on-in-radix_tree_insert.patch
* radix-tree-add-support-for-multi-order-iterating.patch
* radix-tree-test-suite-multi-order-iteration-test.patch
* radix-tree-rewrite-radix_tree_tag_set.patch
* radix-tree-rewrite-radix_tree_tag_clear.patch
* radix-tree-rewrite-radix_tree_tag_get.patch
* radix-tree-test-suite-add-multi-order-tag-test.patch
* radix-tree-fix-radix_tree_create-for-sibling-entries.patch
* radix-tree-rewrite-radix_tree_locate_item.patch
* radix-tree-fix-radix_tree_range_tag_if_tagged-for-multiorder-entries.patch
* radix-tree-fix-radix_tree_dump-for-multi-order-entries.patch
* radix-tree-add-copyright-statements.patch
* drivers-hwspinlock-use-correct-radix-tree-api.patch
* radix-tree-miscellaneous-fixes.patch
* radix-tree-split-node-path-into-offset-and-height.patch
* radix-tree-replace-node-height-with-node-shift.patch
* radix-tree-remove-a-use-of-root-height-from-delete_node.patch
* radix-tree-test-suite-remove-dependencies-on-height.patch
* radix-tree-remove-root-height.patch
* radix-tree-rename-indirect_ptr-to-internal_node.patch
* radix-tree-rename-ptr_to_indirect-to-node_to_entry.patch
* radix-tree-rename-indirect_to_ptr-to-entry_to_node.patch
* radix-tree-rename-radix_tree_is_indirect_ptr.patch
* radix-tree-change-naming-conventions-in-radix_tree_shrink.patch
* radix-tree-tidy-up-next_chunk.patch
* radix-tree-tidy-up-range_tag_if_tagged.patch
* radix-tree-tidy-up-__radix_tree_create.patch
* radix-tree-introduce-radix_tree_replace_clear_tags.patch
* radix-tree-make-radix_tree_descend-more-useful.patch
* dax-move-radix_dax_-definitions-to-daxc.patch
* radix-tree-free-up-the-bottom-bit-of-exceptional-entries-for-reuse.patch
* lib-add-crc64-ecma-module.patch
* checkpatch-add-prefer_is_enabled-test.patch
* checkpatch-improve-constant_comparison-test-for-structure-members.patch
* checkpatch-add-test-for-keywords-not-starting-on-tabstops.patch
* checkpatch-whine-about-access_once.patch
* checkpatch-advertise-the-fix-and-fix-inplace-options-more.patch
* checkpatch-add-list-types-to-show-message-types-to-show-or-ignore.patch
* init-mainc-simplify-initcall_blacklisted.patch
* nilfs2-constify-nilfs_sc_operations-structures.patch
* wait-ptrace-assume-__wall-if-the-child-is-traced.patch
* wait-allow-sys_waitid-to-accept-__wnothread-__wclone-__wall.patch
* signal-make-oom_flags-a-bool.patch
* kernel-signalc-convert-printkkern_level-to-pr_level.patch
* fs-execc-fix-minor-memory-leak.patch
* kexec-introduce-a-protection-mechanism-for-the-crashkernel-reserved-memory.patch
* kexec-provide-arch_kexec_protectunprotect_crashkres.patch
* kexec-make-a-pair-of-map-unmap-reserved-pages-in-error-path.patch
* kexec-do-a-cleanup-for-function-kexec_load.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* arch-defconfig-remove-config_resource_counters.patch
* ipc-semc-fix-complex_count-vs-simple-op-race.patch
* ipc-msgc-msgsnd-use-freezable-blocking-call.patch
* msgrcv-use-freezable-blocking-call.patch
  linux-next.patch
  linux-next-rejects.patch
* mm-rename-_count-field-of-the-struct-page-to-_refcount-fix6.patch
* drivers-net-wireless-intel-iwlwifi-dvm-calibc-fix-min-warning.patch
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
