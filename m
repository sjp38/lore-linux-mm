Date: Mon, 9 Jun 2008 05:39:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: 2.6.26-rc5-mm1
Message-Id: <20080609053908.8021a635.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Temporarily at

  http://userweb.kernel.org/~akpm/2.6.26-rc5-mm1/

Will turn up later at

  ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.26-rc5/2.6.26-rc5-mm1/


- git-block remains dropped from both -mm and linux-next.

- added the unprivilieged mounts tree as git-unprivileged-mounts.patch
  (Miklos Szeredi <miklos@szeredi.hu>)

- There are a large number of deep changes to memory management here:
  fast get_user_pages(), lockless pagecache, extensive hugetlb work and,
  most radically, basically a rip-up-and-rewrite of page reclaim.

  Needless to say: it all needs testing.  And review.  Thanks.



Boilerplate:

- See the `hot-fixes' directory for any important updates to this patchset.

- To fetch an -mm tree using git, use (for example)

  git-fetch git://git.kernel.org/pub/scm/linux/kernel/git/smurf/linux-trees.git tag v2.6.16-rc2-mm1
  git-checkout -b local-v2.6.16-rc2-mm1 v2.6.16-rc2-mm1

- -mm kernel commit activity can be reviewed by subscribing to the
  mm-commits mailing list.

        echo "subscribe mm-commits" | mail majordomo@vger.kernel.org

- If you hit a bug in -mm and it is not obvious which patch caused it, it is
  most valuable if you can perform a bisection search to identify which patch
  introduced the bug.  Instructions for this process are at

        http://www.zip.com.au/~akpm/linux/patches/stuff/bisecting-mm-trees.txt

  But beware that this process takes some time (around ten rebuilds and
  reboots), so consider reporting the bug first and if we cannot immediately
  identify the faulty patch, then perform the bisection search.

- When reporting bugs, please try to Cc: the relevant maintainer and mailing
  list on any email.

- When reporting bugs in this kernel via email, please also rewrite the
  email Subject: in some manner to reflect the nature of the bug.  Some
  developers filter by Subject: when looking for messages to read.

- Occasional snapshots of the -mm lineup are uploaded to
  ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/mm/ and are announced on
  the mm-commits list.  These probably are at least compilable.

- More-than-daily -mm snapshots may be found at
  http://userweb.kernel.org/~akpm/mmotm/.  These are almost certainly not
  compileable.



Changes since 2.6.26-rc2-mm1:


 origin.patch
 linux-next.patch
 git-jg-misc.patch
 git-leds.patch
 git-libata-all.patch
 git-battery.patch
 git-parisc.patch
 git-regulator.patch
 git-unionfs.patch
 git-logfs.patch
 git-unprivileged-mounts.patch
 git-xtensa.patch
 git-orion.patch
 git-pekka.patch

 git trees

-mpc5200_psc_spi-typo-fix-in-header-block.patch
-m68knommu-add-info-about-removing-mcfserial.patch
-oprofile-dont-request-cache-line-alignment-for-cpu_buffer.patch
-fix-lxfb-extend-pll-table-to-support-dotclocks-below-25-mhz.patch
-revert-acpica-fixes-for-unload-and-ddbhandles.patch
-acpi_pm_device_sleep_state-cleanup.patch
-acpi-acpi_numa_init-build-fix.patch
-acpi-fix-drivers-acpi-gluec-build-error.patch
-arch-x86-mm-patc-use-boot_cpu_has.patch
-x86-setup_force_cpu_cap-dont-do-clear_bitnon-unsigned-long.patch
-x86-set_restore_sigmask-avoid-bitop-on-a-u32.patch
-x86-early_init_centaur-use-set_cpu_cap.patch
-x86-bitops-take-an-unsigned-long.patch
-list_for_each_rcu-must-die-audit.patch
-audit_send_reply-fix-error-path-memory-leak.patch
-bkl-removal-convert-cifs-over-to-unlocked_ioctl.patch
-cifs-suppress-warning.patch
-powerpc-add-i2c-pins-to-dts-and-board-setup.patch
-macintosh-replace-deprecated-__initcall-with-device_initcall.patch
-struct-class-sem-to-mutex-converting.patch
-driver-core-struct-class-remove-children-list.patch
-drm-radeon-radeon_enable_vblank-should-return-negative-error.patch
-media-use-get_unaligned_-helpers.patch
-zoran-use-correct-type-for-cpu-flags.patch
-i2c-use-class_for_each_device.patch
-i2c-add-support-for-i2c-bus-on-freescale-cpm1-cpm2-controllers.patch
-hdaps-invert-the-axes-for-hdaps-on-lenovo-r61i-thinkpads.patch
-i5k_amb-support-intel-5400-chipset.patch
-ibmaem-new-driver-for-power-energy-temp-meters-in-ibm-system-x-hardware.patch
-ibmaem-fix-64-bit-division-on-32-bit-platforms.patch
-ibmaem-overview-of-the-driver.patch
-ibmaem-new-driver-for-power-energy-temp-meters-in-ibm-system-x-hardware-ia64-warnings.patch
-hid-use-get-put_unaligned_-helpers.patch
-drivers-infiniband-hw-mlx4-qpc-fix-uninitialised-var-warning.patch
-jfs-switch-to-seq_files.patch
-leds-add-pca9532-led-driver.patch
-leds-add-pca9532-platform-data-for-thecus-n2100.patch
-ata-remove-fit-macro.patch
-multi-statement-if-seems-to-be-missing-braces.patch
-sctp-fix-use-of-uninitialized-pointer.patch
-iphase-fix-64bit-warning.patch
-list_for_each_rcu-must-die-networking.patch
-net-hso-driver-uses-rfkill-functions.patch
-linux-atm_tcph-linux-atmh-cleanup-for-userspace.patch
-hysdn-remove-cli-sti-calls.patch
-hysdn-no-longer-broken-on-smp.patch
-gigaset-use-dev_-macros-for-messages.patch
-gigaset-gigaset_isowbuf_getbytes-may-return-signed-unnoticed.patch
-isdn-capi-return-proper-errnos-on-module-init.patch
-ehca-ret-is-unsigned-ibmebus_request_irq-negative-return-ignored-in-hca_create_eq.patch
-dm9000-use-delayed-work-to-update-mii-phy-state-fix.patch
-pcnet32-fix-warning.patch
-drivers-net-tokenring-3c359c-squish-a-warning.patch
-drivers-net-tokenring-olympicc-fix-warning.patch
-rndis_host-increase-delay-in-command-response-loop.patch
-net-s2io-set_rxd_buffer_pointer-returns-enomem-not-enomem.patch
-power_supply-add-charge_counter-property-and-olpc_battery-support-for-it-fix.patch
-fs-nfs-callback_xdrc-suppress-uninitialiized-variable-warnings.patch
-nfs-lsm-make-nfsv4-set-lsm-mount-options.patch
-nfs-replace-remaining-__function__-occurrences.patch
-nfs-path_getput-cleanups.patch
-nfs-make-nfs4_drop_state_owner-static.patch
-ntfs-le_add_cpu-conversion.patch
-parisc-new-termios-definitions.patch
-parisc-replace-remaining-__function__-occurences.patch
-drivers-parisc-replace-remaining-__function__-occurrences.patch
-parisc-remove-redundant-display-of-free-swap-space-in-show_mem.patch
-arch-parisc-kernel-unalignedc-use-time_-macros.patch
-pci-hotplug-mm-pciehp-fix-typo-in-dbg_ctrl.patch
-pci-hotplug-mm-pciehp-remove-null-status-register-write.patch
-pci-hotplug-construct-one-fakephp-slot-per-pci-slot.patch
-pci-hotplug-export-kobject_rename-for-pci_hotplug_core.patch
-pci-hotplug-introduce-pci_slot.patch
-pci-hotplug-acpi-pci-slot-detection-driver.patch
-s390-char-vmlogrdr-module-initialization-function-should-return-negative-errors.patch
-mutex-debug-check-mutex-magic-before-owner.patch
-show_schedstat-fix-memleak.patch
-rcu-remove-duplicated-include-in-kernel-rcupreemptc.patch
-rcu-remove-duplicated-include-in-kernel-rcupreempt_tracec.patch
-scsi-use-get_unaligned_-helpers.patch
-fix-gregkh-usb-usb-ohci-host-controller-resumes-leave-root-hub-suspended.patch
-uwb-fix-all-printk-format-warnings.patch
-drivers-uwb-nehc-processor-flags-have-type-unsigned-long.patch
-uwb-fix-scscanf-warning.patch
-drivers-uwb-i1480-dfu-macc-fix-min-warning.patch
-drivers-uwb-i1480-dfu-usbc-fix-size_t-confusion.patch
-drivers-uwb-whcic-needs-dma-mappingh.patch
-usb-usbtest-comment-on-why-this-code-expects-negative-and-positive-errnos.patch
-rndis-switch-to-seq_files.patch
-rndis-switch-to-seq_files-checkpatch-fixes.patch
-net-usb-add-support-for-apple-usb-ethernet-adapter.patch
-itco_wdt-ich9do-support.patch
-watchdog-fix-booke_wdtc-on-mpc85xx-smp-system.patch
-wireless-fix-iwlwifi-unify-init-driver-flow.patch
-mac80211-michaelc-use-kernel-provided-infrastructure.patch
-mac80211-introduce-struct-michael_mic_ctx-and-static-helpers.patch
-mac80211-tkipc-use-kernel-provided-infrastructure.patch
-mac80211-add-const-remove-unused-function-make-one-function-static.patch
-mac80211-add-a-struct-to-hold-tkip-context.patch
-mac80211-tkipc-use-struct-tkip_ctx-in-phase-1-key-mixing.patch
-mac80211-tkipc-use-struct-tkip_ctx-in-phase-2-key-mixing.patch
-b43-replace-limit_value-macro-with-clamp_val.patch
-b43legacy-replace-limit_value-macro-with-clamp_val.patch
-wireless-use-get-put_unaligned_-helpers.patch
-b43-use-the-bitrev-helpers-rather-than-rolling-a-private-one.patch
-xfs-suppress-uninitialized-var-warnings.patch
-module-loading-elf-handling-use-selfmag-instead-of-numeric-constant.patch
-pnp-cleanup-pnp_fixup_device.patch
-pnp-add-pnp_build_option-to-the-api.patch
-pnp-add-isapnp-mpu-option-quirks.patch
-mm-fix-infinite-loop-in-filemap_fault.patch
-atmel_lcdfb-fix-initialization-of-a-pre-allocated-framebuffer.patch
-ipmi-support-i-o-resources-in-of-driver.patch
-memory-hotplug-memmap_init_zone-called-twice.patch
-jbd-need-to-hold-j_state_lock-to-updates-to-transaction-t_state-to-t_commit.patch
-asm-alphah8300umv850xtensa-paramh-unbreak-hz-for-userspace.patch
-cgroups-fix-compile-warning.patch
-ext3-4-fix-uninitialized-bs-in-ext3-4_xattr_set_handle.patch
-video-logo-add-support-for-blackfin-linux-logo-for-framebuffer-console.patch
-lib-create-common-ascii-hex-array.patch
-memory_hotplug-check-for-walk_memory_resource-failure-in-online_pages.patch
-per_cpu-fix-define_per_cpu_shared_aligned-for-modules.patch
-per_cpu-fix-define_per_cpu_shared_aligned-for-modules-fix.patch
-mprotect-prevent-alteration-of-the-pat-bits.patch
-mprotect-prevent-alteration-of-the-pat-bits-checkpatch-fixes.patch
-memory_hotplug-always-initialize-pageblock-bitmap.patch
-char-select-fw_loader-by-moxa.patch
-remove-blkdev-warning-triggered-by-using-md.patch
-tty_check_change-avoid-taking-tasklist_lock-while-holding-tty-ctrl_lock.patch
-colibri-fix-support-for-dm9000-ethernet-device.patch
-colibri-fix-support-for-dm9000-ethernet-device-fix.patch
-cpufreq-fix-null-object-access-on-transmeta-cpu.patch
-cpufreq-arusoe-longrun-cpufreq-module-reports-false-min-freq.patch
-mmc-fix-omap-compile-by-replacing-dev_name-with-dma_dev_name.patch
-ntp-make-the-rtc-sync-mode-11-minute-again.patch
-hostap-procfs-fix-for-hostap_fwc.patch
-mm-allow-pfnmap-faults.patch
-pcmcia-kill-in_card_services.patch
-pcmcia-pccard-deadlock-fix.patch
-accounting-account-for-user-time-when-updating-memory-integrals.patch
-update-checkpatchpl-to-version-019.patch
-update-checkpatchpl-to-version-019-fix.patch
-zorro-replace-deprecated-__initcall-with-equivalent-device_initcall.patch
-xen-drivers-xen-balloonc-make-a-function-static.patch
-video-fix-integer-as-null-pointer-warnings.patch
-documentation-build-source-files-in-documentation-sub-dir.patch
-documentation-build-source-files-in-documentation-sub-dir-disable.patch
-fs-ext4-use-bug_on.patch
-ext4-fix-mount-messages-when-quota-disabled.patch
-ext4-fix-synchronization-of-quota-files-in-journal=data-mode.patch
-ext4-fix-typos-in-messages-and-comments-journalled-journaled.patch
-ext4-correct-mount-option-parsing-to-detect-when-quota-options-can-be-changed.patch
-ext4-switch-to-seq_files.patch
-jbd2-need-to-hold-j_state_lock-during-updates-to-transaction-t_state.patch
-kgdb-use-the-common-ascii-hex-helpers.patch
-mn10300-use-the-common-ascii-hex-helpers.patch
-sh-use-the-common-ascii-hex-helpers.patch
-make-struct-mpt_proc_root_dir-static.patch
-aacraid-linitc-make-aac_show_serial_number-static.patch

 Merged into mainline or a subsystem tree

+agp-add-support-for-radeon-mobility-9000-chipset.patch
+mm-fix-incorrect-variable-type-in-do_try_to_free_pages.patch
+fat-relax-the-permission-check-of-fat_setattr.patch
+m68k-add-ext2_find_firstnext_bit-for-ext4.patch
+m68k-add-ext2_find_firstnext_bit-for-ext4-checkpatch-fixes.patch
+hgafb-resource-management-fix.patch
+isight_firmware-avoid-crash-on-loading-invalid-firmware.patch

 2.6.26 queue

-linux-next-git-rejects.patch
-revert-9p-convert-from-semaphore-to-spinlock.patch
-ia64-kvm-dont-delete-files-which-we-need.patch

 Unneeded

+linux-next-git-rejects.patch
+drivers-net-wireless-iwlwifi-iwl-4965-rsc-config_iwl4965_ht=n-hack.patch
+fix-x86_64-splat.patch
+kvm-unbork.patch
+kvm-is-busted-on-ia64.patch

 Various linux-next fixes

+add-have_clk-to-kconfig-for-driver-dependencies.patch

 Maybe 2.6.26.

+bay-exit-if-notify-handler-cannot-be-installed.patch
+dockc-remove-trailing-printk-whitespace.patch
+acpi-use-memory_read_from_buffer.patch

 ACPI things

+x86-remove-unused-variable-loops-in-arch-x86-boot-a20c.patch
+x86-fix-longstanding-setupc-printk-format-warning.patch

 x86 things

+ac97-add-support-for-wm9711-master-left-inv-switch.patch

 alsa device support

+agp-add-a-missing-via-agp-module-alias.patch
+intel-agp-rewrite-gtt-on-resume.patch
+intel-agp-rewrite-gtt-on-resume-update.patch
+intel-agp-rewrite-gtt-on-resume-update-checkpatch-fixes.patch

 AGP things

-arm-omap1-n770-convert-audio_pwr_sem-in-a-mutex-fix.patch

 Folded into arm-omap1-n770-convert-audio_pwr_sem-in-a-mutex.patch

+remove-drivers-acorn-char-defkeymap-l7200c.patch
+arm-fix-header-guards.patch

 arm things

+kernel-auditc-nlh-nlmsg_type-is-gotten-more-than-once.patch
+audit-remove-useless-argument-type-in-audit_filter_user.patch

 audit things

+cifs-primitive-is-not-an-asn1-class.patch

 CIFS fix

+cm4000_cs-switch-to-unlocked_ioctl.patch
+pcmcia-add-support-the-cf-pcmcia-driver-for-blackfin-try-2.patch
+pcmcia-pccard-deadlock-fix.patch

 PCMCIA things

+macintosh-therm_windtunnel-semaphore-to-mutex.patch
+macintosh-media-bay-semaphore-to-mutex.patch
+arch-powerpc-platforms-pseries-eeh_driverc-fix-warning.patch
+arch-powerpc-platforms-pseries-eeh_driverc-fix-warning-checkpatch-fixes.patch

 powerpc things

+dev_set_name-fix-missing-kernel-doc.patch

 driver tree things

+drm-remove-defines-for-non-linux-systems.patch

 DRM cleanup

+ttusb-use-simple_read_from_buffer.patch

 v4l fix

+hrtimer-remove-unused-variables-in-ktime_divns.patch
+ntp-let-update_persistent_clock-sleep.patch

 timer things

+input-i8042-add-dritek-quirk-for-acer-travelmate-660.patch
+input-add-switch-for-dock-events.patch

 input things

-git-kbuild-fixes.patch

 Unneeded

+kbuild-remove-final-references-to-deprecated-unreferenced-topdir.patch
+kbuild-move-non-__kernel__-checking-headers-to-header-y.patch
+documentation-build-source-files-in-documentation-sub-dir.patch
+documentation-build-source-files-in-documentation-sub-dir-disable.patch

 kbuild things

+leds-add-support-for-philips-pca955x-i2c-led-drivers.patch

 Leds fix

+mips-remove-board_watchpoint_handler.patch

 MIPS fix

-mmc-sd-host-driver-for-ricoh-bay1controllers-fix.patch
-mmc-sd-host-driver-for-ricoh-bay1controllers-fix-2.patch

 Folded into mmc-sd-host-driver-for-ricoh-bay1controllers.patch

+mtd-mtdcharc-silence-sparse-warning.patch
+mtd-mtdcharc-remove-shadowed-variable-warnings.patch
+drivers-mtd-devices-block2mtdc-suppress-warning.patch

 MTD fixes

-git-net-git-rejects.patch

 Unneeded

+drivers-atm-enih-remove-unused-macro-kernel_offset.patch

 net fix

+bluetooth-hci_bcspc-small-cleanups-api-users.patch
+bluetooth-hci_bcspc-small-cleanups-api-users-fix.patch

 bluetooth

+isdn-divas-fix-proc-creation.patch
+isdn-use-simple_read_from_buffer.patch

 ISDN things

+ipg-fix-receivemode-ipg_rm_receivemulticasthash-in-ipg_nic_set_multicast_list.patch
+fec_mpc52xx-mpc52xx_messages_default-2nd-netif_msg_ifdown-=-ifup.patch
+smc911x-remove-unused-8-bit-i-o-operations.patch
+smc911x-fix-16-bit-i-o-operations.patch
+smc911x-pass-along-private-data-and-use-iomem.patch
+smc911x-introduce-platform-data-flags.patch
+smc911x-superh-architecture-support.patch
+net-sh_eth-add-support-for-renesas-superh-ethernet.patch
+net-sh_eth-add-support-for-renesas-superh-ethernet-checkpatch-fixes.patch
+macb-use-random-mac-if-stored-address-in-eeprom-is-invalid.patch
+smc-ultra-get-rid-of-eth%d-message.patch

 netdev

+ocfs2-use-simple_read_from_buffer.patch

 ocfs2 cleanup

+parisc-fix-incomplete-header-guard.patch

 parisc fixlet

-selinux-dopey-hack.patch

 Unneeded

+fakephp-construct-one-fakephp-slot-per-pci-slot.patch
+pci-introduce-pci_slot.patch
+acpi-pci-slot-detection-driver.patch
+acpi-pci-slot-detection-driver-fix.patch

 PCI things

+s390-vmcp-use-simple_read_from_buffer.patch
+s390-use-simple_read_from_buffer.patch
+s390-cio-use-memory_read_from_buffer.patch
+s390-use-memory_read_from_buffer.patch

 s390 cleanups

+sched-sched_clock-lockdep-fix.patch

 fix lockdep glitch

+rcu-remove-unused-field-struct-rcu_data-rcu_tasklet.patch
+netfilter-conntrack_helper-needs-to-include-rculisth.patch

 RCU things

+git-scsi-misc-fix-scsi_dh-build-errors.patch

 Fix git-scsi-misc

+paride-push-ioctl-down-into-driver.patch
+pktcdvd-push-bkl-down-into-driver.patch
+pktcdvd-push-bkl-down-into-driver-fix.patch
+dac960-push-down-bkl.patch
+ipr-use-memory_read_from_buffer.patch
+qla2xxx-use-memory_read_from_buffer.patch
+block-add-blk_queue_update_dma_pad.patch
+ide-use-the-dma-safe-check-for-req_type_ata_pc.patch
+block-blk_rq_map_kern-uses-the-bounce-buffers-for-stack-buffers.patch
+ide-avoid-dma-on-the-stack-for-req_type_ata_pc.patch
+scsi-sr-avoids-useless-buffer-allocation.patch
+cdrom-revert-commit-22a9189-cdrom-use-kmalloced-buffers-instead-of-buffers-on-stack.patch

 block things

-unionfs-broke.patch

 Unneeded

+accessrunner-avoid-unnecessary-memset.patch
+usb-host-use-get-put_unaligned_-helpers-to-fix-more-potential-unaligned-issues.patch
+usb-host-use-get-put_unaligned_-helpers-to-fix-more-potential-unaligned-issues-fix.patch
+usb-host-use-get-put_unaligned_-helpers-to-fix-more-potential-unaligned-issues-fix-2.patch
+usb-cp2101c-fix-sparse-signedness-mismatch-warnings.patch
+usb-speedtchc-fix-sparse-shadowed-variable-warning.patch
+usbmon-use-simple_read_from_buffer.patch
+usb-digi_accelportc-trivial-sparse-lock-annotation.patch

 USB things

-revert-git-v9fs.patch

 Unneeded

-git-watchdog-git-rejects.patch

 Unneeded

+vfs-fix-err_ptr-abuse-in-generic_readlink.patch
+flock-remove-unused-fields-from-file_lock_operations.patch

 VFS things

+git-unprivileged-mounts.patch

 
+at91sam9-cap9-watchdog-driver.patch
+watchdog-clean-acquirewdt-and-check-for-bkl-dependancies.patch
+watchdog-clean-up-and-check-advantech-watchdog.patch
+watchdog-ali-watchdog-locking-and-style.patch
+watchdog-ar7-watchdog.patch
+watchdog-atp-watchdog.patch
+watchdog-at91-watchdog-to-unlocked_ioctl.patch
+watchdog-cpu5_wdt-switch-to-unlocked_ioctl.patch
+watchdog-davinci_wdt-unlocked_ioctl-and-check-locking.patch
+watchdog-ep93xx_wdt-unlocked_ioctl.patch
+watchdog-eurotechwdt-unlocked_ioctl-code-lock-check-and-tidy.patch
+watchdog-hpwdt-couple-of-include-cleanups.patch
+watchdog-ib700wdt-clean-up-and-switch-to-unlocked_ioctl.patch
+watchdog-i6300esb-style-unlocked_ioctl-cleanup.patch
+watchdog-ibmasr-coding-style-locking-verify.patch
+watchdog-indydog-clean-up-and-tidy.patch
+watchdog-iop-watchdog-switch-to-unlocked_ioctl.patch
+watchdog-it8712f-unlocked_ioctl.patch
+watchdog-bfin-watchdog-cleanup-and-unlocked_ioctl.patch
+watchdog-ixp2000_wdt-clean-up-and-unlocked_ioctl.patch
+watchdog-ixp4xx_wdt-unlocked_ioctl.patch
+watchdog-ks8695_wdt-clean-up-coding-style-unlocked_ioctl.patch
+watchdog-machzwd-clean-up-coding-style-unlocked_ioctl.patch
+watchdog-mixcomwd-coding-style-locking-unlocked_ioctl.patch
+watchdog-mpc-watchdog-clean-up-and-locking.patch
+watchdog-mpcore-watchdog-unlocked_ioctl-and-bkl-work.patch
+watchdog-mtx-1_wdt-clean-up-coding-style-unlocked-ioctl.patch
+watchdog-mv64x60_wdt-clean-up-and-locking-checks.patch
+watchdog-omap_wdt-locking-unlocked_ioctl-tidy.patch
+watchdog-pc87413_wdt-clean-up-coding-style-unlocked_ioctl.patch
+watchdog-pcwd-clean-up-unlocked_ioctl-usage.patch
+watchdog-pcwd-clean-up-unlocked_ioctl-usage-fix.patch
+watchdog-pnx4008_wdt-unlocked_ioctl-setup.patch
+watchdog-rm9k_wdt-clean-up.patch
+watchdog-s3c2410-watchdog-cleanup-and-switch-to-unlocked_ioctl.patch
+watchdog-sa1100_wdt-switch-to-unlocked_ioctl.patch
+watchdog-sbc60xxwdt-clean-up-and-switch-to-unlocked_ioctl.patch
+watchdog-stg7240_wdt-unlocked_ioctl.patch
+watchdog-sbc8360-clean-up.patch
+watchdog-sbc_epx_c3_wdt-switch-to-unlocked_ioctl.patch
+watchdog-sb_wdog-clean-up-and-switch-to-unlocked_ioctl.patch
+watchdog-sc1200_wdt-clean-up-fix-locking-and-use-unlocked_ioctl.patch
+watchdog-sc520_wdt-clean-up-and-switch-to-unlocked_ioctl.patch
+watchdog-scx200_wdt-clean-up-and-switch-to-unlocked_ioctl.patch
+watchdog-shwdt-coding-style-cleanup-switch-to-unlocked_ioctl.patch
+watchdog-smsc37b787_wdt-coding-style-switch-to-unlocked_ioctl.patch
+watchdog-softdog-clean-up-coding-style-and-switch-to-unlocked_ioctl.patch
+watchdog-txx9-fix-locking-switch-to-unlocked_ioctl.patch
+watchdog-w83627hf-coding-style-clean-up-and-switch-to-unlocked_ioctl.patch
+watchdog-w83877f_wdt-clean-up-code-coding-style-switch-to-unlocked_ioctl.patch
+watchdog-w83977f_wdt-clean-up-coding-style-and-switch-to-unlocked_ioctl.patch
+watchdog-wafer5823wdt-clean-up-coding-style-switch-to-unlocked_ioctl.patch
+watchdog-wdrtas-clean-up-coding-style-switch-to-unlocked_ioctl.patch
+watchdog-wdt285-switch-to-unlocked_ioctl-and-tidy-up-oddments-of-coding-style.patch
+watchdog-wdt977-clean-up-coding-style-and-switch-to-unlocked_ioctl.patch
+watchdog-wdt501-pci-clean-up-coding-style-and-switch-to-unlocked_ioctl.patch
+watchdog-wdt501-pci-clean-up-coding-style-and-switch-to-unlocked_ioctl-fix.patch
+pcwd-a-couple-of-watchdogs-escaped-conversion.patch
+mpc83xx_wdt-convert-to-the-of-platform-driver.patch
+mpc83xx_wdt-add-support-for-mpc86xx-cpus.patch
+mpc83xx_wdt-rename-to-mpc8xxx_wdt.patch
+mpc8xxx_wdt-various-renames-mostly-s-mpc83xx-mpc8xxx-g.patch
+mpc8xxx_wdt-add-support-for-mpc8xx-watchdogs.patch
+powerpc-fsl_soc-remove-mpc83xx_wdt-code.patch
+powerpc-86xx-mpc8610_hpcd-add-watchdog-node.patch

 A few watchdog patches I picked up.

+airo-use-simple_read_from_buffer.patch

 wireless cleanup

-git-orion-git-rejects.patch

 Unneeded

-ext4-is-busted-on-m68k.patch

 It got unbusted

+maintainers-update-maintainership-of-pxa2xx-pxa3xx.patch
+#provide-rtc_cmos-platform-device-take-2.patch: david-b wibbling
+provide-rtc_cmos-platform-device-take-2.patch
+provide-rtc_cmos-platform-device-take-2-fix.patch
+rtc-make-hpet_rtc_irq-track-hpet_emulate_rtc.patch
+rtc-ramtron-fm3130-rtc-support.patch
+fat_valid_media-isnt-for-userspace.patch
+mmc-wbsd-initialize-tasklets-before-requesting-interrupt.patch

 More 2.6.26 queue

+acpi-fix-drivers-acpi-gluec-build-error.patch
+spi-fix-list-scan-success-verification-in-pxa-ssp-driver.patch
+nand-flash-fix-timings-for-at91sam9x-evaluation-kits.patch
+audit-fix-kernel-doc-parameter-notation.patch
+cifs-fix-oops-on-mount-when-config_cifs_dfs_upcall-is-enabled.patch
+dm-crypt-add-cond_resched-to-crypt_convert.patch
+ext4-fix-online-resize-bug.patch
+mtd-m25p80-fix-bug-atmel-spi-flash-fails-to-be-copied-to.patch
+mtd-m25p80-fix-bug-atmel-spi-flash-fails-to-be-copied-to-fix-up.patch
+gigaset-fix-module-reference-counting.patch
+drivers-isdn-sc-ioctlc-add-missing-kfree.patch
+forcedeth-msi-interrupts.patch
+pnpacpi-fix-irq-flag-decoding.patch
+pnpacpi-fix-irq-flag-decoding-comment-fix.patch
+pnpacpi-fix-shareable-irq-encode-decode.patch
+pnpacpi-use-_crs-irq-descriptor-length-for-_srs-v2.patch
+ftrace-disable-function-tracing-bringing-up-new-cpu.patch
+sched-fix-memory-leak-in-the-cpu-hotplug-handing-logic.patch
+sched-cpu-hotplug-events-must-not-destroy-scheduler-domains-created-by-the-cpusets.patch
+sched-fix-task_wakekill-vs-sigkill-race.patch
+__mutex_lock_common-use-signal_pending_state.patch
+do_generic_file_read-s-eintr-eio-if-lock_page_killable-fails.patch
+vfs-utimensat-ignore-tv_sec-if-tv_nsec-==-utime_omit-or-utime_now.patch
+vfs-utimensat-be-consistent-with-utime-for-immutable-and-append-only-files.patch
+vfs-utimensat-fix-error-checking-for-utime_nowutime_omit-case.patch
+vfs-utimensat-fix-error-checking-for-utime_nowutime_omit-case-cleanup.patch
+vfs-utimensat-fix-write-access-check-for-futimens.patch

 Patches which I think should be in 2.6.26 but which go vie subsystem trees.

+x86-fix-lockdep-warning-during-suspend-to-ram.patch

 Fix interrupt annotation

+access_process_vm-device-memory-infrastructure.patch
+access_process_vm-device-memory-infrastructure-fix.patch
+use-generic_access_phys-for-dev-mem-mappings.patch
+use-generic_access_phys-for-dev-mem-mappings-fix.patch
+use-generic_access_phys-for-pci-mmap-on-x86.patch
+powerpc-ioremap_prot.patch
+spufs-use-the-new-vm_ops-access.patch
+spufs-use-the-new-vm_ops-access-fix.patch
+mm-remove-double-indirection-on-tlb-parameter-to-free_pgd_range-co.patch
+buddy-clarify-comments-describing-buddy-merge.patch
+fix-soft-lock-up-at-nfs-mount-by-per-sb-lru-list-of-unused-dentries.patch
+fix-soft-lock-up-at-nfs-mount-by-per-sb-lru-list-of-unused-dentries-fix.patch
+page-flags-record-page-flag-overlays-explicitly.patch
+page-flags-record-page-flag-overlays-explicitly-xen.patch
+slub-record-page-flag-overlays-explicitly.patch
+slob-record-page-flag-overlays-explicitly.patch
+mapping_set_error-add-unlikely.patch
+mm-drop-unneeded-pgdat-argument-from-free_area_init_node.patch
+vfs-pagecache-usage-optimization-onpagesize=blocksize-environment.patch
+hugetlb-move-hugetlb_acct_memory.patch
+hugetlb-reserve-huge-pages-for-reliable-map_private-hugetlbfs-mappings-until-fork.patch
+hugetlb-guarantee-that-cow-faults-for-a-process-that-called-mmapmap_private-on-hugetlbfs-will-succeed.patch
+hugetlb-guarantee-that-cow-faults-for-a-process-that-called-mmapmap_private-on-hugetlbfs-will-succeed-fix.patch
+hugetlb-guarantee-that-cow-faults-for-a-process-that-called-mmapmap_private-on-hugetlbfs-will-succeed-build-fix.patch
+huge-page-private-reservation-review-cleanups.patch
+huge-page-private-reservation-review-cleanups-fix.patch
+mm-record-map_noreserve-status-on-vmas-and-fix-small-page-mprotect-reservations.patch
+hugetlb-move-reservation-region-support-earlier.patch
+hugetlb-allow-huge-page-mappings-to-be-created-without-reservations.patch
+hugetlb-allow-huge-page-mappings-to-be-created-without-reservations-cleanups.patch
+generic_file_aio_read-cleanups.patch
+tmpfs-support-aio.patch
+sync_file_range_write-may-and-will-block-document-that.patch
+sync_file_range_write-may-and-will-block-document-that-fix.patch
+vmallocinfo-add-numa-information.patch
+vmallocinfo-add-numa-information-fix.patch
+hugetlb-factor-out-prep_new_huge_page.patch
+hugetlb-modular-state-for-hugetlb-page-size.patch
+hugetlb-modular-state-for-hugetlb-page-size-checkpatch-fixes.patch
+hugetlb-multiple-hstates-for-multiple-page-sizes.patch
+hugetlb-multiple-hstates-for-multiple-page-sizes-checkpatch-fixes.patch
+hugetlbfs-per-mount-huge-page-sizes.patch
+hugetlb-new-sysfs-interface.patch
+hugetlb-abstract-numa-round-robin-selection.patch
+mm-introduce-non-panic-alloc_bootmem.patch
+mm-export-prep_compound_page-to-mm.patch
+hugetlb-support-larger-than-max_order.patch
+hugetlb-support-boot-allocate-different-sizes.patch
+hugetlb-printk-cleanup.patch
+hugetlb-introduce-pud_huge.patch
+x86-support-gb-hugepages-on-64-bit.patch
+x86-add-hugepagesz-option-on-64-bit.patch
+hugetlb-override-default-huge-page-size.patch
+hugetlb-override-default-huge-page-size-ia64-build.patch
+hugetlb-allow-arch-overried-hugepage-allocation.patch
+powerpc-function-to-allocate-gigantic-hugepages.patch
+powerpc-scan-device-tree-for-gigantic-pages.patch
+powerpc-define-support-for-16g-hugepages.patch
+fs-check-for-statfs-overflow.patch
+powerpc-support-multiple-hugepage-sizes.patch
+bootmem-reorder-code-to-match-new-bootmem-structure.patch
+bootmem-clean-up-bootmemc-file-header.patch
+bootmem-add-documentation-to-api-functions.patch
+bootmem-add-debugging-framework.patch
+bootmem-add-debugging-framework-fix.patch
+bootmem-revisit-bitmap-size-calculations.patch
+bootmem-revisit-bootmem-descriptor-list-handling.patch
+bootmem-clean-up-free_all_bootmem_core.patch
+bootmem-clean-up-free_all_bootmem_core-fix.patch
+bootmem-clean-up-alloc_bootmem_core.patch
+bootmem-free-reserve-helpers.patch
+bootmem-free-reserve-helpers-fix.patch
+bootmem-factor-out-the-marking-of-a-pfn-range.patch
+bootmem-factor-out-the-marking-of-a-pfn-range-fix.patch
+bootmem-respect-goal-more-likely.patch
+bootmem-make-__alloc_bootmem_low_node-fall-back-to-other-nodes.patch
+bootmem-revisit-alloc_bootmem_section.patch
+bootmem-replace-node_boot_start-in-struct-bootmem_data.patch

 Memory management updates

+security-protect-legacy-apps-from-insufficient-privilege.patch
+security-protect-legacy-apps-from-insufficient-privilege-cleanup.patch

 Security things

+gigaset-use-dev_-macros-for-messages.patch
+gigaset-gigaset_isowbuf_getbytes-may-return-signed-unnoticed.patch

 gigaset driver updates

+snapshot-push-bkl-down-into-ioctl-handlers.patch
+swsusp-provide-users-with-a-hint-about-the-no_console_suspend-option.patch
+swsusp-provide-users-with-a-hint-about-the-no_console_suspend-option-fix.patch
+pm-boot-time-suspend-selftest.patch
+remove-include-linux-pm_legacyh.patch

 power management

+cris-remove-unused-global_flush_tlb.patch
+cris-use-simple_read_from_buffer.patch

 cris updates

+list_for_each_rcu-must-die-networking.patch
+#percpu-introduce-define_per_cpu_page_aligned.patch: Rusty queries
+percpu-introduce-define_per_cpu_page_aligned.patch
+remove-argument-from-open_softirq-which-is-always-null.patch
+lib-taint-kernel-in-common-report_bug-warn-path.patch
+build-kernel-profileo-only-when-requested.patch
+build-kernel-profileo-only-when-requested-cleanups.patch
+asm-generic-int-ll64h-always-provide-__su64.patch
+remove-some-more-tipar-bits.patch
+call_usermodehelper-increase-reliability.patch
+fs-partition-checkc-fix-return-value-warning.patch
+fs-partition-checkc-fix-return-value-warning-v2-cleanup.patch
+block-ioctlc-and-fs-partition-checkc.patch
+block-ioctlc-and-fs-partition-checkc-checkpatch-fixes.patch
+misc-add-hp-wmi-laptop-extras-driver.patch
+clean-up-duplicated-alloc-free_thread_info.patch

 Misc

+remove-the-oss-trident-driver.patch
+remove-the-oss-trident-driver-fix.patch
+config_sound_wm97xx-remove-stale-makefile-line.patch

 OSS drivers

+binfmt_misc-use-simple_read_from_buffer.patch

 ninfmt_misc cleanup

+add-a-warn-macro-this-is-warn_on-printk-arguments-fix-2.patch
+kernel-irq-managec-replace-a-printk-warn_on-to-a-warn.patch

 More WARN_ON fiddling

+list-debugging-use-warn_on-instead-of-bug.patch

 list-management update

+flag-parameters-signalfd-fix.patch

 Fix flag-parameters-signalfd.patch

+flag-parameters-eventfd-fix.patch

 Fix flag-parameters-eventfd.patch

+flag-parameters-check-magic-constants-alpha.patch

 Fix flag-parameters-check-magic-constants.patch

+cputopology-always-define-cpu-topology-information.patch
+cputopology-always-define-cpu-topology-information-cleanup.patch

 CPU topology updates

+8250-fix-break-handling-for-intel-82571.patch
+serial-add-support-for-a-no-name-4-ports-multiserial-card.patch

 Serial updates

+oprofile-multiplexing.patch
+oprofile-multiplexing-checkpatch-fixes.patch

 oprofile feature (future is unertain)

+spi-make-spi_board_infomodalias-a-char-array.patch
+spidev-bkl-removal.patch

 SPI updates

+vt-hold-console_sem-across-sysfs-operations.patch

 VT fix

+kprobes-improve-kretprobe-scalability-with-hashed-locking.patch

 kprobes speedup

+i2o-handle-sysfs_create_link-failures.patch

 i2o fix

+ecryptfs-privileged-kthread-for-lower-file-opens.patch

 ecryptfs work

+rtc-push-the-bkl-down-into-the-driver-ioctl-method.patch
+rtc-push-the-bkl-down-into-the-driver-ioctl-method-fix.patch

 RTC updates

+gpio-gpio-driver-for-max7301-spi-gpio-expander.patch
+gpio-gpio-driver-for-max7301-spi-gpio-expander-checkpatch-fixes.patch

 GPIO updates

+tridentfb-acceleration-code-improvements.patch
+tridentfb-acceleration-bug-fixes.patch
+tridentfb-various-pixclock-and-timing-improvements.patch
+tridentfb-acceleration-constants-change.patch
+tridentfb-source-code-improvements.patch
+tridentfb-fix-console-freeze-when-switching-from-x11.patch
+tridentfb-fix-224-color-logo-at-8-bpp.patch
+tridentfb-y-panning-fixes.patch
+tridentfb-blade3d-clock-fixes.patch
+atmel_lcdfb-fifo-underflow-management.patch
+atmel_lcdfb-fifo-underflow-management-rework.patch
+fbcon-make-logo_height-a-local-variable.patch
+uvesafb-change-mode-parameter-to-mode_option.patch
+tridentfb-documentation-update.patch
+tdfxfb-add-mode_option-module-parameter.patch
+vga16fb-source-code-improvement.patch
+tdfxfb-remove-ypan-checks-done-by-a-higher-layer.patch
+video-superh-mobile-lcdc-driver.patch
+video-superh-mobile-lcdc-driver-update.patch
+vfb-only-enable-if-explicitly-requested-when-compiled-in.patch
+hgafb-convert-to-new-platform-driver-api-bugzilla-9689.patch
+fbdev-width-and-height-are-unsigned.patch
+fbdev-xoffset-yoffset-and-yres-are-unsigned.patch
+atyfb-remove-dead-code.patch
+atyfb-correct_chipset-can-fail.patch
+atyfb-use-a-pci-device-id-table.patch
+atyfb-report-probe-errors.patch
+atyfb-fix-a-cast.patch
+aty-use-memory_read_from_buffer.patch
+skeletonfb-update-to-correct-platform-driver-usage.patch
+atmel_lcdfb-avoid-division-by-zero.patch
+atmel_lcdfb-avoid-division-by-zero-checkpatch-fixes.patch

 fbdev updates

+pnp-make-pnp_portmemetc_start-et-al-work-for-invalid-resources.patch
+pnp-replace-pnp_resource_table-with-dynamically-allocated-resources.patch
+pnp-replace-pnp_resource_table-with-dynamically-allocated-resources-fix.patch
+pnp-remove-ratelimit-on-add-resource-failures.patch
+pnp-dont-sort-by-type-in-sys-resources.patch
+pnp-set-the-pnp_card-dma_mask-for-use-by-isapnp-cards.patch
+isa-set-24-bit-dma_mask-for-isa-devices.patch
+pnp-add-pnp_possible_config-can-a-device-could-be-configured-this-way.patch
+pnp-add-pnp_possible_config-can-a-device-could-be-configured-this-way-fix.patch
+pnp-whitespace-coding-style-fixes.patch
+pnp-define-pnp-specific-ioresource_io_-flags-alongside-irq-dma-mem.patch
+pnp-make-resource-option-structures-private-to-pnp-subsystem.patch
+pnp-introduce-pnp_irq_mask_t-typedef.patch
+pnp-increase-i-o-port-memory-option-address-sizes.patch
+pnp-improve-resource-assignment-debug.patch
+pnp-in-debug-resource-dump-make-empty-list-obvious.patch
+pnp-make-resource-assignment-functions-return-0-success-or-ebusy-failure.patch
+pnp-remove-redundant-pnp_can_configure-check.patch
+pnp-centralize-resource-option-allocations.patch
+pnpacpi-ignore-_prs-interrupt-numbers-larger-than-pnp_irq_nr.patch
+pnp-rename-pnp_register__resource-local-variables.patch
+pnp-support-optional-irq-resources.patch
+pnp-remove-extra-0x100-bit-from-option-priority.patch
+isapnp-handle-independent-options-following-dependent-ones.patch
+pnp-convert-resource-options-to-single-linked-list.patch
+pnp-convert-resource-options-to-single-linked-list-checkpatch-fixes.patch

 PNP updates

+ext2-remove-double-definitions-of-xattr-macros.patch

 ext2 cleanup

+ext3-improve-some-code-in-rb-tree-part-of-dirc.patch
+jbd-fix-race-between-free-buffer-and-commit-trasanction.patch
+jbd-fix-race-between-free-buffer-and-commit-trasanction-checkpatch-fixes.patch
+jbd-fix-race-between-free-buffer-and-commit-trasanction-checkpatch-fixes-fix.patch
+ext3-remove-double-definitions-of-xattr-macros.patch
+jbd-strictly-check-for-write-errors-on-data-buffers.patch
+jbd-ordered-data-integrity-fix.patch
+jbd-abort-when-failed-to-log-metadata-buffers.patch
+jbd-fix-error-handling-for-checkpoint-io.patch
+ext3-abort-ext3-if-the-journal-has-aborted.patch
+ext3-abort-ext3-if-the-journal-has-aborted-warning-fix.patch

 ext3 updates (some will be dropped)

+reiserfs-remove-double-definitions-of-xattr-macros.patch

 reserfs cleanup

+msdos-fs-remove-unsettable-atari-option.patch

 msdos fixlet

+quota-rename-quota-functions-from-upper-case-make-bigger-ones-non-inline.patch
+quota-cleanup-loop-in-sync_dquots.patch
+quota-move-function-macros-from-quotah-to-quotaopsh.patch
+quota-move-function-macros-from-quotah-to-quotaopsh-jfs-fix.patch
+quota-move-function-macros-from-quotah-to-quotaopsh-jfs-fix-fix.patch
+quota-convert-macros-to-inline-functions.patch

 quote cleanups

+cgroup-list_for_each-cleanup-v2.patch
+cgroup-anotate-two-variables-with-__read_mostly.patch

 cgroups updates

+memcg-remove-refcnt-from-page_cgroup.patch
+memcg-remove-refcnt-from-page_cgroup-fix.patch
+memcg-handle-swap-cache.patch
+memcg-handle-swap-cache-fix.patch
+memcg-helper-function-for-relcaim-from-shmem.patch
+memcg-add-hints-for-branch.patch
+memcg-remove-a-redundant-check.patch
+memcg-clean-up-checking-of-the-disabled-flag.patch

 memoru controller updates

+memrlimit-add-memrlimit-controller-documentation.patch
+memrlimit-setup-the-memrlimit-controller.patch
+memrlimit-cgroup-mm-owner-callback-changes-to-add-task-info.patch
+memrlimit-add-memrlimit-controller-accounting-and-control.patch

 New cgroup conrtoller

+cpusets-restructure-the-function-update_cpumask-and-update_nodemask.patch
+cpusets-update-tasks-cpus_allowed-and-mems_allowed-after-cpu-node-offline-online.patch

 cpusets work

+introduce-pf_kthread-flag.patch
+kill-pf_borrowed_mm-in-favour-of-pf_kthread.patch
+coredump-zap_threads-must-skip-kernel-threads.patch

 coredump fixlet

+posix-timers-timer_delete-remove-the-bogus-it_process-=-null-check.patch
+posix-timers-release_posix_timer-kill-the-bogus-put_task_struct-it_process.patch
+signals-collect_signal-remove-the-unneeded-sigismember-check.patch
+signals-collect_signal-simplify-the-still_pending-logic.patch
+signals-change-collect_signal-to-return-void.patch
+__exit_signal-dont-take-rcu-lock.patch
+signals-dequeue_signal-dont-check-signal_group_exit-when-setting-signal_stop_dequeued.patch
+signals-do_signal_stop-kill-the-signal_unkillable-check.patch
+coredump-zap_threads-comments-use-while_each_thread.patch

 Signal management updates

 ext4-mm-stable-boundary.patch
 ext4-mm-stable-boundary-undo.patch
+ext4-mm-ext4-new-defm-options.patch
+ext4-mm-ext4-call-blkdev_issue_flush-on-fsync.patch
 ext4-mm-ext4-page-mkwrite.patch
-ext4-mm-ext4-retry-if-allocated-from-system-zone.patch
 ext4-mm-ext4_ialloc-flexbg.patch
 ext4-mm-delalloc-vfs.patch
 ext4-mm-ext4-fix-fs-corruption-with-delalloc.patch
 ext4-mm-delalloc-ext4.patch
+ext4-mm-delalloc-ext4-release-page-when-write_begin-failed.patch
 ext4-mm-delalloc-ext4-preallocation-handling.patch
 ext4-mm-delalloc-i-disksize-update.patch
 ext4-mm-jbd-blocks-reservation-fix-for-large-blk.patch
 ext4-mm-ext4-online-defrag-for-relevant-files.patch
 ext4-mm-ext4-online-defrag-check-for-freespace-fragmentation.patch
 ext4-mm-ext4-online-defrag-move-victim-files.patch
-ext4-mm-jbd2-commit-time.patch
 ext4-mm-vfs-fiemap.patch
 ext4-mm-ext4-add-ext4_ext_walk_space.patch
 ext4-mm-ext4-fiemap.patch
-ext4-mm-ext4-inverse-pagelock-vs-transaction.patch
-ext4-mm-delalloc-ext4-lock-reverse.patch

 hm, why isn't ext4 in linux-next?

+ext4-error-proc-entry-creation-when-the-fs-ext4-is-not-correctly-created.patch
+ext4-improve-some-code-in-rb-tree-part-of-dirc.patch
+ext4-remove-double-definitions-of-xattr-macros.patch
+ext4-error-processing-and-coding-enhancement-for-mballoc.patch
+ext4-fix-error-processing-in-mb_free_blocks.patch
+jbd2-fix-race-between-jbd2_journal_try_to_free_buffers-and-jbd2-commit-transaction.patch
+jbd2-fix-race-between-jbd2_journal_try_to_free_buffers-and-jbd2-commit-transaction-cleanup.patch

 ext4 things

+idr-make-idr_get_new-rcu-safe-fix.patch

 Fix idr-make-idr_get_new-rcu-safe.patch

+ipc-semc-convert-undo-structures-to-struct-list_head.patch
+ipc-semc-convert-undo-structures-to-struct-list_head-checkpatch-fixes.patch
+ipc-semc-remove-unused-entries-from-struct-sem_queue.patch
+ipc-semc-convert-sem_arraysem_pending-to-struct-list_head.patch
+ipc-semc-convert-sem_arraysem_pending-to-struct-list_head-checkpatch-fixes.patch
+ipc-semc-rewrite-undo-list-locking.patch
+ipc-semc-rewrite-undo-list-locking-checkpatch-fixes.patch
+ipc-use-simple_read_from_buffer.patch

 IPC updates

+tty-remove-unused-var-real_tty-in-n_tty_ioctl.patch

 tty work

+efirtc-push-down-the-bkl.patch
+ip2-push-bkl-down-for-the-firmware-interface.patch
+mwave-ioctl-bkl-pushdown.patch
+rio-push-down-the-bkl-into-the-firmware-ioctl-handler.patch
+sx-push-bkl-down-into-the-firmware-ioctl-handler.patch
+ixj-push-bkl-into-driver-and-wrap-ioctls.patch
+ppdev-wrap-ioctl-handler-in-driver-and-push-lock-down.patch
+ds1302-push-down-the-bkl-into-the-driver-ioctl-code.patch
+dsp56k-bkl-pushdown.patch
+zorro-use-memory_read_from_buffer.patch
+nwflash-use-simple_read_from_buffer.patch

 char driver work

+sgi-xp-define-is_shub-and-is_uv-macros.patch
+sgi-xp-define-xpsalerror-reason-code.patch
+sgi-xp-define-bytes_per_word.patch
+sgi-xp-support-runtime-selection-of-xp_max_npartitions.patch
+sgi-xp-create-a-common-xp_remote_memcpy-function.patch
+sgi-xp-prepare-xpc_rsvd_page-to-work-on-either-sn2-or-uv-hardware.patch
+sgi-xp-isolate-xpc_vars_part-structure-to-sn2-only.patch
+sgi-xp-isolate-xpc_vars-structure-to-sn2-only.patch
+sgi-xp-base-xpc_rsvd_pages-timestamp-on-jiffies.patch
+sgi-xp-move-xpc_allocate-into-xpc_send-xpc_send_notify.patch
+sgi-xp-isolate-activate-irqs-hardware-specific-components.patch
+sgi-xp-isolate-additional-sn2-specific-code.patch
+sgi-xp-separate-chctl_flags-from-xpcs-notify-irq.patch
+sgi-xp-replace-amo_t-typedef-by-struct-amo.patch
+sgi-xp-isolate-allocation-of-xpcs-msgqueues-to-sn2-only.patch
+sgi-xp-enable-xpnet-to-handle-more-than-64-partitions.patch
+sgi-xp-isolate-remote-copy-buffer-to-sn2-only.patch
+sgi-xp-add-_sn2-suffix-to-a-few-variables.patch

 SGI XP driver updates

+firmware-use-memory_read_from_buffer.patch
+dcdbas-use-memory_read_from_buffer.patch
+dell_rbu-use-memory_read_from_buffer.patch

 cleanups

+sysctl-check-for-bogus-modes.patch
+sysctl-allow-override-of-proc-sys-net-with-cap_net_admin.patch

 susctl work

+ata-over-ethernet-convert-emsgs_sema-in-a-completion.patch

 AOE

+markers-use-rcu_barrier_sched-and-call_rcu_sched.patch

 Markers

+accounting-account-for-user-time-when-updating-memory-integrals.patch

 accounting feature

+bsdacct-rename-acct_blbls-to-bsd_acct_struct.patch
+pidns-use-kzalloc-when-allocating-new-pid_namespace-struct.patch
+pidns-add-the-struct-bsd_acct_struct-pointer-on-pid_namespace-struct.patch
+bsdacct-truthify-a-comment-near-acct_process.patch
+bsdacct-make-check-timer-accept-a-bsd_acct_struct-argument.patch
+bsdacct-turn-the-acct_lock-from-on-the-struct-to-global.patch
+bsdacct-make-internal-code-work-with-passed-bsd_acct_struct-not-global.patch
+bsdacct-switch-from-global-bsd_acct_struct-instance-to-per-pidns-one.patch
+bsdacct-turn-acct-off-for-all-pidns-s-on-umount-time.patch
+bsdacct-account-dying-tasks-in-all-relevant-namespaces.patch
+bsdacct-stir-up-comments-around-acct_process.patch

 BSD accountig work

+distinct-tgid-tid-i-o-statistics.patch
+update-taskstats-struct-document-for-scaled-time-accounting.patch
+per-task-delay-accounting-add-memory-reclaim-delay.patch
+per-task-delay-accounting-update-taskstats-for-memory-reclaim-delay.patch
+per-task-delay-accounting-update-document-and-getdelaysc-for-memory-reclaim.patch
+getdelaysc-add-a-usr1-signal-handler.patch
+getdelaysc-add-a-usr1-signal-handler-checkpatch-fixes.patch

 taskstats work

+lockd-dont-return-eagain-for-a-permanent-error.patch
+locks-add-special-return-value-for-asynchronous-locks.patch
+locks-cleanup-code-duplication.patch
+locks-allow-lock-to-return-file_lock_deferred.patch
+fuse-prepare-lookup-for-nfs-export.patch
+fuse-add-export-operations.patch
+fuse-add-fuse_lookup_name-helper.patch
+fuse-nfs-export-special-lookups.patch
+fuse-lockd-support.patch

 FUSE updates

+dma-mapping-add-the-device-argument-to-dma_mapping_error.patch
+dma-mapping-add-the-device-argument-to-dma_mapping_error-sge-fix.patch
+dma-mapping-add-the-device-argument-to-dma_mapping_error-svc_rdma-fix.patch
+dma-mapping-add-the-device-argument-to-dma_mapping_error-bnx2x.patch
+dma-mapping-add-the-device-argument-to-dma_mapping_error-sparc32.patch
+dma-mapping-x86-per-device-dma_mapping_ops-support.patch
+dma-mapping-x86-per-device-dma_mapping_ops-support-fix.patch

 DMA-mapping updates

+bfs-assorted-cleanups.patch
+bfs-kill-bkl.patch

 bfs maintenance

+tpm-correct-tpm-timeouts-to-jiffies-conversion.patch
+tpm-increase-size-of-internal-tpm-response-buffers.patch
+tpm-increase-size-of-internal-tpm-response-buffers-checkpatch-fixes.patch

 TPM updates

+memstick-allow-set_param-method-to-return-an-error-code.patch
+memstick-allow-set_param-method-to-return-an-error-code-checkpatch-fixes.patch
+memstick-add-start-and-stop-methods-to-memstick-device.patch
+revert-linux-next-changes-to-make-memstick-use-fully-asynchronous-request-processing-apply.patch
+memstick-use-fully-asynchronous-request-processing.patch
+revert-revert-linux-next-changes-to-make-memstick-use-fully-asynchronous-request-processing-apply.patch

 memstick fixlets

+mn10300-use-the-common-ascii-hex-helpers.patch

 mn10300 cleanup

+common-implementation-of-iterative-div-mod.patch
+add-an-inlined-version-of-iter_div_u64_rem.patch
+always_inline-timespec_add_ns.patch

 Might fix a few problems with open-coded div/mods

+kernel-call-constructors.patch
+kernel-introduce-gcc_version_lower-macro.patch
+seq_file-add-function-to-write-binary-data.patch
+gcov-add-gcov-profiling-infrastructure.patch
+gcov-create-links-to-gcda-files-in-build-directory.patch
+gcov-architecture-specific-compile-flag-adjustments.patch

 gcov feature

+x86-implement-pte_special.patch
+mm-introduce-get_user_pages_fast.patch
+mm-introduce-get_user_pages_fast-fix.patch
+mm-introduce-get_user_pages_fast-checkpatch-fixes.patch
+x86-lockless-get_user_pages_fast.patch
+x86-lockless-get_user_pages_fast-checkpatch-fixes.patch
+x86-lockless-get_user_pages_fast-fix.patch
+x86-lockless-get_user_pages_fast-fix-2.patch
+x86-lockless-get_user_pages_fast-fix-2-fix.patch
+x86-lockless-get_user_pages_fast-fix-2-fix-fix.patch
+x86-lockless-get_user_pages_fast-fix-warning.patch
+dio-use-get_user_pages_fast.patch
+splice-use-get_user_pages_fast.patch

 fast get_user_pages() for x86

+mm-readahead-scan-lockless.patch
+radix-tree-add-gang_lookup_slot-gang_lookup_slot_tag.patch
+mm-speculative-page-references.patch
+mm-speculative-page-references-fix.patch
+mm-lockless-pagecache.patch
+mm-spinlock-tree_lock.patch
+powerpc-implement-pte_special.patch

 lockess pagecache

+vmscan-move-isolate_lru_page-to-vmscanc.patch
+vmscan-use-an-indexed-array-for-lru-variables.patch
+vmscan-use-an-array-for-the-lru-pagevecs.patch
+vmscan-free-swap-space-on-swap-in-activation.patch
+vmscan-define-page_file_cache-function.patch
+vmscan-split-lru-lists-into-anon-file-sets.patch
+vmscan-second-chance-replacement-for-anonymous-pages.patch
+vmscan-add-some-sanity-checks-to-get_scan_ratio.patch
+vmscan-fix-pagecache-reclaim-referenced-bit-check.patch
+vmscan-add-newly-swapped-in-pages-to-the-inactive-list.patch
+vmscan-more-aggressively-use-lumpy-reclaim.patch
+vmscan-pageflag-helpers-for-configed-out-flags.patch
+vmscan-noreclaim-lru-infrastructure.patch
+vmscan-noreclaim-lru-page-statistics.patch
+vmscan-ramfs-and-ram-disk-pages-are-non-reclaimable.patch
+vmscan-shm_locked-pages-are-non-reclaimable.patch
+vmscan-mlocked-pages-are-non-reclaimable.patch
+vmscan-downgrade-mmap-sem-while-populating-mlocked-regions.patch
+vmscan-handle-mlocked-pages-during-map-remap-unmap.patch
+vmscan-mlocked-pages-statistics.patch
+vmscan-cull-non-reclaimable-pages-in-fault-path.patch
+vmscan-noreclaim-and-mlocked-pages-vm-events.patch
+mm-only-vmscan-noreclaim-lru-scan-sysctl.patch
+vmscan-mlocked-pages-count-attempts-to-free-mlocked-page.patch
+vmscan-noreclaim-lru-and-mlocked-pages-documentation.patch

 Basically rewrite page reclaim

+reiser4-tree_lock-fixes.patch

 Repair reiser4

-put_pid-make-sure-we-dont-free-the-live-pid.patch

 Dropped.



1364 commits in 941 patch files

All patches:

ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.26-rc5/2.6.26-rc5-mm1/patch-list


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
