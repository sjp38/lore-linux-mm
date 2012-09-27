Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id C9C166B0068
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 19:58:52 -0400 (EDT)
Received: by favv1 with SMTP id v1so159756fav.2
        for <linux-mm@kvack.org>; Thu, 27 Sep 2012 16:58:51 -0700 (PDT)
Subject: mmotm 2012-09-27-16-57 uploaded
From: akpm@linux-foundation.org
Date: Thu, 27 Sep 2012 16:58:48 -0700
Message-Id: <20120927235849.337795C0050@hpza9.eem.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

The mm-of-the-moment snapshot 2012-09-27-16-57 has been uploaded to

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


This mmotm tree contains the following patches against 3.6-rc7:
(patches marked "*" will be included in linux-next)

  origin.patch
* thp-avoid-vm_bug_on-page_countpage-false-positives-in-__collapse_huge_page_copy.patch
  linux-next.patch
  i-need-old-gcc.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
* cris-fix-i-o-macros.patch
* selinux-fix-sel_netnode_insert-suspicious-rcu-dereference.patch
* vfs-d_obtain_alias-needs-to-use-as-default-name.patch
* cpu_hotplug-unmap-cpu2node-when-the-cpu-is-hotremoved.patch
* cpu_hotplug-unmap-cpu2node-when-the-cpu-is-hotremoved-fix.patch
* acpi_memhotplugc-fix-memory-leak-when-memory-device-is-unbound-from-the-module-acpi_memhotplug.patch
* acpi_memhotplugc-free-memory-device-if-acpi_memory_enable_device-failed.patch
* acpi_memhotplugc-remove-memory-info-from-list-before-freeing-it.patch
* acpi_memhotplugc-dont-allow-to-eject-the-memory-device-if-it-is-being-used.patch
* acpi_memhotplugc-bind-the-memory-device-when-the-driver-is-being-loaded.patch
* acpi_memhotplugc-auto-bind-the-memory-device-which-is-hotplugged-before-the-driver-is-loaded.patch
* arch-x86-platform-iris-irisc-register-a-platform-device-and-a-platform-driver.patch
* x86-numa-dont-check-if-node-is-numa_no_node.patch
* arch-x86-tools-insn_sanityc-identify-source-of-messages.patch
* uv-fix-incorrect-tlb-flush-all-issue.patch
* audith-replace-defines-with-c-stubs.patch
* audith-replace-defines-with-c-stubs-fix.patch
* mn10300-only-add-mmem-funcs-to-kbuild_cflags-if-gcc-supports-it.patch
* fs-debugsfs-remove-unnecessary-inode-i_private-initialization.patch
* dma-dmaengine-lower-the-priority-of-failed-to-get-dma-channel-message.patch
* pcmcia-move-unbind-rebind-into-dev_pm_opscomplete.patch
* drm-i915-optimize-div_round_closest-call.patch
* gpu-drm-ttm-use-copy_highpage.patch
  cyber2000fb-avoid-palette-corruption-at-higher-clocks.patch
* timeconstpl-remove-deprecated-defined-array.patch
* time-dont-inline-export_symbol-functions.patch
* kbuild-make-fix-if_changed-when-command-contains-backslashes.patch
* compiler-gcc4h-correct-verion-check-for-__compiletime_error.patch
* h8300-select-generic-atomic64_t-support.patch
* thermal-exynos-fix-null-pointer-dereference-in-exynos_unregister_thermal.patch
* drivers-thermal-step_wisec-add-missing-static-storage-class-specifiers.patch
* drivers-thermal-fair_sharec-add-missing-static-storage-class-specifiers.patch
* drivers-thermal-user_spacec-add-missing-static-storage-class-specifiers.patch
* unicore32-select-generic-atomic64_t-support.patch
* rapidio-rionet-fix-multicast-packet-transmit-logic.patch
* readahead-fault-retry-breaks-mmap-file-read-random-detection.patch
* drivers-scsi-atp870uc-fix-bad-use-of-udelay.patch
* cciss-cleanup-bitops-usage.patch
* cciss-use-check_signature.patch
* block-store-partition_meta_infouuid-as-a-string.patch
* init-reduce-partuuid-min-length-to-1-from-36.patch
* block-partition-msdos-provide-uuids-for-partitions.patch
* drbd-use-copy_highpage.patch
* vfs-increment-iversion-when-a-file-is-truncated.patch
* fs-push-rcu_barrier-from-deactivate_locked_super-to-filesystems.patch
* fs-change-return-values-from-eacces-to-eperm.patch
* fs-block_devc-need-not-to-check-inode-i_bdev-in-bd_forget.patch
* mm-slab-remove-duplicate-check.patch
  mm.patch
