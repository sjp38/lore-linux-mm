Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id EDC256B012B
	for <linux-mm@kvack.org>; Wed,  6 Nov 2013 19:16:02 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so423153pab.40
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 16:16:02 -0800 (PST)
Received: from psmtp.com ([74.125.245.205])
        by mx.google.com with SMTP id dj3si464828pbc.250.2013.11.06.16.15.59
        for <linux-mm@kvack.org>;
        Wed, 06 Nov 2013 16:16:00 -0800 (PST)
Received: by mail-qe0-f74.google.com with SMTP id 1so30601qec.1
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 16:15:58 -0800 (PST)
Subject: mmotm 2013-11-06-16-14 uploaded
From: akpm@linux-foundation.org
Date: Wed, 06 Nov 2013 16:15:57 -0800
Message-Id: <20131107001557.B1BDE5A426A@corp2gmr1-2.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

The mm-of-the-moment snapshot 2013-11-06-16-14 has been uploaded to

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


This mmotm tree contains the following patches against 3.12:
(patches marked "*" will be included in linux-next)

  origin.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  i-need-old-gcc.patch
* kthread-make-kthread_create-killable.patch
* sh64-kernel-use-usp-instead-of-fn.patch
* sh64-kernel-remove-useless-variable-regs.patch
* arch-x86-mnify-pte_to_pgoff-and-pgoff_to_pte-helpers.patch
* x86-srat-use-numa_no_node.patch
* x86-mm-get-aslr-work-for-hugetlb-mappings.patch
* kernel-auditc-remove-duplicated-comment.patch
* media-platform-drivers-fix-build-on-cris-arch.patch
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
* input-route-kbd-leds-through-the-generic-leds-layer.patch
* input-route-kbd-leds-through-the-generic-leds-layer-fix.patch
* input-route-kbd-leds-through-the-generic-leds-layer-fix-3.patch
* scripts-sortextable-support-objects-with-more-than-64k-sections.patch
* configfs-fix-race-between-dentry-put-and-lookup.patch
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
* ocfs2-fix-possible-double-free-in-ocfs2_write_begin_nolock.patch
* add-clustername-to-cluster-connection.patch
* add-dlm-recovery-callbacks.patch
* shift-allocation-ocfs2_live_connection-to-user_connect.patch
* pass-ocfs2_cluster_connection-to-ocfs2_this_node.patch
* framework-for-version-lvb.patch
* use-the-new-dlm-operation-callbacks-while-requesting-new-lockspace.patch
* ocfs2-should-call-ocfs2_journal_access_di-before-ocfs2_delete_entry-in-ocfs2_orphan_del.patch
* ocfs2-llseek-requires-ocfs2-inode-lock-for-the-file-in-seek_end.patch
* ocfs2-fix-issue-that-ocfs2_setattr-does-not-deal-with-new_i_size==i_size.patch
* ocfs2-update-inode-size-after-zeronig-the-hole.patch
* drivers-pci-pci-driverc-warn-on-driver-probe-return-value-greater-than-zero.patch
* mm-readaheadc-do_readhead-dont-check-for-readpage.patch
* scsi-do-not-call-do_div-with-a-64-bit-divisor.patch
* drivers-cdrom-gdromc-remove-deprecated-irqf_disabled.patch
* drivers-block-sx8c-use-module_pci_driver.patch
* drivers-block-sx8c-remove-unnecessary-pci_set_drvdata.patch
* drivers-block-paride-pgc-underflow-bug-in-pg_write.patch
* hpsa-return-0-from-driver-probe-function-on-success-not-1.patch
* drivers-block-ccissc-cciss_init_one-use-proper-errnos.patch
* block-remove-unrelated-header-files-and-export-symbol.patch
* mtd-cmdlinepart-use-cmdline-partition-parser-lib.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* anon_inodefs-forbid-open-via-proc.patch
* posix_acl-uninlining.patch
* watchdog-trigger-all-cpu-backtrace-when-locked-up-and-going-to-panic.patch
* xfs-underflow-bug-in-xfs_attrlist_by_handle.patch
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
* documentation-vm-zswaptxt-fix-typos.patch
* mm-thp-cleanup-mv-alloc_hugepage-to-better-place.patch
* mm-thp-khugepaged-add-policy-for-finding-target-node.patch
* mm-thp-khugepaged-add-policy-for-finding-target-node-fix.patch
* mm-mempolicy-use-numa_no_node.patch
* memcg-refactor-mem_control_numa_stat_show.patch
* memcg-support-hierarchical-memorynuma_stats.patch
* mm-sparsemem-use-pages_per_section-to-remove-redundant-nr_pages-parameter.patch
* mm-sparsemem-fix-a-bug-in-free_map_bootmem-when-config_sparsemem_vmemmap.patch
* mm-sparsemem-fix-a-bug-in-free_map_bootmem-when-config_sparsemem_vmemmap-v2.patch
* mm-kmemleak-avoid-false-negatives-on-vmalloced-objects.patch
* mm-swapfilec-fix-comment-typos.patch
* frontswap-enable-call-to-invalidate-area-on-swapoff.patch
* mm-page_allocc-remove-unused-marco-long_align.patch
* smaps-show-vm_softdirty-flag-in-vmflags-line.patch
* smaps-show-vm_softdirty-flag-in-vmflags-line-fix.patch
* page-typesc-support-kpf_softdirty-bit.patch
* writeback-do-not-sync-data-dirtied-after-sync-start.patch
* writeback-do-not-sync-data-dirtied-after-sync-start-fix.patch
* writeback-do-not-sync-data-dirtied-after-sync-start-fix-2.patch
* writeback-do-not-sync-data-dirtied-after-sync-start-fix-3.patch
* mm-zswap-avoid-unnecessary-page-scanning.patch
* mmap-arch_get_unmapped_area-use-proper-mmap-base-for-bottom-up-direction.patch
* s390-mmap-randomize-mmap-base-for-bottom-up-direction.patch
* swap-fix-setting-page_size-blocksize-during-swapoff-swapon-race.patch
* memblock-factor-out-of-top-down-allocation.patch
* memblock-introduce-bottom-up-allocation-mode.patch
* x86-mm-factor-out-of-top-down-direct-mapping-setup.patch
* x86-mem-hotplug-support-initialize-page-tables-in-bottom-up.patch
* x86-acpi-crash-kdump-do-reserve_crashkernel-after-srat-is-parsed.patch
* mem-hotplug-introduce-movable_node-boot-option.patch
* mm-set-n_cpu-to-node_states-during-boot.patch
* mm-clear-n_cpu-from-node_states-at-cpu-offline.patch
* mm-bootmemc-remove-unused-local-map.patch
* mm-do-not-walk-all-of-system-memory-during-show_mem.patch
* readahead-fix-sequential-read-cache-miss-detection.patch
* mm-fix-page_group_by_mobility_disabled-breakage.patch
* mm-get-rid-of-unnecessary-overhead-of-trace_mm_page_alloc_extfrag.patch
* mm-__rmqueue_fallback-should-respect-pageblock-type.patch
* mm-ensure-get_unmapped_area-returns-higher-address-than-mmap_min_addr.patch
* memcg-kmem-use-is_root_cache-instead-of-hard-code.patch
* memcg-kmem-rename-cache_from_memcg-to-cache_from_memcg_idx.patch
* memcg-kmem-use-cache_from_memcg_idx-instead-of-hard-code.patch
* mm-zswap-bugfix-memory-leak-when-invalidate-and-reclaim-occur-concurrentu200bly.patch
* mm-zswap-refoctor-the-get-put-routines.patch
* mm-fix-the-incorrect-function-name-in-alloc_low_pages.patch
* mm-fix-the-comment-in-zlc_setup.patch
* mm-improve-the-description-for-dirty_background_ratio-dirty_ratio-sysctl.patch
* mm-factor-commit-limit-calculation.patch
* mm-factor-commit-limit-calculation-fix.patch
* swap-add-a-simple-detector-for-inappropriate-swapin-readahead.patch
* swap-add-a-simple-detector-for-inappropriate-swapin-readahead-fix.patch
* hpet-allow-user-controlled-mmap-for-user-processes.patch
* percpu-add-test-module-for-various-percpu-operations.patch
* cramfs-mark-as-obsolete.patch
* syscallsh-use-gcc-alias-instead-of-assembler-aliases-for-syscalls.patch
* scripts-mod-modpostc-handle-non-abs-crc-symbols.patch
* init-do_mountsc-add-maj-min-syntax-comment.patch
* errnoh-remove-nfs-from-descriptions-in-comments.patch
* gen_init_cpio-avoid-null-pointer-dereference-and-rework-env-expanding.patch
* kernel-delayacctc-remove-redundant-checking-in-__delayacct_add_tsk.patch
* kernel-sysc-remove-obsolete-include-linux-kexech.patch
* jump_label-unlikelyx-0.patch
* sh-move-fpu_counter-into-arch-specific-thread_struct.patch
* x86-move-fpu_counter-into-arch-specific-thread_struct.patch
* sched-remove-arch-specific-fpu_counter-from-task_struct.patch
* lglock-map-to-spinlock-when-config_smp.patch
* init-mainc-remove-prototype-for-softirq_init.patch
* drivers-misc-ti-st-st_corec-fix-null-dereference-on-protocol-type-check.patch
* printk-report-console-names-during-cut-over.patch
* kernel-printk-printkc-convert-to-pr_foo.patch
* vsprintf-check-real-user-group-id-for-%pk.patch
* kernel-printk-printkc-enable-boot-delay-for-earlyprintk.patch
* kernel-printk-printkc-enable-boot-delay-for-earlyprintk-fix.patch
* printkc-comments-should-refer-to-proc-vmcore-instead-of-proc-vmcoreinfo.patch
* printk-cache-mark-printk_once-test-variable-__read_mostly.patch
* get_maintainerpl-incomplete-output.patch
* maintainers-remove-richard-purdie-as-backlight-maintainer.patch
* maintainers-remove-richard-purdie-as-backlight-maintainer-fix.patch
* update-zwane-mwaikambos-e-mail-address.patch
* backlight-lp855x_bl-support-new-lp8555-device.patch
* backlight-lm3630-apply-chip-revision.patch
* backlight-lm3630-signedness-bug-in-lm3630a_chip_init.patch
* backlight-lm3630-potential-null-deref-in-probe.patch
* backlight-lm3630-apply-chip-revision-fix.patch
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
* drivers-video-backlight-lm3630a_blc-add-missing-destroy_workqueue-on-error-in-lm3630a_intr_config.patch
* backlight-atmel-pwm-bl-fix-reported-brightness.patch
* backlight-atmel-pwm-bl-fix-gpio-polarity-in-remove.patch
* backlight-atmel-pwm-bl-fix-module-autoload.patch
* backlight-atmel-pwm-bl-clean-up-probe-error-handling.patch
* backlight-atmel-pwm-bl-clean-up-get_intensity.patch
* backlight-atmel-pwm-bl-remove-unused-include.patch
* backlight-atmel-pwm-bl-use-gpio_is_valid.patch
* backlight-atmel-pwm-bl-refactor-gpio_on-handling.patch
* backlight-atmel-pwm-bl-use-gpio_request_one.patch
* drivers-video-backlight-hx8357c-remove-redundant-of_match_ptr.patch
* bitops-find-clarify-and-extend-documentation.patch
* lib-remove-unnecessary-work-pending-test.patch
* lib-vsprintfc-document-formats-for-dentry-and-struct-file.patch
* lib-digsigc-use-err_cast-inlined-function-instead-of-err_ptrptr_err.patch
* lib-genalloc-add-a-helper-function-for-dma-buffer-allocation.patch
* arch-arm-mach-davinci-sramc-use-gen_pool_dma_alloc-to-sramc.patch
* drivers-dma-mmp_tdmac-use-gen_pool_dma_alloc-to-allocate-descriptor.patch
* drivers-media-platform-codac-use-gen_pool_dma_alloc-to-allocate-iram-buffer.patch
* drivers-uio-uio_prussc-use-gen_pool_dma_alloc-to-allocate-sram-memory.patch
* sound-soc-davinci-davinci-pcmc-use-gen_pool_dma_alloc-in-davinci-pcmc.patch
* sound-soc-pxa-mmp-pcmc-use-gen_pool_dma_alloc-to-allocate-dma-buffer.patch
* lib-add-crc64-ecma-module.patch
* checkpatch-report-missing-spaces-around-trigraphs-with-strict.patch
* checkpatch-extend-camelcase-types-and-ignore-existing-camelcase-uses-in-a-patch.patch
* checkpatch-update-seq_foo-tests.patch
* checkpatch-find-camelcase-definitions-of-struct-union-enum.patch
* checkpatch-add-test-for-defines-of-arch_has_foo.patch
* checkpatch-add-rules-to-check-init-attribute-and-const-defects.patch
* checkpatch-make-the-memory-barrier-test-noisier.patch
* checkpatchpl-check-for-the-fsf-mailing-address.patch
* checkpatch-improve-return-is-not-a-function-test.patch
* checkpatch-add-check-for-sscanf-without-return-use.patch
* checkpatch-add-check-for-sscanf-without-return-use-v2.patch
* epoll-optimize-epoll_ctl_del-using-rcu.patch
* epoll-optimize-epoll_ctl_del-using-rcu-fix.patch
* epoll-do-not-take-global-epmutex-for-simple-topologies.patch
* epoll-do-not-take-global-epmutex-for-simple-topologies-fix.patch
* binfmt_elfc-use-get_random_int-to-fix-entropy-depleting.patch
* inith-document-the-existence-of-__initconst.patch
* init-do_mounts_rdc-fix-null-pointer-dereference-while-loading-initramfs.patch
* init-do_mounts_rdc-fix-null-pointer-dereference-while-loading-initramfs-fix.patch
* init-make-init-failures-more-explicit.patch
* initramfs-read-config_rd_-variables-for-initramfs-compression.patch
* initramfs-read-config_rd_-variables-for-initramfs-compression-fix.patch
* initramfs-read-config_rd_-variables-for-initramfs-compression-fix-2.patch
* kprobes-use-ksym_name_len-to-size-identifier-buffers.patch
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
* drivers-rtc-rtc-m48t59c-use-dev_get_platdata.patch
* drivers-rtc-rtc-m48t86c-use-dev_get_platdata.patch
* drivers-rtc-rtc-pcf2123c-use-dev_get_platdata.patch
* drivers-rtc-rtc-rs5c348c-use-dev_get_platdata.patch
* drivers-rtc-rtc-shc-use-dev_get_platdata.patch
* drivers-rtc-rtc-v3020c-use-dev_get_platdata.patch
* drivers-rtc-rtc-vt8500c-remove-redundant-of_match_ptr.patch
* drivers-rtc-rtc-omapc-remove-redundant-of_match_ptr.patch
* drivers-rtc-rtc-sirfsocc-remove-redundant-of_match_ptr.patch
* drivers-rtc-rtc-snvsc-remove-redundant-of_match_ptr.patch
* drivers-rtc-rtc-stmp3xxxc-remove-redundant-of_match_ptr.patch
* drivers-rtc-rtc-ds1307c-change-variable-type-to-bool.patch
* drivers-rtc-rtc-pl03xc-remove-unnecessary-amba_set_drvdata.patch
* drivers-rtc-rtc-puv3c-use-dev_dbg-instead-of-pr_debug.patch
* drivers-rtc-rtc-pl030c-use-devm_kzalloc-instead-of-kmalloc.patch
* drivers-rtc-rtc-tps65910c-remove-unnecessary-include.patch
* rtc-s5m-rtc-add-real-time-clock-driver-for-s5m8767.patch
* drivers-rtc-rtc-as3722-add-rtc-driver.patch
* drivers-rtc-rtc-as3722-add-rtc-driver-checkpatch-fixes.patch
* fs-hfs-btreeh-remove-duplicate-defines.patch
* fs-hfs-btreeh-remove-duplicate-defines-fix.patch
* hfsplus-add-metadata-files-clump-size-calculation-functionality.patch
* hfsplus-implement-attributes-files-header-node-initialization-code.patch
* hfsplus-implement-attributes-files-header-node-initialization-code-v2.patch
* hfsplus-implement-attributes-file-creation-functionality.patch
* hfsplus-implement-attributes-file-creation-functionality-v2.patch
* documentation-filesystems-vfattxt-fix-directory-entry-example.patch
* fat-add-i_disksize-to-represent-uninitialized-size.patch
* fat-add-fat_fallocate-operation.patch
* fat-zero-out-seek-range-on-_fat_get_block.patch
* fat-fallback-to-buffered-write-in-case-of-fallocatded-region-on-direct-io.patch
* fat-permit-to-return-phy-block-number-by-fibmap-in-fallocated-region.patch
* documentation-trace-tracepointstxt-add-links-to-trace_event-documentation.patch
* kernel-doc-improve-no-structured-comments-found-error.patch
* documentation-abi-document-the-non-abi-status-of-kconfig-and-symbols.patch
* procfs-clean-up-proc_reg_get_unmapped_area-for-80-column-limit.patch
* exec-ptrace-fix-get_dumpable-incorrect-tests.patch
* kernel-kexecc-use-vscnprintf-instead-of-vsnprintf-in-vmcoreinfo_append_str.patch
* kernel-sysctlc-check-return-value-after-call-proc_put_char-in-__do_proc_doulongvec_minmax.patch
* kernel-sysctl_binaryc-use-scnprintf-instead-of-snprintf.patch
* kernel-taskstatsc-add-nla_nest_cancel-for-failure-processing-between-nla_nest_start-and-nla_nest_end.patch
* kernel-taskstatsc-return-enomem-when-alloc-memory-fails-in-add_del_listener.patch
* gcov-move-gcov-structs-definitions-to-a-gcc-version-specific-file.patch
* gcov-add-support-for-gcc-47-gcov-format.patch
* gcov-add-support-for-gcc-47-gcov-format-fix.patch
* gcov-add-support-for-gcc-47-gcov-format-fix-fix.patch
* gcov-add-support-for-gcc-47-gcov-format-checkpatch-fixes.patch
* gcov-add-support-for-gcc-47-gcov-format-fix-3.patch
* gcov-compile-specific-gcov-implementation-based-on-gcc-version.patch
* kernel-modulec-use-pr_foo.patch
* kernel-gcov-fsc-use-pr_warn.patch
* gcov-reuse-kbasename-helper.patch
* kernel-panicc-reduce-1-byte-usage-for-print-tainted-buffer.patch
* pktcdvd-debugfs-functions-return-null-on-error.patch
* drivers-pps-clients-pps-gpioc-remove-redundant-of_match_ptr.patch
* pps-add-non-blocking-option-to-pps_fetch-ioctl.patch
* drivers-memstick-core-mspro_blockc-fix-attributes-array-allocation.patch
* drivers-memstick-core-ms_blockc-fix-unreachable-state-in-h_msb_read_page.patch
* w1-ds1wm-use-dev_get_platdata.patch
* drivers-w1-make-w1_slave-flags-long-to-avoid-casts.patch
* init-kconfig-add-option-to-disable-kernel-compression.patch
* makefile-export-initial-ramdisk-compression-config-option.patch
* devpts-plug-the-memory-leak-in-kill_sb.patch
* ipc-remove-unnecessary-work-pending-test.patch
* ipc-msg-fix-message-length-check-for-negative-values.patch
* ipc-msg-fix-message-length-check-for-negative-values-fix.patch
* scripts-bloat-o-meter-ignore-changes-in-the-size-of-linux_banner.patch
* scripts-bloat-o-meter-use-startswith-rather-than-fragile-slicing.patch
  linux-next.patch
