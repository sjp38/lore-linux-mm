Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 148046B005D
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 18:44:09 -0500 (EST)
Received: by mail-wg0-f73.google.com with SMTP id dt12so1060208wgb.0
        for <linux-mm@kvack.org>; Fri, 04 Jan 2013 15:44:07 -0800 (PST)
Subject: mmotm 2013-01-04-15-43 uploaded
From: akpm@linux-foundation.org
Date: Fri, 04 Jan 2013 15:44:04 -0800
Message-Id: <20130104234405.8750720004E@hpza10.eem.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

The mm-of-the-moment snapshot 2013-01-04-15-43 has been uploaded to

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


This mmotm tree contains the following patches against 3.8-rc2:
(patches marked "*" will be included in linux-next)

  origin.patch
* drivers-rtc-rtc-tegrac-convert-to-dt-driver.patch
* ipc-remove-forced-assignment-of-selected-message.patch
* ipc-add-sysctl-to-specify-desired-next-object-id.patch
* ipc-message-queue-receive-cleanup.patch
* ipc-message-queue-copy-feature-introduced.patch
* selftests-ipc-message-queue-copy-feature-test.patch
* ipc-simplify-free_copy-call.patch
* ipc-convert-prepare_copy-from-macro-to-function.patch
* ipc-simplify-message-copying.patch
* ipc-add-more-comments-to-message-copying-related-code.patch
* documentation-sysctl-kerneltxt-document-proc-sys-shmall.patch
* mm-fix-zone_watermark_ok_safe-accounting-of-isolated-pages.patch
* mm-limit-mmu_gather-batching-to-fix-soft-lockups-on-config_preempt.patch
* maintainers-remove-drivers-platform-msm.patch
* maintainers-remove-arch-arm-common-time-acornc.patch
* maintainers-remove-arch-arm-plat-s5p.patch
* maintainers-fix-drivers-rtc-rtc-vt8500c.patch
* maintainers-fix-arch-arm-mach-at91-include-mach-at_hdmach.patch
* maintainers-fix-drivers-media-platform-atmel-isic.patch
* maintainers-adjust-for-uapi.patch
* maintainers-fix-drivers-media-usb-dvb-usb-cxusb.patch
* maintainers-remove-drivers-video-epson1355fbc.patch
* maintainers-fix-plat-mxc-include-mach-imxfbh.patch
* maintainers-fix-drivers-ieee802154.patch
* maintainers-remove-firmware-isci.patch
* maintainers-remove-arch-x86-platform-mrst-pmu.patch
* maintainers-fix-documentation-mei.patch
* maintainers-remove-drivers-mmc-host-imxmmc.patch
* maintainers-remove-arch-lib-perf_eventc.patch
* maintainers-remove-include-linux-of_pwmh.patch
* maintainers-fix-drivers-staging-sm7xx.patch
* rtc-add-rtc-driver-for-tps6586x.patch
* drivers-rtc-rtc-vt8500c-correct-handling-of-cr_24h-bitfield.patch
* drivers-rtc-rtc-vt8500c-fix-handling-of-data-passed-in-struct-rtc_time.patch
* printk-fix-incorrect-length-from-print_time-when-seconds-99999.patch
  linux-next.patch
  linux-next-git-rejects.patch
  make-my-i386-build-work.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
* compiler-gcc4h-reorder-macros-based-upon-gcc-ver.patch
* compiler-gcch-add-gcc-recommended-gcc_version-macro.patch
* compiler-gcc34h-use-gcc_version-macro.patch
* compiler-gcc4h-bugh-remove-duplicate-macros.patch
* bugh-fix-build_bug_on-macro-in-__checker__.patch
* bugh-prevent-double-evaulation-of-in-build_bug_on.patch
* bugh-prevent-double-evaulation-of-in-build_bug_on-fix.patch
* bugh-make-build_bug_on-generate-compile-time-error.patch
* compilerh-bugh-prevent-double-error-messages-with-build_bug_on.patch
* bugh-compilerh-introduce-compiletime_assert-build_bug_on_msg.patch
* bugh-compilerh-introduce-compiletime_assert-build_bug_on_msg-checkpatch-fixes.patch
  i-need-old-gcc.patch
