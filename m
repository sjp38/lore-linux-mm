Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 00F098D003B
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 18:49:55 -0500 (EST)
Message-Id: <201102042349.p14NnQEm025834@imap1.linux-foundation.org>
Subject: mmotm 2011-02-04-15-15 uploaded
From: akpm@linux-foundation.org
Date: Fri, 04 Feb 2011 15:15:17 -0800
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

The mm-of-the-moment snapshot 2011-02-04-15-15 has been uploaded to

   http://userweb.kernel.org/~akpm/mmotm/

and will soon be available at

   git://zen-kernel.org/kernel/mmotm.git

It contains the following patches against 2.6.38-rc3:

origin.patch
linux-next.patch
next-remove-localversion.patch
i-need-old-gcc.patch
arch-alpha-kernel-systblss-remove-debug-check.patch
include-asm-generic-vmlinuxldsh-fix-__modver-section-warnings.patch
ptrace-use-safer-wake-up-on-ptrace_detach.patch
drivers-gpio-pca953xc-add-a-mutex-to-fix-race-condition.patch
backlight-new-driver-for-the-adp8870-backlight-devices.patch
drivers-rtc-add-module_put-on-error-path-in-rtc_proc_open.patch
nbd-remove-module-level-ioctl-mutex.patch
memblock-dont-adjust-size-in-memblock_find_base.patch
drivers-misc-apds9802alsc-put-the-device-into-runtime-suspend-after-resume-probe-is-handled.patch
mm-vmap-area-cache.patch
agp-ensure-gart-has-an-address-before-enabling-it.patch
loop-queue_lock-null-pointer-derefence-in-blk_throtl_exit-v3.patch
drivers-media-video-tlg2300-pd-videoc-fix-double-mutex_unlock-in-pd_vidioc_s_fmt.patch
acerhdf-add-support-for-aspire-1410-bios-v13314.patch
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
backlight-apple_bl-depends-on-acpi.patch
btusb-patch-add_apple_macbookpro62.patch
fs-ocfs2-dlm-dlmdomainc-avoid-a-gfp_atomic-allocation.patch
pci-avoid-potential-null-pointer-dereference-in-pci_scan_bridge.patch
drivers-message-fusion-mptsasc-fix-warning.patch
scsi-fix-a-header-to-include-linux-typesh.patch
drivers-block-makefile-replace-the-use-of-module-objs-with-module-y.patch
drivers-block-aoe-makefile-replace-the-use-of-module-objs-with-module-y.patch
cciss-make-cciss_revalidate-not-loop-through-ciss_max_luns-volumes-unnecessarily.patch
loop-queue_lock-null-pointer-derefence-in-blk_throtl_exit.patch
drbd-fix-warning.patch
usb-yurex-recognize-generalkeys-wireless-presenter-as-generic-hid.patch
mm.patch
mm-compaction-check-migrate_pagess-return-value-instead-of-list_empty.patch
mm-numa-aware-alloc_task_struct_node.patch
mm-numa-aware-alloc_thread_info_node.patch
kthread-numa-aware-kthread_create_on_cpu.patch
kthread-use-kthread_create_on_cpu.patch
oom-suppress-nodes-that-are-not-allowed-from-meminfo-on-oom-kill.patch
oom-suppress-show_mem-for-many-nodes-in-irq-context-on-page-alloc-failure.patch
oom-suppress-nodes-that-are-not-allowed-from-meminfo-on-page-alloc-failure.patch
mm-notifier_from_errno-cleanup.patch
mm-remove-unused-token-argument-from-apply_to_page_range-callback.patch
mm-add-apply_to_page_range_batch.patch
ioremap-use-apply_to_page_range_batch-for-ioremap_page_range.patch
vmalloc-use-plain-pte_clear-for-unmaps.patch
vmalloc-use-apply_to_page_range_batch-for-vunmap_page_range.patch
vmalloc-use-apply_to_page_range_batch-for-vmap_page_range_noflush.patch
vmalloc-use-apply_to_page_range_batch-in-alloc_vm_area.patch
xen-mmu-use-apply_to_page_range_batch-in-xen_remap_domain_mfn_range.patch
xen-grant-table-use-apply_to_page_range_batch.patch
mm-allow-gup-to-fail-instead-of-waiting-on-a-page.patch
mm-allow-gup-to-fail-instead-of-waiting-on-a-page-fix.patch
mm-add-replace_page_cache_page-function.patch
memsw-remove-noswapaccount-kernel-parameter.patch
xattrh-expose-string-defines-to-userspace.patch
frv-duplicate-output_buffer-of-e03.patch
frv-duplicate-output_buffer-of-e03-checkpatch-fixes.patch
hpet-factor-timer-allocate-from-open.patch
arch-alpha-include-asm-ioh-s-extern-inline-static-inline.patch
uml-kernels-on-i386x86_64-produce-bad-coredumps.patch
add-the-common-dma_addr_t-typedef-to-include-linux-typesh.patch
fs-use-appropriate-printk-priority-level.patch
bh1780gli-convert-to-dev-pm-ops.patch
drivers-misc-bmp085c-free-initmem-memory.patch
move-x86-specific-oops=panic-to-generic-code.patch
include-linux-errh-add-a-function-to-cast-error-pointers-to-a-return-value.patch
smp-move-smp-setup-functions-to-kernel-smpc.patch
kernel-cpuc-fix-many-errors-related-to-style.patch
kernel-cpuc-fix-many-errors-related-to-style-fix.patch
llist-add-kconfig-option-arch_have_nmi_safe_cmpxchg.patch
llist-lib-add-lock-less-null-terminated-single-list.patch
llist-irq_work-use-llist-in-irq_work.patch
llist-net-rds-replace-xlist-in-net-rds-xlisth-with-llist.patch
net-convert-%p-usage-to-%pk.patch
vsprintf-neaten-%pk-kptr_restrict-save-a-bit-of-code-space.patch
console-allow-to-retain-boot-console-via-boot-option-keep_bootcon.patch
console-prevent-registered-consoles-from-dumping-old-kernel-message-over-again.patch
printk-allow-setting-default_message_level-via-kconfig.patch
vfs-ignore-error-on-forced-remount.patch
vfs-keep-list-of-mounts-for-each-superblock.patch
vfs-protect-remounting-superblock-read-only.patch
vfs-fs_may_remount_ro-turn-unnecessary-check-into-a-warn_on.patch
fs-ioctlc-remove-unnecessary-variable.patch
get_maintainerpl-allow-k-pattern-tests-to-match-non-patch-text.patch
sigma-firmware-loader-for-analog-devices-sigmastudio.patch
sigma-firmware-loader-for-analog-devices-sigmastudio-v2.patch
drivers-mmc-host-omapc-use-resource_size.patch
drivers-mmc-host-omap_hsmmcc-use-resource_size.patch
scripts-checkpatchpl-reset-rpt_cleaners-warnings.patch
select-remove-unused-max_select_seconds.patch
epoll-move-ready-event-check-into-proper-inline.patch
epoll-fix-compiler-warning-and-optimize-the-non-blocking-path.patch
epoll-fix-compiler-warning-and-optimize-the-non-blocking-path-fix.patch
binfmt_elf-quiet-gcc-46-set-but-not-used-warning-in-load_elf_binary.patch
lib-hexdumpc-make-hex2bin-return-the-updated-src-address.patch
fs-binfmt_miscc-use-kernels-hex_to_bin-method.patch
fs-binfmt_miscc-use-kernels-hex_to_bin-method-fix.patch
fs-binfmt_miscc-use-kernels-hex_to_bin-method-fix-fix.patch
init-return-proper-error-code-in-do_mounts_rd.patch
rtc-add-support-for-the-rtc-in-via-vt8500-and-compatibles.patch
rtc-add-real-time-clock-driver-for-nvidia-tegra.patch
gpio-add-new-altera-pio-driver.patch
gpio-make-gpio_requestfree_array-gpio-array-parameter-const.patch
pnp-only-assign-ioresource_dma-if-config_isa_dma_api-is-enabled.patch
x86-only-compile-8237a-if-config_isa_dma_api-is-enabled.patch
x86-only-compile-floppy-driver-if-config_isa_dma_api-is-enabled.patch
x86-allow-config_isa_dma_api-to-be-disabled.patch
jbd-remove-dependency-on-__gfp_nofail.patch
cgroup-remove-the-ns_cgroup.patch
memcg-res_counter_read_u64-fix-potential-races-on-32-bit-machines.patch
memcg-fix-ugly-initialization-of-return-value-is-in-caller.patch
memcg-soft-limit-reclaim-should-end-at-limit-not-below.patch
memcg-simplify-the-way-memory-limits-are-checked.patch
memcg-remove-unused-page-flag-bitfield-defines.patch
memcg-remove-impossible-conditional-when-committing.patch
memcg-remove-null-check-from-lookup_page_cgroup-result.patch
memcg-add-memcg-sanity-checks-at-allocating-and-freeing-pages.patch
memcg-add-memcg-sanity-checks-at-allocating-and-freeing-pages-update.patch
memcg-no-uncharged-pages-reach-page_cgroup_zoneinfo.patch
memcg-change-page_cgroup_zoneinfo-signature.patch
memcg-fold-__mem_cgroup_move_account-into-caller.patch
memcg-condense-page_cgroup-to-page-lookup-points.patch
memcg-remove-direct-page_cgroup-to-page-pointer.patch
memcg-remove-direct-page_cgroup-to-page-pointer-fix.patch
exec_domain-establish-a-linux32-domain-on-config_compat-systems.patch
drivers-char-add-msm-smd_pkt-driver.patch
drivers-char-bfin_jtag_commc-avoid-calling-put_tty_driver-on-null.patch
rapidio-add-new-sysfs-attributes.patch
rapidio-add-rapidio-documentation.patch
fs-execc-provide-the-correct-process-pid-to-the-pipe-helper.patch
taskstats-use-appropriate-printk-priority-level.patch
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
drivers-w1-masters-omap_hdqc-add-missing-clk_put.patch
crash_dump-export-is_kdump_kernel-to-modules-consolidate-elfcorehdr_addr-setup_elfcorehdr-and-saved_max_pfn.patch
crash_dump-export-is_kdump_kernel-to-modules-consolidate-elfcorehdr_addr-setup_elfcorehdr-and-saved_max_pfn-fix.patch
crash_dump-export-is_kdump_kernel-to-modules-consolidate-elfcorehdr_addr-setup_elfcorehdr-and-saved_max_pfn-fix-fix.patch
kexec-remove-kmsg_dump_kexec.patch
fs-devpts-inodec-correctly-check-d_alloc_name-return-code-in-devpts_pty_new.patch
kvm-stop-including-asm-generic-bitops-leh-directly.patch
rds-stop-including-asm-generic-bitops-leh-directly.patch
bitops-merge-little-and-big-endian-definisions-in-asm-generic-bitops-leh.patch
asm-generic-rename-generic-little-endian-bitops-functions.patch
asm-generic-change-little-endian-bitops-to-take-any-pointer-types.patch
asm-generic-change-little-endian-bitops-to-take-any-pointer-types-convert-little-endian-bitops-macros-to-static-inline-functions.patch
powerpc-introduce-little-endian-bitops.patch
powerpc-introduce-little-endian-bitops-convert-little-endian-bitops-macros-to-static-inline-functions.patch
s390-introduce-little-endian-bitops.patch
s390-introduce-little-endian-bitops-convert-little-endian-bitops-macros-to-static-inline-functions.patch
arm-introduce-little-endian-bitops.patch
arm-introduce-little-endian-bitops-convert-little-endian-bitops-macros-to-static-inline-functions.patch
m68k-introduce-little-endian-bitops.patch
m68k-introduce-little-endian-bitops-convert-little-endian-bitops-macros-to-static-inline-functions.patch
bitops-introduce-config_generic_find_bit_le.patch
m68knommu-introduce-little-endian-bitops.patch
m68knommu-introduce-little-endian-bitops-convert-little-endian-bitops-macros-to-static-inline-functions.patch
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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
