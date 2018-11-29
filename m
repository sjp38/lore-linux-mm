Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id BC3B86B54B2
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 16:38:28 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id 12so2522815plb.18
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 13:38:28 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a18si2970045pgj.77.2018.11.29.13.38.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Nov 2018 13:38:26 -0800 (PST)
Date: Thu, 29 Nov 2018 13:38:22 -0800
From: akpm@linux-foundation.org
Subject: mmotm 2018-11-29-13-37 uploaded
Message-ID: <20181129213822.EbBH1%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org

The mm-of-the-moment snapshot 2018-11-29-13-37 has been uploaded to

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


This mmotm tree contains the following patches against 4.20-rc4:
(patches marked "*" will be included in linux-next)

  origin.patch
* alpha-fix-hang-caused-by-the-bootmem-removal.patch
* maintainers-update-name-change-for-myself.patch
* mm-gup-finish-consolidating-error-handling.patch
* sh-provide-prototypes-for-pci-i-o-mapping-in-asm-ioh.patch
* mm-thp-always-specify-disabled-vmas-as-nh-in-smaps.patch
* ocfs2-fix-dead-lock-caused-by-ocfs2_defrag_extent.patch
* mm-cleancache-fix-corruption-on-missed-inode-invalidation.patch
* mm-cleancache-fix-corruption-on-missed-inode-invalidation-fix.patch
* mm-use-swp_offset-as-key-in-shmem_replace_page.patch
* mm-page_alloc-fix-calculation-of-pgdat-nr_zones.patch
* proc-update-maintainers-with-proctxt.patch
* hfs-do-not-free-node-before-using.patch
* hfsplus-do-not-free-node-before-using.patch
* test_kmod-fix-rmmod-double-free.patch
* userfaultfd-use-enoent-instead-of-efault-if-the-atomic-copy-user-fails.patch
* userfaultfd-shmem-allocate-anonymous-memory-for-map_private-shmem.patch
* userfaultfd-shmem-hugetlbfs-only-allow-to-register-vm_maywrite-vmas.patch
* userfaultfd-shmem-add-i_size-checks.patch
* userfaultfd-shmem-uffdio_copy-set-the-page-dirty-if-vm_write-is-not-set.patch
* debugobjects-avoid-recursive-calls-with-kmemleak.patch
* proc-fixup-map_files-test-on-arm.patch
* psi-make-disabling-enabling-easier-for-vendor-kernels.patch
* kernel-kcovc-mark-funcs-in-__sanitizer_cov_trace_pc-as-notrace.patch
* vmalloc-new-flag-for-flush-before-releasing-pages.patch
* x86-modules-make-x86-allocs-to-flush-when-free.patch
* initramfs-clean-old-path-before-creating-a-hardlink.patch
* initramfs-clean-old-path-before-creating-a-hardlink-fix.patch
* mm-huge_memory-rename-freeze_page-to-unmap_page.patch
* mm-huge_memory-splitting-set-mappingindex-before-unfreeze.patch
* mm-huge_memory-fix-lockdep-complaint-on-32-bit-i_size_read.patch
* mm-khugepaged-collapse_shmem-stop-if-punched-or-truncated.patch
* mm-khugepaged-fix-crashes-due-to-misaccounted-holes.patch
* mm-khugepaged-collapse_shmem-remember-to-clear-holes.patch
* mm-khugepaged-minor-reorderings-in-collapse_shmem.patch
* mm-khugepaged-collapse_shmem-without-freezing-new_page.patch
* mm-khugepaged-collapse_shmem-do-not-crash-on-compound.patch
* mm-khugepaged-fix-the-xas_create_range-error-path.patch
* ocfs2-fix-potential-use-after-free.patch
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
* arch-sh-mach-kfr2r09-fix-struct-mtd_oob_ops-build-warning.patch
* debugobjects-call-debug_objects_mem_init-eariler.patch
* ocfs2-optimize-the-reading-of-heartbeat-data.patch
* ocfs2-dlmfs-remove-set-but-not-used-variable-status.patch
* ocfs2-remove-set-but-not-used-variable-lastzero.patch
* ocfs2-improve-ocfs2-makefile.patch
* ocfs2-fix-panic-due-to-unrecovered-local-alloc.patch
* ocfs2-clear-journal-dirty-flag-after-shutdown-journal.patch
* ocfs2-dont-clear-bh-uptodate-for-block-read.patch
* ocfs2-clear-zero-in-unaligned-direct-io.patch
* ocfs2-clear-zero-in-unaligned-direct-io-checkpatch-fixes.patch
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
* mm-use-mm_zero_struct_page-from-sparc-on-all-64b-architectures.patch
* mm-drop-meminit_pfn_in_nid-as-it-is-redundant.patch
* mm-implement-new-zone-specific-memblock-iterator.patch
* mm-initialize-max_order_nr_pages-at-a-time-instead-of-doing-larger-sections.patch
* mm-move-hot-plug-specific-memory-init-into-separate-functions-and-optimize.patch
* mm-add-reserved-flag-setting-to-set_page_links.patch
* mm-use-common-iterator-for-deferred_init_pages-and-deferred_free_pages.patch
* writeback-dont-decrement-wb-refcnt-if-wb-bdi.patch
* mm-simplify-get_next_ra_size.patch
* mm-vmscan-skip-ksm-page-in-direct-reclaim-if-priority-is-low.patch
* mm-ksm-do-not-block-on-page-lock-when-searching-stable-tree.patch
* mm-ksm-do-not-block-on-page-lock-when-searching-stable-tree-fix.patch
* mm-print-more-information-about-mapping-in-__dump_page.patch
* mm-print-more-information-about-mapping-in-__dump_page-fix.patch
* mm-print-more-information-about-mapping-in-__dump_page-fix-2.patch
* mm-lower-the-printk-loglevel-for-__dump_page-messages.patch
* mm-memory_hotplug-drop-pointless-block-alignment-checks-from-__offline_pages.patch
* mm-memory_hotplug-print-reason-for-the-offlining-failure.patch
* mm-memory_hotplug-print-reason-for-the-offlining-failure-fix.patch
* mm-memory_hotplug-be-more-verbose-for-memory-offline-failures.patch
* mm-memory_hotplug-be-more-verbose-for-memory-offline-failures-fix.patch
* mm-memory_hotplug-be-more-verbose-for-memory-offline-failures-update.patch
* xxhash-create-arch-dependent-32-64-bit-xxhash.patch
* ksm-replace-jhash2-with-xxhash.patch
* mm-treewide-remove-unused-address-argument-from-pte_alloc-functions-v2.patch
* mm-speed-up-mremap-by-20x-on-large-regions-v5.patch
* mm-speed-up-mremap-by-20x-on-large-regions-v5-fix.patch
* mm-select-have_move_pmd-in-x86-for-faster-mremap.patch
* mm-mmap-remove-verify_mm_writelocked.patch
* mm-memory_hotplug-do-not-clear-numa_node-association-after-hot_remove.patch
* mm-add-an-f_seal_future_write-seal-to-memfd.patch
* mm-add-an-f_seal_future_write-seal-to-memfd-fix.patch
* mm-add-an-f_seal_future_write-seal-to-memfd-fix-2.patch
* selftests-memfd-add-tests-for-f_seal_future_write-seal.patch
* selftests-memfd-add-tests-for-f_seal_future_write-seal-fix.patch
* mm-remove-reset-of-pcp-counter-in-pageset_init.patch
* ksm-assist-buddy-allocator-to-assemble-1-order-pages.patch
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
* mm-stall-movable-allocations-until-kswapd-progresses-during-serious-external-fragmentation-event.patch
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
* zram-writeback-throttle.patch
* mm-remove-pte_lock_deinit.patch
* mm-sparse-drop-pgdat_resize_lock-in-sparse_add-remove_one_section.patch
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
* coding-style-dont-use-extern-with-function-prototypes.patch
* kernelh-disable-type-checks-in-container_of-for-sparse.patch
* build_bugh-remove-negative-array-fallback-for-build_bug_on.patch
* build_bugh-remove-most-of-dummy-build_bug_on-stubs-for-sparse.patch
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
* autofs-fix-possible-inode-leak-in-autofs_fill_super.patch
* autofs-simplify-parse_options-function-call.patch
* autofs-change-catatonic-setting-to-a-bit-flag.patch
* autofs-add-strictexpire-mount-option.patch
* hfsplus-return-file-attributes-on-statx.patch
* fat-replaced-11-magic-to-msdos_name-for-volume-label.patch
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
* scripts-gdb-fix-lx-version-string-output.patch
* initramfs-cleanup-incomplete-rootfs.patch
* ipc-allow-boot-time-extension-of-ipcmni-from-32k-to-8m.patch
* ipc-allow-boot-time-extension-of-ipcmni-from-32k-to-8m-checkpatch-fixes.patch
* ipc-conserve-sequence-numbers-in-extended-ipcmni-mode.patch
  linux-next.patch
  linux-next-git-rejects.patch
