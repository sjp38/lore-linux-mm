Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BFAC96B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 20:00:18 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e14so45571pfi.9
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 17:00:18 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u2si6768392pfm.402.2018.04.05.17.00.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Apr 2018 17:00:14 -0700 (PDT)
Date: Thu, 05 Apr 2018 17:00:09 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2018-04-05-16-59 uploaded
Message-ID: <20180406000009.l1ebV%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org

The mm-of-the-moment snapshot 2018-04-05-16-59 has been uploaded to

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


This mmotm tree contains the following patches against 4.16:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
* zboot-fix-stack-protector-in-compressed-boot-phase.patch
* hugetlbfs-fix-bug-in-pgoff-overflow-checking.patch
* lib-fix-stall-in-__bitmap_parselist.patch
* scripts-faddr2line-show-the-code-context.patch
* ocfs2-use-osb-instead-of-ocfs2_sb.patch
* ocfs2-use-oi-instead-of-ocfs2_i.patch
* ocfs2-clean-up-some-unused-function-declaration.patch
* ocfs2-keep-the-trace-point-consistent-with-the-function-name.patch
* ocfs2-dlm-dont-handle-migrate-lockres-if-already-in-shutdown.patch
* ocfs2-remove-unnecessary-null-pointer-check-before-kmem_cache_destroy.patch
* ocfs2-clean-up-two-unused-functions-in-suballocc.patch
* ocfs2-dlm-clean-unrelated-comment.patch
* ocfs2-dlm-clean-up-unused-argument-for-dlm_destroy_recovery_area.patch
* ocfs2-dlm-clean-up-unused-stack-variable-in-dlm_do_local_ast.patch
* ocfs2-dlm-wait-for-dlm-recovery-done-when-migrating-all-lock-resources.patch
* ocfs2-fix-spelling-mistake-migrateable-migratable.patch
* ocfs2-correct-spelling-mistake-for-migratable-for-all.patch
* ocfs2-move-some-definitions-to-header-file.patch
* ocfs2-fix-some-small-problems.patch
* ocfs2-add-kobject-for-online-file-check.patch
* ocfs2-add-duplicative-ino-number-check.patch
* ocfs2-o2hb-check-len-for-bio_add_page-to-avoid-getting-incorrect-bio.patch
* ocfs2-dlm-clean-up-unused-variable-in-dlm_process_recovery_data.patch
* net-9p-avoid-erestartsys-leak-to-userspace.patch
* 9p-dont-maintain-dir-i_nlink-if-the-exported-fs-doesnt-either.patch
* 9p-check-memory-allocation-result-for-cachetag.patch
* fs-9p-dont-set-sb_noatime-by-default.patch
* net-9p-fix-potential-refcnt-problem-of-trans-module.patch
* fs-dont-flush-pagecache-when-expanding-block-device.patch
* slab-mark-kmalloc-machinery-as-__ro_after_init.patch
* slub-use-jitter-free-reference-while-printing-age.patch
* slab-fixup-calculate_alignment-argument-type.patch
* slab-make-kmalloc_index-return-unsigned-int.patch
* slab-make-kmalloc_size-return-unsigned-int.patch
* slab-make-create_kmalloc_cache-work-with-32-bit-sizes.patch
* slab-make-create_boot_cache-work-with-32-bit-sizes.patch
* slab-make-kmem_cache_create-work-with-32-bit-sizes.patch
* slab-make-size_index-array-u8.patch
* slab-make-size_index_elem-unsigned-int.patch
* slub-make-remote_node_defrag_ratio-unsigned-int.patch
* slub-make-max_attr_size-unsigned-int.patch
* slub-make-red_left_pad-unsigned-int.patch
* slub-make-reserved-unsigned-int.patch
* slub-make-align-unsigned-int.patch
* slub-make-inuse-unsigned-int.patch
* slub-make-cpu_partial-unsigned-int.patch
* slub-make-offset-unsigned-int.patch
* slub-make-object_size-unsigned-int.patch
* slub-make-size-unsigned-int.patch
* slab-make-kmem_cache_flags-accept-32-bit-object-size.patch
* kasan-make-kasan_cache_create-work-with-32-bit-slab-cache-sizes.patch
* slab-make-usercopy-region-32-bit.patch
* slub-make-slab_index-return-unsigned-int.patch
* slub-make-struct-kmem_cache_order_objects-x-unsigned-int.patch
* slub-make-size_from_object-return-unsigned-int.patch
* slab-use-32-bit-arithmetic-in-freelist_randomize.patch
* slab-slub-remove-size-disparity-on-debug-kernel.patch
* slab_common-remove-test-if-cache-name-is-accessible.patch
* slab-slub-skip-unnecessary-kasan_cache_shutdown.patch
* mm-ksm-make-function-stable_node_dup-static.patch
* mm-always-print-rlimit_data-warning.patch
* mm-migrate-change-migration-reason-mr_cma-as-mr_contig_range.patch
* mm-hugetlbfs-move-hugetlbfs_i-outside-ifdef-config_hugetlbfs.patch
* mm-memfd-split-out-memfd-for-use-by-multiple-filesystems.patch
* mm-memfd-remove-memfd-code-from-shmem-files-and-use-new-memfd-files.patch
* mm-swap_slots-use-conditional-compilation-for-swap_slotsc.patch
* mm-disable-interrupts-while-initializing-deferred-pages.patch
* mm-initialize-pages-on-demand-during-boot.patch
* mm-thp-fix-potential-clearing-to-referenced-flag-in-page_idle_clear_pte_refs_one.patch
* mm-memory_hotplug-enforce-block-size-aligned-range-check.patch
* x86-mm-memory_hotplug-determine-block-size-based-on-the-end-of-boot-memory.patch
* mm-uninitialized-struct-page-poisoning-sanity-checking.patch
* mm-memory_hotplug-optimize-probe-routine.patch
* mm-memory_hotplug-dont-read-nid-from-struct-page-during-hotplug.patch
* mm-memory_hotplug-optimize-memory-hotplug.patch
* mm-hwpoison-disable-memory-error-handling-on-1gb-hugepage.patch
* mm-page_alloc-extend-kernelcore-and-movablecore-for-percent.patch
* mm-page_alloc-move-mirrored_kernelcore-to-__meminitdata.patch
* mm-re-use-define_show_attribute-macro.patch
* mm-fix-races-between-address_space-dereference-and-free-in-page_evicatable.patch
* mm-page_ref-use-atomic_set_release-in-page_ref_unfreeze.patch
* mm-huge_memoryc-reorder-operations-in-__split_huge_page_tail.patch
* z3fold-limit-use-of-stale-list-for-allocation.patch
* mmvmscan-dont-pretend-forward-progress-upon-shrinker_rwsem-contention.patch
* mm-swap-clean-up-swap-readahead.patch
* mm-swap-unify-cluster-based-and-vma-based-swap-readahead.patch
* mm-kmemleak-make-kmemleak_boot_config-__init.patch
* mm-page_owner-make-early_page_owner_param-__init.patch
* mm-page_poison-make-early_page_poison_param-__init.patch
* mm-make-should_failslab-always-available-for-fault-injection.patch
* mm-compaction-drain-pcps-for-zone-when-kcompactd-fails.patch
* mm-free_pcppages_bulk-update-pcp-count-inside.patch
* mm-free_pcppages_bulk-do-not-hold-lock-when-picking-pages-to-free.patch
* mm-free_pcppages_bulk-prefetch-buddy-while-not-holding-lock.patch
* mm-gupc-fixed-coding-style-issues.patch
* mm-powerpc-use-vma_kernel_pagesize-in-vma_mmu_pagesize.patch
* mm-hugetlbfs-introduce-pagesize-to-vm_operations_struct.patch
* device-dax-implement-pagesize-for-smaps-to-report-mmupagesize.patch
* mm-provide-consistent-declaration-for-num_poisoned_pages.patch
* direct-io-minor-cleanups-in-do_blockdev_direct_io.patch
* mm-fix-races-between-swapoff-and-flush-dcache.patch
* zsmalloc-introduce-zs_huge_class_size-function.patch
* zram-drop-max_zpage_size-and-use-zs_huge_class_size.patch
* mm-nommu-remove-description-of-alloc_vm_area.patch
* mm-swap-remove-cold-parameter-description-for-release_pages.patch
* mm-kernel-doc-add-missing-parameter-descriptions.patch
* block_invalidatepage-only-release-page-if-the-full-page-was-invalidated.patch
* mm-swap-make-bool-enable_vma_readahead-and-function-swap_vma_readahead-static.patch
* mm-make-count-list_lru_one-nr_items-lockless.patch
* detect-early-free-of-a-live-mm.patch
* mm-page_alloc-wakeup-kcompactd-even-if-kswapd-cannot-free-more-memory.patch
* mm-oom-remove-3%-bonus-for-cap_sys_admin-processes.patch
* mm-change-return-type-to-vm_fault_t.patch
* mm-make-start_isolate_page_range-fail-if-already-isolated.patch
* include-linux-mmdebugh-make-vm_warn-non-rvals.patch
* headers-untangle-kmemleakh-from-mmh.patch
* mm-memblock-cast-constant-ullong_max-to-phys_addr_t.patch
* mm-ksm-fix-interaction-with-thp.patch
* mmoom_reaper-check-for-mmf_oom_skip-before-complain.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* prctl-add-pr_et_pdeathsig_proc.patch
* ocfs2-get-rid-of-ocfs2_is_o2cb_active-function.patch
* ocfs2-without-quota-support-try-to-avoid-calling-quota-recovery.patch
* ocfs2-without-quota-support-try-to-avoid-calling-quota-recovery-checkpatch-fixes.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* dentry-fix-kmemcheck-splat-at-take_dentry_name_snapshot.patch
  mm.patch
