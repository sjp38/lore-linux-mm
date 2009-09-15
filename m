Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 83D5E6B004F
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 19:16:03 -0400 (EDT)
Date: Tue, 15 Sep 2009 16:15:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: 2.6.32 -mm merge plans
Message-Id: <20090915161535.db0a6904.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


- If replying to this email, please rewrite the Subject: appropriately.

- Please also cc the relevant developer(s).  Locate the patch in
  http://userweb.kernel.org/~akpm/mmotm/broken-out/ and check the signoff
  and Cc lines to find the names and email addresses.

- If you were bcc'ed on this email then you and I have unfinished
  business.  Please see if you can work out what it is from the below and
  let me know ;)

- There's an unusual amount of memory management work here.

- I seem to have a lot of patches which people were going to send me
  updates for, and which might have outstanding reviewer issues.

- If someone understand why I'm (still) sitting on 176 patches on behalf
  of subsystem maintainers, please fell free to explain this to me.



sdhci-orphan-driver-and-list.patch
proc-kcore-work-around-a-bug.patch
hugetlb-restore-interleaving-of-bootmem-huge-pages-2631.patch
fs-make-sure-data-stored-into-inode-is-properly-seen-before-unlocking-new-inode.patch
fs-make-sure-data-stored-into-inode-is-properly-seen-before-unlocking-new-inode-fix.patch
proc-document-guest-column-in-proc-stat.patch

  Merge.  A lot of these patches missed 2.6.31 so there are cc:stable's there.

mm-memory-failure-remove-config_unevictable_lru-config-option.patch

  -> Andi

kernel-core-add-smp_call_function_any.patch
arch-x86-kernel-cpu-cpufreq-acpi-cpufreqc-avoid-cross-cpu-interrupts-by-using-smp_call_function_any.patch
cpuidle-menu-governor-reduce-latency-on-exit.patch
acerhdf-convert-to-dev_pm_ops.patch
acerhdf-additional-bios-versions.patch
acpi-switch-proc-acpi-debug_layerdebug_level-to-seq_file.patch
hwmon-driver-for-acpi-40-power-meters.patch
hwmon-driver-for-acpi-40-power-meters-fix.patch
hwmon-driver-for-acpi-40-power-meters-fix-2.patch
thermal-add-missing-kconfig-dependency.patch
dell_laptop-when-the-hardware-switch-is-disabled-dont-actually-allow-changing-the-softblock-status.patch
cpuidle-a-new-variant-of-the-menu-governor-to-boost-io-performance.patch

  -> lenb.

  I need to update
  cpuidle-a-new-variant-of-the-menu-governor-to-boost-io-performance.patch
  and might merge that myself, dunno yet.

cs5535-gpio-add-amd-cs5535-cs5536-gpio-driver-support.patch
cs5535-gpio-request-function-mask-names-added.patch
cs5535-gpio-request-function-mask-names-added-fix.patch
alsa-cs5535audio-free-olpc-quirks-from-reliance-on-mgeode_lx-cpu-optimization.patch

  -> tiwai

agp-correct-missing-cleanup-on-error-in-agp_add_bridge.patch

  -> airlied

s3c-fix-check-of-index-into-s3c_gpios.patch
stmp3xxx-deallocation-with-negative-index-of-descriptors.patch
spitz-fix-touchscreen-max-presure.patch

  -> rmk

avr32-convert-to-asm-generic-hardirqh.patch

  -> Haavard & co.

dm-strncpy-does-not-null-terminate-string.patch
md-dm-log-fix-cn_ulog_callback-declaration.patch

  -> agk

pcmcia-yenta-add-missing-__devexit-marking.patch
pcmcia-fix-read-buffer-overflow.patch
pcmcia-switch-proc-bus-pccard-drivers-to-seq_file.patch
pcmcia-cleanup-fixup-patch-for-sa1100_jornada_pcmcia-driver.patch

  Seems that Dmitry is having downtime so I'll merge these directly.

powerpc-sky-cpu-redundant-or-incorrect-tests-on-unsigned.patch

  -> benh

hpilo-add-locking-comment.patch

  -> gregkh

drm-via-add-pci-id-for-via-vx800-chipset.patch

  -> airlied

video-initial-support-for-adv7180.patch
video-initial-support-for-adv7180-update.patch
video-initial-support-for-adv7180-update-fix.patch

  -> mchehab

genirq-switch-proc-irq-spurious-to-seq_file.patch

  -> tglx, mingo

timer-stats-fix-del_timer_sync-and-try_to_del_timer_sync.patch

  -> tglx, mingo

ia64-use-printk_once.patch

  -> Tony

input-drivers-input-xpadc-improve-xbox-360-wireless-support-and-add-sysfs-interface.patch
input-documentation-input-xpadtxt-update-for-new-driver-functionality.patch
input-touchpad-not-detected-on-asus-g1s.patch
input-add-a-shutdown-method-to-pnp-drivers.patch

  -> dmitry

gitignore-usr-initramfs_datacpiobz2-and-usr-initramfs_datacpiolzma.patch
kernel-hacking-move-strip_asm_syms-from-general.patch
kbuild-add-static-to-prototypes.patch
ctags-usability-fix.patch
checkincludespl-close-file-as-soon-as-were-done-with-it.patch
checkincludespl-provide-usage-helper.patch
checkincludespl-add-option-to-remove-duplicates-in-place.patch
markup_oops-use-modinfo-to-avoid-confusion-with-underscored-module-names.patch
kbuild-generate-modulesbuiltin.patch
kbuild-rebuild-fix-for-makefilemodbuiltin.patch
kconfig-cross_compile-option.patch
kbuild-fix-cc1-options-check-to-ensure-we-do-not-use-fpic-when-compiling.patch
gconfig-disable-typeahead-find-search-in-treeviews.patch
kbuild-fix-ld-option-makefile-macro-to-really-work.patch
kbuild-check-if-linker-supports-the-x-option.patch
kbuild-echo-the-record_mcount-command.patch
kbuild-fail-build-if-recordmcountpl-fails.patch
kbuild-set-fconserve-stack-option-for-gcc-45.patch

  -> Sam

ide-use-printk_once.patch

  -> davem

mips-decrease-size-of-au1xxx_dbdma_pm_regs.patch
mips-octeon-add-hardware-rng-platform-device.patch
hw_random-add-hardware-rng-for-octeon-socs.patch
octeon-false-positive-timeout.patch
msp71xx-request_irq-failure-ignored-in-msp_pcibios_config_access.patch

  -> ralf

jffs2-move-jffs2_gcd_mtd-threads-to-the-new-kthread-api.patch
mtd-sst25l-non-jedec-spi-flash-driver.patch
mtd-sst25l-fix-lock-imbalance.patch
mtd-register-orion_nand-using-platform_driver_probe.patch
mtd-make-onenand-genericc-more-generic.patch
mtd-nand-add-page-parameter-to-all-read_page-read_page_raw-apis.patch
mtd-nand-add-new-ecc-mode-ecc_hw_oob_first.patch
mtd-nand-davinci-add-4-bit-ecc-support-for-large-page-nand-chips.patch
mtd-nand-davinci-add-4-bit-ecc-support-for-large-page-nand-chips-update.patch
mtd-jffs2-fix-read-buffer-overflow.patch
mtd-prevent-a-read-from-eraseregions.patch
mtd-prevent-a-read-from-regions.patch
mtd-jedec_probe-fix-nec-upd29f064115-detection.patch
mtdpart-memory-accessor-interface-for-mtd-layer.patch

  -> dwmw2

