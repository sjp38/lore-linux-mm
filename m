Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7CEA96B0169
	for <linux-mm@kvack.org>; Wed, 24 Aug 2011 17:48:26 -0400 (EDT)
Message-Id: <201108242148.p7OLm1lt009191@imap1.linux-foundation.org>
Subject: mmotm 2011-08-24-14-08 uploaded
From: akpm@linux-foundation.org
Date: Wed, 24 Aug 2011 14:09:05 -0700
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

The mm-of-the-moment snapshot 2011-08-24-14-08 has been uploaded to

   http://userweb.kernel.org/~akpm/mmotm/

It contains the following patches against 3.1-rc3:
(patches marked "*" will be included in linux-next)

  origin.patch
  headers_check-is-broken.patch
  samples-hidraw-is-busted.patch
* drivers-misc-ptic-add-missing-includes.patch
* alpha-unbreak-osf_setsysinfossi_nvpairs.patch
* alpha-unbreak-osf_setsysinfossi_nvpairs-checkpatch-fixes.patch
* w1-fix-for-loop-in-w1_f29_remove_slave.patch
* maintainers-evgeniy-has-moved.patch
* memcg-pin-execution-to-current-cpu-while-draining-stock.patch
* scripts-get_maintainerpl-update-linuss-git-repository.patch
* checkpatch-add-missing-warn-argument-for-min_t-and-max_t-tests.patch
* drivers-char-msm_smd_pktc-dont-use-is_err.patch
* mm-fix-a-vmscan-warning.patch
* maintainers-paul-menage-has-moved.patch
* kernel-printk-do-not-turn-off-bootconsole-in-printk_late_init-if-keep_bootcon.patch
* vmscan-clear-zone_congested-for-zone-with-good-watermark-resend.patch
* rapidio-fix-use-of-non-compatible-registers.patch
* drivers-video-backlight-ep93xx_blc-add-missing-include-of-linux-moduleh.patch
* leds-add-missing-include-of-linux-moduleh.patch
* memcg-make-oom_lock-0-and-1-based-rather-than-coutner.patch
* backlight-add-a-callback-notify_after-for-backlight-control.patch
* backlight-fix-module-alias-prefix-for-adp8870_bl.patch
* drivers-misc-fsa9480-fix-a-leak-of-the-irq-during-init-failure.patch
* drivers-misc-ab8500-pwmc-fix-modalias.patch
* cris-add-arch-cris-include-asm-serialh.patch
* drivers-leds-leds-bd2802c-bd2802_unregister_led_classdev-should-unregister-all-registered-leds.patch
  linux-next.patch
  i-need-old-gcc.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
* mm-mempolicyc-make-copy_from_user-provably-correct.patch
* floppy-use-del_timer_sync-in-init-cleanup.patch
* drm-fix-kconfig-unmet-dependency-warning.patch
* sched-fix-a-memory-leak-in-__sdt_free.patch
* kernel-timec-change-jiffies_to_clock_t-input-parameters-type-to-unsigned-long.patch
* readlinkat-ensure-we-return-enoent-for-the-empty-pathname-for-normal-lookups.patch
* acerhdf-add-support-for-aspire-1410-bios-v13314.patch
* arch-x86-platform-iris-irisc-register-a-platform-device-and-a-platform-driver.patch
* x86-fix-mmap-random-address-range.patch
* leds-new-pcengines-alix-system-driver-enables-leds-via-gpio-interface.patch
* leds-new-pcengines-alix-system-driver-enables-leds-via-gpio-interface-fix.patch
* arch-x86-kernel-e820c-eliminate-bubble-sort-from-sanitize_e820_map.patch
* tracex86-add-tracepoint-to-x86-timer-interrupt-handler.patch
* tracex86-add-x86-irq-vector-entry-exit-tracepoints.patch
* arch-arm-mach-ux500-mbox-db5500c-world-writable-sysfs-fifo-file.patch
* arm-exec-remove-redundant-set_fsuser_ds.patch
* audit-always-follow-va_copy-with-va_end.patch
* btrfs-dont-dereference-extent_mapping-if-null.patch
* fsl-rio-correct-iecsr-register-clear-value.patch
* drm-vmwgfx-use-ida_simple_get-for-id-allocation.patch
* drivers-gpu-vga-vgaarbc-add-missing-kfree.patch
* fb-fix-potential-deadlock-between-lock_fb_info-and-console_lock.patch
  cyber2000fb-avoid-palette-corruption-at-higher-clocks.patch
