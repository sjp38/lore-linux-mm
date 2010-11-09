Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6FAC26B004A
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 19:03:28 -0500 (EST)
Message-Id: <201011100003.oAA03O3c015222@imap1.linux-foundation.org>
Subject: mmotm 2010-11-09-15-31 uploaded
From: akpm@linux-foundation.org
Date: Tue, 09 Nov 2010 15:31:15 -0800
Sender: owner-linux-mm@kvack.org
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The mm-of-the-moment snapshot 2010-11-09-15-31 has been uploaded to

   http://userweb.kernel.org/~akpm/mmotm/

and will soon be available at

   git://zen-kernel.org/kernel/mmotm.git

It contains the following patches against 2.6.37-rc1:

origin.patch
hpet-factor-timer-allocate-from-open.patch
um-fix-ptrace-build-error.patch
include-linux-fsh-needs-typesh.patch
drivers-macintosh-adb-iopc-flags-should-be-unsigned-long.patch
rapidio-use-resource_size.patch
scripts-kernel-doc-escape-special-characters-for-xml-struct-output.patch
include-linux-resourceh-needs-typesh.patch
atomic-add-atomic_inc_not_zero_hint.patch
atomic-add-atomic_inc_not_zero_hint-checkpatch-fixes.patch
linux-next.patch
next-remove-localversion.patch
arch-x86-kernel-entry_64s-fix-build-with-gas-2161.patch
arch-x86-kernel-entry_32s-i386-too.patch
i-need-old-gcc.patch
arch-alpha-kernel-systblss-remove-debug-check.patch
drivers-misc-isl29020c-fix-signedness-bug.patch
drivers-misc-isl29020c-dont-ignore-the-i2c_smbus_read_byte_data-return-value.patch
drivers-misc-apds9802alsc-fix-signedness-bug.patch
memcg-null-dereference-on-allocation-failure.patch
drivers-misc-bh1770glcc-error-handling-in-bh1770_power_state_store.patch
fuse-clear-attribute-cache-for-openo_trunc.patch
kernel-range-fix-clean_sort_range-for-the-case-of-full-array.patch
mm-vfs-revalidate-page-mapping-in-do_generic_file_read.patch
latencytop-fix-per-task-accumulator.patch
mm-vmap-area-cache.patch
arch-arm-plat-omap-iovmmc-fix-end-address-of-vm-area-comparation-in-alloc_iovm_area.patch
backlight-fix-88pm860x_bl-macro-collision.patch
cciss-fix-botched-tag-masking-for-scsi-tape-commands.patch
ibm_rtl-fix-printk-format-warning.patch
arch-x86-kernel-apic-io_apicc-fix-warning.patch
fs-btrfs-inodec-eliminate-memory-leak.patch
btrfs-dont-dereference-extent_mapping-if-null.patch
cpufreq-fix-ondemand-governor-powersave_bias-execution-time-misuse.patch
drivers-dma-use-the-ccflag-y-instead-of-extra_cflags.patch
drivers-dma-ioat-use-the-ccflag-y-instead-of-extra_cflags.patch
powerpc-enable-arch_dma_addr_t_64bit-with-arch_phys_addr_t_64bit.patch
debugfs-remove-module_exit.patch
drivers-gpu-drm-radeon-atomc-fix-warning.patch
drivers-media-video-gspca-cpia1c-fix-error-check.patch
ecryptfs-fix-truncation-error-in-ecryptfs_read_update_atime.patch
irq-use-per_cpu-kstat_irqs.patch
irq-use-per_cpu-kstat_irqs-checkpatch-fixes.patch
leds-route-kbd-leds-through-the-generic-leds-layer.patch
led-class-always-implement-blinking.patch
leds-driver-for-national-semiconductor-lp5521-chip.patch
leds-driver-for-national-semiconductors-lp5523-chip.patch
leds-update-lp552x-support-kconfig-and-makefile.patch
documentation-led-drivers-lp5521-and-lp5523.patch
leds-add-led-trigger-for-input-subsystem-led-events.patch
gpio-led-properly-initialize-return-value.patch
mips-enable-arch_dma_addr_t_64bit-with-highmem-64bit_phys_addr-64bit.patch
isdn-capi-unregister-capictr-notifier-after-init-failure.patch
isdn-capi-make-kcapi-use-a-separate-workqueue.patch
net-avoid-limits-overflow.patch
drivers-video-backlight-s6e63m0c-set-permissions-on-gamma_table-file-to-0444.patch
backlight-fix-blanking-for-lms283gf05-lcd.patch
backlight-fix-blanking-for-l4f00242t03-lcd.patch
backlight-s6e63m0-unregister-backlight-device-and-remove-sysfs-attribute-file-in-s6e63m0_remove.patch
backlight-s6e63m0-fix-section-mismatch.patch
backlight-add-low-threshold-to-pwm-backlight.patch
video-backlight-adp8860-fix-ambient-light-zone-overwrite-handling.patch
drivers-video-backlight-adp8860_blc-check-strict_strtoul-return-value.patch
btusb-patch-add_apple_macbookpro62.patch
drivers-char-amiserialc-remove-unused-variable-icount.patch
atmel_serial-fix-rts-high-after-initialization-in-rs485-mode.patch
atmel_serial-fix-rts-high-after-initialization-in-rs485-mode-fix.patch
drivers-message-fusion-mptsasc-fix-warning.patch
hpsa-remove-incorrect-redefinition-of-pci_device_id_hp_cissf.patch
drivers-block-makefile-replace-the-use-of-module-objs-with-module-y.patch
drivers-block-aoe-makefile-replace-the-use-of-module-objs-with-module-y.patch
vfs-remove-a-warning-on-open_fmode.patch
vfs-add-__fmode_exec.patch
n_hdlc-fix-read-and-write-locking.patch
n_hdlc-fix-read-and-write-locking-update.patch
mm.patch
mm-smaps-export-mlock-information.patch
mm-page-allocator-adjust-the-per-cpu-counter-threshold-when-memory-is-low.patch
mm-vmstat-use-a-single-setter-function-and-callback-for-adjusting-percpu-thresholds.patch
mm-vmstat-use-a-single-setter-function-and-callback-for-adjusting-percpu-thresholds-fix.patch
mm-mempolicyc-add-rcu-read-lock-to-protect-pid-structure.patch
mm-convert-sprintf_symbol-to-%ps.patch
writeback-integrated-background-writeback-work.patch
writeback-trace-wakeup-event-for-background-writeback.patch
writeback-stop-background-kupdate-works-from-livelocking-other-works.patch
writeback-avoid-livelocking-wb_sync_all-writeback.patch
writeback-check-skipped-pages-on-wb_sync_all.patch
sync_inode_metadata-fix-comment.patch
define-madv_hugepage.patch
frv-duplicate-output_buffer-of-e03.patch
frv-duplicate-output_buffer-of-e03-checkpatch-fixes.patch
add-the-common-dma_addr_t-typedef-to-include-linux-typesh.patch
scripts-get_maintainerpl-make-rolestats-the-default.patch
scripts-get_maintainerpl-use-git-fallback-more-often.patch
maintainers-intel-gfx-is-a-subscribers-only-mailing-list.patch
percpucounter-optimize-__percpu_counter_add-a-bit-through-the-use-of-this_cpu-operations.patch
drivers-mmc-host-omapc-use-resource_size.patch
drivers-mmc-host-omap_hsmmcc-use-resource_size.patch
epoll-convert-max_user_watches-to-long.patch
binfmt_elf-cleanups.patch
rtc-add-real-time-clock-driver-for-nvidia-tegra.patch
cyber2000fb-avoid-palette-corruption-at-higher-clocks.patch
jbd-remove-dependency-on-__gfp_nofail.patch
memcg-add-page_cgroup-flags-for-dirty-page-tracking.patch
memcg-document-cgroup-dirty-memory-interfaces.patch
memcg-document-cgroup-dirty-memory-interfaces-fix.patch
memcg-create-extensible-page-stat-update-routines.patch
memcg-add-lock-to-synchronize-page-accounting-and-migration.patch
writeback-create-dirty_info-structure.patch
memcg-add-dirty-page-accounting-infrastructure.patch
memcg-add-kernel-calls-for-memcg-dirty-page-stats.patch
memcg-add-dirty-limits-to-mem_cgroup.patch
memcg-add-dirty-limits-to-mem_cgroup-use-native-word-to-represent-dirtyable-pages.patch
memcg-add-dirty-limits-to-mem_cgroup-catch-negative-per-cpu-sums-in-dirty-info.patch
memcg-add-dirty-limits-to-mem_cgroup-avoid-overflow-in-memcg_hierarchical_free_pages.patch
memcg-add-dirty-limits-to-mem_cgroup-correct-memcg_hierarchical_free_pages-return-type.patch
memcg-add-dirty-limits-to-mem_cgroup-avoid-free-overflow-in-memcg_hierarchical_free_pages.patch
memcg-cpu-hotplug-lockdep-warning-fix.patch
memcg-add-cgroupfs-interface-to-memcg-dirty-limits.patch
memcg-break-out-event-counters-from-other-stats.patch
memcg-check-memcg-dirty-limits-in-page-writeback.patch
memcg-use-native-word-page-statistics-counters.patch
memcg-use-native-word-page-statistics-counters-fix.patch
memcg-add-mem_cgroup-parameter-to-mem_cgroup_page_stat.patch
memcg-pass-mem_cgroup-to-mem_cgroup_dirty_info.patch
memcg-make-throttle_vm_writeout-memcg-aware.patch
memcg-make-throttle_vm_writeout-memcg-aware-fix.patch
memcg-simplify-mem_cgroup_page_stat.patch
memcg-simplify-mem_cgroup_dirty_info.patch
memcg-make-mem_cgroup_page_stat-return-value-unsigned.patch
memcg-use-zalloc-rather-than-mallocmemset.patch
fs-proc-basec-kernel-latencytopc-convert-sprintf_symbol-to-%ps.patch
fs-proc-basec-kernel-latencytopc-convert-sprintf_symbol-to-%ps-checkpatch-fixes.patch
drivers-char-nozomic-fix-unused-variable-compiler-warning.patch
rapidio-use-common-destid-storage-for-endpoints-and-switches.patch
rapidio-integrate-rio_switch-into-rio_dev.patch
fs-execc-provide-the-correct-process-pid-to-the-pipe-helper.patch
nfc-driver-for-nxp-semiconductors-pn544-nfc-chip.patch
nfc-driver-for-nxp-semiconductors-pn544-nfc-chip-update.patch
remove-dma64_addr_t.patch
pps-trivial-fixes.patch
pps-declare-variables-where-they-are-used-in-switch.patch
pps-fix-race-in-pps_fetch-handler.patch
pps-unify-timestamp-gathering.patch
pps-access-pps-device-by-direct-pointer.patch
pps-convert-printk-pr_-to-dev_.patch
pps-move-idr-stuff-to-ppsc.patch
pps-add-async-pps-event-handler.patch
pps-add-async-pps-event-handler-fix.patch
pps-dont-disable-interrupts-when-using-spin-locks.patch
pps-use-bug_on-for-kernel-api-safety-checks.patch
pps-simplify-conditions-a-bit.patch
ntp-add-hardpps-implementation.patch
pps-capture-monotonic_raw-timestamps-as-well.patch
pps-add-kernel-consumer-support.patch
pps-add-parallel-port-pps-client.patch
pps-add-parallel-port-pps-signal-generator.patch
memstick-a-few-changes-to-core.patch
memstick-add-support-for-legacy-memorysticks.patch
memstick-add-driver-for-ricoh-r5c592-card-reader.patch
memstick-add-driver-for-ricoh-r5c592-card-reader-fix.patch
memstick-core-fix-device_register-error-handling.patch
w1-ds2423-counter-driver-and-documentation.patch
make-sure-nobodys-leaking-resources.patch
journal_add_journal_head-debug.patch
releasing-resources-with-children.patch
make-frame_pointer-default=y.patch
mutex-subsystem-synchro-test-module.patch
mutex-subsystem-synchro-test-module-add-missing-header-file.patch
slab-leaks3-default-y.patch
put_bh-debug.patch
add-debugging-aid-for-memory-initialisation-problems.patch
workaround-for-a-pci-restoring-bug.patch
prio_tree-debugging-patch.patch
single_open-seq_release-leak-diagnostics.patch
add-a-refcount-check-in-dput.patch
getblk-handle-2tb-devices.patch
memblock-add-input-size-checking-to-memblock_find_region.patch
memblock-add-input-size-checking-to-memblock_find_region-fix.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