* mm-sparse-add-a-static-variable-nr_present_sections.patch
* mm-sparsemem-defer-the-ms-section_mem_map-clearing.patch
* mm-sparse-add-a-new-parameter-data_unit_size-for-alloc_usemap_and_memmap.patch
* mm-introduce-nr_indirectly_reclaimable_bytes.patch
* mm-treat-indirectly-reclaimable-memory-as-available-in-memavailable.patch
* dcache-account-external-names-as-indirectly-reclaimable-memory.patch
* dcache-account-external-names-as-indirectly-reclaimable-memory-fix.patch
* dcache-account-external-names-as-indirectly-reclaimable-memory-fix-2.patch
* mm-treat-indirectly-reclaimable-memory-as-free-in-overcommit-logic.patch
* mm-vmscan-update-stale-comments.patch
* mm-vmscan-remove-redundant-current_may_throttle-check.patch
* mm-vmscan-dont-change-pgdat-state-on-base-of-a-single-lru-list-state-v2.patch
* mm-vmscan-dont-mess-with-pgdat-flags-in-memcg-reclaim-v2.patch
* mm-vmscan-tracing-use-pointer-to-reclaim_stat-struct-in-trace-event.patch
* mm-hmm-documentation-editorial-update-to-hmm-documentation.patch
* mm-hmm-fix-header-file-if-else-endif-maze-v2.patch
* mm-hmm-hmm-should-have-a-callback-before-mm-is-destroyed-v3.patch
* mm-hmm-unregister-mmu_notifier-when-last-hmm-client-quit-v3.patch
* mm-hmm-hmm_pfns_bad-was-accessing-wrong-struct.patch
* mm-hmm-use-struct-for-hmm_vma_fault-hmm_vma_get_pfns-parameters-v2.patch
* mm-hmm-remove-hmm_pfn_read-flag-and-ignore-peculiar-architecture-v2.patch
* mm-hmm-use-uint64_t-for-hmm-pfn-instead-of-defining-hmm_pfn_t-to-ulong-v2.patch
* mm-hmm-cleanup-special-vma-handling-vm_special.patch
* mm-hmm-do-not-differentiate-between-empty-entry-or-missing-directory-v3.patch
* mm-hmm-rename-hmm_pfn_device_unaddressable-to-hmm_pfn_device_private.patch
* mm-hmm-move-hmm_pfns_clear-closer-to-where-it-is-use.patch
* mm-hmm-factor-out-pte-and-pmd-handling-to-simplify-hmm_vma_walk_pmd-v2.patch
* mm-hmm-change-hmm_vma_fault-to-allow-write-fault-on-page-basis.patch
* mm-hmm-use-device-driver-encoding-for-hmm-pfn-v2.patch
* mm-hmm-use-device-driver-encoding-for-hmm-pfn-v2-fix.patch
* mm-hmm-use-device-driver-encoding-for-hmm-pfn-v2-fix-2.patch
* hmm-remove-superflous-rcu-protection-around-radix-tree-lookup.patch
* mm-hmm-fix-header-file-if-else-endif-maze-again.patch
* sched-numa-avoid-trapping-faults-and-attempting-migration-of-file-backed-dirty-pages.patch
* mm-check-__highest_present_sectioin_nr-directly-in-memory_dev_init.patch
* mm-migrate-properly-preserve-write-attribute-in-special-migrate-entry.patch
* memcg-thp-do-not-invoke-oom-killer-on-thp-charges.patch
* z3fold-fix-memory-leak.patch
* z3fold-fix-memory-leak-fix.patch
* mm-ksm-fix-inconsistent-accounting-of-zero-pages.patch
* mm-memcg-make-sure-memoryevents-is-uptodate-when-waking-pollers.patch
* mm-swap-fix-race-between-swapoff-and-some-swap-operations.patch
* mm-swap-fix-race-between-swapoff-and-some-swap-operations-v6.patch
* mm-fix-race-between-swapoff-and-mincore.patch
* mmvmscan-mark-register_shrinker-as-__must_check.patch
* list_lru-prefetch-neighboring-list-entries-before-acquiring-lock.patch
* list_lru-prefetch-neighboring-list-entries-before-acquiring-lock-fix.patch
* mm-oom-refactor-the-oom_kill_process-function.patch
* mm-implement-mem_cgroup_scan_tasks-for-the-root-memory-cgroup.patch
* mm-oom-cgroup-aware-oom-killer.patch
* mm-oom-cgroup-aware-oom-killer-fix.patch
* mm-oom-introduce-memoryoom_group.patch
* mm-oom-introduce-memoryoom_group-fix.patch
* mm-oom-add-cgroup-v2-mount-option-for-cgroup-aware-oom-killer.patch
* mm-oom-docs-describe-the-cgroup-aware-oom-killer.patch
* mm-oom-docs-describe-the-cgroup-aware-oom-killer-fix.patch
* mm-oom-docs-describe-the-cgroup-aware-oom-killer-fix-2.patch
* mm-oom-docs-describe-the-cgroup-aware-oom-killer-fix-2-fix.patch
* cgroup-list-groupoom-in-cgroup-features.patch
* mm-add-strictlimit-knob-v2.patch
* mm-page_alloc-dont-reserve-zone_highmem-for-zone_movable-request.patch
* mm-cma-manage-the-memory-of-the-cma-area-by-using-the-zone_movable.patch
* mm-cma-remove-alloc_cma.patch
* arm-cma-avoid-double-mapping-to-the-cma-area-if-config_highmem-=-y.patch
* mm-thp-dont-count-zone_movable-as-the-target-for-freepage-reserving.patch
* mm-dont-expose-page-to-fast-gup-before-its-ready.patch
* mm-swap-make-pointer-swap_avail_heads-static.patch
* mm-numa-rework-do_pages_move.patch
* mm-migrate-remove-reason-argument-from-new_page_t.patch
* mm-unclutter-thp-migration.patch
* mm-page_owner-align-with-pageblock_nr_pages.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* kasan-slub-fix-handling-of-kasan_slab_free-hook.patch
* kasan-slub-fix-handling-of-kasan_slab_free-hook-v2.patch
* kasan-fix-invalid-free-test-crashing-the-kernel.patch
* kasan-disallow-compiler-to-optimize-away-memset-in-tests.patch
* mm-kasan-dont-vfree-nonexistent-vm_area.patch
* procfs-add-seq_put_hex_ll-to-speed-up-proc-pid-maps.patch
* procfs-add-seq_put_hex_ll-to-speed-up-proc-pid-maps-v3.patch
* procfs-optimize-seq_pad-to-speed-up-proc-pid-maps.patch
* proc-get-rid-of-task-lock-unlock-pair-to-read-umask-for-the-status-file.patch
* proc-do-less-stuff-under-pde_unload_lock.patch
* proc-move-proc-sysvipc-creation-to-where-it-belongs.patch
* proc-faster-open-close-of-files-without-release-hook.patch
* proc-randomize-struct-pde_opener.patch
* proc-move-struct-pde_opener-to-kmem-cache.patch
* proc-account-struct-pde_opener.patch
* proc-add-seq_put_decimal_ull_width-to-speed-up-proc-pid-smaps.patch
* proc-add-seq_put_decimal_ull_width-to-speed-up-proc-pid-smaps-fix.patch
* proc-replace-seq_printf-on-seq_putc-to-speed-up-proc-pid-smaps.patch
* proc-optimize-single-symbol-delimiters-to-spead-up-seq_put_decimal_ull.patch
* proc-replace-seq_printf-by-seq_put_smth-to-speed-up-proc-pid-status.patch
* proc-check-permissions-earlier-for-proc-wchan.patch
* proc-use-set_puts-at-proc-wchan.patch
* fs-sysctl-fix-potential-page-fault-while-unregistering-sysctl-table.patch
* fs-sysctl-remove-redundant-link-check-in-proc_sys_link_fill_cache.patch
* proc-test-proc-self-wchan.patch
* proc-test-proc-self-syscall.patch
* proc-move-struct-proc_dir_entry-into-kmem-cache.patch
* proc-fix-proc-map_files-lookup-some-more.patch
* proc-register-filesystem-last.patch
* proc-faster-proc-cmdline.patch
* proc-do-mmput-asap-for-proc-map_files.patch
* proc-revalidate-misc-dentries.patch
* proc-test-last-field-of-proc-loadavg.patch
* proc-reject-and-as-filenames.patch
* proc-switch-struct-proc_dir_entry-count-to-refcount.patch
* proc-shotgun-test-read-readdir-readlink-a-little-write.patch
* proc-shotgun-test-read-readdir-readlink-a-little-write-fix.patch
* proc-shotgun-test-read-readdir-readlink-a-little-write-fix-2.patch
* proc-use-slower-rb_first.patch
* proc-test-proc-uptime.patch
* taint-convert-to-indexed-initialization.patch
* taint-consolidate-documentation.patch
* taint-add-taint-for-randstruct.patch
* uts-create-struct-uts_namespace-from-kmem_cache.patch
* clang-format-add-configuration-file.patch
* kernelh-introduce-const_max-for-vla-removal.patch
* remove-false-positive-vlas-when-using-max.patch
* task_struct-only-use-anon-struct-under-randstruct-plugin.patch
* maintainers-update-email-address-for-alexandre-bounine.patch
* lib-kconfigdebug-debug-lockups-and-hangs-keep-softlockup-options-together.patch
* test_bitmap-do-not-accidentally-use-stack-vla.patch
* lib-add-testing-module-for-ubsan.patch
* lib-add-testing-module-for-ubsan-fix.patch
* list_debug-print-unmangled-addresses.patch
* rslib-remove-vlas-by-setting-upper-bound-on-nroots.patch
* checkpatch-improve-parse_email-signature-checking.patch
* checkpatchpl-add-spdx-license-tag-check.patch
* checkpatch-add-crypto-on_stack-to-declaration_macros.patch
* checkpatch-add-sub-routine-get_stat_real.patch
* checkpatch-remove-unused-variable-declarations.patch
* checkpatch-add-sub-routine-get_stat_here.patch
* checkpatch-warn-for-use-of-%px.patch
* checkpatch-improve-get_quoted_string-for-trace_event-macros.patch
* checkpatch-two-spelling-fixes.patch
* checkpatch-test-symbolic_perms-multiple-times-per-line.patch
* checkpatch-add-test-for-assignment-at-start-of-line.patch
* checkpatch-allow-space-between-colon-and-bracket.patch
* init-ramdisk-use-pr_cont-at-the-end-of-ramdisk-loading.patch
* autofs4-use-wait_event_killable.patch
* autofs4-use-wait_event_killable-fix.patch
* fs-reiserfs-journalc-add-missing-resierfs_warning-arg.patch
* seq_file-allocate-seq_file-from-kmem_cache.patch
* seq_file-account-everything.patch
* seq_file-delete-small-value-optimization.patch
* fork-unconditionally-clear-stack-on-fork.patch
* exec-pass-stack-rlimit-into-mm-layout-functions.patch
* exec-introduce-finalize_exec-before-start_thread.patch
* exec-pin-stack-limit-during-exec.patch
* rapidio-fix-typo-in-comment.patch
* sysctl-fix-sizeof-argument-to-match-variable-name.patch
* exofs-avoid-vla-in-structures.patch
* kernel-downgrade-warning-for-unsafe-parameters.patch
* ipc-shm-introduce-shmctlshm_stat_any.patch
* ipc-sem-introduce-semctlsem_stat_any.patch
* ipc-msg-introduce-msgctlmsg_stat_any.patch
* proc-sysctl-fix-typo-in-sysctl_check_table_array.patch
* sysctl-add-kdoc-comments-to-do_proc_douintvec_minmax_conv_param.patch
* ipc-shmc-shm_split-remove-unneeded-test-for-null-shm_file_datavm_ops.patch
  linux-next.patch
  linux-next-rejects.patch
  linux-next-git-rejects.patch
  linux-next-fixup.patch