* hwmon-convert-idr-to-ida-and-use-ida_simple-interface.patch
* drivers-hwmon-hwmonc-convert-idr-to-ida-and-use-ida_simple_get.patch
* cputime-clean-up-cputime_to_usecs-and-usecs_to_cputime-macros.patch
* tick-fix-update_ts_time_stat-idle-accounting.patch
* nohz-do-not-update-idle-iowait-counters-from-get_cpu_idleiowait_time_us-if-not-asked.patch
* proc-consider-no_hz-when-printing-idle-and-iowait-times.patch
* ia64-exec-remove-redundant-set_fsuser_ds.patch
* unicore32-exec-remove-redundant-set_fsuser_ds.patch
  btusb-patch-add_apple_macbookpro62.patch
* debugobjects-extend-debugobjects-to-assert-that-an-object-is-initialized.patch
* kernel-timerc-use-debugobjects-to-catch-deletion-of-uninitialized-timers.patch
* ext4-use-proper-little-endian-bitops.patch
* ocfs2-avoid-unaligned-access-to-dqc_bitmap.patch
* parisc-exec-remove-redundant-set_fsuser_ds.patch
* pci-dmar-update-dmar-units-devices-list-during-hotplug.patch
* drivers-firmware-dmi_scanc-make-dmi_name_in_vendors-more-focused.patch
* kernel-rtmutexc-fix-warning-improve-coding-style.patch
* scsi-fix-a-header-to-include-linux-typesh.patch
* drivers-scsi-megaraidc-fix-sparse-warnings.patch
* drivers-scsi-aacraid-commctrlc-fix-mem-leak-in-aac_send_raw_srb.patch
* drivers-scsi-sdc-use-ida_simple_get-and-ida_simple_remove-in-place-of-boilerplate-code.patch
* drivers-scsi-osd-osd_uldc-use-ida_simple_get-to-handle-id.patch
* drivers-scsi-sgc-convert-to-kstrtoul_from_user.patch
* drivers-block-brdc-make-brd_make_request-return-error-code.patch
  drivers-block-loopc-emit-uevent-on-auto-release.patch
* sparc-exec-remove-redundant-addr_limit-assignment.patch
* drivers-staging-rts5139-rts51x_scsic-needs-vmalloch.patch
* drivers-staging-rts5139-xdc-needs-vmalloch.patch
* drivers-staging-rts5139-msc-needs-vmalloch.patch
* slab-add-taint-flag-outputting-to-debug-paths.patch
* slub-add-taint-flag-outputting-to-debug-paths.patch
  mm.patch
