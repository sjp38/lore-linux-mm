Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5E81D6B004A
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 20:35:54 -0500 (EST)
Message-Id: <201011180135.oAI1Znl3017273@imap1.linux-foundation.org>
Subject: mmotm 2010-11-17-17-03 uploaded
From: akpm@linux-foundation.org
Date: Wed, 17 Nov 2010 17:03:30 -0800
Sender: owner-linux-mm@kvack.org
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The mm-of-the-moment snapshot 2010-11-17-17-03 has been uploaded to

   http://userweb.kernel.org/~akpm/mmotm/

and will soon be available at

   git://zen-kernel.org/kernel/mmotm.git

It contains the following patches against 2.6.37-rc2:

origin.patch
hpet-factor-timer-allocate-from-open.patch
leds-fix-bug-with-reading-nas-ss4200-dmi-code.patch
include-linux-fsh-fix-userspace-build.patch
nommu-yield-cpu-while-disposing-vm.patch
linux-next.patch
next-remove-localversion.patch
i-need-old-gcc.patch
aesni-nfg.patch
arch-alpha-kernel-systblss-remove-debug-check.patch
sgi-xpc-xpc-fails-to-discover-partitions-with-all-nasids-above-128.patch
fuse-fix-attributes-after-openo_trunc.patch
drivers-leds-leds-lp5521c-change-some-macros-to-functions.patch
drivers-leds-leds-lp5523c-change-some-macros-to-functions.patch
drivers-leds-leds-lp5521c-adjust-delays-and-add-comments-to-them.patch
drivers-leds-leds-lp5523c-adjust-delays-and-add-comments-to-them.patch
drivers-leds-leds-lp5521c-perform-sw-reset-before-detection.patch
drivers-leds-leds-lp5523c-perform-sw-reset-before-detection.patch
memcg-avoid-deadlock-between-move-charge-and-try_charge.patch
cgroups-make-swap-accounting-default-behavior-configurable.patch
mm-vmap-area-cache.patch
arch-arm-plat-omap-iovmmc-fix-end-address-of-vm-area-comparation-in-alloc_iovm_area.patch
backlight-fix-88pm860x_bl-macro-collision.patch
cciss-fix-botched-tag-masking-for-scsi-tape-commands.patch
arch-x86-kernel-entry_32s-work-around-gas-2161-glitch.patch
arch-x86-kernel-entry_64s-fix-build-with-gas-2161.patch
arch-x86-kernel-entry_32s-i386-too.patch
arch-x86-include-asm-fixmaph-mark-__set_fixmap_offset-as-__always_inline.patch
ibm_rtl-fix-printk-format-warning.patch
acerhdf-add-support-for-aspire-1410-bios-v13314.patch
arch-x86-kernel-apic-io_apicc-fix-warning.patch
fs-btrfs-inodec-eliminate-memory-leak.patch
btrfs-dont-dereference-extent_mapping-if-null.patch
cifs-dont-overwrite-dentry-name-in-d_revalidate.patch
cpufreq-fix-ondemand-governor-powersave_bias-execution-time-misuse.patch
drivers-dma-use-the-ccflag-y-instead-of-extra_cflags.patch
drivers-dma-ioat-use-the-ccflag-y-instead-of-extra_cflags.patch
jfs-dont-overwrite-dentry-name-in-d_revalidate.patch
powerpc-enable-arch_dma_addr_t_64bit-with-arch_phys_addr_t_64bit.patch
debugfs-remove-module_exit.patch
drivers-gpu-drm-radeon-atomc-fix-warning.patch
drivers-media-video-gspca-cpia1c-fix-error-check.patch
irq-use-per_cpu-kstat_irqs.patch
irq-use-per_cpu-kstat_irqs-checkpatch-fixes.patch
leds-route-kbd-leds-through-the-generic-leds-layer.patch
mips-enable-arch_dma_addr_t_64bit-with-highmem-64bit_phys_addr-64bit.patch
isdn-capi-unregister-capictr-notifier-after-init-failure.patch
isdn-capi-make-kcapi-use-a-separate-workqueue.patch
drivers-video-backlight-l4f00242t03c-full-implement-fb-power-states-for-this-lcd.patch
btusb-patch-add_apple_macbookpro62.patch
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
mm-page-allocator-adjust-the-per-cpu-counter-threshold-when-memory-is-low.patch
mm-vmstat-use-a-single-setter-function-and-callback-for-adjusting-percpu-thresholds.patch
mm-vmstat-use-a-single-setter-function-and-callback-for-adjusting-percpu-thresholds-fix.patch
mm-vmstat-use-a-single-setter-function-and-callback-for-adjusting-percpu-thresholds-update.patch
mm-mempolicyc-add-rcu-read-lock-to-protect-pid-structure.patch
writeback-integrated-background-writeback-work.patch
writeback-trace-wakeup-event-for-background-writeback.patch
writeback-stop-background-kupdate-works-from-livelocking-other-works.patch
writeback-stop-background-kupdate-works-from-livelocking-other-works-update.patch
writeback-avoid-livelocking-wb_sync_all-writeback.patch
writeback-avoid-livelocking-wb_sync_all-writeback-update.patch
writeback-check-skipped-pages-on-wb_sync_all.patch
writeback-check-skipped-pages-on-wb_sync_all-update.patch
writeback-check-skipped-pages-on-wb_sync_all-update-fix.patch
writeback-io-less-balance_dirty_pages.patch
writeback-consolidate-variable-names-in-balance_dirty_pages.patch
writeback-per-task-rate-limit-on-balance_dirty_pages.patch
writeback-per-task-rate-limit-on-balance_dirty_pages-fix.patch
writeback-prevent-duplicate-balance_dirty_pages_ratelimited-calls.patch
writeback-account-per-bdi-accumulated-written-pages.patch
writeback-bdi-write-bandwidth-estimation.patch
writeback-show-bdi-write-bandwidth-in-debugfs.patch
writeback-quit-throttling-when-bdi-dirty-pages-dropped-low.patch
writeback-reduce-per-bdi-dirty-threshold-ramp-up-time.patch
writeback-make-reasonable-gap-between-the-dirty-background-thresholds.patch
writeback-scale-down-max-throttle-bandwidth-on-concurrent-dirtiers.patch
writeback-add-trace-event-for-balance_dirty_pages.patch
writeback-make-nr_to_write-a-per-file-limit.patch
writeback-make-nr_to_write-a-per-file-limit-fix.patch
sync_inode_metadata-fix-comment.patch
mm-page-writebackc-fix-__set_page_dirty_no_writeback-return-value.patch
vmscan-factor-out-kswapd-sleeping-logic-from-kswapd.patch
mm-find_get_pages_contig-fixlet.patch
fs-mpagec-consolidate-code.patch
fs-mpagec-consolidate-code-checkpatch-fixes.patch
mm-convert-sprintf_symbol-to-%ps.patch
mm-smaps-export-mlock-information.patch
define-madv_hugepage.patch
frv-duplicate-output_buffer-of-e03.patch
frv-duplicate-output_buffer-of-e03-checkpatch-fixes.patch
kernel-power-changed-makefile-to-use-proper-ccflag-flag.patch
um-mark-config_highmem-as-broken.patch
kmsg_dump-constrain-mtdoops-and-ramoops-to-perform-their-actions-only-for-kmsg_dump_panic.patch
kmsg_dump-add-kmsg_dump-calls-to-the-reboot-halt-poweroff-and-emergency_restart-paths.patch
add-the-common-dma_addr_t-typedef-to-include-linux-typesh.patch
scripts-get_maintainerpl-make-rolestats-the-default.patch
scripts-get_maintainerpl-use-git-fallback-more-often.patch
maintainers-intel-gfx-is-a-subscribers-only-mailing-list.patch
lib-add-generic-exponentially-weighted-moving-average-ewma-function.patch
lib-add-generic-exponentially-weighted-moving-average-ewma-function-fix.patch
percpucounter-optimize-__percpu_counter_add-a-bit-through-the-use-of-this_cpu-operations.patch
drivers-mmc-host-omapc-use-resource_size.patch
drivers-mmc-host-omap_hsmmcc-use-resource_size.patch
scripts-checkpatchpl-add-check-for-multiple-terminating-semicolons-and-casts-of-vmalloc.patch
fs-select-fix-information-leak-to-userspace.patch
fs-select-fix-information-leak-to-userspace-fix.patch
epoll-convert-max_user_watches-to-long.patch
binfmt_elf-cleanups.patch
drivers-rtc-rtc-omapc-fix-a-memory-leak.patch
rtc-add-real-time-clock-driver-for-nvidia-tegra.patch
drivers-gpio-cs5535-gpioc-add-some-additional-cs5535-specific-gpio-functionality.patch
drivers-staging-olpc_dcon-convert-to-new-cs5535-gpio-api.patch
cyber2000fb-avoid-palette-corruption-at-higher-clocks.patch
jbd-remove-dependency-on-__gfp_nofail.patch
memcg-add-page_cgroup-flags-for-dirty-page-tracking.patch
memcg-document-cgroup-dirty-memory-interfaces.patch
memcg-document-cgroup-dirty-memory-interfaces-fix.patch
memcg-create-extensible-page-stat-update-routines.patch
memcg-add-lock-to-synchronize-page-accounting-and-migration.patch
memcg-use-zalloc-rather-than-mallocmemset.patch
fs-proc-basec-kernel-latencytopc-convert-sprintf_symbol-to-%ps.patch
fs-proc-basec-kernel-latencytopc-convert-sprintf_symbol-to-%ps-checkpatch-fixes.patch
exec_domain-establish-a-linux32-domain-on-config_compat-systems.patch
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
