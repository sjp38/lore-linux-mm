Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 408988E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 18:09:58 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id d71so15049338pgc.1
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 15:09:58 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z19si15640467pfc.95.2018.12.18.15.09.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 15:09:55 -0800 (PST)
Date: Tue, 18 Dec 2018 15:09:52 -0800
From: akpm@linux-foundation.org
Subject: mmotm 2018-12-18-15-09 uploaded
Message-ID: <20181218230952.xaHC5%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org

The mm-of-the-moment snapshot 2018-12-18-15-09 has been uploaded to

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


This mmotm tree contains the following patches against 4.20-rc7:
(patches marked "*" will be included in linux-next)

  origin.patch
* checkpatch-dont-interpret-stack-dumps-as-commit-ids.patch
* mm-thp-fix-flags-for-pmd-migration-when-split.patch
* forkmemcg-fix-crash-in-free_thread_stack-on-memcg-charge-fail.patch
* mm-thp-always-specify-disabled-vmas-as-nh-in-smaps.patch
* mm-memcg-fix-reclaim-deadlock-with-writeback.patch
* mm-page_alloc-fix-has_unmovable_pages-for-hugepages.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* kasan-mm-change-hooks-signatures.patch
* kasan-slub-handle-pointer-tags-in-early_kmem_cache_node_alloc.patch
* kasan-move-common-generic-and-tag-based-code-to-commonc.patch
* kasan-rename-source-files-to-reflect-the-new-naming-scheme.patch
* kasan-add-config_kasan_generic-and-config_kasan_sw_tags.patch
* kasan-arm64-adjust-shadow-size-for-tag-based-mode.patch
* kasan-rename-kasan_zero_page-to-kasan_early_shadow_page.patch
* kasan-initialize-shadow-to-0xff-for-tag-based-mode.patch
* arm64-move-untagged_addr-macro-from-uaccessh-to-memoryh.patch
* kasan-add-tag-related-helper-functions.patch
* kasan-arm64-untag-address-in-_virt_addr_is_linear.patch
* kasan-preassign-tags-to-objects-with-ctors-or-slab_typesafe_by_rcu.patch
* kasan-arm64-fix-up-fault-handling-logic.patch
* kasan-arm64-enable-top-byte-ignore-for-the-kernel.patch
* kasan-mm-perform-untagged-pointers-comparison-in-krealloc.patch
* kasan-split-out-generic_reportc-from-reportc.patch
* kasan-add-bug-reporting-routines-for-tag-based-mode.patch
* mm-move-obj_to_index-to-include-linux-slab_defh.patch
* kasan-add-hooks-implementation-for-tag-based-mode.patch
* kasan-arm64-add-brk-handler-for-inline-instrumentation.patch
* kasan-mm-arm64-tag-non-slab-memory-allocated-via-pagealloc.patch
* kasan-add-__must_check-annotations-to-kasan-hooks.patch
* kasan-arm64-select-have_arch_kasan_sw_tags.patch
* kasan-update-documentation.patch
* kasan-add-spdx-license-identifier-mark-to-source-files.patch
* bloat-o-meter-ignore-__addressable_-symbols.patch
* scripts-decodecode-set-arch-when-running-natively-on-arm-arm64.patch
* scripts-decode_stacktrace-only-strip-base-path-when-a-prefix-of-the-path.patch
* checkstackpl-dynamic-stack-growth-for-aarch64.patch
* scripts-add-spdxcheckpy-self-test.patch
* scripts-tags-add-more-declarations.patch
* arch-sh-mach-kfr2r09-fix-struct-mtd_oob_ops-build-warning.patch
* sh-kfr2r09-drop-pointless-static-qualifier-in-kfr2r09_usb0_gadget_setup.patch
* sh-boards-convert-to-spdx-identifiers.patch
* sh-drivers-convert-to-spdx-identifiers.patch
* sh-include-convert-to-spdx-identifiers.patch
* sh-sh2-convert-to-spdx-identifiers.patch
* sh-sh2a-convert-to-spdx-identifiers.patch
* sh-sh3-convert-to-spdx-identifiers.patch
* sh-sh4-convert-to-spdx-identifiers.patch
* sh-sh4a-convert-to-spdx-identifiers.patch
* sh-sh5-convert-to-spdx-identifiers.patch
* sh-shmobile-convert-to-spdx-identifiers.patch
* sh-cpu-convert-to-spdx-identifiers.patch
* sh-kernel-convert-to-spdx-identifiers.patch
* sh-lib-convert-to-spdx-identifiers.patch
* debugobjects-call-debug_objects_mem_init-eariler.patch
* debugobjects-move-printk-out-of-db-lock-critical-sections.patch
* ocfs2-optimize-the-reading-of-heartbeat-data.patch
* ocfs2-dlmfs-remove-set-but-not-used-variable-status.patch
* ocfs2-remove-set-but-not-used-variable-lastzero.patch
* ocfs2-improve-ocfs2-makefile.patch
* ocfs2-fix-panic-due-to-unrecovered-local-alloc.patch
* ocfs2-clear-journal-dirty-flag-after-shutdown-journal.patch
* ocfs2-dont-clear-bh-uptodate-for-block-read.patch
* ocfs2-clear-zero-in-unaligned-direct-io.patch
* ocfs2-clear-zero-in-unaligned-direct-io-checkpatch-fixes.patch
* ocfs2-dlm-clean-dlm_lksb_get_lvb-and-dlm_lksb_put_lvb-when-the-cancel_pending-is-set.patch
* ocfs2-dlm-return-dlm_cancelgrant-if-the-lock-is-on-granted-list-and-the-operation-is-canceled.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
  mm.patch
