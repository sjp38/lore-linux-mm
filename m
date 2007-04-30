Date: Mon, 30 Apr 2007 16:20:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: 2.6.22 -mm merge plans
Message-Id: <20070430162007.ad46e153.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

- If replying, please be sure to cc the appropriate individuals.  Please
  also consider rewriting the Subject: to something appropriate.

- I'll cc linux-mm on this - the memory-management situation is complicated.

- The overall stability in recent -mm's was not sufficiently high and we ran
  out of time to find all the bugs.  I shouldn't have merged all those patches
  last week - they contained an exceptional amount of garbage.

  This all means that more bugs than usual will probably leak into mainline,
  and we'll have to fix them there.

- I've been ducking most non-bugfix patches recently.  I have ~200 feature
  and cleanup patches queued for later consideration, so people who sent those
  will be hearing from me eventually.




 extend-print_symbol-capability.patch
 reiserfs-suppress-lockdep-warning.patch
 rework-pm_ops-pm_disk_mode-kill-misuse.patch
 power-management-remove-firmware-disk-mode.patch
 power-management-implement-pm_opsvalid-for-everybody.patch
 power-management-force-pm_opsvalid-callback-to-be.patch
 add-kvasprintf.patch
 pm-include-eio-from-errno-baseh.patch

Sent

 ia64-race-flushing-icache-in-do_no_page-path.patch

People are still discussing this

 zlib-backout.patch

A huge zlib revert patch.  It's a last resort for bug #8405, which is still
being worked on.  2.6.20.x needs fixing, too.

 networking-fix-sending-netlink-message-when-replace-route.patch

Will send to davem

 slab-introduce-krealloc.patch

Will merge soon

 exit-acpi-processor-module-gracefully-if-acpi-is-disabled.patch

Will send to Len

 remove-unused-header-file-arch-arm-mach-s3c2410-basth.patch
 iop13xx-msi-support-rev6.patch
 arm-remove-useless-config-option-generic_bust_spinlock.patch

Will send to rmk

 cifs-use-mutexdiff.patch
 cifs-use-simple_prepare_write-to-zero-page-data.patch

Will send to sfrench

 macintosh-mediabay-convert-to-kthread-api.patch
 macintosh-adb-convert-to-the-kthread-api.patch
 macintosh-therm_pm72c-partially-convert-to-kthread-api.patch
 powerpc-pseries-rtasd-convert-to-kthread-api.patch
 powerpc-pseries-eeh-convert-to-kthread-api.patch

Will send to paulus (I already did - does Paul not handle the macintosh
driver?)

 revert-gregkh-driver-remove-struct-subsystem-as-it-is-no-longer-needed.patch

This is here because Greg's tree wrecks Dmitry's tree.  Will drop once they
sort it out.

 idr-fix-obscure-bug-in-allocation-path.patch
 idr-separate-out-idr_mark_full.patch
 ida-implement-idr-based-id-allocator.patch
 ida-implement-idr-based-id-allocator-fix.patch

These will go in via Greg's tree.

 fix-sysfs-rom-file-creation-for-bios-rom-shadows.patch
 more-fix-gregkh-driver-sysfs-kill-unnecessary-attribute-owner.patch
 even-more-fix-gregkh-driver-sysfs-kill-unnecessary-attribute-owner.patch
 even-even-more-fix-gregkh-driver-sysfs-kill-unnecessary-attribute-owner.patch
 acpi-driver-model-flags-and-platform_enable_wake.patch
 update-documentation-driver-model-platformtxt.patch
 power-management-remove-some-useless-code-from-arm.patch

Will send to Greg for the driver tree

 git-dvb.patch
 dvb_en_50221-convert-to-kthread-api.patch
 mm-only-saa7134-tvaudio-convert-to-kthread-api.patch
 git-dvb-vs-gregkh-driver-sysfs-kill-unnecessary-attribute-owner.patch

For Mauro

 i2c-tsl2550-support.patch
 apple-smc-driver-hardware-monitoring-and-control.patch

For Jean

 ia64-sn-xpc-convert-to-use-kthread-api.patch
 ia64-sn-xpc-convert-to-use-kthread-api-fix.patch
 ia64-sn-xpc-convert-to-use-kthread-api-fix-2.patch
 spin_lock_unlocked-macro-cleanup-in-arch-ia64.patch

For Tony

 sbp2-include-fixes.patch
 ieee1394-iso-needs-schedh.patch

For Stephan

 input-convert-from-class-devices-to-standard-devices.patch
 input-evdev-implement-proper-locking.patch
 mousedev-fix.patch
 mousedev-fix-2.patch

Dmitry will merge these once Greg has merged the preparatory work.  Except these
patches make the Vaio-of-doom crash in obscure circumstances, and we weren't
able to fix that?

 wistron_btns-add-led-support.patch
 input-ff-add-ff_raw-effect.patch
 input-phantom-add-a-new-driver.patch

For Dmitry

 kconfig-abort-configuration-with-recursive-dependencies.patch
 kbuild-handle-compressed-cpio-initramfs-es.patch

For Sam and Roman

 ahci-crash-fix.patch
 libata-acpi-add-infrastructure-for-drivers-to-use.patch
 pata_acpi-restore-driver.patch
 optional-led-trigger-for-libata.patch
 ata_timing-ensure-t-cycle-is-always-correct.patch
 pata_pcmcia-recognize-2gb-compactflash-from-transcend.patch
 drivers-ata-remove-the-wildcard-from-sata_nv-driver.patch
 pata_icside-driver.patch

ata stuff

 sl82c105-switch-to-ref-counting-api.patch

For Bart

 mmc-omap-add-missing-newline.patch
 mmc-omap-fix-omap-to-use-mmc_power_on.patch
 mmc-omap-clean-up-omap-set_ios-and-make-mmc_power_on.patch

Not sure.  These hit three different subsystems: arm, omap and mmc.  I might
just send them in.

 nommu-present-backing-device-capabilities-for-mtd.patch
 nommu-add-support-for-direct-mapping-through-mtdconcat.patch
 nommu-generalise-the-handling-of-mtd-specific-superblocks.patch
 nommu-make-it-possible-for-romfs-to-use-mtd-devices.patch
 romfs-printk-format-warnings.patch
 dont-force-uclinux-mtd-map-to-be-root-dev.patch

For dwmw2 (again?)

 8139too-force-media-setting-fix.patch
 sundance-change-phy-address-search-from-phy=1-to-phy=0.patch
 forcedeth-improve-napi-logic.patch
 ne-add-platform_driver.patch
 ne-add-platform_driver-fix.patch
 ne-mips-use-platform_driver-for-ne-on-rbtx49xx.patch
 mips-drop-unnecessary-config_isa-from-rbtx49xx.patch
 ibmtr_cs-fix-hang-on-eject.patch

For netdev tree

 2621-rc5-mm3-fix-e1000-compilation.patch

Will re-re-resend to Auke

 ppp_generic-fix-lockdep-warning.patch

Jeff, I guess.  It's not clear that this is correct.

 input-rfkill-add-support-for-input-key-to-control-wireless-radio.patch

Will resend to davem once the preparatory bits are merged by Greg.

 bluetooth-add-sco-work-around-for-the-broadcom.patch

Will resend to Marcel

 fix-i-oat-for-kexec.patch

Will re-re-re-re-resend to Dan

 auth_gss-unregister-gss_domain-when-unloading-module.patch
 nfs-kill-the-obsolete-nfs_paranoia.patch
 nfs-statfs-error-handling-fix.patch
 nfs-use-__set_current_state.patch
 nfs-suppress-warnings-about-nfs4err_old_stateid-in-nfs4_handle_exception.patch

For Trond

 round_up-macro-cleanup-in-drivers-parisc.patch

Will re-re-resend to Kyle.

 pcmcia-pccard-deadlock-fix.patch
 pcmcia-delete-obsolete-pcmcia_ioctl-feature.patch
 at91_cf-minor-fix.patch
 add-new_id-to-pcmcia-drivers.patch
 ide-cs-recognize-2gb-compactflash-from-transcend.patch

Dominik is busy.  Will probably re-review and send these direct to Linus.

 serial-driver-pmc-msp71xx.patch
 rm9000-serial-driver.patch
 serial-define-fixed_port-flag-for-serial_core.patch
 serial-use-resource_size_t-for-serial-port-io-addresses.patch
 mpsc-serial-driver-tx-locking.patch
 serial-suppress-rts-assertion-with-disabled-crtscts.patch
 8250_pci-fix-pci-must_checks.patch