* cross-memory-attach-v3.patch
* cross-memory-attach-update.patch
* cross-memory-attach-v4.patch
* mm-compaction-trivial-clean-up-in-acct_isolated.patch
* mm-change-isolate-mode-from-define-to-bitwise-type.patch
* mm-compaction-make-isolate_lru_page-filter-aware.patch
* mm-zone_reclaim-make-isolate_lru_page-filter-aware.patch
* mm-migration-clean-up-unmap_and_move.patch
* radix_tree-clean-away-saw_unset_tag-leftovers.patch
* vmscan-add-block-plug-for-page-reclaim.patch
* mm-page-writebackc-make-determine_dirtyable_memory-static-again.patch
* oom-avoid-killing-kthreads-if-they-assume-the-oom-killed-threads-mm.patch
* tmpfs-add-tmpfs-to-the-kconfig-prompt-to-make-it-obvious.patch
* mm-output-a-list-of-loaded-modules-when-we-hit-bad_page.patch
* mm-vmscan-fix-force-scanning-small-targets-without-swap.patch
* mm-vmscan-fix-force-scanning-small-targets-without-swap-fix.patch
* mm-vmscan-drop-nr_force_scan-from-get_scan_count.patch
* mm-distinguish-between-mlocked-and-pinned-pages.patch
* mm-add-comments-to-explain-mm_struct-fields.patch
* mm-add-comments-to-explain-mm_struct-fields-fix.patch
* mm-vmscan-do-not-writeback-filesystem-pages-in-direct-reclaim.patch
* mm-vmscan-remove-dead-code-related-to-lumpy-reclaim-waiting-on-pages-under-writeback.patch
* xfs-warn-if-direct-reclaim-tries-to-writeback-pages.patch
* ext4-warn-if-direct-reclaim-tries-to-writeback-pages.patch
* mm-vmscan-do-not-writeback-filesystem-pages-in-kswapd-except-in-high-priority.patch
* mm-vmscan-throttle-reclaim-if-encountering-too-many-dirty-pages-under-writeback.patch
* mm-vmscan-immediately-reclaim-end-of-lru-dirty-pages-when-writeback-completes.patch
* vmscan-count-pages-into-balanced-for-zone-with-good-watermark.patch
* mm-debug-pageallocc-use-plain-__ratelimit-instead-of-printk_ratelimit.patch
* lib-stringc-introduce-memchr_inv.patch
* mm-debug-pageallocc-use-memchr_inv.patch
* vmscan-fix-initial-shrinker-size-handling.patch
* vmscan-use-atomic-long-for-shrinker-batching.patch
* vmscan-use-atomic-long-for-shrinker-batching-fix.patch
* mm-avoid-null-pointer-access-in-vm_struct-via-proc-vmallocinfo.patch
* vmscan-promote-shared-file-mapped-pages.patch
* vmscan-activate-executable-pages-after-first-usage.patch
* memblock-add-memblock_start_of_dram.patch
* memblock-add-no_bootmem-config-symbol.patch
* mremap-check-for-overflow-using-deltas.patch
* mremap-avoid-sending-one-ipi-per-page.patch
* thp-mremap-support-and-tlb-optimization.patch
* thp-mremap-support-and-tlb-optimization-fix.patch
* thp-mremap-support-and-tlb-optimization-fix-fix.patch
* thp-mremap-support-and-tlb-optimization-fix-fix-fix.patch
* drivers-base-inodec-let-vmstat_text-be-optional.patch
* drivers-base-inodec-let-vmstat_text-be-optional-fix.patch
* selinuxfs-remove-custome-hex_to_bin.patch
* include-linux-securityh-fix-security_inode_init_security-arg.patch
  frv-duplicate-output_buffer-of-e03.patch
  frv-duplicate-output_buffer-of-e03-checkpatch-fixes.patch
* hpet-factor-timer-allocate-from-open.patch
* intel_idle-fix-api-misuse.patch
* intel_idle-disable-auto_demotion-for-hotplugged-cpus.patch
* kprobes-silence-debug_strict_user_copy_checks=y-warning.patch
* x86-implement-strict-user-copy-checks-for-x86_64.patch
* consolidate-config_debug_strict_user_copy_checks.patch
* consolidate-config_debug_strict_user_copy_checks-fix.patch
* lis3lv02d-avoid-divide-by-zero-due-to-unchecked.patch
* lis3-update-maintainer-information.patch
* lis3-add-support-for-hp-elitebook-2730p.patch
* lis3-add-support-for-hp-elitebook-8540w.patch
* hp_accel-add-hp-probook-655x.patch
* config_hp_accel-fix-help-text.patch
* lis3-free-regulators-if-probe-fails.patch
* lis3-change-naming-to-consistent.patch
* lis3-change-exported-function-to-use-given.patch
* lis3-remove-the-references-to-the-global-variable-in-core-driver.patch
* printk-add-module-parameter-ignore_loglevel-to-control-ignore_loglevel.patch
* printk-add-module-parameter-ignore_loglevel-to-control-ignore_loglevel-fix.patch
* printk-add-console_suspend-module-parameter.patch
* fs-nameic-remove-unused-getname_flags.patch
  fcntlf_setfl-allow-setting-of-o_sync.patch