* mm-slab-remove-unnecessary-unlikely.patch
* mm-slab-remove-unnecessary-unlikely-fix.patch
* mm-slub-remove-validation-on-cpu_slab-in-__flush_cpu_slab.patch
* mm-slub-page-is-always-non-null-for-node_match.patch
* mm-slub-record-final-state-of-slub-action-in-deactivate_slab.patch
* mm-slub-record-final-state-of-slub-action-in-deactivate_slab-fix.patch
* mm-slub-improve-performance-by-skipping-checked-node-in-get_any_partial.patch
* mm-slub-improve-performance-by-skipping-checked-node-in-get_any_partial-fix.patch
* mm-slab-fix-sparse-warning-in-kmalloc_type.patch
* mm-page_owner-clamp-read-count-to-page_size.patch
* mm-page_owner-clamp-read-count-to-page_size-fix.patch
* mm-hotplug-optimize-clear_hwpoisoned_pages.patch
* mm-hotplug-optimize-clear_hwpoisoned_pages-fix.patch
* mm-mmu_notifier-remove-mmu_notifier_synchronize.patch
* writeback-dont-decrement-wb-refcnt-if-wb-bdi.patch
* mm-simplify-get_next_ra_size.patch
* mm-vmscan-skip-ksm-page-in-direct-reclaim-if-priority-is-low.patch
* mm-ksm-do-not-block-on-page-lock-when-searching-stable-tree.patch
* mm-ksm-do-not-block-on-page-lock-when-searching-stable-tree-fix.patch
* mm-print-more-information-about-mapping-in-__dump_page.patch
* mm-print-more-information-about-mapping-in-__dump_page-fix.patch
* mm-print-more-information-about-mapping-in-__dump_page-fix-2.patch
* mm-lower-the-printk-loglevel-for-__dump_page-messages.patch
* mm-lower-the-printk-loglevel-for-__dump_page-messages-fix.patch
* mm-lower-the-printk-loglevel-for-__dump_page-messages-fix-fix.patch
* mm-memory_hotplug-drop-pointless-block-alignment-checks-from-__offline_pages.patch
* mm-memory_hotplug-print-reason-for-the-offlining-failure.patch
* mm-memory_hotplug-print-reason-for-the-offlining-failure-fix.patch
* mm-memory_hotplug-be-more-verbose-for-memory-offline-failures.patch
* mm-memory_hotplug-be-more-verbose-for-memory-offline-failures-fix.patch
* mm-memory_hotplug-be-more-verbose-for-memory-offline-failures-update.patch
* mm-only-report-isolation-failures-when-offlining-memory.patch
* xxhash-create-arch-dependent-32-64-bit-xxhash.patch
* ksm-replace-jhash2-with-xxhash.patch
* mm-mmap-remove-verify_mm_writelocked.patch
* mm-memory_hotplug-do-not-clear-numa_node-association-after-hot_remove.patch
* mm-add-an-f_seal_future_write-seal-to-memfd.patch
* mm-add-an-f_seal_future_write-seal-to-memfd-fix.patch
* mm-add-an-f_seal_future_write-seal-to-memfd-fix-2.patch
* selftests-memfd-add-tests-for-f_seal_future_write-seal.patch
* selftests-memfd-add-tests-for-f_seal_future_write-seal-fix.patch
* mm-remove-reset-of-pcp-counter-in-pageset_init.patch
* mm-reference-totalram_pages-and-managed_pages-once-per-function.patch
* mm-convert-zone-managed_pages-to-atomic-variable.patch
* mm-convert-totalram_pages-and-totalhigh_pages-variables-to-atomic.patch
* mm-convert-totalram_pages-and-totalhigh_pages-variables-to-atomic-checkpatch-fixes.patch
* mm-remove-managed_page_count-spinlock.patch
* vmscan-return-node_reclaim_noscan-in-node_reclaim-when-config_numa-is-n.patch
* mm-swap-use-nr_node_ids-for-avail_lists-in-swap_info_struct.patch
* userfaultfd-convert-userfaultfd_ctx-refcount-to-refcount_t.patch
* mm-change-the-order-of-migrate_reclaimable-migrate_movable-in-fallbacks.patch
* mm-devm_memremap_pages-mark-devm_memremap_pages-export_symbol_gpl.patch
* mm-devm_memremap_pages-kill-mapping-system-ram-support.patch
* mm-devm_memremap_pages-fix-shutdown-handling.patch
* mm-devm_memremap_pages-add-memory_device_private-support.patch
* mm-hmm-use-devm-semantics-for-hmm_devmem_add-remove.patch
* mm-hmm-replace-hmm_devmem_pages_create-with-devm_memremap_pages.patch
* mm-hmm-mark-hmm_devmem_add-add_resource-export_symbol_gpl.patch
* mm-hmm-mark-hmm_devmem_add-add_resource-export_symbol_gpl-fix.patch
* mm-page_alloc-free-order-0-pages-through-pcp-in-page_frag_free.patch
* mm-page_alloc-free-order-0-pages-through-pcp-in-page_frag_free-fix.patch
* mm-page_alloc-use-a-single-function-to-free-page.patch
* make-__memblock_free_early-a-wrapper-of-memblock_free-rather-dup-it.patch
* memblock-replace-usage-of-__memblock_free_early-with-memblock_free.patch
* drivers-base-memoryc-remove-an-unnecessary-check-on-nr_mem_sections.patch
* mm-memory_hotplug-drop-online-parameter-from-add_memory_resource.patch
* mm-page_alloc-spread-allocations-across-zones-before-introducing-fragmentation.patch
* mm-move-zone-watermark-accesses-behind-an-accessor.patch
* mm-use-alloc_flags-to-record-if-kswapd-can-wake.patch
* mm-use-alloc_flags-to-record-if-kswapd-can-wake-fix.patch
* mm-reclaim-small-amounts-of-memory-when-an-external-fragmentation-event-occurs.patch
* mm-make-migratetype_names-const-char.patch
* mm-make-migrate_reason_names-const-char.patch
* mm-make-free_reserved_area-return-const-char.patch
* reorganize-the-oom-report-in-dump_header.patch
* add-oom-victims-memcg-to-the-oom-context-information.patch
* mm-put_and_wait_on_page_locked-while-page-is-migrated.patch
* mm-put_and_wait_on_page_locked-while-page-is-migrated-fix.patch
* mm-check-nr_initialised-with-pages_per_section-directly-in-defer_init.patch
* mm-memory_hotplug-add-nid-parameter-to-arch_remove_memory.patch
* kernel-resource-check-for-ioresource_sysram-in-release_mem_region_adjustable.patch
* mm-memory_hotplug-move-zone-pages-handling-to-offline-stage.patch
* mm-memory-hotplug-rework-unregister_mem_sect_under_nodes.patch
* mm-memory_hotplug-refactor-shrink_zone-pgdat_span.patch
* mm-memblock-skip-kmemleak-for-kasan_init.patch
* zram-fix-lockdep-warning-of-free-block-handling.patch
* zram-fix-double-free-backing-device.patch
* zram-refactoring-flags-and-writeback-stuff.patch
* zram-introduce-zram_idle-flag.patch
* zram-support-idle-huge-page-writeback.patch
* zram-add-bd_stat-statistics.patch
* zram-add-bd_stat-statistics-v4.patch
* zram-writeback-throttle.patch
* zram-writeback-throttle-v4.patch
* mm-remove-pte_lock_deinit.patch
* mm-sparse-drop-pgdat_resize_lock-in-sparse_add-remove_one_section.patch
* mm-sparse-drop-pgdat_resize_lock-in-sparse_add-remove_one_section-v4.patch
* mm-sparse-pass-nid-instead-of-pgdat-to-sparse_add_one_section.patch
* mm-hotplug-move-init_currently_empty_zone-under-zone_span_lock-protection.patch
* mm-refactor-swap-in-logic-out-of-shmem_getpage_gfp.patch
* mm-rid-swapoff-of-quadratic-complexity.patch
* mm-rid-swapoff-of-quadratic-complexity-fix-1.patch
* mm-rid-swapoff-of-quadratic-complexity-fix-2.patch
* mm-hmm-remove-set-but-not-used-variable-devmem.patch
* mm-show_mem-drop-pgdat_resize_lock-in-show_mem.patch
* mm-dont-break-integrity-writeback-on-writepage-error.patch
* mm-dont-break-integrity-writeback-on-writepage-error-fix.patch
* mm-page_alloc-drop-uneeded-__meminit-and-__meminitdata.patch
* mm-use-mm_zero_struct_page-from-sparc-on-all-64b-architectures.patch
* mm-drop-meminit_pfn_in_nid-as-it-is-redundant.patch
* mm-implement-new-zone-specific-memblock-iterator.patch
* mm-initialize-max_order_nr_pages-at-a-time-instead-of-doing-larger-sections.patch
* mm-move-hot-plug-specific-memory-init-into-separate-functions-and-optimize.patch
* mm-add-reserved-flag-setting-to-set_page_links.patch
* mm-use-common-iterator-for-deferred_init_pages-and-deferred_free_pages.patch
* mm-use-common-iterator-for-deferred_init_pages-and-deferred_free_pages-fix.patch
* tools-vm-page-typesc-fix-kpagecount-returned-fewer-pages-than-expected-failures.patch
* proc-kpagecount-return-0-for-special-pages-that-are-never-mapped.patch
* proc-kpagecount-return-0-for-special-pages-that-are-never-mapped-v2.patch
* mm-remove-useless-check-in-pagecache_get_page.patch
* mm-page_alloc-calculate-first_deferred_pfn-directly.patch
* ioremap-rework-pxd_free_pyd_page-api.patch
* arm64-mmu-drop-pxd_present-checks-from-pxd_free_pyd_table.patch
* x86-pgtable-drop-pxd_none-checks-from-pxd_free_pyd_table.patch
* lib-ioremap-ensure-phys_addr-actually-corresponds-to-a-physical-address.patch
* lib-ioremap-ensure-break-before-make-is-used-for-huge-p4d-mappings.patch
* mm-kmemleak-little-optimization-while-scanning.patch
* mm-kmemleak-little-optimization-while-scanning-fix.patch
* hwpoison-memory_hotplug-allow-hwpoisoned-pages-to-be-offlined.patch
* mm-mmu_notifier-use-structure-for-invalidate_range_start-end-callback.patch
* mm-mmu_notifier-use-structure-for-invalidate_range_start-end-callback-fix-fix.patch
* mm-mmu_notifier-use-structure-for-invalidate_range_start-end-calls-v2.patch
* mm-mmu_notifier-use-structure-for-invalidate_range_start-end-calls-v3.patch
* mm-mmu_notifier-use-structure-for-invalidate_range_start-end-calls-v2-checkpatch-fixes.patch
* mm-mmu_notifier-contextual-information-for-event-triggering-invalidation-v2.patch
* mm-mmu_notifier-contextual-information-for-event-triggering-invalidation-v2-fix.patch
* memory_hotplug-remove-duplicate-declaration-of-offline_pages.patch
* filemap-kill-page_cache_read-usage-in-filemap_fault.patch
* filemap-kill-page_cache_read-usage-in-filemap_fault-fix.patch
* filemap-pass-vm_fault-to-the-mmap-ra-helpers.patch
* filemap-drop-the-mmap_sem-for-all-blocking-operations.patch
* filemap-drop-the-mmap_sem-for-all-blocking-operations-v6.patch
* filemap-drop-the-mmap_sem-for-all-blocking-operations-checkpatch-fixes.patch
* mm-proc-be-more-verbose-about-unstable-vma-flags-in-proc-pid-smaps.patch
* mm-thp-proc-report-thp-eligibility-for-each-vma.patch
* mm-proc-report-pr_set_thp_disable-in-proc.patch
* mm-memory_hotplug-try-to-migrate-full-pfn-range.patch
* mm-memory_hotplug-deobfuscate-migration-part-of-offlining.patch
* mm-memory_hotplug-deobfuscate-migration-part-of-offlining-fix.patch
* mm-fault_around-do-not-take-a-reference-to-a-locked-page.patch
* mm-memory_hotplug-dont-bail-out-in-do_migrate_range-prematurely.patch
* ksm-react-on-changing-sleep_millisecs-parameter-faster.patch
* mm-pageblock-throw-compiling-time-error-if-pageblock_bits-can-not-hold-migrate_types.patch
* userfaultfd-clear-flag-if-remap-event-not-enabled.patch
* mm-page_alloc-dont-call-kasan_free_pages-at-deferred-mem-init.patch
* mm-memory_hotplug-initialize-struct-pages-for-the-full-memory-section.patch
* kmemleak-add-config-to-select-auto-scan.patch
* mm-page_alloc-enable-pcpu_drain-with-zone-capability.patch
* mm-page_alloc-enable-pcpu_drain-with-zone-capability-fix.patch
* mm-migration-factor-out-code-to-compute-expected-number-of-page-references.patch
* mm-migration-factor-out-code-to-compute-expected-number-of-page-references-fix.patch
* mm-migrate-lock-buffers-before-migrate_page_move_mapping.patch
* mm-migrate-move-migrate_page_lock_buffers.patch
* mm-migrate-provide-buffer_migrate_page_norefs.patch
* mm-migrate-provide-buffer_migrate_page_norefs-fix.patch
* blkdev-avoid-migration-stalls-for-blkdev-pages.patch
* mm-migrate-drop-unused-argument-of-migrate_page_move_mapping.patch
* mm-page_allocc-allow-error-injection.patch
* mm-remove-unused-page-state-adjustment-macro.patch
* mm-remove-__hugepage_set_anon_rmap.patch
* memory_hotplug-add-missing-newlines-to-debugging-output.patch
* memory_hotplug-free-pages-as-higher-order.patch
* memory_hotplug-free-pages-as-higher-order-fix.patch
* memory_hotplug-free-pages-as-higher-order-fix-fix.patch
* mm-page_alloc-remove-software-prefetching-in-__free_pages_core.patch
* mm-swap-fix-race-between-swapoff-and-some-swap-operations.patch
* mm-swap-fix-race-between-swapoff-and-some-swap-operations-v6.patch
* mm-fix-race-between-swapoff-and-mincore.patch
* mm-dont-expose-page-to-fast-gup-before-its-ready.patch
* mm-page_owner-align-with-pageblock_nr_pages.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* info-task-hung-in-generic_file_write_iter.patch
* proc-use-ns_capable-instead-of-capable-for-timerslack_ns.patch
* fs-proc-utilc-include-fs-proc-internalh-for-name_to_int.patch
* proc-delete-unnecessary-variable-in-proc_alloc_inode.patch
* proc-slightly-faster-proc-limits.patch
* proc-sysctl-fix-return-error-for-proc_doulongvec_minmax.patch
* coding-style-dont-use-extern-with-function-prototypes.patch
* build_bugh-remove-negative-array-fallback-for-build_bug_on.patch
* build_bugh-remove-most-of-dummy-build_bug_on-stubs-for-sparse.patch
* kernel-hung_taskc-force-console-verbose-before-panic.patch
* kernel-hung_taskc-break-rcu-locks-based-on-jiffies.patch
* udmabuf-convert-to-use-vm_fault_t.patch
* drop-silly-static-inline-asmlinkage-from-dump_stack.patch
* fls-change-parameter-to-unsigned-int.patch
* lib-genaloc-fix-allocation-of-aligned-buffer-from-non-aligned-chunk.patch
* find_bit_benchmark-align-test_find_next_and_bit-with-others.patch
* checkpatch-warn-on-const-char-foo-=-bar-declarations.patch
* fs-epoll-remove-max_nests-argument-from-ep_call_nested.patch
* fs-epoll-simplify-ep_send_events_proc-ready-list-loop.patch
* fs-epoll-drop-ovflist-branch-prediction.patch
* fs-epoll-robustify-ep-mtx-held-checks.patch
* fs-epoll-reduce-the-scope-of-wq-lock-in-epoll_wait.patch
* fs-epoll-reduce-the-scope-of-wq-lock-in-epoll_wait-fix.patch
* fs-epoll-avoid-barrier-after-an-epoll_wait2-timeout.patch
* fs-epoll-avoid-barrier-after-an-epoll_wait2-timeout-fix.patch
* fs-epoll-rename-check_events-label-to-send_events.patch
* fs-epoll-deal-with-wait_queue-only-once.patch
* fs-epoll-deal-with-wait_queue-only-once-fix.patch
* make-initcall_level_names-const-char.patch
* autofs-improve-ioctl-sbi-checks.patch
* autofs-improve-ioctl-sbi-checks-fix.patch
* autofs-simplify-parse_options-function-call.patch
* autofs-change-catatonic-setting-to-a-bit-flag.patch
* autofs-add-strictexpire-mount-option.patch
* hfsplus-return-file-attributes-on-statx.patch
* fat-replaced-11-magic-to-msdos_name-for-volume-label.patch
* fat-removed-fat_first_ent-macro.patch
* fat-moved-max_fat-to-fath-and-changed-it-to-inline-function.patch
* fat-new-inline-functions-to-determine-the-fat-variant-32-16-or-12.patch
* ptrace-take-into-account-saved_sigmask-in-ptrace_getsetsigmask.patch
* fork-fix-some-wmissing-prototypes-warnings.patch
* exec-load_script-dont-blindly-truncate-shebang-string.patch
* exec-increase-binprm_buf_size-to-256.patch
* exec-separate-mm_anonpages-and-rlimit_stack-accounting.patch
* exec-separate-mm_anonpages-and-rlimit_stack-accounting-fix.patch
* exec-separate-mm_anonpages-and-rlimit_stack-accounting-checkpatch-fixes.patch
* bfs-extra-sanity-checking-and-static-inode-bitmap.patch
* panic-add-options-to-print-system-info-when-panic-happens.patch
* kernel-sysctl-add-panic_print-into-sysctl.patch
* kernel-kcovc-mark-func-write_comp_data-as-notrace.patch
* scripts-gdb-fix-lx-version-string-output.patch
* initramfs-cleanup-incomplete-rootfs.patch
* ipc-allow-boot-time-extension-of-ipcmni-from-32k-to-8m.patch
* ipc-allow-boot-time-extension-of-ipcmni-from-32k-to-8m-checkpatch-fixes.patch
* ipc-conserve-sequence-numbers-in-extended-ipcmni-mode.patch
  linux-next.patch
  linux-next-rejects.patch