Seems that I'm maintaining serial now.  Will re-review, re-check with rmk then
send.

 fix-gregkh-pci-pci-remove-the-broken-pci_multithread_probe-option.patch
 remove-pci_dac_dma_-apis.patch
 round_up-macro-cleanup-in-drivers-pci.patch
 pcie-remove-spin_lock_unlocked.patch
 cpqphp-partially-convert-to-use-the-kthread-api.patch
 ibmphp-partially-convert-to-use-the-kthreads-api.patch
 cpci_hotplug-partially-convert-to-use-the-kthread-api.patch
 msi-fix-arm-compile.patch
 support-pci-mcfg-space-on-intel-i915-bridges.patch
 pci-syscallc-switch-to-refcounting-api.patch

Stuff to (various levels of re-)send to Greg for the PCI tree.  I'll probably
drop the kthread patches as they seemed a bit half-baked and I've lost track
of which ones have which levels of baking.

 pci-device-ensure-sysdata-initialised-v2.patch

This is for Jeff's git-pciseg.patch which is sort-of on hold at present.

 git-s390-vs-gregkh-driver-sysfs-kill-unnecessary-attribute-owner.patch
 s390-scsi-zfcp_erp-partially-convert-to-use-the-kthread-api.patch
 s390-qeth-convert-to-use-the-kthread-api.patch
 s390-net-lcs-convert-to-the-kthread-api.patch

For Martin

 round_up-macro-cleanup-in-arch-sh64-kernel-pci_sh5c.patch

For Paul

 drivers-scsi-small-cleanups.patch
 drivers-scsi-advansysc-cleanups.patch
 megaraid-fix-warnings-when-config_proc_fs=n.patch
 remove-unnecessary-check-in-drivers-scsi-sgc.patch
 pci_module_init-convertion-in-tmscsimc.patch
 drivers-scsi-ncr5380c-replacing-yield-with-a.patch
 drivers-scsi-megaraidc-replacing-yield-with-a.patch
 drivers-scsi-mca_53c9xc-save_flags-cli-removal.patch
 sym53c8xx_2-claims-cpqarray-device.patch
 drivers-scsi-wd33c93c-cleanups.patch
 scsi-cover-up-bugs-fix-up-compiler-warnings-in-megaraid-driver.patch
 drivers-scsi-qla4xxx-possible-cleanups.patch
 make-seagate_st0x_detect-static.patch
 scsi-fix-obvious-typo-spin_lock_irqrestore-in-gdthc.patch
 drivers-scsi-aic7xxx_old-convert-to-generic-boolean-values.patch
 cleanup-variable-usage-in-mesh-interrupt-handler.patch
 fix--confusion-in-fusion-driver.patch
 use-unchecked_isa_dma-in-sd_revalidate_disk.patch
 fdomainc-get-rid-of-unused-stuff.patch
 remove-the-broken-scsi_acornscsi_3-driver.patch
 scsi-fix-config_scsi_wait_scan=m.patch
 sas_scsi_host-partially-convert-to-use-the-kthread-api.patch
 qla1280-use-dma_64bit_mask-instead-of-0ull.patch
 pci-error-recovery-symbios-scsi-base-support.patch
 pci-error-recovery-symbios-scsi-first-failure.patch

Will re^N-send to James.

 sparc64-powerc-convert-to-use-the-kthread-api.patch

Might drop, might send to davem.

 git-unionfs.patch

Does this have a future?

 cxacru-add-documentation-file.patch
 cxacru-cleanup-sysfs-attribute-code.patch

For Greg.

 i386-map-enough-initial-memory-to-create-lowmem-mappings-fix.patch
 fault-injection-disable-stacktrace-filter-for-x86-64.patch
 i386-efi-fix-proc-iomem-type-for-kexec-tools.patch
 fault-injection-enable-stacktrace-with-dwarf2-unwinder.patch
 i386-__inquire_remote_apic-printk-warning-fix.patch
 x86-msr-add-support-for-safe-variants.patch

For Andi

 xfs-clean-up-shrinker-games.patch
 xfs-fix-unmount-race.patch

For David

 add-apply_to_page_range-which-applies-a-function-to-a-pte-range.patch
 add-apply_to_page_range-which-applies-a-function-to-a-pte-range-fix.patch
 safer-nr_node_ids-and-nr_node_ids-determination-and-initial.patch
 use-zvc-counters-to-establish-exact-size-of-dirtyable-pages.patch
 proper-prototype-for-hugetlb_get_unmapped_area.patch
 mm-remove-gcc-workaround.patch
 slab-ensure-cache_alloc_refill-terminates.patch
 mm-more-rmap-checking.patch
 mm-make-read_cache_page-synchronous.patch
 fs-buffer-dont-pageuptodate-without-page-locked.patch
 allow-oom_adj-of-saintly-processes.patch
 introduce-config_has_dma.patch
 mm-slabc-proper-prototypes.patch
 mm-detach_vmas_to_be_unmapped-fix.patch

Misc MM things.  Will merge.

 add-a-bitmap-that-is-used-to-track-flags-affecting-a-block-of-pages.patch
 add-__gfp_movable-for-callers-to-flag-allocations-from-high-memory-that-may-be-migrated.patch
 split-the-free-lists-for-movable-and-unmovable-allocations.patch
 choose-pages-from-the-per-cpu-list-based-on-migration-type.patch
 add-a-configure-option-to-group-pages-by-mobility.patch
 drain-per-cpu-lists-when-high-order-allocations-fail.patch
 move-free-pages-between-lists-on-steal.patch
 group-short-lived-and-reclaimable-kernel-allocations.patch
 group-high-order-atomic-allocations.patch
 do-not-group-pages-by-mobility-type-on-low-memory-systems.patch
 bias-the-placement-of-kernel-pages-at-lower-pfns.patch
 be-more-agressive-about-stealing-when-migrate_reclaimable-allocations-fallback.patch
 fix-corruption-of-memmap-on-ia64-sparsemem-when-mem_section-is-not-a-power-of-2.patch
 create-the-zone_movable-zone.patch
 allow-huge-page-allocations-to-use-gfp_high_movable.patch
 x86-specify-amount-of-kernel-memory-at-boot-time.patch
 ppc-and-powerpc-specify-amount-of-kernel-memory-at-boot-time.patch
 x86_64-specify-amount-of-kernel-memory-at-boot-time.patch
 ia64-specify-amount-of-kernel-memory-at-boot-time.patch
 add-documentation-for-additional-boot-parameter-and-sysctl.patch
 handle-kernelcore=-boot-parameter-in-common-code-to-avoid-boot-problem-on-ia64.patch

Mel's moveable-zone work.

I don't believe that this has had sufficient review and I'm sure that it
hasn't had sufficient third-party testing.  Most of the approbations thus far
have consisted of people liking the overall idea, based on the changelogs and
multi-year-old discussions.

For such a large and core change I'd have expected more detailed reviewing
effort and more third-party testing.  And I STILL haven't made time to review
the code in detail myself.

So I'm a bit uncomfortable with moving ahead with these changes.

 mm-simplify-filemap_nopage.patch
 mm-fix-fault-vs-invalidate-race-for-linear-mappings.patch
 mm-merge-populate-and-nopage-into-fault-fixes-nonlinear.patch
 mm-merge-nopfn-into-fault.patch
 convert-hugetlbfs-to-use-vm_ops-fault.patch
 mm-remove-legacy-cruft.patch
 mm-debug-check-for-the-fault-vs-invalidate-race.patch
 mm-fix-clear_page_dirty_for_io-vs-fault-race.patch
 add-unitialized_var-macro-for-suppressing-gcc-warnings.patch
 i386-add-ptep_test_and_clear_dirtyyoung.patch
 i386-use-pte_update_defer-in-ptep_test_and_clear_dirtyyoung.patch

Miscish MM changes.  Will merge, dependent upon what still applies and works
if the moveable-zone patches get stalled.

 smaps-extract-pmd-walker-from-smaps-code.patch
 smaps-add-pages-referenced-count-to-smaps.patch
 smaps-add-clear_refs-file-to-clear-reference.patch

