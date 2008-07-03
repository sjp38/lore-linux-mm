Date: Thu, 3 Jul 2008 02:02:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: 2.6.26-rc8-mm1
Message-Id: <20080703020236.adaa51fa.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.26-rc8/2.6.26-rc8-mm1/

- Seems to work on my x86 test boxes.  It does emit a
  sleeping-while-atomic warning during exit from an application which
  holds mlocks.  Known problem.

- It's dead as a doornail on the powerpc Mac g5.  I'll bisect it later.


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



Changes since 2.6-26-rc5-mm3:

 origin.patch
 linux-next.patch
 git-jg-misc.patch
 git-kbuild-next.patch
 git-bluetooth.patch
 git-pci-current.patch
 git-regulator.patch
 git-unionfs.patch
 git-logfs.patch
 git-v9fs.patch
 git-unprivileged-mounts.patch
 git-xtensa.patch

git trees

-agp-add-support-for-radeon-mobility-9000-chipset.patch
-mm-fix-incorrect-variable-type-in-do_try_to_free_pages.patch
-fat-relax-the-permission-check-of-fat_setattr.patch
-m68k-add-ext2_find_firstnext_bit-for-ext4.patch
-m68k-add-ext2_find_firstnext_bit-for-ext4-checkpatch-fixes.patch
-hgafb-resource-management-fix.patch
-cpusets-provide-another-web-page-url-in-maintainers-file.patch
-maintainers-update-pppoe-maintainer-address.patch
-proc_fsh-move-struct-mm_struct-forward-declaration.patch
-capabilities-add-back-dummy-support-for-keepcaps.patch
-cciss-add-new-hardware-support.patch
-cciss-add-new-hardware-support-fix.patch
-cciss-bump-version-to-20-to-reflect-new-hw-support.patch
-kprobes-fix-error-checking-of-batch-registration.patch
-m68knommu-init-coldfire-timer-trr-with-n-1-not-n.patch
-rtc-at32ap700x-fix-bug-in-at32_rtc_readalarm.patch
-isight_firmware-avoid-crash-on-loading-invalid-firmware.patch
-acpi-adjust-register-handling.patch
-acpi-adjust-_acpi_modulefunction_name-definitions.patch
-miscacpibacklight-compal-laptop-extras-3rd-try.patch
-acpi-change-processors-from-array-to-per_cpu-variable.patch
-proper-prototype-for-acpi_processor_tstate_has_changed.patch
-dockc-remove-trailing-printk-whitespace.patch
-acpi-use-memory_read_from_buffer.patch
-lguest-use-cpu-capability-accessors.patch
-x86-remove-unused-variable-loops-in-arch-x86-boot-a20c.patch
-x86-fix-longstanding-setupc-printk-format-warning.patch
-ac97-add-support-for-wm9711-master-left-inv-switch.patch
-agp-add-a-missing-via-agp-module-alias.patch
-intel-agp-rewrite-gtt-on-resume.patch
-arm-omap1-n770-convert-audio_pwr_sem-in-a-mutex.patch
-remove-drivers-acorn-char-defkeymap-l7200c.patch
-arm-fix-header-guards.patch
-kernel-auditc-nlh-nlmsg_type-is-gotten-more-than-once.patch
-audit-remove-useless-argument-type-in-audit_filter_user.patch
-cifs-fix-oops-on-mount-when-config_cifs_dfs_upcall-is-enabled.patch
-cm4000_cs-switch-to-unlocked_ioctl.patch
-pcmcia-add-support-the-cf-pcmcia-driver-for-blackfin-try-2.patch
-spufs-convert-nopfn-to-fault.patch
-macintosh-therm_windtunnel-semaphore-to-mutex.patch
-macintosh-media-bay-semaphore-to-mutex.patch
-arch-powerpc-platforms-pseries-eeh_driverc-fix-warning.patch
-dev_set_name-fix-missing-kernel-doc.patch
-hrtimer-remove-unused-variables-in-ktime_divns.patch
-drivers-atm-enih-remove-unused-macro-kernel_offset.patch
-bluetooth-hci_bcspc-small-cleanups-api-users.patch
-isdn-divas-fix-proc-creation.patch
-isdn-use-simple_read_from_buffer.patch
-ipg-fix-receivemode-ipg_rm_receivemulticasthash-in-ipg_nic_set_multicast_list.patch
-fec_mpc52xx-mpc52xx_messages_default-2nd-netif_msg_ifdown-=-ifup.patch
-smc911x-remove-unused-8-bit-i-o-operations.patch
-smc911x-fix-16-bit-i-o-operations.patch
-smc911x-pass-along-private-data-and-use-iomem.patch
-smc911x-introduce-platform-data-flags.patch
-smc911x-superh-architecture-support.patch
-net-sh_eth-add-support-for-renesas-superh-ethernet.patch
-macb-use-random-mac-if-stored-address-in-eeprom-is-invalid.patch
-ocfs2-use-simple_read_from_buffer.patch
-selinux-change-handling-of-invalid-classes.patch
-fakephp-construct-one-fakephp-slot-per-pci-slot.patch
-pci-introduce-pci_slot.patch
-acpi-pci-slot-detection-driver.patch
-acpi-pci-slot-detection-driver-fix.patch
-sched-sched_clock-lockdep-fix.patch
-rcu-remove-unused-field-struct-rcu_data-rcu_tasklet.patch
-uwb-fix-kconfig-causing-undefined-references.patch
-drivers-usb-host-isp1760-hcdc-procesxor-flags-have-type-unsigned-long.patch
-drivers-uwb-wlp-sysfsc-dead-code.patch
-accessrunner-avoid-unnecessary-memset.patch
-usb-host-use-get-put_unaligned_-helpers-to-fix-more-potential-unaligned-issues.patch
-usb-cp2101c-fix-sparse-signedness-mismatch-warnings.patch
-usb-speedtchc-fix-sparse-shadowed-variable-warning.patch
-usbmon-use-simple_read_from_buffer.patch
-usb-digi_accelportc-trivial-sparse-lock-annotation.patch
-vfs-path_getput-cleanups.patch
-fs-make-struct-file-arg-to-d_path-const.patch
-vfs-fix-err_ptr-abuse-in-generic_readlink.patch
-flock-remove-unused-fields-from-file_lock_operations.patch
-airo-use-simple_read_from_buffer.patch
-iwlwifi-remove-iwl4965_ht-config.patch
-maintainers-update-maintainership-of-pxa2xx-pxa3xx.patch
-#provide-rtc_cmos-platform-device-take-2.patch: david-b wibbling
-provide-rtc_cmos-platform-device-take-2.patch
-provide-rtc_cmos-platform-device-take-2-fix.patch
-rtc-make-hpet_rtc_irq-track-hpet_emulate_rtc.patch
-rtc-ramtron-fm3130-rtc-support.patch
-fat_valid_media-isnt-for-userspace.patch
-mmc-wbsd-initialize-tasklets-before-requesting-interrupt.patch
-drivers-isdn-sc-ioctlc-add-missing-kfree.patch
-intel_rng-make-device-not-found-a-warning.patch
-driver-video-cirrusfb-fix-ram-address-printk.patch
-driver-video-cirrusfb-fix-ram-address-printk-fix.patch
-driver-video-cirrusfb-fix-ram-address-printk-fix-fix.patch
-driver-char-generic_nvram-fix-banner.patch
-pagemap-pass-mm-into-pagewalkers.patch
-pagemap-fix-large-pages-in-pagemap.patch
-proc-sysvipc-shm-fix-32-bit-truncation-of-segment-sizes.patch
-console-keyboard-mapping-broken-by-04c71976.patch
-acpi-handle-invalid-acpi-slit-table.patch
-acpi-fix-drivers-acpi-gluec-build-error.patch
-bay-exit-if-notify-handler-cannot-be-installed.patch
-spi-fix-list-scan-success-verification-in-pxa-ssp-driver.patch
-audit-fix-kernel-doc-parameter-notation.patch
-ext4-fix-online-resize-bug.patch
-gigaset-fix-module-reference-counting.patch
-forcedeth-msi-interrupts.patch
-smc91x-fix-build-error-from-the-smc_get_mac_addr-api-change.patch
-pnpacpi-fix-irq-flag-decoding.patch
-pnpacpi-fix-shareable-irq-encode-decode.patch
-pnpacpi-use-_crs-irq-descriptor-length-for-_srs-v2.patch
-sched-fix-memory-leak-in-the-cpu-hotplug-handing-logic.patch
-sched-cpu-hotplug-events-must-not-destroy-scheduler-domains-created-by-the-cpusets.patch
-sched-fix-task_wakekill-vs-sigkill-race.patch
-__mutex_lock_common-use-signal_pending_state.patch
-do_generic_file_read-s-eintr-eio-if-lock_page_killable-fails.patch
-vfs-utimensat-ignore-tv_sec-if-tv_nsec-==-utime_omit-or-utime_now.patch
-vfs-utimensat-be-consistent-with-utime-for-immutable-and-append-only-files.patch
-vfs-utimensat-fix-error-checking-for-utime_nowutime_omit-case.patch
-vfs-utimensat-fix-write-access-check-for-futimens.patch
-x86-fix-lockdep-warning-during-suspend-to-ram.patch
-security-protect-legacy-apps-from-insufficient-privilege.patch
-snapshot-push-bkl-down-into-ioctl-handlers.patch
-percpu-introduce-define_per_cpu_page_aligned.patch
-remove-argument-from-open_softirq-which-is-always-null.patch
-lib-taint-kernel-in-common-report_bug-warn-path.patch
-cputopology-always-define-cpu-topology-information.patch
-cputopology-always-define-cpu-topology-information-cleanup.patch
-mfd-sm501c-if-0-unused-functions.patch
-pnp-add-detail-to-debug-resource-dump.patch
-pnp-remove-pnp_resourceindex.patch
-pnp-add-pnp_resource_type-internal-interface.patch
-pnp-add-pnp_resource_type_name-helper-function.patch
-pnp-make-pnp_portmemetc_start-et-al-work-for-invalid-resources.patch
-pnp-replace-pnp_resource_table-with-dynamically-allocated-resources.patch
-pnp-replace-pnp_resource_table-with-dynamically-allocated-resources-fix.patch
-pnp-remove-ratelimit-on-add-resource-failures.patch
-pnp-dont-sort-by-type-in-sys-resources.patch
-pnp-add-pnp_possible_config-can-a-device-could-be-configured-this-way.patch
-pnp-add-pnp_possible_config-can-a-device-could-be-configured-this-way-fix.patch
-pnp-whitespace-coding-style-fixes.patch
-pnp-define-pnp-specific-ioresource_io_-flags-alongside-irq-dma-mem.patch
-pnp-make-resource-option-structures-private-to-pnp-subsystem.patch
-pnp-introduce-pnp_irq_mask_t-typedef.patch
-pnp-increase-i-o-port-memory-option-address-sizes.patch
-pnp-improve-resource-assignment-debug.patch
-pnp-in-debug-resource-dump-make-empty-list-obvious.patch
-pnp-make-resource-assignment-functions-return-0-success-or-ebusy-failure.patch
-pnp-remove-redundant-pnp_can_configure-check.patch
-pnp-centralize-resource-option-allocations.patch
-pnpacpi-ignore-_prs-interrupt-numbers-larger-than-pnp_irq_nr.patch
-pnp-rename-pnp_register__resource-local-variables.patch
-pnp-support-optional-irq-resources.patch
-pnp-remove-extra-0x100-bit-from-option-priority.patch
-isapnp-handle-independent-options-following-dependent-ones.patch
-pnp-convert-resource-options-to-single-linked-list.patch
-pnp-convert-resource-options-to-single-linked-list-checkpatch-fixes.patch
-ext4-improve-some-code-in-rb-tree-part-of-dirc.patch
-ext4-remove-double-definitions-of-xattr-macros.patch
-ext4-error-processing-and-coding-enhancement-for-mballoc.patch
-jbd2-fix-race-between-jbd2_journal_try_to_free_buffers-and-jbd2-commit-transaction.patch
-tty-remove-unused-var-real_tty-in-n_tty_ioctl.patch
-zorro-use-memory_read_from_buffer.patch
-update-taskstats-struct-document-for-scaled-time-accounting.patch
-common-implementation-of-iterative-div-mod.patch
-add-an-inlined-version-of-iter_div_u64_rem.patch
-always_inline-timespec_add_ns.patch

 Merged into mainline or a subsystem tree.

