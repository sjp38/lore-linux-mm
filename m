Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id DCE446B0038
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 20:03:57 -0400 (EDT)
Received: by pagj7 with SMTP id j7so9291832pag.2
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 17:03:57 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id gq4si1037773pbb.64.2015.03.24.17.03.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 17:03:56 -0700 (PDT)
Date: Tue, 24 Mar 2015 17:03:55 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2015-03-24-17-02 uploaded
Message-ID: <5511fb6b.AId+BddNi/aOaoeM%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz

The mm-of-the-moment snapshot 2015-03-24-17-02 has been uploaded to

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


This mmotm tree contains the following patches against 4.0-rc5:
(patches marked "*" will be included in linux-next)

  origin.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  i-need-old-gcc.patch
* aoe-update-aoe-maintainer-information.patch
* drivers-rtc-rtc-mrst-fix-suspend-resume.patch
* drivers-rtc-rtc-mrst-fix-suspend-resume-fix.patch
* mm-fix-anon_vma-degree-underflow-in-anon_vma-endless-growing-prevention.patch
* mm-fix-anon_vma-degree-underflow-in-anon_vma-endless-growing-prevention-v2.patch
* mm-pagewalk-prevent-positive-return-value-of-walk_page_test-from-being-passed-to-callers.patch
* maintainers-correct-rtc-armada38x-pattern-entry.patch
* mm-memory-hotplog-postpone-the-reset-of-obsolete-pgdat.patch
* mm-slub-fix-lockups-on-preempt-smp-kernels.patch
* mm-page_alloc-call-kernel_map_pages-in-unset_migrateype_isolate.patch
* fs-affs-filec-unlock-release-page-on-error.patch
* fs-affs-filec-unlock-release-page-on-error-v2.patch
* maintainers-add-myself-as-dmi-smbios-support-maintainer.patch
* hfsplus-fix-b-tree-corruption-after-insertion-at-position-0.patch
* mm-numa-group-related-processes-based-on-vma-flags-instead-of-page-table-flags.patch
* mm-numa-preserve-pte-write-permissions-across-a-numa-hinting-fault.patch
* mm-numa-slow-pte-scan-rate-if-migration-failures-occur.patch
* mm-numa-mark-huge-ptes-young-when-clearing-numa-hinting-faults.patch
* ptrace-x86-fix-the-tif_forced_tf-logic-in-handle_signal.patch
* cxgb4-drop-__gfp_nofail-allocation.patch
* cxgb4-drop-__gfp_nofail-allocation-fix.patch
* sh-dwarf-destroy-mempools-on-cleanup.patch
* sh-dwarf-use-mempool_create_slab_pool.patch
* fs-ext4-fsyncc-generic_file_fsync-call-based-on-barrier-flag.patch
* jbd2-revert-must-not-fail-allocation-loops-back-to-gfp_nofail.patch
* ocfs2-deletion-of-unnecessary-checks-before-three-function-calls.patch
* ocfs2-less-function-calls-in-ocfs2_convert_inline_data_to_extents-after-error-detection.patch
* ocfs2-less-function-calls-in-ocfs2_figure_merge_contig_type-after-error-detection.patch
* ocfs2-one-function-call-less-in-ocfs2_merge_rec_left-after-error-detection.patch
* ocfs2-one-function-call-less-in-ocfs2_merge_rec_right-after-error-detection.patch
* ocfs2-one-function-call-less-in-ocfs2_init_slot_info-after-error-detection.patch
* ocfs2-one-function-call-less-in-user_cluster_connect-after-error-detection.patch
* ocfs2-avoid-a-pointless-delay-in-o2cb_cluster_check.patch
* ocfs2-fix-a-typing-error-in-ocfs2_direct_io_write.patch
* ocfs2-no-need-get-dinode-bh-when-zeroing-extend.patch
* ocfs2-take-inode-lock-when-get-clusters.patch
* ocfs2-do-not-use-ocfs2_zero_extend-during-direct-io.patch
* ocfs2-fix-typo-in-ocfs2_reserve_local_alloc_bits.patch
* ocfs2-dereferencing-freed-pointers-in-ocfs2_reflink.patch
* ocfs2-use-actual-name-length-when-find-entry-in-ocfs2_orphan_del.patch
* ocfs2-use-enoent-instead-of-eexist-when-get-system-file-fails.patch
* ocfs2-rollback-the-cleared-bits-if-error-occurs-after-ocfs2_block_group_clear_bits.patch
* ocfs2-remove-goto-statement-in-ocfs2_check_dir_for_entry.patch
* ocfs2-fix-possible-uninitialized-variable-access.patch
* ocfs2-fix-a-typo-in-the-copyright-statement.patch
* ocfs2-incorrect-check-for-debugfs-returns.patch
* ocfs2-trusted-xattr-missing-cap_sys_admin-check.patch
* ocfs2-flush-inode-data-to-disk-and-free-inode-when-i_count-becomes-zero.patch
* add-errors=continue.patch
* acknowledge-return-value-of-ocfs2_error.patch
* clear-the-rest-of-the-buffers-on-error.patch
* ocfs2-fix-a-tiny-case-that-inode-can-not-removed.patch
* ocfs2-use-64bit-variables-to-track-heartbeat-time.patch
* ocfs2-call-ocfs2_journal_access_di-before-ocfs2_journal_dirty-in-ocfs2_write_end_nolock.patch
* ocfs2-avoid-access-invalid-address-when-read-o2dlm-debug-messages.patch
* ocfs2-avoid-access-invalid-address-when-read-o2dlm-debug-messages-v3.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* posix_acl-make-posix_acl_create-safer-and-cleaner.patch
* vfs-delete-vfs_readdir-function-declaration.patch
* watchdog-new-definitions-and-variables-initialization.patch
* watchdog-introduce-the-proc_watchdog_update-function.patch
* watchdog-move-definition-of-watchdog_proc_mutex-outside-of-proc_dowatchdog.patch
* watchdog-introduce-the-proc_watchdog_common-function.patch
* watchdog-introduce-separate-handlers-for-parameters-in-proc-sys-kernel.patch
* watchdog-implement-error-handling-for-failure-to-set-up-hardware-perf-events.patch
* watchdog-implement-error-handling-for-failure-to-set-up-hardware-perf-events-fix.patch
* watchdog-enable-the-new-user-interface-of-the-watchdog-mechanism.patch
* watchdog-enable-the-new-user-interface-of-the-watchdog-mechanism-fix.patch
* watchdog-clean-up-some-function-names-and-arguments.patch
* watchdog-introduce-the-hardlockup_detector_disable-function.patch
  mm.patch