referenced-page accounting in /proc/pid/smaps.  Is realted to the maps2
patches.  Will merge.

 maps2-uninline-some-functions-in-the-page-walker.patch
 maps2-eliminate-the-pmd_walker-struct-in-the-page-walker.patch
 maps2-remove-vma-from-args-in-the-page-walker.patch
 maps2-propagate-errors-from-callback-in-page-walker.patch
 maps2-add-callbacks-for-each-level-to-page-walker.patch
 maps2-move-the-page-walker-code-to-lib.patch
 maps2-simplify-interdependence-of-proc-pid-maps-and-smaps.patch
 maps2-move-clear_refs-code-to-task_mmuc.patch
 maps2-regroup-task_mmu-by-interface.patch
 maps2-make-proc-pid-smaps-optional-under-config_embedded.patch
 maps2-make-proc-pid-clear_refs-option-under-config_embedded.patch
 maps2-add-proc-pid-pagemap-interface.patch
 maps2-add-proc-kpagemap-interface.patch

/proc/pid/pagemap and /proc/kpagemap.  A fairly important and low-level way of
exposing memory state to userspace, for developers.

Matt still has a decent-sized todo list here.  Might merge, might hold over
for 2.6.23.

 lumpy-reclaim-v4.patch

This is in a similar situation to the moveable-zone work.  Sounds great on
paper, but it needs considerable third-party testing and review.  It is a
major change to core MM and, we hope, a significant advance.  On paper.

 add-pfn_valid_within-helper-for-sub-max_order-hole-detection.patch
 anti-fragmentation-switch-over-to-pfn_valid_within.patch
 lumpy-move-to-using-pfn_valid_within.patch

More Mel things, and linkage between Mel-things and lumpy reclaim.  It's here
where the patch ordering gets into a mess and things won't improve if
moveable-zones and lumpy-reclaim get deferred.  Such a deferral would limit my
ability to queue more MM changes for 2.6.23.

 readahead-improve-heuristic-detecting-sequential-reads.patch
 readahead-code-cleanup.patch

Will merge.

 bias-the-location-of-pages-freed-for-min_free_kbytes-in-the-same-max_order_nr_pages-blocks.patch
 remove-page_group_by_mobility.patch
 dont-group-high-order-atomic-allocations.patch

More moveable-zone work.

 mm-move-common-segment-checks-to-separate-helper-function-v7.patch
 slab-use-num_possible_cpus-in-enable_cpucache.patch
 slab-dont-allocate-empty-shared-caches.patch
 slab-numa-kmem_cache-diet.patch
 do-not-disable-interrupts-when-reading-min_free_kbytes.patch
 slab-mark-set_up_list3s-__init.patch
 mm-clean-up-and-kernelify-shrinker-registration.patch
 fix-section-mismatch-of-memory-hotplug-related-code.patch
 add-white-list-into-modpostc-for-memory-hotplug-code-and-ia64s-machvec-section.patch
 split-mmap.patch
 only-allow-nonlinear-vmas-for-ram-backed-filesystems.patch
 cpusets-allow-tif_memdie-threads-to-allocate-anywhere.patch

More MM misc.  Will merge those patches which survive other merge decisions.

 i386-use-page-allocator-to-allocate-thread_info-structure.patch
 slub-core.patch

slub.  Or part thereof.  This is another patch series which got messed up by
poor patch sequencing.

 make-page-private-usable-in-compound-pages-v1.patch
 optimize-compound_head-by-avoiding-a-shared-page.patch
 add-virt_to_head_page-and-consolidate-code-in-slab-and-slub.patch
 slub-fix-object-tracking.patch
 slub-enable-tracking-of-full-slabs.patch
 slub-validation-of-slabs-metadata-and-guard-zones.patch
 slub-add-min_partial.patch
 slub-add-ability-to-list-alloc--free-callers-per-slab.patch
 slub-free-slabs-and-sort-partial-slab-lists-in-kmem_cache_shrink.patch
 slub-remove-object-activities-out-of-checking-functions.patch
 slub-user-documentation.patch
 slub-add-slabinfo-tool.patch

Most of the rest of slub.  Will merge it all.

 quicklists-for-page-table-pages.patch
 quicklist-support-for-ia64.patch
 quicklist-support-for-x86_64.patch
 quicklist-support-for-sparc64.patch

Will merge

 slob-handle-slab_panic-flag.patch
 include-kern_-constant-in-printk-calls-in-mm-slabc.patch
 mm-madvise-avoid-exclusive-mmap_sem.patch
 mm-remove-destroy_dirty_buffers-from-invalidate_bdev.patch
 mm-optimize-kill_bdev.patch
 mm-optimize-acorn-partition-truncate.patch
 slab-allocators-remove-obsolete-slab_must_hwcache_align.patch
 kmem_cache-simplify-slab-cache-creation.patch
 slab-allocators-remove-multiple-alignment-specifications.patch
 use-slab_panic-flag-cleanup.patch
 fault-injection-fix-failslab-with-config_numa.patch
 mm-document-fault_data-and-flags.patch
 mm-fix-handling-of-panic_on_oom-when-cpusets-are-in-use.patch
 oom-fix-constraint-deadlock.patch

More MM misc.  Will merge.

 get_unmapped_area-handles-map_fixed-on-powerpc.patch
 get_unmapped_area-handles-map_fixed-on-alpha.patch
 get_unmapped_area-handles-map_fixed-on-arm.patch
 get_unmapped_area-handles-map_fixed-on-frv.patch
 get_unmapped_area-handles-map_fixed-on-i386.patch
 get_unmapped_area-handles-map_fixed-on-ia64.patch
 get_unmapped_area-handles-map_fixed-on-parisc.patch
 get_unmapped_area-handles-map_fixed-on-sparc64.patch
 get_unmapped_area-handles-map_fixed-on-x86_64.patch
 get_unmapped_area-handles-map_fixed-in-hugetlbfs.patch
 get_unmapped_area-handles-map_fixed-in-generic-code.patch
 get_unmapped_area-doesnt-need-hugetlbfs-hacks-anymore.patch

Will merge.

 slub-exploit-page-mobility-to-increase-allocation-order.patch

Slub entanglement with moveable-zones.  Will merge if moveable-zones is merged.

 slab-allocators-remove-slab_debug_initial-flag.patch
 slab-allocators-remove-slab_ctor_atomic.patch
 slub-mm-only-make-slub-the-default-slab-allocator.patch

Various slab-related patches which are dependent upon multiple previous
patches.

 slub-i386-support.patch

Will hold for a while.

 lazy-freeing-of-memory-through-madv_free.patch
 lazy-freeing-of-memory-through-madv_free-vs-mm-madvise-avoid-exclusive-mmap_sem.patch
 restore-madv_dontneed-to-its-original-linux-behaviour.patch

I think the MADV_FREE changes need more work:

We need crystal-clear statements regarding the present functionality, the new
functionality and how these relate to the spec and to implmentations in other
OS'es.  Once we have that info we are in a position to work out whether the
code can be merged as-is, or if additional changes are needed.

Because right now, I don't know where we are with respect to these things and
I doubt if many of our users know either.  How can Michael write a manpage for
this is we don't tell him what it all does?

 implement-file-posix-capabilities.patch
 file-capabilities-accomodate-future-64-bit-caps.patch
 return-eperm-not-echild-on-security_task_wait-failure.patch

I think we're still waiting for the security guys to work out what to do with
this work.

 blackfin-arch.patch
 driver_bfin_serial_core.patch
 blackfin-on-chip-ethernet-mac-controller-driver.patch
 blackfin-patch-add-blackfin-support-in-smc91x.patch
 blackfin-on-chip-rtc-controller-driver.patch
 blackfin-blackfin-on-chip-spi-controller-driver.patch

 convert-h8-300-to-generic-timekeeping.patch
 h8300-generic-irq.patch
 h8300-add-zimage-support.patch

 round_up-macro-cleanup-in-arch-alpha-kernel-osf_sysc.patch
 alpha-fix-bootp-image-creation.patch
 alpha-prctl-macros.patch
 srmcons-fix-kmallocgfp_kernel-inside-spinlock.patch

 arm26-remove-useless-config-option-generic_bust_spinlock.patch

arch stuff.  Will merge.

 fix-refrigerator-vs-thaw_process-race.patch
 swsusp-use-inline-functions-for-changing-page-flags.patch
 swsusp-do-not-use-page-flags.patch
 mm-remove-unused-page-flags.patch
 swsusp-fix-error-paths-in-snapshot_open.patch
 swsusp-use-gfp_kernel-for-creating-basic-data-structures.patch
 freezer-remove-pf_nofreeze-from-handle_initrd.patch
 swsusp-use-rbtree-for-tracking-allocated-swap.patch
 freezer-fix-racy-usage-of-try_to_freeze-in-kswapd.patch
 remove-software_suspend.patch
 power-management-change-sys-power-disk-display.patch
 kconfig-mentioneds-hibernation-not-just-swsusp.patch
 swsusp-fix-snapshot_release.patch
 swsusp-free-more-memory.patch

