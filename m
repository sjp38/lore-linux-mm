Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id E34A96B0002
	for <linux-mm@kvack.org>; Wed, 22 May 2013 19:42:14 -0400 (EDT)
Received: by mail-vb0-f74.google.com with SMTP id w15so144847vbf.5
        for <linux-mm@kvack.org>; Wed, 22 May 2013 16:42:13 -0700 (PDT)
Subject: mmotm 2013-05-22-16-40 uploaded
From: akpm@linux-foundation.org
Date: Wed, 22 May 2013 16:42:12 -0700
Message-Id: <20130522234213.254ED31C6DC@corp2gmr1-1.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

The mm-of-the-moment snapshot 2013-05-22-16-40 has been uploaded to

   http://www.ozlabs.org/~akpm/mmotm/

mmotm-readme.txt says

README for mm-of-the-moment:

http://www.ozlabs.org/~akpm/mmotm/

This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
more than once a week.

You will need quilt to apply these patches to the latest Linus release (3.x
or 3.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
http://ozlabs.org/~akpm/mmotm/series

The file broken-out.tar.gz contains two datestamp files: .DATE and
.DATE-yyyy-mm-dd-hh-mm-ss.  Both contain the string yyyy-mm-dd-hh-mm-ss,
followed by the base kernel version against which this patch series is to
be applied.

This tree is partially included in linux-next.  To see which patches are
included in linux-next, consult the `series' file.  Only the patches
within the #NEXT_PATCHES_START/#NEXT_PATCHES_END markers are included in
linux-next.

A git tree which contains the memory management portion of this tree is
maintained at git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
by Michal Hocko.  It contains the patches which are between the
"#NEXT_PATCHES_START mm" and "#NEXT_PATCHES_END" markers, from the series
file, http://www.ozlabs.org/~akpm/mmotm/series.


A full copy of the full kernel tree with the linux-next and mmotm patches
already applied is available through git within an hour of the mmotm
release.  Individual mmotm releases are tagged.  The master branch always
points to the latest release, so it's constantly rebasing.

http://git.cmpxchg.org/?p=linux-mmotm.git;a=summary

To develop on top of mmotm git:

  $ git remote add mmotm git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
  $ git remote update mmotm
  $ git checkout -b topic mmotm/master
  <make changes, commit>
  $ git send-email mmotm/master.. [...]

To rebase a branch with older patches to a new mmotm release:

  $ git remote update mmotm
  $ git rebase --onto mmotm/master <topic base> topic




The directory http://www.ozlabs.org/~akpm/mmots/ (mm-of-the-second)
contains daily snapshots of the -mm tree.  It is updated more frequently
than mmotm, and is untested.

A git copy of this tree is available at

	http://git.cmpxchg.org/?p=linux-mmots.git;a=summary

and use of this tree is similar to
http://git.cmpxchg.org/?p=linux-mmotm.git, described above.


This mmotm tree contains the following patches against 3.10-rc2:
(patches marked "*" will be included in linux-next)

  origin.patch
  linux-next.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  i-need-old-gcc.patch
* drivers-block-xsysacec-fix-id-with-missing-port-number.patch
* rapidio-make-enumeration-discovery-configurable.patch
* rapidio-add-enumeration-discovery-start-from-user-space.patch
* rapidio-documentation-update-for-enumeration-changes.patch
* fat-fix-possible-overflow-for-fat_clusters.patch
* wait-fix-false-timeouts-when-using-wait_event_timeout.patch
* mm-mmu_notifier-re-fix-freed-page-still-mapped-in-secondary-mmu.patch
* mm-mmu_notifier-re-fix-freed-page-still-mapped-in-secondary-mmu-fix.patch
* ocfs2-unlock-rw-lock-if-inode-lock-failed.patch
* drivers-video-implement-a-simple-framebuffer-driver.patch
* mm-memcg-remove-incorrect-vm_bug_on-for-swap-cache-pages-in-uncharge.patch
* hfs-avoid-crash-in-hfs_bnode_create.patch
* shm-fix-null-pointer-deref-when-userspace-specifies-invalid-hugepage-size-fix.patch
* rapidio-tsi721-fix-bug-in-msi-interrupt-handling.patch
* mm-compaction-fix-of-improper-cache-flush-in-migration-code.patch
* linux-kernelh-fix-kernel-doc-warning.patch
* mm-thp-use-pmd_populate-to-update-the-pmd-with-pgtable_t-pointer.patch
* drivers-leds-leds-ot200c-fix-error-caused-by-shifted-mask.patch
* revert-selftest-add-simple-test-for-soft-dirty-bit.patch
* aio-fix-io_getevents-documentation.patch
* auditfilterc-fix-kernel-doc-warnings.patch
* drivers-rtc-rtc-pl031c-pass-correct-pointer-to-free_irq.patch
* fbdev-fb_goldfish-should-depend-on-has_dma.patch
* drivers-block-brdc-fix-brd_lookup_page-race.patch
* nilfs2-fix-issue-of-nilfs_set_page_dirty-for-page-at-eof-boundary.patch
* mm-memory_hotplugc-fix-printk-format-warnings.patch
* cpu-hotplug-provide-a-generic-helper-to-disable-enable-cpu-hotplug.patch
* cpu-hotplug-provide-a-generic-helper-to-disable-enable-cpu-hotplug-v11.patch
* migrate-shutdown-reboot-to-boot-cpu.patch
* migrate-shutdown-reboot-to-boot-cpu-v11.patch
* kmsg-honor-dmesg_restrict-sysctl-on-dev-kmsg.patch
* kmsg-honor-dmesg_restrict-sysctl-on-dev-kmsg-fix.patch
* kernel-audit_treec-audit_add_tree_rule-protect-rule-from-kill_rules.patch
* drivers-char-randomc-fix-priming-of-last_data.patch
* random-fix-accounting-race-condition-with-lockless-irq-entropy_count-update.patch
* sound-soc-codecs-si476xc-dont-use-0bnnn.patch
* x86-make-mem=-option-to-work-for-efi-platform.patch
* audit-fix-mq_open-and-mq_unlink-to-add-the-mq-root-as-a-hidden-parent-audit_names-record.patch
* kernel-auditfilterc-fix-leak-in-audit_add_rule-error-path.patch
* drm-fb-helper-dont-sleep-for-screen-unblank-when-an-oopps-is-in-progress.patch
* video-smscufx-use-null-instead-of-0.patch
* video-udlfb-use-null-instead-of-0.patch
* video-udlfb-make-local-symbol-static.patch
* video-imxfb-make-local-symbols-static.patch
* cyber2000fb-avoid-palette-corruption-at-higher-clocks.patch
* posix_cpu_timer-consolidate-expiry-time-type.patch
* posix_cpu_timers-consolidate-timer-list-cleanups.patch
* posix_cpu_timers-consolidate-expired-timers-check.patch
* selftests-add-basic-posix-timers-selftests.patch
* posix-timers-correctly-get-dying-task-time-sample-in-posix_cpu_timer_schedule.patch
* posix_timers-fix-racy-timer-delta-caching-on-task-exit.patch
* drivers-infiniband-core-cmc-convert-to-using-idr_alloc_cyclic.patch
* configfs-use-capped-length-for-store_attribute.patch
* ipvs-change-type-of-netns_ipvs-sysctl_sync_qlen_max.patch
* fs-ocfs2-nameic-remove-unecessary-error-when-removing-non-empty-directory.patch
* softirq-use-_ret_ip_.patch
* lockdep-introduce-lock_acquire_exclusive-shared-helper-macros.patch
* lglock-update-lockdep-annotations-to-report-recursive-local-locks.patch
* drivers-cdrom-gdromc-fix-device-number-leak.patch
* block-compat_ioctlc-do-not-leak-info-to-user-space.patch
* block-remove-refs-to-xd-disks-from-documentation.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* vfs-fix-invalid-ida_remove-call.patch
* watchdog-trigger-all-cpu-backtrace-when-locked-up-and-going-to-panic.patch
  mm.patch
* clear_refs-sanitize-accepted-commands-declaration.patch
* clear_refs-introduce-private-struct-for-mm_walk.patch
* pagemap-introduce-pagemap_entry_t-without-pmshift-bits.patch
* pagemap-introduce-pagemap_entry_t-without-pmshift-bits-v4.patch
* mm-soft-dirty-bits-for-user-memory-changes-tracking.patch
* mm-soft-dirty-bits-for-user-memory-changes-tracking-call-mmu-notifiers-when-write-protecting-ptes.patch
* pagemap-prepare-to-reuse-constant-bits-with-page-shift.patch
* mm-thp-use-the-right-function-when-updating-access-flags.patch
* mm-memcg-dont-take-task_lock-in-task_in_mem_cgroup.patch
* mm-remove-free_area_cache.patch
* mm-remove-compressed-copy-from-zram-in-memory.patch
* mm-remove-compressed-copy-from-zram-in-memory-fix.patch
* mm-page_alloc-fix-watermark-check-in-__zone_watermark_ok.patch
* swap-add-a-simple-detector-for-inappropriate-swapin-readahead.patch
* mm-use-vma_pages-to-replace-vm_end-vm_start-page_shift.patch
* ncpfs-use-vma_pages-to-replace-vm_end-vm_start-page_shift.patch
* uio-use-vma_pages-to-replace-vm_end-vm_start-page_shift.patch
* mm-page_alloc-factor-out-setting-of-pcp-high-and-pcp-batch.patch
* mm-page_alloc-prevent-concurrent-updaters-of-pcp-batch-and-high.patch
* mm-page_alloc-insert-memory-barriers-to-allow-async-update-of-pcp-batch-and-high.patch
* mm-page_alloc-protect-pcp-batch-accesses-with-access_once.patch
* mm-page_alloc-convert-zone_pcp_update-to-rely-on-memory-barriers-instead-of-stop_machine.patch
* mm-page_alloc-when-handling-percpu_pagelist_fraction-dont-unneedly-recalulate-high.patch
* mm-page_alloc-factor-setup_pageset-into-pageset_init-and-pageset_set_batch.patch
* mm-page_alloc-relocate-comment-to-be-directly-above-code-it-refers-to.patch
* mm-page_alloc-factor-zone_pageset_init-out-of-setup_zone_pageset.patch
* mm-page_alloc-in-zone_pcp_update-uze-zone_pageset_init.patch
* mm-page_alloc-rename-setup_pagelist_highmark-to-match-naming-of-pageset_set_batch.patch
* mm-thp-add-pmd-args-to-pgtable-deposit-and-withdraw-apis.patch
* mm-thp-withdraw-the-pgtable-after-pmdp-related-operations.patch
* mm-thp-dont-use-hpage_shift-in-transparent-hugepage-code.patch
* mm-thp-deposit-the-transpare-huge-pgtable-before-set_pmd.patch
* mm-vmscan-limit-the-number-of-pages-kswapd-reclaims-at-each-priority.patch
* mm-vmscan-obey-proportional-scanning-requirements-for-kswapd.patch
* mm-vmscan-flatten-kswapd-priority-loop.patch
* mm-vmscan-decide-whether-to-compact-the-pgdat-based-on-reclaim-progress.patch
* mm-vmscan-do-not-allow-kswapd-to-scan-at-maximum-priority.patch
* mm-vmscan-have-kswapd-writeback-pages-based-on-dirty-pages-encountered-not-priority.patch
* mm-vmscan-block-kswapd-if-it-is-encountering-pages-under-writeback.patch
* mm-vmscan-block-kswapd-if-it-is-encountering-pages-under-writeback-fix.patch
* mm-vmscan-check-if-kswapd-should-writepage-once-per-pgdat-scan.patch
* mm-vmscan-move-logic-from-balance_pgdat-to-kswapd_shrink_zone.patch
* mm-fix-comment-referring-to-non-existent-size_seqlock-change-to-span_seqlock.patch
* mmzone-note-that-node_size_lock-should-be-manipulated-via-pgdat_resize_lock.patch
* memory_hotplug-use-pgdat_resize_lock-in-online_pages.patch
* memory_hotplug-use-pgdat_resize_lock-in-__offline_pages.patch
* memory_hotplug-use-pgdat_resize_lock-in-__offline_pages-fix.patch
* include-linux-mmzoneh-cleanups.patch
* include-linux-mmzoneh-cleanups-fix.patch
* mm-memmap_init_zone-performance-improvement.patch
* drop_caches-add-some-documentation-and-info-messsge.patch
* drivers-usb-gadget-amd5536udcc-avoid-calling-dma_pool_create-with-null-dev.patch
* mm-dmapoolc-fix-null-dev-in-dma_pool_create.patch
* memcg-debugging-facility-to-access-dangling-memcgs.patch
* memcg-debugging-facility-to-access-dangling-memcgs-fix.patch
* mm-add-vm-event-counters-for-balloon-pages-compaction.patch
* errh-is_err-can-accept-__user-pointers.patch
* dump_stack-serialize-the-output-from-dump_stack.patch
* dump_stack-serialize-the-output-from-dump_stack-fix.patch
* panic-add-cpu-pid-to-warn_slowpath_common-in-warning-printks.patch
* panic-add-cpu-pid-to-warn_slowpath_common-in-warning-printks-fix.patch
* smp-give-warning-when-calling-smp_call_function_many-single-in-serving-irq.patch
* backlight-atmel-pwm-bl-remove-unnecessary-platform_set_drvdata.patch
* backlight-ep93xx-remove-unnecessary-platform_set_drvdata.patch
* backlight-lp8788-remove-unnecessary-platform_set_drvdata.patch
* backlight-pcf50633-remove-unnecessary-platform_set_drvdata.patch
* lib-bitmapc-speed-up-bitmap_find_free_region.patch
* lib-bitmapc-speed-up-bitmap_find_free_region-fix.patch
* rbtree-remove-unneeded-include.patch
* rbtree-remove-unneeded-include-fix.patch
* checkpatch-change-camelcase-test-and-make-it-strict.patch
* checkpatch-warn-when-using-gccs-binary-constant-extension.patch
* binfmt_elfc-use-get_random_int-to-fix-entropy-depleting.patch
* init-remove-permanent-string-buffer-from-do_one_initcall.patch
* insert-missing-space-in-printk-line-of-root_delay.patch
* autofs4-allow-autofs-to-work-outside-the-initial-pid-namespace.patch
* autofs4-translate-pids-to-the-right-namespace-for-the-daemon.patch
* rtc-rtc-88pm80x-remove-unnecessary-platform_set_drvdata.patch
* drivers-rtc-rtc-v3020c-remove-redundant-goto.patch
* drivers-rtc-interfacec-fix-checkpatch-errors.patch
* drivers-rtc-rtc-at32ap700xc-fix-checkpatch-error.patch
* drivers-rtc-rtc-at91rm9200c-include-linux-uaccessh.patch
* drivers-rtc-rtc-cmosc-fix-whitespace-related-errors.patch
* drivers-rtc-rtc-davincic-fix-whitespace-warning.patch
* drivers-rtc-rtc-ds1305c-add-missing-braces-around-sizeof.patch
* drivers-rtc-rtc-ds1374c-fix-spacing-related-issues.patch
* drivers-rtc-rtc-ds1511c-fix-issues-related-to-spaces-and-braces.patch
* drivers-rtc-rtc-ds3234c-fix-whitespace-issue.patch
* drivers-rtc-rtc-fm3130c-fix-whitespace-related-issue.patch
* drivers-rtc-rtc-m41t80c-fix-spacing-related-issue.patch
* drivers-rtc-rtc-max6902c-remove-unwanted-spaces.patch
* drivers-rtc-rtc-max77686c-remove-space-before-semicolon.patch
* drivers-rtc-rtc-max8997c-remove-space-before-semicolon.patch
* drivers-rtc-rtc-mpc5121c-remove-space-before-tab.patch
* drivers-rtc-rtc-msm6242c-use-pr_warn.patch
* drivers-rtc-rtc-mxcc-fix-checkpatch-error.patch
* drivers-rtc-rtc-omapc-include-linux-ioh-instead-of-asm-ioh.patch
* drivers-rtc-rtc-pcf2123c-remove-space-before-tabs.patch
* drivers-rtc-rtc-pcf8583c-move-assignment-outside-if-condition.patch
* drivers-rtc-rtc-rs5c313c-include-linux-ioh-instead-of-asm-ioh.patch
* drivers-rtc-rtc-rs5c313c-fix-spacing-related-issues.patch
* drivers-rtc-rtc-v3020c-fix-spacing-issues.patch
* drivers-rtc-rtc-vr41xxc-fix-spacing-issues.patch
* drivers-rtc-rtc-x1205c-fix-checkpatch-issues.patch
* rtc-rtc-88pm860x-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-ab3100-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-ab8500-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-at32ap700x-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-at91rm9200-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-at91sam9-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-au1xxx-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-bfin-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-bq4802-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-coh901331-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-da9052-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-da9055-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-davinci-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-dm355evm-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-ds1302-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-ep93xx-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-jz4740-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-lp8788-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-lpc32xx-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-ls1x-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-m48t59-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-max8925-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-max8998-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-mc13xxx-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-msm6242-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-mxc-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-nuc900-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-pcap-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-pm8xxx-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-s3c-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-sa1100-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-sh-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-spear-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-stmp3xxx-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-twl-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-vr41xx-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-vt8500-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-m48t86-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-puv3-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-rp5c01-remove-unnecessary-platform_set_drvdata.patch
* rtc-rtc-tile-remove-unnecessary-platform_set_drvdata.patch
* drivers-rtc-rtc-rv3029c2c-fix-disabling-aie-irq.patch
* drivers-rtc-rtc-m48t86c-remove-empty-function.patch
* drivers-rtc-rtc-tilec-remove-empty-function.patch
* drivers-rtc-rtc-nuc900c-remove-empty-function.patch
* drivers-rtc-rtc-msm6242c-remove-empty-function.patch
* drivers-rtc-rtc-max8998c-remove-empty-function.patch
* drivers-rtc-rtc-max8925c-remove-empty-function.patch
* drivers-rtc-rtc-ls1xc-remove-empty-function.patch
* drivers-rtc-rtc-lp8788c-remove-empty-function.patch
* drivers-rtc-rtc-ds1302c-remove-empty-function.patch
* drivers-rtc-rtc-dm355evmc-remove-empty-function.patch
* drivers-rtc-rtc-da9055c-remove-empty-function.patch
* drivers-rtc-rtc-da9052c-remove-empty-function.patch
* drivers-rtc-rtc-bq4802c-remove-empty-function.patch
* drivers-rtc-rtc-au1xxxc-remove-empty-function.patch
* drivers-rtc-rtc-ab3100c-remove-empty-function.patch
* rtc-rtc-hid-sensor-time-allow-full-years-16bit-in-hid-reports.patch
* rtc-rtc-hid-sensor-time-allow-16-and-32-bit-values-for-all-attributes.patch
* rtc-rtc-hid-sensor-time-add-option-hctosys-to-set-time-at-boot.patch
* rtc-rtc-hid-sensor-time-add-support-for-milliseconds.patch
* rtc-add-ability-to-push-out-an-existing-wakealarm-using-sysfs.patch
* drivers-rtc-rtc-tps6586xc-device-wakeup-flags-correction.patch
* reiserfs-fix-deadlock-with-nfs-racing-on-create-lookup.patch
* fs-fat-use-fat_msg-to-replace-printk-in-__fat_fs_error.patch
* fat-additions-to-support-fat_fallocate.patch
* fat-additions-to-support-fat_fallocate-fix.patch
* documentation-codingstyle-allow-multiple-return-statements-per-function.patch
* ptrace-x86-revert-hw_breakpoints-fix-racy-access-to-ptrace-breakpoints.patch
* ptrace-powerpc-revert-hw_breakpoints-fix-racy-access-to-ptrace-breakpoints.patch
* ptrace-arm-revert-hw_breakpoints-fix-racy-access-to-ptrace-breakpoints.patch
* ptrace-sh-revert-hw_breakpoints-fix-racy-access-to-ptrace-breakpoints.patch
* ptrace-revert-prepare-to-fix-racy-accesses-on-task-breakpoints.patch
* ptrace-x86-simplify-the-disable-logic-in-ptrace_write_dr7.patch
* ptrace-x86-dont-delay-disable-till-second-pass-in-ptrace_write_dr7.patch
* ptrace-x86-introduce-ptrace_register_breakpoint.patch
* ptrace-x86-ptrace_write_dr7-should-create-bp-if-disabled.patch
* ptrace-x86-cleanup-ptrace_set_debugreg.patch
* ptrace-ptrace_detach-should-do-flush_ptrace_hw_breakpointchild.patch
* ptrace-x86-flush_ptrace_hw_breakpoint-shoule-clear-the-virtual-debug-registers.patch
* x86-kill-tif_debug.patch
* fork-reorder-permissions-when-violating-number-of-processes-limits.patch
* idr-print-a-stack-dump-after-ida_remove-warning.patch
* idr-print-a-stack-dump-after-ida_remove-warning-fix.patch
* mwave-fix-info-leak-in-mwave_ioctl.patch
* partitions-msdosc-end-of-line-whitespace-and-semicolon-cleanup.patch
* partitions-add-aix-lvm-partition-support-files.patch
* partitions-add-aix-lvm-partition-support-files-v2.patch
* partitions-add-aix-lvm-partition-support-files-checkpatch-fixes.patch
* partitions-add-aix-lvm-partition-support-files-compile-aixc-if-configured.patch
* partitions-add-aix-lvm-partition-support-files-add-the-aix_partition-entry.patch
* partitions-msdos-enumerate-also-aix-lvm-partitions.patch
* rapidio-switches-remove-tsi500-driver.patch
* drivers-parport-use-kzalloc.patch
* drivers-pps-clients-pps-gpioc-convert-to-devm_-helpers.patch
* drivers-pps-clients-pps-gpioc-convert-to-module_platform_driver.patch
* drivers-w1-slaves-w1_ds2408c-add-magic-sequence-to-disable-p0-test-mode.patch
* drivers-w1-slaves-w1_ds2408c-add-magic-sequence-to-disable-p0-test-mode-fix.patch
* relay-fix-timer-madness.patch
* aio-reqs_active-reqs_available.patch
* aio-percpu-reqs_available.patch
* generic-dynamic-per-cpu-refcounting.patch
* aio-percpu-ioctx-refcount.patch
* aio-use-xchg-instead-of-completion_lock.patch
* block-prep-work-for-batch-completion.patch
* block-prep-work-for-batch-completion-fix-2.patch
* block-prep-work-for-batch-completion-fix-3.patch
* block-prep-work-for-batch-completion-fix-3-fix.patch
* block-prep-work-for-batch-completion-fix-99.patch
* block-prep-work-for-batch-completion-fix-4.patch
* block-prep-work-for-batch-completion-fix-101.patch
* block-aio-batch-completion-for-bios-kiocbs.patch
* aio-fix-kioctx-not-being-freed-after-cancellation-at-exit-time.patch
* block-aio-batch-completion-for-bios-kiocbs-fix.patch
* virtio-blk-convert-to-batch-completion.patch
* mtip32xx-convert-to-batch-completion.patch
* aio-convert-the-ioctx-list-to-radix-tree.patch
* lib-add-weak-clz-ctz-functions.patch
* decompressor-add-lz4-decompressor-module.patch
* lib-add-support-for-lz4-compressed-kernel.patch
* lib-add-support-for-lz4-compressed-kernel-kbuild-fix-for-updated-lz4-tool-with-the-new-streaming-format.patch
* arm-add-support-for-lz4-compressed-kernel.patch
* arm-add-support-for-lz4-compressed-kernel-fix.patch
* x86-add-support-for-lz4-compressed-kernel.patch
* x86-add-support-for-lz4-compressed-kernel-doc-add-lz4-magic-number-for-the-new-compression.patch
* lib-add-lz4-compressor-module.patch
* lib-add-lz4-compressor-module-fix.patch
* crypto-add-lz4-cryptographic-api.patch
* crypto-add-lz4-cryptographic-api-fix.patch
* scripts-sortextablec-fix-building-on-non-linux-systems.patch
  debugging-keep-track-of-page-owners.patch
  debugging-keep-track-of-page-owners-fix.patch
  debugging-keep-track-of-page-owners-fix-2.patch
  debugging-keep-track-of-page-owners-fix-2-fix.patch
  debugging-keep-track-of-page-owners-fix-2-fix-fix.patch
  debugging-keep-track-of-page-owners-fix-2-fix-fix-fix.patch
  debugging-keep-track-of-page-owner-now-depends-on-stacktrace_support.patch
  make-sure-nobodys-leaking-resources.patch
  journal_add_journal_head-debug.patch
  releasing-resources-with-children.patch
  make-frame_pointer-default=y.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  mutex-subsystem-synchro-test-module.patch
  slab-leaks3-default-y.patch
  put_bh-debug.patch
  add-debugging-aid-for-memory-initialisation-problems.patch
  workaround-for-a-pci-restoring-bug.patch
  single_open-seq_release-leak-diagnostics.patch
  add-a-refcount-check-in-dput.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