isdn-hisax-fix-lock-imbalance.patch
hfc_usb-fix-read-buffer-overflow.patch
isdn-fix-netjet-build-errors.patch
misdn-fix-reversed-if-in-st_own_ctrl.patch
isdn-eicon-use-offsetof.patch
isdn-eicon-return-on-error.patch

  -> Karsten

zorro8390-fix-read-buffer-overflow-in-zorro8390_init_one-checkpatch-fixes.patch

  Will drop.  Sigh.

3x59x-fix-pci-resource-management.patch

  I need to test this.  Still.

video-mbp_nvidia_bl-add-support-for-macbookair-11.patch

  -> rpurdie

sunrpc-use-formatting-of-module-name-in-sunrpc.patch

  -> trond & co

tpm-fixup-pcrs-sysfs-file.patch
tpm-fixup-pcrs-sysfs-file-update.patch
tpm-fix-up-pubek-sysfs-file.patch

  -> jmorris.  These might be obsolete anyway.

serial_txx9-use-container_of-instead-of-direct-cast.patch
icom-converting-space-to-tabs.patch
cyclades-read-buffer-overflow.patch
serial167-fix-read-buffer-overflow.patch
serial-add-parameter-to-force-skipping-the-test-for-the-txen-bug.patch

  -> alan

drivers-md-introduce-missing-kfree.patch

  -> neilb

regulator-fix-calculation-of-voltage-range-in-da9034_set_ldo12_voltage.patch

  -> Liam & co

spinlocks-check-spinlock_t-rwlock_t-argument-type-on-non-smp-builds.patch
spinlocks-check-spinlock_t-rwlock_t-argument-type-on-non-smp-builds-v3.patch
waitqueues-give-waitqueue-spinlocks-their-own-lockdep-classes-checkpatch-fixes.patch
kernel-profilec-switch-proc-irq-prof_cpu_mask-to-seq_file.patch

  -> Martin

scsi-use-the-common-hex_asc-array-rather-than-a-private-one.patch
scsi-gdthc-use-unaligned-access-helpers.patch
scsi-annotate-gdth_rdcap_data-gdth_rdcap16_data-endianness.patch
scsi-add-__init-__exit-macros-to-ibmvstgtc.patch
drivers-scsi-fnic-fnic_scsic-clean-up.patch
ibmmca-buffer-overflow.patch
scsi-eata-fix-buffer-overflow.patch
drivers-scsi-gdthc-fix-buffer-overflow.patch
drivers-scsi-u14-34fc-fix-uffer-overflow.patch
drivers-scsi-lpfc-lpfc_vportc-fix-read-buffer-overflow.patch
osst-fix-read-buffer-overflow.patch
scsi-fix-func-names-in-kernel-doc.patch
gdth-unmap-ccb_phys-when-scsi_add_host-fails-in-gdth_eisa_probe_one.patch
zfcp-test-kmalloc-failure-in-scsi_get_vpd_page.patch
st-fix-test-of-value-range-in-st_set_options.patch
st-fix-test-of-value-range-in-st_set_options-fix.patch
hptiop-add-rr44xx-adapter-support.patch

  -> James

cpqarray-switch-to-seq_file.patch
dac960-switch-to-seq_file.patch
cciss-fix-schedule_timeout-parameters.patch

  -> Jens

sparc32-convert-to-asm-generic-hardirqh.patch

  -> davem

synaptics-touchscreen-for-htc-dream-check-that-smbus-is-available.patch
drivers-staging-octeon-ethernet-rgmiic-dont-ignore-request_irq-return-code.patch
revert-staging-android-lowmemorykillerc-fix-it-for-oom-move-oom_adj-value-from-task_struct-to-mm_struct.patch

  -> gregkh

vfs-fix-vfs_rename_dir-for-fs_rename_does_d_move-filesystems.patch
raw-fix-rawctl-compat-ioctls-breakage-on-amd64-and-itanic.patch
vfs-improve-comment-describing-fget_light.patch
libfs-make-simple_read_from_buffer-conventional.patch
fs-inodec-add-dev-id-and-inode-number-for-debugging-in-init_special_inode.patch
vfs-split-generic_forget_inode-so-that-hugetlbfs-does-not-have-to-copy-it.patch
fs-fix-overflow-in-sys_mount-for-in-kernel-calls.patch
vfs-optimization-for-touch_atime.patch
vfs-optimize-touch_time-too.patch
vfs-optimize-touch_time-too-fix.patch
ecryptfs-another-lockdep-issue.patch
vfs-explicitly-cast-s_maxbytes-in-fiemap_check_ranges.patch
vfs-change-sb-s_maxbytes-to-a-loff_t.patch
vfs-remove-redundant-position-check-in-do_sendfile.patch
fs-remove-unneeded-dcache_unhashed-tricks.patch
fs-improve-remountro-vs-buffercache-coherency.patch
fs-improve-remountro-vs-buffercache-coherency-fix.patch
fs-new-truncate-helpers.patch
fs-use-new-truncate-helpers.patch
fs-introduce-new-truncate-sequence.patch
fs-convert-simple-fs-to-new-truncate.patch
tmpfs-convert-to-use-the-new-truncate-convention.patch
ext2-convert-to-use-the-new-truncate-convention.patch
ext2-convert-to-use-the-new-truncate-convention-fix.patch
fat-convert-to-use-the-new-truncate-convention.patch
btrfs-convert-to-use-the-new-truncate-convention.patch
jfs-convert-to-use-the-new-truncate-convention.patch
udf-convert-to-use-the-new-truncate-convention.patch
minix-convert-to-use-the-new-truncate-convention.patch
vfs-fix-d_path-for-unreachable-paths.patch
seq_file-return-a-negative-error-code-when-seq_path_root-fails.patch
vfs-seq_file-add-helpers-for-data-filling.patch
vfs-revert-proc-mounts-to-old-behavior-for-unreachable-mountpoints.patch
vfs-no-unreachable-prefix-for-sysvipc-maps-in-proc-pid-maps.patch
libfs-return-error-code-on-failed-attr-set.patch
const-make-struct-super_block-dq_op-const.patch
const-make-struct-super_block-s_qcop-const.patch
const-mark-remaining-super_operations-const.patch
const-mark-remaining-export_operations-const.patch
const-mark-remaining-address_space_operations-const.patch
const-mark-remaining-inode_operations-as-const.patch
const-make-file_lock_operations-const.patch
const-make-lock_manager_operations-const.patch
const-make-block_device_operations-const.patch

  Lots of VFS changes.  As viro has recently reappeared I'll me sending
  them in his direction, but there's a lot of material here.

xtensa-use-generic-sys_pipe.patch
xtensa-convert-to-asm-generic-hardirqh.patch

  -> chris

percpu-avoid-calling-__pcpu_ptr_to_addrnull.patch

  -> Rusty/Tejun

tty-fix-regression-caused-by-tty-make-the-kref-destructor-occur-asynchronously.patch

  I think this might be "wrong".  Shall scare gregkh with it.

x86-_end-symbol-missing-from-symbolmap.patch

  Need to work out what to do about this.