+christoph-has-moved.patch
+mm-dirty-page-accounting-vs-vm_mixedmap.patch
+rtc_read_alarm-handles-wraparound.patch
+firmware-fix-the-request_firmware-dummy.patch
+serial-fix-serial_match_port-for-dynamic-major-tty-device-numbers.patch
+get_user_pages-fix-possible-page-leak-on-oom.patch
+rtc-x1205-fix-alarm-set.patch
+rtc-x1205-fix-alarm-set-fix.patch
+rtc-fix-cmos-time-error-after-writing-proc-acpi-alarm.patch
+pci-vt3336-cant-do-msi-either.patch
+miguel-ojeda-has-moved.patch
+ext3-add-missing-unlock-to-error-path-in-ext3_quota_write.patch
+ext4-add-missing-unlock-to-an-error-path-in-ext4_quota_write.patch
+reiserfs-add-missing-unlock-to-an-error-path-in-reiserfs_quota_write.patch
+ecryptfs-remove-unnecessary-mux-from-ecryptfs_init_ecryptfs_miscdev.patch
+lib-taint-kernel-in-common-report_bug-warn-path.patch
+spi-spi_mpc83xx-clockrate-fixes.patch
+gpio-pca953x-i2c-handles-max7310-too.patch
+fsl_diu_fb-fix-build-with-config_pm=y-plus-fix-some-warnings.patch
+update-taskstats-struct-document-for-scaled-time-accounting.patch
+cciss-fix-regression-that-no-device-nodes-are-created-if-no-logical-drives-are-configured.patch
+delay-accounting-maintainer-update.patch
+doc-kernel-parameterstxt-fix-stale-references.patch
+hdaps-add-support-for-various-newer-lenovo-thinkpads.patch
+mn10300-export-certain-arch-symbols-required-to-build-allmodconfig.patch
+mn10300-provide-__ucmpdi2-for-mn10300.patch
+introduce-rculisth.patch
+man-pages-is-supported.patch
+update-ntfs-help-text.patch
+update-ntfs-help-text-fix.patch
+add-kernel-doc-for-simple_read_from_buffer-and-memory_read_from_buffer.patch
+sisusbvga-fix-oops-on-disconnect.patch
+w100fb-do-not-depend-on-sharpsl.patch
+w100fb-add-80-mhz-modeline.patch
+mfd-maintainer.patch
+cgroups-document-the-effect-of-attaching-pid-0-to-a-cgroup.patch
+cgroups-document-the-effect-of-attaching-pid-0-to-a-cgroup-fix.patch
+spi-fix-the-read-path-in-spidev.patch
+spi-fix-the-read-path-in-spidev-cleanup.patch
+doc-doc-maintainers.patch
+drm-i915-only-use-tiled-blits-on-965.patch
+security-filesystem-capabilities-fix-fragile-setuid-fixup-code.patch
+security-filesystem-capabilities-fix-fragile-setuid-fixup-code-checkpatch-fixes.patch
+security-filesystem-capabilities-fix-cap_setpcap-handling.patch
+security-filesystem-capabilities-fix-cap_setpcap-handling-fix.patch
+alpha-linux-kernel-fails-with-inconsistent-kallsyms-data.patch
+cpusets-document-proc-status-cpus-and-mems-allowed-lists.patch
+maintainers-update-the-email-address-of-andreas-dilger.patch
+cciss-read-config-to-obtain-max-outstanding-commands-per-controller.patch
+olpc-sdhci-add-quirk-for-the-marvell-cafes-vdd-powerup-issue.patch
+olpc-sdhci-add-quirk-for-the-marvell-cafes-interrupt-timeout.patch
+net-ipv4-tcpc-needs-linux-scatterlisth.patch
+doc-document-the-relax_domain_level-kernel-boot-argument.patch
+doc-document-the-relax_domain_level-kernel-boot-argument-fix.patch
+doc-document-the-relax_domain_level-kernel-boot-argument-correct-default.patch

 2.6.26 queue

