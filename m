Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 7B7C46B00E7
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 23:10:52 -0500 (EST)
Date: Mon, 10 Jan 2011 23:10:50 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <704975885.41077.1294719050536.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <411170284.39793.1294707696900.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Subject: Re: bnx2 card cannot be detected (WAS Re: mmotm 2011-01-06-15-41
 uploaded)
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next <linux-next@vger.kernel.org>
List-ID: <linux-mm.kvack.org>



----- Original Message -----
> After updated to this kernel, my system with bnx2 card (Ethernet
> controller: Broadcom Corporation NetXtreme II BCM5709S Gigabit
> Ethernet (rev 20) can't be detected. The system has no any of eth*.
> mmotm 2010-12-02-16-34 version is working fine there. Is this a known
> issue?
This was introduced again by this big patch,
linux-next.patch

GIT 47ec85165ad275a2ca62c4aca4bf029e9ffd6af0 git+ssh://master.kernel.org/pub/scmm
/linux/kernel/git/sfr/linux-next.git

CAI Qian

> ----- Original Message -----
> > The mm-of-the-moment snapshot 2011-01-06-15-41 has been uploaded to
> >
> > http://userweb.kernel.org/~akpm/mmotm/
> >
> > and will soon be available at
> >
> > git://zen-kernel.org/kernel/mmotm.git
> >
> > It contains the following patches against 2.6.37:
> >
> > linux-next.patch
> > next-remove-localversion.patch
> > i-need-old-gcc.patch
> > arch-alpha-kernel-systblss-remove-debug-check.patch
> > arch-alpha-include-asm-ioh-s-extern-inline-static-inline.patch
> > memblock-fix-memblock_is_region_memory.patch
> > mm-vmap-area-cache.patch
> > mm-vmap-area-cache-fix.patch
> > backlight-fix-88pm860x_bl-macro-collision.patch
> > cciss-fix-botched-tag-masking-for-scsi-tape-commands.patch
> > acerhdf-add-support-for-aspire-1410-bios-v13314.patch
> > arm-translate-delays-into-mostly-c.patch
> > arm-allow-machines-to-override-__delay.patch
> > arm-implement-a-timer-based-__delay-loop.patch
> > msm-timer-migrate-to-timer-based-__delay.patch
> > audit-always-follow-va_copy-with-va_end.patch
> > fs-btrfs-inodec-eliminate-memory-leak.patch
> > btrfs-dont-dereference-extent_mapping-if-null.patch
> > cpufreq-fix-ondemand-governor-powersave_bias-execution-time-misuse.patch
> > macintosh-wrong-test-in-fan_readwrite_reg.patch
> > spufs-use-simple_write_to_buffer.patch
> > debugfs-remove-module_exit.patch
> > drivers-gpu-drm-radeon-atomc-fix-warning.patch
> > drivers-video-i810-i810-i2cc-fix-i2c-bus-handling.patch
> > maintainers-update-entries-affecting-via-technologies.patch
> > cyber2000fb-avoid-palette-corruption-at-higher-clocks.patch
> > irq-use-per_cpu-kstat_irqs.patch
> > drivers-leds-leds-lp5521c-fix-potential-buffer-overflow.patch
> > leds-leds-pca9532-cleanups.patch
> > leds-leds-lp5523-modify-the-way-of-setting-led-device-name.patch
> > leds-lp5523-fix-circular-locking.patch
> > leds-lp5521-fix-circular-locking.patch
> > leds-lp5521-modify-the-way-of-setting-led-device-name.patch
> > leds-add-output-inversion-option-to-backlight-trigger.patch
> > leds-add-output-inversion-option-to-backlight-trigger-fix.patch
> > leds-h1940-use-gpiolib-for-latch-access-fix-build-failure.patch
> > leds-route-kbd-leds-through-the-generic-leds-layer.patch
> > mips-enable-arch_dma_addr_t_64bit-with-highmem-64bit_phys_addr-64bit.patch
> > drivers-video-backlight-l4f00242t03c-make-1-bit-signed-field-unsigned.patch
> > drivers-video-backlight-l4f00242t03c-full-implement-fb-power-states-for-this-lcd.patch
> > drivers-video-backlight-l4f00242t03c-prevent-unbalanced-calls-to-regulator-enable-disable.patch
> > mbp_nvidia_bl-remove-dmi-dependency.patch
> > mbp_nvidia_bl-check-that-the-backlight-control-functions.patch
> > mbp_nvidia_bl-rename-to-apple_bl.patch
> > drivers-video-backlight-l4f00242t03c-fix-reset-sequence.patch
> > btusb-patch-add_apple_macbookpro62.patch
> > ext4-dont-use-pr_warning_ratelimited.patch
> > fs-ext4-superc-ext4_register_li_request-fix-use-uninitialised.patch
> > atmel_serial-fix-rts-high-after-initialization-in-rs485-mode.patch
> > atmel_serial-fix-rts-high-after-initialization-in-rs485-mode-fix.patch
> > sched-remove-long-deprecated-clone_stopped-flag.patch
> > drivers-message-fusion-mptsasc-fix-warning.patch
> > scsi-fix-a-header-to-include-linux-typesh.patch
> > drivers-block-makefile-replace-the-use-of-module-objs-with-module-y.patch
> > drivers-block-aoe-makefile-replace-the-use-of-module-objs-with-module-y.patch
> > cciss-make-cciss_revalidate-not-loop-through-ciss_max_luns-volumes-unnecessarily.patch
> > vfs-remove-a-warning-on-open_fmode.patch
> > vfs-add-__fmode_exec.patch
> > fs-make-block-fiemap-mapping-length-at-least-blocksize-long.patch
> > n_hdlc-fix-read-and-write-locking.patch
> > n_hdlc-fix-read-and-write-locking-update.patch
> > mm.patch
> > mm-page-allocator-adjust-the-per-cpu-counter-threshold-when-memory-is-low.patch
> > mm-vmstat-use-a-single-setter-function-and-callback-for-adjusting-percpu-thresholds.patch
> > mm-vmstat-use-a-single-setter-function-and-callback-for-adjusting-percpu-thresholds-fix.patch
> > mm-vmstat-use-a-single-setter-function-and-callback-for-adjusting-percpu-thresholds-update.patch
> > mm-vmstat-use-a-single-setter-function-and-callback-for-adjusting-percpu-thresholds-fix-set_pgdat_percpu_threshold-dont-use-for_each_online_cpu.patch
> > writeback-integrated-background-writeback-work.patch
> > writeback-trace-wakeup-event-for-background-writeback.patch
> > writeback-stop-background-kupdate-works-from-livelocking-other-works.patch
> > writeback-stop-background-kupdate-works-from-livelocking-other-works-update.patch
> > writeback-avoid-livelocking-wb_sync_all-writeback.patch
> > writeback-avoid-livelocking-wb_sync_all-writeback-update.patch
> > writeback-check-skipped-pages-on-wb_sync_all.patch
> > writeback-check-skipped-pages-on-wb_sync_all-update.patch
> > writeback-check-skipped-pages-on-wb_sync_all-update-fix.patch
> > writeback-io-less-balance_dirty_pages.patch
> > writeback-consolidate-variable-names-in-balance_dirty_pages.patch
> > writeback-per-task-rate-limit-on-balance_dirty_pages.patch
> > writeback-per-task-rate-limit-on-balance_dirty_pages-fix.patch
> > writeback-prevent-duplicate-balance_dirty_pages_ratelimited-calls.patch
> > writeback-account-per-bdi-accumulated-written-pages.patch
> > writeback-bdi-write-bandwidth-estimation.patch
> > writeback-bdi-write-bandwidth-estimation-fix.patch
> > writeback-show-bdi-write-bandwidth-in-debugfs.patch
> > writeback-quit-throttling-when-bdi-dirty-pages-dropped-low.patch
> > writeback-reduce-per-bdi-dirty-threshold-ramp-up-time.patch
> > writeback-make-reasonable-gap-between-the-dirty-background-thresholds.patch
> > writeback-scale-down-max-throttle-bandwidth-on-concurrent-dirtiers.patch
> > writeback-add-trace-event-for-balance_dirty_pages.patch
> > writeback-make-nr_to_write-a-per-file-limit.patch
> > writeback-make-nr_to_write-a-per-file-limit-fix.patch
> > sync_inode_metadata-fix-comment.patch
> > mm-page-writebackc-fix-__set_page_dirty_no_writeback-return-value.patch
> > vmscan-factor-out-kswapd-sleeping-logic-from-kswapd.patch
> > mm-find_get_pages_contig-fixlet.patch
> > fs-mpagec-consolidate-code.patch
> > fs-mpagec-consolidate-code-checkpatch-fixes.patch
> > mm-convert-sprintf_symbol-to-%ps.patch
> > mm-smaps-export-mlock-information.patch
> > mm-compaction-add-trace-events-for-memory-compaction-activity.patch
> > mm-vmscan-convert-lumpy_mode-into-a-bitmask.patch
> > mm-vmscan-reclaim-order-0-and-use-compaction-instead-of-lumpy-reclaim.patch
> > mm-vmscan-reclaim-order-0-and-use-compaction-instead-of-lumpy-reclaim-fix.patch
> > mm-migration-allow-migration-to-operate-asynchronously-and-avoid-synchronous-compaction-in-the-faster-path.patch
> > mm-migration-allow-migration-to-operate-asynchronously-and-avoid-synchronous-compaction-in-the-faster-path-fix.patch
> > mm-migration-cleanup-migrate_pages-api-by-matching-types-for-offlining-and-sync.patch
> > mm-compaction-perform-a-faster-migration-scan-when-migrating-asynchronously.patch
> > mm-vmscan-rename-lumpy_mode-to-reclaim_mode.patch
> > mm-vmscan-rename-lumpy_mode-to-reclaim_mode-fix.patch
> > mm-deactivate-invalidated-pages.patch
> > mm-deactivate-invalidated-pages-fix.patch
> > mm-remove-unused-get_vm_area_node.patch
> > mm-remove-gfp-mask-from-pcpu_get_vm_areas.patch
> > mm-unify-module_alloc-code-for-vmalloc.patch
> > oom-allow-a-non-cap_sys_resource-proces-to-oom_score_adj-down.patch
> > mm-clear-pageerror-bit-in-msync-fsync.patch
> > do_wp_page-remove-the-reuse-flag.patch
> > do_wp_page-clarify-dirty_page-handling.patch
> > mlock-avoid-dirtying-pages-and-triggering-writeback.patch
> > mlock-only-hold-mmap_sem-in-shared-mode-when-faulting-in-pages.patch
> > mlock-only-hold-mmap_sem-in-shared-mode-when-faulting-in-pages-fix.patch
> > mm-add-foll_mlock-follow_page-flag.patch
> > mm-move-vm_locked-check-to-__mlock_vma_pages_range.patch
> > mlock-do-not-hold-mmap_sem-for-extended-periods-of-time.patch
> > mlock-do-not-hold-mmap_sem-for-extended-periods-of-time-fix.patch
> > mlock-do-not-hold-mmap_sem-for-extended-periods-of-time-fix2.patch
> > mempolicy-remove-tasklist_lock-from-migrate_pages.patch
> > vmalloc-remove-redundant-unlikely.patch
> > mm-remove-likely-from-mapping_unevictable.patch
> > mm-remove-unlikely-from-page_mapping.patch
> > mm-remove-likely-from-grab_cache_page_write_begin.patch
> > mm-kswapd-stop-high-order-balancing-when-any-suitable-zone-is-balanced.patch
> > mm-kswapd-keep-kswapd-awake-for-high-order-allocations-until-a-percentage-of-the-node-is-balanced.patch
> > mm-kswapd-use-the-order-that-kswapd-was-reclaiming-at-for-sleeping_prematurely.patch
> > mm-kswapd-reset-kswapd_max_order-and-classzone_idx-after-reading.patch
> > mm-kswapd-treat-zone-all_unreclaimable-in-sleeping_prematurely-similar-to-balance_pgdat.patch
> > mm-kswapd-use-the-classzone-idx-that-kswapd-was-using-for-sleeping_prematurely.patch
> > mm-set-correct-numa_zonelist_order-string-when-configured-on-the-kernel-command-line.patch
> > writeback-avoid-unnecessary-determine_dirtyable_memory-call.patch
> > writeback-avoid-unnecessary-determine_dirtyable_memory-call-fix.patch
> > thp-ksm-free-swap-when-swapcache-page-is-replaced.patch
> > thp-fix-bad_page-to-show-the-real-reason-the-page-is-bad.patch
> > thp-transparent-hugepage-support-documentation.patch
> > thp-mm-define-madv_hugepage.patch
> > thp-compound_lock.patch
> > thp-alter-compound-get_page-put_page.patch
> > thp-put_page-recheck-pagehead-after-releasing-the-compound_lock.patch
> > thp-update-futex-compound-knowledge.patch
> > thp-clear-compound-mapping.patch
> > thp-add-native_set_pmd_at.patch
> > thp-add-pmd-paravirt-ops.patch
> > thp-no-paravirt-version-of-pmd-ops.patch
> > thp-export-maybe_mkwrite.patch
> > thp-comment-reminder-in-destroy_compound_page.patch
> > thp-config_transparent_hugepage.patch
> > thp-config_transparent_hugepage-fix.patch
> > thp-special-pmd_trans_-functions.patch
> > thp-add-pmd-mangling-generic-functions.patch
> > thp-add-pmd-mangling-generic-functions-fix-pgtableh-build-for-um.patch
> > thp-add-pmd-mangling-functions-to-x86.patch
> > thp-bail-out-gup_fast-on-splitting-pmd.patch
> > thp-pte-alloc-trans-splitting.patch
> > thp-pte-alloc-trans-splitting-fix.patch
> > thp-pte-alloc-trans-splitting-fix-checkpatch-fixes.patch
> > thp-add-pmd-mmu_notifier-helpers.patch
> > thp-clear-page-compound.patch
> > thp-add-pmd_huge_pte-to-mm_struct.patch
> > thp-split_huge_page_mm-vma.patch
> > thp-split_huge_page-paging.patch
> > thp-clear_copy_huge_page.patch
> > thp-kvm-mmu-transparent-hugepage-support.patch
> > thp-_gfp_no_kswapd.patch
> > thp-dont-alloc-harder-for-gfp-nomemalloc-even-if-nowait.patch
> > thp-transparent-hugepage-core.patch
> > thp-split_huge_page-anon_vma-ordering-dependency.patch
> > thp-verify-pmd_trans_huge-isnt-leaking.patch
> > thp-madvisemadv_hugepage.patch
> > thp-add-pagetranscompound.patch
> > thp-pmd_trans_huge-migrate-bugcheck.patch
> > thp-memcg-compound.patch
> > thp-transhuge-memcg-commit-tail-pages-at-charge.patch
> > thp-memcg-huge-memory.patch
> > thp-transparent-hugepage-vmstat.patch
> > thp-khugepaged.patch
> > thp-khugepaged-vma-merge.patch
> > thp-skip-transhuge-pages-in-ksm-for-now.patch
> > thp-remove-pg_buddy.patch
> > thp-add-x86-32bit-support.patch
> > thp-mincore-transparent-hugepage-support.patch
> > thp-add-pmd_modify.patch
> > thp-mprotect-pass-vma-down-to-page-table-walkers.patch
> > thp-mprotect-transparent-huge-page-support.patch
> > thp-set-recommended-min-free-kbytes.patch
> > thp-enable-direct-defrag.patch
> > thp-add-numa-awareness-to-hugepage-allocations.patch
> > thp-allocate-memory-in-khugepaged-outside-of-mmap_sem-write-mode.patch
> > thp-allocate-memory-in-khugepaged-outside-of-mmap_sem-write-mode-fix.patch
> > thp-transparent-hugepage-config-choice.patch
> > thp-select-config_compaction-if-transparent_hugepage-enabled.patch
> > thp-transhuge-isolate_migratepages.patch
> > thp-avoid-breaking-huge-pmd-invariants-in-case-of-vma_adjust-failures.patch
> > thp-dont-allow-transparent-hugepage-support-without-pse.patch
> > thp-mmu_notifier_test_young.patch
> > thp-freeze-khugepaged-and-ksmd.patch
> > thp-use-compaction-in-kswapd-for-gfp_atomic-order-0.patch
> > thp-use-compaction-for-all-allocation-orders.patch
> > thp-disable-transparent-hugepages-by-default-on-small-systems.patch
> > thp-fix-anon-memory-statistics-with-transparent-hugepages.patch
> > thp-scale-nr_rotated-to-balance-memory-pressure.patch
> > thp-transparent-hugepage-sysfs-meminfo.patch
> > thp-add-debug-checks-for-mapcount-related-invariants.patch
> > thp-fix-memory-failure-hugetlbfs-vs-thp-collision.patch
> > thp-compound_trans_order.patch
> > thp-compound_trans_order-fix.patch
> > thp-mm-define-madv_nohugepage.patch
> > thp-madvisemadv_nohugepage.patch
> > thp-khugepaged-make-khugepaged-aware-of-madvise.patch
> > thp-khugepaged-make-khugepaged-aware-of-madvise-fix.patch
> > mm-migration-use-rcu_dereference_protected-when-dereferencing-the-radix-tree-slot-during-file-page-migration.patch
> > mm-migration-use-rcu_dereference_protected-when-dereferencing-the-radix-tree-slot-during-file-page-migration-fix.patch
> > mm-hugetlbc-fix-error-path-memory-leak-in-nr_hugepages_store_common.patch
> > mm-hugetlbc-fix-error-path-memory-leak-in-nr_hugepages_store_common-fix.patch
> > brk-fix-min_brk-lower-bound-computation-for-compat_brk.patch
> > brk-fix-min_brk-lower-bound-computation-for-compat_brk-fix.patch
> > mm-page_allocc-simplify-calculation-of-combined-index-of-adjacent-buddy-lists.patch
> > mm-page_allocc-simplify-calculation-of-combined-index-of-adjacent-buddy-lists-checkpatch-fixes.patch
> > mm-page_allocc-simplify-calculation-of-combined-index-of-adjacent-buddy-lists-fix.patch
> > mm-dmapoolc-take-lock-only-once-in-dma_pool_free.patch
> > mm-dmapoolc-use-task_uninterruptible-in-dma_pool_alloc.patch
> > fs-fs-writebackc-fix-sync_inodes_sb-return-value-kernel-doc.patch
> > hugetlb-check-the-return-value-of-string-conversion-in-sysctl-handler.patch
> > hugetlb-check-the-return-value-of-string-conversion-in-sysctl-handler-fix.patch
> > hugetlb-do-not-allow-pagesize-=-max_order-pool-adjustment.patch
> > hugetlb-do-not-allow-pagesize-=-max_order-pool-adjustment-fix.patch
> > hugetlb-do-not-allow-pagesize-=-max_order-pool-adjustment-fix-fix.patch
> > hugetlb-fix-handling-of-parse-errors-in-sysfs.patch
> > hugetlb-handle-nodemask_alloc-failure-correctly.patch
> > frv-duplicate-output_buffer-of-e03.patch
> > frv-duplicate-output_buffer-of-e03-checkpatch-fixes.patch
> > hpet-factor-timer-allocate-from-open.patch
> > um-mark-config_highmem-as-broken.patch
> > arch-um-drivers-linec-safely-iterate-over-list-of-winch-handlers.patch
> > uml-mmapper_kern-needs-module_license.patch
> > uml-use-simple_write_to_buffer.patch
> > kmsg_dump-constrain-mtdoops-and-ramoops-to-perform-their-actions-only-for-kmsg_dump_panic.patch
> > kmsg_dump-add-kmsg_dump-calls-to-the-reboot-halt-poweroff-and-emergency_restart-paths.patch
> > set_rtc_mmss-show-warning-message-only-once.patch
> > include-linux-kernelh-abs-fix-handling-of-32-bit-unsigneds-on-64-bit.patch
> > include-linux-kernelh-abs-fix-handling-of-32-bit-unsigneds-on-64-bit-fix.patch
> > add-the-common-dma_addr_t-typedef-to-include-linux-typesh.patch
> > toshibah-hide-a-function-prototypes-behind-__kernel__-macro.patch
> > include-linux-unaligned-packed_structh-use-__packed.patch
> > include-asm-generic-vmlinuxldsh-make-readmostly-section-correctly-align.patch
> > ihex-fix-unused-return-value-compiler-warning.patch
> > ihex-fix-unused-return-value-compiler-warning-fix.patch
> > st-spear-pcie-gadget-suppport.patch
> > kernel-clean-up-use_generic_smp_helpers.patch
> > mm-numa-aware-alloc_task_struct_node.patch
> > mm-numa-aware-alloc_thread_info_node.patch
> > kthread-numa-aware-kthread_create_on_cpu.patch
> > kthread-use-kthread_create_on_cpu.patch
> > kptr_restrict-for-hiding-kernel-pointers-from-unprivileged-users.patch
> > kptr_restrict-for-hiding-kernel-pointers-from-unprivileged-users-fix.patch
> > kptr_restrict-for-hiding-kernel-pointers-v4.patch
> > kptr_restrict-for-hiding-kernel-pointers-v6.patch
> > kptr_restrict-for-hiding-kernel-pointers-v7.patch
> > kptr_restrict-for-hiding-kernel-pointers-v7-fix.patch
> > kptr_restrict-fix-build-when-printk-not-enabled.patch
> > net-convert-%p-usage-to-%pk.patch
> > dca-remove-unneeded-null-check.patch
> > printk-use-rcu-to-prevent-potential-lock-contention-in-kmsg_dump.patch
> > include-linux-printkh-move-console-functions-and-variables-together.patch
> > include-linux-printkh-use-space-after-define.patch
> > include-linux-printkh-use-and-neaten-no_printk.patch
> > include-linux-printkh-add-pr_level_once-macros.patch
> > include-linux-printkh-lib-hexdumpc-neatening-and-add-config_printk-guard.patch
> > include-linux-printkh-organize-printk_ratelimited-macros.patch
> > include-linux-printkh-use-tab-not-spaces-for-indent.patch
> > lib-fix-vscnprintf-if-size-is-==-0.patch
> > vfs-remove-unlikely-from-fput_light.patch
> > vfs-remove-unlikely-from-fget_light.patch
> > fs-fs_posix_acl-does-not-depend-on-block.patch
> > scripts-get_maintainerpl-make-rolestats-the-default.patch
> > scripts-get_maintainerpl-use-git-fallback-more-often.patch
> > maintainers-openwrt-devel-is-subscribers-only.patch
> > credits-update-stelians-entry.patch
> > maintainers-orphan-the-meye-driver.patch
> > maintainers-remove-stelian-from-the-ams-driver-record.patch
> > flex_array-export-symbols-to-modules.patch
> > drivers-mmc-host-omapc-use-resource_size.patch
> > drivers-mmc-host-omap_hsmmcc-use-resource_size.patch
> > scripts-checkpatchpl-add-check-for-multiple-terminating-semicolons-and-casts-of-vmalloc.patch
> > checkpatchpl-fix-cast-detection.patch
> > checkpatch-check-for-world-writeable-sysfs-debugfs-files.patch
> > checkpatchpl-add-prefer-__packed-check.patch
> > fs-select-fix-information-leak-to-userspace.patch
> > fs-select-fix-information-leak-to-userspace-fix.patch
> > epoll-convert-max_user_watches-to-long.patch
> > binfmt_elf-cleanups.patch
> > lib-hexdumpc-make-hex2bin-return-the-updated-src-address.patch
> > fs-binfmt_miscc-use-kernels-hex_to_bin-method.patch
> > fs-binfmt_miscc-use-kernels-hex_to_bin-method-fix.patch
> > fs-binfmt_miscc-use-kernels-hex_to_bin-method-fix-fix.patch
> > vgacon-check-for-efi-machine.patch
> > drivers-rtc-rtc-omapc-fix-a-memory-leak.patch
> > rtc-cmos-fix-suspend-resume.patch
> > rtc-delete-legacy-maintainers-entry.patch
> > rtc-add-real-time-clock-driver-for-nvidia-tegra.patch
> > drivers-gpio-cs5535-gpioc-add-some-additional-cs5535-specific-gpio-functionality.patch
> > drivers-staging-olpc_dcon-convert-to-new-cs5535-gpio-api.patch
> > cs5535-deprecate-older-cs5535_gpio-driver.patch
> > gpio-adp5588-gpio-irq_data-conversion.patch
> > gpio-langwell_gpio-irq_data-conversion.patch
> > gpio-max732x-irq_data-conversion.patch
> > gpio-pca953x-irq_data-conversion.patch
> > gpio-pl061-irq_data-conversion.patch
> > gpio-stmpe-gpio-irq_data-conversion.patch
> > gpio-sx150x-irq_data-conversion.patch
> > gpio-tc35892-gpio-irq_data-conversion.patch
> > gpio-timbgpio-irq_data-conversion.patch
> > gpio-vr41xx_giu-irq_data-conversion.patch
> > gpio_rdc321x-select-mfd_support-to-squelch-kconfig-warning.patch
> > gpio_vx855-eliminate-kconfig-dependency-warning.patch
> > gpio-ml_ioh_gpio-ml7213-gpio-driver.patch
> > gpio-ml_ioh_gpio-ml7213-gpio-driver-fix.patch
> > gpiolib-annotate-gpio-intialization-with-__must_check.patch
> > gpiolib-add-missing-functions-to-generic-fallback.patch
> > pipe-use-event-aware-wakeups.patch
> > drivers-telephony-ixjc-fix-warning.patch
> > ext2-speed-up-file-creates-by-optimizing-rec_len-functions.patch
> > ext3-speed-up-file-creates-by-optimizing-rec_len-functions.patch
> > ext3-remove-redundant-unlikely.patch
> > jbd-remove-dependency-on-__gfp_nofail.patch
> > befs-dont-pass-huge-structs-by-value.patch
> > reiserfs-make-sure-va_end-is-always-called-after-va_start.patch
> > documentation-email-clientstxt-warn-about-word-wrap-bug-in-kmail.patch
> > cgroups-remove-deprecated-subsystem-from-examples.patch
> > memcg-add-page_cgroup-flags-for-dirty-page-tracking.patch
> > memcg-document-cgroup-dirty-memory-interfaces.patch
> > memcg-document-cgroup-dirty-memory-interfaces-fix.patch
> > memcg-create-extensible-page-stat-update-routines.patch
> > memcg-add-lock-to-synchronize-page-accounting-and-migration.patch
> > memcg-fix-unit-mismatch-in-memcg-oom-limit-calculation.patch
> > memcg-remove-unnecessary-return-from-void-returning-mem_cgroup_del_lru_list.patch
> > memcg-fix-deadlock-between-cpuset-and-memcg.patch
> > memcg-fix-deadlock-between-cpuset-and-memcg-fix.patch
> > memcg-use-zalloc-rather-than-mallocmemset.patch
> > memcg-fix-memory-migration-of-shmem-swapcache.patch
> > fs-proc-basec-kernel-latencytopc-convert-sprintf_symbol-to-%ps.patch
> > fs-proc-basec-kernel-latencytopc-convert-sprintf_symbol-to-%ps-checkpatch-fixes.patch
> > proc-use-unsigned-long-inside-proc-statm.patch
> > proc-use-seq_puts-seq_putc-where-possible.patch
> > proc-low_ino-cleanup.patch
> > proc-use-single_open-correctly.patch
> > kpagecount-added-slab-page-checking-because-of-_mapcount-in-union.patch
> > proc-less-lock-unlock-in-remove_proc_entry.patch
> > exec_domain-establish-a-linux32-domain-on-config_compat-systems.patch
> > kernel-workqueuec-remove-noop-in-workqueue.patch
> > fs-char_devc-remove-unused-cdev_index.patch
> > rapidio-use-common-destid-storage-for-endpoints-and-switches.patch
> > rapidio-integrate-rio_switch-into-rio_dev.patch
> > rapidio-add-definitions-of-component-tag-fields.patch
> > rapidio-add-device-object-linking-into-discovery.patch
> > rapidio-use-component-tag-for-unified-switch-identification.patch
> > rapidio-add-new-idt-srio-switches.patch
> > rapidio-fix-hang-on-rapidio-doorbell-queue-full-condition.patch
> > rapidio-add-new-sysfs-attributes.patch
> > sysctl-fix-ifdef-guard-comment.patch
> > sysctl-remove-obsolete-comments.patch
> > sysctl-remove-obsolete-comments-fix.patch
> > user_ns-improve-the-user_ns-on-the-slab-packaging.patch
> > user_ns-improve-the-user_ns-on-the-slab-packaging-fix.patch
> > fs-execc-provide-the-correct-process-pid-to-the-pipe-helper.patch
> > nfc-driver-for-nxp-semiconductors-pn544-nfc-chip.patch
> > nfc-driver-for-nxp-semiconductors-pn544-nfc-chip-update.patch
> > taskstats-use-better-ifdef-for-alignment.patch
> > remove-dma64_addr_t.patch
> > pps-trivial-fixes.patch
> > pps-declare-variables-where-they-are-used-in-switch.patch
> > pps-fix-race-in-pps_fetch-handler.patch
> > pps-unify-timestamp-gathering.patch
> > pps-access-pps-device-by-direct-pointer.patch
> > pps-convert-printk-pr_-to-dev_.patch
> > pps-move-idr-stuff-to-ppsc.patch
> > pps-make-idr-lock-a-mutex-and-protect-idr_pre_get.patch
> > pps-use-bug_on-for-kernel-api-safety-checks.patch
> > pps-simplify-conditions-a-bit.patch
> > pps-timestamp-is-always-passed-to-dcd_change.patch
> > ntp-add-hardpps-implementation.patch
> > ntp-add-hardpps-implementation-update-v7.patch
> > pps-capture-monotonic_raw-timestamps-as-well.patch
> > pps-capture-monotonic_raw-timestamps-as-well-v7.patch
> > pps-add-kernel-consumer-support.patch
> > pps-add-kernel-consumer-support-v7.patch
> > pps-add-parallel-port-pps-client.patch
> > pps-add-parallel-port-pps-client-v7.patch
> > pps-add-parallel-port-pps-signal-generator.patch
> > pps-add-parallel-port-pps-signal-generator-fix.patch
> > pps-add-parallel-port-pps-signal-generator-v7.patch
> > memstick-core-fix-device_register-error-handling.patch
> > memstick-fix-setup-for-jmicron-38x-controllers.patch
> > memstick-set-pmos-values-propery-for-jmicron-38x-controllers.patch
> > memstick-add-support-for-jmicron-jmb-385-and-390-controllers.patch
> > memstick-avert-possible-race-condition-between-idr_pre_get-and-idr_get_new.patch
> > memstick-remove-mspro_block_mutex.patch
> > memstick-factor-out-transfer-initiating-functionality-in-mspro_blockc.patch
> > memstick-factor-out-transfer-initiating-functionality-in-mspro_blockc-fix.patch
> > memstick-add-support-for-mspro-specific-data-transfer-method.patch
> > w1-ds2423-counter-driver-and-documentation.patch
> > w1-ds2423-counter-driver-and-documentation-fix.patch
> > vmware-balloon-stop-locking-pages-when-hypervisor-tells-us-enough.patch
> > aio-remove-unnecessary-check.patch
> > aio-remove-unused-aio_run_iocbs.patch
> > aio-remove-unused-aio_run_iocbs-checkpatch-fixes.patch
> > cramfs-hide-function-prototypes-behind-__kernel__-macro.patch
> > cramfs-generate-unique-inode-number-for-better-inode-cache-usage.patch
> > cramfs-generate-unique-inode-number-for-better-inode-cache-usage-fix.patch
> > cramfs-generate-unique-inode-number-for-better-inode-cache-usage-checkpatch-fixes.patch
> > ramoops-fix-types-remove-typecasts.patch
> > romfs-have-romfs_fsh-pull-in-necessary-headers.patch
> > decompressors-add-missing-init-ie-__init.patch
> > decompressors-get-rid-of-set_error_fn-macro.patch
> > decompressors-include-linux-slabh-in-linux-decompress-mmh.patch
> > decompressors-remove-unused-function-from-lib-decompress_unlzmac.patch
> > decompressors-fix-header-validation-in-decompress_unlzmac.patch
> > decompressors-check-for-read-errors-in-decompress_unlzmac.patch
> > decompressors-check-for-write-errors-in-decompress_unlzmac.patch
> > decompressors-validate-match-distance-in-decompress_unlzmac.patch
> > decompressors-check-for-write-errors-in-decompress_unlzoc.patch
> > decompressors-check-input-size-in-decompress_unlzoc.patch
> > decompressors-fix-callback-to-callback-mode-in-decompress_unlzoc.patch
> > decompressors-add-xz-decompressor-module.patch
> > decompressors-add-boot-time-xz-support.patch
> > decompressors-add-boot-time-xz-support-update.patch
> > x86-support-xz-compressed-kernel.patch
> > decompressors-check-input-size-in-decompress_inflatec.patch
> > decompressors-remove-unused-constant-from-inflateh.patch
> > bitops-merge-little-and-big-endian-definisions-in-asm-generic-bitops-leh.patch
> > bitops-rename-generic-little-endian-bitops-functions.patch
> > s390-introduce-little-endian-bitops.patch
> > arm-introduce-little-endian-bitops.patch
> > m68k-introduce-little-endian-bitops.patch
> > bitops-introduce-config_generic_find_le_bit.patch
> > m68knommu-introduce-little-endian-bitops.patch
> > m68knommu-introduce-little-endian-bitops-build-fix.patch
> > bitops-introduce-little-endian-bitops-for-most-architectures.patch
> > rds-stop-including-asm-generic-bitops-leh.patch
> > kvm-stop-including-asm-generic-bitops-leh.patch
> > asm-generic-use-little-endian-bitops.patch
> > ext3-use-little-endian-bitops.patch
> > ext4-use-little-endian-bitops.patch
> > ocfs2-use-little-endian-bitops.patch
> > nilfs2-use-little-endian-bitops.patch
> > reiserfs-use-little-endian-bitops.patch
> > udf-use-little-endian-bitops.patch
> > ufs-use-little-endian-bitops.patch
> > md-use-little-endian-bit-operations.patch
> > dm-use-little-endian-bit-operations.patch
> > bitops-remove-ext2-non-atomic-bitops-from-asm-bitopsh.patch
> > m68k-remove-inline-asm-from-minix_find_first_zero_bit.patch
> > bitops-remove-minix-bitops-from-asm-bitopsh.patch
> > bitops-use-find_first_zero_bit-instead-of-find_next_zero_bitaddr-size-0.patch
> > make-sure-nobodys-leaking-resources.patch
> > journal_add_journal_head-debug.patch
> > releasing-resources-with-children.patch
> > make-frame_pointer-default=y.patch
> > mutex-subsystem-synchro-test-module.patch
> > mutex-subsystem-synchro-test-module-add-missing-header-file.patch
> > slab-leaks3-default-y.patch
> > put_bh-debug.patch
> > add-debugging-aid-for-memory-initialisation-problems.patch
> > workaround-for-a-pci-restoring-bug.patch
> > prio_tree-debugging-patch.patch
> > single_open-seq_release-leak-diagnostics.patch
> > add-a-refcount-check-in-dput.patch
> > memblock-add-input-size-checking-to-memblock_find_region.patch
> > memblock-add-input-size-checking-to-memblock_find_region-fix.patch
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org. For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Fight unfair telecom policy in Canada: sign
> > http://dissolvethecrtc.ca/
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