hwpoison-fix-uninitialized-warning.patch

  -> Andi

mm-make-swap-token-dummies-static-inlines.patch
mm-make-swap-token-dummies-static-inlines-fix.patch
mm-make-swap-token-dummies-static-inlines-fix-2.patch
mm-remove-obsoleted-alloc_pages-cpuset-comment.patch
readahead-add-blk_run_backing_dev.patch
readahead-add-blk_run_backing_dev-fix.patch
readahead-add-blk_run_backing_dev-fix-fix-2.patch
memory-hotplug-update-zone-pcp-at-memory-online.patch
memory-hotplug-update-zone-pcp-at-memory-online-fix.patch
memory-hotplug-exclude-isolated-page-from-pco-page-alloc.patch
memory-hotplug-make-pages-from-movable-zone-always-isolatable.patch
#memory-hotplug-alloc-page-from-other-node-in-memory-online.patch: cl had query
memory-hotplug-alloc-page-from-other-node-in-memory-online.patch
memory-hotplug-migrate-swap-cache-page.patch
page_alloc-fix-kernel-doc-warning.patch
revert-hugetlb-restore-interleaving-of-bootmem-huge-pages-2631.patch
hugetlb-balance-freeing-of-huge-pages-across-nodes.patch
hugetlb-use-free_pool_huge_page-to-return-unused-surplus-pages.patch
hugetlb-use-free_pool_huge_page-to-return-unused-surplus-pages-fix.patch
hugetlb-clean-up-and-update-huge-pages-documentation.patch
hugetlb-restore-interleaving-of-bootmem-huge-pages.patch
mm-clean-up-page_remove_rmap.patch
mm-show_free_areas-display-slab-pages-in-two-separate-fields.patch
documentation-memorytxt-remove-some-very-outdated-recommendations.patch
mm-oom-analysis-add-per-zone-statistics-to-show_free_areas.patch
mm-oom-analysis-add-buffer-cache-information-to-show_free_areas.patch
mm-oom-analysis-show-kernel-stack-usage-in-proc-meminfo-and-oom-log-output.patch
mm-oom-analysis-add-shmem-vmstat.patch
mm-update-alloc_flags-after-oom-killer-has-been-called.patch
mm-rename-pgmoved-variable-in-shrink_active_list.patch
mm-shrink_inactive_list-nr_scan-accounting-fix-fix.patch

  Memory Management...

#mm-vmstat-add-isolate-pages.patch: Hugh dislikes
mm-vmstat-add-isolate-pages.patch
mm-vmstat-add-isolate-pages-fix.patch

  This needs updating

vmscan-throttle-direct-reclaim-when-too-many-pages-are-isolated-already.patch
mm-remove-__addsub_zone_page_state.patch
vm-document-that-setting-vfs_cache_pressure-to-0-isnt-a-good-idea.patch
mm-count-only-reclaimable-lru-pages-v2.patch
vmscan-dont-attempt-to-reclaim-anon-page-in-lumpy-reclaim-when-no-swap-space-is-avilable.patch
vmscan-move-clearpageactive-from-move_active_pages-to-shrink_active_list.patch
vmscan-kill-unnecessary-page-flag-test.patch
vmscan-kill-unnecessary-prefetch.patch
mm-add-gfp-mask-checking-for-__get_free_pages.patch
vmallocc-fix-double-error-checking.patch
mm-perform-non-atomic-test-clear-of-pg_mlocked-on-free.patch
ksm-add-mmu_notifier-set_pte_at_notify.patch
ksm-first-tidy-up-madvise_vma.patch
ksm-define-madv_mergeable-and-madv_unmergeable.patch
ksm-the-mm-interface-to-ksm.patch
ksm-no-debug-in-page_dup_rmap.patch
ksm-identify-pageksm-pages.patch
ksm-kernel-samepage-merging.patch
ksm-prevent-mremap-move-poisoning.patch
ksm-change-copyright-message.patch
ksm-change-ksm-nice-level-to-be-5.patch
ksm-rename-kernel_pages_allocated.patch
ksm-move-pages_sharing-updates.patch
ksm-pages_unshared-and-pages_volatile.patch
ksm-break-cow-once-unshared.patch
ksm-keep-quiet-while-list-empty.patch
ksm-five-little-cleanups.patch
ksm-fix-endless-loop-on-oom.patch
ksm-distribute-remove_mm_from_lists.patch
ksm-fix-oom-deadlock.patch
ksm-fix-deadlock-with-munlock-in-exit_mmap.patch
ksm-sysfs-and-defaults.patch
ksm-add-some-documentation.patch
ksm-remove-vm_mergeable_flags.patch
ksm-clean-up-obsolete-references.patch
ksm-unmerge-is-an-origin-of-ooms.patch
ksm-mremap-use-err-from-ksm_madvise.patch
mm-warn-once-when-a-page-is-freed-with-pg_mlocked-set.patch
pagemap-clear_refs-modify-to-specify-anon-or-mapped-vma-clearing.patch
mm-kmem_cache_create-make-it-easier-to-catch-null-cache-names.patch
page-allocator-change-migratetype-for-all-pageblocks-within-a-high-order-page-during-__rmqueue_fallback.patch
page-allocator-change-migratetype-for-all-pageblocks-within-a-high-order-page-during-__rmqueue_fallback-fix.patch
vmalloc-unmap-vmalloc-area-after-hiding-it.patch
revert-proc-kcore-work-around-a-bug.patch
kcore-fix-vread-vwrite-to-be-aware-of-holes.patch
kcore-fix-vread-vwrite-to-be-aware-of-holes-update.patch
kcore-proc-kcore-should-use-vread.patch
arches-drop-superfluous-casts-in-nr_free_pages-callers.patch
arches-drop-superfluous-casts-in-nr_free_pages-callers-checkpatch-fixes.patch
page-allocator-remove-dead-function-free_cold_page.patch
tracing-page-allocator-add-trace-events-for-page-allocation-and-page-freeing.patch
tracing-page-allocator-add-trace-events-for-anti-fragmentation-falling-back-to-other-migratetypes.patch
tracing-page-allocator-add-trace-event-for-page-traffic-related-to-the-buddy-lists.patch
tracing-page-allocator-add-trace-event-for-page-traffic-related-to-the-buddy-lists-fix.patch
tracing-page-allocator-add-a-postprocessing-script-for-page-allocator-related-ftrace-events.patch
tracing-documentation-add-a-document-describing-how-to-do-some-performance-analysis-with-tracepoints.patch
tracing-documentation-add-a-document-on-the-kmem-tracepoints.patch
mm-add_to_swap_cache-must-not-sleep.patch
mm-add_to_swap_cache-does-not-return-eexist.patch
mm-add_to_swap_cache-does-not-return-eexist-fix.patch
mm-includecheck-fix-for-mm-shmemc.patch
mm-includecheck-fix-for-mm-nommuc.patch
md-avoid-use-of-broken-kzalloc-mempool.patch
mm-remove-broken-kzalloc-mempool.patch
mm-drop-unneeded-double-negations.patch
mm-introduce-page_lru_base_type.patch
mm-introduce-page_lru_base_type-fix.patch
mm-return-boolean-from-page_is_file_cache.patch
mm-return-boolean-from-page_has_private.patch
mm-document-is_page_cache_freeable.patch
page-allocator-limit-the-number-of-migrate_reserve-pageblocks-per-zone.patch
memory-hotplug-fix-updating-of-num_physpages-for-hot-plugged-memory.patch
mm-replace-various-uses-of-num_physpages-by-totalram_pages.patch
mm-dont-use-alloc_bootmem_low-where-not-strictly-needed.patch
mm-also-use-alloc_large_system_hash-for-the-pid-hash-table.patch
mm-vmscan-rename-zone_nr_pages-to-zone_lru_nr_pages.patch
oom-move-oom_killer_enable-oom_killer_disable-to-where-they-belong.patch
mm-do-batched-scans-for-mem_cgroup.patch
mm-vmscan-remove-page_queue_congested-comment.patch
hugetlbfs-allow-the-creation-of-files-suitable-for-map_private-on-the-vfs-internal-mount.patch
hugetlb-add-map_hugetlb-for-mmaping-pseudo-anonymous-huge-page-regions.patch
hugetlb-add-map_hugetlb-for-mmaping-pseudo-anonymous-huge-page-regionspatch-in-mm-fix.patch
hugetlb-add-map_hugetlb-example.patch
oom-move-oom_adj-value-from-task_struct-to-signal_struct.patch
oom-move-oom_adj-value-from-task_struct-to-signal_struct-fix.patch
oom-make-oom_score-to-per-process-value.patch
oom-oom_kill-doesnt-kill-vfork-parentor-child.patch
oom-fix-oom_adjust_write-input-sanity-check.patch
page-allocator-split-per-cpu-list-into-one-list-per-migrate-type.patch
page-allocator-maintain-rolling-count-of-pages-to-free-from-the-pcp.patch
page-allocator-maintain-rolling-count-of-pages-to-free-from-the-pcp-checkpatch-fixes.patch
mm-vsmcan-check-shrink_active_list-sc-isolate_pages-return-value.patch
mm-fix-numa-accounting-in-numastattxt.patch
mm-munlock-use-follow_page.patch
mm-remove-unused-gup-flags.patch
mm-add-get_dump_page.patch
mm-foll_dump-replace-foll_anon.patch
mm-follow_hugetlb_page-flags.patch
mm-fix-anonymous-dirtying.patch
mm-reinstate-zero_page.patch
mm-foll-flags-for-gup-flags.patch
mm-munlock-avoid-zero_page.patch
mm-hugetlbfs_pagecache_present.patch
mm-zero_page-without-pte_special.patch
mm-move-highest_memmap_pfn.patch
mmap-remove-unnecessary-code.patch
tmpfs-depend-on-shmem.patch
mm-make-vmalloc_user-align-base-kernel-virtual-address-to-shmlba.patch
perf-allocate-mmap-buffer-using-vmalloc_user.patch
mmap-avoid-unnecessary-anon_vma-lock-acquisition-in-vma_adjust.patch
mmap-avoid-unnecessary-anon_vma-lock-acquisition-in-vma_adjust-tweak.patch
mmap-save-some-cycles-for-the-shared-anonymous-mapping.patch

 More Memory Management.

 I think I'll merge pretty much all the above.  A few bits and pieces
 need some additional confirmation.

