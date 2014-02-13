Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f49.google.com (mail-oa0-f49.google.com [209.85.219.49])
	by kanga.kvack.org (Postfix) with ESMTP id B41936B0031
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 15:32:04 -0500 (EST)
Received: by mail-oa0-f49.google.com with SMTP id i7so13359488oag.36
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 12:32:04 -0800 (PST)
Received: from mail-ob0-f201.google.com (mail-ob0-f201.google.com [209.85.214.201])
        by mx.google.com with ESMTPS id tk7si1850800obc.68.2014.02.13.12.32.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Feb 2014 12:32:03 -0800 (PST)
Received: by mail-ob0-f201.google.com with SMTP id gq1so2388125obb.2
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 12:32:03 -0800 (PST)
Subject: mmotm 2014-02-13-12-31 uploaded
From: akpm@linux-foundation.org
Date: Thu, 13 Feb 2014 12:32:02 -0800
Message-Id: <20140213203202.C10EC5A42D8@corp2gmr1-2.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

The mm-of-the-moment snapshot 2014-02-13-12-31 has been uploaded to

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


This mmotm tree contains the following patches against 3.14-rc2:
(patches marked "*" will be included in linux-next)

  origin.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  i-need-old-gcc.patch
* mm-page_alloc-make-first_page-visible-before-pagetail.patch
* mm-hwpoison-release-page-on-pagehwpoison-in-__do_fault.patch
* drivers-iommu-omap-iommu-debugc-fix-decimal-permissions.patch
* drivers-fmc-fmc-write-eepromc-fix-decimal-permissions.patch
* mm-thp-fix-infinite-loop-on-memcg-oom.patch
* memcg-change-oom_info_lock-to-mutex.patch
* ipcmqueue-remove-limits-for-the-amount-of-system-wide-queues.patch
* arm-mm-fix-the-memblock-allocation-for-lpae-machines.patch
* kthread-ensure-locality-of-task_struct-allocations.patch
* arm-use-generic-fixmaph.patch
* fs-cifs-cifsfsc-add-__init-to-cifs_init_inodecache.patch
* fanotify-remove-useless-bypass_perm-check.patch
* fanotify-use-fanotify-event-structure-for-permission-response-processing.patch
* fanotify-remove-useless-test-from-event-initialization.patch
* fanotify-convert-access_mutex-to-spinlock.patch
* fanotify-reorganize-loop-in-fanotify_read.patch
* fanotify-move-unrelated-handling-from-copy_event_to_user.patch
* sched_clock-document-4mhz-vs-1mhz-decision.patch
* input-route-kbd-leds-through-the-generic-leds-layer.patch
* jffs2-unlock-f-sem-on-error-in-jffs2_new_inode.patch
* jffs2-fix-unbalanced-locking.patch
* jffs2-avoid-soft-lockup-in-jffs2_reserve_space_gc.patch
* jffs2-remove-wait-queue-after-schedule.patch
* fs-udf-superc-add-__init-to-init_inodecache.patch
* drivers-net-irda-donauboe-convert-to-module_pci_driver.patch
* net-core-rtnetlinkc-copy-paste-error-in-rtnl_bridge_notify.patch
* ocfs2-fix-null-pointer-dereference-when-access-dlm_state-before-launching-dlm-thread.patch
* ocfs2-o2net-incorrect-to-terminate-accepting-connections-loop-upon-rejecting-an-invalid-one.patch
* ocfs2-fix-a-tiny-race-when-running-dirop_fileop_racer.patch
* ocfs2-o2net-o2net_listen_data_ready-should-do-nothing-if-socket-state-is-not-tcp_listen.patch
* ocfs2-should-call-ocfs2_journal_access_di-before-ocfs2_delete_entry-in-ocfs2_orphan_del.patch
* ocfs2-llseek-requires-ocfs2-inode-lock-for-the-file-in-seek_end.patch
* drivers-scsi-megaraid-megaraid_mmc-missing-bounds-check-in-mimd_to_kioc.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* kernel-watchdogc-touch_nmi_watchdog-should-only-touch-local-cpu-not-every-one.patch
* watchdog-trigger-all-cpu-backtrace-when-locked-up-and-going-to-panic.patch
* mm-slab-slub-use-page-list-consistently-instead-of-page-lru.patch
  mm.patch