swsusp: will merge.

 remove-unused-header-file-arch-m68k-atari-atasoundh.patch
 spin_lock_unlocked-cleanup-in-arch-m68k.patch

 remove-unused-header-file-drivers-serial-crisv10h.patch
 cris-check-for-memory-allocation.patch
 cris-remove-code-related-to-pre-22-kernel.patch

 uml-delete-unused-code.patch
 uml-formatting-fixes.patch
 uml-host_info-tidying.patch
 uml-mark-tt-mode-code-for-future-removal.patch
 uml-print-coredump-limits.patch
 uml-handle-block-device-hotplug-errors.patch
 uml-driver-formatting-fixes.patch
 uml-driver-formatting-fixes-fix.patch
 uml-network-interface-hotplug-error-handling.patch
 array_size-check-for-type.patch
 uml-move-sigio-testing-to-sigioc.patch
 uml-create-archh.patch
 uml-create-as-layouth.patch
 uml-move-remaining-useful-contents-of-user_utilh.patch
 uml-remove-user_utilh.patch
 uml-add-missing-__init-declarations.patch
 remove-unused-header-file-arch-um-kernel-tt-include-mode_kern-tth.patch
 uml-improve-checking-and-diagnostics-of-ethernet-macs.patch
 uml-eliminate-temporary-buffer-in-eth_configure.patch
 uml-replace-one-element-array-with-zero-element-array.patch
 uml-fix-umid-in-xterm-titles.patch
 uml-speed-up-exec.patch
 uml-no-locking-needed-in-tlsc.patch
 uml-tidy-processc.patch
 uml-remove-page_size.patch
 uml-kernel_thread-shouldnt-panic.patch
 uml-tidy-fault-code.patch
 uml-kernel-segfaults-should-dump-proper-registers.patch
 uml-comment-early-boot-locking.patch
 uml-irq-locking-commentary.patch
 uml-delete-host_frame_size.patch
 uml-drivers-get-release-methods.patch
 uml-dump-registers-on-ptrace-or-wait-failure.patch
 uml-speed-up-page-table-walking.patch
 uml-remove-unused-x86_64-code.patch
 uml-start-fixing-os_read_file-and-os_write_file.patch
 uml-tidy-libc-code.patch
 uml-convert-libc-layer-to-call-read-and-write.patch
 uml-batch-i-o-requests.patch
 uml-send-pointers-instead-of-structures-to-i-o-thread.patch
 uml-dump-core-on-panic.patch
 uml-dont-try-to-handle-signals-on-initial-process-stack.patch
 uml-change-remaining-callers-of-os_read_write_file.patch
 uml-formatting-fixes-around-os_read_write_file-callers.patch
 uml-remove-debugging-remnants.patch
 uml-rename-os_read_write_file_k-back-to-os_read_write_file.patch
 uml-aio-deadlock-avoidance.patch
 uml-speed-page-fault-path.patch
 uml-eliminate-a-piece-of-debugging-code.patch
 uml-more-page-fault-path-trimming.patch
 uml-only-flush-areas-covered-by-vma.patch
 uml-out-of-tmpfs-space-error-clarification.patch
 uml-virtualized-time-fix.patch

 v850-generic-timekeeping-conversion.patch

 xtensa-strlcpy-is-smart-enough.patch

More arch things.  Will merge.

 deprecate-smbfs-in-favour-of-cifs.patch

Probably 2.6.23.

 cpuset-remove-sched-domain-hooks-from-cpusets.patch