dev-mem-remove-redundant-test-on-len.patch
dev-mem-introduce-size_inside_page.patch
dev-mem-cleanup-unxlate_dev_mem_ptr-calls.patch
dev-mem-cleanup-unxlate_dev_mem_ptr-calls-fix.patch
dev-mem-cleanup-unxlate_dev_mem_ptr-calls-fix-fix.patch
dev-mem-make-size_inside_page-logic-straight.patch
dev-mem-remove-the-written-variable-in-write_kmem.patch
dev-mem-remove-the-written-variable-in-write_kmem-fix.patch
dev-mem-remove-redundant-parameter-from-do_write_kmem.patch

  These seem a bit green so not yet..

frv-duplicate-output_buffer-of-e03.patch
frv-duplicate-output_buffer-of-e03-checkpatch-fixes.patch

  We don't know what to do with these - might drop.

frv-convert-to-asm-generic-hardirqh.patch

  Send to dhowells.

blackfin-convert-to-use-arch_gettimeoffset.patch
blackfin-fix-read-buffer-overflow.patch

  -> blackfin guys

h8300-convert-to-asm-generic-hardirqh.patch

   -> ysato

alpha-convert-to-use-arch_gettimeoffset.patch
arch-alpha-boot-tools-objstripc-wrong-variable-tested-after-open.patch
alpha-use-printk_once.patch
alpha-convert-to-asm-generic-hardirqh.patch

  Merge

m32r-remove-redundant-tests-on-unsigned.patch
m32r-convert-to-use-arch_gettimeoffset.patch
m32r-convert-to-asm-generic-hardirqh.patch

  -> takata

m68k-convert-to-use-arch_gettimeoffset.patch
m68k-convert-to-asm-generic-hardirqh.patch

  -> geert

cris-convert-to-use-arch_gettimeoffset.patch

  -> CRIS maintainers

um-convert-to-asm-generic-hardirqh.patch
uml-fix-order-of-pud-and-pmd_free.patch

  Merge

printk-boot_delay-rename-printk_delay_msec-to-loops_per_msec.patch
printk-boot_delay-rename-printk_delay_msec-to-loops_per_msec-fix.patch
printk-boot_delay-rename-printk_delay_msec-to-loops_per_msec-fix-2.patch
printk-add-printk_delay-to-make-messages-readable-for-some-scenarios.patch
printk-add-printk_delay-to-make-messages-readable-for-some-scenarios-fix.patch
printk-add-printk_delay-to-make-messages-readable-for-some-scenarios-cleanup.patch
move-magic-numbers-into-magich.patch
move-magic-numbers-into-magich-update.patch
kmod-fix-race-in-usermodehelper-code.patch
dac960-fix-undefined-behavior-on-empty-string.patch
fix-all-wmissing-prototypes-warnings-in-x86-defconfig.patch
generic-ipi-make-struct-call_function_data-lockless.patch
generic-ipi-make-struct-call_function_data-lockless-cleanup.patch
dme1737-keep-index-within-pwm_config.patch
documentation-fix-warnings-from-wmissing-prototypes-in-hostcflags.patch
seq_file-constify-seq_operations.patch
proc-connector-add-event-for-process-becoming-session-leader.patch
printk_once-use-bool-for-boolean-flag.patch
misc-remove-redundant-start_kernel-prototypes.patch
fs-turn-iprune_mutex-into-rwsem.patch
fs-bufferc-clean-up-export-macros.patch
build_bug_on-fix-it-and-a-couple-of-bogus-uses-of-it.patch
aioc-move-export-macros-to-line-after-function.patch
maintainers-remove-dead-ncpfs-list.patch
anonfd-split-interface-into-file-creation-and-install.patch
ntfs-remove-ntfs_file_write.patch
qnx4-remove-write-support.patch
vlynq-includecheck-fix-drivers-vlynq-vlynqc.patch
fix-compat_sys_utimensat.patch
make-sure-the-value-in-abs-does-not-get-truncated-if-it-is-greater-than-232.patch

  Misc.  Shall merge, subjet to re-review.

generic-ipi-cleanup-for-generic_smp_call_function_interrupt.patch
kernel-smpc-relocate-some-code.patch

  -> tglx. mingo

