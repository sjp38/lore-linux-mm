Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 6E3516B0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 20:21:24 -0500 (EST)
Received: by mail-qe0-f74.google.com with SMTP id a11so731756qen.5
        for <linux-mm@kvack.org>; Tue, 19 Feb 2013 17:21:23 -0800 (PST)
Subject: mmotm 2013-02-19-17-20 uploaded
From: akpm@linux-foundation.org
Date: Tue, 19 Feb 2013 17:21:22 -0800
Message-Id: <20130220012122.870BB31C11E@corp2gmr1-1.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

The mm-of-the-moment snapshot 2013-02-19-17-20 has been uploaded to

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


This mmotm tree contains the following patches against 3.8:
(patches marked "*" will be included in linux-next)

* device_cgroup-dont-grab-mutex-in-rcu-callback.patch
  linux-next.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
* compiler-gcc4h-reorder-macros-based-upon-gcc-ver.patch
* compiler-gcch-add-gcc-recommended-gcc_version-macro.patch
* compiler-gcc34h-use-gcc_version-macro.patch
* compiler-gcc4h-bugh-remove-duplicate-macros.patch
* bugh-fix-build_bug_on-macro-in-__checker__.patch
* bugh-prevent-double-evaulation-of-in-build_bug_on.patch
* bugh-prevent-double-evaulation-of-in-build_bug_on-fix.patch
* bugh-make-build_bug_on-generate-compile-time-error.patch
* compilerh-bugh-prevent-double-error-messages-with-build_bug_on.patch
* bugh-compilerh-introduce-compiletime_assert-build_bug_on_msg.patch
* bugh-compilerh-introduce-compiletime_assert-build_bug_on_msg-checkpatch-fixes.patch
  i-need-old-gcc.patch
* proc-avoid-extra-pde_put-in-proc_fill_super.patch
* compat-return-efault-on-error-in-waitid.patch
* inotify-remove-broken-mask-checks-causing-unmount-to-be-einval.patch
* fs-block_devc-page-cache-wrongly-left-invalidated-after-revalidate_disk.patch
* x86-numa-dont-check-if-node-is-numa_no_node.patch
* revert-x86-mm-make-spurious_fault-check-explicitly-check-the-present-bit.patch
* pageattr-prevent-pse-and-gloabl-leftovers-to-confuse-pmd-pte_present-and-pmd_huge.patch
* x86-make-mem=-option-to-work-for-efi-platform.patch
* drivers-md-persistent-data-dm-transaction-managerc-rename-hash_size.patch
* mn10300-use-for_each_pci_dev-to-simplify-the-code.patch
* cris-use-int-for-ssize_t-to-match-size_t.patch
* pcmcia-move-unbind-rebind-into-dev_pm_opscomplete.patch
* mm-remove-free_area_cache-use-in-powerpc-architecture.patch
* mm-use-vm_unmapped_area-on-powerpc-architecture.patch
* drm-fb-helper-dont-sleep-for-screen-unblank-when-an-oopps-is-in-progress.patch
* fbcon-clear-the-logo-bitmap-from-the-margin-area.patch
* goldfish-framebuffer-driver.patch
* goldfish-framebuffer-driver-fix.patch
* video-mmp-display-subsystem.patch
* video-mmp-fb-support.patch
* video-mmp-fb-support-fix.patch
* video-mmp-display-controller-support.patch
* video-mmp-add-tpo-hvga-panel-supported.patch
* video-mmpdisp-add-spi-port-in-display-controller.patch
* arm-mmp-added-device-for-display-controller.patch
* arm-mmp-enable-display-in-ttc_dkb.patch
* arm-mmp-add-display-and-fb-support-in-pxa910-defconfig.patch
* drivers-video-kconfig-specify-the-socs-that-make-use-of-fb_imx.patch
* drivers-video-exynos-s6e8ax0c-use-devm_-apis-in-s6e8ax0c.patch
* drivers-video-exynos-exynos_mipi_dsic-fix-an-error-check-condition.patch
* drivers-video-exynos-exynos_mipi_dsic-use-devm_-apis.patch
* video-s3c-fb-use-arch_-dependancy.patch
* video-s3c-fb-remove-duplicated-s3c_fb_max_win.patch
* video-s3c-fb-remove-unnecessary-brackets.patch
* video-s3c-fb-add-the-bit-definitions-for-csc-eq709-and-eq601.patch
* video-s3c-fb-fix-typo-in-definition-of-vidcon1_vstatus_frontporch-value.patch
* video-exynos_dp-add-missing-of_node_put.patch
* video-exynos_dp-move-disable_irq-to-exynos_dp_suspend.patch
* cyber2000fb-avoid-palette-corruption-at-higher-clocks.patch
* time-dont-inline-export_symbol-functions.patch
* timer_list-split-timer_list_show_tickdevices.patch
* timer_list-convert-timer-list-to-be-a-proper-seq_file.patch
* timer_list-convert-timer-list-to-be-a-proper-seq_file-fix.patch
* timer_list-convert-timer-list-to-be-a-proper-seq_file-v2.patch
* timer_list-convert-timer-list-to-be-a-proper-seq_file-v2-fix.patch
* timer_list-convert-timer-list-to-be-a-proper-seq_file-fix-fix.patch
* mm-use-vm_unmapped_area-on-ia64-architecture.patch
* mm-use-vm_unmapped_area-in-hugetlbfs-on-ia64-architecture.patch
* scripts-tagssh-add-ctags-magic-for-declarations-of-popular-kernel-type.patch
* ocfs2-remove-kfree-redundant-null-checks.patch
* ocfs2-remove-kfree-redundant-null-checks-fix.patch
* mm-use-vm_unmapped_area-on-parisc-architecture.patch
* sched-proc-sched_stat-fails-on-very-very-large-machines.patch
* sched-proc-sched_stat-fails-on-very-very-large-machines-fix.patch
* sched-proc-sched_stat-fails-on-very-very-large-machines-v2.patch
* sched-proc-sched_stat-fails-on-very-very-large-machines-v2-fix.patch
* sched-proc-sched_stat-fails-on-very-very-large-machines-v2-fix-fix.patch
* sched-proc-sched_debug-fails-on-very-very-large-machines.patch
* sched-proc-sched_debug-fails-on-very-very-large-machines-fix.patch
* sched-proc-sched_debug-fails-on-very-very-large-machines-v2.patch
* sched-proc-sched_debug-fails-on-very-very-large-machines-v2-fix.patch
* lockdep-make-lockdep_assert_held-not-have-a-return-value.patch
* drivers-scsi-aacraid-srcc-silence-two-gcc-warnings.patch
* block-dont-select-percpu_rwsem.patch
* drivers-block-swim3c-fix-null-pointer-dereference.patch
* cfq-fix-lock-imbalance-with-failed-allocations.patch
* block-use-i_size_write-in-bd_set_size.patch
* block-remove-redundant-check-to-bd_openers.patch
* loopdev-fix-a-deadlock.patch
* loopdev-update-block-device-size-in-loop_set_status.patch
* loopdev-move-common-code-into-loop_figure_size.patch
* loopdev-remove-an-user-triggerable-oops.patch
* loopdev-ignore-negative-offset-when-calculate-loop-device-size.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* fs-change-return-values-from-eacces-to-eperm.patch
* fs-block_devc-need-not-to-check-inode-i_bdev-in-bd_forget.patch
* fs-return-eagain-when-o_nonblock-write-should-block-on-frozen-fs.patch
* fs-fix-hang-with-bsd-accounting-on-frozen-filesystem.patch
* ocfs2-add-freeze-protection-to-ocfs2_file_splice_write.patch
* watchdog-trigger-all-cpu-backtrace-when-locked-up-and-going-to-panic.patch
  mm.patch
