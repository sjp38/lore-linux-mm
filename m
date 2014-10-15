Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 1884E6B0069
	for <linux-mm@kvack.org>; Wed, 15 Oct 2014 19:58:22 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id fp1so2118928pdb.35
        for <linux-mm@kvack.org>; Wed, 15 Oct 2014 16:58:21 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ge5si17333973pbc.3.2014.10.15.16.58.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Oct 2014 16:58:21 -0700 (PDT)
Date: Wed, 15 Oct 2014 16:58:20 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2014-10-15-16-57 uploaded
Message-ID: <543f0a1c.AmG8qX8YTuJY54NT%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz

The mm-of-the-moment snapshot 2014-10-15-16-57 has been uploaded to

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


This mmotm tree contains the following patches against 3.17:
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
* fs-cifs-remove-obsolete-__constant.patch
* fs-cifs-filec-replace-countsize-kzalloc-by-kcalloc.patch
* fs-cifs-smb2filec-replace-countsize-kzalloc-by-kcalloc.patch
* kernel-posix-timersc-code-clean-up.patch
* kernel-posix-timersc-code-clean-up-checkpatch-fixes.patch
* input-route-kbd-leds-through-the-generic-leds-layer.patch
* input-route-kbd-leds-through-the-generic-leds-layer-fix.patch
* input-route-kbd-leds-through-the-generic-leds-layer-fix-2.patch
* fs-ext4-fsyncc-generic_file_fsync-call-based-on-barrier-flag.patch
* ocfs2-dlm-let-sender-retry-if-dlm_dispatch_assert_master-failed-with-enomem.patch
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
* mm-memcontrol-lockless-page-counters.patch
* mm-memcontrol-lockless-page-counters-fix.patch
* mm-memcontrol-lockless-page-counters-fix-fix.patch
* mm-hugetlb_cgroup-convert-to-lockless-page-counters.patch
* kernel-res_counter-remove-the-unused-api.patch
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
* mm-update-generic-gup-implementation-to-handle-hugepage-directory.patch
* arch-powerpc-switch-to-generic-rcu-get_user_pages_fast.patch
* mm-verify-compound-order-when-freeing-a-page.patch
* mm-vmscan-count-only-dirty-pages-as-congested.patch
* mm-compaction-pass-classzone_idx-and-alloc_flags-to-watermark-checking.patch
* mm-compaction-simplify-deferred-compaction.patch
* mm-compaction-simplify-deferred-compaction-fix.patch
* mm-compaction-defer-only-on-compact_complete.patch
* mm-compaction-always-update-cached-scanner-positions.patch
* mm-compaction-more-focused-lru-and-pcplists-draining.patch
* mm-introduce-do_shared_fault-and-drop-do_fault-fix-fix.patch
* fs-mpagec-forgotten-write_sync-in-case-of-data-integrity-write.patch
* zsmalloc-merge-size_class-to-reduce-fragmentation.patch
* mm-zbud-init-user-ops-only-when-it-is-needed.patch
* do_shared_fault-check-that-mmap_sem-is-held.patch
* security-smack-replace-kzalloc-with-kmem_cache-for-inode_smack.patch
* freezer-check-oom-kill-while-being-frozen.patch
* freezer-remove-obsolete-comments-in-__thaw_task.patch
* oom-pm-oom-killed-task-cannot-escape-pm-suspend.patch
* fs-proc-use-a-rb-tree-for-the-directory-entries.patch
* fs-proc-use-a-rb-tree-for-the-directory-entries-fix.patch
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
* drivers-rtc-interfacec-check-the-validation-of-rtc_time-in-__rtc_read_time.patch
* rtc-pm8xxx-rework-to-support-pm8941-rtc.patch
* rtc-pm8xxx-rework-to-support-pm8941-rtc-checkpatch-fixes.patch
* hfsplus-fix-longname-handling.patch
* kexec-remove-unnecessary-kern_err-from-kexecc.patch
* kernel-sysctl-resolve-missing-field-initializers-warnings.patch
* fs-affs-filec-forward-declaration-clean-up.patch
* fs-affs-amigaffsc-use-va_format-instead-of-buffer-vnsprintf.patch
* kgdb-timeout-if-secondary-cpus-ignore-the-roundup.patch
* make-initrd-compression-algorithm-selection-not-expert.patch
* ipc-semc-chance-memory-barrier-in-sem_lock-to-smp_rmb.patch
* ipc-semc-chance-memory-barrier-in-sem_lock-to-smp_rmb-fix.patch
* ipc-semc-chance-memory-barrier-in-sem_lock-to-smp_rmb-fix-fix.patch
* ipc-semc-increase-semmsl-semmni-semopm.patch
* ipc-msg-increase-msgmni-remove-scaling.patch
* ipc-msg-increase-msgmni-remove-scaling-checkpatch-fixes.patch
  linux-next.patch
  linux-next-git-rejects.patch
* drivers-gpio-gpio-zevioc-fix-build.patch
* efi-bgrt-add-error-handling-inform-the-user-when-ignoring-the-bgrt.patch
* maintainers-update-santosh-shilimkars-email-id.patch
* fat-add-i_disksize-to-represent-uninitialized-size.patch
* fat-add-fat_fallocate-operation.patch
* fat-skip-cluster-allocation-on-fallocated-region.patch
* fat-permit-to-return-phy-block-number-by-fibmap-in-fallocated-region.patch
* documentation-filesystems-vfattxt-update-the-limitation-for-fat-fallocate.patch
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
