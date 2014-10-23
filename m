Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id D2A4A6B0071
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 19:27:09 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id lj1so2003563pab.4
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 16:27:09 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ey1si1329568pbc.18.2014.10.23.16.27.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Oct 2014 16:27:08 -0700 (PDT)
Date: Thu, 23 Oct 2014 16:27:08 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2014-10-23-16-26 uploaded
Message-ID: <54498ecc.hhvSv+WUtdCJvPHX%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz

The mm-of-the-moment snapshot 2014-10-23-16-26 has been uploaded to

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


This mmotm tree contains the following patches against 3.18-rc1:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
* cgroup-kmemleak-add-kmemleak_free-for-cgroup-deallocations.patch
* mm-compaction-avoid-premature-range-skip-in-isolate_migratepages_range.patch
* fsnotify-next_i-is-freed-during-fsnotify_unmount_inodes.patch
* gcov-add-arm64-to-gcov_profile_all.patch
* mm-free-compound-page-with-correct-order.patch
* drivers-of-add-return-value-to-of_reserved_mem_device_init.patch
* mm-thp-fix-collapsing-of-hugepages-on-madvise.patch
* rtc-pm8xxx-rework-to-support-pm8941-rtc.patch
* rtc-pm8xxx-rework-to-support-pm8941-rtc-checkpatch-fixes.patch
* rtc-pm8xxx-rework-to-support-pm8941-rtc-fix.patch
* kernel-kmod-fix-use-after-free-of-the-sub_info-structure.patch
* kernel-kmod-fix-use-after-free-of-the-sub_info-structure-v2.patch
* drivers-rtc-fix-s3c-rtc-initialization-failure-without-rtc-source-clock.patch
* memory-hotplug-clear-pgdat-which-is-allocated-by-bootmem-in-try_offline_node.patch
* memory-hotplug-clear-pgdat-which-is-allocated-by-bootmem-in-try_offline_node-v2.patch
* rtc-bq3000-fix-register-value.patch
* bitmap-fix-undefined-shift-in-__bitmap_shift_leftright.patch
* mm-page-writeback-inline-account_page_dirtied-into-single-caller.patch
* mm-memcontrol-fix-missed-end-writeback-page-accounting.patch
* mm-memcontrol-fix-missed-end-writeback-page-accounting-fix.patch
* mm-rmap-split-out-page_remove_file_rmap.patch
* ocfs2-fix-d_splice_alias-return-code-checking.patch
* mm-slab_common-dont-check-for-duplicate-cache-names.patch
* mm-cma-make-kmemleak-ignore-cma-regions.patch
* mm-cma-make-kmemleak-ignore-cma-regions-fix.patch
* mm-cma-make-kmemleak-ignore-cma-regions-fix-fix.patch
* fs-cifs-remove-obsolete-__constant.patch
* fs-cifs-filec-replace-countsize-kzalloc-by-kcalloc.patch
* fs-cifs-smb2filec-replace-countsize-kzalloc-by-kcalloc.patch
* fallocate-create-fan_modify-and-in_modify-events.patch
* kernel-posix-timersc-code-clean-up.patch
* kernel-posix-timersc-code-clean-up-checkpatch-fixes.patch
* input-route-kbd-leds-through-the-generic-leds-layer.patch
* input-route-kbd-leds-through-the-generic-leds-layer-fix.patch
* input-route-kbd-leds-through-the-generic-leds-layer-fix-2.patch
* fs-ext4-fsyncc-generic_file_fsync-call-based-on-barrier-flag.patch
* ocfs2-dlm-let-sender-retry-if-dlm_dispatch_assert_master-failed-with-enomem.patch
* ocfs2-fix-an-off-by-one-bug_on-statement.patch
* ocfs2-fix-xattr-check-in-ocfs2_get_xattr_nolock.patch
* ocfs2-remove-bogus-test-from-ocfs2_read_locked_inode.patch
* ocfs2-report-error-from-o2hb_do_disk_heartbeat-to-user.patch
* ocfs2-remove-pointless-assignment-in-ocfs2_init.patch
* o2dlm-fix-null-pointer-dereference-in-o2dlm_blocking_ast_wrapper.patch
* o2dlm-fix-null-pointer-dereference-in-o2dlm_blocking_ast_wrapper-checkpatch-fixes.patch
* ocfs2-free-inode-when-i_count-becomes-zero.patch
* ocfs2-call-ocfs2_journal_access_di-before-ocfs2_journal_dirty-in-ocfs2_write_end_nolock.patch
* ocfs2-avoid-access-invalid-address-when-read-o2dlm-debug-messages.patch
* ocfs2-avoid-access-invalid-address-when-read-o2dlm-debug-messages-v2.patch
* ocfs2-dlm-fix-race-between-dispatched_work-and-dlm_lockres_grab_inflight_worker.patch
* ocfs2-reflink-fix-slow-unlink-for-refcounted-file.patch
* ocfs2-fix-journal-commit-deadlock.patch
* ocfs2-eliminate-the-static-flag-of-some-functions.patch
* ocfs2-add-two-functions-of-add-and-remove-inode-in-orphan-dir.patch
* ocfs2-add-orphan-recovery-types-in-ocfs2_recover_orphans.patch
* ocfs2-add-and-remove-inode-in-orphan-dir-in-ocfs2_direct_io.patch
* ocfs2-add-and-remove-inode-in-orphan-dir-in-ocfs2_direct_io-fix.patch
* ocfs2-allocate-blocks-in-ocfs2_direct_io_get_blocks.patch
* ocfs2-do-not-fallback-to-buffer-i-o-write-if-appending.patch
* ocfs2-do-not-fallback-to-buffer-i-o-write-if-fill-holes.patch
* ocfs2-do-not-fallback-to-buffer-i-o-write-if-fill-holes-checkpatch-fixes.patch
* bio-modify-__bio_add_page-to-accept-pages-that-dont-start-a-new-segment.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
  mm.patch
