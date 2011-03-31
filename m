Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1FD118D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 18:24:47 -0400 (EDT)
Message-Id: <201103312224.p2VMOA5g000983@imap1.linux-foundation.org>
Subject: mmotm 2011-03-31-14-48 uploaded
From: akpm@linux-foundation.org
Date: Thu, 31 Mar 2011 14:48:44 -0700
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

The mm-of-the-moment snapshot 2011-03-31-14-48 has been uploaded to

   http://userweb.kernel.org/~akpm/mmotm/

and will soon be available at

   git://zen-kernel.org/kernel/mmotm.git

It contains the following patches against 2.6.39-rc1:

origin.patch
memcg-fix-mem_cgroup_rotate_reclaimable_page.patch
mm-optimize-pfn-calculation-in-online_page.patch
backlight-new-driver-for-the-adp8870-backlight-devices.patch
linux-next.patch
next-remove-localversion.patch
i-need-old-gcc.patch
arch-alpha-kernel-systblss-remove-debug-check.patch
include-asm-generic-vmlinuxldsh-fix-__modver-section-warnings.patch
drivers-i2c-busses-i2c-designware-corec-needs-delayh.patch
sound-soc-codecs-sn95031c-needs-delayh.patch
fs-partitions-ldmc-fix-oops-caused-by-corrupted-partition-table.patch
fs-partitions-ldmc-fix-oops-caused-by-corrupted-partition-table-checkpatch-fixes.patch
mm-page_allocc-silence-build_all_zonelists-section-mismatch.patch
vmstat-update-comment-regarding-stat_threshold.patch
leds-leds-regulatorc-fix-handling-of-already-enabled-regulators.patch
kstrtox-fix-compile-warnings-in-test.patch
kstrtox-simpler-code-in-_kstrtoull.patch
maintainers-add-arm-ts78xx-setup-platform-maintainer.patch
maintainers-update-m68knommu-patterns.patch
maintainers-update-various-tty-patterns.patch
mm-add-vm-counters-for-transparent-hugepages.patch
acerhdf-add-support-for-aspire-1410-bios-v13314.patch
arch-x86-include-asm-delayh-fix-udelay-and-ndelay-for-8-bit-args.patch
x86-fix-mmap-random-address-range.patch
x86-stop-including-linux-delayh-in-two-asm-header-files.patch
msm-timer-migrate-to-timer-based-__delay.patch
arch-arm-mach-ux500-mbox-db5500c-world-writable-sysfs-fifo-file.patch
audit-always-follow-va_copy-with-va_end.patch
fs-btrfs-inodec-eliminate-memory-leak.patch
btrfs-dont-dereference-extent_mapping-if-null.patch
drivers-gpu-drm-radeon-atomc-fix-warning.patch
fb-fix-potential-deadlock-between-lock_fb_info-and-console_lock.patch
cyber2000fb-avoid-palette-corruption-at-higher-clocks.patch
bitmap-irq-add-smp_affinity_list-interface-to-proc-irq.patch
drivers-leds-leds-pca9532c-add-gpio-capability.patch
leds-route-kbd-leds-through-the-generic-leds-layer.patch
net-irda-convert-bfin_sir-to-common-blackfin-uart-header.patch
net-convert-%p-usage-to-%pk.patch
backlight-add-backlight-type-fix.patch
backlight-add-backlight-type-fix-fix.patch
i915-add-native-backlight-control.patch
btusb-patch-add_apple_macbookpro62.patch
drivers-message-fusion-mptsasc-fix-warning.patch
scsi-fix-a-header-to-include-linux-typesh.patch
aic94xx-world-writable-sysfs-update_bios-file.patch
drbd-fix-warning.patch
usb-yurex-recognize-generalkeys-wireless-presenter-as-generic-hid.patch
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
lib-vsprintfc-fix-interaction-of-kasprintf-and-vsnprintf-when-using-%pv.patch
lib-hexdumpc-make-hex2bin-return-the-updated-src-address.patch
fs-binfmt_miscc-use-kernels-hex_to_bin-method.patch
fs-binfmt_miscc-use-kernels-hex_to_bin-method-fix.patch
fs-binfmt_miscc-use-kernels-hex_to_bin-method-fix-fix.patch
rtc-add-support-for-the-rtc-in-via-vt8500-and-compatibles.patch
rtc-add-em3027-rtc-driver.patch
rtc-add-rv3029c2-rtc-support.patch
rtc-driver-for-pt7c4338-chip.patch
rtc-driver-for-pt7c4338-chip-checkpatch-fixes.patch
rtc-driver-for-pt7c4338-chip-fix.patch
gpio-add-new-altera-pio-driver.patch
gpio-add-new-altera-pio-driver-update.patch
gpio-make-gpio_requestfree_array-gpio-array-parameter-const.patch
jbd-remove-dependency-on-__gfp_nofail.patch
documentation-atomic_opstxt-avoid-volatile-in-sample-code.patch
cgroup-remove-the-ns_cgroup.patch
mm-move-enum-vm_event_item-into-a-standalone-header-file.patch
memcg-count-the-soft_limit-reclaim-in-global-background-reclaim.patch
memcg-add-stats-to-monitor-soft_limit-reclaim.patch
add-the-pagefault-count-into-memcg-stats.patch
add-the-pagefault-count-into-memcg-stats-fix.patch
memcg-remove-pointless-next_mz-nullification-in-mem_cgroup_soft_limit_reclaim.patch
kstrtox-convert-fs-proc.patch
proc-constify-status-array.patch
proc-stat-use-defined-macro-kmalloc_max_size.patch
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