* lib-cpu_rmap-avoid-flushing-all-workqueues.patch
* lib-cpu_rmap-avoid-flushing-all-workqueues-fix.patch
* drivers-rtc-rtc-da9055c-fix-cross-section-reference.patch
* fs-block_devc-page-cache-wrongly-left-invalidated-after-revalidate_disk.patch
* x86-numa-dont-check-if-node-is-numa_no_node.patch
* arch-x86-tools-insn_sanityc-identify-source-of-messages.patch
* uv-fix-incorrect-tlb-flush-all-issue.patch
* olpc-fix-olpc-xo1-scic-build-errors.patch
* x86-convert-update_mmu_cache-and-update_mmu_cache_pmd-to-functions.patch
* x86-fix-the-argument-passed-to-sync_global_pgds.patch
* x86-fix-a-compile-error-a-section-type-conflict.patch
* x86-make-mem=-option-to-work-for-efi-platform.patch
* audit-create-explicit-audit_seccomp-event-type.patch
* audit-catch-possible-null-audit-buffers.patch
* kernel-auditc-avoid-negative-sleep-durations.patch
* cris-use-int-for-ssize_t-to-match-size_t.patch
* pcmcia-move-unbind-rebind-into-dev_pm_opscomplete.patch
* drivers-gpu-drm-drm_fb_helperc-avoid-sleeping-in-unblank_screen-if-oops-in-progress.patch
* fb-rework-locking-to-fix-lock-ordering-on-takeover.patch
* fb-rework-locking-to-fix-lock-ordering-on-takeover-fix.patch
* fb-rework-locking-to-fix-lock-ordering-on-takeover-fix-2.patch
* cyber2000fb-avoid-palette-corruption-at-higher-clocks.patch
* timeconstpl-remove-deprecated-defined-array.patch
* time-dont-inline-export_symbol-functions.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* fs-change-return-values-from-eacces-to-eperm.patch
* fs-block_devc-need-not-to-check-inode-i_bdev-in-bd_forget.patch
* watchdog-trigger-all-cpu-backtrace-when-locked-up-and-going-to-panic.patch
  mm.patch