+repeatable-slab-corruption-with-ltp-msgctl08.patch

 debug patch

+revert-introduce-rculisth.patch

 Make linux-next apply

-linux-next-git-rejects.patch

 Unneeded

+s390-build-fixes.patch
+linux-next-fixups.patch

 linux-next repairs

-fix-x86_64-splat.patch
-kvm-unbork.patch

 Unneeded

 kvm-is-busted-on-ia64.patch

Maybe it got unborked, dunno.

+acpi-add-the-abity-to-reset-the-system-using-reset_reg-in-fadt-table.patch
+acpi-utmisc-use-warn_on-instead-of-warn_on_slowpath.patch

 ACPI things

+x86-pci-use-dev_printk-when-possible.patch
+arch-x86-kernel-smpbootc-fix-warning.patch
+arch-x86-mm-pgtable_32c-remove-unused-variable-fixmaps.patch
+arch-x86-mm-init_64c-early_memtest-fix-types.patch

 x86 things

+sysfs-rulestxt-reword-api-stability-statement.patch

 sysfs doc fix

+drivers-media-video-videobuf-dma-sgc-avoid-clearing-memory-twice.patch
+drivers-media-video-cx18-cx18-av-firmwarec-fix-warning.patch
+drivers-media-video-uvc-uvc_v4l2c-suppress-uninitialized-var-warning.patch

 DVB fixes