maintainers-add-ipvs-include-files.patch
scripts-get_maintainerpl-add-git-blame.patch
scripts-get_maintainerpl-add-sections-in-pattern-match-depth-order.patch
scripts-get_maintainerpl-add-pattern-depth.patch
scripts-get_maintainerpl-better-email-routines-use-perl-not-shell-where-possible.patch
scripts-get_maintainerpl-add-mailmap-use-shell-and-email-cleanups.patch
scripts-get_maintainerpl-using-separator-implies-nomultiline.patch
scripts-get_maintainerpl-add-remove-duplicates.patch
scripts-get_maintainerpl-add-maintainers-in-order-listed-in-matched-section.patch
maintainers-acpi-add-include-acpi.patch
maintainers-omap-fix-regex.patch
maintainers-integrate-p-m-lines.patch

  Merge

getrusage-fill-ru_maxrss-value.patch
getrusage-fill-ru_maxrss-value-update.patch

  Merge, subject to rechecking

vsprintf-use-warn_on_once.patch
flex_array-add-flex_array_clear-function.patch
flex_array-poison-free-elements.patch
flex_array-add-flex_array_shrink-function.patch
flex_array-introduce-define_flex_array.patch
flex_array-add-missing-kerneldoc-annotations.patch

  Merge

asm-sections-add-text-data-checking-functions-for-arches-to-override.patch
kallsyms-use-new-arch_is_kernel_text.patch
lockdep-use-new-arch_is_kernel_data.patch
blackfin-override-text-data-checking-functions.patch

  Need to recheck all this with relevant arch people.

mmc-in-mmc_power_up-use-previously-selected-ocr-if-available.patch
omap-hsmmc-do-not-enable-buffer-ready-interrupt-if-using-dma.patch
mmc-msm_sdccc-driver-for-htc-dream.patch
msm_sdccc-convert-printkkern_level-to-pr_level.patch
msm_sdccc-stylistic-cleaning.patch
msm_sdccc-move-overly-indented-code-to-separate-function.patch
mmc-register-mmci-omap-hs-using-platform_driver_probe.patch
sdio-do-not-ignore-mmc_vdd_165_195.patch
# mmc-make-the-configuration-memory-resource-optional.patch: bunfight
# "Phillip's comments should be addressed in the next version" -- Paul Mundt
mmc-make-the-configuration-memory-resource-optional.patch
tmio_mmc-optionally-support-using-platform-clock.patch
sh-switch-migo-r-to-use-the-tmio-mmc-driver-instead-of-spi.patch
mmc-add-enable-and-disable-methods-to-mmc-host.patch
mmc-allow-host-claim-release-nesting.patch
mmc-add-mmc_cap_nonremovable-host-capability.patch
mmc-add-ability-to-save-power-by-powering-off-cards.patch
mmc-add-mmc-card-sleep-and-awake-support.patch
mmc-power-off-once-at-removal.patch
mmc-check-status-after-mmc-switch-command.patch
omap_hsmmc-add-debugfs-entry-host-registers.patch
omap_hsmmc-make-use-of-new-enable-disable-interface.patch
arm-omap-mmc-twl4030-add-context-loss-counter-support.patch
omap_hsmmc-keep-track-of-power-mode.patch
omap_hsmmc-context-save-restore-support.patch
omap_hsmmc-set-open-drain-bit-correctly.patch
omap_hsmmc-ensure-workqueues-are-empty-before-suspend.patch
omap_hsmmc-fix-scatter-gather-list-sanity-checking.patch
omap_hsmmc-make-use-of-new-mmc_cap_nonremovable-host-capability.patch
omap_hsmmc-support-for-deeper-power-saving-states.patch
arm-omap-mmc-twl4030-add-regulator-sleep-wake-function.patch
omap_hsmmc-put-mmc-regulator-to-sleep.patch
omap_hsmmc-add-mmc-card-sleep-and-awake-support.patch
omap_hsmmc-fix-null-pointer-dereference.patch
omap_hsmmc-cleanup-macro-usage.patch
omap_hsmmc-clear-interrupt-status-after-init-sequence.patch
omap_hsmmc-cater-for-weird-cmd6-behaviour.patch
omap_hsmmc-prevent-races-with-irq-handler.patch
omap_hsmmc-code-refactoring.patch
omap_hsmmc-protect-the-card-when-the-cover-is-open.patch
omap_hsmmc-ensure-all-clock-enables-and-disables-are-paired.patch
omap_hsmmc-ensure-all-clock-enables-and-disables-are-paired-fix-for-the-db-clock-failure-message.patch
omap_hsmmc-set-a-large-data-timeout-for-commands-with-busy-signal.patch
arm-omap-rx51-set-mmc-capabilities-and-power-saving-flag.patch
arm-omap-rx51-set-mmc-capabilities-and-power-saving-flag-update.patch
maintainers-update-for-ti-omap-hsmmc-driver.patch
sdio-add-cd-disable-support.patch
sdio-add-cd-disable-support-cleanup.patch
sdhci-be-more-strict-with-get_min_clock-usage.patch
sdio-fix-read-buffer-overflow.patch
sdhci-of-fix-sd-clock-calculation.patch
sdhci-of-avoid-writing-reserved-bits-into-host-control-register.patch
sdhci-of-fix-high-speed-cards-recognition.patch
powerpc-introduce-and-document-sdhciwp-inverted-property-for-esdhc.patch
sdhci-of-dont-hard-code-inverted-write-protect-quirk.patch
sdhci-of-cleanup-esdhcs-set_clock-a-little-bit.patch
powerpc-85xx-add-esdhc-support-for-mpc8536ds-boards.patch
sdio-add-mmc_quirk_lenient_fn0.patch
sdio-add-mmc_quirk_lenient_fn0-fix.patch
atmel-mci-unified-atmel-mci-drivers-avr32-at91.patch
at91-atmel-mci-platform-configuration-to-the-the-atmel-mci-driver.patch
at91-atmel-mci-platform-configuration-to-the-the-atmel-mci-driver-checkpatch-fixes.patch
sdhci-add-no-card-no-reset-quirk-for-ricoh-r5c822-sony-z11.patch
omap4-mmc-driver-support-on-omap4.patch
mmc_spi-fail-gracefully-if-host-or-card-do-not-support-the-switch-command.patch
#sdio-recognize-io-card-without-powercycle.patch, etc: check with Pierre
sdio-recognize-io-card-without-powercycle.patch
sdio-pass-whitelisted-cis-funce-tuples-to-sdio-drivers.patch

  MMC.  Merge, subject to the couple of caveats above.

checkpatch-possible-types-else-cannot-start-a-type.patch
checkpatch-handle-c99-comments-correctly-performance-issue.patch
checkpatch-indent-checks-stop-when-we-run-out-of-continuation-lines.patch
checkpatch-make-f-alias-file-add-help-more-verbose-help-message.patch
checkpatch-format-strings-should-not-have-brackets-in-macros.patch
checkpatch-limit-sn-un-matches-to-actual-bit-sizes.patch
checkpatch-version-029.patch
checkpatch-add-some-common-blackfin-checks.patch

  Grumpy.  These spit perl warnings but maintainer won't talk to me.

poll-select-avoid-arithmetic-overflow-in-__estimate_accuracy.patch

  Merge