Hold.

 # clone-flag-clone_parent_tidptr-leaves-invalid-results-in-memory.patch: Eric B had issues
 clone-flag-clone_parent_tidptr-leaves-invalid-results-in-memory.patch
 factor-outstanding-i-o-error-handling.patch
 block_write_full_page-handle-enospc.patch
 simplify-the-stacktrace-code.patch
 filesystem-disk-errors-at-boot-time-caused-by-probe.patch
 allow-access-to-proc-pid-fd-after-setuid.patch
 ext2-3-4-fix-file-date-underflow-on-ext2-3-filesystems-on-64-bit-systems.patch
 reduce-size-of-task_struct-on-64-bit-machines.patch
 fix-quadratic-behavior-of-shrink_dcache_parent.patch
 mm-shrink-parent-dentries-when-shrinking-slab.patch
 ipmi-add-powerpc-openfirmware-sensing.patch
 ipmi-allow-shared-interrupts.patch
 ipmi-add-new-ipmi-nmi-watchdog-handling.patch
 ipmi-add-pci-remove-handling.patch
 freezer-task-exit_state-should-be-treated-as-bolean.patch
 softlockup-trivial-s-99-max_rt_prio.patch
 fix-constant-folding-and-poor-optimization-in-byte-swapping.patch
 documentation-ask-driver-writers-to-provide-pm-support.patch
 # fix-__d_path-for-lazy-unmounts-and-make-it-unambiguous.patch: Alan issues
 use-symbolic-constants-in-generic-lseek-code.patch
 use-use-seek_max-to-validate-user-lseek-arguments.patch
 devpts-add-fsnotify-create-event.patch
 tty-clarify-documentation-of-write.patch
 drivers-char-hvc_consolec-cleanups.patch
 is_power_of_2-in-fat.patch
 is_power_of_2-in-fs-hfs.patch
 is_power_of_2-in-fs-block_devc.patch
 freevxfs-possible-null-pointer-dereference-fix.patch
 reiserfs-possible-null-pointer-dereference-during-resize.patch
 scripts-kernel-doc-whitespace-cleanup.patch
 fix-section-mismatch-warning-in-lib-swiotlbc.patch
 init-do_mountsc-proper-prepare_namespace-prototype.patch
 fix-compilation-of-drivers-with-o0.patch
 reiserfs-shrink-superblock-if-no-xattrs.patch
 module-use-krealloc.patch
 reiserfs-correct-misspelled-reiserfs_proc_info-to.patch
 kconfig-centralize-the-selection-of-semaphore-debugging.patch
 irq-add-__must_check-to-request_irq.patch
 # use-stop_machine_run-in-the-intel-rng-driver.patch: needs re-review
 use-stop_machine_run-in-the-intel-rng-driver.patch
 cap-shmmax-at-int_max-in-compat-shminfo.patch
 exec-fix-remove_arg_zero.patch
 merge-sys_clone-sys_unshare-nsproxy-and-namespace.patch
 rcutorture-mark-rcu_torture_init-as-__init.patch
 init-dma-masks-in-pnp_dev.patch
 optimize-timespec_trunc.patch
 ext3-dirindex-error-pointer-issues.patch
 the-scheduled-removal-of-obsolete_oss-options.patch
 epoll-optimizations-and-cleanups.patch
 oss-strlcpy-is-smart-enough.patch
 add-filesystem-subtype-support.patch
 fix-race-between-proc_get_inode-and-remove_proc_entry.patch
 fix-race-between-proc_readdir-and-remove_proc_entry.patch
 proc-remove-pathetic-deleted-warn_on.patch
 vfs-remove-superflous-sb-==-null-checks.patch
 nameic-remove-utterly-outdated-comment.patch
 tpm_infineon-add-support-for-devices-in-mmio-space.patch
 replace-pci_find_device-in-drivers-telephony-ixjc.patch
 floppy-handle-device_create_file-failure-while-init.patch
 drivers-macintosh-mac_hidc-make-code-static.patch
 rocket-remove-modversions-include.patch
 virtual_eisa_root_init-should-be-__init.patch
 proc-maps-protection.patch
 remove-unused-header-file-drivers-message-i2o-i2o_lanh.patch
 remove-unused-header-file-drivers-char-digih.patch
 drivers-char-synclinkc-check-kmalloc-return-value.patch
 procfs-reorder-struct-pid_dentry-to-save-space-on-64bit-archs-and-constify-them.patch
 add-file-position-info-to-proc.patch
 vfs-delay-the-dentry-name-generation-on-sockets-and.patch
 tty-i386-x86_64-arbitary-speed-support.patch
 kprobes-make-kprobesymbol_name-const.patch
 fix-cycladesh-for-x86_64-and-probably-others.patch
 cyclades-remove-custom-types.patch
 small-fixes-for-jsm-driver.patch
 jsm-driver-fix-for-linuxpps-support.patch
 as-fix-antic_expire-check.patch
 rtc-add-rtc-rs5c313-driver.patch
 # rtc-add-rtc-class-driver-for-the-maxim-max6900.patch: Jean requested updates
 rtc-add-rtc-class-driver-for-the-maxim-max6900.patch
 # fix-rmmod-read-write-races-in-proc-entries.patch: worrisome (Arjan)
 fix-rmmod-read-write-races-in-proc-entries.patch
 # getrusage-fill-ru_inblock-and-ru_oublock-fields-if-possible.patch: wrong
 getrusage-fill-ru_inblock-and-ru_oublock-fields-if-possible.patch
 futex-restartable-futex_wait.patch
 proc-oom_score-oops-re-badness.patch
 enlarge-console-name.patch
 fixes-and-cleanups-for-earlyprintk-aka-boot-console.patch
 tty-remove-unnecessary-export-of-proc_clear_tty.patch
 tty-simplify-calling-of-put_pid.patch
 tty-introduce-no_tty-and-use-it-in-selinux.patch
 reiserfs-proc-support-requires-proc_fs.patch
 kprobes-fix-sparse-null-warning.patch
 add-ability-to-keep-track-of-callers-of-symbol_getput.patch
 update-mtd-use-of-symbol_getput.patch
 update-dvb-use-of-symbol_getput.patch
 move-die-notifier-handling-to-common-code.patch
 char-rocket-add-module_device_table.patch
 char-cs5535_gpio-add-module_device_table.patch
 remove-do_sync_file_range.patch
 protect-tty-drivers-list-with-tty_mutex.patch
 # more-scheduled-oss-driver-removal.patch: too early?
 more-scheduled-oss-driver-removal.patch
 schedule-obsolete-oss-drivers-for-removal-4th-round.patch
 delete-unused-header-file-math-emu-extendedh.patch
 fix-sscanf-%n-match-at-end-of-input-string.patch
 make-remove_inode_dquot_ref-static.patch
 fix-race-between-attach_task-and-cpuset_exit.patch
 delete-unused-header-file-linux-awe_voiceh.patch
 kernel-irq-procc-unprotected-iteration-over-the-irq-action-list-in-name_unique.patch
 parport-dev-driver-model-support.patch
 legacy-pc-parports-support-parport-dev.patch
 layered-parport-code-uses-parport-dev.patch
 cache-pipe-buf-page-address-for-non-highmem-arch.patch
 add-support-for-deferrable-timers-respun.patch
 add-a-new-deferrable-delayed-work-init.patch
 linux-sysdevh-needs-to-include-linux-moduleh.patch
 irq-check-for-percpu-flag-only-when-adding-first-irqaction.patch
 # time-smp-friendly-alignment-of-struct-clocksource.patch: needs x86_64-move-__vgetcpu_mode-__jiffies-to-the-vsyscall_2-zone.patch
 time-smp-friendly-alignment-of-struct-clocksource.patch
 move-timekeeping-code-to-timekeepingc.patch
 ignore-stolen-time-in-the-softlockup-watchdog.patch
 add-touch_all_softlockup_watchdogs.patch
 header-cleaning-dont-include-smp_lockh-when-not-used.patch
 fix-82875-pci-setup.patch
 unexport-pci_proc_attach_device.patch
 make-dev-port-conditional-on-config-symbol.patch
 remove-artificial-software-max_loop-limit.patch
 kdump-kexec-calculate-note-size-at-compile-time.patch
 fix-kevents-childs-priority-greediness.patch
 display-all-possible-partitions-when-the-root-filesystem-failed-to-mount.patch
 enhance-initcall_debug-measure-latency.patch
 kprobes-print-details-of-kretprobe-on-assertion-failure.patch
 reregister_binfmt-returns-with-ebusy.patch
 pnpacpi-sets-pnpdev-devarchdata.patch
 simplify-module_get_kallsym-by-dropping-length-arg.patch
 fix-race-between-rmmod-and-cat-proc-kallsyms.patch
 simplify-kallsyms_lookup.patch
 fix-race-between-cat-proc-wchan-and-rmmod-et-al.patch
 fix-race-between-cat-proc-slab_allocators-and-rmmod.patch
 kernel-paramsc-fix-lying-comment-for-param_array.patch
 replace-deprecated-sa_xxx-interrupt-flags.patch
 deprecate-sa_xxx-interrupt-flags-v2.patch
 # expose-range-checking-functions-from-arch-specific.patch: wrong? crap!
 expose-range-checking-functions-from-arch-specific.patch
 remove-hardcoding-of-hard_smp_processor_id-on-up.patch
 use-the-apic-to-determine-the-hardware-processor-id-i386.patch
 use-the-apic-to-determine-the-hardware-processor-id-x86_64.patch
 always-ask-the-hardware-to-obtain-hardware-processor-id-ia64.patch
 round_up-macro-cleanup-in-drivers-char-lpc.patch
 i386-schedh-inclusion-from-moduleh-is-baack.patch
 parport_serial-fix-pci-must_checks.patch
 round_up-macro-cleanup-in-fs-selectcompatreaddirc.patch
 round_up-macro-cleanup-in-fs-smbfs-requestc.patch
 doc-kernel-parameters-use-x86-32-tag-instead-of-ia-32.patch
 kernel-doc-handle-arrays-with-arithmetic-expressions-as.patch
 merge-compat_ioctlh-into-compat_ioctlc.patch
 lockdep-treats-down_write_trylock-like-regular-down_write.patch
 pad-irq_desc-to-internode-cacheline-size.patch
 partition-add-support-for-sysv68-partitions.patch
 dtlk-fix-error-checks-in-module_init.patch
 add-spaces-on-either-side-of-case-operator.patch
 cleanup-compat-ioctl-handling.patch
 partitions-check-the-return-value-of-kobject_add-etc.patch
 kallsyms-cleanup-use-seq_release_private-where-appropriate.patch
 proc-cleanup-use-seq_release_private-where-appropriate.patch
 cciss-reformat-error-handling.patch
 cciss-add-sg_io-ioctl-to-cciss.patch
 cciss-set-rq-errors-more-correctly-in-driver.patch
 generate-main-index-page-when-building-htmldocs.patch
 alphabetically-sorted-entries-in.patch
 fix-hotplug-for-legacy-platform-drivers.patch
 # remove-redundant-check-from-proc_setattr: need sds ack
 remove-redundant-check-from-proc_setattr.patch
 remove-redundant-check-from-proc_sys_setattr.patch
 make-iunique-use-a-do-while-loop-rather-than-its-obscure-goto-loop.patch
 kernel-doc-html-mode-struct-highlights.patch
 add-webpages-url-and-summarize-3-lines.patch
 add-keyboard-blink-driver.patch
 efi-warn-only-for-pre-100-system-tables.patch
 apm-fix-incorrect-comment.patch
 cciss-include-scsi-scsih-unconditionally.patch
 highres-dyntick-prevent-xtime-lock-contention.patch
 documentation-cciss-detecting-failed-drives.patch
 spin_lock_unlocked-cleanup-in-init_taskh.patch
 spin_lock_unlocked-cleanup-in-drivers-char-keyboard.patch
 spin_lock_unlocked-cleanup-in-drivers-serial.patch
 lockdep-lookup_chain_cache-comment-errata.patch
 taskstats-fix-getdelays-usage-information.patch
 smbfs-remove-unnecessary-allow_signal.patch
 pnpbios-conert-to-use-the-kthread-api.patch
 introduce-a-handy-list_first_entry-macro-v2.patch
 document-spin_lock_unlocked-rw_lock_unlocked-deprecation.patch
 getdelaysc-fix-overrun.patch
 serial_txx9-use-assigned-device-numbers.patch
 serial_txx9-zap-changelog-from-source-code.patch
 cpu-time-limit-patch--setrlimitrlimit_cpu-0-cheat-fix.patch
 ext3-copy-i_flags-to-inode-flags-on-write.patch
 codingstyle-start-flamewar-about-use-of-braces.patch
 upper-32-bits.patch
 console-utf-8-fixes.patch
 #report-that-kernel-is-tainted-if-there-were-an-oops-before.patch
 clarify-the-creation-of-the-localversion_auto-string.patch
 add-pci_try_set_mwi.patch
 check-privileges-before-setting-mount-propagation.patch
 jbd-check-for-error-returned-by-kthread_create-on-creating-journal-thread.patch
 clean-up-mutex_trylock-noise.patch
 the-scheduled-einval-for-invalid-timevals-in-setitimer.patch
 reiserfs-use-__set_current_state.patch
 drivers-char-use-__set_current_state.patch
 kill-warnings-when-building-mandocs.patch
 cleanup-mostly-unused-iospace-macros.patch
 lockdep-removed-unused-ip-argument-in-mark_lock-mark_held_locks.patch
 fat_dont-use_free_clusters-for-fat32.patch
 copy-i_flags-to-ext2-inode-flags-on-write.patch
 fix-chapter-reference-in-codingstyle.patch
 sleep-during-spinlock-in-tpm-driver.patch
 consolidate-asm-consth-to-linux-consth.patch
 x86_64-kill-19000-sparse-warnings.patch
 move-log_buf_shift-to-a-more-sensible-place.patch
 w1-printk-format-warning.patch
 w1-allow-bus-master-to-have-reset-and-byte-ops.patch
 driver-for-the-maxim-ds1wm-a-1-wire-bus-master-asic-core.patch
 dma_declare_coherent_memory-wrong-allocation.patch
 deflate-inflate_dynamic-too.patch
 fix-wrong-identifier-name-in-documentation-driver-model-devrestxt.patch
 edd-switch-to-refcounting-pci-apis.patch
 fix-vfat-compat-ioctls-on-64-bit-systems.patch

