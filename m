Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id DCEDB6B0032
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 19:16:12 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kp14so1956424pab.20
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 16:16:12 -0700 (PDT)
Received: by mail-yh0-f74.google.com with SMTP id c41so197365yho.5
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 16:16:09 -0700 (PDT)
Subject: mmotm 2013-09-26-16-15 uploaded
From: akpm@linux-foundation.org
Date: Thu, 26 Sep 2013 16:16:08 -0700
Message-Id: <20130926231608.CBF2D5A424C@corp2gmr1-2.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

The mm-of-the-moment snapshot 2013-09-26-16-15 has been uploaded to

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


This mmotm tree contains the following patches against 3.12-rc2:
(patches marked "*" will be included in linux-next)

  origin.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  i-need-old-gcc.patch
* revert-mm-memory-hotplug-fix-lowmem-count-overflow-when-offline-pages.patch
* fs-binfmt_elfc-prevent-a-coredump-with-a-large-vm_map_count-from-oopsing.patch
* fs-binfmt_elfc-prevent-a-coredump-with-a-large-vm_map_count-from-oopsing-fix.patch
* fs-binfmt_elfc-prevent-a-coredump-with-a-large-vm_map_count-from-oopsing-fix-fix.patch
* include-linux-of_irqh-fix-warnings-when-config_of=n.patch
* mm-compactionc-periodically-schedule-when-freeing-pages.patch
* ipc-semc-fix-race-in-sem_lock.patch
* ipc-semc-optimize-sem_lock.patch
* ipc-semc-synchronize-the-proc-interface.patch
* kernel-kmodc-check-for-null-in-call_usermodehelper_exec.patch
* kernel-kmodc-check-for-null-in-call_usermodehelper_exec-update.patch
* mm-bouncec-wix-a-regression-where-ms_snap_stable-stable-pages-snapshotting-was-ignored.patch
* documentation-kernel-parameterstxt-replace-kernelcore-with-movable.patch
* nilfs2-fix-issue-with-race-condition-of-competition-between-segments-for-dirty-blocks.patch
* drm-i915-fix-up-usage-of-shrink_stop.patch
* include-asm-generic-vtimeh-avoid-zero-length-file.patch
* arch-parisc-mm-faultc-fix-uninitialized-variable-usage.patch
* mm-avoid-reinserting-isolated-balloon-pages-into-lru-lists.patch
* mm-avoid-reinserting-isolated-balloon-pages-into-lru-lists-fix.patch
* mm-mlockc-prevent-walking-off-the-end-of-a-pagetable-in-no-pmd-configuration.patch
* block-change-config-option-name-for-cmdline-partition-parsing.patch
* mm-hwpoison-fix-traverse-hugetlbfs-page-to-avoid-printk-flood.patch
* mm-hwpoison-fix-miss-catch-transparent-huge-page.patch
* mm-hwpoison-fix-false-report-2nd-try-page-recovery.patch
* mm-hwpoison-fix-the-lack-of-one-reference-count-against-poisoned-page.patch
* kernel-params-fix-handling-of-signed-integer-types.patch
* ipc-semc-update-sem_otime-for-all-operations.patch
* ipc-semc-update-sem_otime-for-all-operations-checkpatch-fixes.patch
* pidns-fix-free_pid-to-handle-the-first-fork-failure.patch
* kthread-make-kthread_create-killable.patch
* sh64-kernel-use-usp-instead-of-fn.patch
* sh64-kernel-remove-useless-variable-regs.patch
* arch-x86-mnify-pte_to_pgoff-and-pgoff_to_pte-helpers.patch
* x86-srat-use-numa_no_node.patch
* sound-soc-atmel-atmel-pcmc-fix-warning.patch
* kernel-auditc-remove-duplicated-comment.patch
* drivers-pcmcia-pd6729c-convert-to-module_pci_driver.patch
* drivers-pcmcia-yenta_socketc-convert-to-module_pci_driver.patch
* drm-fb-helper-dont-sleep-for-screen-unblank-when-an-oopps-is-in-progress.patch
* drm-cirrus-correct-register-values-for-16bpp.patch
* drm-nouveau-make-vga_switcheroo-code-depend-on-vga_switcheroo.patch
* drm-nouveau-make-vga_switcheroo-code-depend-on-vga_switcheroo-fix.patch
* drivers-iommu-omap-iopgtableh-remove-unneeded-cast-of-void.patch
* genirq-correct-fuzzy-and-fragile-irq_retval-definition.patch
* sched_clock-document-4mhz-vs-1mhz-decision.patch
* kernel-timerc-convert-kmalloc_nodegfp_zero-to-kzalloc_node.patch
* kernel-time-tick-commonc-document-tick_do_timer_cpu.patch
* drivers-infiniband-core-cmc-convert-to-using-idr_alloc_cyclic.patch
* input-remove-unnecessary-work-pending-test.patch
* scripts-sortextable-support-objects-with-more-than-64k-sections.patch
* makefile-enable-werror=implicit-int-and-werror=strict-prototypes-by-default.patch
* drivers-net-irda-donauboe-convert-to-module_pci_driver.patch
* fs-ocfs2-remove-unnecessary-variable-bits_wanted-from-ocfs2_calc_extend_credits.patch
* fs-ocfs2-filec-fix-wrong-comment.patch
* ocfs2-return-enomem-when-sb_getblk-fails.patch
* ocfs2-return-enomem-when-sb_getblk-fails-update.patch
* ocfs2-add-necessary-check-in-case-sb_getblk-fails.patch
* ocfs2-add-necessary-check-in-case-sb_getblk-fails-update.patch
* ocfs2-dont-spam-on-edquot.patch
* ocfs2-use-bitmap_weight.patch
* ocfs2-skip-locks-in-the-blocked-list.patch
* ocfs2-delay-migration-when-the-lockres-is-in-migration-state.patch
* ocfs2-use-find_last_bit.patch
* ocfs2-break-useless-while-loop.patch
* ocfs2-rollback-transaction-in-ocfs2_group_add.patch
* ocfs2-do-not-call-brelse-if-group_bh-is-not-initialized-in-ocfs2_group_add.patch
* ocfs2-add-missing-errno-in-ocfs2_ioctl_move_extents.patch
* ocfs2-should-call-ocfs2_journal_access_di-before-ocfs2_delete_entry-in-ocfs2_orphan_del.patch
* ocfs2-llseek-requires-ocfs2-inode-lock-for-the-file-in-seek_end.patch
* ocfs2-fix-issue-that-ocfs2_setattr-does-not-deal-with-new_i_size==i_size.patch
* ocfs2-update-inode-size-after-zeronig-the-hole.patch
* mm-readaheadc-return-the-value-which-force_page_cache_readahead-returns.patch
* mm-readaheadc-do_readhead-dont-check-for-readpage.patch
* drivers-scsi-a100u2w-convert-to-module_pci_driver.patch
* drivers-scsi-dc395x-convert-to-module_pci_driver.patch
* drivers-scsi-dmx3191d-convert-to-module_pci_driver.patch
* drivers-scsi-initio-convert-to-module_pci_driver.patch
* drivers-scsi-mvumi-convert-to-module_pci_driver.patch
* drivers-scsi-hpsac-remove-unused-smart-array-id.patch
* drivers-cdrom-gdromc-remove-deprecated-irqf_disabled.patch
* fs-bio-integrityc-remove-duplicate-code.patch
* drivers-block-sx8c-use-module_pci_driver.patch
* drivers-block-sx8c-remove-unnecessary-pci_set_drvdata.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* anon_inodefs-forbid-open-via-proc.patch
* watchdog-trigger-all-cpu-backtrace-when-locked-up-and-going-to-panic.patch
  mm.patch
