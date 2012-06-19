Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id B73E56B0078
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 17:25:23 -0400 (EDT)
Received: by qcha6 with SMTP id a6so594656qch.2
        for <linux-mm@kvack.org>; Tue, 19 Jun 2012 14:25:22 -0700 (PDT)
Subject: mmotm 2012-06-19-14-24 uploaded
From: akpm@linux-foundation.org
Date: Tue, 19 Jun 2012 14:25:21 -0700
Message-Id: <20120619212521.D53D6A01BD@akpm.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

The mm-of-the-moment snapshot 2012-06-19-14-24 has been uploaded to

   http://www.ozlabs.org/~akpm/mmotm/

It contains the following patches against 3.5-rc3:
(patches marked "*" will be included in linux-next)

  origin.patch
* selinux-fix-something.patch
  linux-next.patch
  linux-next-git-rejects.patch
  i-need-old-gcc.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  drivers-block-nvmec-stop-breaking-my-i386-build.patch
  drivers-power-power_supply_corec-partially-fix.patch
* mm-fix-slab-page-_count-corruption-when-using-slub.patch
* mm-fix-slab-page-_count-corruption-when-using-slub-fix.patch
* thp-avoid-atomic64_read-in-pmd_read_atomic-for-32bit-pae.patch
* nilfs2-ensure-proper-cache-clearing-for-gc-inodes.patch
* mm-oom-fix-and-cleanup-oom-score-calculations.patch
* memcg-fix-use_hierarchy-css_is_ancestor-oops-regression.patch
* xtensa-replace-xtensa-specific-_fdatatext-by-_sdatatext.patch
* xtensa-use-test-e-instead-of-bashism-test-a.patch
* xtensa-use-the-declarations-provided-by-asm-sectionsh.patch
* h8300-fix-use-of-extinct-_sbss-and-_ebss.patch
* h8300-use-the-declarations-provided-by-asm-sectionsh.patch
* mm-thp-print-useful-information-when-mmap_sem-is-unlocked-in-zap_pmd_range.patch
* mm-correctly-synchronize-rss-counters-at-exit-exec.patch
* mm-fix-kernel-doc-warnings.patch
* mm-memoryc-fix-kernel-doc-warnings.patch
* get_maintainer-fix-help-warning.patch
* viresh-has-moved.patch
* fault-inject-avoid-call-to-random32-if-fault-injection-is-disabled.patch
* pidns-guarantee-that-the-pidns-init-will-be-the-last-pidns-process-reaped.patch
* pidns-find_new_reaper-can-no-longer-switch-to-init_pid_nschild_reaper.patch
* c-r-prctl-move-pr_get_tid_address-to-a-proper-place.patch
* tmpfs-implement-numa-node-interleaving.patch
* tmpfs-implement-numa-node-interleaving-fix.patch
* cciss-fix-incorrect-scsi-status-reporting.patch
* arch-x86-platform-iris-irisc-register-a-platform-device-and-a-platform-driver.patch
* arch-x86-include-asm-spinlockh-fix-comment.patch
  cyber2000fb-avoid-palette-corruption-at-higher-clocks.patch
* timeconstpl-remove-deprecated-defined-array.patch
* time-dont-inline-export_symbol-functions.patch
* ocfs2-use-find_last_bit.patch
* ocfs2-use-bitmap_weight.patch
* drivers-scsi-ufs-use-module_pci_driver.patch
* drivers-scsi-ufs-reverse-the-ufshcd_is_device_present-logic.patch
* ufs-fix-incorrect-return-value-about-success-and-failed.patch
* drivers-scsi-atp870uc-fix-bad-use-of-udelay.patch
* vfs-increment-iversion-when-a-file-is-truncated.patch
* fs-symlink-restrictions-on-sticky-directories.patch
* fs-hardlink-creation-restrictions.patch
* fs-push-rcu_barrier-from-deactivate_locked_super-to-filesystems.patch
* hfs-push-lock_super-down.patch
* hfs-get-rid-of-lock_super.patch
* hfs-remove-extra-mdb-write-on-unmount.patch
* hfs-simplify-a-bit-checking-for-r-o.patch
* hfs-introduce-vfs-superblock-object-back-reference.patch
* hfs-get-rid-of-hfs_sync_super.patch
* hfs-get-rid-of-hfs_sync_super-checkpatch-fixes.patch
* fs-xattrc-getxattr-improve-handling-of-allocation-failures.patch
* mm-slab-remove-duplicate-check.patch
* slab-move-full-state-transition-to-an-initcall.patch
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
* mm-compaction-handle-incorrect-migrate_unmovable-type-pageblocks.patch
* mm-compaction-handle-incorrect-migrate_unmovable-type-pageblocks-fix.patch
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
* hugetlb-cgroup-add-the-cgroup-pointer-to-page-lru.patch
* hugetlb-cgroup-add-charge-uncharge-routines-for-hugetlb-cgroup.patch
* hugetlb-cgroup-add-support-for-cgroup-removal.patch
* hugetlb-cgroup-add-hugetlb-cgroup-control-files.patch
* hugetlb-cgroup-migrate-hugetlb-cgroup-info-from-oldpage-to-new-page-during-migration.patch
* hugetlb-cgroup-add-hugetlb-controller-documentation.patch
* hugetlb-move-all-the-in-use-pages-to-active-list.patch
* hugetlb-cgroup-assign-the-page-hugetlb-cgroup-when-we-move-the-page-to-active-list.patch
* hugetlb-cgroup-remove-exclude-and-wakeup-rmdir-calls-from-migrate.patch
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
* clk-validate-pointer-in-__clk_disable.patch
* nmi-watchdog-fix-for-lockup-detector-breakage-on-resume.patch
* kmsg-dev-kmsg-properly-return-possible-copy_from_user-failure.patch
* printk-add-generic-functions-to-find-kern_level-headers.patch
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
* backlight-l4f00242t03-use-devm_gpio_request_one-fix.patch
* include-linux-bitopsh-fix-warning.patch
* string-introduce-memweight.patch
* string-introduce-memweight-fix.patch
* qnx4fs-use-memweight.patch
* dm-use-memweight.patch
* affs-use-memweight.patch
* video-uvc-use-memweight.patch
* ocfs2-use-memweight.patch
* ext2-use-memweight.patch
* ext3-use-memweight.patch
* ext4-use-memweight.patch
* checkpatch-update-alignment-check.patch
* drivers-rtc-rtc-coh901331c-use-clk_prepare-unprepare.patch
* drivers-rtc-rtc-coh901331c-use-devm-allocation.patch
* drivers-rtc-rtc-ab8500c-use-irqf_oneshot-when-requesting-a-threaded-irq.patch
* hfsplus-use-enomem-when-kzalloc-fails.patch
* kmod-avoid-deadlock-from-recursive-kmod-call.patch
* fork-use-vma_pages-to-simplify-the-code.patch
* fork-use-vma_pages-to-simplify-the-code-fix.patch
* ipc-semc-alternatives-to-preempt_disable.patch
* drivers-char-ipmi-ipmi_watchdogc-remove-local-ioctl-defines-replaced-by-generic-ones.patch
* fs-cachefiles-add-support-for-large-files-in-filesystem-caching.patch
* fs-cachefiles-add-support-for-large-files-in-filesystem-caching-fix.patch
* c-r-fcntl-add-f_getowner_uids-option.patch
* notify_change-check-that-i_mutex-is-held.patch
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
