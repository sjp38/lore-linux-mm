Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id D69AA6B005A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 20:00:58 -0400 (EDT)
Received: by bkwj4 with SMTP id j4so112846bkw.2
        for <linux-mm@kvack.org>; Fri, 29 Jun 2012 17:00:57 -0700 (PDT)
Subject: mmotm 2012-06-29-17-00 uploaded
From: akpm@linux-foundation.org
Date: Fri, 29 Jun 2012 17:00:54 -0700
Message-Id: <20120630000055.AF381A02DE@akpm.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

The mm-of-the-moment snapshot 2012-06-29-17-00 has been uploaded to

   http://www.ozlabs.org/~akpm/mmotm/

It contains the following patches against 3.5-rc4:
(patches marked "*" will be included in linux-next)

  origin.patch
* selinux-fix-something.patch
  linux-next.patch
  linux-next-git-rejects.patch
  i-need-old-gcc.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  drivers-block-nvmec-stop-breaking-my-i386-build.patch
  thermal-constify-type-argument-for-the-registration-routine.patch
* memory-hotplug-fix-invalid-memory-access-caused-by-stale-kswapd-pointer.patch
* memory-hotplug-fix-invalid-memory-access-caused-by-stale-kswapd-pointer-fix.patch
* drivers-rtc-rtc-spearc-fix-use-after-free-in-spear_rtc_remove.patch
* mn10300-move-setup_jiffies_interrupt-to-cevt-mn10300c.patch
* mn10300-remove-duplicate-definition-of-ptrace_o_tracesysgood.patch
* mn10300-kernel-internalh-needs-linux-irqreturnh.patch
* mn10300-kernel-trapsc-needs-linux-exporth.patch
* mn10300-mm-dma-allocc-needs-linux-exporth.patch
* mn10300-use-elif-definedconfig_-instead-of-elif-config_.patch
* ocfs2-fix-null-pointer-dereferrence-in-__ocfs2_change_file_space.patch
* c-r-prctl-less-paranoid-prctl_set_mm_exe_file.patch
* drivers-gpio-devresc-export-devm_gpio_request_one-to-modules.patch
* mm-thp-abort-compaction-if-migration-page-cannot-be-charged-to-memcg.patch
* drivers-rtc-rtc-ab8500c-use-irqf_oneshot-when-requesting-a-threaded-irq.patch
* rtc-ensure-correct-probing-of-the-ab8500-rtc-when-device-tree-is-enabled.patch
* rtc-ensure-correct-probing-of-the-ab8500-rtc-when-device-tree-is-enabled-checkpatch-fixes.patch
* mm-fix-goal-calculating-with-usemap.patch
* h8300-pgtable-add-missing-include-asm-generic-pgtableh.patch
* h8300-signal-fix-typo-statis.patch
* h8300-time-add-missing-include-asm-irq_regsh.patch
* h8300-uaccess-remove-assignment-to-__gu_val-in-unhandled-case-of-get_user.patch
* h8300-uaccess-add-mising-__clear_user.patch
* mm-memory_hotplugc-release-memory-resources-if-hotadd_new_pgdat-fails.patch
* drivers-rtc-rtc-mxcc-fix-irq-enabled-interrupts-warning.patch
* fs-ramfs-file-nommu-add-setpageuptodate.patch
* sgi-xp-nested-calls-to-spin_lock_irqsave.patch
* maintainers-add-omap-cpufreq-driver-to-omap-power-management-section.patch
* memblock-free-allocated-memblock_reserved_regions-later.patch
* fat-fix-non-atomic-nfs-i_pos-read.patch
* cciss-fix-incorrect-scsi-status-reporting.patch
* arch-x86-platform-iris-irisc-register-a-platform-device-and-a-platform-driver.patch
* arch-x86-include-asm-spinlockh-fix-comment.patch
* arch-x86-kernel-cpu-perf_event_intel_uncoreh-make-uncore_pmu_hrtimer_interval-64-bit.patch
* cpuidle-move-field-disable-from-per-driver-to-per-cpu.patch
* prctl-remove-redunant-assignment-of-error-to-zero.patch
  cyber2000fb-avoid-palette-corruption-at-higher-clocks.patch