+migrate_timers-add-comment-use-spinlock_irq.patch
+tick-schedc-suppress-needless-timer-reprogramming.patch
+tick-schedc-suppress-needless-timer-reprogramming-checkpatch-fixes.patch

 time-management things

+drivers-input-tablet-gtcoc-eliminate-early-return.patch

 input cleanup

+leds-make-sure-led-trigger-is-valid-before-calling-trigger-activate.patch

 leds fix

+cdrom-dont-check-cdc_play_audio-in-cdrom_count_tracks.patch

 cdrom fix

+m32r-remove-the-unused-nohighmem-option.patch

 m32r cleanup

+au1xmmc-remove-custom-carddetect-poll-implementation.patch

 mmc cleanup

+atmel_nand-speedup-via-readwritesbw.patch
+atmel_nand-work-around-at32ap7000-ecc-errata.patch
+mtd-atmel_nand-can-be-modular.patch
+mtd-handle-pci_name-being-const.patch

 mtd things

+random32-seeding-improvement.patch
+random32-seeding-improvement-v2.patch

 Improve lib/random32.c

+acpi-compal-laptop-use-rfkill-switch-subsystem.patch

 More acpi - depends on git-net-next.

+bluetooth-hci_bcsp-fix-bitrev-kconfig.patch

 bluetooth fix

+pm-remove-references-to-struct-pm_dev-from-irda-headers.patch

 IRDA cleanup

+8390-split-8390-support-into-a-pausing-and-a-non-pausing-driver-core-fix-fix.patch
+e100-fix-printk-format-warning.patch
+e1000-make-ioport-free.patch
+3c59x-handle-pci_name-being-const.patch

 netdev things

+pci-handle-pci_name-being-const.patch

 pci fixlet

+rcu-classic-update-qlen-when-cpu-offline.patch

 rcu fix

+aic7xxx-introduce-dont_generate_debug_code-keyword-in-aicasm-parser.patch
+aic7xxx-update-reg-files.patch
+aic7xxx-update-reg-files-update.patch
+aic7xxx-update-_shipped-files.patch
+scsi-make-struct-scsi_hosttarget_type-static.patch
+lkdtm-fix-for-config_scsi=n.patch

 scsi things

+git-block-fix-drivers-block-pktcdvdc.patch
+drivers-block-pktcdvdc-avoid-useless-memset.patch
+ramfs-enable-splice-write.patch
+block-request_module-use-format-string.patch

 block things

+unionfs-fix-memory-leak.patch
+fsstack-fsstack_copy_inode_size-locking.patch

 fixes for git-unionfs

+drivers-usb-class-cdc-acmc-use-correct-type-for-cpu-flags.patch
+drivers-usb-class-cdc-acmc-fix-build-with-config_pm=n.patch
+drivers-usb-class-cdc-wdmc-fix-build-with-config_pm=n.patch

 USB fixes

+drivers-net-wireless-b43legacy-dmac-remove-the-switch-in-b43legacy_dma_init.patch

 wireless workaround for old gcc silliness

+splice-fix-generic_file_splice_read-race-with-page-invalidation.patch
+wan-add-missing-skb-dev-assignment-in-frame-relay-rx-code.patch
+forcedeth-fix-lockdep-warning-on-ethtool-s.patch
+usb-fix-possible-memory-leak-in-pxa27x_udc.patch
+x86-fix-intel-mac-booting-with-efi.patch

 Things which we might want in 2.6.26

+ide-cd-use-the-new-object_is_in_stack-helper.patch
+block-blk-mapc-use-the-new-object_is_on_stack-helper.patch

 cleanups

+mm-remove-nopfn-fix.patch

 Fix mm-remove-nopfn.patch

+hugetlb-modular-state-for-hugetlb-page-size-cleanup.patch

 Fix hugetlb-modular-state-for-hugetlb-page-size.patch

+hugetlb-new-sysfs-interface-fix-2.patch

 Fix hugetlb-new-sysfs-interface.patch

+hugetlb-reservations-move-region-tracking-earlier.patch
+hugetlb-reservations-fix-hugetlb-map_private-reservations-across-vma-splits-v2.patch
+hugetlb-reservations-fix-hugetlb-map_private-reservations-across-vma-splits-v2-fix.patch
+hugetlb-fix-race-when-reading-proc-meminfo.patch

 hugetlb work

+linux-next-revert-bootmem-add-return-value-to-reserve_bootmem_node.patch
+revert-linux-next-revert-bootmem-add-return-value-to-reserve_bootmem_node.patch
+revert-revert-linux-next-revert-bootmem-add-return-value-to-reserve_bootmem_node.patch
+revert-revert-revert-linux-next-revert-bootmem-add-return-value-to-reserve_bootmem_node.patch

 More mm work

+bootmem-clean-up-alloc_bootmem_core-fix-new-alloc_bootmem_core.patch

 Fix bootmem-clean-up-alloc_bootmem_core.patch

+revert-revert-revert-revert-linux-next-revert-bootmem-add-return-value-to-reserve_bootmem_node.patch

 argh