* leds-renesas-tpu-led-driver-v2.patch
* leds-renesas-tpu-led-driver-v2-fix.patch
* drivers-leds-led-triggersc-fix-memory-leak.patch
  leds-route-kbd-leds-through-the-generic-leds-layer.patch
  leds-route-kbd-leds-through-the-generic-leds-layer-fix.patch
* lib-kstrtox-common-code-between-kstrto-and-simple_strto-functions.patch
* lib-crc-add-slice-by-8-algorithm-to-crc32c.patch
* lib-crc-add-slice-by-8-algorithm-to-crc32c-fix.patch
* epoll-fix-spurious-lockdep-warnings.patch
  lib-hexdumpc-make-hex2bin-return-the-updated-src-address.patch
  fs-binfmt_miscc-use-kernels-hex_to_bin-method.patch
  fs-binfmt_miscc-use-kernels-hex_to_bin-method-fix.patch
  fs-binfmt_miscc-use-kernels-hex_to_bin-method-fix-fix.patch
* oprofilefs-handle-zero-length-writes.patch
* drivers-rtc-classc-convert-idr-to-ida-and-use-ida_simple_get.patch
* minix-describe-usage-of-different-magic-numbers.patch
* memcg-rename-mem-variable-to-memcg.patch
* memcg-fix-oom-schedule_timeout.patch
* memcg-use-vzalloc-instead-of-vmalloc.patch
* memcg-replace-ss-id_lock-with-a-rwlock.patch
* memcg-do-not-expose-uninitialized-mem_cgroup_per_node-to-world.patch
* memcg-remove-unneeded-preempt_disable.patch
* procfs-report-eisdir-when-reading-sysctl-dirs-in-proc.patch
* ipc-introduce-shm_rmid_forced-sysctl-testing.patch
* init-add-root=partuuid=uuid-partnroff=%d-support.patch
* init-add-root=partuuid=uuid-partnroff=%d-support-fix.patch
* drivers-rapidio-rio-scanc-use-discovered-bit-to-test-if-enumeration-is-complete.patch
* rapidio-add-mport-driver-for-tsi721-bridge.patch
* sysctl-make-config_sysctl_syscall-default-to-n.patch
* nbd-use-task_pid_nr-to-get-current-pid.patch
* nbd-replace-sysfs_create_file-with-device_create_file.patch
* nbd-replace-printk-kern_err-with-dev_err.patch
* nbd-lower-the-loglevel-of-an-error-message.patch
* nbd-replace-some-printk-with-dev_warn-and-dev_info.patch
* nbd-replace-some-printk-with-dev_warn-and-dev_info-checkpatch-fixes.patch
* pps-default-echo-function.patch
* pps-new-client-driver-using-gpio.patch
* pps-new-client-driver-using-gpio-fix.patch
  scatterlist-new-helper-functions.patch
  scatterlist-new-helper-functions-update.patch
  scatterlist-new-helper-functions-update-fix.patch
  memstick-add-support-for-legacy-memorysticks.patch
  memstick-add-support-for-legacy-memorysticks-fix.patch
  memstick-add-support-for-legacy-memorysticks-update-2.patch
* w1-ds2760-and-ds2780-use-ida-for-id-and-ida_simple_get-to-get-it.patch
* drivers-power-ds2780_batteryc-create-central-point-for-calling-w1-interface.patch
* drivers-power-ds2780_batteryc-add-a-nolock-function-to-w1-interface.patch
* drivers-power-ds2780_batteryc-fix-deadlock-upon-insertion-and-removal.patch
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