* timeconstpl-remove-deprecated-defined-array.patch
* time-dont-inline-export_symbol-functions.patch
* include-linux-timeh-make-nsec_per_sec-64-bit-on-32-bit-architectures.patch
* include-linux-timeh-make-nsec_per_sec-64-bit-on-32-bit-architectures-fix.patch
* include-linux-timeh-make-nsec_per_sec-64-bit-on-32-bit-architectures-fix-fix.patch
* include-linux-timeh-make-nsec_per_sec-64-bit-on-32-bit-architectures-fix-fix-fix.patch
* include-linux-timeh-make-nsec_per_sec-64-bit-on-32-bit-architectures-fix-fix-fix-fix.patch
* thermal-fix-potential-out-of-bounds-memory-access.patch
* ocfs2-use-find_last_bit.patch
* ocfs2-use-bitmap_weight.patch
* drivers-scsi-ufs-use-module_pci_driver.patch
* drivers-scsi-ufs-reverse-the-ufshcd_is_device_present-logic.patch
* ufs-fix-incorrect-return-value-about-success-and-failed.patch
* drivers-scsi-atp870uc-fix-bad-use-of-udelay.patch
* vfs-increment-iversion-when-a-file-is-truncated.patch
* fs-push-rcu_barrier-from-deactivate_locked_super-to-filesystems.patch
* hfs-push-lock_super-down.patch
* hfs-get-rid-of-lock_super.patch
* hfs-remove-extra-mdb-write-on-unmount.patch
* hfs-simplify-a-bit-checking-for-r-o.patch
* hfs-introduce-vfs-superblock-object-back-reference.patch
* hfs-get-rid-of-hfs_sync_super.patch
* hfs-get-rid-of-hfs_sync_super-checkpatch-fixes.patch
* fs-xattrc-getxattr-improve-handling-of-allocation-failures.patch
* fs-add-link-restrictions.patch
* fs-add-link-restriction-audit-reporting.patch
* fs-make-dumpable=2-require-fully-qualified-path.patch
* coredump-warn-about-unsafe-suid_dumpable-core_pattern-combo.patch
* xtensa-mm-faultc-port-oom-changes-to-do_page_fault.patch
* mm-slab-remove-duplicate-check.patch
* slab-move-full-state-transition-to-an-initcall.patch
* slab-do-not-call-compound_head-in-page_get_cache.patch
  mm.patch