Misc.  A few of these need rechecking by people who had comments.  I'll
re-review these and will mostly-merge.

 consolidate-generic_writepages-and-mpage_writepages.patch

Might merge.  I forget what happened to this.

 sync_sb_inodes-propagate-errors.patch

This still isn't right.

 minor-spi_butterfly-cleanup.patch
 dev-spidevbc-interface.patch
 # mpc52xx-psc-spi-master-driver.patch: needs s-o-b
 mpc52xx-psc-spi-master-driver.patch

Will merge.

 mips-convert-to-use-shared-apm-emulation-fix.patch

Send to Ralf.  Or drop.  Not sure what it's doing here.

 make-static-counters-in-new_inode-and-iunique-be-32-bits.patch
 change-libfs-sb-creation-routines-to-avoid-collisions-with-their-root-inodes.patch

Will merge.

 schedule_on_each_cpu-use-preempt_disable.patch
 reimplement-flush_workqueue.patch
 implement-flush_work.patch
 flush_workqueue-use-preempt_disable-to-hold-off-cpu-hotplug.patch
 flush_cpu_workqueue-dont-flush-an-empty-worklist.patch
 aio-use-flush_work.patch
 kblockd-use-flush_work.patch
 relayfs-use-flush_keventd_work.patch
 tg3-use-flush_keventd_work.patch
 e1000-use-flush_keventd_work.patch
 libata-use-flush_work.patch
 phy-use-flush_work.patch

Will mostly-merge.  Some can go via subsystem maintainers if/when the base
patches are in.

 extend-notifier_call_chain-to-count-nr_calls-made.patch
 define-and-use-new-eventscpu_lock_acquire-and-cpu_lock_release.patch
 eliminate-lock_cpu_hotplug-in-kernel-schedc.patch
 call-cpu_chain-with-cpu_down_failed-if-cpu_down_prepare-failed.patch
 call-cpu_chain-with-cpu_down_failed-if-cpu_down_prepare-failed-vs-reduce-size-of-task_struct-on-64-bit-machines.patch
 slab-use-cpu_lock_.patch
 workqueue-fix-freezeable-workqueues-implementation.patch
 workqueue-fix-flush_workqueue-vs-cpu_dead-race.patch
 workqueue-dont-clear-cwq-thread-until-it-exits.patch
 workqueue-dont-migrate-pending-works-from-the-dead-cpu.patch
 workqueue-kill-run_scheduled_work.patch
 workqueue-dont-save-interrupts-in-run_workqueue.patch
 workqueue-make-cancel_rearming_delayed_workqueue-work-on-idle-dwork.patch
 workqueue-introduce-cpu_singlethread_map.patch
 workqueue-introduce-workqueue_struct-singlethread.patch
 workqueue-make-init_workqueues-__init.patch
 make-queue_delayed_work-friendly-to-flush_fork.patch
 unify-queue_delayed_work-and-queue_delayed_work_on.patch
 workqueue-introduce-wq_per_cpu-helper.patch
 make-cancel_rearming_delayed_work-work-on-any-workqueue-not-just-keventd_wq.patch
 ipvs-flush-defense_work-before-module-unload.patch
 workqueue-kill-noautorel-works.patch
 worker_thread-dont-play-with-signals.patch
 worker_thread-fix-racy-try_to_freeze-usage.patch
 zap_other_threads-remove-unneeded-exit_signal-change.patch
 # slab-shutdown-cache_reaper-when-cpu-goes-down.patch
 unify-flush_work-flush_work_keventd-and-rename-it-to-cancel_work_sync.patch
 ____call_usermodehelper-dont-flush_signals.patch

A lot of this is Oleg's workqueue rework which I deferred from 2.6.21.  Will
merge.

 freezer-read-pf_borrowed_mm-in-a-nonracy-way.patch
 freezer-close-theoretical-race-between-refrigerator-and-thaw_tasks.patch
 freezer-remove-pf_nofreeze-from-rcutorture-thread.patch
 freezer-remove-pf_nofreeze-from-bluetooth-threads.patch
 freezer-add-try_to_freeze-calls-to-all-kernel-threads.patch
 freezer-fix-vfork-problem.patch
 freezer-take-kernel_execve-into-consideration.patch
 kthread-dont-depend-on-work-queues-take-2.patch
 change-reparent_to_init-to-reparent_to_kthreadd.patch

Freezer work - trying to get the freezer ready to use it for CPU hotplug. 
Will merge.

 nlmclnt_recovery-dont-use-clone_sighand.patch
 usbatm_heavy_init-dont-use-clone_sighand.patch
 wait_for_helper-remove-unneeded-do_sigaction.patch
 worker_thread-dont-play-with-sigchld-and-numa-policy.patch
 change-kernel-threads-to-ignore-signals-instead-of-blocking-them.patch
 fix-kthread_create-vs-freezer-theoretical-race.patch
 fix-pf_nofreeze-and-freezeable-race-2.patch
 freezer-document-task_lock-in-thaw_process.patch
 move-frozen_process-to-kernel-power-processc.patch
 remvoe-kthread_bind-call-from-_cpu_down.patch

Various core thread-management things.  Will merge.

 move-page-writeback-acounting-out-of-macros.patch

Will merge.  Or might drop, dunno.  I think it makes sense.

 ext2-reservations.patch

This still awaits more testing.

 make-drivers-isdn-capi-capiutilccdebbuf_alloc-static.patch
 drivers-isdn-hardware-eicon-remove-unused-header-files.patch
 fix-spinlock-usage-in-hysdn_log_close.patch

ISDN: will merge.

 remove-obsolete-label-from-isdn4linux-v3.patch

This caused a lkml foodfight.  Will drop.

 remove-nfs4_acl_add_ace.patch
 the-nfsv2-nfsv3-server-does-not-handle-zero-length-write.patch
 knfsd-rename-sk_defer_lock-to-sk_lock.patch
 nfsd-nfs4state-remove-unnecessary-daemonize-call.patch
 rpc-add-wrapper-for-svc_reserve-to-account-for-checksum.patch

nfsd things - will merge after checking with Neil.

 sched-fix-idle-load-balancing-in-softirqd-context.patch
 sched-dynticks-idle-load-balancing-v3.patch
 speedup-divides-by-cpu_power-in-scheduler.patch
 sched-optimize-siblings-status-check-logic-in-wake_idle.patch
 sched-redundant-reschedule-when-set_user_nice-boosts-a-prio-of-a-task-from-the-expired-array.patch
 sched-align-rq-to-cacheline-boundary.patch

CPU scheduler: will merge.

 rcutorture-use-array_size-macro-when-appropriate.patch
 rcutorture-style-cleanup-avoid-=-null-in-boolean-tests.patch
 rcutorture-remove-redundant-assignment-to-cur_ops-in.patch

Will merge.

 utimensat-implementation.patch

