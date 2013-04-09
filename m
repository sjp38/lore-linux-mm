Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id AA1A96B003A
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 19:38:32 -0400 (EDT)
Received: by mail-ie0-f201.google.com with SMTP id a11so1906915iee.2
        for <linux-mm@kvack.org>; Tue, 09 Apr 2013 16:38:32 -0700 (PDT)
Subject: mmotm 2013-04-09-16-37 uploaded
From: akpm@linux-foundation.org
Date: Tue, 09 Apr 2013 16:38:30 -0700
Message-Id: <20130409233830.9B6045A4252@corp2gmr1-2.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

The mm-of-the-moment snapshot 2013-04-09-16-37 has been uploaded to

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


This mmotm tree contains the following patches against 3.9-rc6:
(patches marked "*" will be included in linux-next)

  origin.patch
  linux-next.patch
  linux-next-git-rejects.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  i-need-old-gcc.patch
* thinkpad-acpi-kill-hotkey_thread_mutex.patch
* drivers-video-mmp-corec-fix-use-after-free-bug.patch
* revert-ipc-dont-allocate-a-copy-larger-than-max.patch
* checkpatch-fix-stringification-macro-defect.patch
* mips-define-kvm_user_mem_slots.patch
* drivers-char-randomc-fix-priming-of-last_data.patch
* kthread-introduce-to_live_kthread.patch
* kthread-kill-task_get_live_kthread.patch
* arch-x86-mm-init_64c-fix-build-warning-when-config_memory_hotremove=n.patch
* x86-make-mem=-option-to-work-for-efi-platform.patch
* auditsc-use-kzalloc-instead-of-kmallocmemset.patch
* auditsc-use-kzalloc-instead-of-kmallocmemset-fix.patch
* mm-remove-free_area_cache-use-in-powerpc-architecture.patch
* mm-use-vm_unmapped_area-on-powerpc-architecture.patch
* drm-fb-helper-dont-sleep-for-screen-unblank-when-an-oopps-is-in-progress.patch
* matroxfb-convert-struct-i2c_msg-initialization-to-c99-format.patch
* drivers-video-console-fbcon_cwc-fix-compiler-warning-in-cw_update_attr.patch
* drivers-video-add-hyper-v-synthetic-video-frame-buffer-driver.patch
* drivers-video-add-hyper-v-synthetic-video-frame-buffer-driver-fix.patch
* drivers-video-exynos-exynos_mipi_dsic-convert-to-devm_ioremap_resource.patch
* video-ep93xx-fbc-fix-section-mismatch-and-use-module_platform_driver.patch
* drivers-video-mmp-remove-legacy-hw-definitions.patch
* drivers-video-implement-a-simple-framebuffer-driver.patch
* drivers-video-implement-a-simple-framebuffer-driver-fix.patch
* cyber2000fb-avoid-palette-corruption-at-higher-clocks.patch
* timer_list-split-timer_list_show_tickdevices.patch
* timer_list-convert-timer-list-to-be-a-proper-seq_file.patch
* timer_list-convert-timer-list-to-be-a-proper-seq_file-v5.patch
* posix_cpu_timer-consolidate-expiry-time-type.patch
* posix_cpu_timers-consolidate-timer-list-cleanups.patch
* posix_cpu_timers-consolidate-expired-timers-check.patch
* selftests-add-basic-posix-timers-selftests.patch
* ktime_add_ns-may-overflow-on-32bit-architectures.patch
* posix-timers-correctly-get-dying-task-time-sample-in-posix_cpu_timer_schedule.patch
* posix_timers-fix-racy-timer-delta-caching-on-task-exit.patch
* posix_timers-remove-dead-task-timer-expiry-caching.patch
* mkcapflagspl-convert-to-mkcapflagssh.patch
* headers_installpl-convert-to-headers_installsh.patch
* scripts-decodecode-make-faulting-insn-ptr-more-robust.patch
* ipvs-change-type-of-netns_ipvs-sysctl_sync_qlen_max.patch
* ocfs2-delay-inode-update-transactions-after-verifying-the-input-flags.patch
* ocfs2-fix-error-return-code-in-ocfs2_info_handle_freefrag.patch
* ocfs2-fix-error-handling-in-ocfs2_ioctl_move_extents.patch
* ocfs2-fix-null-dereference-for-moving-extents.patch
* debug_locksh-make-warning-more-verbose.patch
* lockdep-introduce-lock_acquire_exclusive-shared-helper-macros.patch
* lglock-update-lockdep-annotations-to-report-recursive-local-locks.patch
* drivers-block-mg_diskc-add-config_pm_sleep-to-suspend-resume-functions.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* fs-block_devc-need-not-to-check-inode-i_bdev-in-bd_forget.patch
* watchdog-trigger-all-cpu-backtrace-when-locked-up-and-going-to-panic.patch
  mm.patch
