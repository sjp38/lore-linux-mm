Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A667A6B0012
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 20:34:08 -0400 (EDT)
Message-Id: <201106160034.p5G0Y4dr028904@imap1.linux-foundation.org>
Subject: mmotm 2011-06-15-16-56 uploaded
From: akpm@linux-foundation.org
Date: Wed, 15 Jun 2011 16:56:49 -0700
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

The mm-of-the-moment snapshot 2011-06-15-16-56 has been uploaded to

   http://userweb.kernel.org/~akpm/mmotm/

and will soon be available at
   git://zen-kernel.org/kernel/mmotm.git
or
   git://git.cmpxchg.org/linux-mmotm.git

It contains the following patches against 3.0-rc3:

origin.patch
kbuild-call-depmodsh-via-shell.patch
mm-remove-khugepaged-double-thp-vmstat-update-with-config_numa=n.patch
mm-memoryc-fix-kernel-doc-notation.patch
lib-bitmapc-fix-kernel-doc-notation.patch
fs-execc-use-build_bug_on-for-vm_stack_flags-vm_stack_incomplete_setup.patch
backlight-new-driver-for-the-adp8870-backlight-devices.patch
backlight-add-backlight-type-fix.patch
vmscanmemcg-memcg-aware-swap-token.patch
vmscan-implement-swap-token-trace.patch
vmscan-implement-swap-token-priority-aging.patch
memcg-add-documentation-for-the-memorynumastat-api.patch
kmsg_dumph-fix-build-when-config_printk-is-disabled.patch
checkpatch-add-warning-for-uses-of-printk_ratelimit.patch
mm-increase-reclaim_distance-to-30.patch
drivers-misc-spear13xx_pcie_gadgetc-fix-a-memory-leak-in-spear_pcie_gadget_probe-error-path.patch
drivers-misc-cs5535-mfgptc-fix-wrong-if-condition.patch
mm-fix-wrong-kunmap_atomic-pointer.patch
mm-compaction-fix-special-case-1-order-checks.patch
mm-migratec-dont-account-swapcache-as-shmem.patch
build_bug_on_zero-fix-sparse-breakage.patch
uts-make-default-hostname-configurable-rather-than-always-using-none.patch
maintainers-balbir-has-moved.patch
drivers-leds-leds-asic3-make-leds_asic3-depend-on-leds_class.patch
leds-move-leds_gpio_register-out-of-menuconfig-new_leds.patch
maintainers-add-videobuf2-maintainers.patch
include-asm-generic-pgtableh-fix-unbalanced-parenthesis.patch
w1-w1_master_ds1wm-should-depend-on-generic_hardirqs.patch
init-calibratec-remove-annoying-printk.patch
mm-memory_hotplugc-fix-building-of-node-hotplug-zonelist.patch
mm-fix-negative-commitlimit-when-gigantic-hugepages-are-allocated.patch
leds-fix-the-menuconfig-being-wrongly-displayed.patch
mm-memorynuma_stat-fix-file-permission.patch
memcg-fix-init_page_cgroup-nid-with-sparsemem.patch
memcg-clear-mm-owner-when-last-possible-owner-leaves.patch
memcg-fix-wrong-check-of-noswap-with-softlimit.patch
memcg-fix-percpu-cached-charge-draining-frequency.patch
memcg-avoid-percpu-cached-charge-draining-at-softlimit.patch
maintainers-add-entry-for-legacy-eeprom-driver.patch
gcov-disable-config_constructors-when-not-needed-by-config_gcov_kernel.patch
mm-memory-failurec-fix-page-isolated-count-mismatch.patch
compaction-checks-correct-fragmentation-index.patch
mm-compaction-ensure-that-the-compaction-free-scanner-does-not-move-to-the-next-zone.patch
mm-vmscan-do-not-use-page_count-without-a-page-pin.patch
mm-compaction-abort-compaction-if-too-many-pages-are-isolated-and-caller-is-asynchronous-v2.patch
documentation-feature-removal-scheduletxt-remove-ns_cgroup-from-feature-removal-scheduletxt.patch
drivers-char-hpetc-fix-periodic-emulation-for-delayed-interrupts.patch
drivers-tty-serial-pch_uartc-dont-oops-if-dmi_get_system_info-returns-null.patch
rtc-fix-build-warnings-in-defconfigs.patch
ksm-fix-null-pointer-dereference-in-scan_get_next_rmap_item.patch
drivers-misc-apds990xc-apds990x_chip_on-should-depend-on-config_pm-config_pm_runtime.patch
alpha-fix-several-security-issues.patch
mm-move-vmtruncate_range-to-truncatec.patch
mm-move-shmem-prototypes-to-shmem_fsh.patch
tmpfs-take-control-of-its-truncate_range.patch
tmpfs-add-shmem_read_mapping_page_gfp.patch
drm-ttm-use-shmem_read_mapping_page.patch
drm-i915-use-shmem_read_mapping_page.patch
drm-i915-use-shmem_truncate_range.patch
drm-i915-more-struct_mutex-locking.patch
drm-i915-more-struct_mutex-locking-fix.patch
mm-cleanup-descriptions-of-filler-arg.patch
mm-truncate-functions-are-in-truncatec.patch
mm-tidy-vmtruncate_range-and-related-functions.patch
mm-consistent-truncate-and-invalidate-loops.patch
mm-pincer-in-truncate_inode_pages_range.patch
tmpfs-no-need-to-use-i_lock.patch
mm-nommuc-fix-remap_pfn_range.patch
linux-next.patch
next-remove-localversion.patch
i-need-old-gcc.patch
arch-alpha-kernel-systblss-remove-debug-check.patch
bdi_min_ratio-never-shrinks-ultimately-preventing-valid-setting-of-min_ratio.patch
cris-fix-a-build-error-in-kernel-forkc.patch
cris-fix-a-build-error-in-kernel-forkc-checkpatch-fixes.patch
cris-fix-a-build-error-in-sync_serial_open.patch
cris-fix-the-prototype-of-sync_serial_ioctl.patch
cris-add-missing-declaration-of-kgdb_init-and-breakpoint.patch
hfsplus-add-missing-call-to-bio_put.patch
drivers-scsi-pmcraid-reject-negative-request-size.patch
drivers-scsi-iprc-reorder-error-handling-code-to-include-iounmap.patch
timerfd-really-wake-up-processes-when-timer-is-cancelled-on-clock-change.patch
thermal-hide-config_thermal_hwmon.patch
thermal-split-hwmon-lookup-to-a-separate-function.patch
thermal-make-thermal_hwmon-implementation-fully-internal.patch
acerhdf-add-support-for-aspire-1410-bios-v13314.patch
arch-x86-include-asm-delayh-fix-udelay-and-ndelay-for-8-bit-args.patch
x86-fix-mmap-random-address-range.patch
leds-new-pcengines-alix-system-driver-enables-leds-via-gpio-interface.patch
arch-arm-mach-ux500-mbox-db5500c-world-writable-sysfs-fifo-file.patch
audit-always-follow-va_copy-with-va_end.patch
btrfs-dont-dereference-extent_mapping-if-null.patch
fb-fix-potential-deadlock-between-lock_fb_info-and-console_lock.patch
cyber2000fb-avoid-palette-corruption-at-higher-clocks.patch
i915-add-native-backlight-control.patch
btusb-patch-add_apple_macbookpro62.patch
pci-dmar-update-dmar-units-devices-list-during-hotplug.patch
drivers-firmware-dmi_scanc-make-dmi_name_in_vendors-more-focused.patch
pci-enumerate-the-pci-device-only-removed-out-pci-hierarchy-of-os-when-re-scanning-pci.patch
pci-enumerate-the-pci-device-only-removed-out-pci-hierarchy-of-os-when-re-scanning-pci-fix.patch
scsi-fix-a-header-to-include-linux-typesh.patch
drivers-scsi-megaraidc-fix-sparse-warnings.patch
drivers-block-brdc-make-brd_make_request-return-error-code.patch
staging-iio-make-iio-depend-on-generic_hardirqs.patch
drivers-staging-speakup-devsynthc-fix-buffer-size-is-not-provably-correct-error.patch
drivers-staging-gma500-psb_intel_displayc-fix-build.patch
drivers-staging-dt3155v4l-dt3155v4lc-needs-slabh.patch
drivers-staging-solo6x10-corec-needs-slabh.patch
drivers-staging-solo6x10-p2mc-needs-slabh.patch
staging-more-missing-slabh-inclusions.patch
slab-use-numa_no_node.patch
mm.patch
mm-extend-memory-hotplug-api-to-allow-memory-hotplug-in-virtual-machines.patch
mm-extend-memory-hotplug-api-to-allow-memory-hotplug-in-virtual-machines-fix.patch
xen-balloon-memory-hotplug-support-for-xen-balloon-driver.patch
mm-swap-token-fix-dead-link.patch
mm-swap-token-makes-global-variables-to-function-local.patch
mm-swap-token-add-a-comment-for-priority-aging.patch
pagewalk-fix-walk_page_range-dont-check-find_vma-result-properly.patch
pagewalk-dont-look-up-vma-if-walk-hugetlb_entry-is-unused.patch
pagewalk-add-locking-rule-comments.patch
pagewalk-add-locking-rule-comments-fix.patch
pagewalk-fix-code-comment-for-thp.patch
mm-dmapool-fix-possible-use-after-free-in-dmam_pool_destroy.patch
mm-remove-the-leftovers-of-noswapaccount.patch
frv-hook-up-gpiolib-support.patch
frv-duplicate-output_buffer-of-e03.patch
frv-duplicate-output_buffer-of-e03-checkpatch-fixes.patch
hpet-factor-timer-allocate-from-open.patch
intel_idle-fix-api-misuse.patch
intel_idle-disable-auto_demotion-for-hotplugged-cpus.patch
cris-fix-some-build-warnings-in-pinmuxc.patch
drivers-use-kzalloc-kcalloc-instead-of-kmallocmemset-where-possible.patch
asm-generic-systemh-drop-useless-__kernel__.patch
lpfc-silence-debug_strict_user_copy_checks=y-warning.patch
kprobes-silence-debug_strict_user_copy_checks=y-warning.patch
x86-implement-strict-user-copy-checks-for-x86_64.patch
consolidate-config_debug_strict_user_copy_checks.patch
fcntlf_setfl-allow-setting-of-o_sync.patch
leds-route-kbd-leds-through-the-generic-leds-layer.patch
checkpatch-suggest-using-min_t-or-max_t-v2.patch
checkpatch-add-__rcu-as-a-sparse-modifier.patch
misc-eeprom-add-driver-for-microwire-93xx46-eeproms.patch
misc-eeprom-add-eeprom-access-driver-for-digsy_mtc-board.patch
lib-hexdumpc-make-hex2bin-return-the-updated-src-address.patch
fs-binfmt_miscc-use-kernels-hex_to_bin-method.patch
fs-binfmt_miscc-use-kernels-hex_to_bin-method-fix.patch
fs-binfmt_miscc-use-kernels-hex_to_bin-method-fix-fix.patch
init-skip-calibration-delay-if-previously-done.patch
init-skip-calibration-delay-if-previously-done-fix.patch
init-skip-calibration-delay-if-previously-done-fix-fix.patch
init-skip-calibration-delay-if-previously-done-fix-fix-fix.patch
init-calibratec-calibrate_delay-tidy-up-the-pr_info-messages.patch
drivers-rtc-rtc-mpc5121c-add-support-for-rtc-on-mpc5200.patch
drivers-rtc-add-support-for-qualcomm-pmic8xxx-rtc.patch
drivers-rtc-add-support-for-qualcomm-pmic8xxx-rtc-fix.patch
drivers-rtc-rtc-ds1307c-add-support-for-the-pt7c4338-rtc-device.patch
memcg-do-not-expose-uninitialized-mem_cgroup_per_node-to-world.patch
cpusets-randomize-node-rotor-used-in-cpuset_mem_spread_node.patch
cpusets-randomize-node-rotor-used-in-cpuset_mem_spread_node-fix-2.patch
cpusets-randomize-node-rotor-used-in-cpuset_mem_spread_node-cpusets-initialize-spread-rotor-lazily.patch
cpusets-randomize-node-rotor-used-in-cpuset_mem_spread_node-cpusets-initialize-spread-rotor-lazily-fix.patch
ptrace-unify-show_regs-prototype.patch
ptrace-unify-show_regs-prototype-fix.patch
kernel-forkc-fix-a-few-coding-style-issues.patch
cpumask-convert-for_each_cpumask-with-for_each_cpu.patch
cpumask-alloc_cpumask_var-use-numa_no_node.patch
cpumask-add-cpumask_var_t-documentation.patch
sysctl-add-proc_dointvec_bool-handler.patch
sysctl-use-proc_dointvec_bool-where-appropriate.patch
sysctl-add-proc_dointvec_unsigned-handler.patch
sysctl-add-proc_dointvec_unsigned-handler-update.patch
sysctl-use-proc_dointvec_unsigned-where-appropriate.patch
scatterlist-new-helper-functions.patch
scatterlist-new-helper-functions-update.patch
scatterlist-new-helper-functions-update-fix.patch
memstick-add-support-for-legacy-memorysticks.patch
memstick-add-support-for-legacy-memorysticks-update-2.patch
kexec-remove-kmsg_dump_kexec.patch
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
memblock-add-input-size-checking-to-memblock_find_region.patch
memblock-add-input-size-checking-to-memblock_find_region-fix.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