Will merge.

 rtc-remove-sys-class-rtc-dev.patch
 rtc-rtc-interfaces-dont-use-class_device.patch
 rtc-simplified-rtc-sysfs-attribute-handling.patch
 rtc-simplified-proc-driver-rtc-handling.patch
 rtc-remove-rest-of-class_device.patch
 rtc-suspend-resume-restores-system-clock.patch
 rtc-simplified-rtc-sysfs-attribute-handling-tidy.patch
 rtc-update-to-class-device-removal-patches.patch
 rtc-kconfig-cleanup.patch
 rtc-update-vr41xx-alarm-handling.patch
 rtc-cmos-wakeup-interface.patch
 acpi-wakeup-hooks-for-rtc-cmos.patch
 workaround-rtc-related-acpi-table-bugs.patch
 revert-rtc-add-rtc_merge_alarm.patch
 remove-rtc_alm_set-mode-bugs.patch
 rtc-cmos-make-it-load-on-pnpbios-systems.patch

Will merge.

 declare-struct-ktime.patch
 futex-priority-based-wakeup.patch
 make-futex_wait-use-an-hrtimer-for-timeout.patch
 futex_requeue_pi-optimization.patch

Will merge.

 kprobes-use-hlist_for_each_entry.patch
 kprobes-codingstyle-cleanups.patch
 kprobes-kretprobes-simplifcations.patch
 kprobes-the-on-off-knob-thru-debugfs-updated.patch

Will merge.

 atomich-add-atomic64-cmpxchg-xchg-and-add_unless-to-alpha.patch
 atomich-complete-atomic_long-operations-in-asm-generic.patch
 atomich-i386-type-safety-fix.patch
 atomich-add-atomic64-cmpxchg-xchg-and-add_unless-to-ia64.patch
 atomich-add-atomic64-cmpxchg-xchg-and-add_unless-to-mips.patch
 atomich-add-atomic64-cmpxchg-xchg-and-add_unless-to-parisc.patch
 atomich-add-atomic64-cmpxchg-xchg-and-add_unless-to-powerpc.patch
 atomich-add-atomic64-cmpxchg-xchg-and-add_unless-to-sparc64.patch
 atomich-add-atomic64-cmpxchg-xchg-and-add_unless-to-x86_64.patch
 atomich-atomic_add_unless-as-inline-remove-systemh-atomich-circular-dependency.patch
 local_t-architecture-independant-extension.patch
 local_t-alpha-extension.patch
 local_t-i386-extension.patch
 local_t-ia64-extension.patch
 local_t-mips-extension.patch
 local_t-parisc-cleanup.patch
 local_t-powerpc-extension.patch
 local_t-sparc64-cleanup.patch
 local_t-x86_64-extension.patch
 linux-kernel-markers-kconfig-menus.patch
 linux-kernel-markers-architecture-independant-code.patch
 linux-kernel-markers-powerpc-optimization.patch
 linux-kernel-markers-i386-optimization.patch
 markers-add-instrumentation-markers-menus-to-avr32.patch
 linux-kernel-markers-non-optimized-architectures.patch
 markers-alpha-and-avr32-supportadd-alpha-markerh-add-arm26-markerh.patch
 linux-kernel-markers-documentation.patch
 markers-define-the-linker-macro-extra_rwdata.patch
 markers-use-extra_rwdata-in-architectures.patch

Static markers.  Will merge.

 some-grammatical-fixups-and-additions-to-atomich-kernel-doc.patch
 no-longer-include-asm-kdebugh.patch

Will merge.

 nfs-fix-congestion-control-use-atomic_longs.patch

Will merge.

 udf-use-sector_t-and-loff_t-for-file-offsets.patch
 udf-introduce-struct-extent_position.patch
 udf-use-get_bh.patch
 udf-add-assertions.patch
 udf-support-files-larger-than-1g.patch
 udf-fix-link-counts.patch
 udf-possible-null-pointer-dereference-while-load_partition.patch

Will merge.

 attach_pid-with-struct-pid-parameter.patch
 statically-initialize-struct-pid-for-swapper.patch
 explicitly-set-pgid-and-sid-of-init-process.patch
 use-struct-pid-parameter-in-copy_process.patch
 use-task_pgrp-task_session-in-copy_process.patch
 kill-unused-sesssion-and-group-values-in-rocket-driver.patch
 fix-some-coding-style-errors-in-autofs.patch
 replace-pid_t-in-autofs-with-struct-pid-reference.patch
 dont-init-pgrp-and-__session-in-init_signals.patch

Will merge.

 signal-timer-event-fds-v9-anonymous-inode-source.patch
 signal-timer-event-fds-v9-signalfd-core.patch
 signal-timer-event-signalfd-wire-up-x86-arches.patch
 signal-timer-event-fds-v9-signalfd-compat-code.patch
 signal-timer-event-fds-v9-timerfd-core.patch
 signal-timer-event-timerfd-wire-up-x86-arches.patch
 signal-timer-event-fds-v9-timerfd-compat-code.patch
 signal-timer-event-fds-v9-eventfd-core.patch
 signal-timer-event-eventfd-wire-up-x86-arches.patch
 signal-timer-event-fds-v9-kaio-eventfd-support-example.patch
 epoll-use-anonymous-inodes.patch

Will merge.

 epoll-cleanups-epoll-no-module.patch
 epoll-cleanups-epoll-remove-static-pre-declarations-and-akpm-ize-the-code.patch

Will merge.

 revoke-special-mmap-handling.patch
 revoke-special-mmap-handling-vs-fault-vs-invalidate.patch
 revoke-core-code.patch
 revoke-core-code-misc-fixes.patch
 revoke-core-code-fix-shared-mapping-revoke.patch
 revoke-core-code-move-magic.patch
 revoke-core-code-fs-revokec-cleanups-and-bugfix-for-64bit-systems.patch
 revoke-core-code-revoke-no-revoke-for-nommu.patch
 revoke-core-code-fix-shared-mapping-revoke-revoke-only-revoke-mappings-for-the-given-inode.patch
 revoke-core-code-break-cow-for-private-mappings.patch
 revoke-core-code-generic_file_revoke-stub-for-nommu.patch
 revoke-core-code-break-cow-fixes.patch
 revoke-core-code-mapping-revocation.patch
 revoke-core-code-only-fput-unused-files.patch
 revoke-core-code-slab-allocators-remove-slab_debug_initial-flag-revoke.patch
 revoke-support-for-ext2-and-ext3.patch
 revoke-add-documentation.patch
 revoke-wire-up-i386-system-calls.patch

Hold.  This is tricky stuff and I don't think we've seen sufficient reviewing,
testing and acking yet?

 add-irqf_irqpoll-flag-common-code.patch
 add-irqf_irqpoll-flag-on-x86_64.patch
 add-irqf_irqpoll-flag-on-i386.patch
 add-irqf_irqpoll-flag-on-ia64.patch
 add-irqf_irqpoll-flag-on-sh.patch
 add-irqf_irqpoll-flag-on-parisc.patch
 add-irqf_irqpoll-flag-on-arm.patch

Merge.

 char-cyclades-remove-pause.patch
 char-cyclades-cy_readx-writex-cleanup.patch
 char-cyclades-timer-cleanup.patch
 char-cyclades-remove-volatiles.patch
 char-cyclades-remove-useless-casts.patch

Merge.

 pnp-notice-whether-we-have-pnp-devices-pnpbios-or-pnpacpi.patch
 pnp-workaround-hp-bios-defect-that-leaves-smcf010-device-partly-enabled.patch
 smsc-ircc2-tidy-up-module-parameter-checking.patch
 smsc-ircc2-add-pnp-support.patch
 x86-serial-convert-legacy-com-ports-to-platform-devices.patch

Misc stuff.  Will merge.

 lguest-the-guest-code.patch
 lguest-vs-x86_64-mm-use-per-cpu-variables-for-gdt-pda.patch
 lguest-the-guest-code-update-lguests-patch-code-for-new-paravirt-patch.patch
 lguest-the-host-code.patch
 lguest-the-host-code-vs-x86_64-mm-i386-separate-hardware-defined-tss-from-linux-additions.patch
 lguest-the-host-code-fix-lguest-oops-when-guest-dies-while-receiving-i-o.patch
 lguest-the-host-code-simplification-dont-pin-guest-trap-handlers.patch
 lguest-the-asm-offsets.patch
 lguest-the-makefile-and-kconfig.patch
 lguest-the-console-driver.patch
 lguest-the-net-driver.patch
 lguest-the-block-driver.patch
 lguest-the-documentation-example-launcher.patch
 lguest-the-documentation-example-launcher-fix-lguest-documentation-error.patch