* scripts-atomic-check-atomicssh-dont-assume-that-scripts-are-executable.patch
* lib-fix-build-failure-in-config_debug_virtual-test.patch
* mm-treewide-remove-unused-address-argument-from-pte_alloc-functions-v2.patch
* mm-treewide-remove-unused-address-argument-from-pte_alloc-functions-v2-fix.patch
* mm-speed-up-mremap-by-20x-on-large-regions-v5.patch
* mm-speed-up-mremap-by-20x-on-large-regions-v5-fix.patch
* mm-select-have_move_pmd-in-x86-for-faster-mremap.patch
* async-remove-some-duplicated-includes.patch
* signal-remove-some-duplicated-includes.patch
* locking-atomics-build-atomic-headers-as-required.patch
* mm-balloon-update-comment-about-isolation-migration-compaction.patch
* mm-convert-pg_balloon-to-pg_offline.patch
* mm-convert-pg_balloon-to-pg_offline-fix.patch
* kexec-export-pg_offline-to-vmcoreinfo.patch
* xen-balloon-mark-inflated-pages-pg_offline.patch
* hv_balloon-mark-inflated-pages-pg_offline.patch
* vmw_balloon-mark-inflated-pages-pg_offline.patch
* vmw_balloon-mark-inflated-pages-pg_offline-v2.patch
* pm-hibernate-use-pfn_to_online_page.patch
* pm-hibernate-exclude-all-pageoffline-pages.patch
* pm-hibernate-exclude-all-pageoffline-pages-v2.patch
* locking-mutex-remove-caller-signal_pending-branch-predictions.patch
* kernel-sched-remove-caller-signal_pending-branch-predictions.patch
* arch-arc-remove-caller-signal_pending_branch-predictions.patch
* mm-remove-caller-signal_pending-branch-predictions.patch
* fs-remove-caller-signal_pending-branch-predictions.patch
* fs-remove-caller-signal_pending-branch-predictions-fix.patch
* include-replace-tsk-to-task-in-linux-sched-signalh.patch
* fs-dont-opencode-lru_to_page.patch
* drivers-base-kmemleak-ignore-a-known-leak.patch
* docs-fix-co-developed-by-docs.patch
* checkpatch-add-co-developed-by-to-signature-tags.patch
* mm-fix-polled-swap-page-in.patch
* fork-remove-duplicated-include-from-forkc.patch
* fix-read-buffer-overflow-in-delta-ipc.patch
* openvswitch-convert-to-kvmalloc.patch
* md-convert-to-kvmalloc.patch
* selinux-convert-to-kvmalloc.patch
* generic-radix-trees.patch
* proc-commit-to-genradix.patch
* sctp-convert-to-genradix.patch
* drop-flex_arrays.patch
  make-sure-nobodys-leaking-resources.patch
  releasing-resources-with-children.patch
  mutex-subsystem-synchro-test-module.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  slab-leaks3-default-y.patch
  workaround-for-a-pci-restoring-bug.patch