* mm-vmscan-respect-numa-policy-mask-when-shrinking-slab-on-direct-reclaim.patch
* mm-vmscan-move-call-to-shrink_slab-to-shrink_zones.patch
* mm-vmscan-remove-shrink_control-arg-from-do_try_to_free_pages.patch
* mm-compaction-ignore-pageblock-skip-when-manually-invoking-compaction.patch
* mm-optimize-put_mems_allowed-usage.patch
* mm-hugetlb-unify-region-structure-handling.patch
* mm-hugetlb-improve-cleanup-resv_map-parameters.patch
* mm-hugetlb-fix-race-in-region-tracking.patch
* mm-hugetlb-remove-resv_map_put.patch
* mm-hugetlb-use-vma_resv_map-map-types.patch
* mm-hugetlb-improve-page-fault-scalability.patch
* mm-hugetlb-improve-page-fault-scalability-fix.patch
* mm-vmscan-shrink_slab-rename-max_pass-freeable.patch
* zram-drop-init_done-struct-zram-member.patch
* zram-do-not-pass-rw-argument-to-__zram_make_request.patch
* zram-remove-good-and-bad-compress-stats.patch
* zram-use-atomic64_t-for-all-zram-stats.patch
* zram-remove-zram-stats-code-duplication.patch
* zram-report-failed-read-and-write-stats.patch
* zram-drop-not-used-table-count-member.patch
* zram-move-zram-size-warning-to-documentation.patch
* zram-document-failed_reads-failed_writes-stats.patch
* mm-vmstat-fix-up-zone-state-accounting.patch
* mm-vmstat-fix-up-zone-state-accounting-fix.patch
* fs-cachefiles-use-add_to_page_cache_lru.patch
* lib-radix-tree-radix_tree_delete_item.patch
* mm-shmem-save-one-radix-tree-lookup-when-truncating-swapped-pages.patch
* mm-filemap-move-radix-tree-hole-searching-here.patch
* mm-fs-prepare-for-non-page-entries-in-page-cache-radix-trees.patch
* mm-fs-store-shadow-entries-in-page-cache.patch
* mm-thrash-detection-based-file-cache-sizing.patch
* lib-radix_tree-tree-node-interface.patch
* mm-keep-page-cache-radix-tree-nodes-in-check.patch
* mm-keep-page-cache-radix-tree-nodes-in-check-fix.patch
* mm-keep-page-cache-radix-tree-nodes-in-check-fix-fix.patch
* mm-keep-page-cache-radix-tree-nodes-in-check-fix-fix-fix.patch
* mm-hugetlb-mark-some-bootstrap-functions-as-__init.patch
* mm-compaction-avoid-isolating-pinned-pages.patch
* mm-compactionc-mark-function-as-static.patch
* mm-memoryc-mark-functions-as-static.patch
* mm-mmapc-mark-function-as-static.patch
* mm-process_vm_accessc-mark-function-as-static.patch
* mm-page_cgroupc-mark-functions-as-static.patch
* mm-nobootmemc-mark-function-as-static.patch
* include-linux-mmh-remove-ifdef-condition.patch
* mm-readaheadc-fix-readahead-fail-for-no-local-memory-and-limit-readahead-pages.patch
* pagewalk-update-page-table-walker-core.patch
* pagewalk-add-walk_page_vma.patch
* smaps-redefine-callback-functions-for-page-table-walker.patch
* clear_refs-redefine-callback-functions-for-page-table-walker.patch
* pagemap-redefine-callback-functions-for-page-table-walker.patch
* numa_maps-redefine-callback-functions-for-page-table-walker.patch
* memcg-redefine-callback-functions-for-page-table-walker.patch
* madvise-redefine-callback-functions-for-page-table-walker.patch
* arch-powerpc-mm-subpage-protc-use-walk_page_vma-instead-of-walk_page_range.patch
* pagewalk-remove-argument-hmask-from-hugetlb_entry.patch
* mempolicy-apply-page-table-walker-on-queue_pages_range.patch
* mm-rename-__do_fault-do_fault.patch
* mm-do_fault-extract-to-call-vm_ops-do_fault-to-separate-function.patch
* mm-introduce-do_read_fault.patch
* mm-introduce-do_cow_fault.patch
* mm-introduce-do_shared_fault-and-drop-do_fault.patch
* mm-consolidate-code-to-call-vm_ops-page_mkwrite.patch
* mm-consolidate-code-to-setup-pte.patch
* mm-thp-drop-do_huge_pmd_wp_zero_page_fallback.patch
* mm-remove-read_cache_page_async.patch
* drop_caches-add-some-documentation-and-info-message.patch
* mm-zswap-fix-trivial-typo-and-arrange-indentation.patch
* mm-zswap-update-zsmalloc-in-comment-to-zbud.patch
* include-linux-syscallsh-add-sys32_quotactl-prototype.patch
* include-linux-syscallsh-add-sys32_quotactl-prototype-fix.patch
* kernel-used-macros-from-compilerh-instead-of-__attribute__.patch
* asm-systemh-clean-asm-systemh-from-docs.patch
* asm-systemh-sparc-sparc_cpu_model-isnt-in-asm-systemh-any-more.patch
* asm-systemh-um-arch_align_stack-moved-to-asm-exech.patch
* asm-systemh-arm-delete-asm-systemh.patch
* kernel-audit-fix-non-modular-users-of-module_init-in-core-code.patch
* drivers-misc-ti-st-st_corec-fix-null-dereference-on-protocol-type-check.patch
* vsprintf-remove-%n-handling.patch
* lib-vsprintf-add-%pt-format-specifier.patch
* maintainers-add-backlight-co-maintainers.patch
* backlight-update-bd-state-fb_blank-properties-when-necessary.patch
* backlight-update-backlight-status-when-necessary.patch
* backlight-aat2870-remove-unnecessary-oom-messages.patch
* backlight-adp8860-remove-unnecessary-oom-messages.patch
* backlight-adp8870-remove-unnecessary-oom-messages.patch
* backlight-corgi_lcd-remove-unnecessary-oom-messages.patch
* backlight-hx8357-remove-unnecessary-oom-messages.patch
* backlight-ili922x-remove-unnecessary-oom-messages.patch
* backlight-ili9320-remove-unnecessary-oom-messages.patch
* backlight-l4f00242t03-remove-unnecessary-oom-messages.patch
* backlight-lm3533_bl-remove-unnecessary-oom-messages.patch
* backlight-lms283gf05-remove-unnecessary-oom-messages.patch
* backlight-platform_lcd-remove-unnecessary-oom-messages.patch
* backlight-tps65217_bl-remove-unnecessary-oom-messages.patch
* drivers-video-backlight-backlightc-remove-backlight-sysfs-uevent.patch
* lib-devresc-fix-some-sparse-warnings.patch
* mm-utilc-add-kstrimdup.patch
* lib-add-crc64-ecma-module.patch
* checkpatch-add-test-for-long-udelay.patch
* checkpatch-dont-warn-on-some-function-pointer-return-styles.patch
* checkpatch-add-checks-for-constant-non-octal-permissions.patch
* checkpatch-warn-on-uses-of-__constant_foo-functions.patch
* fs-efs-superc-add-__init-to-init_inodecache.patch
* binfmt_elfc-use-get_random_int-to-fix-entropy-depleting.patch
* init-do_mountsc-fix-comment-error.patch
* ncpfs-add-pr_fmt-and-convert-printks-to-pr_level.patch
* ncpfs-convert-dprintk-ddprintk-to-ncp_dbg.patch
* ncpfs-convert-dprintk-ddprintk-to-ncp_dbg-fix.patch
* ncpfs-convert-dprintk-ddprintk-to-ncp_dbg-fix-fix.patch
* ncpfs-convert-pprintk-to-ncp_vdbg.patch
* ncpfs-remove-now-unused-printk-macro.patch
* ncpfs-inode-fix-mismatch-printk-formats-and-arguments.patch
* rtc-rtc-imxdi-check-the-return-value-from-clk_prepare_enable.patch
* rtc-rtc-at32ap700x-remove-unnecessary-oom-messages.patch
* rtc-rtc-davinci-remove-unnecessary-oom-messages.patch
* rtc-rtc-ds1390-remove-unnecessary-oom-messages.patch
* rtc-rtc-moxart-remove-unnecessary-oom-messages.patch
* rtc-rtc-nuc900-remove-unnecessary-oom-messages.patch
* rtc-rtc-pm8xxx-remove-unnecessary-oom-messages.patch
* rtc-rtc-rx8025-remove-unnecessary-oom-messages.patch
* rtc-rtc-sirfsoc-remove-unnecessary-oom-messages.patch
* rtc-rtc-lpc32xx-remove-unnecessary-oom-messages.patch
* rtc-rtc-spear-remove-unnecessary-oom-messages.patch
* rtc-rtc-coh901331-use-devm_ioremap_resource.patch
* rtc-rtc-davinci-use-devm_ioremap_resource.patch
* rtc-rtc-vt8500-use-devm_ioremap_resource.patch
* rtc-rtc-jz4740-use-devm_ioremap_resource.patch
* drivers-rtc-rtc-isl12057c-remove-duplicate-include.patch
* drivers-rtc-rtc-da9052c-remove-redundant-private-structure-field.patch
* fs-minix-inodec-add-__init-to-init_inodecache.patch
* nilfs2-update-maintainers-file-entries.patch
* nilfs2-add-struct-nilfs_suinfo_update-and-flags.patch
* nilfs2-add-nilfs_sufile_set_suinfo-to-update-segment-usage.patch
* nilfs2-add-nilfs_sufile_set_suinfo-to-update-segment-usage-fix.patch
* nilfs2-implementation-of-nilfs_ioctl_set_suinfo-ioctl.patch
* nilfs2-implementation-of-nilfs_ioctl_set_suinfo-ioctl-fix.patch
* hfsplus-add-hfsx-subfolder-count-support.patch
* fs-ufs-superc-add-__init-to-init_inodecache.patch
* fs-ufs-remove-unused-ufs_super_block_first-pointer.patch
* fs-ufs-remove-unused-ufs_super_block_second-pointer.patch
* fs-ufs-remove-unused-ufs_super_block_third-pointer.patch
* ufs-sb-mutex-merge-mutex_destroy.patch
* fs-reiserfs-move-prototype-declaration-to-header-file.patch
* fat-add-i_disksize-to-represent-uninitialized-size.patch
* fat-add-fat_fallocate-operation.patch
* fat-zero-out-seek-range-on-_fat_get_block.patch
* fat-fallback-to-buffered-write-in-case-of-fallocated-region-on-direct-io.patch
* fat-permit-to-return-phy-block-number-by-fibmap-in-fallocated-region.patch
* fat-update-the-limitation-for-fat-fallocate.patch
* cpusets-allocate-heap-only-when-required.patch
* kmod-run-usermodehelpers-only-on-cpus-allowed-for-kthreadd-v2.patch
* kmod-run-usermodehelpers-only-on-cpus-allowed-for-kthreadd-v2-fix.patch
* kmod-run-usermodehelpers-only-on-cpus-allowed-for-kthreadd-v2-checkpatch-fixes.patch
* include-linux-crash_dumph-add-vmcore_cleanup-prototype.patch
* include-linux-crash_dumph-add-vmcore_cleanup-prototype-fix.patch
* fs-adfs-superc-add-__init-to-init_inodecache.patch
* kernel-panicc-display-reason-at-end-pr_emerg.patch
* kernel-panicc-display-reason-at-end-pr_emerg-fix.patch
* pps-add-non-blocking-option-to-pps_fetch-ioctl.patch
* drivers-misc-sgi-gru-grukdumpc-cleanup-gru_dump_context-a-little.patch
  linux-next.patch
  linux-next-git-rejects.patch
* drivers-spi-spic-fix-max-warning.patch
* w1-call-put_device-if-device_register-fails.patch
* arm-move-arm_dma_limit-to-setup_dma_zone.patch
* mm-add-strictlimit-knob-v2.patch
  debugging-keep-track-of-page-owners.patch
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
