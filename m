Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 335A06B0092
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 19:22:03 -0500 (EST)
Subject: mmotm 2011-01-25-15-47 uploaded
Message-Id: <201101260021.p0Q0LxsS016458@imap1.linux-foundation.org>
From: akpm@linux-foundation.org
Date: Tue, 25 Jan 2011 15:48:04 -0800
Sender: owner-linux-mm@kvack.org
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The mm-of-the-moment snapshot 2011-01-25-15-47 has been uploaded to

   http://userweb.kernel.org/~akpm/mmotm/

and will soon be available at

   git://zen-kernel.org/kernel/mmotm.git

It contains the following patches against 2.6.38-rc2:

origin.patch
thp-fix-paravirt-x86-32bit-nopae.patch
mm-pgtable-genericc-fix-config_swap=n-build.patch
leds-leds-pwm-return-proper-error-if-pwm_request-failed.patch
langwell_gpio-modify-eoi-handling-following-change-of-kernel-irq-subsystem.patch
parport-make-lockdep-happy-with-waitlist_lock.patch
pps-ktimer-remove-noisy-message.patch
pps-claim-parallel-port-exclusively.patch
mm-fix-deferred-congestion-timeout-if-preferred-zone-is-not-allowed.patch
mm-clear-pages_scanned-only-if-draining-a-pcp-adds-pages-to-the-buddy-allocator.patch
mm-memcontrolc-fix-uninitialized-variable-use-in-mem_cgroup_move_parent.patch
mm-compaction-dont-depend-on-hugetlb_page.patch
mm-migration-clarify-migrate_pages-comment.patch
memcg-fix-account-leak-at-failure-of-memsw-acconting.patch
memcg-bugfix-check-mem_cgroup_disabled-at-split-fixup.patch
memcg-fix-race-at-move_parent-around-compound_order.patch
atmel_tc-tcb_clksrc-fix-init-sequence.patch
radix_tree-radix_tree_gang_lookup_tag_slot-may-not-return-forever.patch
squashfs-fix-use-of-uninitialised-variable-in-zlib-xz-decompressors.patch
change-acquire-release_console_sem-to-console_lock-unlock.patch
mm-numa-aware-alloc_task_struct_node.patch
mm-numa-aware-alloc_thread_info_node.patch
kthread-numa-aware-kthread_create_on_cpu.patch
kthread-use-kthread_create_on_cpu.patch
linux-next.patch
linux-next-git-rejects.patch
next-remove-localversion.patch
i-need-old-gcc.patch
arch-alpha-kernel-systblss-remove-debug-check.patch
backlight-new-driver-for-the-adp8870-backlight-devices.patch
mm-vmap-area-cache.patch
loop-queue_lock-null-pointer-derefence-in-blk_throtl_exit-v3.patch
drivers-media-video-tlg2300-pd-videoc-fix-double-mutex_unlock-in-pd_vidioc_s_fmt.patch
scsi-include-linux-scatterlisth-to-pick-up-arch_has_sg_chain.patch
acerhdf-add-support-for-aspire-1410-bios-v13314.patch
x86-numa-add-error-handling-for-bad-cpu-to-node-mappings.patch
msm-timer-migrate-to-timer-based-__delay.patch
audit-always-follow-va_copy-with-va_end.patch
fs-btrfs-inodec-eliminate-memory-leak.patch
btrfs-dont-dereference-extent_mapping-if-null.patch
cpufreq-fix-ondemand-governor-powersave_bias-execution-time-misuse.patch
drivers-dma-ipu-ipu_irqc-irq_data-conversion.patch
debugfs-remove-module_exit.patch
drivers-gpu-drm-radeon-atomc-fix-warning.patch
cyber2000fb-avoid-palette-corruption-at-higher-clocks.patch
leds-convert-bd2802-driver-to-dev_pm_ops.patch
leds-convert-bd2802-driver-to-dev_pm_ops-fix.patch
leds-add-driver-for-lm3530-als.patch
leds-add-driver-for-lm3530-als-update.patch
leds-route-kbd-leds-through-the-generic-leds-layer.patch
mips-enable-arch_dma_addr_t_64bit-with-highmem-64bit_phys_addr-64bit.patch
backlight-add-backlight-type.patch
backlight-add-backlight-type-fix.patch
backlight-add-backlight-type-fix-fix.patch
i915-add-native-backlight-control.patch
radeon-expose-backlight-class-device-for-legacy-lvds-encoder.patch
radeon-expose-backlight-class-device-for-legacy-lvds-encoder-update.patch
nouveau-change-the-backlight-parent-device-to-the-connector-not-the-pci-dev.patch
acpi-tie-acpi-backlight-devices-to-pci-devices-if-possible.patch
mbp_nvidia_bl-remove-dmi-dependency.patch
mbp_nvidia_bl-check-that-the-backlight-control-functions.patch
mbp_nvidia_bl-rename-to-apple_bl.patch
btusb-patch-add_apple_macbookpro62.patch
tty-serial-fix-apbuart-build.patch
drivers-message-fusion-mptsasc-fix-warning.patch
scsi-fix-a-header-to-include-linux-typesh.patch
drivers-block-makefile-replace-the-use-of-module-objs-with-module-y.patch
drivers-block-aoe-makefile-replace-the-use-of-module-objs-with-module-y.patch
cciss-make-cciss_revalidate-not-loop-through-ciss_max_luns-volumes-unnecessarily.patch
loop-queue_lock-null-pointer-derefence-in-blk_throtl_exit.patch
drbd-fix-warning.patch
usb-yurex-recognize-generalkeys-wireless-presenter-as-generic-hid.patch
vfs-remove-a-warning-on-open_fmode.patch
vfs-add-__fmode_exec.patch
fs-make-block-fiemap-mapping-length-at-least-blocksize-long.patch
n_hdlc-fix-read-and-write-locking.patch
mm.patch
oom-suppress-nodes-that-are-not-allowed-from-meminfo-on-oom-kill.patch
oom-suppress-show_mem-for-many-nodes-in-irq-context-on-page-alloc-failure.patch
oom-suppress-nodes-that-are-not-allowed-from-meminfo-on-page-alloc-failure.patch
mm-notifier_from_errno-cleanup.patch
mm-add-replace_page_cache_page-function.patch
frv-duplicate-output_buffer-of-e03.patch
frv-duplicate-output_buffer-of-e03-checkpatch-fixes.patch
hpet-factor-timer-allocate-from-open.patch
arch-alpha-include-asm-ioh-s-extern-inline-static-inline.patch
uml-kernels-on-i386x86_64-produce-bad-coredumps.patch
add-the-common-dma_addr_t-typedef-to-include-linux-typesh.patch
bh1780gli-convert-to-dev-pm-ops.patch
drivers-misc-bmp085c-free-initmem-memory.patch
smp-move-smp-setup-functions-to-kernel-smpc.patch
llist-add-kconfig-option-arch_have_nmi_safe_cmpxchg.patch
llist-lib-add-lock-less-null-terminated-single-list.patch
llist-irq_work-use-llist-in-irq_work.patch
llist-net-rds-replace-xlist-in-net-rds-xlisth-with-llist.patch
net-convert-%p-usage-to-%pk.patch
vsprintf-neaten-%pk-kptr_restrict-save-a-bit-of-code-space.patch
console-allow-to-retain-boot-console-via-boot-option-keep_bootcon.patch
console-prevent-registered-consoles-from-dumping-old-kernel-message-over-again.patch
vfs-ignore-error-on-forced-remount.patch
vfs-keep-list-of-mounts-for-each-superblock.patch
vfs-protect-remounting-superblock-read-only.patch
vfs-fs_may_remount_ro-turn-unnecessary-check-into-a-warn_on.patch
fs-ioctlc-remove-unnecessary-variable.patch
get_maintainerpl-add-support-to-match-arbitrary-text.patch
sigma-firmware-loader-for-analog-devices-sigmastudio.patch
sigma-firmware-loader-for-analog-devices-sigmastudio-v2.patch
drivers-mmc-host-omapc-use-resource_size.patch
drivers-mmc-host-omap_hsmmcc-use-resource_size.patch
select-remove-unused-max_select_seconds.patch
epoll-move-ready-event-check-into-proper-inline.patch
epoll-fix-compiler-warning-and-optimize-the-non-blocking-path.patch
binfmt_elf-quiet-gcc-46-set-but-not-used-warning-in-load_elf_binary.patch
lib-hexdumpc-make-hex2bin-return-the-updated-src-address.patch
fs-binfmt_miscc-use-kernels-hex_to_bin-method.patch
fs-binfmt_miscc-use-kernels-hex_to_bin-method-fix.patch
fs-binfmt_miscc-use-kernels-hex_to_bin-method-fix-fix.patch
init-return-proper-error-code-in-do_mounts_rd.patch
rtc-add-support-for-the-rtc-in-via-vt8500-and-compatibles.patch
rtc-add-real-time-clock-driver-for-nvidia-tegra.patch
jbd-remove-dependency-on-__gfp_nofail.patch
exec_domain-establish-a-linux32-domain-on-config_compat-systems.patch
rapidio-add-new-sysfs-attributes.patch
rapidio-add-rapidio-documentation.patch
fs-execc-provide-the-correct-process-pid-to-the-pipe-helper.patch
kernel-gcov-makefile-use-proper-ccflag-flag-in-makefile.patch
remove-dma64_addr_t.patch
adfs-fix-e-f-dir-size-2048-crashing-kernel.patch
adfs-improve-timestamp-precision.patch
adfs-add-hexadecimal-filetype-suffix-option.patch
adfs-remove-the-big-kernel-lock.patch
scatterlist-new-helper-functions.patch
memstick-add-driver-for-ricoh-r5c592-card-reader.patch
memstick-add-support-for-legacy-memorysticks.patch
memstick-add-support-for-legacy-memorysticks-update.patch
memstick-add-alex-dubov-to-maintainers-of-the-memstick-core.patch
kvm-stop-including-asm-generic-bitops-leh-directly.patch
rds-stop-including-asm-generic-bitops-leh-directly.patch
bitops-merge-little-and-big-endian-definisions-in-asm-generic-bitops-leh.patch
asm-generic-rename-generic-little-endian-bitops-functions.patch
asm-generic-change-little-endian-bitops-to-take-any-pointer-types.patch
powerpc-introduce-little-endian-bitops.patch
s390-introduce-little-endian-bitops.patch
arm-introduce-little-endian-bitops.patch
m68k-introduce-little-endian-bitops.patch
bitops-introduce-config_generic_find_bit_le.patch
m68knommu-introduce-little-endian-bitops.patch
bitops-introduce-little-endian-bitops-for-most-architectures.patch
asm-generic-use-little-endian-bitops.patch
kvm-use-little-endian-bitops.patch
rds-use-little-endian-bitops.patch
ext3-use-little-endian-bitops.patch
ext4-use-little-endian-bitops.patch
ocfs2-use-little-endian-bitops.patch
nilfs2-use-little-endian-bitops.patch
reiserfs-use-little-endian-bitops.patch
udf-use-little-endian-bitops.patch
ufs-use-little-endian-bitops.patch
md-use-little-endian-bitops.patch
dm-use-little-endian-bitops.patch
bitops-remove-ext2-non-atomic-bitops-from-asm-bitopsh.patch
m68k-remove-inline-asm-from-minix_find_first_zero_bit.patch
bitops-remove-minix-bitops-from-asm-bitopsh.patch
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
memblock-add-input-size-checking-to-memblock_find_region.patch
memblock-add-input-size-checking-to-memblock_find_region-fix.patch
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