* memcg-oom-provide-more-precise-dump-info-while-memcg-oom-happening.patch
* mm-memcontrolc-convert-printkkern_foo-to-pr_foo.patch
* mm-hugetlbc-convert-to-pr_foo.patch
* cma-make-putback_lru_pages-call-conditional.patch
* cma-make-putback_lru_pages-call-conditional-fix.patch
* mm-memcg-only-evict-file-pages-when-we-have-plenty.patch
* mm-vmscan-save-work-scanning-almost-empty-lru-lists.patch
* mm-vmscan-clarify-how-swappiness-highest-priority-memcg-interact.patch
* mm-vmscan-improve-comment-on-low-page-cache-handling.patch
* mm-vmscan-clean-up-get_scan_count.patch
* mm-vmscan-clean-up-get_scan_count-fix.patch
* mm-vmscan-compaction-works-against-zones-not-lruvecs.patch
* mm-vmscan-compaction-works-against-zones-not-lruvecs-fix.patch
* mm-reduce-rmap-overhead-for-ex-ksm-page-copies-created-on-swap-faults.patch
* mm-page_allocc-__setup_per_zone_wmarks-make-min_pages-unsigned-long.patch
* mm-vmscanc-__zone_reclaim-replace-max_t-with-max.patch
* mm-compaction-do-not-accidentally-skip-pageblocks-in-the-migrate-scanner.patch
* mm-huge_memory-use-new-hashtable-implementation.patch
* mmksm-use-new-hashtable-implementation.patch
* memcgvmscan-do-not-break-out-targeted-reclaim-without-reclaimed-pages.patch
* mm-memmap_init_zone-performance-improvement.patch
* drop_caches-add-some-documentation-and-info-messsge.patch
* drivers-usb-gadget-amd5536udcc-avoid-calling-dma_pool_create-with-null-dev.patch
* mm-dmapoolc-fix-null-dev-in-dma_pool_create.patch
* memcg-debugging-facility-to-access-dangling-memcgs.patch
* memcg-debugging-facility-to-access-dangling-memcgs-fix.patch
* mm-add-vm-event-counters-for-balloon-pages-compaction.patch
* ext3-ext4-ocfs2-remove-unused-macro-namei_ra_index.patch
* scripts-pnmtologo-fix-for-plain-pbm-checkpatch-fixes.patch
* scripts-tagssh-add-magic-for-declarations-of-popular-kernel-type.patch
* get_maintainerpl-find-maintainers-for-removed-files.patch
* backlight-add-lms501kf03-lcd-driver.patch
* backlight-add-lms501kf03-lcd-driver-fix.patch
* backlight-ld9040-use-sleep-instead-of-delay.patch
* backlight-ld9040-remove-unnecessary-null-deference-check.patch
* backlight-ld9040-replace-efault-with-einval.patch
* backlight-ld9040-remove-redundant-return-variables.patch
* backlight-ld9040-reorder-inclusions-of-linux-xxxh.patch
* backlight-s6e63m0-use-lowercase-names-of-structs.patch
* backlight-s6e63m0-use-sleep-instead-of-delay.patch
* backlight-s6e63m0-remove-unnecessary-null-deference-check.patch
* backlight-s6e63m0-replace-efault-with-einval.patch
* backlight-s6e63m0-remove-redundant-variable-before_power.patch
* backlight-s6e63m0-reorder-inclusions-of-linux-xxxh.patch
* backlight-ams369fg06-use-sleep-instead-of-delay.patch
* backlight-ams369fg06-remove-unnecessary-null-deference-check.patch
* backlight-ams369fg06-replace-efault-with-einval.patch
* backlight-ams369fg06-remove-redundant-variable-before_power.patch
* backlight-ams369fg06-reorder-inclusions-of-linux-xxxh.patch
* backlight-add-new-lp8788-backlight-driver.patch
* backlight-add-new-lp8788-backlight-driver-checkpatch-fixes.patch
* backlight-l4f00242t03-use-spi_get_drvdata-and-spi_set_drvdata.patch
* backlight-ld9040-use-spi_get_drvdata-and-spi_set_drvdata.patch
* backlight-s6e63m0-use-spi_get_drvdata-and-spi_set_drvdata.patch
* backlight-ltv350qv-use-spi_get_drvdata-and-spi_set_drvdata.patch
* backlight-tdo24m-use-spi_get_drvdata-and-spi_set_drvdata.patch
* backlight-lms283gf05-use-spi_get_drvdata-and-spi_set_drvdata.patch
* backlight-ams369fg06-use-spi_get_drvdata-and-spi_set_drvdata.patch
* backlight-vgg2432a4-use-spi_get_drvdata-and-spi_set_drvdata.patch
* backlight-tosa-use-spi_get_drvdata-and-spi_set_drvdata.patch
* backlight-corgi_lcd-use-spi_get_drvdata-and-spi_set_drvdata.patch
* backlight-lms501kf03-use-spi_get_drvdata-and-spi_set_drvdata.patch
* backlight-aat2870-use-bl_get_data-instead-of-dev_get_drvdata.patch
* pwm_backlight-use-bl_get_data-instead-of-dev_get_drvdata.patch
* backlight-ams369fg06-use-bl_get_data-instead-of-dev_get_drvdata.patch
* backlight-corgi_lcd-use-bl_get_data-instead-of-dev_get_drvdata.patch
* backlight-tosa-use-bl_get_data-instead-of-dev_get_drvdata.patch
* backlight-omap1-use-bl_get_data-instead-of-dev_get_drvdata.patch
* backlight-corgi_lcd-use-lcd_get_data-instead-of-dev_get_drvdata.patch
* backlight-lm3649_backlight-remove-ret-=-eio-at-error-paths-of-probe.patch
* checkpatch-prefer-dev_level-to-dev_printkkern_level.patch
* checkpatch-warn-on-unnecessary-__devfoo-section-markings.patch
* epoll-support-for-disabling-items-and-a-self-test-app.patch
* binfmt_elfc-use-get_random_int-to-fix-entropy-depleting.patch
* drivers-rtc-dump-small-buffers-via-%ph.patch
* drivers-rtc-rtc-pxac-fix-alarm-not-match-issue.patch
* drivers-rtc-rtc-pxac-fix-alarm-cant-wake-up-system-issue.patch
* drivers-rtc-rtc-pxac-fix-set-time-sync-time-issue.patch
* rtc-ds1307-long-block-operations-bugfix.patch
* rtc-ds1307-long-block-operations-bugfix-fix.patch
* rtc-max77686-add-maxim-77686-driver.patch
* rtc-max77686-add-maxim-77686-driver-fix.patch
* rtc-pcf8523-add-low-battery-voltage-support.patch
* rtc-pcf8523-add-low-battery-voltage-support-fix.patch
* drivers-rtc-use-of_match_ptr-macro.patch
* drivers-rtc-rtc-pxac-avoid-cpuid-checking.patch
* drivers-rtc-remove-unnecessary-semicolons.patch
* rtc-ds2404-use-module_platform_driver-macro.patch
* rtc-add-new-lp8788-rtc-driver.patch
* hfsplus-add-osx-prefix-for-handling-namespace-of-mac-os-x-extended-attributes.patch
* hfsplus-add-on-disk-layout-declarations-related-to-attributes-tree.patch
* hfsplus-add-functionality-of-manipulating-by-records-in-attributes-tree.patch
* hfsplus-rework-functionality-of-getting-setting-and-deleting-of-extended-attributes.patch
* hfsplus-add-support-of-manipulation-by-attributes-file.patch
* fat-add-extended-fileds-to-struct-fat_boot_sector.patch
* fat-mark-fs-as-dirty-on-mount-and-clean-on-umount.patch
* documentation-dma-api-howtotxt-minor-grammar-corrections.patch
* documentation-cgroups-blkio-controllertxt-fix-typo.patch
* fork-unshare-remove-dead-code.patch
* kexec-add-the-values-related-to-buddy-system-for-filtering-free-pages.patch
* ipc-semc-alternatives-to-preempt_disable.patch
* drivers-char-miscc-misc_register-do-not-loop-on-misc_list-unconditionally.patch
* drivers-char-miscc-misc_register-do-not-loop-on-misc_list-unconditionally-fix.patch
* mtd-mtd_nandecctest-use-prandom_bytes-instead-of-get_random_bytes.patch
* mtd-mtd_oobtest-convert-to-use-prandom-library.patch
* mtd-mtd_pagetest-convert-to-use-prandom-library.patch
* mtd-mtd_speedtest-use-prandom_bytes.patch
* mtd-mtd_subpagetest-convert-to-use-prandom-library.patch
* mtd-mtd_stresstest-use-prandom_bytes.patch
* dma-debug-new-interfaces-to-debug-dma-mapping-errors-fix-fix.patch
* w1-add-support-for-ds2413-dual-channel-addressable-switch.patch
* mm-remove-old-aio-use_mm-comment.patch
* aio-remove-dead-code-from-aioh.patch
* gadget-remove-only-user-of-aio-retry.patch
* aio-remove-retry-based-aio.patch
* char-add-aio_readwrite-to-dev-nullzero.patch
* aio-kill-return-value-of-aio_complete.patch
* aio-kiocb_cancel.patch
* aio-kiocb_cancel-fix.patch
* aio-move-private-stuff-out-of-aioh.patch
* aio-dprintk-pr_debug.patch
* aio-do-fget-after-aio_get_req.patch
* aio-make-aio_put_req-lockless.patch
* aio-refcounting-cleanup.patch
* wait-add-wait_event_hrtimeout.patch
* wait-add-wait_event_hrtimeout-fix.patch
* aio-make-aio_read_evt-more-efficient-convert-to-hrtimers.patch
* aio-use-flush_dcache_page.patch
* aio-use-cancellation-list-lazily.patch
* aio-change-reqs_active-to-include-unreaped-completions.patch
* aio-kill-batch-allocation.patch
* aio-kill-struct-aio_ring_info.patch
* aio-give-shared-kioctx-fields-their-own-cachelines.patch
* aio-give-shared-kioctx-fields-their-own-cachelines-fix.patch
* aio-reqs_active-reqs_available.patch
* aio-percpu-reqs_available.patch
* generic-dynamic-per-cpu-refcounting.patch
* generic-dynamic-per-cpu-refcounting-fix.patch
* aio-percpu-ioctx-refcount.patch
* aio-use-xchg-instead-of-completion_lock.patch
* aio-dont-include-aioh-in-schedh.patch
* aio-dont-include-aioh-in-schedh-fix.patch
* aio-dont-include-aioh-in-schedh-fix-fix.patch
* aio-dont-include-aioh-in-schedh-fix-3.patch
* aio-kill-ki_key.patch
* aio-kill-ki_retry.patch
* block-aio-batch-completion-for-bios-kiocbs.patch
* block-aio-batch-completion-for-bios-kiocbs-fix.patch
* virtio-blk-convert-to-batch-completion.patch
* mtip32xx-convert-to-batch-completion.patch
* aio-smoosh-struct-kiocb.patch
* aio-smoosh-struct-kiocb-fix.patch
  debugging-keep-track-of-page-owners.patch
  debugging-keep-track-of-page-owners-fix.patch
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