* vmalloc-walk-vmap_areas-by-sorted-list-instead-of-rb_next.patch
* mm-make-vb_alloc-more-foolproof.patch
* mm-make-vb_alloc-more-foolproof-fix.patch
* memcg-rename-mem_cgroup_stat_swapout-as-mem_cgroup_stat_swap.patch
* memcg-rename-mem_cgroup_charge_type_mapped-as-mem_cgroup_charge_type_anon.patch
* memcg-remove-mem_cgroup_charge_type_force.patch
* swap-allow-swap-readahead-to-be-merged.patch
* documentation-update-how-page-cluster-affects-swap-i-o.patch
* mm-account-the-total_vm-in-the-vm_stat_account.patch
* mm-buddy-cleanup-on-should_fail_alloc_page.patch
* mm-prepare-for-removal-of-obsolete-proc-sys-vm-nr_pdflush_threads.patch
* hugetlb-rename-max_hstate-to-hugetlb_max_hstate.patch
* hugetlb-dont-use-err_ptr-with-vm_fault-values.patch
* hugetlb-add-an-inline-helper-for-finding-hstate-index.patch
* hugetlb-use-mmu_gather-instead-of-a-temporary-linked-list-for-accumulating-pages.patch
* hugetlb-avoid-taking-i_mmap_mutex-in-unmap_single_vma-for-hugetlb.patch
* hugetlb-simplify-migrate_huge_page.patch
* hugetlb-add-a-list-for-tracking-in-use-hugetlb-pages.patch
* hugetlb-make-some-static-variables-global.patch
* hugetlb-make-some-static-variables-global-mark-hugelb_max_hstate-__read_mostly.patch
* mm-hugetlb-add-new-hugetlb-cgroup.patch
* mm-hugetlb-add-new-hugetlb-cgroup-fix.patch
* mm-hugetlb-add-new-hugetlb-cgroup-fix-fix.patch
* mm-hugetlb-add-new-hugetlb-cgroup-fix-3.patch
* mm-hugetlb-add-new-hugetlb-cgroup-mark-root_h_cgroup-static.patch
* hugetlb-cgroup-add-the-cgroup-pointer-to-page-lru.patch
* hugetlb-cgroup-add-charge-uncharge-routines-for-hugetlb-cgroup.patch
* hugetlb-cgroup-add-charge-uncharge-routines-for-hugetlb-cgroup-fix.patch
* hugetlb-cgroup-add-support-for-cgroup-removal.patch
* hugetlb-cgroup-add-hugetlb-cgroup-control-files.patch
* hugetlb-cgroup-add-hugetlb-cgroup-control-files-fix.patch
* hugetlb-cgroup-add-hugetlb-cgroup-control-files-fix-fix.patch
* hugetlb-cgroup-migrate-hugetlb-cgroup-info-from-oldpage-to-new-page-during-migration.patch
* hugetlb-cgroup-add-hugetlb-controller-documentation.patch
* hugetlb-move-all-the-in-use-pages-to-active-list.patch
* hugetlb-cgroup-assign-the-page-hugetlb-cgroup-when-we-move-the-page-to-active-list.patch
* hugetlb-cgroup-remove-exclude-and-wakeup-rmdir-calls-from-migrate.patch
* mm-oom-do-not-schedule-if-current-has-been-killed.patch
* mm-memblockc-memblock_double_array-cosmetic-cleanups.patch
* memcg-remove-check-for-signal_pending-during-rmdir.patch
* memcg-clean-up-force_empty_list-return-value-check.patch
* memcg-mem_cgroup_move_parent-doesnt-need-gfp_mask.patch
* memcg-make-mem_cgroup_force_empty_list-return-bool.patch
* memcg-make-mem_cgroup_force_empty_list-return-bool-fix.patch
* mm-compaction-cleanup-on-compaction_deferred.patch
* memcg-prevent-oom-with-too-many-dirty-pages.patch
* mm-fadvise-dont-return-einval-when-filesystem-cannot-implement-fadvise.patch
* mm-fadvise-dont-return-einval-when-filesystem-cannot-implement-fadvise-checkpatch-fixes.patch
* mm-clear-pages_scanned-only-if-draining-a-pcp-adds-pages-to-the-buddy-allocator-again.patch
* mm-oom-fix-potential-killing-of-thread-that-is-disabled-from-oom-killing.patch
* mm-oom-replace-some-information-in-tasklist-dump.patch
* mm-do-not-use-page_count-without-a-page-pin.patch
* mm-clean-up-__count_immobile_pages.patch
* memcg-rename-config-variables.patch
* memcg-rename-config-variables-fix.patch
* memcg-rename-config-variables-fix-fix.patch
* mm-remove-unused-lru_all_evictable.patch
* memcg-fix-bad-behavior-in-use_hierarchy-file.patch
* memcg-rename-mem_control_xxx-to-memcg_xxx.patch
* mm-have-order-0-compaction-start-off-where-it-left.patch
* mm-have-order-0-compaction-start-off-where-it-left-checkpatch-fixes.patch
* mm-config_have_memblock_node-config_have_memblock_node_map.patch
* vmscan-remove-obsolete-shrink_control-comment.patch
* mm-memoryc-print_vma_addr-call-up_readmm-mmap_sem-directly.patch
* tmpfs-implement-numa-node-interleaving.patch
* tmpfs-implement-numa-node-interleaving-fix.patch
* isolate_freepages-check-that-high_pfn-is-aligned-as-expected.patch
* frv-kill-used-but-uninitialized-variable.patch
* avr32-mm-faultc-port-oom-changes-to-do_page_fault.patch
* avr32-mm-faultc-port-oom-changes-to-do_page_fault-fix.patch
* clk-add-non-config_have_clk-routines.patch
* clk-remove-redundant-depends-on-from-drivers-kconfig.patch
* i2c-i2c-pxa-remove-conditional-compilation-of-clk-code.patch
* usb-marvell-remove-conditional-compilation-of-clk-code.patch
* usb-musb-remove-conditional-compilation-of-clk-code.patch
* ata-pata_arasan-remove-conditional-compilation-of-clk-code.patch
* net-c_can-remove-conditional-compilation-of-clk-code.patch
* net-stmmac-remove-conditional-compilation-of-clk-code.patch
* gadget-m66592-remove-conditional-compilation-of-clk-code.patch
* gadget-r8a66597-remove-conditional-compilation-of-clk-code.patch
* usb-host-r8a66597-remove-conditional-compilation-of-clk-code.patch
* arch-arm-mach-netx-fbc-reuse-dummy-clk-routines-for-config_have_clk=n.patch
* clk-validate-pointer-in-__clk_disable.patch
* panic-fix-a-possible-deadlock-in-panic.patch
* nmi-watchdog-fix-for-lockup-detector-breakage-on-resume.patch
* kmsg-dev-kmsg-properly-return-possible-copy_from_user-failure.patch
* printk-add-generic-functions-to-find-kern_level-headers.patch
* printk-add-generic-functions-to-find-kern_level-headers-fix.patch
* printk-add-kern_levelsh-to-make-kern_level-available-for-asm-use.patch
* arch-remove-direct-definitions-of-kern_level-uses.patch
* btrfs-use-printk_get_level-and-printk_skip_level-add-__printf-fix-fallout.patch
* btrfs-use-printk_get_level-and-printk_skip_level-add-__printf-fix-fallout-fix.patch
* btrfs-use-printk_get_level-and-printk_skip_level-add-__printf-fix-fallout-checkpatch-fixes.patch
* sound-use-printk_get_level-and-printk_skip_level.patch
* printk-convert-the-format-for-kern_level-to-a-2-byte-pattern.patch
* printk-only-look-for-prefix-levels-in-kernel-messages.patch
* printk-remove-the-now-unnecessary-c-annotation-for-kern_cont.patch
* vsprintf-add-%pmr-for-bluetooth-mac-address.patch
* vsprintf-add-%pmr-for-bluetooth-mac-address-fix.patch
* lib-vsprintfc-remind-people-to-update-documentation-printk-formatstxt-when-adding-printk-formats.patch
* drivers-video-backlight-atmel-pwm-blc-use-devm_-functions.patch
* drivers-video-backlight-ot200_blc-use-devm_-functions.patch
* drivers-video-backlight-lm3533_blc-use-devm_-functions.patch
* backlight-atmel-pwm-bl-use-devm_gpio_request.patch
* backlight-ot200_bl-use-devm_gpio_request.patch
* backlight-tosa_lcd-use-devm_gpio_request.patch
* backlight-tosa_bl-use-devm_gpio_request.patch
* backlight-lms283gf05-use-devm_gpio_request.patch
* backlight-corgi_lcd-use-devm_gpio_request.patch
* backlight-l4f00242t03-use-devm_gpio_request_one.patch
* string-introduce-memweight.patch
* string-introduce-memweight-fix.patch
* string-introduce-memweight-fix-build-error-caused-by-memweight-introduction.patch
* qnx4fs-use-memweight.patch
* dm-use-memweight.patch
* affs-use-memweight.patch
* video-uvc-use-memweight.patch
* ocfs2-use-memweight.patch
* ext2-use-memweight.patch
* ext3-use-memweight.patch
* ext4-use-memweight.patch
* checkpatch-update-alignment-check.patch
* checkpatch-test-for-non-standard-signatures.patch
* checkpatch-check-usleep_range-arguments.patch
* drivers-rtc-rtc-coh901331c-use-clk_prepare-unprepare.patch
* drivers-rtc-rtc-coh901331c-use-devm-allocation.patch
* rtc-pl031-encapsulate-per-vendor-ops.patch
* rtc-pl031-use-per-vendor-variables-for-special-init.patch
* rtc-pl031-fix-up-irq-flags.patch
* drivers-rtc-rtc-ab8500c-use-uie-emulation.patch
* drivers-rtc-rtc-ab8500c-use-uie-emulation-checkpatch-fixes.patch
* drivers-rtc-rtc-ab8500c-remove-fix-for-ab8500-ed-version.patch
* drivers-rtc-rtc-r9701c-avoid-second-call-to-rtc_valid_tm.patch
* drivers-rtc-rtc-r9701c-check-that-r9701_set_datetime-succeeded.patch
* hfsplus-use-enomem-when-kzalloc-fails.patch
* hfsplus-make-hfsplus_sync_fs-static.patch
* hfsplus-amend-debugging-print.patch
* hfsplus-remove-useless-check.patch
* hfsplus-get-rid-of-write_super.patch
* hfsplus-get-rid-of-write_super-checkpatch-fixes.patch
* fat-accessors-for-msdos_dir_entry-start-fields.patch
* kmod-avoid-deadlock-from-recursive-kmod-call.patch
* fork-use-vma_pages-to-simplify-the-code.patch
* fork-use-vma_pages-to-simplify-the-code-fix.patch
* ipc-semc-alternatives-to-preempt_disable.patch
* fs-cachefiles-add-support-for-large-files-in-filesystem-caching.patch
* fs-cachefiles-add-support-for-large-files-in-filesystem-caching-fix.patch
* include-linux-aioh-cpp-c-conversions.patch
* c-r-fcntl-add-f_getowner_uids-option.patch
  make-sure-nobodys-leaking-resources.patch
  journal_add_journal_head-debug.patch
  releasing-resources-with-children.patch
  make-frame_pointer-default=y.patch
  mutex-subsystem-synchro-test-module.patch
  mutex-subsystem-synchro-test-module-fix.patch
  slab-leaks3-default-y.patch
  put_bh-debug.patch
  add-debugging-aid-for-memory-initialisation-problems.patch
  workaround-for-a-pci-restoring-bug.patch
  prio_tree-debugging-patch.patch
  single_open-seq_release-leak-diagnostics.patch
  add-a-refcount-check-in-dput.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