* hwpoison-check-dirty-flag-to-match-against-clean-page.patch
* mm-trace-filemap-add-and-del.patch
* mm-trace-filemap-add-and-del-v2.patch
* mm-show_mem-suppress-page-counts-in-non-blockable-contexts.patch
* mm-shmemc-remove-an-ifdef.patch
* vm-adjust-ifdef-for-tiny_rcu.patch
* mm-frontswap-lazy-initialization-to-allow-tmem-backends-to-build-run-as-modules.patch
* frontswap-make-frontswap_init-use-a-pointer-for-the-ops.patch
* mm-frontswap-cleanup-code.patch
* frontswap-get-rid-of-swap_lock-dependency.patch
* mm-cleancache-lazy-initialization-to-allow-tmem-backends-to-build-run-as-modules.patch
* cleancache-make-cleancache_init-use-a-pointer-for-the-ops.patch
* mm-cleancache-clean-up-cleancache_enabled.patch
* xen-tmem-enable-xen-tmem-shim-to-be-built-loaded-as-a-module.patch
* xen-tmem-enable-xen-tmem-shim-to-be-built-loaded-as-a-module-fix.patch
* zcache-tmem-better-error-checking-on-frontswap_register_ops-return-value.patch
* staging-zcache-enable-ramster-to-be-built-loaded-as-a-module.patch
* staging-zcache-enable-zcache-to-be-built-loaded-as-a-module.patch
* rmap-recompute-pgoff-for-unmapping-huge-page.patch
* memblock-add-assertion-for-zero-allocation-alignment.patch
* mm-walk_memory_range-fix-typo-in-comment.patch
* direct-io-fix-boundary-block-handling.patch
* direct-io-submit-bio-after-boundary-buffer-is-added-to-it.patch
* vmscan-minor-cleanup-for-kswapd.patch
* mm-introduce-common-help-functions-to-deal-with-reserved-managed-pages.patch
* mm-alpha-use-common-help-functions-to-free-reserved-pages.patch
* mm-arm-use-common-help-functions-to-free-reserved-pages.patch
* mm-avr32-use-common-help-functions-to-free-reserved-pages.patch
* mm-blackfin-use-common-help-functions-to-free-reserved-pages.patch
* mm-c6x-use-common-help-functions-to-free-reserved-pages.patch
* mm-cris-use-common-help-functions-to-free-reserved-pages.patch
* mm-frv-use-common-help-functions-to-free-reserved-pages.patch
* mm-h8300-use-common-help-functions-to-free-reserved-pages.patch
* mm-ia64-use-common-help-functions-to-free-reserved-pages.patch
* mm-m32r-use-common-help-functions-to-free-reserved-pages.patch
* mm-m68k-use-common-help-functions-to-free-reserved-pages.patch
* mm-microblaze-use-common-help-functions-to-free-reserved-pages.patch
* mm-mips-use-common-help-functions-to-free-reserved-pages.patch
* mm-mn10300-use-common-help-functions-to-free-reserved-pages.patch
* mm-openrisc-use-common-help-functions-to-free-reserved-pages.patch
* mm-parisc-use-common-help-functions-to-free-reserved-pages.patch
* mm-ppc-use-common-help-functions-to-free-reserved-pages.patch
* mm-s390-use-common-help-functions-to-free-reserved-pages.patch
* mm-score-use-common-help-functions-to-free-reserved-pages.patch
* mm-sh-use-common-help-functions-to-free-reserved-pages.patch
* mm-sparc-use-common-help-functions-to-free-reserved-pages.patch
* mm-um-use-common-help-functions-to-free-reserved-pages.patch
* mm-unicore32-use-common-help-functions-to-free-reserved-pages.patch
* mm-x86-use-common-help-functions-to-free-reserved-pages.patch
* mm-xtensa-use-common-help-functions-to-free-reserved-pages.patch
* mm-arc-use-common-help-functions-to-free-reserved-pages.patch
* mm-metag-use-common-help-functions-to-free-reserved-pages.patch
* mmkexec-use-common-help-functions-to-free-reserved-pages.patch
* mm-introduce-free_highmem_page-helper-to-free-highmem-pages-into-buddy-system.patch
* mm-arm-use-free_highmem_page-to-free-highmem-pages-into-buddy-system.patch
* mm-frv-use-free_highmem_page-to-free-highmem-pages-into-buddy-system.patch
* mm-metag-use-free_highmem_page-to-free-highmem-pages-into-buddy-system.patch
* mm-microblaze-use-free_highmem_page-to-free-highmem-pages-into-buddy-system.patch
* mm-mips-use-free_highmem_page-to-free-highmem-pages-into-buddy-system.patch
* mm-ppc-use-free_highmem_page-to-free-highmem-pages-into-buddy-system.patch
* mm-sparc-use-free_highmem_page-to-free-highmem-pages-into-buddy-system.patch
* mm-um-use-free_highmem_page-to-free-highmem-pages-into-buddy-system.patch
* mm-x86-use-free_highmem_page-to-free-highmem-pages-into-buddy-system.patch
* memcg-keep-prevs-css-alive-for-the-whole-mem_cgroup_iter.patch
* memcg-rework-mem_cgroup_iter-to-use-cgroup-iterators.patch
* memcg-relax-memcg-iter-caching.patch
* memcg-relax-memcg-iter-caching-checkpatch-fixes.patch
* memcg-simplify-mem_cgroup_iter.patch
* memcg-further-simplify-mem_cgroup_iter.patch
* cgroup-remove-css_get_next.patch
* fs-dont-compile-in-drop_cachesc-when-config_sysctl=n.patch
* mm-hugetlb-add-more-arch-defined-huge_pte-functions.patch
* mm-make-snapshotting-pages-for-stable-writes-a-per-bio-operation.patch
* mm-make-snapshotting-pages-for-stable-writes-a-per-bio-operation-v3.patch
* mm-vmalloc-change-iterating-a-vmlist-to-find_vm_area.patch
* mm-vmalloc-move-get_vmalloc_info-to-vmallocc.patch
* mm-vmalloc-protect-va-vm-by-vmap_area_lock.patch
* mm-vmalloc-iterate-vmap_area_list-instead-of-vmlist-in-vread-vwrite.patch
* mm-vmalloc-iterate-vmap_area_list-in-get_vmalloc_info.patch
* mm-vmalloc-iterate-vmap_area_list-instead-of-vmlist-in-vmallocinfo.patch
* mm-vmalloc-export-vmap_area_list-instead-of-vmlist.patch
* mm-vmalloc-remove-list-management-of-vmlist-after-initializing-vmalloc.patch
* kexec-vmalloc-export-additional-vmalloc-layer-information.patch
* kexec-vmalloc-export-additional-vmalloc-layer-information-fix.patch
* mmap-find_vma-remove-the-warn_on_oncemm-check.patch
* memcg-do-not-check-for-do_swap_account-in-mem_cgroup_readwritereset.patch
* mm-allow-arch-code-to-control-the-user-page-table-ceiling.patch
* arm-set-the-page-table-freeing-ceiling-to-task_size.patch
* mm-merging-memory-blocks-resets-mempolicy.patch
* mm-hugetlb-include-hugepages-in-meminfo.patch
* mm-hugetlb-include-hugepages-in-meminfo-checkpatch-fixes.patch
* mm-try-harder-to-allocate-vmemmap-blocks.patch
* sparse-vmemmap-specify-vmemmap-population-range-in-bytes.patch
* sparse-vmemmap-specify-vmemmap-population-range-in-bytes-fix.patch
* x86-64-remove-dead-debugging-code-for-pse-setups.patch
* x86-64-use-vmemmap_populate_basepages-for-pse-setups.patch
* x86-64-use-vmemmap_populate_basepages-for-pse-setups-fix.patch
* x86-64-fall-back-to-regular-page-vmemmap-on-allocation-failure.patch
* mm-page_alloc-avoid-marking-zones-full-prematurely-after-zone_reclaim.patch
* mm-page_alloc-avoid-marking-zones-full-prematurely-after-zone_reclaim-fix.patch
* mm-migrate-fix-comment-typo-syncronous-synchronous.patch
* mm-speedup-in-__early_pfn_to_nid.patch
* mm-speedup-in-__early_pfn_to_nid-fix.patch
* page_alloc-make-setup_nr_node_ids-usable-for-arch-init-code.patch
* x86-mm-numa-use-setup_nr_node_ids-instead-of-opencoding.patch
* powerpc-mm-numa-use-setup_nr_node_ids-instead-of-opencoding.patch
* powerpc-mm-numa-use-setup_nr_node_ids-instead-of-opencoding-fix.patch
* include-linux-memoryh-implement-register_hotmemory_notifier.patch
* mm-limit-growth-of-3%-hardcoded-other-user-reserve.patch
* mm-replace-hardcoded-3%-with-admin_reserve_pages-knob.patch
* mm-reinititalise-user-and-admin-reserves-if-memory-is-added-or-removed.patch
* mm-reinititalise-user-and-admin-reserves-if-memory-is-added-or-removed-fix.patch
* mm-memcontrolc-remove-unnecessary.patch
* mm-remove-config_hotplug-ifdefs.patch
* thp-fix-comment-about-memory-barrier.patch
* mm-remove-free_area_cache.patch
* include-linux-mmzoneh-cleanups.patch
* include-linux-mmzoneh-cleanups-fix.patch
* mm-memmap_init_zone-performance-improvement.patch
* drop_caches-add-some-documentation-and-info-messsge.patch
* drivers-usb-gadget-amd5536udcc-avoid-calling-dma_pool_create-with-null-dev.patch
* mm-dmapoolc-fix-null-dev-in-dma_pool_create.patch
* memcg-debugging-facility-to-access-dangling-memcgs.patch
* memcg-debugging-facility-to-access-dangling-memcgs-fix.patch
* mm-add-vm-event-counters-for-balloon-pages-compaction.patch
* rpmsg-fix-error-return-code-in-rpmsg_probe.patch
* genalloc-add-devres-support-allow-to-find-a-managed-pool-by-device.patch
* genalloc-add-devres-support-allow-to-find-a-managed-pool-by-device-fix.patch
* misc-generic-on-chip-sram-allocation-driver.patch
* misc-generic-on-chip-sram-allocation-driver-fix.patch
* media-coda-use-genalloc-api.patch
* kernel-watchdogc-add-comments-to-explain-watchdog_disabled-variable.patch
* kernel-rangec-subtract_range-fix-the-broken-phrase-issued-by-printk.patch
* smp-give-warning-when-calling-smp_call_function_many-single-in-serving-irq.patch
* include-linux-fsh-disable-preempt-when-acquire-i_size_seqcount-write-lock.patch
* kernel-smpc-cleanups.patch
* printk-tracing-rework-console-tracing.patch
* early_printk-consolidate-random-copies-of-identical-code.patch
* early_printk-consolidate-random-copies-of-identical-code-v3.patch
* early_printk-consolidate-random-copies-of-identical-code-v3-fix.patch
* include-linux-printkh-include-stdargh.patch
* printk-fix-failure-to-return-error-in-devkmsg_poll.patch
* get_maintainer-use-filename-only-regex-match-for-tegra.patch
* get_maintainer-use-filename-only-regex-match-for-tegra-fix.patch
* maintainers-i8k-driver-is-orphan.patch
* drivers-video-backlight-ams369fg06c-convert-ams369fg06-to-dev_pm_ops.patch
* drivers-video-backlight-ams369fg06c-convert-ams369fg06-to-dev_pm_ops-fix.patch
* backlight-platform_lcd-remove-unnecessary-ifdefs.patch
* backlight-ep93xx_bl-remove-incorrect-__init-annotation.patch
* drivers-video-backlight-atmel-pwm-blc-use-module_platform_driver_probe.patch
* drivers-video-backlight-atmel-pwm-blc-add-__init-annotation.patch
* drivers-video-backlight-lp855x_blc-fix-compiler-warning-in-lp855x_probe.patch
* drivers-video-backlight-jornada720_c-use-dev_err-dev_info-instead-of-pr_err-pr_info.patch
* drivers-video-backlight-omap1_blc-use-dev_info-instead-of-pr_info.patch
* drivers-video-backlight-generic_blc-use-dev_info-instead-of-pr_info.patch
* backlight-adp8870-add-missing-braces.patch
* drivers-video-backlight-l4f00242t03c-check-return-value-of-regulator_enable.patch
* drivers-video-backlight-l4f00242t03c-check-return-value-of-regulator_enable-fix.patch
* backlight-ld9040-convert-ld9040-to-dev_pm_ops.patch
* backlight-lms501kf03-convert-lms501kf03-to-dev_pm_ops.patch
* backlight-s6e63m0-convert-s6e63m0-to-dev_pm_ops.patch
* backlight-adp5520-convert-adp5520_bl-to-dev_pm_ops.patch
* backlight-adp8860-convert-adp8860-to-dev_pm_ops.patch
* backlight-adp8870-convert-adp8870-to-dev_pm_ops.patch
* backlight-corgi_lcd-convert-corgi_lcd-to-dev_pm_ops.patch
* backlight-ep93xx-convert-ep93xx-to-dev_pm_ops.patch
* backlight-hp680_bl-convert-hp680bl-to-dev_pm_ops.patch
* backlight-kb3886_bl-convert-kb3886bl-to-dev_pm_ops.patch
* backlight-lm3533_bl-convert-lm3533_bl-to-dev_pm_ops.patch
* backlight-locomolcd-convert-locomolcd-to-dev_pm_ops.patch
* backlight-ltv350qv-convert-ltv350qv-to-dev_pm_ops.patch
* backlight-tdo24m-convert-tdo24m-to-dev_pm_ops.patch
* drivers-video-backlight-kconfig-fix-typo-mach_sam9ek-three-times.patch
* drivers-video-backlight-adp5520_blc-fix-compiler-warning-in-adp5520_show.patch
* video-backlight-add-ili922x-lcd-driver.patch
* backlight-da903x_bl-use-bl_core_suspendresume-option.patch
* backlight-lp855x-use-page_size-for-the-sysfs-read-operation.patch
* drivers-video-backlight-adp8860_blc-fix-error-return-code-in-adp8860_led_probe.patch
* drivers-video-backlight-adp8870_blc-fix-error-return-code-in-adp8870_led_probe.patch
* drivers-video-backlight-as3711_blc-add-of-support.patch
* backlight-ili9320-use-spi_set_drvdata.patch
* backlight-ili922x-use-spi_set_drvdata.patch
* drivers-leds-leds-ot200c-fix-error-caused-by-shifted-mask.patch
* lib-int_sqrtc-optimize-square-root-algorithm.patch
* argv_split-teach-it-to-handle-mutable-strings.patch
* argv_split-teach-it-to-handle-mutable-strings-fix.patch
* argv_split-teach-it-to-handle-mutable-strings-fix-2.patch
* kernel-compatc-make-do_sysinfo-static.patch
* kernel-timerc-convert-compat_sys_sysinfo-to-compat_syscall_define.patch
* kernel-timerc-ove-some-non-timer-related-syscalls-to-kernel-sysc.patch
* kernel-timerc-ove-some-non-timer-related-syscalls-to-kernel-sysc-checkpatch-fixes.patch
* checkpatch-add-check-for-reuse-of-krealloc-arg.patch
* checkpatch-prefer-seq_puts-to-seq_printf.patch
* checkpatch-complain-about-executable-files.patch
* checkpatch-warn-on-space-before-semicolon.patch
* epoll-trim-epitem-by-one-cache-line-on-x86_64.patch
* epoll-trim-epitem-by-one-cache-line-on-x86_64-fix.patch
* epoll-trim-epitem-by-one-cache-line-on-x86_64-fix-fix.patch
* epoll-support-for-disabling-items-and-a-self-test-app.patch
* epoll-support-for-disabling-items-and-a-self-test-app-fix.patch
* epoll-use-rcu-to-protect-wakeup_source-in-epitem.patch
* epoll-use-rcu-to-protect-wakeup_source-in-epitem-fix.patch
* epoll-lock-ep-mtx-in-ep_free-to-silence-lockdep.patch
* epoll-cleanup-hoist-out-f_op-poll-calls.patch
* fs-make-binfmt-support-for-scripts-modular-and-removable.patch
* binfmt_elfc-use-get_random_int-to-fix-entropy-depleting.patch
* init-scream-bloody-murder-if-interrupts-are-enabled-too-early.patch
* init-raise-log-level.patch
* init-mainc-convert-to-pr_foo.patch
* dmi_scan-refactor-dmi_scan_machine-smbiosdmi_present.patch
* dmi_scan-refactor-dmi_scan_machine-smbiosdmi_present-fix.patch
* i2o-check-copy_from_user-size-parameter.patch
* rtc-rtc-mv-add-__init-annotation.patch
* rtc-rtc-davinci-add-__exit-annotation.patch
* rtc-rtc-ds1302-add-__exit-annotation.patch
* rtc-rtc-imxdi-add-__init-__exit-annotation.patch
* rtc-rtc-nuc900-add-__init-__exit-annotation.patch
* rtc-rtc-pcap-add-__init-__exit-annotation.patch
* rtc-rtc-tegra-add-__init-__exit-annotation.patch
* rtc-add-devm_rtc_device_registerunregister.patch
* rtc-max77686-use-module_platform_driver.patch
* rtc-max77686-add-missing-module-author-name.patch
* rtc-max77686-use-devm_kzalloc.patch
* rtc-max77686-fix-indentation-of-bit-definitions.patch
* rtc-max77686-use-dev_info-dev_emerg-instead-of-pr_info-pr_emerg.patch
* rtc-rtc-v3020-use-gpio_request_array.patch
* rtc-use-struct-device-as-the-first-argument-for-devm_rtc_device_register.patch
* rtc-rtc-ab3100-use-module_platform_driver_probe.patch
* rtc-rtc-at32ap700x-use-module_platform_driver_probe.patch
* rtc-rtc-at91rm9200-use-module_platform_driver_probe.patch
* rtc-rtc-au1xxx-use-module_platform_driver_probe.patch
* rtc-rtc-coh901331-use-module_platform_driver_probe.patch
* rtc-rtc-davinci-use-module_platform_driver_probe.patch
* rtc-rtc-ds1302-use-module_platform_driver_probe.patch
* rtc-rtc-efi-use-module_platform_driver_probe.patch
* rtc-rtc-generic-use-module_platform_driver_probe.patch
* rtc-rtc-imxdi-use-module_platform_driver_probe.patch
* rtc-rtc-mc13xxx-use-module_platform_driver_probe.patch
* rtc-rtc-msm6242-use-module_platform_driver_probe.patch
* rtc-rtc-mv-use-module_platform_driver_probe.patch
* rtc-rtc-nuc900-use-module_platform_driver_probe.patch
* rtc-rtc-omap-use-module_platform_driver_probe.patch
* rtc-rtc-pcap-use-module_platform_driver_probe.patch
* rtc-rtc-ps3-use-module_platform_driver_probe.patch
* rtc-rtc-pxa-use-module_platform_driver_probe.patch
* rtc-rtc-rp5c01-use-module_platform_driver_probe.patch
* rtc-rtc-sh-use-module_platform_driver_probe.patch
* rtc-rtc-starfire-use-module_platform_driver_probe.patch
* rtc-rtc-sun4v-use-module_platform_driver_probe.patch
* rtc-rtc-tegra-use-module_platform_driver_probe.patch
* rtc-rtc-tx4939-use-module_platform_driver_probe.patch
* rtc-rtc-88pm80x-use-devm_rtc_device_register.patch
* rtc-rtc-coh90133-use-devm_rtc_device_register.patch
* rtc-rtc-da9052-use-devm_rtc_device_register.patch
* rtc-rtc-da9055-use-devm_rtc_device_register.patch
* rtc-rtc-davinci-use-devm_rtc_device_register.patch
* rtc-rtc-ds1511-use-devm_rtc_device_register.patch
* rtc-rtc-ds1553-use-devm_rtc_device_register.patch
* rtc-rtc-ds1742-use-devm_rtc_device_register.patch
* rtc-rtc-ep93xx-use-devm_rtc_device_register.patch
* rtc-rtc-imxdi-use-devm_rtc_device_register.patch
* rtc-rtc-lp8788-use-devm_rtc_device_register.patch
* rtc-rtc-lpc32xx-use-devm_rtc_device_register.patch
* rtc-rtc-max77686-use-devm_rtc_device_register.patch
* rtc-rtc-max8907-use-devm_rtc_device_register.patch
* rtc-rtc-max8997-use-devm_rtc_device_register.patch
* rtc-rtc-mv-use-devm_rtc_device_register.patch
* rtc-rtc-mxc-use-devm_rtc_device_register.patch
* rtc-rtc-palmas-use-devm_rtc_device_register.patch
* rtc-rtc-pcf8523-use-devm_rtc_device_register.patch
* rtc-rtc-s3c-use-devm_rtc_device_register.patch
* rtc-rtc-snvs-use-devm_rtc_device_register.patch
* rtc-rtc-spear-use-devm_rtc_device_register.patch
* rtc-rtc-stk17ta8-use-devm_rtc_device_register.patch
* rtc-rtc-tps6586x-use-devm_rtc_device_register.patch
* rtc-rtc-tps65910-use-devm_rtc_device_register.patch
* rtc-rtc-tps80031-use-devm_rtc_device_register.patch
* rtc-rtc-tx4939-use-devm_rtc_device_register.patch
* rtc-rtc-vt8500-use-devm_rtc_device_register.patch
* rtc-rtc-wm831x-use-devm_rtc_device_register.patch
* rtc-ds1286-fix-compiler-warning-while-doing-make-w=1.patch
* drivers-rtc-rtc-pxac-fix-set-time-sync-time-issue.patch
* drivers-rtc-rtc-pxac-fix-set-time-sync-time-issue-fix.patch
* rtc-tegra-protect-suspend-resume-callbacks-with-config_pm_sleep.patch
* rtc-tegra-use-struct-dev_pm_ops-for-power-management.patch
* rtc-tegra-set-irq-name-as-device-name.patch
* rtc-tegra-use-managed-rtc_device_register.patch
* rtc-tegra-use-managed-rtc_device_register-fix.patch
* rtc-ds1307-long-block-operations-bugfix.patch
* rtc-rtc-palmas-use-devm_request_threaded_irq.patch
* rtc-rtc-s3c-convert-s3c_rtc-to-dev_pm_ops.patch
* rtc-rtc-ds1307-use-dev_dbg-instead-of-pr_debug.patch
* rtc-rtc-fm3130-use-dev_dbg-instead-of-pr_debug.patch
* rtc-rtc-ab3100-use-devm_rtc_device_register.patch
* rtc-rtc-au1xxx-use-devm_rtc_device_register.patch
* rtc-rtc-bq32k-use-devm_rtc_device_register.patch
* rtc-rtc-dm355evm-use-devm_rtc_device_register.patch
* rtc-rtc-ds1302-use-devm_rtc_device_register.patch
* rtc-rtc-ds1672-use-devm_rtc_device_register.patch
* rtc-rtc-ds3234-use-devm_rtc_device_register.patch
* rtc-rtc-efi-use-devm_rtc_device_register.patch
* rtc-rtc-em3027-use-devm_rtc_device_register.patch
* rtc-rtc-generic-use-devm_rtc_device_register.patch
* rtc-hid-sensor-time-use-devm_rtc_device_register.patch
* rtc-rtc-ls1x-use-devm_rtc_device_register.patch
* rtc-rtc-m41t93-use-devm_rtc_device_register.patch
* rtc-rtc-m41t94-use-devm_rtc_device_register.patch
* rtc-rtc-m48t86-use-devm_rtc_device_register.patch
* rtc-rtc-max6900-use-devm_rtc_device_register.patch
* rtc-rtc-max6902-use-devm_rtc_device_register.patch
* rtc-rtc-ps3-use-devm_rtc_device_register.patch
* rtc-rtc-r9701-use-devm_rtc_device_register.patch
* rtc-rtc-rc5t583-use-devm_rtc_device_register.patch
* rtc-rtc-rs5c313-use-devm_rtc_device_register.patch
* rtc-rtc-rv3029c2-use-devm_rtc_device_register.patch
* rtc-rtc-rx4581-use-devm_rtc_device_register.patch
* rtc-rtc-rx8581-use-devm_rtc_device_register.patch
* rtc-rtc-starfire-use-devm_rtc_device_register.patch
* rtc-rtc-sun4v-use-devm_rtc_device_register.patch
* rtc-rtc-test-use-devm_rtc_device_register.patch
* rtc-rtc-tile-use-devm_rtc_device_register.patch
* rtc-rtc-wm8350-use-devm_rtc_device_register.patch
* rtc-rtc-x1205-use-devm_rtc_device_register.patch
* rtc-rtc-at91rm9200-switch-to-using-simple_dev_pm_ops.patch
* rtc-rtc-mxc-switch-to-using-simple_dev_pm_ops.patch
* rtc-rtc-pxa-switch-to-using-simple_dev_pm_ops.patch
* rtc-rtc-rc5t583-switch-to-using-simple_dev_pm_ops.patch
* rtc-rtc-sa1100-switch-to-using-simple_dev_pm_ops.patch
* rtc-rtc-sh-switch-to-using-simple_dev_pm_ops.patch
* rtc-rtc-wm8350-switch-to-using-simple_dev_pm_ops.patch
* rtc-rtc-tps6586x-switch-to-using-simple_dev_pm_ops.patch
* rtc-rtc-tps65910-switch-to-using-simple_dev_pm_ops.patch
* rtc-rtc-tps80031-switch-to-using-simple_dev_pm_ops.patch
* rtc-omap-update-to-devm_-api.patch
* drivers-rtc-rtc-palmasc-add-dt-support.patch
* drivers-rtc-rtc-ds1374c-add-config_pm_sleep-to-suspend-resume-functions.patch
* drivers-rtc-rtc-88pm80xc-add-config_pm_sleep-to-suspend-resume-functions.patch
* drivers-rtc-rtc-tps6586xc-remove-incorrect-use-of-rtc_device_unregister.patch
* drivers-rtc-rtc-tps65910c-fix-incorrect-return-value-on-error.patch
* drivers-rtc-rtc-max8997c-fix-incorrect-return-value-on-error.patch
* drivers-rtc-rtc-max77686c-fix-incorrect-return-value-on-error.patch
* drivers-rtc-rtc-max8907c-remove-redundant-code.patch
* drivers-rtc-rtc-at91rm9200c-add-dt-support.patch
* drivers-rtc-rtc-ds1307c-change-sysfs-function-pointer-assignment.patch
* rtc-rtc-rx4581-use-spi_set_drvdata.patch
* rtc-rtc-m41t94-use-spi_set_drvdata.patch
* rtc-rtc-r9701-use-spi_set_drvdata.patch
* rtc-rtc-ds3234-use-spi_set_drvdata.patch
* rtc-rtc-ds1390-use-spi_set_drvdata.patch
* rtc-rtc-m41t93-use-spi_set_drvdata.patch
* rtc-rtc-max6902-use-spi_set_drvdata.patch
* hfsplus-fix-warnings-in-fs-hfsplus-bfindc-in-function-hfs_find_1st_rec_by_cnid.patch
* hfsplus-fix-warnings-in-fs-hfsplus-bfindc-in-function-hfs_find_1st_rec_by_cnid-fix.patch
* hfs-hfsplus-convert-dprint-to-hfs_dbg.patch
* hfs-hfsplus-convert-printks-to-pr_level.patch
* fat-introduce-2-new-values-for-the-o-nfs-mount-option.patch
* fat-move-fat_i_pos_read-to-fath.patch
* fat-introduce-a-helper-fat_get_blknr_offset.patch
* fat-restructure-export_operations.patch
* fat-exportfs-rebuild-inode-if-ilookup-fails.patch
* fat-exportfs-rebuild-directory-inode-if-fat_dget.patch
* documentation-update-nfs-option-in-filesystem-vfattxt.patch
* ptrace-add-ability-to-retrieve-signals-without-removing-from-a-queue-v4.patch
* selftest-add-a-test-case-for-ptrace_peeksiginfo.patch
* usermodehelper-export-_exec-and-_setup-functions.patch
* usermodehelper-export-_exec-and-_setup-functions-fix.patch
* kmod-split-call-to-call_usermodehelper_fns.patch
* keys-split-call-to-call_usermodehelper_fns.patch
* coredump-remove-trailling-whitespaces.patch
* split-remaining-calls-to-call_usermodehelper_fns.patch
* kmod-remove-call_usermodehelper_fns.patch
* coredump-only-sigkill-should-interrupt-the-coredumping-task.patch
* coredump-ensure-that-sigkill-always-kills-the-dumping-thread.patch
* coredump-sanitize-the-setting-of-signal-group_exit_code.patch
* coredump-introduce-dump_interrupted.patch
* coredump-factor-out-the-setting-of-pf_dumpcore.patch
* coredump-change-wait_for_dump_helpers-to-use-wait_event_interruptible.patch
* fs-proc-truncate-proc-pid-comm-writes-to-first-task_comm_len-bytes.patch
* set_task_comm-kill-the-pointless-memset-wmb.patch
* exec-do-not-abuse-cred_guard_mutex-in-threadgroup_lock.patch
* kexec-fix-wrong-types-of-some-local-variables.patch
* kexec-use-min_t-to-simplify-logic.patch
* kexec-use-min_t-to-simplify-logic-fix.patch
* idr-introduce-idr_alloc_cyclic.patch
* drivers-infiniband-hw-amso1100-convert-to-using-idr_alloc_cyclic.patch
* drivers-infiniband-hw-mlx4-convert-to-using-idr_alloc_cyclic.patch
* nfsd-convert-nfs4_alloc_stid-to-use-idr_alloc_cyclic.patch
* inotify-convert-inotify_add_to_idr-to-use-idr_alloc_cyclic.patch
* sctp-convert-sctp_assoc_set_id-to-use-idr_alloc_cyclic.patch
* ipc-clamp-with-min.patch
* ipc-separate-msg-allocation-from-userspace-copy.patch
* ipc-tighten-msg-copy-loops.patch
* ipc-set-efault-as-default-error-in-load_msg.patch
* ipc-remove-msg-handling-from-queue-scan.patch
* ipc-implement-msg_copy-as-a-new-receive-mode.patch
* ipc-simplify-msg-list-search.patch
* ipc-refactor-msg-list-search-into-separate-function.patch
* ipc-refactor-msg-list-search-into-separate-function-fix.patch
* ipc-msgutilc-use-linux-uaccessh.patch
* ipc-remove-bogus-lock-comment-for-ipc_checkid.patch
* ipc-introduce-obtaining-a-lockless-ipc-object.patch
* ipc-introduce-obtaining-a-lockless-ipc-object-fix.patch
* ipc-introduce-lockless-pre_down-ipcctl.patch
* ipcsem-do-not-hold-ipc-lock-more-than-necessary.patch
* ipcsem-open-code-and-rename-sem_lock.patch
* ipcsem-open-code-and-rename-sem_lock-fix.patch
* ipcsem-have-only-one-list-in-struct-sem_queue.patch
* ipcsem-fine-grained-locking-for-semtimedop.patch
* ipcsem-fine-grained-locking-for-semtimedop-fix.patch
* ipcsem-fine-grained-locking-for-semtimedop-fix-fix.patch
* ipc-msgc-use-list_for_each_entry_-for-list-traversing.patch
* ipc-semc-alternatives-to-preempt_disable.patch
* kernel-pidc-improve-flow-of-a-loop-inside-alloc_pidmap.patch
* kernel-pidc-improve-flow-of-a-loop-inside-alloc_pidmap-fix.patch
* pid_namespacec-h-simplify-defines.patch
* pid_namespacec-h-simplify-defines-fix.patch
* aoe-replace-kmalloc-and-then-memcpy-with-kmemdup.patch
* raid6test-use-prandom_bytes.patch
* uuid-use-prandom_bytes.patch
* x86-pageattr-test-remove-srandom32-call.patch
* x86-rename-random32-to-prandom_u32.patch
* lib-rename-random32-to-prandom_u32.patch
* mm-rename-random32-to-prandom_u32.patch
* kernel-rename-random32-to-prandom_u32.patch
* drbd-rename-random32-to-prandom_u32.patch
* infiniband-rename-random32-to-prandom_u32.patch
* mmc-rename-random32-to-prandom_u32.patch
* video-uvesafb-rename-random32-to-prandom_u32.patch
* uwb-rename-random32-to-prandom_u32.patch
* lguest-rename-random32-to-prandom_u32.patch
* scsi-rename-random32-to-prandom_u32.patch
* drivers-net-rename-random32-to-prandom_u32.patch
* drivers-net-rename-random32-to-prandom_u32-fix.patch
* net-sunrpc-rename-random32-to-prandom_u32.patch
* net-sched-rename-random32-to-prandom_u32.patch
* net-netfilter-rename-random32-to-prandom_u32.patch
* net-core-rename-random32-to-prandom_u32.patch
* net-core-remove-duplicate-statements-by-do-while-loop.patch
* net-rename-random32-to-prandom.patch
* remove-unused-random32-and-srandom32.patch
* pps-hide-more-configuration-symbols-behind-config_pps.patch
* semaphore-give-an-unlikely-for-downs-timeout.patch
* semaphore-boolize-semaphore_waiters-up.patch
* memstick-r592-make-r592_pm_ops-static.patch
* relay-remove-unused-function-argument-actor.patch
* relay-move-fix_size-macro-into-relayc.patch
* relay-use-macro-page_align-instead-of-fix_size.patch
* mm-remove-old-aio-use_mm-comment.patch
* aio-remove-dead-code-from-aioh.patch
* gadget-remove-only-user-of-aio-retry.patch
* gadget-remove-only-user-of-aio-retry-checkpatch-fixes.patch
* aio-remove-retry-based-aio.patch
* aio-remove-retry-based-aio-checkpatch-fixes.patch
* char-add-aio_readwrite-to-dev-nullzero.patch
* aio-kill-return-value-of-aio_complete.patch
* aio-add-kiocb_cancel.patch
* aio-move-private-stuff-out-of-aioh.patch
* aio-dprintk-pr_debug.patch
* aio-do-fget-after-aio_get_req.patch
* aio-make-aio_put_req-lockless.patch
* aio-make-aio_put_req-lockless-checkpatch-fixes.patch
* aio-refcounting-cleanup.patch
* aio-refcounting-cleanup-checkpatch-fixes.patch
* wait-add-wait_event_hrtimeout.patch
* aio-make-aio_read_evt-more-efficient-convert-to-hrtimers.patch
* aio-make-aio_read_evt-more-efficient-convert-to-hrtimers-checkpatch-fixes.patch
* aio-use-flush_dcache_page.patch
* aio-use-cancellation-list-lazily.patch
* aio-change-reqs_active-to-include-unreaped-completions.patch
* aio-kill-batch-allocation.patch
* aio-kill-struct-aio_ring_info.patch
* aio-give-shared-kioctx-fields-their-own-cachelines.patch
* aio-reqs_active-reqs_available.patch
* aio-percpu-reqs_available.patch
* generic-dynamic-per-cpu-refcounting.patch
* generic-dynamic-per-cpu-refcounting-checkpatch-fixes.patch
* aio-percpu-ioctx-refcount.patch
* aio-use-xchg-instead-of-completion_lock.patch
* aio-dont-include-aioh-in-schedh.patch
* aio-dont-include-aioh-in-schedh-fix.patch
* aio-kill-ki_key.patch
* aio-kill-ki_retry.patch
* aio-kill-ki_retry-fix.patch
* aio-kill-ki_retry-checkpatch-fixes.patch
* block-prep-work-for-batch-completion.patch
* block-prep-work-for-batch-completion-checkpatch-fixes.patch
* block-prep-work-for-batch-completion-fix.patch
* block-prep-work-for-batch-completion-fix-2.patch
* block-prep-work-for-batch-completion-fix-3.patch
* block-prep-work-for-batch-completion-fix-3-fix.patch
* block-aio-batch-completion-for-bios-kiocbs.patch
* block-aio-batch-completion-for-bios-kiocbs-checkpatch-fixes.patch
* block-aio-batch-completion-for-bios-kiocbs-fix.patch
* virtio-blk-convert-to-batch-completion.patch
* mtip32xx-convert-to-batch-completion.patch
* aio-fix-kioctx-not-being-freed-after-cancellation-at-exit-time.patch
* kconfig-consolidate-config_debug_strict_user_copy_checks.patch
* kconfig-consolidate-config_debug_strict_user_copy_checks-fix.patch
* kconfig-menu-move-virtualization-drivers-near-other-virtualization-options.patch
* init-kconfig-make-expert-as-config-instead-of-menuconfig.patch
* uapi-remove-empty-kbuild-files.patch
* kernel-sysc-make-prctlpr_set_mm-generally-available.patch
* decompressor-add-lz4-decompressor-module.patch
* lib-add-support-for-lz4-compressed-kernel.patch
* arm-add-support-for-lz4-compressed-kernel.patch
* x86-add-support-for-lz4-compressed-kernel.patch
* lib-add-lz4-compressor-module.patch
* lib-add-lz4-compressor-module-fix.patch
* crypto-add-lz4-cryptographic-api.patch
* crypto-add-lz4-cryptographic-api-fix.patch
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
  add-a-refcount-check-in-dput.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