* mm-slub-parse-slub_debug-o-option-in-switch-statement.patch
* mm-rename-foll_mlock-to-foll_populate.patch
* mm-rename-__mlock_vma_pages_range-to-populate_vma_page_range.patch
* mm-move-gup-posix-mlock-error-conversion-out-of-__mm_populate.patch
* mm-move-mm_populate-related-code-to-mm-gupc.patch
* mm-memblockc-name-the-local-variable-of-memblock_type-as-type.patch
* mm-memcontrol-update-copyright-notice.patch
* memory-hotplug-use-macro-to-switch-between-section-and-pfn.patch
* mm-cma-debugfs-interface.patch
* mm-cma-allocation-trigger.patch
* mm-cma-release-trigger.patch
* mm-cma-release-trigger-checkpatch-fixes.patch
* mm-cma-release-trigger-fixpatch.patch
* mm-cma-allocation-trigger-fix.patch
* cma-debug-document-new-debugfs-interface.patch
* mm-hotplug-fix-concurrent-memory-hot-add-deadlock.patch
* mm-cma-change-fallback-behaviour-for-cma-freepage.patch
* mm-page_alloc-factor-out-fallback-freepage-checking.patch
* mm-compaction-enhance-compaction-finish-condition.patch
* mm-compaction-enhance-compaction-finish-condition-fix.patch
* mm-incorporate-zero-pages-into-transparent-huge-pages.patch
* mm-incorporate-zero-pages-into-transparent-huge-pages-fix.patch
* page_writeback-cleanup-mess-around-cancel_dirty_page.patch
* page_writeback-cleanup-mess-around-cancel_dirty_page-checkpatch-fixes.patch
* mm-hide-per-cpu-lists-in-output-of-show_mem.patch
* mm-hide-per-cpu-lists-in-output-of-show_mem-fix.patch
* mm-completely-remove-dumping-per-cpu-lists-from-show_mem.patch
* alpha-expose-number-of-page-table-levels-on-kconfig-level.patch
* arm64-expose-number-of-page-table-levels-on-kconfig-level.patch
* arm-expose-number-of-page-table-levels-on-kconfig-level.patch
* ia64-expose-number-of-page-table-levels-on-kconfig-level.patch
* m68k-mark-pmd-folded-and-expose-number-of-page-table-levels.patch
* mips-expose-number-of-page-table-levels-on-kconfig-level.patch
* parisc-expose-number-of-page-table-levels-on-kconfig-level.patch
* powerpc-expose-number-of-page-table-levels-on-kconfig-level.patch
* s390-expose-number-of-page-table-levels.patch
* sh-expose-number-of-page-table-levels.patch
* sparc-expose-number-of-page-table-levels.patch
* tile-expose-number-of-page-table-levels.patch
* um-expose-number-of-page-table-levels.patch
* x86-expose-number-of-page-table-levels-on-kconfig-level.patch
* mm-define-default-pgtable_levels-to-two.patch
* mm-do-not-add-nr_pmds-into-mm_struct-if-pmd-is-folded.patch
* mm-refactor-do_wp_page-extract-the-reuse-case.patch
* mm-refactor-do_wp_page-extract-the-reuse-case-fix.patch
* mm-refactor-do_wp_page-rewrite-the-unlock-flow.patch
* mm-refactor-do_wp_page-extract-the-page-copy-flow.patch
* mm-refactor-do_wp_page-handling-of-shared-vma-into-a-function.patch
* ocfs2-copy-fs-uuid-to-superblock.patch
* cleancache-zap-uuid-arg-of-cleancache_init_shared_fs.patch
* cleancache-forbid-overriding-cleancache_ops.patch
* cleancache-remove-limit-on-the-number-of-cleancache-enabled-filesystems.patch
* cleancache-remove-limit-on-the-number-of-cleancache-enabled-filesystems-fix.patch
* mm-mempolicy-migrate_to_node-should-only-migrate-to-node.patch
* mm-remove-gfp_thisnode.patch
* mm-thp-really-limit-transparent-hugepage-allocation-to-local-node.patch
* kernel-cpuset-remove-exception-for-__gfp_thisnode.patch
* mm-cma-constify-and-use-correct-signness-in-mm-cmac.patch
* mm-clarify-__gfp_nofail-deprecation-status.patch
* mm-clarify-__gfp_nofail-deprecation-status-checkpatch-fixes.patch
* sparc-clarify-__gfp_nofail-allocation.patch
* mm-page_allocc-add-and-in-comment.patch
* mm-change-__get_vm_area_node-to-use-fls_long.patch
* lib-add-huge-i-o-map-capability-interfaces.patch
* lib-add-huge-i-o-map-capability-interfaces-fix.patch
* mm-change-ioremap-to-set-up-huge-i-o-mappings.patch
* mm-change-ioremap-to-set-up-huge-i-o-mappings-fix.patch
* mm-change-vunmap-to-tear-down-huge-kva-mappings.patch
* mm-change-vunmap-to-tear-down-huge-kva-mappings-fix.patch
* x86-mm-support-huge-i-o-mapping-capability-i-f.patch
* x86-mm-support-huge-kva-mappings-on-x86.patch
* x86-mm-support-huge-kva-mappings-on-x86-fix.patch
* mm-memcontrol-let-mem_cgroup_move_account-have-effect-only-if-mmu-enabled.patch
* arm-factor-out-mmap-aslr-into-mmap_rnd.patch
* x86-standardize-mmap_rnd-usage.patch
* arm64-standardize-mmap_rnd-usage.patch
* arm64-standardize-mmap_rnd-usage-v4.patch
* mips-extract-logic-for-mmap_rnd.patch
* mips-extract-logic-for-mmap_rnd-v4.patch
* powerpc-standardize-mmap_rnd-usage.patch
* powerpc-standardize-mmap_rnd-usage-v4.patch
* s390-standardize-mmap_rnd-usage.patch
* mm-expose-arch_mmap_rnd-when-available.patch
* s390-redefine-randomize_et_dyn-for-elf_et_dyn_base.patch
* mm-split-et_dyn-aslr-from-mmap-aslr.patch
* mm-fold-arch_randomize_brk-into-arch_has_elf_randomize.patch
* mm-numa-remove-migrate_ratelimited.patch
* memcg-print-cgroup-information-when-system-panics-due-to-panic_on_oom.patch
* mm-mempool-do-not-allow-atomic-resizing.patch
* mm-mempool-do-not-allow-atomic-resizing-checkpatch-fixes.patch
* mm-hugetlb-abort-__get_user_pages-if-current-has-been-oom-killed.patch
* mm-move-memtest-under-mm.patch
* mm-move-memtest-under-mm-fix.patch
* memtest-use-phys_addr_t-for-physical-addresses.patch
* arm64-add-support-for-memtest.patch
* arm-add-support-for-memtest.patch
* kconfig-memtest-update-number-of-test-patterns-up-to-17.patch
* documentation-update-arch-list-in-the-memtest-entry.patch
* mm-oom_killc-fix-a-typo.patch
* mm-refactor-zone_movable_is_highmem.patch
* memcg-zap-mem_cgroup_lookup.patch
* memcg-remove-obsolete-comment.patch
* mm-memory-failurec-define-page-types-for-action_result-in-one-place.patch
* mm-memory-failurec-define-page-types-for-action_result-in-one-place-fix.patch
* mm-consolidate-all-page-flags-helpers-in-linux-page-flagsh.patch
* page-flags-trivial-cleanup-for-pagetrans-helpers.patch
* page-flags-introduce-page-flags-policies-wrt-compound-pages.patch
* page-flags-define-pg_locked-behavior-on-compound-pages.patch
* page-flags-define-behavior-of-fs-io-related-flags-on-compound-pages.patch
* page-flags-define-behavior-of-lru-related-flags-on-compound-pages.patch
* page-flags-define-behavior-slb-related-flags-on-compound-pages.patch
* page-flags-define-behavior-of-xen-related-flags-on-compound-pages.patch
* page-flags-define-pg_reserved-behavior-on-compound-pages.patch
* page-flags-define-pg_swapbacked-behavior-on-compound-pages.patch
* page-flags-define-pg_swapcache-behavior-on-compound-pages.patch
* page-flags-define-pg_mlocked-behavior-on-compound-pages.patch
* page-flags-define-pg_uncached-behavior-on-compound-pages.patch
* page-flags-define-pg_uptodate-behavior-on-compound-pages.patch
* page-flags-look-on-head-page-if-the-flag-is-encoded-in-page-mapping.patch
* mm-sanitize-page-mapping-for-tail-pages.patch
* include-linux-page-flagsh-rename-macros-to-avoid-collisions.patch
* allow-compaction-of-unevictable-pages.patch
* mm-change-deactivate_page-with-deactivate_file_page.patch
* mm-memcg-sync-allocation-and-memcg-charge-gfp-flags-for-thp.patch
* mm-memcg-sync-allocation-and-memcg-charge-gfp-flags-for-thp-fix.patch
* mm-compaction-reset-compaction-scanner-positions.patch
* hugetlbfs-add-minimum-size-tracking-fields-to-subpool-structure.patch
* hugetlbfs-add-minimum-size-accounting-to-subpools.patch
* hugetlbfs-accept-subpool-min_size-mount-option-and-setup-accordingly.patch
* hugetlbfs-document-min_size-mount-option-and-cleanup.patch
* mm-vmalloc-fix-possible-exhaustion-of-vmalloc-space-caused-by-vm_map_ram-allocator.patch
* mm-vmalloc-occupy-newly-allocated-vmap-block-just-after-allocation.patch
* mm-vmalloc-get-rid-of-dirty-bitmap-inside-vmap_block-structure.patch
* mremap-should-return-enomem-when-__vm_enough_memory-fail.patch
* clean-up-goto-just-return-err_ptr.patch
* mm-use-read_once-for-non-scalar-types.patch
* mm-remove-rest-of-access_once-usages.patch
* mm-vmscan-fix-the-page-state-calculation-in-too_many_isolated.patch
* mm-page_isolation-check-pfn-validity-before-access.patch
* mm-fix-invalid-use-of-pfn_valid_within-in-test_pages_in_a_zone.patch
* fs-mpagec-forgotten-write_sync-in-case-of-data-integrity-write.patch
* mm-support-madvisemadv_free.patch
* mm-support-madvisemadv_free-fix.patch
* mm-support-madvisemadv_free-fix-2.patch
* mm-dont-split-thp-page-when-syscall-is-called.patch
* mm-dont-split-thp-page-when-syscall-is-called-fix.patch
* mm-dont-split-thp-page-when-syscall-is-called-fix-2.patch
* mm-free-swp_entry-in-madvise_free.patch
* mm-move-lazy-free-pages-to-inactive-list.patch
* x86-add-pmd_-for-thp.patch
* x86-add-pmd_-for-thp-fix.patch
* sparc-add-pmd_-for-thp.patch
* sparc-add-pmd_-for-thp-fix.patch
* powerpc-add-pmd_-for-thp.patch
* arm-add-pmd_mkclean-for-thp.patch
* arm64-add-pmd_-for-thp.patch
* zram-cosmetic-zram_attr_ro-code-formatting-tweak.patch
* zram-use-idr-instead-of-zram_devices-array.patch
* zram-factor-out-device-reset-from-reset_store.patch
* zram-reorganize-code-layout.patch
* zram-add-dynamic-device-add-remove-functionality.patch
* zram-add-dynamic-device-add-remove-functionality-fix.patch
* zram-remove-max_num_devices-limitation.patch
* zram-report-every-added-and-removed-device.patch
* zram-trivial-correct-flag-operations-comment.patch
* zram-return-zram-device_id-value-from-zram_add.patch
* zram-introduce-automatic-device_id-generation.patch
* zram-introduce-automatic-device_id-generation-fix.patch
* zram-do-not-let-user-enforce-new-device-dev_id.patch
* zsmalloc-decouple-handle-and-object.patch
* zsmalloc-factor-out-obj_.patch
* zsmalloc-support-compaction.patch
* zsmalloc-support-compaction-fix.patch
* zsmalloc-adjust-zs_almost_full.patch
* zram-support-compaction.patch
* zsmalloc-record-handle-in-page-private-for-huge-object.patch
* zsmalloc-add-fullness-into-stat.patch
* zsmalloc-zsmalloc-documentation.patch
* mm-zsmallocc-fix-comment-for-get_pages_per_zspage.patch
* zram-remove-num_migrated-device-attr.patch
* zram-move-compact_store-to-sysfs-functions-area.patch
* zram-use-generic-start-end-io-accounting.patch
* zram-describe-device-attrs-in-documentation.patch
* zram-export-new-io_stat-sysfs-attrs.patch
* zram-export-new-mm_stat-sysfs-attrs.patch
* zram-deprecate-zram-attrs-sysfs-nodes.patch
* zsmalloc-remove-synchronize_rcu-from-zs_compact.patch
* zsmalloc-remove-extra-cond_resched-in-__zs_compact.patch
* zsmalloc-do-not-remap-dst-page-while-prepare-next-src-page.patch
* zsmalloc-micro-optimize-zs_object_copy.patch
* proc-pid-status-show-all-sets-of-pid-according-to-ns.patch
* docs-add-missing-and-new-proc-pid-status-file-entries-fix-typos.patch
* proc-show-locks-in-proc-pid-fdinfo-x.patch
* proc-show-locks-in-proc-pid-fdinfo-x-v2.patch
* include-linux-remove-empty-conditionals.patch
* paride-fix-the-verbose-module-param.patch
* kernel-conditionally-support-non-root-users-groups-and-capabilities.patch
* kernel-conditionally-support-non-root-users-groups-and-capabilities-checkpatch-fixes.patch
* resource-remove-deprecated-__check_region-and-friends.patch
* hung_task-change-hung_taskc-to-use-for_each_process_thread.patch
* printk-comment-pr_cont-stating-it-is-only-to-continue-a-line.patch
* lib-vsprintfc-eliminate-some-branches.patch
* lib-vsprintfc-reduce-stack-use-in-number.patch
* lib-vsprintfc-eliminate-duplicate-hex-string-array.patch
* lib-vsprintfc-another-small-hack.patch
* lib-vsprintf-document-%p-parameters-passed-by-reference.patch
* lib-vsprintf-move-integer-format-types-to-the-top.patch
* lib-vsprintf-add-%pcnr-format-specifiers-for-clocks.patch
* lib-vsprintf-add-%pcnr-format-specifiers-for-clocks-fix.patch
* lib-vsprintfc-fix-potential-null-deref-in-hex_string.patch
* lib-string_helpersc-refactor-string_escape_mem.patch
* lib-string_helpersc-change-semantics-of-string_escape_mem.patch
* lib-string_helpersc-change-semantics-of-string_escape_mem-fix.patch
* lib-string_helpersc-change-semantics-of-string_escape_mem-fix-fix.patch
* lib-vsprintf-add-%pt-format-specifier.patch
* maintainers-use-tabs-consistently.patch
* credits-add-ricardo-ribalda-delgado.patch
* mailmap-add-ricardo-ribalda.patch
* linux-bitmaph-improve-bitmap_lastfirst_word_mask.patch
* x86-mtrr-if-remove-use-of-seq_printf-return-value.patch
* power-wakeup-remove-use-of-seq_printf-return-value.patch
* rtc-remove-use-of-seq_printf-return-value.patch
* ipc-remove-use-of-seq_printf-return-value.patch
* microblaze-mb-remove-use-of-seq_printf-return-value.patch
* microblaze-mb-remove-use-of-seq_printf-return-value-fix.patch
* nios2-cpuinfo-remove-use-of-seq_printf-return-value.patch
* arm-plat-pxa-remove-use-of-seq_printf-return-value.patch
* openrisc-remove-use-of-seq_printf-return-value.patch
* cris-remove-use-of-seq_printf-return-value.patch
* cris-fasttimer-remove-use-of-seq_printf-return-value.patch
* s390-remove-use-of-seq_printf-return-value.patch
* i8k-remove-use-of-seq_printf-return-value.patch
* watchdog-bcm281xx-remove-use-of-seq_printf-return-value.patch
* proc-remove-use-of-seq_printf-return-value.patch
* cgroup-remove-use-of-seq_printf-return-value.patch
* tracing-remove-use-of-seq_printf-return-value.patch
* lru_cache-remove-use-of-seq_printf-return-value.patch
* parisc-remove-use-of-seq_printf-return-value.patch
* lib-find__bit-reimplementation.patch
* lib-find__bit-reimplementation-fix.patch
* lib-move-find_last_bit-to-lib-find_next_bitc.patch
* lib-rename-lib-find_next_bitc-to-lib-find_bitc.patch
* lib-vsprintfc-even-faster-decimal-conversion.patch
* lib-vsprintfc-even-faster-decimal-conversion-fix.patch
* lib-dma-debug-fix-bucket_find_contain.patch
* util_macrosh-add-find_closest-macro.patch
* documentation-update-codingstyle-on-local-variables-naming-in-macros.patch
* hwmon-ina2xx-replace-ina226_avg_bits-with-find_closest.patch
* hwmon-lm85-use-find_closest-in-x_to_reg-functions.patch
* hwmon-w83795-use-find_closest_descending-in-pwm_freq_to_reg.patch
* lib-vsprintfc-improve-put_dec_trunc8-slightly.patch
* kernelh-implement-div_round_closest_ull.patch
* clk-bcm-kona-use-div_round_closest_ull.patch
* cpuidle-menu-use-div_round_closest_ull.patch
* media-cxd2820r-use-div_round_closest_ull.patch
* mm-utilc-add-kstrimdup.patch
* lib-add-crc64-ecma-module.patch
* ihex-restore-missing-default-in-switch-statement.patch
* checkpatch-improve-no-space-is-necessary-after-a-cast-test.patch
* checkpatch-add-spell-checking-of-email-subject-line.patch
* checkpatch-spell-check-reudce.patch
* checkpatch-add-optional-codespell-dictionary-to-find-more-typos.patch
* checkpatch-match-more-world-writable-permissions.patch
* checkpatch-match-more-world-writable-permissions-fix.patch
* checkpatch-improve-return-negative-errno-check.patch
* checkpatch-add-test-for-repeated-const-uses.patch
* binfmt_misc-simplify-entry_status.patch
* binfmt_misc-simplify-entry_status-fix.patch
* rtc-pcf8563-simplify-return-from-function.patch
* rtc-stmp3xxx-use-optional-crystal-in-low-power-states.patch
* rtc-mc13xxx-fix-obfuscated-and-wrong-format-string.patch
* rtc-mediatek-add-mt63xx-rtc-driver.patch
* drivers-rtc-rtc-em3027c-add-device-tree-support.patch
* rtc-x1205-use-sign_extend32-for-sign-extension.patch
* rtc-hctosys-do-not-treat-lack-of-rtc-device-as-error.patch
* rtc-s3c-delete-duplicate-clock-control.patch
* rtc-rtc-ab-b5ze-s3-constify-struct-regmap_config.patch
* rtc-add-rtc-abx805-a-driver-for-the-abracon-ab-1805-i2c-rtc.patch
* rtc-add-abracon-abx80x-driver.patch
* rtc-add-abracon-abx80x-driver-fix.patch
* rtc-ds1685-remove-owner-assignment-from-platform_driver.patch
* rtc-ds1685-fix-sparse-warnings.patch
* rtc-da9052-add-extra-reads-with-timeouts-to-avoid-returning-partially-updated-values.patch
* rtc-da9052-add-constraints-to-set-valid-year.patch
* rtc-da9052-register-ability-of-alarm-to-wake-device-from-suspend.patch
* rtc-hym8563-return-clock-rate-even-when-clock-is-disabled.patch
* rtc-digicolor-document-device-tree-binding.patch
* rtc-driver-for-conexant-digicolor-cx92755-on-chip-rtc.patch
* rtc-driver-for-conexant-digicolor-cx92755-on-chip-rtc-fix.patch
* rtc-omap-add-external-32k-clock-feature.patch
* rtc-omap-add-external-32k-clock-feature-fix.patch
* drivers-rtc-interfacec-check-the-error-after-__rtc_read_time.patch
* rtc-restore-alarm-after-resume.patch
* nilfs2-do-not-use-async-write-flag-for-segment-summary-buffers.patch
* nilfs2-use-set_mask_bits-for-operations-on-buffer-state-bitmap.patch
* nilfs2-use-bgl_lock_ptr.patch
* nilfs2-unify-type-of-key-arguments-in-bmap-interface.patch
* nilfs2-add-bmap-function-to-seek-a-valid-key.patch
* nilfs2-add-helper-to-find-existent-block-on-metadata-file.patch
* nilfs2-improve-execution-time-of-nilfs_ioctl_get_cpinfo-ioctl.patch
* hfsplus-add-missing-curly-braces-in-hfsplus_delete_cat.patch
* fs-hfsplus-move-xattr_name-allocation-in-hfsplus_getxattr.patch
* fs-hfsplus-move-xattr_name-allocation-in-hfsplus_setxattr.patch
* fs-hfsplus-atomically-set-inode-i_flags.patch
* fs-hfsplus-use-bool-instead-of-int-for-is_known_namespace-return-value.patch
* fs-hfsplus-replace-if-bug-by-bug_on.patch
* fs-fat-remove-unnecessary-defintion.patch
* fs-fat-remove-unnecessary-includes.patch
* fs-fat-remove-unnecessary-includes-fix.patch
* fs-fat-remove-unnecessary-includes-fix-2.patch
* fs-fat-comment-fix-fat_bits-can-be-also-32.patch
* fat-add-fat_fallocate-operation.patch
* fat-skip-cluster-allocation-on-fallocated-region.patch
* fat-permit-to-return-phy-block-number-by-fibmap-in-fallocated-region.patch
* documentation-filesystems-vfattxt-update-the-limitation-for-fat-fallocate.patch
* ptrace-fix-race-between-ptrace_resume-and-wait_task_stopped.patch
* ptrace-ptrace_detach-can-no-longer-race-with-sigkill.patch
* signal-remove-warning-about-using-si_tkill-in-rt_sigqueueinfo.patch
* fork-report-pid-reservation-failure-properly.patch
* fork_init-update-max_threads-comment.patch
* mm-rcu-protected-get_mm_exe_file.patch
* mm-rcu-protected-get_mm_exe_file-fix.patch
* mm-rcu-protected-get_mm_exe_file-fix-2.patch
* de_thread-move-notify_count-write-under-lock.patch
* cpumask-dont-perform-while-loop-in-cpumask_next_and.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* adfs-returning-correct-return-values.patch
* fs-affs-use-affs_mount-prefix-for-mount-options.patch
* fs-affs-affsh-add-mount-option-manipulation-macros.patch
* fs-affs-superc-use-affs_set_opt.patch
* fs-affs-use-affs_test_opt.patch
* affs-kstrdup-memory-handling.patch
* affs-kstrdup-memory-handling-fix.patch
* bfs-bfad_worker-cleanup.patch
* memstick-mspro_block-add-missing-curly-braces.patch
* kconfig-use-macros-which-are-already-defined.patch
* kconfig-use-macros-which-are-already-defined-fix.patch
* arc-do-not-export-symbols-in-troubleshootc.patch
* lib-lz4-pull-out-constant-tables.patch
* seccomp-allow-compat-sigreturn-overrides.patch
* arm-use-asm-generic-for-seccomph.patch
* microblaze-use-asm-generic-for-seccomph.patch
* mips-switch-to-using-asm-generic-for-seccomph.patch
* parisc-switch-to-using-asm-generic-for-seccomph.patch
* powerpc-switch-to-using-asm-generic-for-seccomph.patch
* sparc-switch-to-using-asm-generic-for-seccomph.patch
* x86-switch-to-using-asm-generic-for-seccomph.patch
  linux-next.patch
  linux-next-rejects.patch