+mm-add-alloc_pages_exact-and-free_pages_exact.patch
+mm-page_allocc-cleanups.patch
+mm-make-register_page_bootmem_info_section-static.patch
+page_align-correctly-handle-64-bit-values-on-32-bit-architectures.patch
+page_align-correctly-handle-64-bit-values-on-32-bit-architectures-fix.patch
+page_align-correctly-handle-64-bit-values-on-32-bit-architectures-v850-fix.patch
+page_align-correctly-handle-64-bit-values-on-32-bit-architectures-x86_64-fix.patch
+page_align-correctly-handle-64-bit-values-on-32-bit-architectures-powerpc-fix.patch
+page_align-correctly-handle-64-bit-values-on-32-bit-architectures-arm-fix.patch
+page_align-correctly-handle-64-bit-values-on-32-bit-architectures-mips-fix.patch
+page_align-correctly-handle-64-bit-values-on-32-bit-architectures-dvb.patch
+page_align-correctly-handle-64-bit-values-on-32-bit-architectures-mtd-fix.patch
+page_align-correctly-handle-64-bit-values-on-32-bit-architectures-powerpc-fixes.patch
+mm-remove-initialization-of-static-per-cpu-variables.patch
+memory-hotplugallocate-usemap-on-the-section-with-pgdat-take-4.patch
+memory-hotplug-small-fixes-to-bootmem-freeing-for-memory-hotremove.patch
+memory-hotplug-dont-calculate-vm_total_pages-twice-when-rebuilding-zonelists-in-online_pages.patch
+memory-hotplug-add-sysfs-removable-attribute-for-hotplug-memory-remove.patch
+mmu-notifiers-add-list_del_init_rcu.patch
+mmu-notifiers-add-mm_take_all_locks-operation.patch
+mmu-notifiers-add-mm_take_all_locks-operation-checkpatch-fixes.patch
+mmu-notifier-core.patch
+mmu-notifier-core-checkpatch-fixes.patch
+mmu-notifier-core-fix.patch
+mmu-notifier-core-fix-2.patch

 MM updates

+security-protect-legacy-applications-from-executing-with-insufficient-privilege-checkpatch-fixes.patch

 Fix security-protect-legacy-apps-from-insufficient-privilege-cleanup.patch

+security-protect-legacy-applications-from-executing-with-insufficient-privilege.patch
+security-filesystem-capabilities-refactor-kernel-code.patch
+security-filesystem-capabilities-no-longer-experimental.patch
+security-remove-unused-forwards.patch

 Security things

+alpha-remove-the-unused-alpha_core_agp-option.patch

 alpha cleanup

+pm-boot-time-suspend-selftest-vs-linux-next.patch

 Fix pm-boot-time-suspend-selftest.patch

+pm-remove-definition-of-struct-pm_dev.patch
+pm-remove-remaining-obsolete-definitions-from-pmh.patch
+pm-remove-obsolete-piece-of-pm-documentation-rev-2.patch
+pm-drop-unnecessary-includes-from-pmh.patch

 power management work

+mn10300-move-sg_dma_addresslen-to-asm-scatterlisth.patch

 mn10300 cleanup

+hppfs-remove-hppfs_permission.patch

 UML cleanup

-proper-spawn_ksoftirqd-prototype.patch

 Dropped

+include-linux-kernelh-userspace-header-cleanup.patch
+seq_file-fix-bug-when-seq_read-reads-nothing.patch
+seq_file-fix-bug-when-seq_read-reads-nothing-fix.patch
+pdflush-use-time_after-instead-of-open-coding-it.patch
+fifo-pipe-reuse-xxx_fifo_fops-for-xxx_pipe_fops.patch
+exec-remove-some-includes.patch
+exec-remove-some-includes-fix.patch
+inflate-refactor-inflate-malloc-code.patch
+inflate-refactor-inflate-malloc-code-checkpatch-fixes.patch
+drivers-power-fix-platform-driver-hotplug-coldplug.patch
+mfd-fix-platform-driver-hotplug-coldplug.patch
+parport-fix-platform-driver-hotplug-coldplug.patch
+dma-fix-platform-driver-hotplug-coldplug.patch

 Misc

+checkpatch-version-020.patch
+checkpatch-return-is-not-a-function-parentheses-for-casts-are-ok-too.patch
+checkpatch-types-some-types-may-also-be-identifiers.patch
+checkpatch-add-a-checkpatch-warning-for-new-uses-of-__initcall.patch
+checkpatch-possible-types-__asm__-is-never-a-type.patch
+checkpatch-comment-detection-ignore-macro-continuation-when-detecting-associated-comments.patch
+checkpatch-types-unary-goto-introduces-unary-context.patch
+checkpatch-macros-fix-statement-counting-block-end-detection.patch
+checkpatch-trailing-statement-indent-fix-end-of-statement-location.patch
+checkpatch-allow-printk-strings-to-exceed-80-characters-to-maintain-their-searchability.patch
+checkpatch-switch-report-trailing-statements-on-case-and-default.patch
+checkpatch-check-spacing-for-square-brackets.patch
+checkpatch-toughen-trailing-if-statement-checks-and-extend-them-to-while-and-for.patch
+checkpatch-condition-loop-indent-checks.patch
+checkpatch-usb_free_urb-can-take-null.patch
+checkpatch-correct-spelling-in-kfree-checks.patch
+checkpatch-allow-for-type-modifiers-on-multiple-declarations.patch
+checkpatch-improve-type-matcher-debug.patch
+checkpatch-possible-modifiers-are-not-being-correctly-matched.patch
+checkpatch-macro-complexity-checks-are-meaningless-in-linker-scripts.patch
+checkpatch-handle-return-types-of-pointers-to-functions.patch
+checkpatch-possible-types-known-modifiers-cannot-be-types.patch
+checkpatch-possible-modifiers-handle-multiple-modifiers-and-trailing.patch
+checkpatch-add-checks-for-question-mark-and-colon-spacing.patch
+checkpatch-variants-move-the-main-unary-binary-operators-to-use-variants.patch
+checkpatch-complex-macros-need-to-ignore-comments.patch
+checkpatch-types-cannot-start-mid-word-for-pointer-tests.patch
+checkpatch-version-021.patch

 checkpatch updates

-rename-warn-to-warning-to-clear-the-namespace-fix.patch

 Folded into rename-warn-to-warning-to-clear-the-namespace.patch

+kallsyms-unify-32-and-64-bit-code.patch

 kallsyms cleanup

+vfs-fix-coding-style-in-dcachec.patch
+vfs-add-cond_resched_lock-while-scanning-dentry-lru-lists.patch

 VFS stuff

