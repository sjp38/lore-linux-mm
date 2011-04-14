Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E2F39900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 18:45:05 -0400 (EDT)
Message-Id: <201104142244.p3EMiWTC010977@imap1.linux-foundation.org>
Subject: mmotm 2011-04-14-15-08 uploaded
From: akpm@linux-foundation.org
Date: Thu, 14 Apr 2011 15:08:47 -0700
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

The mm-of-the-moment snapshot 2011-04-14-15-08 has been uploaded to

   http://userweb.kernel.org/~akpm/mmotm/

and will soon be available at

   git://zen-kernel.org/kernel/mmotm.git

It contains the following patches against 2.6.39-rc3:

origin.patch
memcg-fix-mem_cgroup_rotate_reclaimable_page.patch
mm-optimize-pfn-calculation-in-online_page.patch
rtc-rtc-mc13xxx-fix-unterminated-platform_device_id-table.patch
fs-partitions-ldmc-fix-oops-caused-by-corrupted-partition-table.patch
mm-page_allocc-silence-build_all_zonelists-section-mismatch.patch
vmstat-update-comment-regarding-stat_threshold.patch
leds-leds-regulatorc-fix-handling-of-already-enabled-regulators.patch
kstrtox-fix-compile-warnings-in-test.patch
kstrtox-simpler-code-in-_kstrtoull.patch
maintainers-add-arm-ts78xx-setup-platform-maintainer.patch
maintainers-update-m68knommu-patterns.patch
maintainers-update-various-tty-patterns.patch
mm-add-vm-counters-for-transparent-hugepages.patch
maintainers-update-stable-branch-info.patch
tmpfs-fix-off-by-one-in-max_blocks-checks.patch
drivers-misc-sgi-gru-grufilec-fix-the-wrong-members-of-gru_chip.patch
brk-compat_brk-fix-detection-of-randomized-brk.patch
mm-check-that-we-have-the-right-vma-in-__access_remote_vm.patch
vmscan-all_unreclaimable-use-zone-all_unreclaimable-as-a-name.patch
oom-kill-remove-boost_dying_task_prio.patch
rapidio-add-idt-cps-1432-switch-definitions.patch
rapidio-mpc85xx-fix-possible-mport-registration-problems.patch
maintainers-change-mail-adress-of-hans-j-koch.patch
fs-fhandlec-add-linux-personalityh-for-ia64.patch
um-fix-call-tracer-and-bug-handler.patch
um-disable-config_cmpxchg_local.patch
ramfs-fix-memleak-on-no-mmu-arch.patch
mm-thp-use-conventional-format-for-boolean-attributes.patch
backlight-new-driver-for-the-adp8870-backlight-devices.patch
linux-next.patch
next-remove-localversion.patch
i-need-old-gcc.patch
hid-examplec-is-borked.patch
arch-alpha-kernel-systblss-remove-debug-check.patch
include-asm-generic-vmlinuxldsh-fix-__modver-section-warnings.patch
drivers-i2c-busses-i2c-designware-corec-needs-delayh.patch
vfs-avoid-large-kmallocs-for-the-fdtable.patch
drivers-char-agp-genericc-fix-arbitrary-kernel-memory-writes.patch
drivers-char-agp-genericc-fix-oom-and-buffer-overflow.patch
drivers-scsi-pmcraid-reject-negative-request-size.patch
drivers-scsi-mpt2sas-mpt2sas_ctlc-fix-unbounded-copy_to_user.patch
acpi-remove-acpi_sleep=s4_nonvs.patch
acerhdf-add-support-for-aspire-1410-bios-v13314.patch
arch-x86-include-asm-delayh-fix-udelay-and-ndelay-for-8-bit-args.patch
x86-fix-mmap-random-address-range.patch
leds-new-pcengines-alix-system-driver-enables-leds-via-gpio-interface.patch
gpio-show-explicit-dependency-between-gpio_cs5535-and-mfd_cs5535.patch
sound-pci-hda-hda_codecc-fix-warning.patch
msm-timer-migrate-to-timer-based-__delay.patch
arch-arm-mach-ux500-mbox-db5500c-world-writable-sysfs-fifo-file.patch
audit-always-follow-va_copy-with-va_end.patch
fs-btrfs-inodec-eliminate-memory-leak.patch
btrfs-dont-dereference-extent_mapping-if-null.patch
drivers-gpu-drm-radeon-atomc-fix-warning.patch
fb-fix-potential-deadlock-between-lock_fb_info-and-console_lock.patch
cyber2000fb-avoid-palette-corruption-at-higher-clocks.patch
fscache-remove-dead-code-under-config_workqueue_debugfs.patch
bitmap-irq-add-smp_affinity_list-interface-to-proc-irq.patch
leds-support-automatic-start-of-blinking-with-ledtrig-timer.patch
drivers-leds-leds-pca9532c-add-gpio-capability.patch
leds-route-kbd-leds-through-the-generic-leds-layer.patch
net-irda-convert-bfin_sir-to-common-blackfin-uart-header.patch
net-convert-%p-usage-to-%pk.patch
backlight-add-backlight-type-fix.patch
backlight-add-backlight-type-fix-fix.patch
drivers-video-backlight-adp5520_blc-check-strict_strtoul-return-value.patch
drivers-video-backlight-adp5520_blc-check-strict_strtoul-return-value-fix.patch
i915-add-native-backlight-control.patch
btusb-patch-add_apple_macbookpro62.patch
drivers-message-fusion-mptsasc-fix-warning.patch
scsi-fix-a-header-to-include-linux-typesh.patch
aic94xx-world-writable-sysfs-update_bios-file.patch
osst-wrong-index-used-in-inner-loop.patch
osst-wrong-index-used-in-inner-loop-checkpatch-fixes.patch
drivers-scsi-osstc-fix-warning.patch
drbd-fix-warning.patch
usb-yurex-recognize-generalkeys-wireless-presenter-as-generic-hid.patch
drivers-usb-misc-usbtestc-fix-warning.patch
xtensa-s-irq_chip-irq_data-in-various-places.patch
mm.patch
arch-mm-filter-disallowed-nodes-from-arch-specific-show_mem-functions.patch
mmap-add-alignment-for-some-variables.patch
mmap-avoid-unnecessary-anon_vma-lock.patch
mmap-avoid-merging-cloned-vmas.patch
mm-remove-unused-zone_idx-variable-from-set_migratetype_isolate.patch
mm-nommu-sort-mm-mmap-list-properly.patch
mm-nommu-sort-mm-mmap-list-properly-fix.patch
mm-nommu-dont-scan-the-vma-list-when-deleting.patch
mm-nommu-find-vma-using-the-sorted-vma-list.patch
mm-nommu-check-the-vma-list-when-unmapping-file-mapped-vma.patch
mm-nommu-fix-a-potential-memory-leak-in-do_mmap_private.patch
mm-nommu-fix-a-compile-warning-in-do_mmap_pgoff.patch
mm-per-node-vmstat-show-proper-vmstats.patch
mm-per-node-vmstat-show-proper-vmstats-fix.patch
mm-increase-reclaim_distance-to-30.patch
mm-introduce-wait_on_page_locked_killable.patch
x86mm-make-pagefault-killable.patch
mm-mem-hotplug-fix-section-mismatch-setup_per_zone_inactive_ratio-should-be-__meminit.patch
mm-mem-hotplug-recalculate-lowmem_reserve-when-memory-hotplug-occur.patch
mm-mem-hotplug-update-pcp-stat_threshold-when-memory-hotplug-occur.patch
mm-mem-hotplug-update-pcp-stat_threshold-when-memory-hotplug-occur-fix.patch
mm-convert-vma-vm_flags-to-64-bit.patch
mm-add-__nocast-attribute-to-vm_flags.patch
fremap-convert-vm_flags-to-unsigned-long-long.patch
procfs-convert-vm_flags-to-unsigned-long-long.patch
mm-compaction-reverse-the-change-that-forbade-sync-migraton-with-__gfp_no_kswapd.patch
oom-replace-pf_oom_origin-with-toggling-oom_score_adj.patch
oom-replace-pf_oom_origin-with-toggling-oom_score_adj-update.patch
mm-remove-unused-token-argument-from-apply_to_page_range-callback.patch
mm-add-apply_to_page_range_batch.patch
ioremap-use-apply_to_page_range_batch-for-ioremap_page_range.patch
vmalloc-use-plain-pte_clear-for-unmaps.patch
vmalloc-use-apply_to_page_range_batch-for-vunmap_page_range.patch
vmalloc-use-apply_to_page_range_batch-for-vmap_page_range_noflush.patch
vmalloc-use-apply_to_page_range_batch-in-alloc_vm_area.patch
xen-mmu-use-apply_to_page_range_batch-in-xen_remap_domain_mfn_range.patch
xen-grant-table-use-apply_to_page_range_batch.patch
memsw-remove-noswapaccount-kernel-parameter.patch
mm-batch-activate_page-to-reduce-lock-contention.patch
xattrh-expose-string-defines-to-userspace.patch
frv-duplicate-output_buffer-of-e03.patch
frv-duplicate-output_buffer-of-e03-checkpatch-fixes.patch
hpet-factor-timer-allocate-from-open.patch
arch-alpha-include-asm-ioh-s-extern-inline-static-inline.patch
bluetooth-fix-build-warnings-on-defconfigs.patch
init-calibratec-fix-for-critical-bogomips-intermittent-calculation-failure.patch
init-calibratec-fix-for-critical-bogomips-intermittent-calculation-failure-checkpatch-fixes.patch
init-calibratec-fix-for-critical-bogomips-intermittent-calculation-failure-fix.patch
lib-vsprintfc-fix-interaction-of-kasprintf-and-vsnprintf-when-using-%pv.patch
fcntlf_setfl-allow-setting-of-o_sync.patch
lru_cache-use-correct-type-in-sizeof-for-allocation.patch
lru_cache-use-correct-type-in-sizeof-for-allocation-fix.patch
lib-add-kstrto_from_user.patch
lib-consolidate-debug_per_cpu_maps.patch
include-linux-genalloch-add-multiple-inclusion-guards.patch
lib-genallocc-add-support-for-specifying-the-physical-address.patch
lib-genpoolc-document-return-values-fix-gen_pool_add_virt-return-value.patch
percpu_counter-change-return-value-and-add-comments.patch
percpu_counter-change-return-value-and-add-comments-fix.patch
checkpatch-add-check-for-line-continuations-in-quoted-strings.patch
lib-hexdumpc-make-hex2bin-return-the-updated-src-address.patch
fs-binfmt_miscc-use-kernels-hex_to_bin-method.patch
fs-binfmt_miscc-use-kernels-hex_to_bin-method-fix.patch
fs-binfmt_miscc-use-kernels-hex_to_bin-method-fix-fix.patch
fs-ncpfs-inodec-suppress-used-uninitialised-warning.patch
vt-add-k_off-return-value-to-vt_ioctl-kdgkbmode.patch
drivers-tty-vt-vt_ioctlc-repair-insane-expression.patch
rtc-add-support-for-the-rtc-in-via-vt8500-and-compatibles.patch
rtc-add-em3027-rtc-driver.patch
rtc-add-rv3029c2-rtc-support.patch
rtc-add-basic-support-for-st-m41t93-spi-rtc.patch
drivers-rtc-rtc-mrstc-use-release_mem_region-after-request_mem_region.patch
drivers-rtc-rtc-mrstc-use-release_mem_region-after-request_mem_region-fix.patch
rtc-driver-for-pt7c4338-chip.patch
rtc-driver-for-pt7c4338-chip-checkpatch-fixes.patch
rtc-driver-for-pt7c4338-chip-fix.patch
gpio-add-new-altera-pio-driver.patch
gpio-add-new-altera-pio-driver-update.patch
gpio-make-gpio_requestfree_array-gpio-array-parameter-const.patch
jbd-remove-dependency-on-__gfp_nofail.patch
ufs-truncated-values-handling-64-bit-metadata.patch
documentation-atomic_opstxt-avoid-volatile-in-sample-code.patch
documentation-accounting-getdelaysc-fix-unused-var-warning.patch
documentation-accounting-getdelaysc-handle-sendto-failures.patch
cgroups-read-write-lock-clone_thread-forking-per-threadgroup.patch
cgroups-add-per-thread-subsystem-callbacks.patch
cgroups-make-procs-file-writable.patch
cgroups-use-flex_array-in-attach_proc.patch
cgroup-remove-the-ns_cgroup.patch
mm-move-enum-vm_event_item-into-a-standalone-header-file.patch
memcg-count-the-soft_limit-reclaim-in-global-background-reclaim.patch
memcg-add-stats-to-monitor-soft_limit-reclaim.patch
add-the-pagefault-count-into-memcg-stats.patch
add-the-pagefault-count-into-memcg-stats-fix.patch
memcg-remove-pointless-next_mz-nullification-in-mem_cgroup_soft_limit_reclaim.patch
memcg-mark-init_section_page_cgroup-properly.patch
memcg-fix-off-by-one-when-calculating-swap-cgroup-map-length.patch
memcg-move-page-freeing-code-out-of-lock.patch
maintainers-add-mm-page_cgroupc-into-memcg-subsystem.patch
cpusets-randomize-node-rotor-used-in-cpuset_mem_spread_node.patch
signal-introduce-retarget_shared_pending.patch
signal-retarget_shared_pending-consider-shared-unblocked-signals-only.patch
signal-sigprocmask-narrow-the-scope-of-sigloc.patch
signal-sigprocmask-should-do-retarget_shared_pending.patch
x86-signal-handle_signal-should-use-sigprocmask.patch
x86-signal-sys_rt_sigreturn-should-use-sigprocmask.patch
kstrtox-convert-fs-proc.patch
proc-constify-status-array.patch
proc-stat-use-defined-macro-kmalloc_max_size.patch
dev-kmsg-properly-support-writev-to-avoid-interleaved-printk-lines.patch
dev-kmsg-properly-support-writev-to-avoid-interleaved-printk-lines-fix.patch
fs-partitions-efic-corrupted-guid-partition-tables-can-cause-kernel-oops.patch
fs-partitions-efic-corrupted-guid-partition-tables-can-cause-kernel-oops-fix.patch
sysctl-add-proc_dointvec_bool-handler.patch
sysctl-use-proc_dointvec_bool-where-appropriate.patch
sysctl-add-proc_dointvec_unsigned-handler.patch
sysctl-use-proc_dointvec_unsigned-where-appropriate.patch
pid-fix-typo-in-function-description.patch
fs-execc-provide-the-correct-process-pid-to-the-pipe-helper.patch
scatterlist-new-helper-functions.patch
scatterlist-new-helper-functions-update.patch
scatterlist-new-helper-functions-update-fix.patch
memstick-add-support-for-legacy-memorysticks.patch
memstick-add-support-for-legacy-memorysticks-update-2.patch
w1-add-1-wire-w1-reset-and-resume-command-api-support.patch
w1-add-1-wire-w1-ds2408-8-channel-addressable-switch-support.patch
w1-complete-the-1-wire-w1-ds1wm-driver-search-algorithm.patch
kexec-remove-kmsg_dump_kexec.patch
kexec-remove-kmsg_dump_kexec-fix.patch
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