#drivers-hwmon-coretempc-enable-the-intel-atom.patch: needs checking
drivers-hwmon-coretempc-enable-the-intel-atom.patch
lis3-fix-typo.patch
lis3-add-free-fall-wakeup-function-via-platform_data.patch
lis3-add-power-management-functions.patch
lis3-add-power-management-functions-fix.patch
lis3_spi-code-cleanups.patch
drivers-hwmon-adm1021c-support-high-precision-adm1023-remote-sensor.patch
drivers-hwmon-adm1021c-add-low_power-support-for-adm1021-driver.patch
drivers-hwmon-adm1021c-add-low_power-support-for-adm1021-driver-update.patch
hwmon-fix-freeing-of-gpio_data-and-irq.patch
hwmon-applesmc-restore-accelerometer-and-keyboard-backlight-on-resume.patch
#hwmon-driver-for-texas-instruments-amc6821-chip.patch: updates needed
hwmon-driver-for-texas-instruments-amc6821-chip.patch

  Merge, with caveats.

proc-fix-reported-unit-for-rlimit_cpu.patch
proc_flush_task-flush-proc-tid-task-pid-when-a-sub-thread-exits.patch
#kcore-fix-proc-kcores-statst_size.patch: is it right?
kcore-fix-proc-kcores-statst_size.patch
fs-proc-task_mmuc-v1-fix-clear_refs_write-input-sanity-check.patch
fs-proc-basec-fix-proc_fault_inject_write-input-sanity-check.patch
#
#procfs-provide-stack-information-for-threads-v08.patch: needs a bit of thought still. Buggy?
#procfs-provide-stack-information-for-threads-v08.patch: Valdis.Kletnieks@vt.edu probs?
procfs-provide-stack-information-for-threads-v08.patch
procfs-provide-stack-information-for-threads-v011.patch
procfs-provide-stack-information-for-threads-v011-fix.patch

  procfs.  Will try to merge but there are still some question marks.

kcore-use-usual-list-for-kclist.patch
kcore-add-kclist-types.patch
kcore-register-vmalloc-area-in-generic-way.patch
kcore-register-text-area-in-generic-way.patch
#walk-system-ram-range.patch: busted (Hugh)
walk-system-ram-range.patch
kcore-use-registerd-physmem-information.patch
kcore-use-registerd-physmem-information-ia64-fix.patch
kcore-register-vmemmap-range.patch
kcore-register-vmemmap-range-fix.patch
kcore-register-module-area-in-generic-way.patch

  This is a bt green and Hugh found a bug.  Dunno yet.

ramfs-move-ramfs_magic-to-include-linux-magich.patch

  Merge

ncpfs-read-buffer-overflow.patch
ncpfs-remove-dead-url-from-documentation.patch
ncpfs-fix-wrong-check-in-__ncp_ioctl.patch

  Merge

spi-remove-imx-spi-driver.patch
spi-omap2_mcspi-use-bitn.patch
spi-add-spi_ppc4xx-driver.patch
spih-add-missing-kernel-doc-for-struct-spi_master.patch
spi-add-default-selection-of-pl022-for-arm-reference-platforms.patch
#spi-add-spi-driver-for-most-known-imx-socs.patch: akpm comments
spi-add-spi-driver-for-most-known-imx-socs.patch
spi-add-support-for-device-table-matching.patch
#mtd-m25p80-convert-to-device-table-matching.patch: david-b wanted update?
mtd-m25p80-convert-to-device-table-matching.patch
of-remove-stmm25p40-alias.patch
hwmon-adxx-convert-to-device-table-matching.patch
hwmon-lm70-convert-to-device-table-matching.patch
spi-prefix-modalias-with-spi.patch
pxa2xx_spi-register-earlier.patch
spi-fix-spelling-of-automatically-in-documentation.patch
spi_s3c24xx-fix-header-includes.patch
spi_s3c24xx-use-resource_size-to-get-resource-size.patch
spi_s3c24xx-use-dev_pm_ops.patch
spi_s3c24xx-cache-device-setup-data.patch
spi-freescale-stmp-driver.patch
spi-mcspi-off-mode-support.patch
spi-mcspi-saves-chconfx-too.patch
spi-mcspi-support-for-omap4.patch
spi-handle-tx-only-rx-only.patch
rtc-philips-pcf2123-rtc-spi-driver.patch
rtc-philips-pcf2123-rtc-spi-driver-updates.patch

  SPI.  Mostly merge - there are a couple of things to check.

kprobes-use-do_irq-in-lkdtm.patch

  Merge.

smbfs-read-buffer-overflow.patch

  Merge

rtc-add-driver-for-mxcs-internal-rtc-module.patch
rtc-add-driver-for-mxcs-internal-rtc-module-fix.patch
rtc-add-driver-for-mxcs-internal-rtc-module-fix-fix.patch
rtc-u300-coh-901-331-rtc-driver-v3.patch
rtc-update-documentation-wrt-rtc_pie-irq_set_state.patch
rtc-bfin-do-not-share-rtc-irq.patch
rtc-add-freescale-stmp37xx-378x-driver.patch
rtc-reorder-makefile.patch
rtc-driver-for-pcap2-pmic.patch
rtc-driver-for-pcap2-pmic-update.patch
rtc-driver-for-pcap2-pmic-get-pcap-data-from-the-parent-device.patch
drivers-rtc-correct-error-handling-code.patch
drivers-rtc-introduce-missing-kfree.patch
rtc-at91rm9200-fixes.patch
#rtc-set-wakeup-capability-for-i2c-and-spi-rtc-drivers.patch: david-b issues
rtc-set-wakeup-capability-for-i2c-and-spi-rtc-drivers.patch
rtc-document-the-sysfs-interface.patch
rtc-add-hctosys-sysfs-attribute.patch

  RTC: mostly-merge.

gpiolib-allow-exported-gpio-nodes-to-be-named-using-sysfs-links.patch
gpiolib-allow-exported-gpio-nodes-to-be-named-using-sysfs-links-update.patch
gpiolib-allow-exported-gpio-nodes-to-be-named-using-sysfs-links-update-fix.patch
gpio-add-mc33880-driver.patch
mfd-gpio-add-a-gpio-interface-to-the-ucb1400-mfd-chip-driver-via-gpiolib.patch
gpio-add-intel-moorestown-platform-langwell-chip-gpio-driver.patch
gpio-add-intel-moorestown-platform-langwell-chip-gpio-driver-fix.patch
gpio-pca953x-add-support-for-max7315.patch
gpio-include-linux-gpioh-not-asm-gpioh.patch
#gpiolib-add-names-file-in-gpio-chip-sysfs.patch: david-b issues
gpiolib-add-names-file-in-gpio-chip-sysfs.patch
gpiolib-add-names-file-in-gpio-chip-sysfs-checkpatch-fixes.patch
gpiolib-add-names-file-in-gpio-chip-sysfs-checkpatch-fixes-fix.patch
gpiolib-allow-poll-on-value.patch

  gpio.  mostly-merge after checking with David.