* mm-memoryc-squash-unused-variable-warning.patch
* mm-remove-__gfp_no_kswapd.patch
* x86-pat-remove-the-dependency-on-vm_pgoff-in-track-untrack-pfn-vma-routines.patch
* x86-pat-separate-the-pfn-attribute-tracking-for-remap_pfn_range-and-vm_insert_pfn.patch
* x86-pat-separate-the-pfn-attribute-tracking-for-remap_pfn_range-and-vm_insert_pfn-fix.patch
* mm-x86-pat-rework-linear-pfn-mmap-tracking.patch
* mm-introduce-arch-specific-vma-flag-vm_arch_1.patch
* mm-kill-vma-flag-vm_insertpage.patch
* mm-kill-vma-flag-vm_can_nonlinear.patch
* mm-use-mm-exe_file-instead-of-first-vm_executable-vma-vm_file.patch
* mm-kill-vma-flag-vm_executable-and-mm-num_exe_file_vmas.patch
* mm-prepare-vm_dontdump-for-using-in-drivers.patch
* mm-kill-vma-flag-vm_reserved-and-mm-reserved_vm-counter.patch
* mm-kill-vma-flag-vm_reserved-and-mm-reserved_vm-counter-fix.patch
* mm-fix-nonuniform-page-status-when-writing-new-file-with-small-buffer.patch
* mm-fix-nonuniform-page-status-when-writing-new-file-with-small-buffer-fix.patch
* mm-fix-nonuniform-page-status-when-writing-new-file-with-small-buffer-fix-fix.patch
* mm-mmapc-replace-find_vma_prepare-with-clearer-find_vma_links.patch
* mm-mmapc-replace-find_vma_prepare-with-clearer-find_vma_links-fix.patch
* mm-compaction-update-comment-in-try_to_compact_pages.patch
* mm-vmscan-scale-number-of-pages-reclaimed-by-reclaim-compaction-based-on-failures.patch
* mm-vmscan-scale-number-of-pages-reclaimed-by-reclaim-compaction-based-on-failures-fix.patch
* mm-compaction-capture-a-suitable-high-order-page-immediately-when-it-is-made-available.patch
* revert-mm-mempolicy-let-vma_merge-and-vma_split-handle-vma-vm_policy-linkages.patch
* mempolicy-remove-mempolicy-sharing.patch
* mempolicy-fix-a-race-in-shared_policy_replace.patch
* mempolicy-fix-refcount-leak-in-mpol_set_shared_policy.patch
* mempolicy-fix-a-memory-corruption-by-refcount-imbalance-in-alloc_pages_vma.patch
* mempolicy-fix-a-memory-corruption-by-refcount-imbalance-in-alloc_pages_vma-v2.patch
* mm-mmu_notifier-fix-inconsistent-memory-between-secondary-mmu-and-host.patch
* mm-mmu_notifier-fix-inconsistent-memory-between-secondary-mmu-and-host-fix.patch
* mm-mmu_notifier-have-mmu_notifiers-use-a-global-srcu-so-they-may-safely-schedule.patch
* mm-mmu_notifier-init-notifier-if-necessary.patch
* mm-mmu_notifier-init-notifier-if-necessary-v2.patch
* mm-vmscan-fix-error-number-for-failed-kthread.patch
* oom-remove-deprecated-oom_adj.patch
* mm-hugetlb-add-arch-hook-for-clearing-page-flags-before-entering-pool.patch
* mm-adjust-final-endif-position-in-mm-internalh.patch
* thp-fix-the-count-of-thp_collapse_alloc.patch
* thp-remove-unnecessary-check-in-start_khugepaged.patch
* thp-move-khugepaged_mutex-out-of-khugepaged.patch
* thp-remove-unnecessary-khugepaged_thread-check.patch
* thp-remove-wake_up_interruptible-in-the-exit-path.patch
* thp-remove-some-code-depend-on-config_numa.patch
* thp-merge-page-pre-alloc-in-khugepaged_loop-into-khugepaged_do_scan.patch
* thp-release-page-in-page-pre-alloc-path.patch
* thp-introduce-khugepaged_prealloc_page-and-khugepaged_alloc_page.patch
* thp-remove-khugepaged_loop.patch
* thp-use-khugepaged_enabled-to-remove-duplicate-code.patch
* thp-remove-unnecessary-set_recommended_min_free_kbytes.patch
* mm-fix-potential-anon_vma-locking-issue-in-mprotect.patch
* thp-x86-introduce-have_arch_transparent_hugepage.patch
* thp-remove-assumptions-on-pgtable_t-type.patch
* thp-introduce-pmdp_invalidate.patch
* thp-make-madv_hugepage-check-for-mm-def_flags.patch
* thp-s390-thp-splitting-backend-for-s390.patch
* thp-s390-thp-pagetable-pre-allocation-for-s390.patch
* thp-s390-disable-thp-for-kvm-host-on-s390.patch
* thp-s390-architecture-backend-for-thp-on-s390.patch
* thp-s390-architecture-backend-for-thp-on-s390-fix.patch
* ipc-mqueue-remove-unnecessary-rb_init_node-calls.patch
* rbtree-reference-documentation-rbtreetxt-for-usage-instructions.patch
* rbtree-empty-nodes-have-no-color.patch
* rbtree-empty-nodes-have-no-color-fix.patch
* rbtree-fix-incorrect-rbtree-node-insertion-in-fs-proc-proc_sysctlc.patch
* rbtree-move-some-implementation-details-from-rbtreeh-to-rbtreec.patch
* rbtree-move-some-implementation-details-from-rbtreeh-to-rbtreec-fix.patch
* rbtree-performance-and-correctness-test.patch
* rbtree-performance-and-correctness-test-fix.patch
* rbtree-break-out-of-rb_insert_color-loop-after-tree-rotation.patch
* rbtree-adjust-root-color-in-rb_insert_color-only-when-necessary.patch
* rbtree-low-level-optimizations-in-rb_insert_color.patch
* rbtree-adjust-node-color-in-__rb_erase_color-only-when-necessary.patch
* rbtree-adjust-root-color-in-rb_insert_color-only-when-necessary-fix.patch
* rbtree-optimize-case-selection-logic-in-__rb_erase_color.patch
* rbtree-low-level-optimizations-in-__rb_erase_color.patch
* rbtree-coding-style-adjustments.patch
* rbtree-optimize-fetching-of-sibling-node.patch
* rbtree-test-fix-sparse-warning-about-64-bit-constant.patch
* rbtree-add-__rb_change_child-helper-function.patch
* rbtree-place-easiest-case-first-in-rb_erase.patch
* rbtree-handle-1-child-recoloring-in-rb_erase-instead-of-rb_erase_color.patch
* rbtree-low-level-optimizations-in-rb_erase.patch
* rbtree-augmented-rbtree-test.patch
* rbtree-faster-augmented-rbtree-manipulation.patch
* rbtree-remove-prior-augmented-rbtree-implementation.patch
* rbtree-add-rb_declare_callbacks-macro.patch
* rbtree-add-prio-tree-and-interval-tree-tests.patch
* mm-replace-vma-prio_tree-with-an-interval-tree.patch
* kmemleak-use-rbtree-instead-of-prio-tree.patch
* prio_tree-remove.patch
* rbtree-move-augmented-rbtree-functionality-to-rbtree_augmentedh.patch
* mm-interval-tree-updates.patch
* mm-anon-rmap-remove-anon_vma_moveto_tail.patch
* mm-anon-rmap-replace-same_anon_vma-linked-list-with-an-interval-tree.patch
* mm-rmap-remove-vma_address-check-for-address-inside-vma.patch
* mm-add-config_debug_vm_rb-build-option.patch
* mm-anon-rmap-in-mremap-set-the-new-vmas-position-before-anon_vma_clone.patch
* mm-avoid-taking-rmap-locks-in-move_ptes.patch
* memory-hotplug-build-zonelists-when-offlining-pages.patch
* mm-mmu_notifier-make-the-mmu_notifier-srcu-static.patch
* mm-cma-discard-clean-pages-during-contiguous-allocation-instead-of-migration.patch
* mm-cma-discard-clean-pages-during-contiguous-allocation-instead-of-migration-fix.patch
* mm-cma-discard-clean-pages-during-contiguous-allocation-instead-of-migration-fix-fix.patch
* mm-fix-tracing-in-free_pcppages_bulk.patch
* mm-fix-tracing-in-free_pcppages_bulk-fix.patch
* cma-fix-counting-of-isolated-pages.patch
* cma-count-free-cma-pages.patch
* cma-count-free-cma-pages-fix.patch
* cma-fix-watermark-checking.patch
* cma-fix-watermark-checking-fix.patch
* mm-page_alloc-use-get_freepage_migratetype-instead-of-page_private.patch
* mm-remain-migratetype-in-freed-page.patch
* memory-hotplug-bug-fix-race-between-isolation-and-allocation.patch
* memory-hotplug-fix-pages-missed-by-race-rather-than-failing.patch
* memory-hotplug-fix-pages-missed-by-race-rather-than-failng-fix.patch
* atomic-implement-generic-atomic_dec_if_positive.patch
* atomic-implement-generic-atomic_dec_if_positive-fix.patch
* swap-add-a-simple-detector-for-inappropriate-swapin-readahead.patch
* swap-add-a-simple-detector-for-inappropriate-swapin-readahead-fix.patch
* mm-memblock-reduce-overhead-in-binary-search.patch
* mm-memblock-use-existing-interface-to-set-nid.patch
* mm-memblock-cleanup-early_node_map-related-comments.patch
* mm-compaction-abort-compaction-loop-if-lock-is-contended-or-run-too-long.patch
* mm-compaction-abort-compaction-loop-if-lock-is-contended-or-run-too-long-fix.patch
* mm-compaction-abort-compaction-loop-if-lock-is-contended-or-run-too-long-fix-2.patch
* mm-compaction-move-fatal-signal-check-out-of-compact_checklock_irqsave.patch
* mm-compaction-update-try_to_compact_pageskerneldoc-comment.patch
* mm-compaction-acquire-the-zone-lru_lock-as-late-as-possible.patch
* mm-compaction-acquire-the-zone-lru_lock-as-late-as-possible-fix.patch
* mm-compaction-acquire-the-zone-lru_lock-as-late-as-possible-fix-fix.patch
* mm-compaction-acquire-the-zone-lock-as-late-as-possible.patch
* mm-compaction-acquire-the-zone-lock-as-late-as-possible-fix-2.patch
* revert-mm-have-order-0-compaction-start-off-where-it-left.patch
* mm-compaction-cache-if-a-pageblock-was-scanned-and-no-pages-were-isolated.patch
* mm-compaction-cache-if-a-pageblock-was-scanned-and-no-pages-were-isolated-fix.patch
* mm-compaction-cache-if-a-pageblock-was-scanned-and-no-pages-were-isolated-fix2.patch
* mm-compaction-restart-compaction-from-near-where-it-left-off.patch
* mm-compaction-restart-compaction-from-near-where-it-left-off-fix.patch
* mm-compaction-clear-pg_migrate_skip-based-on-compaction-and-reclaim-activity.patch
* mm-hugetlbc-remove-duplicate-inclusion-of-header-file.patch
* mm-page_alloc-refactor-out-__alloc_contig_migrate_alloc.patch
* mm-page_alloc-refactor-out-__alloc_contig_migrate_alloc-checkpatch-fixes.patch
* memory-hotplug-dont-replace-lowmem-pages-with-highmem.patch
* thp-khugepaged_prealloc_page-forgot-to-reset-the-page-alloc-indicator.patch
* mm-thp-fix-the-pmd_clear-arguments-in-pmdp_get_and_clear.patch
* mm-thp-fix-the-update_mmu_cache-last-argument-passing-in-mm-huge_memoryc.patch
* mm-enable-config_compaction-by-default.patch
* mm-fix-up-zone-present-pages.patch
* memcg-trivial-fixes-for-documentation-cgroups-memorytxt.patch
* memcg-cleanup-kmem-tcp-ifdefs.patch
* memcg-move-mem_cgroup_is_root-upwards.patch
* mm-fix-invalidate_complete_page2-lock-ordering.patch
* mm-remove-vma-arg-from-page_evictable.patch
* mm-clear_page_mlock-in-page_remove_rmap.patch
* mm-remove-free_page_mlock.patch
* mm-numa-reclaim-from-all-nodes-within-reclaim-distance.patch
* mm-numa-reclaim-from-all-nodes-within-reclaim-distance-fix.patch
* mm-numa-reclaim-from-all-nodes-within-reclaim-distance-fix-fix.patch
* memorytxt-remove-stray-information.patch
* mm-thp-fix-pmd_present-for-split_huge_page-and-prot_none-with-thp.patch
* hugetlb-do-not-use-vma_hugecache_offset-for-vma_prio_tree_foreach.patch
* mm-move-all-mmu-notifier-invocations-to-be-done-outside-the-pt-lock.patch
* mm-wrap-calls-to-set_pte_at_notify-with-invalidate_range_start-and-invalidate_range_end.patch
* mm-wrap-calls-to-set_pte_at_notify-with-invalidate_range_start-and-invalidate_range_end-fix.patch
* mm-revert-0def08e3-mm-mempolicyc-check-return-code-of-check_range.patch
* mm-revert-0def08e3-mm-mempolicyc-check-return-code-of-check_range-fix.patch
* memory-hotplug-fix-zone-stat-mismatch.patch
* mm-remove-unevictable_pgs_mlockfreed.patch
* ksm-numa-awareness-sysfs-knob.patch
* mm-memoryc-fix-typo-in-comment.patch
* fs-fs-writebackc-remove-unneccesary-parameter-of-__writeback_single_inode.patch
* kpageflags-fix-wrong-kpf_thp-on-non-huge-compound-pages.patch
* cma-migrate-mlocked-pages.patch
* cma-decrease-ccnr_migratepages-after-reclaiming-pagelist.patch
* sections-disable-const-sections-for-pa-risc-v2.patch
* sections-fix-section-conflicts-in-arch-arm.patch
* sections-fix-section-conflicts-in-arch-frv.patch
* sections-fix-section-conflicts-in-arch-h8300.patch
* sections-fix-section-conflicts-in-arch-h8300-checkpatch-fixes.patch
* sections-fix-section-conflicts-in-arch-ia64.patch
* sections-fix-section-conflicts-in-arch-mips.patch
* sections-fix-section-conflicts-in-arch-powerpc.patch
* sections-fix-section-conflicts-in-arch-score.patch
* sections-fix-section-conflicts-in-arch-sh.patch
* sections-fix-section-conflicts-in-arch-sh-fix.patch
* sections-fix-section-conflicts-in-arch-x86.patch
* sections-fix-section-conflicts-in-drivers-atm.patch
* sections-fix-section-conflicts-in-drivers-char.patch
* sections-fix-section-conflicts-in-drivers-ide.patch
* sections-fix-section-conflicts-in-drivers-macintosh.patch
* sections-fix-section-conflicts-in-drivers-macintosh-checkpatch-fixes.patch
* sections-fix-section-conflicts-in-drivers-mfd.patch
* sections-fix-section-conflicts-in-drivers-mmc.patch
* sections-fix-section-conflicts-in-drivers-net.patch
* sections-fix-section-conflicts-in-drivers-net-hamradio.patch
* sections-fix-section-conflicts-in-drivers-net-wan.patch
* sections-fix-section-conflicts-in-drivers-platform-x86.patch
* sections-fix-section-conflicts-in-drivers-scsi.patch
* sections-fix-section-conflicts-in-drivers-video.patch
* sections-fix-section-conflicts-in-mm-percpuc.patch
* sections-fix-section-conflicts-in-net-can.patch
* sections-fix-section-conflicts-in-net.patch
* sections-fix-section-conflicts-in-sound.patch
* sectons-fix-const-sections-for-crc32-table.patch
* sectons-fix-const-sections-for-crc32-table-checkpatch-fixes.patch
* frv-kill-used-but-uninitialized-variable.patch
* score-select-generic-atomic64_t-support.patch
* cross-arch-dont-corrupt-personality-flags-upon-exec.patch
* tile-fix-personality-bits-handling-upon-exec.patch
* kernel-sysc-call-disable_nonboot_cpus-in-kernel_restart.patch
* poweroff-fix-bug-in-orderly_poweroff.patch
* lib-vsprintf-optimize-division-by-10-for-small-integers.patch
* lib-vsprintf-optimize-division-by-10000.patch
* lib-vsprintf-optimize-put_dec_trunc8.patch
* lib-vsprintf-optimize-put_dec_trunc8-fix.patch
* lib-vsprintf-fix-broken-comments.patch
* lib-vsprintf-update-documentation-to-cover-all-of-%p.patch
* maintainers-update-gpio-subsystem-file-list.patch
* maintainers-add-defconfig-file-to-imx-section.patch
* maintainers-update-gianfar_ptp-after-renaming.patch
* maintainers-fix-indentation-for-viresh-kumar.patch
* drivers-video-backlight-da9052_blc-use-usleep_range-instead-of-msleep-for-small-sleeps.patch
* drivers-video-backlight-ltv350qvc-use-usleep_range-instead-of-msleep-for-small-sleeps.patch
* drivers-video-backlight-kb3886_blc-use-usleep_range-instead-of-msleep-for-small-sleeps.patch
* backlight-lp855x-add-fast-bit-description-for-lp8556.patch
* backlight-add-backlight-driver-for-lm3630-chip.patch
* backlight-add-backlight-driver-for-lm3630-chip-fix.patch
* backlight-add-new-lm3639-backlight-driver.patch
* backlight-add-new-lm3639-backlight-driver-fix.patch
* backlight-add-new-lm3639-backlight-driver-fix-2.patch
* backlight-remove-progear-driver.patch
* drivers-video-backlight-da9052_blc-drop-devm_kfree-of-devm_kzallocd-data.patch
* backlight-platform-lcd-add-support-for-device-tree-based-probe.patch
* backlight-platform-lcd-add-support-for-device-tree-based-probe-fix.patch
* pwm_backlight-add-device-tree-support-for-low-threshold-brightness.patch
* pwm_backlight-add-device-tree-support-for-low-threshold-brightness-fix.patch
* sfc-use-standard-__clearset_bit_le-functions.patch
* drivers-net-ethernet-dec-tulip-use-standard-__set_bit_le-function.patch
* bitops-introduce-generic-clearset_bit_le.patch
* powerpc-bitops-introduce-clearset_bit_le.patch
* kvm-replace-test_and_set_bit_le-in-mark_page_dirty_in_slot-with-set_bit_le.patch
* idr-rename-max_level-to-max_idr_level.patch
* idr-rename-max_level-to-max_idr_level-fix.patch
* idr-rename-max_level-to-max_idr_level-fix-fix-2.patch
* idr-rename-max_level-to-max_idr_level-fix-fix-2-fix.patch
* idr-rename-max_level-to-max_idr_level-fix-3.patch
* lib-parserc-avoid-overflow-in-match_number.patch
* lib-parserc-avoid-overflow-in-match_number-fix.patch
* adjust-hard-lockup-related-kconfig-options.patch
* lib-gcdc-prevent-possible-div-by-0.patch
* genalloc-make-it-possible-to-use-a-custom-allocation-algorithm.patch
* lib-spinlock_debug-avoid-livelock-in-do_raw_spin_lock.patch
* lib-spinlock_debug-avoid-livelock-in-do_raw_spin_lock-fix.patch
* lib-vsprintfc-improve-standard-conformance-of-sscanf.patch
* plist-make-plist-test-announcements-kern_debug.patch
* scatterlist-atomic-sg_mapping_iter-no-longer-needs-disabled-irqs.patch
* drivers-firmware-dmi_scanc-check-dmi-version-when-get-system-uuid.patch
* drivers-firmware-dmi_scanc-check-dmi-version-when-get-system-uuid-fix.patch
* drivers-firmware-dmi_scanc-fetch-dmi-version-from-smbios-if-it-exists.patch
* drivers-firmware-dmi_scanc-fetch-dmi-version-from-smbios-if-it-exists-checkpatch-fixes.patch
* checkpatch-check-utf-8-content-from-a-commit-log-when-its-missing-from-charset.patch
* checkpatch-update-suggested-printk-conversions.patch
* checkpatch-check-networking-specific-block-comment-style.patch
* codingstyle-add-networking-specific-block-comment-style.patch
* epoll-support-for-disabling-items-and-a-self-test-app.patch
* binfmt_elf-uninitialized-variable.patch
* drivers-rtc-rtc-isl1208c-add-support-for-the-isl1218.patch
* rtc-proc-permit-the-proc-driver-rtc-device-to-use-other-devices.patch
* rtc-add-dallas-ds2404-driver.patch
* rtc-add-dallas-ds2404-driver-fix.patch
* rtc-snvs-add-freescale-rtc-snvs-driver.patch
* rtc-snvs-add-freescale-rtc-snvs-driver-fix.patch
* rtc-recycle-id-when-unloading-a-rtc-driver.patch
* rtc-at91sam9-use-module_platform_driver-macro.patch
* rtc-tps65910-add-rtc-driver-for-tps65910-pmic-rtc.patch
* rtc-tps65910-add-rtc-driver-for-tps65910-pmic-rtc-fix.patch
* rtc-add-max8907-rtc-driver.patch
* rtc-kconfig-remove-unnecessary-dependencies.patch
* drivers-rtc-rtc-jz4740c-fix-irq-error-check.patch
* drivers-rtc-rtc-spearc-fix-several-error-checks.patch
* rtc-rc5t583-add-ricoh-rc5t583-rtc-driver.patch
* drivers-rtc-rtc-coh901331c-use-clk_prepare_enable-and-clk_disable_unprepare.patch
* rtc-rtc-mxc-adapt-to-the-new-imx-clock-framework.patch
* rtc-rtc-mxc-convert-to-module_platform_driver.patch
* rtc_sysfs_show_hctosys-return-0-if-resume-failed.patch
* rtc_sysfs_show_hctosys-return-0-if-resume-failed-fix.patch
* rtc_sysfs_show_hctosys-return-0-if-resume-failed-fix-fix.patch
* drivers-rtc-rtc-s3cc-fix-return-value-in-s3c_rtc_probe.patch
* drivers-rtc-rtc-ds1672c-convert-struct-i2c_msg-initialization-to-c99-format.patch
* drivers-rtc-rtc-x1205c-convert-struct-i2c_msg-initialization-to-c99-format.patch
* drivers-rtc-rtc-s35390ac-convert-struct-i2c_msg-initialization-to-c99-format.patch
* drivers-rtc-rtc-rs5c372c-convert-struct-i2c_msg-initialization-to-c99-format.patch
* drivers-rtc-rtc-pcf8563c-convert-struct-i2c_msg-initialization-to-c99-format.patch
* drivers-rtc-rtc-isl1208c-convert-struct-i2c_msg-initialization-to-c99-format.patch
* drivers-rtc-rtc-em3027c-convert-struct-i2c_msg-initialization-to-c99-format.patch
* rtc-kconfig-fixup-dependency-for-ab8500.patch
* drivers-rtc-rtc-tps65910c-use-platform_get_irq-to-get-rtc-irq-details.patch
* drivers-rtc-rtc-m41t80c-remove-disabled-alarm-functionality.patch
* drivers-rtc-rtc-s35390ac-add-wakealarm-support-for-rtc-s35390a-rtc-chip.patch
* hfsplus-add-on-disk-layout-declarations-related-to-attributes-tree.patch
* hfsplus-add-functionality-of-manipulating-by-records-in-attributes-tree.patch
* hfsplus-rework-functionality-of-getting-setting-and-deleting-of-extended-attributes.patch
* hfsplus-add-support-of-manipulation-by-attributes-file.patch
* hfsplus-add-support-of-manipulation-by-attributes-file-checkpatch-fixes.patch
* hfsplus-code-style-fixes-reworked-support-of-extended-attributes.patch
* fat-use-accessor-function-for-msdos_dir_entry-start.patch
* fat-exportfs-move-nfs-support-code.patch
* fat-exportfs-fix-dentry-reconnection.patch
* fs-fat-fix-a-checkpatch-issue-in-namei_msdosc.patch
* fs-fat-fix-some-checkpatch-issues-in-fath.patch
* fs-fat-changed-indentation-of-some-comments-in-fath.patch
* fs-fat-fix-two-checkpatch-issues-in-cachec.patch
* fs-fat-fixes-some-small-checkpatch-issues-in-dirc.patch
* fs-fat-fix-all-other-checkpatch-issues-in-dirc.patch
* fs-fat-fix-all-other-checkpatch-issues-in-dirc-fix.patch
* fs-fat-fix-checkpatch-issues-in-fatentc.patch
* fat-no-need-to-reset-eof-in-ent_put-for-fat32.patch
* fat-simplify-writeback_inode.patch
* fat-simplify-writeback_inode-checkpatch-fixes.patch
* fat-simplify-writeback_inode-checkpatch-fixes-fix.patch
* device_cgroup-add-deny_all-in-dev_cgroup-structure.patch
* device_cgroup-introduce-dev_whitelist_clean.patch
* device_cgroup-convert-device_cgroup-internally-to-policy-exceptions.patch
* device_cgroup-rename-whitelist-to-exception-list.patch
* coredump-prevent-double-free-on-an-error-path-in-core-dumper.patch
* coredump-move-core-dump-functionality-into-its-own-file.patch
* coredump-make-core-dump-functionality-optional.patch
* coredump-make-core-dump-functionality-optional-fix.patch
* coredump-make-core-dump-functionality-optional-fix-fix.patch
* coredump-update-coredump-related-headers.patch
* coredump-add-support-for-%d=__get_dumpable-in-core-name.patch
* coredump-add-support-for-%d=__get_dumpable-in-core-name-fix.patch
* coredump-use-suid_dumpable_enabled-rather-than-hardcoded-1.patch
* coredump-use-suid_dumpable_enabled-rather-than-hardcoded-1-checkpatch-fixes.patch
* coredump-pass-siginfo_t-to-do_coredump-and-below-not-merely-signr.patch
* compat-move-compat_siginfo_t-definition-to-asm-compath.patch
* coredump-add-a-new-elf-note-with-siginfo-of-the-signal.patch
* coredump-extend-core-dump-note-section-to-contain-file-names-of-mapped-files.patch
* proc-return-enomem-when-inode-allocation-failed.patch
* proc-no-need-to-initialize-proc_inode-fd-in-proc_get_inode.patch
* proc-use-kzalloc-instead-of-kmalloc-and-memset.patch
* proc-use-kzalloc-instead-of-kmalloc-and-memset-fix.patch
* proc_sysctlc-use-bug_on-instead-of-bug.patch
* proc-use-null-instead-of-0-for-pointer.patch
* kdump-remove-unneeded-include.patch
* ipc-semc-alternatives-to-preempt_disable.patch
* rapidio-tsi721-modify-mport-name-assignment.patch
* rapidio-fix-kerneldoc-warnings-after-dma-support-was-added.patch
* drivers-rapidio-devices-tsi721c-fix-error-return-code.patch
* rapidio-add-inbound-memory-mapping-interface.patch
* rapidio-tsi721-add-inbound-memory-mapping-callbacks.patch
* rapidio-apply-rx-tx-enable-to-active-switch-ports-only.patch
* nbd-add-set-flags-ioctl.patch
* nbd-handle-discard-requests.patch
* aoe-for-performance-support-larger-packet-payloads.patch
* aoe-kernel-thread-handles-i-o-completions-for-simple-locking.patch
* aoe-kernel-thread-handles-i-o-completions-for-simple-locking-fix.patch
* aoe-become-i-o-request-queue-handler-for-increased-user-control.patch
* aoe-use-a-kernel-thread-for-transmissions.patch
* aoe-use-packets-that-work-with-the-smallest-mtu-local-interface.patch
* aoe-failover-remote-interface-based-on-aoe_deadsecs-parameter.patch
* aoe-do-revalidation-steps-in-order.patch
* aoe-disallow-unsupported-aoe-minor-addresses.patch
* aoe-associate-frames-with-the-aoe-storage-target.patch
* aoe-increase-net_device-reference-count-while-using-it.patch
* aoe-remove-unused-code-and-add-cosmetic-improvements.patch
* aoe-update-internal-version-number-to-49.patch
* aoe-update-copyright-year-in-touched-files.patch
* aoe-update-documentation-with-new-url-and-vm-settings-reference.patch
* taskstats-cgroupstats_user_cmd-may-leak-on-error.patch
* scatterlist-add-sg_nents.patch
* scatterlist-add-sg_nents-fix.patch
* memstick-add-support-for-legacy-memorysticks.patch
* kernel-resourcec-fix-stack-overflow-in-__reserve_region_with_split.patch
* lib-decompressc-add-__init-to-decompress_method-and-data.patch
  make-sure-nobodys-leaking-resources.patch
  journal_add_journal_head-debug.patch
  releasing-resources-with-children.patch
  make-frame_pointer-default=y.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  mutex-subsystem-synchro-test-module.patch
  mutex-subsystem-synchro-test-module-fix.patch
  slab-leaks3-default-y.patch
  put_bh-debug.patch
  add-debugging-aid-for-memory-initialisation-problems.patch
  workaround-for-a-pci-restoring-bug.patch
  single_open-seq_release-leak-diagnostics.patch
  add-a-refcount-check-in-dput.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