+serial-z85c30-avoid-a-hang-at-console-switch-over.patch
+serial-dz11-avoid-a-hang-at-console-switch-over.patch
+cpm1-dont-send-break-on-tx_stop-dont-interrupt-rx-tx-when-adjusting-termios-parameters.patch
+istallion-remove-unused-variable.patch
+stallion-removed-unused-variable.patch

 Serial driver updates

-oprofile-multiplexing.patch
-oprofile-multiplexing-checkpatch-fixes.patch

 Dropped - still being discussed

+spi-au1550_spi-proper-platform-device.patch
+spi-au1550_spi-improve-pio-transfer-mode.patch
+spi-au1550_spi-improve-pio-transfer-mode-checkpatch-fixes.patch

 SPI updates

+asic3-gpiolib-support-mfd-asic3-should-depend-on-gpiolib.patch

 Fix asic3-gpiolib-support.patch

+asic3-new-gpio-configuration-code-fix-asic3-config-array-initialisation.patch

 Fix asic3-new-gpio-configuration-code.patch

+mfd-move-asic3-probe-functions-into-__init-section.patch
+mfd-fix-a-bug-in-the-asic3-irq-demux-code.patch
+sm501-add-power-control-callback.patch
+sm501-add-gpiolib-support.patch
+sm501-gpio-dynamic-registration-for-pci-devices.patch
+sm501-gpio-i2c-support.patch
+sm501-fixes-for-akpms-comments-on-gpiolib-addition.patch
+mfd-sm501-build-fixes-when-config_mfd_sm501_gpio-unset.patch
+mfd-sm501-fix-gpio-number-calculation-for-upper-bank.patch

 MFD updates

+ecryptfs-discard-ecryptfsd-registration-messages-in-miscdev.patch
+ecryptfs-propagate-key-errors-up-at-mount-time.patch
+ecryptfs-string-copy-cleanup.patch

 ecryptfs updates

+autofs4-dont-make-expiring-dentry-negative.patch
+autofs4-dont-make-expiring-dentry-negative-fix.patch
+autofs4-revert-redo-lookup-in-ttfd.patch
+autofs4-use-look-aside-list-for-lookups.patch
+autofs4-use-look-aside-list-for-lookups-autofs4-fix-symlink-name-allocation.patch
+autofs4-dont-release-directory-mutex-if-called-in-oz_mode.patch
+autofs4-use-lookup-intent-flags-to-trigger-mounts.patch
+autofs4-use-struct-qstr-in-waitqc.patch
+autofs4-fix-waitq-locking.patch
+autofs4-fix-pending-mount-race.patch
+autofs4-fix-pending-mount-race-fix.patch
+autofs4-check-kernel-communication-pipe-is-valid-for-write.patch
+autofs4-fix-waitq-memory-leak.patch
+autofs4-detect-invalid-direct-mount-requests.patch

 autofs updates

+rtc-remove-bkl-for-ioctl.patch
+rtc-add-support-for-st-m41t94-spi-rtc.patch
+rtc-ds1305-ds1306-driver.patch
+rtc-ds1305-ds1306-driver-fix.patch
+rtc-bcd-codeshrink.patch
+rtc-rtc-omap-footprint-shrinkage.patch

 RTC updates

+gpio-gpio-driver-for-max7301-spi-gpio-expander-check-spi_setup-return-code-cleanup.patch
+gpio-sysfs-interface-updated.patch
+gpio-sysfs-interface-updated-update.patch
+gpio-mcp23s08-handles-multiple-chips-per-chipselect.patch
+gpio-add-bt8xxgpio-driver.patch
+gpio-add-bt8xxgpio-driver-checkpatch-fixes.patch
+gpio-add-bt8xxgpio-driver-checkpatch-fixes-fix.patch
+gpio-add-bt8xxgpio-driver-checkpatch-fixes-cleanup.patch

 GPIO updates

+sm501-add-inversion-controls-for-vbiasen-and-fpen.patch
+sm501-restructure-init-to-allow-only-1-fb-on-an-sm501.patch
+sm501-fixup-allocation-code-to-be-64bit-resource-compliant.patch
+fb-add-support-for-the-ili9320-video-display-controller.patch
+fb-add-support-for-the-ili9320-video-display-controller-fix.patch
+lcd-add-lcd_device-to-check_fb-entry-in-lcd_ops.patch
+lcd-add-platform_lcd-driver.patch
+lcd-add-platform_lcd-driver-fix.patch
+fsl-diu-fb-update-freescale-diu-driver-to-use-page_alloc_exact.patch
+fsl-diu-fb-update-freescale-diu-driver-to-use-page_alloc_exact-fix.patch
+fbdev-add-new-cobalt-lcd-framebuffer-driver.patch
+fbdev-add-new-cobalt-lcd-framebuffer-driver-fix.patch
+fbdev-add-new-cobalt-lcd-platform-device-register.patch
+lxfb-drop-dead-declarations-from-header.patch
+drivers-video-amifbc-cleanups.patch
+neofb-simplify-clock-calculation.patch
+neofb-drop-redundant-code.patch

 fbdev updates

+pnp-have-quirk_system_pci_resources-include-io-resources.patch

 pnp update

-not-for-merging-pnp-changes-suspend-oops.patch

 I think this ended up getting merged.

+ext3-handle-corrupted-orphan-list-at-mount.patch
+ext3-handle-corrupted-orphan-list-at-mount-cleanup.patch
+ext3-handle-corrupted-orphan-list-at-mount-fix.patch
+ext3-handle-corrupted-orphan-list-at-mount-cleanup-fix.patch
+ext3-dont-read-inode-block-if-the-buffer-has-a-write-error.patch
+ext3-handle-deleting-corrupted-indirect-blocks.patch
+ext3-handle-deleting-corrupted-indirect-blocks-fix.patch
+jbd-unexport-journal_update_superblock.patch
+jbd-positively-dispose-the-unmapped-data-buffers-in-journal_commit_transaction.patch
+ext3-kill-2-useless-magic-numbers.patch
+jbd-dont-abort-if-flushing-file-data-failed.patch
+jbd-dont-abort-if-flushing-file-data-failed-fix.patch
+ext3-validate-directory-entry-data-before-use-v5.patch

 ext3 updates