omapfb-add-support-for-the-apollon-lcd.patch
omapfb-add-support-for-mipi-dcs-compatible-lcds.patch
omapfb-add-support-for-the-amstrad-delta-lcd.patch
omapfb-add-support-for-the-2430sdp-lcd.patch
omapfb-add-support-for-the-omap2evm-lcd.patch
omapfb-add-support-for-the-3430sdp-lcd.patch
omapfb-add-support-for-the-omap3-evm-lcd.patch
omapfb-add-support-for-the-omap3-beagle-dvi-output.patch
omapfb-add-support-for-the-gumstix-overo-lcd.patch
omapfb-add-support-for-the-zoom-mdk-lcd.patch
omapfb-add-support-for-rotation-on-the-blizzard-lcd-ctrl.patch
n770-enable-lcd-mipi-dcs-in-kconfig.patch
omapfb-dispc-various-typo-fixes.patch
omapfb-dispc-disable-iface-clocks-along-with-func-clocks.patch
omapfb-dispc-enable-wake-up-capability.patch
omapfb-dispc-allow-multiple-external-irq-handlers.patch
omapfb-suspend-resume-only-if-fb-device-is-already-initialized.patch
omapfb-fix-coding-style-remove-dead-line.patch
omapfb-add-fb-manual-update-option-to-kconfig.patch
omapfb-hwa742-fix-pointer-to-be-const.patch
atyfb-coding-style-cleanup.patch
#framebuffer-support-for-htc-dream.patch: new version coming from Dima?
framebuffer-support-for-htc-dream.patch
framebuffer-support-for-htc-dream-checkpatch-fixes.patch
platinumfb-misplaced-parenthesis.patch
davinci-fb-frame-buffer-driver-for-ti-da8xx-omap-l1xx.patch
davinci-fb-frame-buffer-driver-for-ti-da8xx-omap-l1xx-v4.patch
davinci-fb-frame-buffer-driver-for-ti-da8xx-omap-l1xx-v4-cleanup.patch
davinci-fb-frame-buffer-driver-for-ti-da8xx-omap-l1xx-v5.patch
sisfb-read-buffer-overflow.patch
ep93xx-video-driver-platform-support.patch
ep93xx-video-driver.patch
ep93xx-video-driver-documentation.patch
viafb-remove-duplicated-cx700-register-init.patch
viafb-remove-temporary-start-address-setting.patch
viafb-merge-viafb_update_viafb_par-in-viafb_update_fix.patch
viafb-split-viafb_set_start_addr-up.patch
viafb-fix-ioremap_nocache-error-handling.patch
viafb-clean-up-viamodeh.patch
viafb-remove-duplicated-mode-information.patch
viafb-clean-up-duoview.patch
viafb-clean-up-virtual-memory-handling.patch
viafb-remove-unused-video-device-stuff.patch
viafb-remove-lvds-initialization.patch
viafb-another-small-cleanup-of-viafb_par.patch
viafb-improve-viafb_par.patch
viafb-2d-engine-rewrite.patch
viafb-2d-engine-rewrite-v2.patch
viafb-switch-to-seq_file.patch
viafb-cleanup-viafb_cursor.patch
viafb-improve-pitch-handling.patch
viafb-hardware-acceleration-initialization-cleanup.patch
viafb-make-module-parameters-visible-in-sysfs.patch
viafb-remove-unused-structure-member.patch
viafb-use-read-only-mode-parsing.patch
viafb-add-support-for-the-vx855-chipset.patch
viafb-choose-acceleration-engine-for-vx855.patch
viafb-make-viafb-a-first-class-citizen-using-pci_driver.patch
viafb-pass-reference-to-pci-device-when-calling-framebuffer_alloc.patch
drivers-video-console-newport_conc-fix-read-outside-array-bounds.patch
drivers-video-add-kmalloc-null-tests.patch
drivers-video-add-kmalloc-null-tests-fix.patch
fb-fix-fb_pan_display-range-check.patch
video-console-use-div_round_up.patch
s3c2410fb-fix-clockrate-calculation.patch
fb-do-not-ignore-fb_set_par-errors.patch
matroxfb-make-config_fb_matrox_multihead=y-mandatory.patch
matroxfb-get-rid-of-unneeded-macros-access_fbinfo-and-minfo.patch
matroxfb-get-rid-of-unneeded-macros-wpminfo-and-friends.patch
matroxfb-get-rid-of-unneeded-macro-minfo_from.patch
matroxfb-get-rid-of-config_fb_matrox_32mb.patch
fbcon-only-unbind-from-console-if-successfully-registered.patch

  fbdev.  Mostly-merge.

#
#intelfb-fix-setting-of-active-pipe-with-lvds-displays.patch: would like testing
intelfb-fix-setting-of-active-pipe-with-lvds-displays.patch

  This is being a problem.

v3-minixfs-add-missing-directory-type-checking.patch
v3-minixfs-add-missing-directory-type-checking-checkpatch-fixes.patch

  Merge

ext2-fix-format-string-compile-warning-ino_t.patch

  Merge

jbdh-bitfields-should-be-unsigned.patch

  Merge

hfsplus-identify-journal-info-block-in-volume-header.patch
#hfsplus-fix-journal-detection.patch: Roman had q?
hfsplus-fix-journal-detection.patch

  Roman's vanished and he had obscure issues with these.  Help.

reiserfs-remove-proc-fs-reiserfs-version.patch
reiserfs-dont-compile-procfso-at-all-if-no-support.patch

  Send to Jeff

time-add-function-to-convert-between-calendar-time-and-broken-down-time-for-universal-use.patch
fatfs-use-common-time_to_tm-in-fat_time_unix2fat.patch

  Send to Ogawa

doc-filesystems-remove-smount-program.patch
doc-filesystems-more-mount-cleanups.patch
documentation-update-stale-definition-of-file-nr-in-fstxt.patch
includecheck-fix-documentation-cfag12864b-examplec.patch
documentation-vm-gitignore-add-page-types.patch
page-types-add-feature-for-walking-process-address-space.patch
page-types-add-feature-for-walking-process-address-space-checkpatch-fixes.patch
docs-fix-various-documentation-paths-in-header-files.patch

  merge

cgroups-make-unlock-sequence-in-cgroup_get_sb-consistent.patch
cgroups-support-named-cgroups-hierarchies.patch
cgroups-move-the-cgroup-debug-subsys-into-cgroupc-to-access-internal-state.patch
cgroups-add-a-back-pointer-from-struct-cg_cgroup_link-to-struct-cgroup.patch
cgroups-allow-cgroup-hierarchies-to-be-created-with-no-bound-subsystems.patch
cgroups-revert-cgroups-fix-pid-namespace-bug.patch
cgroups-add-a-read-only-procs-file-similar-to-tasks-that-shows-only-unique-tgids.patch
cgroups-ensure-correct-concurrent-opening-reading-of-pidlists-across-pid-namespaces.patch
cgroups-use-vmalloc-for-large-cgroups-pidlist-allocations.patch
cgroups-change-css_set-freeing-mechanism-to-be-under-rcu.patch
cgroups-let-ss-can_attach-and-ss-attach-do-whole-threadgroups-at-a-time.patch
cgroups-let-ss-can_attach-and-ss-attach-do-whole-threadgroups-at-a-time-fix.patch
#cgroups-add-functionality-to-read-write-lock-clone_thread-forking-per-threadgroup.patch: Oleg conniptions
cgroups-add-functionality-to-read-write-lock-clone_thread-forking-per-threadgroup.patch
cgroups-add-functionality-to-read-write-lock-clone_thread-forking-per-threadgroup-fix.patch
cgroups-add-ability-to-move-all-threads-in-a-process-to-a-new-cgroup-atomically.patch

  Merge after checking with Oleg.