Will merge the rustyvisor.

 fs-convert-core-functions-to-zero_user_page.patch
 fs-convert-core-functions-to-zero_user_page-pass-kmap-type.patch
 fs-convert-core-functions-to-zero_user_page-fix-2.patch
 affs-use-zero_user_page.patch
 ecryptfs-use-zero_user_page.patch
 ext3-use-zero_user_page.patch
 ext4-use-zero_user_page.patch
 gfs2-use-zero_user_page.patch
 nfs-use-zero_user_page.patch
 ntfs-use-zero_user_page.patch
 ntfs-use-zero_user_page-fix.patch
 ocfs2-use-zero_user_page.patch
 reiserfs-use-zero_user_page.patch
 xfs-use-zero_user_page.patch
 fs-deprecate-memclear_highpage_flush.patch

Merge.

 char-cyclades-create-cy_init_ze.patch
 char-cyclades-use-pci_iomap-unmap.patch
 char-cyclades-init-ze-immediately.patch
 char-cyclades-create-cy_pci_probe.patch
 char-cyclades-move-card-entries-init-into-function.patch
 char-cyclades-init-card-struct-immediately.patch
 char-cyclades-remove-some-global-vars.patch
 char-cyclades-cy_init-error-handling.patch
 char-cyclades-tty_register_device-separately-for-each-device.patch
 char-cyclades-clear-interrupts-before-releasing.patch
 char-cyclades-allow-debug_shirq.patch

Merge

 add-suspend-related-notifications-for-cpu-hotplug.patch
 microcode-use-suspend-related-cpu-hotplug-notifications.patch

Merge.

 vmstat-use-our-own-timer-events.patch

Merge.

 readahead-kconfig-options.patch
 radixtree-introduce-scan-hole-data-functions.patch
 mm-introduce-probe_page.patch
 mm-introduce-pg_readahead.patch
 readahead-add-look-ahead-support-to-__do_page_cache_readahead.patch
 readahead-insert-cond_resched-calls.patch
 readahead-minmax_ra_pages.patch
 readahead-events-accounting.patch
 readahead-rescue_pages.patch
 readahead-sysctl-parameters.patch
 readahead-min-max-sizes.patch
 readahead-state-based-method-aging-accounting.patch
 readahead-state-based-method-routines.patch
 readahead-state-based-method.patch
 readahead-state-based-method-check-node-id.patch
 readahead-state-based-method-decouple-readahead_ratio-from-growth_limit.patch
 readahead-state-based-method-cancel-lookahead-gracefully.patch
 readahead-context-based-method.patch
 readahead-initial-method-guiding-sizes.patch
 readahead-initial-method-thrashing-guard-size.patch
 readahead-initial-method-user-recommended-size.patch
 readahead-initial-method.patch
 readahead-backward-prefetching-method.patch
 readahead-thrashing-recovery-method.patch
 readahead-thrashing-recovery-method-check-unbalanced-aging.patch
 readahead-thrashing-recovery-method-refill-holes.patch
 readahead-call-scheme.patch
 readahead-call-scheme-cleanup.patch
 readahead-call-scheme-catch-thrashing-on-lookahead-time.patch
 readahead-laptop-mode.patch
 readahead-loop-case.patch
 readahead-nfsd-case.patch
 readahead-remove-parameter-ra_max-from-thrashing_recovery_readahead.patch
 readahead-remove-parameter-ra_max-from-adjust_rala.patch
 readahead-state-based-method-protect-against-tiny-size.patch
 readahead-rename-state_based_readahead-to-clock_based_readahead.patch
 readahead-account-i-o-block-times-for-stock-readahead.patch
 readahead-rescue_pages-updates.patch
 readahead-remove-noaction-shrink-events.patch
 readahead-remove-size-limit-on-read_ahead_kb.patch
 readahead-remove-size-limit-of-max_sectors_kb-on-read_ahead_kb.patch
 readahead-partial-sendfile-fix.patch
 readahead-turn-on-by-default.patch

Hopefully Wu will be coming up with a much simpler best-of-readahead patch
soon.  I don't think we can get these patches over the hump and they are
somewhat costly to maintain.

 [93 random fbdev patches]

Will merge.

 drivers-mdc-use-array_size-macro-when-appropriate.patch
 md-cleanup-use-seq_release_private-where-appropriate.patch
 md-remove-broken-sigkill-support.patch

Will merge after checking with Neil

 md-dm-reduce-stack-usage-with-stacked-block-devices.patch

Will we ever fix this?

 statistics-infrastructure-prerequisite-list.patch
 statistics-infrastructure-prerequisite-parser.patch
 statistics-infrastructure-prerequisite-parser-fix.patch
 add-for_each_substring-and-match_substring.patch
 statistics-infrastructure-prerequisite-timestamp.patch
 statistics-infrastructure-make-printk_clock-a-generic-kernel-wide-nsec-resolution.patch
 statistics-infrastructure-documentation.patch statistics-infrastructure.patch
 statistics-infrastructure-add-for_each_substring-and-match_substring-exploitation.patch
 statistics-infrastructure-fix-parsing-of-statistics-type-attribute.patch
 statistics-infrastructure-simplify-statistics-debugfs-write-function.patch
 statistics-infrastructure-simplify-statistics-debugfs-read-functions.patch
 statistics-infrastructure-fix-string-termination.patch
 statistics-infrastructure-small-cleanup-in-debugfs-write-function.patch
 statistics-infrastructure-fix-cpu-hot-unplug-related-memory-leak.patch
 statistics-infrastructure-timer_stats-slimmed-down-statistics-prereq-labels.patch
 statistics-infrastructure-timer_stats-slimmed-down-statistics-prereq-keys.patch
 statistics-infrastructure-statistics-fix-sorted-list.patch
 add-suspend-related-notifications-for-cpu-hotplug-statistics.patch
 statistics-infrastructure-exploitation-zfcp.patch
 timer_stats-slimmed-down-using-statistics-infrastucture.patch

We have a second user of the statistics infrastructure!  If we have a third,
perhaps we can merge it.  It's an unobvious call.

 mprotect-patch-for-use-by-slim.patch
 integrity-service-api-and-dummy-provider.patch
 integrity-service-api-and-dummy-provider-integrity_dummy_verify_metadata.patch
 slim-main-patch.patch
 slim-main-lsm-getprocattr-hook-api-change.patch
 slim-secfs-patch.patch
 slim-make-and-config-stuff.patch
 slim-debug-output.patch
 slim-integrity-patch.patch
 slim-documentation.patch
 integrity-new-hooks.patch
 integrity-new-hooks-fix.patch
 integrity-fs-hook-placement.patch
 integrity-evm-as-an-integrity-service-provider.patch
 integrity-evm-as-an-integrity-service-provider-tidy.patch
 integrity-evm-as-an-integrity-service-provider-tidy-fix.patch
 integrity-evm-as-an-integrity-service-provider-tidy-fix-2.patch
 integrity-ima-integrity_measure-support.patch
 integrity-ima-integrity_measure-support-tidy.patch
 integrity-ima-integrity_measure-support-fix.patch
 integrity-ima-integrity_measure-support-fix-2.patch
 integrity-ima-integrity_measure-support-ima-exit.patch
 integrity-ima-integrity_measure-support-remove-spinlock.patch
 integrity-ima-identifiers.patch
 integrity-ima-cleanup.patch
 integrity-tpm-internal-kernel-interface.patch
 integrity-tpm-internal-kernel-interface-tidy.patch
 ibac-patch.patch

Hold.   This seems a long way from being mergeable.

 use-menuconfig-objects-acpi.patch
 use-menuconfig-objects-libata.patch
 use-menuconfig-objects-block-layer.patch
 use-menuconfig-objects-connector.patch
 use-menuconfig-objects-crypto.patch
 use-menuconfig-objects-crypto-hw.patch
 use-menuconfig-objects-dccp.patch
 use-menuconfig-objects-i2o.patch
 use-menuconfig-objects-ide.patch
 use-menuconfig-objects-ipvs.patch
 use-menuconfig-objects-sctp.patch
 use-menuconfig-objects-tipc.patch
 use-menuconfig-objects-arcnet.patch
 use-menuconfig-objects-phy.patch
 use-menuconfig-objects-toeknring.patch
 use-menuconfig-objects-netdev.patch
 use-menuconfig-objects-oldcd.patch
 use-menuconfig-objects-parport.patch
 use-menuconfig-objects-pcmcia.patch
 use-menuconfig-objects-pnp.patch
 use-menuconfig-objects-w1.patch

Will merge sometime.  Some needs to go via subsystem maintainers.

 w1-build-fix.patch

A gcc-4.3 maybe-fix.  Still awaiting testing results.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