+coda-remove-coda_fs_old_api.patch

 CODAFS cleanup

+fat-fix-parse_options.patch
+fat-fix-vfat_ioctl_readdir_xxx-and-cleanup-for-userland.patch
+fat-dirc-switch-to-struct-__fat_dirent.patch
+fat-cleanup-fs-fat-dirc.patch
+fat-use-same-logic-in-fat_search_long-and-__fat_readdir.patch
+fat-small-optimization-to-__fat_readdir.patch

 fatfs updates

+remove-the-in-kernel-struct-dirent64.patch
+remove-unused-include-linux-direnths.patch
+fatfs-add-utc-timestamp-option.patch
+utc-timestamp-option-for-fat-filesystems-fix.patch

 VFS cleanups

+procfs-guide-drop-pointless-nbsp-entities.patch

 procfs documentation fixup

+cgroup-files-clean-up-whitespace-in-struct-cftype.patch
+cgroup-files-add-write_string-cgroup-control-file-method.patch
+cgroup-files-move-the-release_agent-file-to-use-typed-handlers.patch
+cgroups-misc-cleanups-to-write_string-patchset.patch
+cgroup-files-move-notify_on_release-file-to-separate-write-handler.patch
+cgroup-files-turn-attach_task_by_pid-directly-into-a-cgroup-write-handler.patch
+cgroup-files-remove-cpuset_common_file_write.patch
+cgroup-files-convert-devcgroup_access_write-into-a-cgroup-write_string-handler.patch
+cgroup-files-convert-res_counter_write-to-be-a-cgroups-write_string-handler.patch
+cgroup-files-convert-res_counter_write-to-be-a-cgroups-write_string-handler-fix.patch
+cgroup_clone-use-pid-of-newly-created-task-for-new-cgroup.patch
+cgroup_clone-use-pid-of-newly-created-task-for-new-cgroup-fix.patch
+cgroup_clone-use-pid-of-newly-created-task-for-new-cgroup-checkpatch-fixes.patch

 cgroups work

+memcg-remove-refcnt-from-page_cgroup-fix-memcg-fix-mem_cgroup_end_migration-race.patch
+memcg-remove-refcnt-from-page_cgroup-memcg-fix-shmem_unuse_inode-charging.patch

 Fix memcg-remove-refcnt-from-page_cgroup.patch som emore

+memcg-handle-swap-cache-fix-shmem-page-migration-incorrectness-on-memcgroup.patch

 Fix memcg-handle-swap-cache.patch some more

+memcg-helper-function-for-relcaim-from-shmem-memcg-shmem_getpage-release-page-sooner.patch
+memcg-helper-function-for-relcaim-from-shmem-memcg-mem_cgroup_shrink_usage-css_put.patch

 Fix memcg-helper-function-for-relcaim-from-shmem.patch some more

+memcg-clean-up-checking-of-the-disabled-flag-memcg-further-checking-of-disabled-flag.patch

 Fix memcg-clean-up-checking-of-the-disabled-flag.patch

+memrlimit-setup-the-memrlimit-controller-cgroup-files-convert-res_counter_write-to-be-a-cgroups-write_string-handler-memrlimitcgroup.patch
+memrlimit-setup-the-memrlimit-controller-memrlimit-correct-mremap-and-move_vma-accounting.patch

 Fix memrlimit-setup-the-memrlimit-controller.patch

+memrlimit-cgroup-mm-owner-callback-changes-to-add-task-info-memrlimit-fix-sleep-inside-sleeplock-in-mm_update_next_owner.patch

 Fix memrlimit-cgroup-mm-owner-callback-changes-to-add-task-info.patch

+memrlimit-add-memrlimit-controller-accounting-and-control-memrlimit-improve-fork-and-error-handling.patch

 Fix memrlimit-add-memrlimit-controller-accounting-and-control.patch som emore

+memrlimit-improve-error-handling.patch
+memrlimit-improve-error-handling-update.patch
+memrlimit-handle-attach_task-failure-add-can_attach-callback.patch
+memrlimit-handle-attach_task-failure-add-can_attach-callback-update.patch

 More memrlimit work.  Hugh hated it, and that's a problem.

+cpusets-restructure-the-function-update_cpumask-and-update_nodemask-fix.patch

 Fix cpusets-restructure-the-function-update_cpumask-and-update_nodemask.patch

+signals-make-siginfo_t-si_utime-si_sstime-report-times-in-user_hz-not-hz.patch
+kernel-signalc-change-vars-pid-and-tgid-types-to-pid_t.patch

 Signal management work.

+include-asm-ptraceh-userspace-headers-cleanup.patch
+ptrace-give-more-respect-to-sigkill.patch
+ptrace-never-sleep-in-task_traced-if-sigkilled.patch
+ptrace-kill-may_ptrace_stop.patch

 ptrace updates

+coredump-elf_core_dump-skip-kernel-threads.patch

 Core dumping update

+workqueues-insert_work-use-list_head-instead-of-int-tail.patch
+workqueues-implement-flush_work.patch
+workqueues-schedule_on_each_cpu-use-flush_work.patch
+workqueues-make-get_online_cpus-useable-for-work-func.patch
+workqueues-make-get_online_cpus-useable-for-work-func-fix.patch
+s390-topology-dont-use-kthread-for-arch_reinit_sched_domains.patch

 workqueue updates

+pty-remove-unused-unix98_pty_count-options.patch

 pty cleanup

+char-mxser-ioctl-cleanup.patch
+char-mxser-globals-cleanup.patch
+char-mxser-add-cp-102uf-support.patch
+char-mxser-update-documentation.patch
+char-mxser-prints-cleanup.patch
+char-mxser-remove-predefined-isa-support.patch
+char-mxser-various-cleanups.patch

 char driver updates