memcg-remove-the-overhead-associated-with-the-root-cgroup.patch
memcg-remove-the-overhead-associated-with-the-root-cgroup-fix.patch
memcg-remove-the-overhead-associated-with-the-root-cgroup-fix-2.patch
#memcg-add-comments-explaining-memory-barriers.patch: needs update (Balbir)
memcg-add-comments-explaining-memory-barriers.patch
memcg-add-comments-explaining-memory-barriers-checkpatch-fixes.patch
memory-controller-soft-limit-documentation-v9.patch
memory-controller-soft-limit-interface-v9.patch
memory-controller-soft-limit-organize-cgroups-v9.patch
memory-controller-soft-limit-organize-cgroups-v9-fix.patch
memory-controller-soft-limit-refactor-reclaim-flags-v9.patch
memory-controller-soft-limit-reclaim-on-contention-v9.patch
memory-controller-soft-limit-reclaim-on-contention-v9-fix.patch
memory-controller-soft-limit-reclaim-on-contention-v9-fix-softlimit-css-refcnt-handling.patch
memory-controller-soft-limit-reclaim-on-contention-v9-fix-softlimit-css-refcnt-handling-fix.patch
memcg-improve-resource-counter-scalability.patch
memcg-improve-resource-counter-scalability-checkpatch-fixes.patch
memcg-improve-resource-counter-scalability-v5.patch
memcg-show-swap-usage-in-stat-file.patch
memcg-show-swap-usage-in-stat-file-fix.patch

  Merge after checking with Balbir

ptrace-__ptrace_detach-do-__wake_up_parent-if-we-reap-the-tracee.patch
do_wait-wakeup-optimization-shift-security_task_wait-from-eligible_child-to-wait_consider_task.patch
#do_wait-wakeup-optimization-change-__wake_up_parent-to-use-filtered-wakeup.patch: busted (KAMEZAWA)
do_wait-wakeup-optimization-change-__wake_up_parent-to-use-filtered-wakeup.patch
do_wait-wakeup-optimization-change-__wake_up_parent-to-use-filtered-wakeup-selinux_bprm_committed_creds-use-__wake_up_parent.patch
do_wait-wakeup-optimization-child_wait_callback-check-__wnothread-case.patch
do_wait-wakeup-optimization-fix-child_wait_callback-eligible_child-usage.patch
do_wait-wakeup-optimization-simplify-task_pid_type.patch
#do_wait-optimization-do-not-place-sub-threads-on-task_struct-children-list.patch: risky?
do_wait-optimization-do-not-place-sub-threads-on-task_struct-children-list.patch
wait_consider_task-kill-parent-argument.patch
do_wait-fix-sys_waitid-specific-behaviour.patch
wait_noreap_copyout-check-for-wo_info-=-null.patch

  ptrace.  Mostly-merge.

signals-introduce-do_send_sig_info-helper.patch
signals-send_sigio-use-do_send_sig_info-to-avoid-check_kill_permission.patch
fcntl-add-f_etown_ex.patch
signals-inline-__fatal_signal_pending.patch

  Signals.  Merge.

#signals-tracehook_notify_jctl-change.patch: needs changelog folding too
signals-tracehook_notify_jctl-change.patch
signals-tracehook_notify_jctl-change-do_signal_stop-do-not-call-tracehook_notify_jctl-in-task_stopped-state.patch
#signals-introduce-tracehook_finish_jctl-helper.patch: fold into signals-tracehook_notify_jctl-change.patch
signals-introduce-tracehook_finish_jctl-helper.patch
utrace-core.patch

  utrace.  What's happening with this?

exec-make-do_coredump-more-resilient-to-recursive-crashes-v9.patch
exec-make-do_coredump-more-resilient-to-recursive-crashes-v9-checkpatch-fixes.patch
exec-let-do_coredump-limit-the-number-of-concurrent-dumps-to-pipes-v9.patch
exec-let-do_coredump-limit-the-number-of-concurrent-dumps-to-pipes-v9-checkpatch-fixes.patch
exec-allow-do_coredump-to-wait-for-user-space-pipe-readers-to-complete-v9.patch

  coredump.  Merge.

exec-fix-set_binfmt-vs-sys_delete_module-race.patch

  Merge.

elf-clean-up-fill_note_info.patch
elf-clean-up-fill_note_info-fix.patch
#fdpic-ignore-the-loaders-pt_gnu_stack-when-calculating-the-stack-size.patch: pavel unhappy
fdpic-ignore-the-loaders-pt_gnu_stack-when-calculating-the-stack-size.patch

  Elf.  Merge.  See if we can make Pavel happy.

flat-use-is_err_value-helper-macro.patch

  Merge.

dev-zero-avoid-repeated-access_ok-checks.patch
fs-char_devc-remove-useless-loop.patch
pc-fs-char_devc-remove-useless-loop-fix.patch
cyclades-allow-overriding-isa-defaults-also-when-the-driver-is-built-in.patch
mwave-fix-read-buffer-overflow.patch
hpet-hpet-driver-periodic-timer-setup-bug-fixes.patch
drivers-char-rio-rioctrlc-off-by-one-error-in-rioctrlc.patch
drivers-char-uv_mmtimerc-add-memory-mapped-rtc-driver-for-uv.patch

  Merge

maintainers-add-matt-mackall-and-herbert-xu-to-hardware-random-number-generator.patch

  Merge.

sysctl-remove-struct-file-argument-of-proc_handler.patch

  Merge.

fork-disable-clone_parent-for-init.patch
pidns-deny-clone_parentclone_newpid-combination.patch

  Merge.

linux-futexh-place-kernel-types-behind-__kernel__.patch

  Merge

edac-mpc85xx-add-p2020ds-support.patch
edac-mpc85xx-add-mpc83xx-support.patch
edac-fix-resource-size-calculation.patch
edac-i3200-memory-controller-driver.patch
edac-i3200-memory-controller-driver-fix-offset-of-reg-in-i3200_edac-module.patch
edac-core-remove-completion-wait-for-complete-with-rcu_barrier.patch

  Merge

adfs-remove-redundant-test-on-unsigned.patch

  Merge

memstick-move-dev_dbg.patch

  Merge

aio-ifdef-fields-in-mm_struct.patch

  Merge

gru-use-proc_create.patch
gru-allocation-may-fail-in-quicktest1.patch

  Merge

fs-romfs-correct-error-handling-code.patch

  Merge

drivers-vlynq-vlynqc-fix-resource-size-off-by-1-error.patch

  Merge

lzma-gzip-fix-potential-oops-when-input-data-is-truncated.patch
include-linux-unaligned-lbe_byteshifth-fix-usage-for-compressed-kernels.patch

  Merge

task_struct-cleanup-move-binfmt-field-to-mm_struct.patch

  Merge

sound-core-pcm_timerc-use-lib-gcdc.patch
net-netfilter-ipvs-ip_vs_wrrc-use-lib-gcdc.patch
net-netfilter-ipvs-ip_vs_wrrc-use-lib-gcdc-fix.patch

  hm, why do I still have these?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
