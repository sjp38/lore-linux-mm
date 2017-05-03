Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id EB9AE6B0038
	for <linux-mm@kvack.org>; Wed,  3 May 2017 18:17:19 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h87so2686706pfh.2
        for <linux-mm@kvack.org>; Wed, 03 May 2017 15:17:19 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o4si286494plb.28.2017.05.03.15.17.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 May 2017 15:17:18 -0700 (PDT)
Date: Wed, 03 May 2017 15:17:15 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2017-05-03-15-16 uploaded
Message-ID: <590a56eb.l+Eu7L7Jdv9KEqSs%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2017-05-03-15-16 has been uploaded to

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


This mmotm tree contains the following patches against 4.11:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
* dma-debug-make-locking-to-work-for-rt.patch
* scripts-spellingtxt-add-several-more-common-spelling-mistakes.patch
* blackfin-bf609-let-clk_disable-return-immediately-if-clk-is-null.patch
* fs-ocfs2-cluster-use-setup_timer.patch
* ocfs2-o2hb-revert-hb-threshold-to-keep-compatible.patch
* fs-ocfs2-cluster-use-offset_in_page-macro.patch
* slab-avoid-ipis-when-creating-kmem-caches.patch
* mm-fix-100%-cpu-kswapd-busyloop-on-unreclaimable-nodes.patch
* mm-fix-check-for-reclaimable-pages-in-pf_memalloc-reclaim-throttling.patch
* mm-remove-seemingly-spurious-reclaimability-check-from-laptop_mode-gating.patch
* mm-remove-unnecessary-reclaimability-check-from-numa-balancing-target.patch
* mm-dont-avoid-high-priority-reclaim-on-unreclaimable-nodes.patch
* mm-dont-avoid-high-priority-reclaim-on-memcg-limit-reclaim.patch
* mm-delete-nr_pages_scanned-and-pgdat_reclaimable.patch
* revert-mm-vmscan-account-for-skipped-pages-as-a-partial-scan.patch
* mm-remove-unnecessary-back-off-function-when-retrying-page-reclaim.patch
* writeback-use-setup_deferrable_timer.patch
* mm-delete-unnecessary-ttu_-flags.patch
* mm-dont-assume-anonymous-pages-have-swapbacked-flag.patch
* mm-move-madv_free-pages-into-lru_inactive_file-list.patch
* mm-reclaim-madv_free-pages.patch
* mm-fix-lazyfree-bug-on-check-in-try_to_unmap_one.patch
* mm-enable-madv_free-for-swapless-system.patch
* proc-show-madv_free-pages-info-in-smaps.patch
* mm-memcontrol-provide-shmem-statistics.patch
* mm-swap-fix-a-race-in-free_swap_and_cache.patch
* mm-use-is_migrate_highatomic-to-simplify-the-code.patch
* mm-use-is_migrate_isolate_page-to-simplify-the-code.patch
* mm-vmstat-print-non-populated-zones-in-zoneinfo.patch
* mm-vmstat-suppress-pcp-stats-for-unpopulated-zones-in-zoneinfo.patch
* lockdep-teach-lockdep-about-memalloc_noio_save.patch
* lockdep-allow-to-disable-reclaim-lockup-detection.patch
* xfs-abstract-pf_fstrans-to-pf_memalloc_nofs.patch
* mm-introduce-memalloc_nofs_saverestore-api.patch
* xfs-use-memalloc_nofs_saverestore-instead-of-memalloc_noio.patch
* jbd2-mark-the-transaction-context-with-the-scope-gfp_nofs-context.patch
* jbd2-make-the-whole-kjournald2-kthread-nofs-safe.patch
* mm-tighten-up-the-fault-path-a-little.patch
* mm-remove-rodata_test_data-export-add-pr_fmt.patch
* mm-do-not-use-double-negation-for-testing-page-flags.patch
* mm-vmscan-fix-zone-balance-check-in-prepare_kswapd_sleep.patch
* mm-vmscan-only-clear-pgdat-congested-dirty-writeback-state-when-balanced.patch
* mm-vmscan-prevent-kswapd-sleeping-prematurely-due-to-mismatched-classzone_idx.patch
* mm-page_alloc-__gfp_nowarn-shouldnt-suppress-stall-warnings.patch
* mm-sparse-refine-usemap_size-a-little.patch
* mm-compaction-ignore-block-suitable-after-check-large-free-page.patch
* mm-vmscan-more-restrictive-condition-for-retry-in-do_try_to_free_pages.patch
* mm-remove-unncessary-ret-in-page_referenced.patch
* mm-remove-swap_dirty-in-ttu.patch
* mm-remove-swap_mlock-check-for-swap_success-in-ttu.patch
* mm-make-the-try_to_munlock-void-function.patch
* mm-remove-swap_mlock-in-ttu.patch
* mm-remove-swap_again-in-ttu.patch
* mm-make-ttus-return-boolean.patch
* mm-make-rmap_walk-void-function.patch
* mm-make-rmap_one-boolean-function.patch
* mm-remove-swap_.patch
* mm-swap-fix-comment-in-__read_swap_cache_async.patch
* mm-swap-improve-readability-via-make-spin_lock-unlock-balanced.patch
* mm-swap-avoid-lock-swap_avail_lock-when-held-cluster-lock.patch
* mm-enable-page-poisoning-early-at-boot.patch
* mm-include-linux-migrateh-fixing-checkpatch-warning-regarding-function-definition.patch
* swap-add-warning-if-swap-slots-cache-failed-to-initialize.patch
* mm-fix-spelling-error.patch
* userfaultfd-selftest-combine-all-cases-into-the-single-executable.patch
* oom-improve-oom-disable-handling.patch
* mm-mmap-replace-shm_huge_mask-with-map_huge_mask-inside-mmap_pgoff.patch
* mm-vmscan-fix-io-refault-regression-in-cache-workingset-transition.patch
* mm-memcontrol-clean-up-memoryevents-counting-function.patch
* mm-memcontrol-re-use-global-vm-event-enum.patch
* mm-memcontrol-re-use-node-vm-page-state-enum.patch
* mm-memcontrol-use-node-page-state-naming-scheme-for-memcg.patch
* mm-swap-remove-unused-function-prototype.patch
* documentation-vm-add-hugetlbfs-reservation-overview.patch
* mm-madvise-clean-up-madv_soft_offline-and-madv_hwpoison.patch
* mm-madvise-move-up-the-behavior-parameter-validation.patch
* mm-softoffline-add-page-flag-description-in-error-paths.patch
* mm-page_alloc-remove-debug_guardpage_minorder-test-in-warn_alloc.patch
* zram-handle-multiple-pages-attached-bios-bvec.patch
* zram-partial-io-refactoring.patch
* zram-use-zram_slot_lock-instead-of-raw-bit_spin_lock-op.patch
* zram-remove-zram_meta-structure.patch
* zram-introduce-zram-data-accessor.patch
* zram-use-zram_free_page-instead-of-open-coded.patch
* zram-reduce-load-operation-in-page_same_filled.patch
* fs-fix-data-invalidation-in-the-cleancache-during-direct-io.patch
* fs-block_dev-always-invalidate-cleancache-in-invalidate_bdev.patch
* mm-truncate-bail-out-early-from-invalidate_inode_pages2_range-if-mapping-is-empty.patch
* mm-truncate-avoid-pointless-cleancache_invalidate_inode-calls.patch
* mm-gup-fix-access_ok-argument-type.patch
* mm-swap-fix-swap-space-leak-in-error-path-of-swap_free_entries.patch
* mm-hwpoison-call-shake_page-unconditionally.patch
* mm-hwpoison-call-shake_page-after-try_to_unmap-for-mlocked-page.patch
* kasan-introduce-helper-functions-for-determining-bug-type.patch
* kasan-unify-report-headers.patch
* kasan-change-allocation-and-freeing-stack-traces-headers.patch
* kasan-simplify-address-description-logic.patch
* kasan-change-report-header.patch
* kasan-improve-slab-object-description.patch
* kasan-print-page-description-after-stacks.patch
* kasan-improve-double-free-report-format.patch
* kasan-separate-report-parts-by-empty-lines.patch
* mm-uncharge-poisoned-pages.patch
* mm-skip-hwpoisoned-pages-when-onlining-pages.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called.patch
* ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called-fix.patch
* ocfs2-dlm-optimization-of-code-while-free-dead-node-locks.patch
* ocfs2-dlm-optimization-of-code-while-free-dead-node-locks-checkpatch-fixes.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
  mm.patch