* include-sound-fix-build.patch
* unicore32-remove-unnecessary-kern_err-in-fpu-ucf64c.patch
* lib-kconfig-fix-up-have_arch_bitreverse-help-text.patch
* mips-ip32-add-platform-data-hooks-to-use-ds1685-driver.patch
* oprofile-reduce-mmap_sem-hold-for-mm-exe_file.patch
* powerpc-oprofile-reduce-mmap_sem-hold-for-exe_file.patch
* oprofile-reduce-mmap_sem-hold-for-mm-exe_file-fix.patch
* tomoyo-reduce-mmap_sem-hold-for-mm-exe_file.patch
* tomoyo-reduce-mmap_sem-hold-for-mm-exe_file-checkpatch-fixes.patch
* maintainers-add-mediatek-soc-mailing-list.patch
* gitignore-ignore-tar.patch
* rtc-s5m-allow-usage-on-device-type-different-than-main-mfd-type.patch
* rtc-s5m-allow-usage-on-device-type-different-than-main-mfd-type-v2.patch
* documentation-spi-spidev_testc-fix-warning.patch
* rtc-at91rm9200-make-io-endian-agnostic.patch
* mm-x86-document-return-values-of-mapping-funcs.patch
* mtrr-x86-fix-mtrr-lookup-to-handle-inclusive-entry.patch
* mtrr-x86-remove-a-wrong-address-check-in-__mtrr_type_lookup.patch
* mtrr-x86-fix-mtrr-state-checks-in-mtrr_type_lookup.patch
* mtrr-x86-define-mtrr_type_invalid-for-mtrr_type_lookup.patch
* mtrr-x86-clean-up-mtrr_type_lookup.patch
* mtrr-mm-x86-enhance-mtrr-checks-for-kva-huge-page-mapping.patch
* w1-call-put_device-if-device_register-fails.patch
* mm-add-strictlimit-knob-v2.patch
  do_shared_fault-check-that-mmap_sem-is-held.patch
  make-sure-nobodys-leaking-resources.patch
  journal_add_journal_head-debug.patch
  journal_add_journal_head-debug-fix.patch
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