* kfifo-fix-comment.patch
* dcache-add-cond_resched-in-shrink_dentry_list.patch
* maintainers-update-bouncing-aacraid-adapteccom-addresses.patch
* kexec_file-make-an-use-of-purgatory-optional.patch
* kexec_file-make-an-use-of-purgatory-optional-fix.patch
* kexec_filex86powerpc-factor-out-kexec_file_ops-functions.patch
* x86-kexec_file-purge-system-ram-walking-from-prepare_elf64_headers.patch
* x86-kexec_file-remove-x86_64-dependency-from-prepare_elf64_headers.patch
* x86-kexec_file-lift-crash_max_ranges-limit-on-crash_mem-buffer.patch
* x86-kexec_file-clean-up-prepare_elf64_headers.patch
* kexec_file-x86-move-re-factored-code-to-generic-side.patch
* kexec_file-silence-compile-warnings.patch
* kexec_file-remove-checks-in-kexec_purgatory_load.patch
* kexec_file-make-purgatory_info-ehdr-const.patch
* kexec_file-search-symbols-in-read-only-kexec_purgatory.patch
* kexec_file-use-read-only-sections-in-arch_kexec_apply_relocations.patch
* kexec_file-split-up-__kexec_load_puragory.patch
* kexec_file-remove-unneeded-for-loop-in-kexec_purgatory_setup_sechdrs.patch
* kexec_file-remove-unneeded-variables-in-kexec_purgatory_setup_sechdrs.patch
* kexec_file-remove-mis-use-of-sh_offset-field-during-purgatory-load.patch
* kexec_file-allow-archs-to-set-purgatory-load-address.patch
* kexec_file-move-purgatories-sha256-to-common-code.patch
* resource-add-walk_system_ram_res_rev.patch
* kexec_file-load-kernel-at-top-of-system-ram-if-required.patch
* mm-introduce-map_fixed_safe.patch
* fs-elf-drop-map_fixed-usage-from-elf_map.patch
* elf-enforce-map_fixed-on-overlaying-elf-segments.patch
* xen-mm-allow-deferred-page-initialization-for-xen-pv-domains.patch
* linux-consth-prefix-include-guard-of-uapi-linux-consth-with-_uapi.patch
* linux-consth-move-ul-macro-to-include-linux-consth.patch
* linux-consth-refactor-_bitul-and-_bitull-a-bit.patch
* mm-memcg-remote-memcg-charging-for-kmem-allocations.patch
* mm-memcg-remote-memcg-charging-for-kmem-allocations-fix.patch
* fs-fsnotify-account-fsnotify-metadata-to-kmemcg.patch
* fs-fsnotify-account-fsnotify-metadata-to-kmemcg-fix.patch
* radix-tree-use-gfp_zonemask-bits-of-gfp_t-for-flags.patch
* mac80211_hwsim-use-define_ida.patch
* arm64-turn-flush_dcache_mmap_lock-into-a-no-op.patch
* unicore32-turn-flush_dcache_mmap_lock-into-a-no-op.patch
* export-__set_page_dirty.patch
* fscache-use-appropriate-radix-tree-accessors.patch
* xarray-add-the-xa_lock-to-the-radix_tree_root.patch
* page-cache-use-xa_lock.patch
* fix-read-buffer-overflow-in-delta-ipc.patch
* sparc64-ng4-memset-32-bits-overflow.patch
  make-sure-nobodys-leaking-resources.patch
  releasing-resources-with-children.patch
  mutex-subsystem-synchro-test-module.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  slab-leaks3-default-y.patch
  workaround-for-a-pci-restoring-bug.patch