* memcg-oom-provide-more-precise-dump-info-while-memcg-oom-happening.patch
* mm-memcontrolc-convert-printkkern_foo-to-pr_foo.patch
* mm-hugetlbc-convert-to-pr_foo.patch
* cma-make-putback_lru_pages-call-conditional.patch
* cma-make-putback_lru_pages-call-conditional-fix.patch
* mm-memcg-only-evict-file-pages-when-we-have-plenty.patch
* mm-vmscan-save-work-scanning-almost-empty-lru-lists.patch
* mm-vmscan-clarify-how-swappiness-highest-priority-memcg-interact.patch
* mm-vmscan-improve-comment-on-low-page-cache-handling.patch
* mm-vmscan-clean-up-get_scan_count.patch
* mm-vmscan-clean-up-get_scan_count-fix.patch
* mm-vmscan-compaction-works-against-zones-not-lruvecs.patch
* mm-vmscan-compaction-works-against-zones-not-lruvecs-fix.patch
* mm-reduce-rmap-overhead-for-ex-ksm-page-copies-created-on-swap-faults.patch
* mm-page_allocc-__setup_per_zone_wmarks-make-min_pages-unsigned-long.patch
* mm-vmscanc-__zone_reclaim-replace-max_t-with-max.patch
* mm-compaction-do-not-accidentally-skip-pageblocks-in-the-migrate-scanner.patch
* mm-huge_memory-use-new-hashtable-implementation.patch
* mmksm-use-new-hashtable-implementation.patch
* memcgvmscan-do-not-break-out-targeted-reclaim-without-reclaimed-pages.patch
* mmotm-memcgvmscan-do-not-break-out-targeted-reclaim-without-reclaimed-pagespatch-fix.patch
* mmotm-memcgvmscan-do-not-break-out-targeted-reclaim-without-reclaimed-pagespatch-fix-fix.patch
* mm-make-madvisemadv_willneed-support-swap-file-prefetch.patch
* mm-make-madvisemadv_willneed-support-swap-file-prefetch-fix.patch
* mm-make-madvisemadv_willneed-support-swap-file-prefetch-fix-fix.patch
* mm-compaction-make-__compact_pgdat-and-compact_pgdat-return-void.patch
* mm-avoid-calling-pgdat_balanced-needlessly.patch
* mm-remap_file_pages-fixes.patch
* mm-introduce-mm_populate-for-populating-new-vmas.patch
* mm-use-mm_populate-for-blocking-remap_file_pages.patch
* mm-use-mm_populate-when-adjusting-brk-with-mcl_future-in-effect.patch
* mm-use-mm_populate-for-mremap-of-vm_locked-vmas.patch
* mm-remove-flags-argument-to-mmap_region.patch
* mm-remove-flags-argument-to-mmap_region-fix.patch
* mm-directly-use-__mlock_vma_pages_range-in-find_extend_vma.patch
* mm-introduce-vm_populate-flag-to-better-deal-with-racy-userspace-programs.patch
* mm-make-do_mmap_pgoff-return-populate-as-a-size-in-bytes-not-as-a-bool.patch
* mm-memory_hotplug-no-need-to-check-res-twice-in-add_memory.patch
* memory-hotplug-try-to-offline-the-memory-twice-to-avoid-dependence.patch
* memory-hotplug-check-whether-all-memory-blocks-are-offlined-or-not-when-removing-memory.patch
* memory-hotplug-remove-redundant-codes.patch
* memory-hotplug-remove-sys-firmware-memmap-x-sysfs.patch
* memory-hotplug-remove-sys-firmware-memmap-x-sysfs-fix.patch
* memory-hotplug-remove-sys-firmware-memmap-x-sysfs-fix-fix.patch
* memory-hotplug-remove-sys-firmware-memmap-x-sysfs-fix-fix-fix.patch
* memory-hotplug-remove-sys-firmware-memmap-x-sysfs-fix-fix-fix-fix.patch
* memory-hotplug-remove-sys-firmware-memmap-x-sysfs-fix-fix-fix-fix-fix.patch
* memory-hotplug-introduce-new-arch_remove_memory-for-removing-page-table.patch
* memory-hotplug-implement-register_page_bootmem_info_section-of-sparse-vmemmap.patch
* memory-hotplug-implement-register_page_bootmem_info_section-of-sparse-vmemmap-fix.patch
* memory-hotplug-implement-register_page_bootmem_info_section-of-sparse-vmemmap-fix-fix.patch
* memory-hotplug-implement-register_page_bootmem_info_section-of-sparse-vmemmap-fix-fix-fix.patch
* memory-hotplug-implement-register_page_bootmem_info_section-of-sparse-vmemmap-fix-fix-fix-fix.patch
* memory-hotplug-move-pgdat_resize_lock-into-sparse_remove_one_section.patch
* memory-hotplug-common-apis-to-support-page-tables-hot-remove.patch
* memory-hotplug-common-apis-to-support-page-tables-hot-remove-fix.patch
* memory-hotplug-common-apis-to-support-page-tables-hot-remove-fix-fix.patch
* memory-hotplug-common-apis-to-support-page-tables-hot-remove-fix-fix-fix.patch
* memory-hotplug-common-apis-to-support-page-tables-hot-remove-fix-fix-fix-fix.patch
* memory-hotplug-common-apis-to-support-page-tables-hot-remove-fix-fix-fix-fix-fix.patch
* memory-hotplug-common-apis-to-support-page-tables-hot-remove-fix-fix-fix-fix-fix-fix.patch
* memory-hotplug-common-apis-to-support-page-tables-hot-remove-fix-fix-fix-fix-fix-fix-fix.patch
* memory-hotplug-remove-page-table-of-x86_64-architecture.patch
* memory-hotplug-remove-page-table-of-x86_64-architecture-fix.patch
* memory-hotplug-remove-memmap-of-sparse-vmemmap.patch
* memory-hotplug-remove-memmap-of-sparse-vmemmap-fix.patch
* memory-hotplug-integrated-__remove_section-of-config_sparsemem_vmemmap.patch
* memory_hotplug-clear-zone-when-removing-the-memory.patch
* memory-hotplug-remove-sysfs-file-of-node.patch
* memory-hotplug-free-node_data-when-a-node-is-offlined.patch
* memory-hotplug-do-not-allocate-pdgat-if-it-was-not-freed-when-offline.patch
* memory-hotplug-do-not-allocate-pdgat-if-it-was-not-freed-when-offline-fix.patch
* memory-hotplug-do-not-allocate-pdgat-if-it-was-not-freed-when-offline-fix-fix.patch
* memory-hotplug-consider-compound-pages-when-free-memmap.patch
* mempolicy-fix-is_valid_nodemask.patch
* cpu_hotplug-clear-apicid-to-node-when-the-cpu-is-hotremoved.patch
* cpu_hotplug-clear-apicid-to-node-when-the-cpu-is-hotremoved-fix.patch
* memory-hotplug-export-the-function-try_offline_node.patch
* memory-hotplug-export-the-function-try_offline_node-fix.patch
* cpu-hotplug-memory-hotplug-try-offline-the-node-when-hotremoving-a-cpu.patch
* cpu-hotplugmemory-hotplug-clear-cpu_to_node-when-offlining-the-node.patch
* cpu-hotplugmemory-hotplug-clear-cpu_to_node-when-offlining-the-node-fix.patch
* sched-do-not-use-cpu_to_node-to-find-an-offlined-cpus-node.patch
* x86-get-pg_data_ts-memory-from-other-node.patch
* page_alloc-add-movable_memmap-kernel-parameter.patch
* page_alloc-add-movable_memmap-kernel-parameter-fix.patch
* page_alloc-add-movable_memmap-kernel-parameter-fix-fix.patch
* page_alloc-add-movable_memmap-kernel-parameter-fix-fix-checkpatch-fixes.patch
* page_alloc-add-movable_memmap-kernel-parameter-fix-fix-fix.patch
* page_alloc-add-movable_memmap-kernel-parameter-rename-movablecore_map-to-movablemem_map.patch
* page_alloc-introduce-zone_movable_limit-to-keep-movable-limit-for-nodes.patch
* page_alloc-introduce-zone_movable_limit-to-keep-movable-limit-for-nodes-fix.patch
* page_alloc-make-movablecore_map-has-higher-priority.patch
* page_alloc-bootmem-limit-with-movablecore_map.patch
* acpi-memory-hotplug-parse-srat-before-memblock-is-ready.patch
* acpi-memory-hotplug-parse-srat-before-memblock-is-ready-fix.patch
* acpi-memory-hotplug-parse-srat-before-memblock-is-ready-fix-fix.patch
* acpi-memory-hotplug-extend-movablemem_map-ranges-to-the-end-of-node.patch
* acpi-memory-hotplug-extend-movablemem_map-ranges-to-the-end-of-node-fix.patch
* acpi-memory-hotplug-support-getting-hotplug-info-from-srat.patch
* acpi-memory-hotplug-support-getting-hotplug-info-from-srat-fix.patch
* acpi-memory-hotplug-support-getting-hotplug-info-from-srat-fix-fix.patch
* acpi-memory-hotplug-support-getting-hotplug-info-from-srat-fix-fix-fix.patch
* mm-memblockc-use-config_have_memblock_node_map-to-protect-movablecore_map-in-memblock_overlaps_region.patch
* mm-use-zone-present_pages-instead-of-zone-managed_pages-where-appropriate.patch
* mm-set-zone-present_pages-to-number-of-existing-pages-in-the-zone.patch
* mm-increase-totalram_pages-when-free-pages-allocated-by-bootmem-allocator.patch
* mm-remove-migrate_isolate-check-in-hotpath.patch
* memory-failure-fix-an-error-of-mce_bad_pages-statistics.patch
* memory-failure-do-code-refactor-of-soft_offline_page.patch
* memory-failure-use-num_poisoned_pages-instead-of-mce_bad_pages.patch
* memory-failure-use-num_poisoned_pages-instead-of-mce_bad_pages-fix.patch
* mm-memory-failurec-clean-up-soft_offline_page.patch
* mm-memory-failurec-fix-wrong-num_poisoned_pages-in-handling-memory-error-on-thp.patch
* mm-memory-failurec-fix-wrong-num_poisoned_pages-in-handling-memory-error-on-thp-fix.patch
* mm-dont-wait-on-congested-zones-in-balance_pgdat.patch
* mm-teach-mm-by-current-context-info-to-not-do-i-o-during-memory-allocation.patch
* pm-runtime-introduce-pm_runtime_set_memalloc_noio.patch
* block-genhdc-apply-pm_runtime_set_memalloc_noio-on-block-devices.patch
* net-core-apply-pm_runtime_set_memalloc_noio-on-network-devices.patch
* pm-runtime-force-memory-allocation-with-no-i-o-during-runtime-pm-callbcack.patch
* usb-forbid-memory-allocation-with-i-o-during-bus-reset.patch
* mm-remove-unused-memclear_highpage_flush.patch
* mm-numa-fix-minor-typo-in-numa_next_scan.patch
* mm-numa-take-thp-into-account-when-migrating-pages-for-numa-balancing.patch
* mm-numa-handle-side-effects-in-count_vm_numa_events-for-config_numa_balancing.patch
* mm-move-page-flags-layout-to-separate-header.patch
* mm-fold-page-_last_nid-into-page-flags-where-possible.patch
* mm-numa-cleanup-flow-of-transhuge-page-migration.patch
* mm-dont-inline-page_mapping.patch
* swap-make-each-swap-partition-have-one-address_space.patch
* swap-make-each-swap-partition-have-one-address_space-fix.patch
* swap-make-each-swap-partition-have-one-address_space-fix-fix.patch
* swap-add-per-partition-lock-for-swapfile.patch
* swap-add-per-partition-lock-for-swapfile-fix-fix.patch
* swap-add-per-partition-lock-for-swapfile-fix-for-nommu.patch
* swap-add-per-partition-lock-for-swapfile-fix-fix-fix.patch
* swap-add-per-partition-lock-for-swapfile-fix-fix-fix-fix.patch
* swap-add-per-partition-lock-for-swapfile-fix-fix-fix-fix-fix.patch
* mm-rmap-rename-anon_vma_unlock-=-anon_vma_unlock_write.patch
* page-writebackc-subtract-min_free_kbytes-from-dirtyable-memory.patch
* page-writebackc-subtract-min_free_kbytes-from-dirtyable-memory-fix.patch
* page-writebackc-subtract-min_free_kbytes-from-dirtyable-memory-fix-fix.patch
* memcg-do-not-create-memsw-files-if-swap-accounting-is-disabled.patch
* memcg-clean-up-swap-accounting-initialization-code.patch
* mm-uninline-page_xchg_last_nid.patch
* mm-init-report-on-last-nid-information-stored-in-page-flags.patch
* memcg-reduce-the-size-of-struct-memcg-244-fold.patch
* memcg-reduce-the-size-of-struct-memcg-244-fold-fix.patch
* memcg-reduce-the-size-of-struct-memcg-244-fold-fix-fix.patch
* memcg-prevent-changes-to-move_charge_at_immigrate-during-task-attach.patch
* memcg-split-part-of-memcg-creation-to-css_online.patch
* memcg-fast-hierarchy-aware-child-test.patch
* memcg-fast-hierarchy-aware-child-test-fix.patch
* memcg-fast-hierarchy-aware-child-test-fix-fix.patch
* memcg-replace-cgroup_lock-with-memcg-specific-memcg_lock.patch
* memcg-replace-cgroup_lock-with-memcg-specific-memcg_lock-fix.patch
* memcg-increment-static-branch-right-after-limit-set.patch
* memcg-avoid-dangling-reference-count-in-creation-failure.patch
* mm-memmap_init_zone-performance-improvement.patch
* mm-rename-page-struct-field-helpers.patch
* mm-rename-page-struct-field-helpers-fix.patch
* ksm-allow-trees-per-numa-node.patch
* ksm-add-sysfs-abi-documentation.patch
* ksm-trivial-tidyups.patch
* ksm-trivial-tidyups-fix.patch
* ksm-reorganize-ksm_check_stable_tree.patch
* ksm-get_ksm_page-locked.patch
* ksm-remove-old-stable-nodes-more-thoroughly.patch
* ksm-make-ksm-page-migration-possible.patch
* ksm-make-merge_across_nodes-migration-safe.patch
* ksm-enable-ksm-page-migration.patch
* mm-remove-offlining-arg-to-migrate_pages.patch
* ksm-stop-hotremove-lockdep-warning.patch
* mm-shmem-use-new-radix-tree-iterator.patch
* mm-refactor-inactive_file_is_low-to-use-get_lru_size.patch
* mm-mlockc-document-scary-looking-stack-expansion-mlock-chain.patch
* mm-add-section_in_page_flags.patch
* mm-add-use-zone_end_pfn-and-zone_spans_pfn.patch
* mm-add-zone_is_empty-and-zone_is_initialized.patch
* mm-page_alloc-add-a-vm_bug-in-__free_one_page-if-the-zone-is-uninitialized.patch
* mmzone-add-pgdat_end_pfnis_empty-helpers-consolidate.patch
* mm-page_alloc-add-informative-debugging-message-in-page_outside_zone_boundaries.patch
* mm-page_alloc-add-informative-debugging-message-in-page_outside_zone_boundaries-fix.patch
* mm-add-helper-ensure_zone_is_initialized.patch
* mm-memory_hotplug-use-ensure_zone_is_initialized.patch
* mm-memory_hotplug-use-pgdat_end_pfn-instead-of-open-coding-the-same.patch
* mmu_notifier_unregister-null-pointer-deref-and-multiple-release-callouts.patch
* mm-use-numa_no_node.patch
* mm-remove-free_area_cache.patch
* include-linux-mmzoneh-cleanups.patch
* include-linux-mmzoneh-cleanups-fix.patch
* mm-use-up-free-swap-space-before-reaching-oom-kill.patch
* memcg-move-mem_cgroup_soft_limit_tree_init-to-mem_cgroup_init.patch
* memcg-move-memcg_stock-initialization-to-mem_cgroup_init.patch
* memcg-cleanup-mem_cgroup_init-comment.patch
* mm-fix-return-type-for-functions-nr_free__pages.patch
* ia64-use-%ld-to-print-pages-calculated-in-nr_free_buffer_pages.patch
* fs-bufferc-change-type-of-max_buffer_heads-to-unsigned-long.patch
* fs-nfsd-change-type-of-max_delegations-nfsd_drc_max_mem-and-nfsd_drc_mem_used.patch
* vmscan-change-type-of-vm_total_pages-to-unsigned-long.patch
* net-change-type-of-virtio_chan-p9_max_pages.patch
* memcg-stop-warning-on-memcg_propagate_kmem.patch
* hwpoison-fix-misjudgement-of-page_action-for-errors-on-mlocked-pages.patch
* hwpoison-fix-misjudgement-of-page_action-for-errors-on-mlocked-pages-fix.patch
* hwpoison-change-order-of-error_statess-elements.patch
* mm-accurately-document-nr_free__pages-functions-with-code-comments.patch
* mm-accurately-document-nr_free__pages-functions-with-code-comments-fix.patch
* mm-use-long-type-for-page-counts-in-mm_populate-and-get_user_pages.patch
* mm-accelerate-mm_populate-treatment-of-thp-pages.patch
* mm-accelerate-munlock-treatment-of-thp-pages.patch
* mm-export-mmu-notifier-invalidates.patch
* mm-fadvise-drain-all-pagevecs-if-posix_fadv_dontneed-fails-to-discard-all-pages.patch
* drop_caches-add-some-documentation-and-info-messsge.patch
* drivers-usb-gadget-amd5536udcc-avoid-calling-dma_pool_create-with-null-dev.patch
* mm-dmapoolc-fix-null-dev-in-dma_pool_create.patch
* memcg-debugging-facility-to-access-dangling-memcgs.patch
* memcg-debugging-facility-to-access-dangling-memcgs-fix.patch
* mm-add-vm-event-counters-for-balloon-pages-compaction.patch
* mm-use-vm_unmapped_area-on-frv-architecture.patch
* bdi-allow-block-devices-to-say-that-they-require-stable-page-writes.patch
* mm-only-enforce-stable-page-writes-if-the-backing-device-requires-it.patch
* 9pfs-fix-filesystem-to-wait-for-stable-page-writeback.patch
* block-optionally-snapshot-page-contents-to-provide-stable-pages-during-write.patch
* ocfs2-wait-for-page-writeback-to-provide-stable-pages.patch
* ubifs-wait-for-page-writeback-to-provide-stable-pages.patch
* mm-use-vm_unmapped_area-on-alpha-architecture.patch
* scripts-pnmtologo-fix-for-plain-pbm-checkpatch-fixes.patch
* smp-make-smp_call_function_many-use-logic-similar-to-smp_call_function_single.patch
* unhide-config_panic_on_oops.patch
* suncom-documentation-fixes.patch
* sys_prctl-arg2-is-unsigned-long-which-is-never-0.patch
* sys_prctl-coding-style-cleanup.patch
* smp-give-warning-when-calling-smp_call_function_many-single-in-serving-irq.patch
* include-linux-fsh-disable-preempt-when-acquire-i_size_seqcount-write-lock.patch
* kernel-smpc-cleanups.patch
* lib-vsprintf-add-%pa-format-specifier-for-phys_addr_t-types.patch
* printk-add-pr_devel_once-and-pr_devel_ratelimited.patch
* get_maintainerpl-find-maintainers-for-removed-files.patch
* get_maintainer-allow-keywords-to-match-filenames.patch
* maintainers-mm-add-additional-include-files-to-listing.patch
* maintainers-remove-mark-m-hoffman.patch
* maintainers-remove-mark-m-hoffman-fix.patch
* backlight-add-lms501kf03-lcd-driver.patch
* backlight-add-lms501kf03-lcd-driver-fix.patch
* backlight-add-lms501kf03-lcd-driver-fix-fix.patch
* backlight-ld9040-use-sleep-instead-of-delay.patch
* backlight-ld9040-remove-unnecessary-null-deference-check.patch
* backlight-ld9040-replace-efault-with-einval.patch
* backlight-ld9040-remove-redundant-return-variables.patch
* backlight-ld9040-reorder-inclusions-of-linux-xxxh.patch
* backlight-s6e63m0-use-lowercase-names-of-structs.patch
* backlight-s6e63m0-use-sleep-instead-of-delay.patch
* backlight-s6e63m0-remove-unnecessary-null-deference-check.patch
* backlight-s6e63m0-replace-efault-with-einval.patch
* backlight-s6e63m0-remove-redundant-variable-before_power.patch
* backlight-s6e63m0-reorder-inclusions-of-linux-xxxh.patch
* backlight-ams369fg06-use-sleep-instead-of-delay.patch
* backlight-ams369fg06-remove-unnecessary-null-deference-check.patch
* backlight-ams369fg06-replace-efault-with-einval.patch
* backlight-ams369fg06-remove-redundant-variable-before_power.patch
* backlight-ams369fg06-reorder-inclusions-of-linux-xxxh.patch
* backlight-add-new-lp8788-backlight-driver.patch
* backlight-add-new-lp8788-backlight-driver-checkpatch-fixes.patch
* backlight-l4f00242t03-use-spi_get_drvdata-and-spi_set_drvdata.patch
* backlight-ld9040-use-spi_get_drvdata-and-spi_set_drvdata.patch
* backlight-s6e63m0-use-spi_get_drvdata-and-spi_set_drvdata.patch
* backlight-ltv350qv-use-spi_get_drvdata-and-spi_set_drvdata.patch
* backlight-tdo24m-use-spi_get_drvdata-and-spi_set_drvdata.patch
* backlight-lms283gf05-use-spi_get_drvdata-and-spi_set_drvdata.patch
* backlight-ams369fg06-use-spi_get_drvdata-and-spi_set_drvdata.patch
* backlight-vgg2432a4-use-spi_get_drvdata-and-spi_set_drvdata.patch
* backlight-tosa-use-spi_get_drvdata-and-spi_set_drvdata.patch
* backlight-corgi_lcd-use-spi_get_drvdata-and-spi_set_drvdata.patch
* backlight-lms501kf03-use-spi_get_drvdata-and-spi_set_drvdata.patch
* backlight-aat2870-use-bl_get_data-instead-of-dev_get_drvdata.patch
* pwm_backlight-use-bl_get_data-instead-of-dev_get_drvdata.patch
* backlight-ams369fg06-use-bl_get_data-instead-of-dev_get_drvdata.patch
* backlight-corgi_lcd-use-bl_get_data-instead-of-dev_get_drvdata.patch
* backlight-tosa-use-bl_get_data-instead-of-dev_get_drvdata.patch
* backlight-omap1-use-bl_get_data-instead-of-dev_get_drvdata.patch
* backlight-corgi_lcd-use-lcd_get_data-instead-of-dev_get_drvdata.patch
* backlight-lm3649_backlight-remove-ret-=-eio-at-error-paths-of-probe.patch
* drivers-video-backlight-l4f00242t03c-convert-to-devm_regulator_get.patch
* drivers-video-backlight-ld9040c-use-devm_regulator_bulk_get-api.patch
* fb-backlight-add-the-himax-hx-8357b-lcd-controller.patch
* fb-backlight-add-the-himax-hx-8357b-lcd-controller-change-parameters-of-the-write-function-to-u8.patch
* fb-backlight-add-the-himax-hx-8357b-lcd-controller-fix-inverted-parameters-for-kcalloc.patch
* fb-backlight-add-the-himax-hx-8357b-lcd-controller-remove-useless-error-message.patch
* fb-backlight-add-the-himax-hx-8357b-lcd-controller-remove-trailing-period.patch
* fb-backlight-add-the-himax-hx-8357b-lcd-controller-use-static-arrays-for-lcd-configuration.patch
* drivers-video-backlight-makefile-cleanup.patch
* backlight-add-an-as3711-pmic-backlight-driver.patch
* backlight-add-an-as3711-pmic-backlight-driver-fix.patch
* backlight-88pm860x_bl-add-missing-of_node_put.patch
* backlight-s6e63m0-report-gamma_table_count-correctly.patch
* drivers-video-backlight-lm3630_blc-remove-ret-=-eio-of-lm3630_backlight_register.patch
* drivers-video-backlight-adp880_blc-fix-resume.patch
* drivers-leds-leds-ot200c-fix-error-caused-by-shifted-mask.patch
* lib-parserc-fix-up-comments-for-valid-return-values-from-match_number.patch
* decompressors-group-xz_dec_-symbols-under-an-if-xz_bcj-endif.patch
* decompressors-drop-dependency-on-config_expert.patch
* decompressors-make-the-default-xz_dec_-config-match-the-selected-architecture.patch
* lib-scatterlist-add-simple-page-iterator.patch
* lib-scatterlist-use-page-iterator-in-the-mapping-iterator.patch
* checkpatch-prefer-dev_level-to-dev_printkkern_level.patch
* checkpatch-warn-on-unnecessary-__devfoo-section-markings.patch
* checkpatch-add-joe-to-maintainers.patch
* checkpatch-dont-emit-the-camelcase-warning-for-pagefoo.patch
* checkpatch-add-check-for-kcalloc-argument-order.patch
* checkpatch-fix-usleep_range-test.patch
* epoll-support-for-disabling-items-and-a-self-test-app.patch
* epoll-support-for-disabling-items-and-a-self-test-app-fix.patch
* binfmt_elf-remove-unused-argument-in-fill_elf_header.patch
* binfmt_elfc-use-get_random_int-to-fix-entropy-depleting.patch
* nsproxy-remove-duplicate-task_cred_xxx-for-user_ns.patch
* drivers-rtc-dump-small-buffers-via-%ph.patch
* drivers-rtc-rtc-pxac-fix-alarm-not-match-issue.patch
* drivers-rtc-rtc-pxac-fix-alarm-cant-wake-up-system-issue.patch
* drivers-rtc-rtc-pxac-fix-set-time-sync-time-issue.patch
* drivers-rtc-rtc-pxac-fix-set-time-sync-time-issue-fix.patch
* rtc-ds1307-long-block-operations-bugfix.patch
* rtc-ds1307-long-block-operations-bugfix-fix.patch
* rtc-max77686-add-maxim-77686-driver.patch
* rtc-max77686-add-maxim-77686-driver-fix.patch
* rtc-max77686-add-missing-variable-initialization.patch
* rtc-max77686-add-missing-variable-initialization-fix.patch
* rtc-pcf8523-add-low-battery-voltage-support.patch
* rtc-pcf8523-add-low-battery-voltage-support-fix.patch
* drivers-rtc-use-of_match_ptr-macro.patch
* drivers-rtc-use-of_match_ptr-macro-fix.patch
* drivers-rtc-rtc-pxac-avoid-cpuid-checking.patch
* drivers-rtc-remove-unnecessary-semicolons.patch
* rtc-ds2404-use-module_platform_driver-macro.patch
* rtc-add-new-lp8788-rtc-driver.patch
* rtc-add-rtc-driver-for-tps80031-tps80032.patch
* rtc-add-rtc-driver-for-tps80031-tps80032-v2.patch
* rtc-add-rtc-driver-for-tps80031-tps80032-v2-fix.patch
* drivers-rtc-rtc-tps65910c-enable-disable-wake-in-suspend-resume.patch
* drivers-rtc-rtc-tps65910c-remove-unnecessary-irq-stat-save-and-restore.patch
* drivers-rtc-rtc-tps65910c-use-sleep_pm_ops-macro-for-initialising-suspend-resume-callbacks.patch
* drivers-rtc-rtc-tps65910c-set-irq-flag-to-irqf_early_resume-during-irq-request.patch
* rtc-add-support-for-spi-rtc-rx4581.patch
* rtc-add-support-for-spi-rtc-rx4581-checkpatch-fixes.patch
* rtc-add-support-for-spi-rtc-rx4581-fix.patch
* rtc-pl031-add-wake-up-support.patch
* arm-mvebu-add-rtc-support-for-armada-370-and-armada-xp.patch
* arm-mvebu-update-defconfig-with-marvell-rtc-support.patch
* drivers-rtc-rtc-s3cc-use-dev_dbg-instaed-of-pr_debug.patch
* rtc-max8997-add-driver-for-max8997-rtc.patch
* rtc-sa1100-move-clock-enable-disable-to-probe-remove.patch
* rtc-use-dev_warn-dev_dbg-pr_err-instead-of-printk.patch
* rtc-max77686-use-dev_info-instead-of-printk.patch
* rtc-rtc-efi-use-dev_err-dev_warn-pr_err-instead-of-printk.patch
* rtc-rtc-ds2404-use-dev_err-instead-of-printk.patch
* rtc-rtc-rs5c372-use-dev_dbg-dev_warn-instead-of-printk-pr_debug.patch
* rtc-rtc-at91rm9200-use-dev_dbg-dev_err-instead-of-printk-pr_debug.patch
* rtc-rtc-rs5c313-use-pr_err-instead-of-printk.patch
* rtc-rtc-vr41xx-use-dev_info-instead-of-printk.patch
* rtc-rtc-sun4v-use-pr_warn-instead-of-printk.patch
* rtc-rtc-pcf8583-use-dev_warn-instead-of-printk.patch
* rtc-rtc-cmos-use-dev_warn-dev_dbg-instead-of-printk-pr_debug.patch
* hfsplus-add-osx-prefix-for-handling-namespace-of-mac-os-x-extended-attributes.patch
* hfsplus-add-on-disk-layout-declarations-related-to-attributes-tree.patch
* hfsplus-add-functionality-of-manipulating-by-records-in-attributes-tree.patch
* hfsplus-rework-functionality-of-getting-setting-and-deleting-of-extended-attributes.patch
* hfsplus-add-support-of-manipulation-by-attributes-file.patch
* hfsplus-fix-issue-with-unzeroed-unused-b-tree-nodes.patch
* fat-add-extended-fileds-to-struct-fat_boot_sector.patch
* fat-mark-fs-as-dirty-on-mount-and-clean-on-umount.patch
* documentation-dma-api-howtotxt-minor-grammar-corrections.patch
* documentation-cgroups-blkio-controllertxt-fix-typo.patch
* signal-allow-to-send-any-siginfo-to-itself.patch
* signal-allow-to-send-any-siginfo-to-itself-fix.patch
* kernel-signalc-fix-suboptimal-printk-usage.patch
* coredump-remove-redundant-defines-for-dumpable-states.patch
* fs-proc-clean-up-printks.patch
* fs-proc-clean-up-printks-fix.patch
* fs-proc-clean-up-printks-fix-fix.patch
* fs-proc-vmcorec-put-if-tests-in-the-top-of-the-while-loop-to-reduce-duplication.patch
* fs-proc-vmcorec-put-if-tests-in-the-top-of-the-while-loop-to-reduce-duplication-fix.patch
* fs-proc-vmcorec-put-if-tests-in-the-top-of-the-while-loop-to-reduce-duplication-fix-fix.patch
* vfork-dont-freezer_count-for-in-kernel-users-of-clone_vfork.patch
* lockdep-check-that-no-locks-held-at-freeze-time.patch
* lockdep-check-that-no-locks-held-at-freeze-time-fix.patch
* coredump-cleanup-the-waiting-for-coredump_finish-code.patch
* coredump-use-a-freezable_schedule-for-the-coredump_finish-wait.patch
* coredump-abort-core-dump-piping-only-due-to-a-fatal-signal.patch
* seq-file-use-seek_-macros-instead-of-hardcoded-numbers.patch
* fs-seq_filec-seq_lseek-fix-switch-statement-indenting.patch
* fs-seq_filec-seq_lseek-fix-switch-statement-indenting-checkpatch-fixes.patch
* fork-unshare-remove-dead-code.patch
* fs-execc-make-bprm_mm_init-static.patch
* kexec-add-the-values-related-to-buddy-system-for-filtering-free-pages.patch
* kexec-get-rid-of-duplicate-check-for-hole_end.patch
* kexec-export-pg_hwpoison-flag-into-vmcoreinfo.patch
* block-fix-ext_devt_idr-handling.patch
* idr-fix-a-subtle-bug-in-idr_get_next.patch
* idr-make-idr_destroy-imply-idr_remove_all.patch
* atm-nicstar-dont-use-idr_remove_all.patch
* block-loop-dont-use-idr_remove_all.patch
* firewire-dont-use-idr_remove_all.patch
* drm-dont-use-idr_remove_all.patch
* dm-dont-use-idr_remove_all.patch
* remoteproc-dont-use-idr_remove_all.patch
* rpmsg-dont-use-idr_remove_all.patch
* dlm-use-idr_for_each_entry-in-recover_idr_clear-error-path.patch
* dlm-dont-use-idr_remove_all.patch
* nfs-idr_destroy-no-longer-needs-idr_remove_all.patch
* inotify-dont-use-idr_remove_all.patch
* cgroup-dont-use-idr_remove_all.patch
* nfsd-idr_destroy-no-longer-needs-idr_remove_all.patch
* idr-deprecate-idr_remove_all.patch
* idr-cosmetic-updates-to-struct-initializer-definitions.patch
* idr-relocate-idr_for_each_entry-and-reorganize-id_get_new.patch
* idr-remove-_idr_rc_to_errno-hack.patch
* idr-refactor-idr_get_new_above.patch
* idr-implement-idr_preload-and-idr_alloc.patch
* idr-implement-idr_preload-and-idr_alloc-fix.patch
* block-fix-synchronization-and-limit-check-in-blk_alloc_devt.patch
* block-convert-to-idr_alloc.patch
* block-loop-convert-to-idr_alloc.patch
* atm-nicstar-convert-to-idr_alloc.patch
* drbd-convert-to-idr_alloc.patch
* dca-convert-to-idr_alloc.patch
* dmaengine-convert-to-idr_alloc.patch
* firewire-add-minor-number-range-check-to-fw_device_init.patch
* firewire-convert-to-idr_alloc.patch
* firewire-convert-to-idr_alloc-fix.patch
* gpio-convert-to-idr_alloc.patch
* drm-convert-to-idr_alloc.patch
* drm-convert-to-idr_alloc-fix.patch
* drm-convert-to-idr_alloc-fix-fix.patch
* drm-exynos-convert-to-idr_alloc.patch
* drm-i915-convert-to-idr_alloc.patch
* drm-sis-convert-to-idr_alloc.patch
* drm-via-convert-to-idr_alloc.patch
* drm-vmwgfx-convert-to-idr_alloc.patch
* i2c-convert-to-idr_alloc.patch
* i2c-convert-to-idr_alloc-fix.patch
* i2c-convert-to-idr_alloc-fix-fix.patch
* ib-core-convert-to-idr_alloc.patch
* ib-amso1100-convert-to-idr_alloc.patch
* ib-cxgb3-convert-to-idr_alloc.patch
* ib-cxgb4-convert-to-idr_alloc.patch
* ib-ehca-convert-to-idr_alloc.patch
* ib-ipath-convert-to-idr_alloc.patch
* ib-mlx4-convert-to-idr_alloc.patch
* ib-ocrdma-convert-to-idr_alloc.patch
* ib-qib-convert-to-idr_alloc.patch
* dm-convert-to-idr_alloc.patch
* memstick-convert-to-idr_alloc.patch
* mfd-convert-to-idr_alloc.patch
* misc-c2port-convert-to-idr_alloc.patch
* misc-tifm_core-convert-to-idr_alloc.patch
* mmc-convert-to-idr_alloc.patch
* mtd-convert-to-idr_alloc.patch
* macvtap-convert-to-idr_alloc.patch
* ppp-convert-to-idr_alloc.patch
* power-convert-to-idr_alloc.patch
* pps-convert-to-idr_alloc.patch
* remoteproc-convert-to-idr_alloc.patch
* rpmsg-convert-to-idr_alloc.patch
* scsi-bfa-convert-to-idr_alloc.patch
* scsi-convert-to-idr_alloc.patch
* target-iscsi-convert-to-idr_alloc.patch
* scsi-lpfc-convert-to-idr_alloc.patch
* thermal-convert-to-idr_alloc.patch
* uio-convert-to-idr_alloc.patch
* vfio-convert-to-idr_alloc.patch
* dlm-convert-to-idr_alloc.patch
* inotify-convert-to-idr_alloc.patch
* ocfs2-convert-to-idr_alloc.patch
* ipc-convert-to-idr_alloc.patch
* ipc-convert-to-idr_alloc-fix.patch
* cgroup-convert-to-idr_alloc.patch
* events-convert-to-idr_alloc.patch
* posix-timers-convert-to-idr_alloc.patch
* net-9p-convert-to-idr_alloc.patch
* mac80211-convert-to-idr_alloc.patch
* sctp-convert-to-idr_alloc.patch
* nfs4client-convert-to-idr_alloc.patch
* idr-fix-top-layer-handling.patch
* idr-remove-max_idr_mask-and-move-left-max_idr_-into-idrc.patch
* idr-remove-length-restriction-from-idr_layer-bitmap.patch
* idr-remove-length-restriction-from-idr_layer-bitmap-checkpatch-fixes.patch
* idr-make-idr_layer-larger.patch
* idr-add-idr_layer-prefix.patch
* idr-implement-lookup-hint.patch
* ipc-semc-alternatives-to-preempt_disable.patch
* ipmi-remove-superfluous-kernel-userspace-explanation.patch
* ipmi-add-new-kernel-options-to-prevent-automatic-ipmi-init.patch
* ipmi-add-options-to-disable-openfirmware-and-pci-scanning.patch
* drivers-char-miscc-misc_register-do-not-loop-on-misc_list-unconditionally.patch
* drivers-char-miscc-misc_register-do-not-loop-on-misc_list-unconditionally-fix.patch
* block-partition-msdos-detect-aix-formatted-disks-even-without-55aa.patch
* ensure-that-the-gpt-header-is-at-least-the-size-of-the-structure.patch
* sysctl-fix-null-checking-in-bin_dn_node_address.patch
* sysctl-put-get-get_uts-into-config_proc_sysctl-code-block.patch
* nbd-support-flush-requests.patch
* nbd-fsync-and-kill-block-device-on-shutdown.patch
* nbd-show-read-only-state-in-sysfs.patch
* nbd-update-documentation-and-link-to-mailinglist.patch
* namespaces-utsname-fix-wrong-comment-about-clone_uts_ns.patch
* mtd-mtd_nandecctest-use-prandom_bytes-instead-of-get_random_bytes.patch
* mtd-mtd_oobtest-convert-to-use-prandom-library.patch
* mtd-mtd_pagetest-convert-to-use-prandom-library.patch
* mtd-mtd_speedtest-use-prandom_bytes.patch
* mtd-mtd_subpagetest-convert-to-use-prandom-library.patch
* mtd-mtd_stresstest-use-prandom_bytes.patch
* eventfd-fix-incorrect-filename-is-a-comment.patch
* dma-debug-new-interfaces-to-debug-dma-mapping-errors-fix-fix.patch
* drivers-pps-clients-pps-gpioc-use-devm_kzalloc.patch
* w1-add-support-for-ds2413-dual-channel-addressable-switch.patch
* ocfs2-fix-possible-use-after-free-with-aio.patch
* fs-direct-ioc-fix-possible-use-after-free-with-aio.patch
* mm-remove-old-aio-use_mm-comment.patch
* aio-remove-dead-code-from-aioh.patch
* gadget-remove-only-user-of-aio-retry.patch
* aio-remove-retry-based-aio.patch
* char-add-aio_readwrite-to-dev-nullzero.patch
* aio-kill-return-value-of-aio_complete.patch
* aio-kiocb_cancel.patch
* aio-kiocb_cancel-fix.patch
* aio-move-private-stuff-out-of-aioh.patch
* aio-dprintk-pr_debug.patch
* aio-do-fget-after-aio_get_req.patch
* aio-make-aio_put_req-lockless.patch
* aio-refcounting-cleanup.patch
* wait-add-wait_event_hrtimeout.patch
* wait-add-wait_event_hrtimeout-fix.patch
* aio-make-aio_read_evt-more-efficient-convert-to-hrtimers.patch
* aio-use-flush_dcache_page.patch
* aio-use-cancellation-list-lazily.patch
* aio-use-cancellation-list-lazily-fix.patch
* aio-use-cancellation-list-lazily-fix-fix.patch
* aio-change-reqs_active-to-include-unreaped-completions.patch
* aio-kill-batch-allocation.patch
* aio-kill-struct-aio_ring_info.patch
* aio-give-shared-kioctx-fields-their-own-cachelines.patch
* aio-give-shared-kioctx-fields-their-own-cachelines-fix.patch
* aio-reqs_active-reqs_available.patch
* aio-percpu-reqs_available.patch
* generic-dynamic-per-cpu-refcounting.patch
* generic-dynamic-per-cpu-refcounting-fix.patch
* generic-dynamic-per-cpu-refcounting-sparse-fixes.patch
* generic-dynamic-per-cpu-refcounting-sparse-fixes-fix.patch
* generic-dynamic-per-cpu-refcounting-doc.patch
* generic-dynamic-per-cpu-refcounting-doc-fix.patch
* aio-percpu-ioctx-refcount.patch
* aio-use-xchg-instead-of-completion_lock.patch
* aio-dont-include-aioh-in-schedh.patch
* aio-dont-include-aioh-in-schedh-fix.patch
* aio-dont-include-aioh-in-schedh-fix-fix.patch
* aio-dont-include-aioh-in-schedh-fix-3.patch
* aio-dont-include-aioh-in-schedh-fix-3-fix.patch
* aio-dont-include-aioh-in-schedh-fix-3-fix-fix.patch
* aio-kill-ki_key.patch
* aio-kill-ki_retry.patch
* aio-kill-ki_retry-fix.patch
* aio-kill-ki_retry-fix-fix.patch
* block-aio-batch-completion-for-bios-kiocbs.patch
* block-aio-batch-completion-for-bios-kiocbs-fix.patch
* block-aio-batch-completion-for-bios-kiocbs-fix-fix.patch
* block-aio-batch-completion-for-bios-kiocbs-fix-fix-fix.patch
* block-aio-batch-completion-for-bios-kiocbs-fix-fix-fix-fix.patch
* block-aio-batch-completion-for-bios-kiocbs-fix-fix-fix-fix-fix.patch
* block-aio-batch-completion-for-bios-kiocbs-fix-fix-fix-fix-fix-fix.patch
* block-aio-batch-completion-for-bios-kiocbs-fix-fix-fix-fix-fix-fix-fix.patch
* virtio-blk-convert-to-batch-completion.patch
* mtip32xx-convert-to-batch-completion.patch
* aio-fix-aio_read_events_ring-types.patch
* aio-document-clarify-aio_read_events-and-shadow_tail.patch
* aio-correct-calculation-of-available-events.patch
* aio-v2-fix-kioctx-not-being-freed-after-cancellation-at-exit-time.patch
* aio-v3-fix-kioctx-not-being-freed-after-cancellation-at-exit-time.patch
* arch-kconfig-centralise-config_arch_no_virt_to_bus.patch
* kfifo-move-kfifoc-from-kernel-to-lib.patch
* kfifo-fix-kfifo_alloc-and-kfifo_init.patch
* selftests-add-tests-for-efivarfs.patch
* selftests-add-tests-for-efivarfs-fix.patch
* selftests-add-tests-for-efivarfs-fix-fix.patch
* selftests-efivarfs-add-empty-file-creation-test.patch
* selftests-efivarfs-add-create-read-test.patch
* tools-testing-selftests-makefile-rearrange-targets.patch
* selftests-add-a-simple-doc.patch
* selftests-add-a-simple-doc-fix.patch
* kcmp-make-it-depend-on-checkpoint_restore.patch
* hlist-drop-the-node-parameter-from-iterators.patch
* hlist-drop-the-node-parameter-from-iterators-fix-fix-fix-fix.patch
* hlist-drop-the-node-parameter-from-iterators-fix-fix-fix-fix-fix.patch
* hlist-drop-the-node-parameter-from-iterators-checkpatch-fixes.patch
* hlist-drop-the-node-parameter-from-iterators-fix.patch
* hlist-drop-the-node-parameter-from-iterators-fix-fix.patch
* hlist-drop-the-node-parameter-from-iterators-fix-fix-fix.patch
* hlist-drop-the-node-parameter-from-iterators-redo-kvm.patch
* hlist-drop-the-node-parameter-from-iterators-fix-fix-fix-fix-fix-fix.patch
* hlist-drop-the-node-parameter-from-iterators-mlx4-fix.patch
  debugging-keep-track-of-page-owners.patch
  debugging-keep-track-of-page-owners-fix.patch
  debugging-keep-track-of-page-owners-fix-2.patch
  debugging-keep-track-of-page-owners-fix-2-fix.patch
  debugging-keep-track-of-page-owners-fix-2-fix-fix.patch
  debugging-keep-track-of-page-owner-now-depends-on-stacktrace_support.patch
  make-sure-nobodys-leaking-resources.patch
  journal_add_journal_head-debug.patch
  releasing-resources-with-children.patch
  make-frame_pointer-default=y.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  mutex-subsystem-synchro-test-module.patch
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