* scripts-atomic-check-atomicssh-dont-assume-that-scripts-are-executable.patch
* async-remove-some-duplicated-includes.patch
* signal-remove-some-duplicated-includes.patch
* locking-atomics-build-atomic-headers-as-required.patch
* mm-replace-all-open-encodings-for-numa_no_node.patch
* mm-introduce-common-struct_page_max_shift-define.patch
* mm-sparse-add-common-helper-to-mark-all-memblocks-present.patch
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
* lib-lzo-tidy-up-ifdefs.patch
* lib-lzo-clean-up-by-introducing-copy16.patch
* lib-lzo-enable-64-bit-ctz-on-arm.patch
* lib-lzo-64-bit-ctz-on-arm64.patch
* lib-lzo-fast-8-byte-copy-on-arm64.patch
* lib-lzo-implement-run-length-encoding.patch
* lib-lzo-separate-lzo-rle-from-lzo.patch
* locking-mutex-remove-caller-signal_pending-branch-predictions.patch
* kernel-sched-remove-caller-signal_pending-branch-predictions.patch
* arch-arc-remove-caller-signal_pending_branch-predictions.patch
* mm-remove-caller-signal_pending-branch-predictions.patch
* fs-remove-caller-signal_pending-branch-predictions.patch
* fs-remove-caller-signal_pending-branch-predictions-fix.patch
* include-replace-tsk-to-task-in-linux-sched-signalh.patch
* fs-dont-opencode-lru_to_page.patch
* vfs-replace-current_kernel_time64-with-ktime-equivalent.patch
* fix-read-buffer-overflow-in-delta-ipc.patch
  make-sure-nobodys-leaking-resources.patch
  releasing-resources-with-children.patch
  mutex-subsystem-synchro-test-module.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  slab-leaks3-default-y.patch
  workaround-for-a-pci-restoring-bug.patch
