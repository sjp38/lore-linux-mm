Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 64DE86B0169
	for <linux-mm@kvack.org>; Tue,  2 Aug 2011 19:58:29 -0400 (EDT)
Message-Id: <201108022357.p72NvsZM022462@imap1.linux-foundation.org>
Subject: mmotm 2011-08-02-16-19 uploaded
From: akpm@linux-foundation.org
Date: Tue, 02 Aug 2011 16:19:30 -0700
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

The mm-of-the-moment snapshot 2011-08-02-16-19 has been uploaded to

   http://userweb.kernel.org/~akpm/mmotm/

and will soon be available at
   git://zen-kernel.org/kernel/mmotm.git
or
   git://git.cmpxchg.org/linux-mmotm.git

It contains the following patches against 3.0:

origin.patch
headers_check-is-broken.patch
samples-hidraw-is-busted.patch
fault-injection-add-ability-to-export-fault_attr-in-arbitrary-directory.patch
rtc-omap-fix-initialization-of-control-register.patch
taskstats-add_del_listener-shouldnt-use-the-wrong-node.patch
taskstats-add_del_listener-should-ignore-valid-listeners.patch
ida-simplified-functions-for-id-allocation.patch
fs-dcachec-fix-new-kernel-doc-warning.patch
init-add-root=partuuid=uuid-partnroff=%d-support.patch
init-add-root=partuuid=uuid-partnroff=%d-support-update.patch
documentation-add-pointer-to-name_to_dev_t-for-root=-values.patch
ramoops-update-module-parameters.patch
mm-page_alloc-increase-__gfp_bits_shift-to-include-__gfp_other_node.patch
shm-fix-a-race-between-shm_exit-and-shm_init.patch
linux-next.patch
i-need-old-gcc.patch
arch-alpha-kernel-systblss-remove-debug-check.patch
arch-x86-platform-mrst-pmuc-needs-moduleh.patch
drivers-acpi-apei-ghesc-fix-32-bit-build.patch
mm-mempolicyc-make-copy_from_user-provably-correct.patch
floppy-use-del_timer_sync-in-init-cleanup.patch
cris-fix-a-build-error-in-kernel-forkc.patch
cris-fix-a-build-error-in-sync_serial_open.patch
cris-fix-the-prototype-of-sync_serial_ioctl.patch
cris-add-missing-declaration-of-kgdb_init-and-breakpoint.patch
lockdep-clear-whole-lockdep_map-on-initialization.patch
kernel-timec-change-jiffies_to_clock_t-input-parameters-type-to-unsigned-long.patch
thermal-hide-config_thermal_hwmon.patch
thermal-split-hwmon-lookup-to-a-separate-function.patch
thermal-make-thermal_hwmon-implementation-fully-internal.patch
acpi-remove-nid_inval.patch
acpi-add-missing-_osi-strings-resend.patch
acerhdf-add-support-for-aspire-1410-bios-v13314.patch
arch-x86-platform-iris-irisc-register-a-platform-device-and-a-platform-driver.patch
x86-fix-mmap-random-address-range.patch
leds-new-pcengines-alix-system-driver-enables-leds-via-gpio-interface.patch
leds-new-pcengines-alix-system-driver-enables-leds-via-gpio-interface-fix.patch
arch-x86-kernel-e820c-eliminate-bubble-sort-from-sanitize_e820_map.patch
tracex86-add-tracepoint-to-x86-timer-interrupt-handler.patch
tracex86-add-x86-irq-vector-entry-exit-tracepoints.patch
arch-arm-mach-ux500-mbox-db5500c-world-writable-sysfs-fifo-file.patch
arm-exec-remove-redundant-set_fsuser_ds.patch
audit-always-follow-va_copy-with-va_end.patch
btrfs-dont-dereference-extent_mapping-if-null.patch
drivers-block-drbd-drbd_nlc-use-bitmap_parse-instead-of-__bitmap_parse.patch
drivers-base-regmap-regmapc-just-send-the-buffer-directly-for-single-register-writes.patch
drm-vmwgfx-use-ida_simple_get-for-id-allocation.patch
fb-fix-potential-deadlock-between-lock_fb_info-and-console_lock.patch
cyber2000fb-avoid-palette-corruption-at-higher-clocks.patch
hwmon-convert-idr-to-ida-and-use-ida_simple-interface.patch
drivers-hwmon-hwmonc-convert-idr-to-ida-and-use-ida_simple_get.patch
genirq-fix-missing-parenthesises-in-generic-chip.patch
ia64-exec-remove-redundant-set_fsuser_ds.patch
unicore32-exec-remove-redundant-set_fsuser_ds.patch
drivers-video-backlight-aat2870_blc-fix-error-checking-for-backlight_device_register.patch
drivers-video-backlight-aat2870_blc-fix-setting-max_current.patch
drivers-video-backlight-aat2870_blc-make-it-buildable-as-a-module.patch
i915-add-native-backlight-control.patch
btusb-patch-add_apple_macbookpro62.patch
debugobjects-extend-debugobjects-to-assert-that-an-object-is-initialized.patch
kernel-timerc-use-debugobjects-to-catch-deletion-of-uninitialized-timers.patch
ext4-use-proper-little-endian-bitops.patch
ocfs2-avoid-unaligned-access-to-dqc_bitmap.patch
parisc-exec-remove-redundant-set_fsuser_ds.patch
pci-dmar-update-dmar-units-devices-list-during-hotplug.patch
drivers-firmware-dmi_scanc-make-dmi_name_in_vendors-more-focused.patch
s390-exec-remove-redundant-set_fsuser_ds.patch
scsi-fix-a-header-to-include-linux-typesh.patch
drivers-scsi-megaraidc-fix-sparse-warnings.patch
drivers-scsi-aacraid-commctrlc-fix-mem-leak-in-aac_send_raw_srb.patch
drivers-scsi-sdc-use-ida_simple_get-and-ida_simple_remove-in-place-of-boilerplate-code.patch
drivers-scsi-osd-osd_uldc-use-ida_simple_get-to-handle-id.patch
drivers-scsi-sgc-convert-to-kstrtoul_from_user.patch
drivers-block-brdc-make-brd_make_request-return-error-code.patch
block-genhdc-remove-useless-cast-in-diskstats_show.patch
drivers-cdrom-cdromc-relax-check-on-dvd-manufacturer-value.patch
drivers-block-loopc-emit-uevent-on-auto-release.patch
sparc-exec-remove-redundant-addr_limit-assignment.patch
drivers-staging-speakup-devsynthc-fix-buffer-size-is-not-provably-correct-error.patch
drivers-staging-solo6x10-corec-needs-slabh.patch
drivers-staging-solo6x10-p2mc-needs-slabh.patch
staging-more-missing-slabh-inclusions.patch
mm.patch
cross-memory-attach-v3.patch
cross-memory-attach-update.patch
mm-compaction-trivial-clean-up-in-acct_isolated.patch
mm-change-isolate-mode-from-define-to-bitwise-type.patch
mm-compaction-make-isolate_lru_page-filter-aware.patch
mm-zone_reclaim-make-isolate_lru_page-filter-aware.patch
mm-migration-clean-up-unmap_and_move.patch
radix_tree-clean-away-saw_unset_tag-leftovers.patch
vmscan-add-block-plug-for-page-reclaim.patch
mm-page-writebackc-make-determine_dirtyable_memory-static-again.patch
oom-avoid-killing-kthreads-if-they-assume-the-oom-killed-threads-mm.patch
radix_tree-exceptional-entries-and-indices.patch
mm-let-swap-use-exceptional-entries.patch
tmpfs-demolish-old-swap-vector-support.patch
tmpfs-miscellaneous-trivial-cleanups.patch
tmpfs-copy-truncate_inode_pages_range.patch
tmpfs-convert-shmem_truncate_range-to-radix-swap.patch
tmpfs-convert-shmem_unuse_inode-to-radix-swap.patch
tmpfs-convert-shmem_getpage_gfp-to-radix-swap.patch
tmpfs-convert-mem_cgroup-shmem-to-radix-swap.patch
tmpfs-convert-shmem_writepage-and-enable-swap.patch
tmpfs-use-kmemdup-for-short-symlinks.patch
mm-a-few-small-updates-for-radix-swap.patch
mm-a-few-small-updates-for-radix-swap-fix.patch
tmpfs-radix_tree-locate_item-to-speed-up-swapoff.patch
mm-clarify-the-radix_tree-exceptional-cases.patch
tmpfs-expand-help-to-explain-value-of-tmpfs_posix_acl.patch
tmpfs-expand-help-to-explain-value-of-tmpfs_posix_acl-v3.patch
selinuxfs-remove-custome-hex_to_bin.patch
frv-duplicate-output_buffer-of-e03.patch
frv-duplicate-output_buffer-of-e03-checkpatch-fixes.patch
hpet-factor-timer-allocate-from-open.patch
intel_idle-fix-api-misuse.patch
intel_idle-disable-auto_demotion-for-hotplugged-cpus.patch
kprobes-silence-debug_strict_user_copy_checks=y-warning.patch
x86-implement-strict-user-copy-checks-for-x86_64.patch
consolidate-config_debug_strict_user_copy_checks.patch
consolidate-config_debug_strict_user_copy_checks-fix.patch
lis3lv02d-avoid-divide-by-zero-due-to-unchecked.patch
lis3-update-maintainer-information.patch
lis3-add-support-for-hp-elitebook-2730p.patch
lis3-add-support-for-hp-elitebook-8540w.patch
hp_accel-add-hp-probook-655x.patch
config_hp_accel-fix-help-text.patch
lis3-free-regulators-if-probe-fails.patch
lis3-change-naming-to-consistent.patch
lis3-change-exported-function-to-use-given.patch
lis3-remove-the-references-to-the-global-variable-in-core-driver.patch
fcntlf_setfl-allow-setting-of-o_sync.patch
leds-renesas-tpu-led-driver-v2.patch
leds-route-kbd-leds-through-the-generic-leds-layer.patch
leds-route-kbd-leds-through-the-generic-leds-layer-fix.patch
lib-crc-add-slice-by-8-algorithm-to-crc32c.patch
lib-crc-add-slice-by-8-algorithm-to-crc32c-fix.patch
lib-hexdumpc-make-hex2bin-return-the-updated-src-address.patch
fs-binfmt_miscc-use-kernels-hex_to_bin-method.patch
fs-binfmt_miscc-use-kernels-hex_to_bin-method-fix.patch
fs-binfmt_miscc-use-kernels-hex_to_bin-method-fix-fix.patch
drivers-rtc-classc-convert-idr-to-ida-and-use-ida_simple_get.patch
minix-describe-usage-of-different-magic-numbers.patch
memcg-do-not-expose-uninitialized-mem_cgroup_per_node-to-world.patch
ipc-introduce-shm_rmid_forced-sysctl-testing.patch
sysctl-add-proc_dointvec_bool-handler.patch
sysctl-use-proc_dointvec_bool-where-appropriate.patch
sysctl-add-proc_dointvec_unsigned-handler.patch
sysctl-add-proc_dointvec_unsigned-handler-update.patch
sysctl-use-proc_dointvec_unsigned-where-appropriate.patch
pps-default-echo-function.patch
pps-new-client-driver-using-gpio.patch
pps-new-client-driver-using-gpio-fix.patch
scatterlist-new-helper-functions.patch
scatterlist-new-helper-functions-update.patch
scatterlist-new-helper-functions-update-fix.patch
memstick-add-support-for-legacy-memorysticks.patch
memstick-add-support-for-legacy-memorysticks-fix.patch
memstick-add-support-for-legacy-memorysticks-update-2.patch
w1-ds2760-and-ds2780-use-ida-for-id-and-ida_simple_get-to-get-it.patch
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