* mm-compaction-reorder-fields-in-struct-compact_control.patch
* mm-compaction-remove-redundant-watermark-check-in-compact_finished.patch
* mm-page_alloc-split-smallest-stolen-page-in-fallback.patch
* mm-page_alloc-split-smallest-stolen-page-in-fallback-fix.patch
* mm-page_alloc-count-movable-pages-when-stealing-from-pageblock.patch
* mm-page_alloc-count-movable-pages-when-stealing-from-pageblock-fix.patch
* mm-compaction-change-migrate_async_suitable-to-suitable_migration_source.patch
* mm-compaction-add-migratetype-to-compact_control.patch
* mm-compaction-restrict-async-compaction-to-pageblocks-of-same-migratetype.patch
* mm-compaction-finish-whole-pageblock-to-reduce-fragmentation.patch
* mm-page_alloc-return-0-in-case-this-node-has-no-page-within-the-zone.patch
* mm-vmscan-do-not-pass-reclaimed-slab-to-vmpressure.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* mm-walk-the-zone-in-pageblock_nr_pages-steps.patch
* proc-remove-cast-from-memory-allocation.patch
* proc-sysctl-fix-the-int-overflow-for-jiffies-conversion.patch
* drivers-virt-use-get_user_pages_unlocked.patch
* jiffiesh-declare-jiffies-and-jiffies_64-with-____cacheline_aligned_in_smp.patch
* make-help-add-tools-help-target.patch
* locking-hung_task-defer-showing-held-locks.patch
* vmci-fix-a-couple-integer-overflow-tests.patch
* c2port-checking-for-null-instead-of-is_err.patch
* revert-lib-test_sortc-make-it-explicitly-non-modular.patch
* lib-add-module-support-to-array-based-sort-tests.patch
* lib-add-module-support-to-linked-list-sorting-tests.patch
* firmware-makefile-force-recompilation-if-makefile-changes.patch
* checkpatch-remove-obsolete-config_experimental-checks.patch
* checkpatch-add-ability-to-find-bad-uses-of-vsprintf-%pfoo-extensions.patch
* checkpatch-add-ability-to-find-bad-uses-of-vsprintf-%pfoo-extensions-fix.patch
* checkpatch-add-ability-to-find-bad-uses-of-vsprintf-%pfoo-extensions-fix-fix.patch
* checkpatch-improve-embedded_function_name-test.patch
* checkpatch-allow-space-leading-blank-lines-in-email-headers.patch
* checkpatch-avoid-suggesting-struct-definitions-should-be-const.patch
* checkpatch-improve-multistatement_macro_use_do_while-test.patch
* checkpatch-clarify-the-embedded_function_name-message.patch
* checkpatch-special-audit-for-revert-commit-line.patch
* checkpatch-improve-kalloc-with-multiplication-and-sizeof-test.patch
* checkpatch-add-typedefsfile.patch
* checkpatch-improve-the-embedded-function-name-test-for-patch-contexts.patch
* checkpatch-improve-the-suspect_code_indent-test.patch
* reiserfs-use-designated-initializers.patch
* fork-free-vmapped-stacks-in-cache-when-cpus-are-offline.patch
* cpumask-make-nr_cpumask_bits-unsigned.patch
* crash-move-crashkernel-parsing-and-vmcore-related-code-under-config_crash_core.patch
* ia64-reuse-append_elf_note-and-final_note-functions.patch
* powerpc-fadump-remove-dependency-with-config_kexec.patch
* powerpc-fadump-reuse-crashkernel-parameter-for-fadump-memory-reservation.patch
* powerpc-fadump-update-documentation-about-crashkernel-parameter-reuse.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* uapi-fix-linux-sysctlh-userspace-compilation-errors.patch
* pidns-disable-pid-allocation-if-pid_ns_prepare_proc-is-failed-in-alloc_pid.patch
* ns-allow-ns_entries-to-have-custom-symlink-content.patch
* pidns-expose-task-pid_ns_for_children-to-userspace.patch
* taskstats-add-e-u-stime-for-tgid-command.patch
* taskstats-add-e-u-stime-for-tgid-command-fix.patch
* taskstats-add-e-u-stime-for-tgid-command-fix-fix.patch
* kcov-simplify-interrupt-check.patch
* scripts-gdb-add-lx-fdtdump-command.patch
* kernel-reboot-add-devm_register_reboot_notifier.patch
* kernel-reboot-add-devm_register_reboot_notifier-fix.patch
* fault-inject-use-correct-check-for-interrupts.patch
* fault-inject-support-systematic-fault-injection.patch
* fault-inject-support-systematic-fault-injection-fix.patch
* fault-inject-automatically-detect-the-number-base-for-fail-nth-write-interface.patch
* fault-inject-parse-as-natural-1-based-value-for-fail-nth-write-interface.patch
* fault-inject-make-fail-nth-read-write-interface-symmetric.patch
* fault-inject-simplify-access-check-for-fail-nth.patch
* fault-inject-simplify-access-check-for-fail-nth-fix.patch
* fault-inject-add-proc-pid-fail-nth.patch
* zlib-inflate-fix-potential-buffer-overflow.patch
* initramfs-provide-a-way-to-ignore-image-provided-by-bootloader.patch
* initramfs-use-vfs_stat-lstat-directly.patch
* ipc-shm-some-shmat-cleanups.patch
* sysvipc-cacheline-align-kern_ipc_perm.patch
  linux-next.patch
  linux-next-git-rejects.patch
