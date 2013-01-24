Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 1169A6B0002
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 20:05:42 -0500 (EST)
Received: by mail-qc0-f201.google.com with SMTP id a22so491213qcs.4
        for <linux-mm@kvack.org>; Wed, 23 Jan 2013 17:05:41 -0800 (PST)
Subject: mmotm 2013-01-23-17-04 uploaded
From: akpm@linux-foundation.org
Date: Wed, 23 Jan 2013 17:05:39 -0800
Message-Id: <20130124010541.226C65A41C6@corp2gmr1-2.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

The mm-of-the-moment snapshot 2013-01-23-17-04 has been uploaded to

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


This mmotm tree contains the following patches against 3.8-rc4:
(patches marked "*" will be included in linux-next)

  origin.patch
* nilfs2-fix-fix-very-long-mount-time-issue.patch
* thp-avoid-dumping-huge-zero-page.patch
* tools-vm-add-gitignore-to-ignore-built-binaries.patch
* drivers-rtc-rtc-vt8500c-fix-year-field-in-vt8500_rtc_set_time.patch
* mm-hugetlb-set-pte-as-huge-in-hugetlb_change_protection-and-remove_migration_pte.patch
* maintainers-update-avr32-web-ressources.patch
* fb-rework-locking-to-fix-lock-ordering-on-takeover.patch
* fb-yet-another-band-aid-for-fixing-lockdep-mess.patch
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
* fs-block_devc-page-cache-wrongly-left-invalidated-after-revalidate_disk.patch
* x86-numa-dont-check-if-node-is-numa_no_node.patch
* arch-x86-tools-insn_sanityc-identify-source-of-messages.patch
* uv-fix-incorrect-tlb-flush-all-issue.patch
* olpc-fix-olpc-xo1-scic-build-errors.patch
* x86-convert-update_mmu_cache-and-update_mmu_cache_pmd-to-functions.patch
* x86-fix-the-argument-passed-to-sync_global_pgds.patch
* x86-fix-a-compile-error-a-section-type-conflict.patch
* revert-x86-mm-make-spurious_fault-check-explicitly-check-the-present-bit.patch
* pageattr-prevent-pse-and-gloabl-leftovers-to-confuse-pmd-pte_present-and-pmd_huge.patch
* x86-make-mem=-option-to-work-for-efi-platform.patch
* cris-use-int-for-ssize_t-to-match-size_t.patch
* pcmcia-move-unbind-rebind-into-dev_pm_opscomplete.patch
* cyber2000fb-avoid-palette-corruption-at-higher-clocks.patch
* timeconstpl-remove-deprecated-defined-array.patch
* time-dont-inline-export_symbol-functions.patch
* timer_list-split-timer_list_show_tickdevices.patch
* timer_list-convert-timer-list-to-be-a-proper-seq_file.patch
* timer_list-convert-timer-list-to-be-a-proper-seq_file-fix.patch
* timer_list-convert-timer-list-to-be-a-proper-seq_file-v2.patch
* timer_list-convert-timer-list-to-be-a-proper-seq_file-v2-fix.patch
* timer_list-convert-timer-list-to-be-a-proper-seq_file-fix-fix.patch
* sched-proc-sched_stat-fails-on-very-very-large-machines.patch
* sched-proc-sched_stat-fails-on-very-very-large-machines-fix.patch
* sched-proc-sched_stat-fails-on-very-very-large-machines-v2.patch
* sched-proc-sched_stat-fails-on-very-very-large-machines-v2-fix.patch
* sched-proc-sched_stat-fails-on-very-very-large-machines-v2-fix-fix.patch
* sched-proc-sched_debug-fails-on-very-very-large-machines.patch
* sched-proc-sched_debug-fails-on-very-very-large-machines-fix.patch
* sched-proc-sched_debug-fails-on-very-very-large-machines-v2.patch
* sched-proc-sched_debug-fails-on-very-very-large-machines-v2-fix.patch
* lockdep-rename-print_unlock_inbalance_bug-to-print_unlock_imbalance_bug.patch
* lockdep-make-lockdep_assert_held-not-have-a-return-value.patch
* block-dont-select-percpu_rwsem.patch
* drivers-block-swim3c-fix-null-pointer-dereference.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* fs-change-return-values-from-eacces-to-eperm.patch
* fs-block_devc-need-not-to-check-inode-i_bdev-in-bd_forget.patch
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
* mm-make-madvisemadv_willneed-support-swap-file-prefetch.patch
* mm-make-madvisemadv_willneed-support-swap-file-prefetch-fix.patch
* mm-make-madvisemadv_willneed-support-swap-file-prefetch-fix-fix.patch
* mm-compaction-make-__compact_pgdat-and-compact_pgdat-return-void.patch
* mm-avoid-calling-pgdat_balanced-needlessly.patch
* mm-make-mlockall-preserve-flags-other-than-vm_locked-in-def_flags.patch
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
* memory-hotplug-consider-compound-pages-when-free-memmap.patch
* mempolicy-fix-is_valid_nodemask.patch
* cpu_hotplug-clear-apicid-to-node-when-the-cpu-is-hotremoved.patch
* memory-hotplug-export-the-function-try_offline_node.patch
* cpu-hotplug-memory-hotplug-try-offline-the-node-when-hotremoving-a-cpu.patch
* cpu-hotplugmemory-hotplug-clear-cpu_to_node-when-offlining-the-node.patch
* cpu-hotplugmemory-hotplug-clear-cpu_to_node-when-offlining-the-node-fix.patch
* sched-do-not-use-cpu_to_node-to-find-an-offlined-cpus-node.patch
* mm-memblockc-use-config_have_memblock_node_map-to-protect-movablecore_map-in-memblock_overlaps_region.patch
* mm-dont-wait-on-congested-zones-in-balance_pgdat.patch
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
* mm-use-zone-present_pages-instead-of-zone-managed_pages-where-appropriate.patch
* mm-set-zone-present_pages-to-number-of-existing-pages-in-the-zone.patch
* mm-increase-totalram_pages-when-free-pages-allocated-by-bootmem-allocator.patch
* mm-remove-migrate_isolate-check-in-hotpath.patch
* memory-failure-fix-an-error-of-mce_bad_pages-statistics.patch
* memory-failure-do-code-refactor-of-soft_offline_page.patch
* memory-failure-use-num_poisoned_pages-instead-of-mce_bad_pages.patch
* memory-failure-use-num_poisoned_pages-instead-of-mce_bad_pages-fix.patch
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
* swap-add-per-partition-lock-for-swapfile.patch
* mm-rmap-rename-anon_vma_unlock-=-anon_vma_unlock_write.patch
* page-writebackc-subtract-min_free_kbytes-from-dirtyable-memory.patch
* page-writebackc-subtract-min_free_kbytes-from-dirtyable-memory-fix.patch
* page-writebackc-subtract-min_free_kbytes-from-dirtyable-memory-fix-fix.patch
* memcg-do-not-create-memsw-files-if-swap-accounting-is-disabled.patch
* memcg-clean-up-swap-accounting-initialization-code.patch
* mm-uninline-page_xchg_last_nid.patch
* mm-init-report-on-last-nid-information-stored-in-page-flags.patch
* mm-memmap_init_zone-performance-improvement.patch
* drop_caches-add-some-documentation-and-info-messsge.patch
* drivers-usb-gadget-amd5536udcc-avoid-calling-dma_pool_create-with-null-dev.patch
* mm-dmapoolc-fix-null-dev-in-dma_pool_create.patch
* memcg-debugging-facility-to-access-dangling-memcgs.patch
* memcg-debugging-facility-to-access-dangling-memcgs-fix.patch
* mm-add-vm-event-counters-for-balloon-pages-compaction.patch
* mm-prevent-addition-of-pages-to-swap-if-may_writepage-is-unset.patch
* bdi-allow-block-devices-to-say-that-they-require-stable-page-writes.patch
* mm-only-enforce-stable-page-writes-if-the-backing-device-requires-it.patch
* 9pfs-fix-filesystem-to-wait-for-stable-page-writeback.patch
* block-optionally-snapshot-page-contents-to-provide-stable-pages-during-write.patch
* ocfs2-wait-for-page-writeback-to-provide-stable-pages.patch
* ubifs-wait-for-page-writeback-to-provide-stable-pages.patch
* scripts-pnmtologo-fix-for-plain-pbm-checkpatch-fixes.patch
* smp-make-smp_call_function_many-use-logic-similar-to-smp_call_function_single.patch
* config_panic_on_oops-should-be-shown-if-debug_kernel.patch
* include-linux-fsh-disable-preempt-when-acquire-i_size_seqcount-write-lock.patch
* kernel-smpc-cleanups.patch
* get_maintainerpl-find-maintainers-for-removed-files.patch
* maintainers-mm-add-additional-include-files-to-listing.patch
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
* lib-parserc-fix-up-comments-for-valid-return-values-from-match_number.patch
* checkpatch-prefer-dev_level-to-dev_printkkern_level.patch
* checkpatch-warn-on-unnecessary-__devfoo-section-markings.patch
* checkpatch-add-joe-to-maintainers.patch
* checkpatch-dont-emit-the-camelcase-warning-for-pagefoo.patch
* epoll-support-for-disabling-items-and-a-self-test-app.patch
* epoll-support-for-disabling-items-and-a-self-test-app-fix.patch
* binfmt_elf-remove-unused-argument-in-fill_elf_header.patch
* binfmt_elfc-use-get_random_int-to-fix-entropy-depleting.patch
* drivers-rtc-dump-small-buffers-via-%ph.patch
* drivers-rtc-rtc-pxac-fix-alarm-not-match-issue.patch
* drivers-rtc-rtc-pxac-fix-alarm-cant-wake-up-system-issue.patch
* drivers-rtc-rtc-pxac-fix-set-time-sync-time-issue.patch
* drivers-rtc-rtc-pxac-fix-set-time-sync-time-issue-fix.patch
* rtc-ds1307-long-block-operations-bugfix.patch
* rtc-ds1307-long-block-operations-bugfix-fix.patch
* rtc-max77686-add-maxim-77686-driver.patch
* rtc-max77686-add-maxim-77686-driver-fix.patch
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
* rtc-add-support-of-rtc-mv-for-mvebu-socs.patch
* arm-mvebu-add-rtc-support-for-armada-370-and-armada-xp.patch
* arm-mvebu-update-defconfig-with-marvell-rtc-support.patch
* hfsplus-add-osx-prefix-for-handling-namespace-of-mac-os-x-extended-attributes.patch
* hfsplus-add-on-disk-layout-declarations-related-to-attributes-tree.patch
* hfsplus-add-functionality-of-manipulating-by-records-in-attributes-tree.patch
* hfsplus-rework-functionality-of-getting-setting-and-deleting-of-extended-attributes.patch
* hfsplus-add-support-of-manipulation-by-attributes-file.patch
* fat-add-extended-fileds-to-struct-fat_boot_sector.patch
* fat-mark-fs-as-dirty-on-mount-and-clean-on-umount.patch
* documentation-dma-api-howtotxt-minor-grammar-corrections.patch
* documentation-cgroups-blkio-controllertxt-fix-typo.patch
* signal-allow-to-send-any-siginfo-to-itself.patch
* signal-allow-to-send-any-siginfo-to-itself-fix.patch
* signalfd-add-ability-to-return-siginfo-in-a-raw-format-v2.patch
* signalfd-add-ability-to-return-siginfo-in-a-raw-format-v2-fix.patch
* signalfd-add-ability-to-read-siginfo-s-without-dequeuing-signals-v4.patch
* seq-file-use-seek_-macros-instead-of-hardcoded-numbers.patch
* fs-seq_filec-seq_lseek-fix-switch-statement-indenting.patch
* fs-seq_filec-seq_lseek-fix-switch-statement-indenting-checkpatch-fixes.patch
* fork-unshare-remove-dead-code.patch
* fs-execc-make-bprm_mm_init-static.patch
* kexec-add-the-values-related-to-buddy-system-for-filtering-free-pages.patch
* ipc-semc-alternatives-to-preempt_disable.patch
* ipmi-remove-superfluous-kernel-userspace-explanation.patch
* ipmi-add-new-kernel-options-to-prevent-automatic-ipmi-init.patch
* ipmi-add-options-to-disable-openfirmware-and-pci-scanning.patch
* drivers-char-miscc-misc_register-do-not-loop-on-misc_list-unconditionally.patch
* drivers-char-miscc-misc_register-do-not-loop-on-misc_list-unconditionally-fix.patch
* sysctl-fix-null-checking-in-bin_dn_node_address.patch
* mtd-mtd_nandecctest-use-prandom_bytes-instead-of-get_random_bytes.patch
* mtd-mtd_oobtest-convert-to-use-prandom-library.patch
* mtd-mtd_pagetest-convert-to-use-prandom-library.patch
* mtd-mtd_speedtest-use-prandom_bytes.patch
* mtd-mtd_subpagetest-convert-to-use-prandom-library.patch
* mtd-mtd_stresstest-use-prandom_bytes.patch
* dma-debug-new-interfaces-to-debug-dma-mapping-errors-fix-fix.patch
* profiling-remove-unused-timer-hook.patch
* w1-add-support-for-ds2413-dual-channel-addressable-switch.patch
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
* aio-kill-ki_key.patch
* aio-kill-ki_retry.patch
* aio-kill-ki_retry-fix.patch
* block-aio-batch-completion-for-bios-kiocbs.patch
* block-aio-batch-completion-for-bios-kiocbs-fix.patch
* block-aio-batch-completion-for-bios-kiocbs-fix-fix.patch
* block-aio-batch-completion-for-bios-kiocbs-fix-fix-fix.patch
* block-aio-batch-completion-for-bios-kiocbs-fix-fix-fix-fix.patch
* block-aio-batch-completion-for-bios-kiocbs-fix-fix-fix-fix-fix.patch
* block-aio-batch-completion-for-bios-kiocbs-fix-fix-fix-fix-fix-fix.patch
* virtio-blk-convert-to-batch-completion.patch
* mtip32xx-convert-to-batch-completion.patch
* aio-smoosh-struct-kiocb.patch
* aio-smoosh-struct-kiocb-fix.patch
* aio-fix-aio_read_events_ring-types.patch
* aio-document-clarify-aio_read_events-and-shadow_tail.patch
* kfifo-move-kfifoc-from-kernel-to-lib.patch
* kfifo-fix-kfifo_alloc-and-kfifo_init.patch
  debugging-keep-track-of-page-owners.patch
  debugging-keep-track-of-page-owners-fix.patch
  debugging-keep-track-of-page-owners-fix-2.patch
  debugging-keep-track-of-page-owners-fix-2-fix.patch
  debugging-keep-track-of-page-owners-fix-2-fix-fix.patch
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