* ksm-remove-redundant-__gfp_zero-from-kcalloc.patch
* mm-vmalloc-use-numa_no_node.patch
* mm-compactionc-update-comment-about-zone-lock-in-isolate_freepages_block.patch
* mm-arch-use-__free_reserved_page-to-simplify-the-code.patch
* drivers-video-acornfbc-use-__free_reserved_page-to-simplify-the-code.patch
* mm-remove-obsolete-comments-about-page-table-lock.patch
* mm-huge_memoryc-fix-stale-comments-of-transparent_hugepage_flags.patch
* mm-use-pgdat_end_pfn-to-simplify-the-code-in-arch.patch
* mm-use-pgdat_end_pfn-to-simplify-the-code-in-others.patch
* mm-use-populated_zone-instead-of-ifzone-present_pages.patch
* mm-memory_hotplugc-rename-the-function-is_memblock_offlined_cb.patch
* mm-memory_hotplugc-use-pfn_to_nid-instead-of-page_to_nidpfn_to_page.patch
* mm-add-a-helper-function-to-check-may-oom-condition.patch
* mm-nobootmemc-have-__free_pages_memory-free-in-larger-chunks.patch
* cpu-mem-hotplug-add-try_online_node-for-cpu_up.patch
* mm-memory-failurec-move-set_migratetype_isolate-outside-get_any_page.patch
* mm-arch-use-numa_no_node.patch
* mm-mempolicy-make-mpol_to_str-robust-and-always-succeed.patch
* mm-vmalloc-dont-set-area-caller-twice.patch
* mm-vmalloc-fix-show-vmap_area-information-race-with-vmap_area-tear-down.patch
* mm-vmalloc-revert-mm-vmallocc-check-vm_uninitialized-flag-in-s_show-instead-of-show_numa_info.patch
* revert-mm-vmallocc-emit-the-failure-message-before-return.patch
* memblock-factor-out-of-top-down-allocation.patch
* memblock-introduce-bottom-up-allocation-mode.patch
* x86-mm-factor-out-of-top-down-direct-mapping-setup.patch
* x86-mem-hotplug-support-initialize-page-tables-in-bottom-up.patch
* x86-acpi-crash-kdump-do-reserve_crashkernel-after-srat-is-parsed.patch
* mem-hotplug-introduce-movablenode-boot-option.patch
* memblock-factor-out-of-top-down-allocation-hack.patch
* documentation-vm-zswaptxt-fix-typos.patch
* mm-thp-cleanup-mv-alloc_hugepage-to-better-place.patch
* mm-thp-khugepaged-add-policy-for-finding-target-node.patch
* mm-thp-khugepaged-add-policy-for-finding-target-node-fix.patch
* mm-mempolicy-use-numa_no_node.patch
* memcg-refactor-mem_control_numa_stat_show.patch
* memcg-support-hierarchical-memorynuma_stats.patch
* mm-kconfig-fix-grammar-s-an-a.patch
* thp-mm-locking-tail-page-is-a-bug.patch
* swap-add-a-simple-detector-for-inappropriate-swapin-readahead.patch
* swap-add-a-simple-detector-for-inappropriate-swapin-readahead-fix.patch
* cramfs-mark-as-obsolete.patch
* syscallsh-use-gcc-alias-instead-of-assembler-aliases-for-syscalls.patch
* scripts-mod-modpostc-handle-non-abs-crc-symbols.patch
* init-do_mountsc-add-maj-min-syntax-comment.patch
* kernel-delayacctc-remove-redundant-checking-in-__delayacct_add_tsk.patch
* kernel-sysc-remove-obsolete-include-linux-kexech.patch
* drivers-misc-ti-st-st_corec-fix-null-dereference-on-protocol-type-check.patch
* printk-report-console-names-during-cut-over.patch
* kernel-printk-printkc-convert-to-pr_foo.patch
* backlight-lp855x_bl-support-new-lp8555-device.patch
* backlight-lm3630-apply-chip-revision.patch
* backlight-ld9040-staticize-local-variable-gamma_table.patch
* backlight-lm3639-dont-mix-different-enum-types.patch
* backlight-lp8788-staticize-default_bl_config.patch
* backlight-use-dev_get_platdata.patch
* backlight-88pm860x_bl-use-devm_backlight_device_register.patch
* backlight-aat2870-use-devm_backlight_device_register.patch
* backlight-adp5520-use-devm_backlight_device_register.patch
* backlight-adp8860-use-devm_backlight_device_register.patch
* backlight-adp8870-use-devm_backlight_device_register.patch
* backlight-as3711_bl-use-devm_backlight_device_register.patch
* backlight-atmel-pwm-bl-use-devm_backlight_device_register.patch
* backlight-bd6107-use-devm_backlight_device_register.patch
* backlight-da903x_bl-use-devm_backlight_device_register.patch
* backlight-da9052_bl-use-devm_backlight_device_register.patch
* backlight-ep93xx-use-devm_backlight_device_register.patch
* backlight-generic_bl-use-devm_backlight_device_register.patch
* backlight-gpio_backlight-use-devm_backlight_device_register.patch
* backlight-kb3886_bl-use-devm_backlight_device_register.patch
* backlight-lm3533_bl-use-devm_backlight_device_register.patch
* backlight-lp855x-use-devm_backlight_device_register.patch
* backlight-lv5207lp-use-devm_backlight_device_register.patch
* backlight-max8925_bl-use-devm_backlight_device_register.patch
* backlight-pandora_bl-use-devm_backlight_device_register.patch
* backlight-pcf50633-use-devm_backlight_device_register.patch
* backlight-tps65217_bl-use-devm_backlight_device_register.patch
* backlight-wm831x_bl-use-devm_backlight_device_register.patch
* backlight-hx8357-use-devm_lcd_device_register.patch
* backlight-ili922x-use-devm_lcd_device_register.patch
* backlight-ili9320-use-devm_lcd_device_register.patch
* backlight-lms283gf05-use-devm_lcd_device_register.patch
* backlight-lms501kf03-use-devm_lcd_device_register.patch
* backlight-ltv350qv-use-devm_lcd_device_register.patch
* backlight-platform_lcd-use-devm_lcd_device_register.patch
* backlight-tdo24m-use-devm_lcd_device_register.patch
* backlight-ams369fg06-use-devm_backlightlcd_device_register.patch
* backlight-ld9040-use-devm_backlightlcd_device_register.patch
* backlight-corgi_lcd-use-devm_backlightlcd_device_register.patch
* backlight-cr_bllcd-use-devm_backlightlcd_device_register.patch
* backlight-s6e63m0-use-devm_backlightlcd_device_register.patch
* backlight-lm3630-signedness-bug-in-lm3630a_chip_init.patch
* backlight-lm3630-potential-null-deref-in-probe.patch
* drivers-video-backlight-l4f00242t03c-remove-redundant-spi_set_drvdata.patch
* drivers-video-backlight-tosa_lcdc-remove-redundant-spi_set_drvdata.patch
* lib-remove-unnecessary-work-pending-test.patch
* lib-vsprintfc-document-formats-for-dentry-and-struct-file.patch
* lib-add-crc64-ecma-module.patch
* checkpatch-report-missing-spaces-around-trigraphs-with-strict.patch
* checkpatch-extend-camelcase-types-and-ignore-existing-camelcase-uses-in-a-patch.patch
* checkpatch-update-seq_foo-tests.patch
* checkpatch-find-camelcase-definitions-of-struct-union-enum.patch
* checkpatch-add-test-for-defines-of-arch_has_foo.patch
* checkpatch-add-rules-to-check-init-attribute-and-const-defects.patch
* binfmt_elfc-use-get_random_int-to-fix-entropy-depleting.patch
* inith-document-the-existence-of-__initconst.patch
* drivers-message-i2o-driverc-add-missing-destroy_workqueue-on-error-in-i2o_driver_register.patch
* autofs4-allow-autofs-to-work-outside-the-initial-pid-namespace.patch
* autofs4-translate-pids-to-the-right-namespace-for-the-daemon.patch
* drivers-rtc-rtc-ds1307c-release-irq-on-error.patch
* drivers-rtc-rtc-isl1208c-remove-redundant-checks.patch
* drivers-rtc-rtc-max6900c-remove-redundant-checks.patch
* drivers-rtc-rtc-vt8500c-fix-return-value.patch
* drivers-rtc-rtc-at91rm9200c-use-devm_-apis.patch
* drivers-rtc-rtc-isl1208c-use-devm_-apis.patch
* drivers-rtc-rtc-sirfsocc-use-devm_rtc_device_register.patch
* drivers-rtc-rtc-cmosc-remove-redundant-dev_set_drvdata.patch
* drivers-rtc-rtc-mrstc-remove-redundant-dev_set_drvdata.patch
* drivers-rtc-rtc-vr41xxc-fix-checkpatch-warnings.patch
* drivers-rtc-rtc-sirfsocc-remove-unneeded-casts-of-void.patch
* drivers-rtc-rtc-88pm80xc-use-dev_get_platdata.patch
* drivers-rtc-rtc-88pm860xc-use-dev_get_platdata.patch
* drivers-rtc-rtc-cmosc-use-dev_get_platdata.patch
* drivers-rtc-rtc-da9055c-use-dev_get_platdata.patch
* drivers-rtc-rtc-ds1305c-use-dev_get_platdata.patch
* drivers-rtc-rtc-ds1307c-use-dev_get_platdata.patch
* drivers-rtc-rtc-ds2404c-use-dev_get_platdata.patch
* drivers-rtc-rtc-ep93xxc-use-dev_get_platdata.patch
* drivers-rtc-rtc-hid-sensor-timec-use-dev_get_platdata.patch
* drivers-rtc-rtc-m48t59c-use-dev_get_platdata.patch
* drivers-rtc-rtc-m48t86c-use-dev_get_platdata.patch
* drivers-rtc-rtc-pcf2123c-use-dev_get_platdata.patch
* drivers-rtc-rtc-rs5c348c-use-dev_get_platdata.patch
* drivers-rtc-rtc-shc-use-dev_get_platdata.patch
* drivers-rtc-rtc-v3020c-use-dev_get_platdata.patch
* drivers-rtc-rtc-hid-sensor-timec-enable-hid-input-processing-early.patch
* hfsplus-add-metadata-files-clump-size-calculation-functionality.patch
* hfsplus-implement-attributes-files-header-node-initialization-code.patch
* hfsplus-implement-attributes-file-creation-functionality.patch
* documentation-filesystems-vfattxt-fix-directory-entry-example.patch
* fat-additions-to-support-fat_fallocate.patch
* fat-additions-to-support-fat_fallocate-v6.patch
* fat-additions-to-support-fat_fallocate-v6-checkpatch-fixes.patch
* documentation-dma-attributestxt-fix-typo.patch
* documentation-trace-tracepointstxt-add-links-to-trace_event-documentation.patch
* drivers-char-xilinx_hwicap-xilinx_hwicapc-remove-unneeded-cast-of-void.patch
* kernel-sysctlc-check-return-value-after-call-proc_put_char-in-__do_proc_doulongvec_minmax.patch
* kernel-taskstatsc-add-nla_nest_cancel-for-failure-processing-between-nla_nest_start-and-nla_nest_end.patch
* gcov-move-gcov-structs-definitions-to-a-gcc-version-specific-file.patch
* gcov-add-support-for-gcc-47-gcov-format.patch
* gcov-add-support-for-gcc-47-gcov-format-fix.patch
* gcov-add-support-for-gcc-47-gcov-format-fix-fix.patch
* gcov-add-support-for-gcc-47-gcov-format-checkpatch-fixes.patch
* gcov-add-support-for-gcc-47-gcov-format-fix-3.patch
* gcov-compile-specific-gcov-implementation-based-on-gcc-version.patch
* kernel-add-support-for-init_array-constructors.patch
* kernel-add-support-for-init_array-constructors-fix.patch
* kernel-modulec-use-pr_foo.patch
* kernel-gcov-fsc-use-pr_warn.patch
* gcov-reuse-kbasename-helper.patch
* w1-w1-gpio-use-dev_get_platdata.patch
* w1-ds1wm-use-dev_get_platdata.patch
* kfifo-kfifo_copy_tofrom_user-fix-copied-bytes-calculation.patch
* ipc-remove-unnecessary-work-pending-test.patch
  linux-next.patch
  linux-next-rejects.patch
* x86-mm-factor-out-of-top-down-direct-mapping-setup-next-fix.patch
* mm-drop-actor-argument-of-do_generic_file_read.patch
* mm-drop-actor-argument-of-do_generic_file_read-fix.patch
  debugging-keep-track-of-page-owners.patch
  debugging-keep-track-of-page-owners-fix.patch
  debugging-keep-track-of-page-owners-fix-2.patch
  debugging-keep-track-of-page-owners-fix-2-fix.patch
  debugging-keep-track-of-page-owners-fix-2-fix-fix.patch
  debugging-keep-track-of-page-owners-fix-2-fix-fix-fix.patch
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