* cpuset-convert-callback_mutex-to-a-spinlock.patch
* cpuset-simplify-cpuset_node_allowed-api.patch
* slab-fix-cpuset-check-in-fallback_alloc.patch
* slub-fix-cpuset-check-in-get_any_partial.patch
* mm-slab-slub-coding-style-whitespaces-and-tabs-mixture.patch
* mm-memcontrol-lockless-page-counters.patch
* mm-memcontrol-lockless-page-counters-fix.patch
* mm-memcontrol-lockless-page-counters-fix-fix.patch
* mm-memcontrol-lockless-page-counters-fix-2.patch
* mm-hugetlb_cgroup-convert-to-lockless-page-counters.patch
* kernel-res_counter-remove-the-unused-api.patch
* kernel-res_counter-remove-the-unused-api-fix.patch
* kernel-res_counter-remove-the-unused-api-fix-2.patch
* mm-memcontrol-convert-reclaim-iterator-to-simple-css-refcounting.patch
* mm-memcontrol-convert-reclaim-iterator-to-simple-css-refcounting-fix.patch
* mm-memcontrol-take-a-css-reference-for-each-charged-page.patch
* mm-memcontrol-remove-obsolete-kmemcg-pinning-tricks.patch
* mm-memcontrol-continue-cache-reclaim-from-offlined-groups.patch
* mm-memcontrol-remove-synchroneous-stock-draining-code.patch
* mm-page_alloc-convert-boot-printks-without-log-level-to-pr_info.patch
* vmalloc-replace-printk-with-pr_warn.patch
* vmscan-replace-printk-with-pr_err.patch
* mm-introduce-single-zone-pcplists-drain.patch
* mm-page_isolation-drain-single-zone-pcplists.patch
* mm-cma-drain-single-zone-pcplists.patch
* mm-memory_hotplug-failure-drain-single-zone-pcplists.patch
* cma-make-default-cma-area-size-zero-for-x86.patch
* mm-verify-compound-order-when-freeing-a-page.patch
* mm-vmscan-count-only-dirty-pages-as-congested.patch
* mm-compaction-pass-classzone_idx-and-alloc_flags-to-watermark-checking.patch
* mm-compaction-simplify-deferred-compaction.patch
* mm-compaction-simplify-deferred-compaction-fix.patch
* mm-compaction-defer-only-on-compact_complete.patch
* mm-compaction-always-update-cached-scanner-positions.patch
* mm-compaction-more-focused-lru-and-pcplists-draining.patch
* mm-numa-balancing-rearrange-kconfig-entry.patch
* memcg-simplify-unreclaimable-groups-handling-in-soft-limit-reclaim.patch
* mm-memcontrol-update-mem_cgroup_page_lruvec-documentation.patch
* mm-memcontrol-clarify-migration-where-old-page-is-uncharged.patch
* memcg-remove-activate_kmem_mutex.patch
* mm-memcontrol-micro-optimize-mem_cgroup_split_huge_fixup.patch
* mm-memcontrol-uncharge-pages-on-swapout.patch
* mm-memcontrol-uncharge-pages-on-swapout-fix.patch
* mm-memcontrol-remove-unnecessary-pcg_memsw-memoryswap-charge-flag.patch
* mm-memcontrol-remove-unnecessary-pcg_mem-memory-charge-flag.patch
* mm-memcontrol-remove-unnecessary-pcg_used-pc-mem_cgroup-valid-flag.patch
* mm-memcontrol-remove-unnecessary-pcg_used-pc-mem_cgroup-valid-flag-fix.patch
* mm-memcontrol-inline-memcg-move_lock-locking.patch
* mm-memcontrol-dont-pass-a-null-memcg-to-mem_cgroup_end_move.patch
* mm-memcontrol-fold-mem_cgroup_start_move-mem_cgroup_end_move.patch
* mm-memcontrol-fold-mem_cgroup_start_move-mem_cgroup_end_move-fix.patch
* mm-hugetlb-correct-bit-shift-in-hstate_sizelog.patch
* mm-cma-split-cma-reserved-in-dmesg-log.patch
* fs-proc-include-cma-info-in-proc-meminfo.patch
* lib-show_mem-this-patch-adds-cma-reserved-infromation.patch
* lib-show_mem-this-patch-adds-cma-reserved-infromation-fix.patch
* mm-cma-use-%pa-to-avoid-truncating-the-physical-address.patch
* memcg-remove-mem_cgroup_reclaimable-check-from-soft-reclaim.patch
* mm-memcontrol-do-not-filter-reclaimable-nodes-in-numa-round-robin.patch
* mm-introduce-do_shared_fault-and-drop-do_fault-fix-fix.patch
* fs-mpagec-forgotten-write_sync-in-case-of-data-integrity-write.patch
* zsmalloc-merge-size_class-to-reduce-fragmentation.patch
* zram-remove-bio-parameter-from-zram_bvec_rw.patch
* zram-change-parameter-from-vaild_io_request.patch
* zram-implement-rw_page-operation-of-zram.patch
* mm-zbud-init-user-ops-only-when-it-is-needed.patch
* do_shared_fault-check-that-mmap_sem-is-held.patch
* security-smack-replace-kzalloc-with-kmem_cache-for-inode_smack.patch
* fs-proc-use-a-rb-tree-for-the-directory-entries.patch
* fs-proc-use-a-rb-tree-for-the-directory-entries-fix.patch
* procfs-fix-error-handling-of-proc_register.patch
* ia64-trivial-replace-get_unused_fd-by-get_unused_fd_flags0.patch
* ppc-cell-trivial-replace-get_unused_fd-by-get_unused_fd_flags0.patch
* binfmt_misc-trivial-replace-get_unused_fd-by-get_unused_fd_flags0.patch
* file-trivial-replace-get_unused_fd-by-get_unused_fd_flags0.patch
* file-remove-get_unused_fd-macro.patch
* drivers-misc-ti-st-st_corec-fix-null-dereference-on-protocol-type-check.patch
* lib-vsprintf-add-%pt-format-specifier.patch
* drivers-video-backlight-backlightc-remove-backlight-sysfs-uevent.patch
* mm-utilc-add-kstrimdup.patch
* lib-add-crc64-ecma-module.patch
* checkpatch-add-an-error-test-for-no-space-before-comma.patch
* checkpatch-add-error-on-use-of-attributeweak-or-__weak-declarations.patch
* checkpatch-improve-test-for-no-space-after-cast.patch
* checkpatch-improve-warning-message-for-needless-if-case.patch
* checkpatch-fix-use-via-symlink-make-missing-spelling-file-non-fatal.patch
* binfmt_misc-add-comments-debug-logs.patch
* binfmt_misc-clean-up-code-style-a-bit.patch
* init-allow-config_init_fallback=n-to-disable-defaults-if-init=-fails.patch
* init-allow-config_init_fallback=n-to-disable-defaults-if-init=-fails-checkpatch-fixes.patch
* init-remove-config_init_fallback.patch
* ncpfs-return-proper-error-from-ncp_ioc_setroot-ioctl.patch
* drivers-rtc-interfacec-check-the-validation-of-rtc_time-in-__rtc_read_time.patch
* rtc-omap-fix-clock-source-configuration.patch
* rtc-omap-fix-missing-wakealarm-attribute.patch
* rtc-omap-fix-interrupt-disable-at-probe.patch
* rtc-omap-clean-up-probe-error-handling.patch
* rtc-omap-fix-class-device-registration.patch
* rtc-omap-remove-unused-register-base-define.patch
* rtc-omap-use-dev_info.patch
* rtc-omap-make-platform-device-id-table-const.patch
* rtc-omap-add-device-abstraction.patch
* rtc-omap-remove-driver_name-macro.patch
* rtc-omap-add-structured-device-type-info.patch
* rtc-omap-silence-bogus-power-up-reset-message-at-probe.patch
* rtc-omap-add-helper-to-read-raw-bcd-time.patch
* rtc-omap-add-helper-to-read-32-bit-registers.patch
* rtc-omap-add-support-for-pmic_power_en.patch
* rtc-omap-enable-wake-up-from-power-off.patch
* rtc-omap-fix-minor-coding-style-issues.patch
* rtc-omap-add-copyright-entry.patch
* arm-dts-am33xx-update-rtc-node-compatible-property.patch
* arm-dts-am335x-boneblack-enable-power-off-and-rtc-wake-up.patch
* befs-remove-dead-code.patch
* hfsplus-fix-longname-handling.patch
* fat-add-fat_fallocate-operation.patch
* fat-skip-cluster-allocation-on-fallocated-region.patch
* fat-permit-to-return-phy-block-number-by-fibmap-in-fallocated-region.patch
* documentation-filesystems-vfattxt-update-the-limitation-for-fat-fallocate.patch
* usermodehelper-dont-use-clone_vfork-for-____call_usermodehelper.patch
* usermodehelper-kill-the-kmod_thread_locker-logic.patch
* kexec-remove-unnecessary-kern_err-from-kexecc.patch
* sysctl-terminate-strings-also-on-r.patch
* sysctl-terminate-strings-also-on-r-fix.patch
* gcov-enable-gcov_profile_all-from-arch-kconfigs.patch
* fs-affs-filec-forward-declaration-clean-up.patch
* fs-affs-amigaffsc-use-va_format-instead-of-buffer-vnsprintf.patch
* kgdb-timeout-if-secondary-cpus-ignore-the-roundup.patch
* ratelimit-add-initialization-macro.patch
* fault-inject-add-ratelimit-option-v2.patch
* make-initrd-compression-algorithm-selection-not-expert.patch
* decompress_bunzip2-off-by-one-in-get_next_block.patch
* ipc-semc-chance-memory-barrier-in-sem_lock-to-smp_rmb.patch
* ipc-semc-chance-memory-barrier-in-sem_lock-to-smp_rmb-fix.patch
* ipc-semc-chance-memory-barrier-in-sem_lock-to-smp_rmb-fix-fix.patch
* ipc-semc-increase-semmsl-semmni-semopm.patch
* ipc-msg-increase-msgmni-remove-scaling.patch
* ipc-msg-increase-msgmni-remove-scaling-checkpatch-fixes.patch
  linux-next.patch
* drivers-gpio-gpio-zevioc-fix-build.patch
* mm-replace-remap_file_pages-syscall-with-emulation.patch
* w1-call-put_device-if-device_register-fails.patch
* mm-add-strictlimit-knob-v2.patch
  debugging-keep-track-of-page-owners.patch
  debugging-keep-track-of-page-owners-fix.patch
  page-owners-correct-page-order-when-to-free-page.patch
  make-sure-nobodys-leaking-resources.patch
  journal_add_journal_head-debug.patch
  journal_add_journal_head-debug-fix.patch
  releasing-resources-with-children.patch
  make-frame_pointer-default=y.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  mutex-subsystem-synchro-test-module.patch
  slab-leaks3-default-y.patch
  add-debugging-aid-for-memory-initialisation-problems.patch
  workaround-for-a-pci-restoring-bug.patch
  single_open-seq_release-leak-diagnostics.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