* x86-mem-hotplug-support-initialize-page-tables-in-bottom-up-next-fix.patch
* mm-drop-actor-argument-of-do_generic_file_read.patch
* mm-drop-actor-argument-of-do_generic_file_read-fix.patch
* mm-avoid-increase-sizeofstruct-page-due-to-split-page-table-lock.patch
* mm-rename-use_split_ptlocks-to-use_split_pte_ptlocks.patch
* mm-convert-mm-nr_ptes-to-atomic_long_t.patch
* mm-introduce-api-for-split-page-table-lock-for-pmd-level.patch
* mm-thp-change-pmd_trans_huge_lock-to-return-taken-lock.patch
* mm-thp-move-ptl-taking-inside-page_check_address_pmd.patch
* mm-thp-do-not-access-mm-pmd_huge_pte-directly.patch
* mm-hugetlb-convert-hugetlbfs-to-use-split-pmd-lock.patch
* mm-hugetlb-convert-hugetlbfs-to-use-split-pmd-lock-checkpatch-fixes.patch
* mm-convert-the-rest-to-new-page-table-lock-api.patch
* mm-implement-split-page-table-lock-for-pmd-level.patch
* x86-mm-enable-split-page-table-lock-for-pmd-level.patch
* x86-mm-enable-split-page-table-lock-for-pmd-level-checkpatch-fixes.patch
* x86-add-missed-pgtable_pmd_page_ctor-dtor-calls-for-preallocated-pmds.patch
* cris-fix-potential-null-pointer-dereference.patch
* m32r-fix-potential-null-pointer-dereference.patch
* xtensa-fix-potential-null-pointer-dereference.patch
* mm-allow-pgtable_page_ctor-to-fail.patch
* microblaze-add-missing-pgtable_page_ctor-dtor-calls.patch
* mn10300-add-missing-pgtable_page_ctor-dtor-calls.patch
* openrisc-add-missing-pgtable_page_ctor-dtor-calls.patch
* alpha-handle-pgtable_page_ctor-fail.patch
* arc-handle-pgtable_page_ctor-fail.patch
* arm-handle-pgtable_page_ctor-fail.patch
* arm64-handle-pgtable_page_ctor-fail.patch
* avr32-handle-pgtable_page_ctor-fail.patch
* cris-handle-pgtable_page_ctor-fail.patch
* frv-handle-pgtable_page_ctor-fail.patch
* hexagon-handle-pgtable_page_ctor-fail.patch
* ia64-handle-pgtable_page_ctor-fail.patch
* m32r-handle-pgtable_page_ctor-fail.patch
* m68k-handle-pgtable_page_ctor-fail.patch
* m68k-handle-pgtable_page_ctor-fail-fix.patch
* m68k-handle-pgtable_page_ctor-fail-fix-fix.patch
* metag-handle-pgtable_page_ctor-fail.patch
* mips-handle-pgtable_page_ctor-fail.patch
* parisc-handle-pgtable_page_ctor-fail.patch
* powerpc-handle-pgtable_page_ctor-fail.patch
* s390-handle-pgtable_page_ctor-fail.patch
* score-handle-pgtable_page_ctor-fail.patch
* sh-handle-pgtable_page_ctor-fail.patch
* sparc-handle-pgtable_page_ctor-fail.patch
* tile-handle-pgtable_page_ctor-fail.patch
* um-handle-pgtable_page_ctor-fail.patch
* unicore32-handle-pgtable_page_ctor-fail.patch
* x86-handle-pgtable_page_ctor-fail.patch
* xtensa-handle-pgtable_page_ctor-fail.patch
* iommu-arm-smmu-handle-pgtable_page_ctor-fail.patch
* xtensa-use-buddy-allocator-for-pte-table.patch
* mm-dynamically-allocate-page-ptl-if-it-cannot-be-embedded-to-struct-page.patch
* seq_file-introduce-seq_setwidth-and-seq_pad.patch
* seq_file-remove-%n-usage-from-seq_file-users.patch
* vsprintf-ignore-%n-again.patch
* drivers-rtc-rtc-hid-sensor-timec-use-dev_get_platdata.patch
* drivers-rtc-rtc-hid-sensor-timec-enable-hid-input-processing-early.patch
* sched-replace-init_completion-with-reinit_completion.patch
* tree-wide-use-reinit_completion-instead-of-init_completion.patch
* tree-wide-use-reinit_completion-instead-of-init_completion-fix.patch
* sched-remove-init_completion.patch
* w1-w1-gpio-use-dev_get_platdata.patch
* scripts-tagssh-remove-obsolete-__devinit.patch
* revert-softirq-add-support-for-triggering-softirq-work-on-softirqs.patch
* kernel-remove-config_use_generic_smp_helpers.patch
* kernel-provide-a-__smp_call_function_single-stub-for-config_smp.patch
* kernel-provide-a-__smp_call_function_single-stub-for-config_smp-fix.patch
* kernel-fix-generic_exec_single-indication.patch
* llists-move-llist_reverse_order-from-raid5-to-llistc.patch
* llists-move-llist_reverse_order-from-raid5-to-llistc-fix.patch
* kernel-use-lockless-list-for-smp_call_function_single.patch
* blk-mq-use-__smp_call_function_single-directly.patch
* sound-core-memallocc-use-gen_pool_dma_alloc-to-allocate-iram-buffer.patch
* kfifo-kfifo_copy_tofrom_user-fix-copied-bytes-calculation.patch
* kfifo-api-type-safety.patch
* kfifo-api-type-safety-checkpatch-fixes.patch
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
