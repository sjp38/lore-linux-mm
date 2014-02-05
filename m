Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f44.google.com (mail-oa0-f44.google.com [209.85.219.44])
	by kanga.kvack.org (Postfix) with ESMTP id F05586B0035
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 18:57:21 -0500 (EST)
Received: by mail-oa0-f44.google.com with SMTP id g12so1427316oah.3
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 15:57:21 -0800 (PST)
Received: from mail-oa0-f74.google.com (mail-oa0-f74.google.com [209.85.219.74])
        by mx.google.com with ESMTPS id tm2si9522658oeb.146.2014.02.05.15.57.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Feb 2014 15:57:20 -0800 (PST)
Received: by mail-oa0-f74.google.com with SMTP id m1so353591oag.5
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 15:57:20 -0800 (PST)
Subject: mmotm 2014-02-05-15-56 uploaded
From: akpm@linux-foundation.org
Date: Wed, 05 Feb 2014 15:57:19 -0800
Message-Id: <20140205235719.A54A231C1DB@corp2gmr1-1.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

The mm-of-the-moment snapshot 2014-02-05-15-56 has been uploaded to

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


This mmotm tree contains the following patches against 3.14-rc1:
(patches marked "*" will be included in linux-next)

  origin.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  i-need-old-gcc.patch
* documentation-kernel-parameterstxt-fix-memmap=-language.patch
* ocfs2-free-allocated-clusters-if-error-occurs-after-ocfs2_claim_clusters.patch
* swap-add-a-simple-detector-for-inappropriate-swapin-readahead.patch
* mm-swap-fix-race-on-swap_info-reuse-between-swapoff-and-swapon.patch
* mm-__set_page_dirty_nobuffers-uses-spin_lock_irqseve-instead-of-spin_lock_irq.patch
* mm-__set_page_dirty-uses-spin_lock_irqsave-instead-of-spin_lock_irq.patch
* gru-unlocking-should-be-conditional-in-gru_dump_context.patch
* get_maintainer-fix-detection-of-git-repository.patch
* checkpatch-fix-detection-of-git-repository.patch
* documentation-update-00-index-files.patch
* drivers-message-i2o-i2o_configc-fix-deadlock-in-compat_ioctli2ogetiops.patch
* vmcore-prevent-pt_note-p_memsz-overflow-during-header-update.patch
* vmcore-prevent-pt_note-p_memsz-overflow-during-header-update-v2.patch
* vmcore-prevent-pt_note-p_memsz-overflow-during-header-update-v3.patch
* bcache-use-%zi-to-format-size_t.patch
* bcache-drop-l-suffix-when-comparing-ssize_t-with-0.patch
* mm-slub-list_lock-may-not-be-held-in-some-circumstances.patch
* xen-properly-account-for-_page_numa-during-xen-pte-translations.patch
* xen-properly-account-for-_page_numa-during-xen-pte-translations-fix.patch
* fs-filec-fdtable-avoid-triggering-ooms-from-alloc_fdmem.patch
* drivers-edac-edac_mc_sysfsc-poll-timeout-cannot-be-zero.patch
* mm-page_alloc-make-first_page-visible-before-pagetail.patch
* ocfs2-fix-ocfs2_sync_file-if-filesystem-is-readonly.patch
* ocfs2-fix-ocfs2_sync_file-if-filesystem-is-readonly-fix.patch
* arm-mm-fix-the-memblock-allocation-for-lpae-machines.patch
* numa-mem-hotplug-initialize-numa_kernel_nodes-in-numa_clear_kernel_node_hotplug.patch
* numa-mem-hotplug-fix-array-index-overflow-when-synchronizing-nid-to-memblockreserved.patch
* kthread-ensure-locality-of-task_struct-allocations.patch
* arm-use-generic-fixmaph.patch
* fanotify-remove-useless-bypass_perm-check.patch
* fanotify-use-fanotify-event-structure-for-permission-response-processing.patch
* fanotify-remove-useless-test-from-event-initialization.patch
* fanotify-convert-access_mutex-to-spinlock.patch
* fanotify-reorganize-loop-in-fanotify_read.patch
* fanotify-move-unrelated-handling-from-copy_event_to_user.patch
* sched_clock-document-4mhz-vs-1mhz-decision.patch
* input-route-kbd-leds-through-the-generic-leds-layer.patch
* jffs2-unlock-f-sem-on-error-in-jffs2_new_inode.patch
* drivers-net-irda-donauboe-convert-to-module_pci_driver.patch
* net-core-rtnetlinkc-copy-paste-error-in-rtnl_bridge_notify.patch
* ocfs2-o2net-incorrect-to-terminate-accepting-connections-loop-upon-rejecting-an-invalid-one.patch
* ocfs2-fix-a-tiny-race-when-running-dirop_fileop_racer.patch
* ocfs2-o2net-o2net_listen_data_ready-should-do-nothing-if-socket-state-is-not-tcp_listen.patch
* ocfs2-check-existence-of-old-dentry-in-ocfs2_link.patch
* ocfs2-should-call-ocfs2_journal_access_di-before-ocfs2_delete_entry-in-ocfs2_orphan_del.patch
* ocfs2-llseek-requires-ocfs2-inode-lock-for-the-file-in-seek_end.patch
* ocfs2-fix-issue-that-ocfs2_setattr-does-not-deal-with-new_i_size==i_size.patch
* ocfs2-update-inode-size-after-zeronig-the-hole.patch
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
* mm-hugetlb-mark-some-bootstrap-functions-as-__init.patch
* kernel-audit-fix-non-modular-users-of-module_init-in-core-code.patch
* drivers-misc-ti-st-st_corec-fix-null-dereference-on-protocol-type-check.patch
* vsprintf-remove-%n-handling.patch
* lib-vsprintf-add-%pt-format-specifier.patch
* backlight-update-bd-state-fb_blank-properties-when-necessary.patch
* backlight-update-backlight-status-when-necessary.patch
* drivers-video-backlight-backlightc-remove-backlight-sysfs-uevent.patch
* mm-utilc-add-kstrimdup.patch
* lib-add-crc64-ecma-module.patch
* checkpatch-add-test-for-long-udelay.patch
* binfmt_elfc-use-get_random_int-to-fix-entropy-depleting.patch
* rtc-rtc-imxdi-check-the-return-value-from-clk_prepare_enable.patch
* nilfs2-update-maintainers-file-entries.patch
* nilfs2-add-struct-nilfs_suinfo_update-and-flags.patch
* nilfs2-add-nilfs_sufile_set_suinfo-to-update-segment-usage.patch
* nilfs2-add-nilfs_sufile_set_suinfo-to-update-segment-usage-fix.patch
* nilfs2-implementation-of-nilfs_ioctl_set_suinfo-ioctl.patch
* nilfs2-implementation-of-nilfs_ioctl_set_suinfo-ioctl-fix.patch
* fs-ufs-superc-add-__init-to-init_inodecache.patch
* ufs-sb-mutex-merge-mutex_destroy.patch
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
* fs-adfs-superc-add-__init-to-init_inodecache.patch
* pps-add-non-blocking-option-to-pps_fetch-ioctl.patch
* drivers-misc-sgi-gru-grukdumpc-cleanup-gru_dump_context-a-little.patch
  linux-next.patch
* fs-udf-superc-add-__init-to-init_inodecache.patch
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