* imx7-fix-kconfig-warning-and-build-errors.patch
* sparc64-ng4-memset-32-bits-overflow.patch
* mm-zeroing-hash-tables-in-allocator.patch
* mm-updated-callers-to-use-hash_zero-flag.patch
* mm-adaptive-hash-table-scaling.patch
* mm-introduce-kvalloc-helpers.patch
* mm-introduce-kvalloc-helpers-fix.patch
* mm-vmalloc-properly-track-vmalloc-users.patch
* mm-support-__gfp_repeat-in-kvmalloc_node-for-32kb.patch
* rhashtable-simplify-a-strange-allocation-pattern.patch
* ila-simplify-a-strange-allocation-pattern.patch
* xattr-zero-out-memory-copied-to-userspace-in-getxattr.patch
* treewide-use-kvalloc-rather-than-opencoded-variants.patch
* net-use-kvmalloc-with-__gfp_repeat-rather-than-open-coded-variant.patch
* md-use-kvmalloc-rather-than-opencoded-variant.patch
* bcache-use-kvmalloc.patch
* mm-swap-use-kvzalloc-to-allocate-some-swap-data-structure.patch
* mm-vmalloc-use-__gfp_highmem-implicitly.patch
* scripts-spellingtxt-add-memory-pattern-and-fix-typos.patch
* scripts-spellingtxt-add-regsiter-register-spelling-mistake.patch
* scripts-spellingtxt-add-intialised-pattern-and-fix-typo-instances.patch
* treewide-correct-diffrent-and-banlance-typos.patch
* treewide-move-set_memory_-functions-away-from-cacheflushh.patch
* arm-use-set_memoryh-header.patch
* arm64-use-set_memoryh-header.patch
* s390-use-set_memoryh-header.patch
* x86-use-set_memoryh-header.patch
* agp-use-set_memoryh-header.patch
* drm-use-set_memoryh-header.patch
* drm-use-set_memoryh-header-fix.patch
* intel_th-use-set_memoryh-header.patch
* watchdog-hpwdt-use-set_memoryh-header.patch
* bpf-use-set_memoryh-header.patch
* module-use-set_memoryh-header.patch
* pm-hibernate-use-set_memoryh-header.patch
* alsa-use-set_memoryh-header.patch
* misc-sram-use-set_memoryh-header.patch
* video-vermilion-use-set_memoryh-header.patch
* drivers-staging-media-atomisp-pci-atomisp2-use-set_memoryh.patch
* treewide-decouple-cacheflushh-and-set_memoryh.patch
* treewide-decouple-cacheflushh-and-set_memoryh-fix.patch
* kref-remove-warn_on-for-null-release-functions.patch
* megasas-remove-expensive-inline-from-megasas_return_cmd.patch
* remove-expensive-warn_on-in-pagefault_disabled_dec.patch
* fs-remove-set-but-not-checked-aop_flag_uninterruptible-flag.patch
* docs-vm-transhuge-fix-few-trivial-typos.patch
* docs-vm-transhuge-fix-few-trivial-typos-fix.patch
* format-security-move-static-strings-to-const.patch
* fs-f2fs-use-ktime_get_real_seconds-for-sit_info-times.patch
* trace-make-trace_hwlat-timestamp-y2038-safe.patch
* fs-cifs-replace-current_time-by-other-appropriate-apis.patch
* fs-ceph-current_time-with-ktime_get_real_ts.patch
* fs-ufs-use-ktime_get_real_ts64-for-birthtime.patch
* fs-ubifs-replace-current_time_sec-with-current_time.patch
* lustre-replace-current_time-macro.patch
* apparmorfs-replace-current_time-with-current_time.patch
* gfs2-replace-current_time-with-current_time.patch
* time-delete-current_time_sec-and-current_time.patch
* time-delete-current_fs_time-function.patch
* mm-huge_memory-use-zap_deposited_table-more.patch
* mm-huge_memory-deposit-a-pgtable-for-dax-pmd-faults-when-required.patch
* mm-prevent-potential-recursive-reclaim-due-to-clearing-pf_memalloc.patch
* mm-introduce-memalloc_noreclaim_saverestore.patch
* treewide-convert-pf_memalloc-manipulations-to-new-helpers.patch
* treewide-convert-pf_memalloc-manipulations-to-new-helpers-fix.patch
* mtd-nand-nandsim-convert-to-memalloc_noreclaim_.patch
* dax-add-tracepoints-to-dax_iomap_pte_fault.patch
* dax-add-tracepoints-to-dax_pfn_mkwrite.patch
* dax-add-tracepoints-to-dax_load_hole.patch
* dax-add-tracepoints-to-dax_writeback_mapping_range.patch
* dax-add-tracepoints-to-dax_writeback_mapping_range-fix.patch
* dax-add-tracepoint-to-dax_writeback_one.patch
* dax-add-tracepoint-to-dax_writeback_one-fix.patch
* dax-add-tracepoint-to-dax_insert_mapping.patch
* selftests-vm-add-a-test-for-virtual-address-range-mapping.patch
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