+proc-always-do-release.patch
+proc-always-do-release-fix.patch
+proc-remove-pathetic-remount-code.patch
+proc-move-kconfig-to-fs-proc-kconfig.patch
+proc-misplaced-export-of-find_get_pid.patch

 procfs updates

+pidns-remove-now-unused-kill_proc-function.patch
+pidns-remove-now-unused-find_pid-function.patch
+pidns-remove-find_task_by_pid-unused-for-a-long-time.patch

 pid namespace updates

+taskstats-remove-initialization-of-static-per-cpu-variable.patch

 taskstats cleanup

+edac-i5100-new-intel-chipset-driver.patch
+edac-i5100-fix-missing-bits.patch
+edac-i5100-fix-enable-ecc-hardware.patch
+edac-i5100-fix-unmask-ecc-bits.patch
+edac-i5100-cleanup.patch
+edac-i5100-cleanup-fix.patch
+edac-core-fix-to-use-dynamic-kobject.patch
+edac-core-fix-workq-timer.patch
+edac-core-fix-redundant-sysfs-controls-to-parameters.patch
+edac-core-fix-static-to-dynamic-kset.patch
+edac-core-fix-added-newline-to-sysfs-dimm-labels.patch
+edac-e752x-fix-too-loud-on-nonmemory-errors.patch
+edac-mv64x60-fix-get_property.patch
+edac-mv64x60-add-pci-fixup.patch
+edac-mpc85xx-fix-pci-ofdev-2nd-pass.patch
+edac-mpc85xx-fix-pci-ofdev-2nd-pass-checkpatch-fixes.patch

 EDAC updates

-dma-mapping-add-the-device-argument-to-dma_mapping_error-b34-fix.patch
+dma-mapping-add-the-device-argument-to-dma_mapping_error-s2io.patch
+dma-mapping-add-the-device-argument-to-dma_mapping_error-pasemi_mac.patch
+dma-mapping-x86-per-device-dma_mapping_ops-support-fix-2.patch
+x86-calgary-fix-handling-of-devices-that-arent-behind-the-calgary.patch
+x86-calgary-fix-handling-of-devices-that-arent-behind-the-calgary-checkpatch-fixes.patch

 Keep hacking away at the DMA mapping API

+parport-remove-superfluous-local-variable.patch
+parport_pc-add-base_hi-bar-for-oxsemi_840.patch

 parport updates

+tpm-use-correct-data-types-for-sizes-in-tpm_write-and-tpm_read.patch

 TPM fix

-revert-linux-next-changes-to-make-memstick-use-fully-asynchronous-request-processing-apply.patch
-revert-revert-linux-next-changes-to-make-memstick-use-fully-asynchronous-request-processing-apply.patch

 Unneeded

+kernel-kexecc-make-kimage_terminate-void.patch

 kexec cleanup

+better-interface-for-hooking-early-initcalls.patch
+full-conversion-to-early_initcall-interface-remove-old-interface.patch
+relay-add-buffer-only-channels-useful-for-early-logging.patch

 Something to do with relayfs

+gcov-add-gcov-profiling-infrastructure-revert-link-changes.patch
+gcov-architecture-specific-compile-flag-adjustments-powerpc-moved-stuff.patch
+gcov-architecture-specific-compile-flag-adjustments-powerpc-fix.patch
+gcov-architecture-specific-compile-flag-adjustments-x86_64-fix.patch

 gcov updates

+mm-speculative-page-references-fix-migration_entry_wait-for-speculative-page-cache.patch

 Fix mm-speculative-page-references-fix.patch some more

+define-page_file_cache-function-fix.patch
+define-page_file_cache-function-fix-splitlru-shmem_getpage-setpageswapbacked-sooner.patch
+vmscan-split-lru-lists-into-anon-file-sets-collect-lru-meminfo-statistics-from-correct-offset.patch
+vmscan-split-lru-lists-into-anon-file-sets-prevent-incorrect-oom-under-split_lru.patch
+vmscan-split-lru-lists-into-anon-file-sets-split_lru-fix-pagevec_move_tail-doesnt-treat-unevictable-page.patch
+vmscan-split-lru-lists-into-anon-file-sets-splitlru-memcg-swapbacked-pages-active.patch
+vmscan-split-lru-lists-into-anon-file-sets-splitlru-bdi_cap_swap_backed.patch
+unevictable-lru-infrastructure-fix.patch
+unevictable-lru-infrastructure-kconfig-fix.patch
+unevictable-lru-infrastructure-remove-redundant-page-mapping-check.patch
+unevictable-lru-page-statistics-fix-printk-in-show_free_areas.patch
+ramfs-and-ram-disk-pages-are-unevictable-undo-the-brdc-part.patch
-mlock-mlocked-pages-are-unevictable-fix-2.patch
+mlock-mlocked-pages-are-unevictable-fix-3.patch
+mlock-mlocked-pages-are-unevictable-fix-4.patch
+mlock-mlocked-pages-are-unevictable-fix-fix-munlock-page-table-walk-now-requires-mm.patch
+fix-double-unlock_page-in-2626-rc5-mm3-kernel-bug-at-mm-filemapc-575.patch
+vmstat-mlocked-pages-statistics-fix-incorrect-mlocked-field-of-proc-meminfo.patch
+swap-cull-unevictable-pages-in-fault-path-fix.patch
+vmscam-kill-unused-lru-functions.patch

 Fix the page scanner updates in -mm a bit.

+documentation-cleanup-trivial-misspelling-punctuation-and-grammar-corrections.patch

 Lots of small fixes to Documentation/*

+make-macfb_setup-static.patch
+video-console-sticonrec-make-code-static.patch
+video-console-sticonrec-make-code-static-checkpatch-fixes.patch
+video-stifbc-make-2-functions-static.patch

 Make more things static

+likely-profiling-disable-ftrace.patch

 Make likely-profiling work better with ftrace



1569 commits in 1181 patch files

(err, that's wrong, and it's Sam's fault)

All patches: ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.26-rc8/2.6.26-rc8-mm1/patch-list


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
