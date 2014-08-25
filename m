Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f42.google.com (mail-oa0-f42.google.com [209.85.219.42])
	by kanga.kvack.org (Postfix) with ESMTP id 7D0976B0035
	for <linux-mm@kvack.org>; Mon, 25 Aug 2014 19:53:27 -0400 (EDT)
Received: by mail-oa0-f42.google.com with SMTP id n16so11387662oag.29
        for <linux-mm@kvack.org>; Mon, 25 Aug 2014 16:53:27 -0700 (PDT)
Received: from mail-ob0-f201.google.com (mail-ob0-f201.google.com [209.85.214.201])
        by mx.google.com with ESMTPS id yx3si828064obb.59.2014.08.25.16.53.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 25 Aug 2014 16:53:26 -0700 (PDT)
Received: by mail-ob0-f201.google.com with SMTP id va2so2235095obc.2
        for <linux-mm@kvack.org>; Mon, 25 Aug 2014 16:53:26 -0700 (PDT)
Date: Mon, 25 Aug 2014 16:53:25 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2014-08-25-16-52 uploaded
Message-ID: <53fbcc75.sRxDj9Tf9kSY0MiY%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz

The mm-of-the-moment snapshot 2014-08-25-16-52 has been uploaded to

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


This mmotm tree contains the following patches against 3.17-rc1:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  maintainers-akpm-maintenance.patch
* checkpatch-relax-check-for-length-of-git-commit-ids.patch
* resource-fix-the-case-of-null-pointer-access.patch
* memblock-memhotplug-fix-wrong-type-in-memblock_find_in_range_node.patch
* mm-actually-clear-pmd_numa-before-invalidating.patch
* lib-turn-config_stacktrace-into-an-actual-option.patch
* zram-fix-incorrectly-stat-with-failed_reads.patch
* mm-zpool-use-prefixed-module-loading.patch
* hugetlb_cgroup-use-lockdep_assert_held-rather-than-spin_is_locked.patch
* x86mm-fix-pte_special-versus-pte_numa.patch
* kexec-create-a-new-config-option-config_kexec_file-for-new-syscall.patch
* kexec-remove-config_kexec-dependency-on-crypto.patch
* xattr-fix-check-for-simultaneous-glibc-header-inclusion.patch
* rtc-s5m-re-add-support-for-devices-without-irq-specified.patch
* x86-purgatory-use-approprate-m64-32-build-flag-for-arch-x86-purgatory.patch
* ocfs2-do-not-write-error-flag-to-user-structure-we-cannot-copy-from-to.patch
* ocfs2-o2net-dont-shutdown-connection-when-idle-timeout.patch
* ocfs2-o2net-set-tcp-user-timeout-to-max-value.patch
* ocfs2-quorum-add-a-log-for-node-not-fenced.patch
* tools-selftests-fixing-build-issue-with-make-kselftests-target.patch
* flush_icache_range-export-symbol-to-fix-build-errors.patch
* add-arm-description-to-documentation-kdump-kdumptxt.patch
* purgatory-add-clean-up-for-purgatory-directory.patch
* mem-hotplug-let-memblock-skip-the-hotpluggable-memory-regions-in-__next_mem_range.patch
* mm-slab_commonc-suppress-warning.patch
* x86mem-hotplug-pass-sync_global_pgds-a-correct-argument-in-remove_pagetable.patch
* x86mem-hotplug-modify-pgd-entry-when-removing-memory.patch
* x86-numa-setup_node_data-drop-dead-code-and-rename-function.patch
* mem-hotplug-fix-boot-failed-in-case-all-the-nodes-are-hotpluggable.patch
* mem-hotplug-fix-boot-failed-in-case-all-the-nodes-are-hotpluggable-checkpatch-fixes.patch
* fs-cifs-remove-obsolete-__constant.patch
* fs-cifs-filec-replace-countsize-kzalloc-by-kcalloc.patch
* fs-cifs-smb2filec-replace-countsize-kzalloc-by-kcalloc.patch
* efi-bgrt-add-error-handling-inform-the-user-when-ignoring-the-bgrt.patch
* kernel-posix-timersc-code-clean-up.patch
* kernel-posix-timersc-code-clean-up-checkpatch-fixes.patch
* input-route-kbd-leds-through-the-generic-leds-layer.patch
* input-route-kbd-leds-through-the-generic-leds-layer-fix.patch
* fs-ext4-fsyncc-generic_file_fsync-call-based-on-barrier-flag.patch
* fs-ocfs2-stack_userc-fix-typo-in-ocfs2_control_release.patch
* o2dlm-fix-null-pointer-dereference-in-o2dlm_blocking_ast_wrapper.patch
* o2dlm-fix-null-pointer-dereference-in-o2dlm_blocking_ast_wrapper-checkpatch-fixes.patch
* ocfs2-free-inode-when-i_count-becomes-zero.patch
* ocfs2-call-ocfs2_journal_access_di-before-ocfs2_journal_dirty-in-ocfs2_write_end_nolock.patch
* ocfs2-avoid-access-invalid-address-when-read-o2dlm-debug-messages.patch
* ocfs2-dlm-fix-race-between-dispatched_work-and-dlm_lockres_grab_inflight_worker.patch
* ocfs2-reflink-fix-slow-unlink-for-refcounted-file.patch
* ocfs2-fix-journal-commit-deadlock.patch
* bio-integrity-remove-the-needless-fail-handle-of-bip_slab-creating.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
  mm.patch
* fix-checkpatch-errors-for-mm-mmapc.patch
* memory-hotplug-add-sysfs-zones_online_to-attribute.patch
* memory-hotplug-add-sysfs-zones_online_to-attribute-fix.patch
* memory-hotplug-add-sysfs-zones_online_to-attribute-fix-2.patch
* mm-remove-misleading-arch_uses_numa_prot_none.patch
* lib-genallocc-add-power-aligned-algorithm.patch
* lib-genallocc-add-genpool-range-check-function.patch
* common-dma-mapping-introduce-common-remapping-functions.patch
* arm-use-genalloc-for-the-atomic-pool.patch
* arm64-add-atomic-pool-for-non-coherent-and-cma-allocations.patch
* mm-page_alloc-determine-migratetype-only-once.patch
* vfs-make-guard_bh_eod-more-generic.patch
* vfs-guard-end-of-device-for-mpage-interface.patch
* block_dev-implement-readpages-to-optimize-sequential-read.patch
* mm-thp-dont-hold-mmap_sem-in-khugepaged-when-allocating-thp.patch
* mm-compaction-defer-each-zone-individually-instead-of-preferred-zone.patch
* mm-compaction-defer-each-zone-individually-instead-of-preferred-zone-fix.patch
* mm-compaction-do-not-count-compact_stall-if-all-zones-skipped-compaction.patch
* mm-compaction-do-not-recheck-suitable_migration_target-under-lock.patch
* mm-compaction-move-pageblock-checks-up-from-isolate_migratepages_range.patch
* mm-compaction-reduce-zone-checking-frequency-in-the-migration-scanner.patch
* mm-compaction-khugepaged-should-not-give-up-due-to-need_resched.patch
* mm-compaction-khugepaged-should-not-give-up-due-to-need_resched-fix.patch
* mm-compaction-periodically-drop-lock-and-restore-irqs-in-scanners.patch
* mm-compaction-skip-rechecks-when-lock-was-already-held.patch
* mm-compaction-remember-position-within-pageblock-in-free-pages-scanner.patch
* mm-compaction-skip-buddy-pages-by-their-order-in-the-migrate-scanner.patch
* mm-rename-allocflags_to_migratetype-for-clarity.patch
* mm-compaction-pass-gfp-mask-to-compact_control.patch
* mm-introduce-check_data_rlimit-helper-v2.patch
* mm-use-may_adjust_brk-helper.patch
* prctl-pr_set_mm-factor-out-mmap_sem-when-update-mm-exe_file.patch
* prctl-pr_set_mm-introduce-pr_set_mm_map-operation-v3.patch
* prctl-pr_set_mm-introduce-pr_set_mm_map-operation-v3-fix.patch
* vmstat-on-demand-vmstat-workers-v8.patch
* vmstat-on-demand-vmstat-workers-v8-fix.patch
* vmstat-on-demand-vmstat-workers-v8-do-not-open-code-alloc_cpumask_var.patch
* vmstat-on-demand-vmstat-workers-v8-fix-2.patch
* mm-introduce-do_shared_fault-and-drop-do_fault-fix-fix.patch
* fs-mpagec-forgotten-write_sync-in-case-of-data-integrity-write.patch
* m68k-call-find_vma-with-the-mmap_sem-held-in-sys_cacheflush.patch
* m68k-call-find_vma-with-the-mmap_sem-held-in-sys_cacheflush-v2.patch
* do_shared_fault-check-that-mmap_sem-is-held.patch
* include-kernelh-rewrite-min3-max3-and-clamp-using-min-and-max.patch
* include-kernelh-rewrite-min3-max3-and-clamp-using-min-and-max-fix.patch
* kernel-async-fixed-coding-style-issues.patch
* drivers-misc-ti-st-st_corec-fix-null-dereference-on-protocol-type-check.patch
* printk-dont-bother-using-log_cpu_max_buf_shift-on-smp.patch
* earlyprintk-re-enable-earlyprintk-calling-early_param.patch
* lib-vsprintf-add-%pt-format-specifier.patch
* maintainers-assing-systemace-driver-to-xilinx.patch
* remove-non-existent-files-from-maintainerspatch-added-to-mm-tree.patch
* maintainers-linaro-mm-sig-is-moderated.patch
* drivers-video-backlight-backlightc-remove-backlight-sysfs-uevent.patch
* mm-utilc-add-kstrimdup.patch
* lib-add-crc64-ecma-module.patch
* checkpatch-fix-spello.patch
* rtc-s3c-define-s3c_rtc-structure-to-remove-global-variables.patch
* rtc-s3c-define-s3c_rtc-structure-to-remove-global-variables-v2.patch
* rtc-s3c-remove-warning-message-when-checking-coding-style-with-checkpatch-script.patch
* rtc-s3c-add-s3c_rtc_data-structure-to-use-variant-data-instead-of-s3c_cpu_type.patch
* rtc-s3c-add-support-for-rtc-of-exynos3250-soc.patch
* arm-dts-fix-wrong-compatible-string-of-exynos3250-rtc-dt-node.patch
* fs-befs-btreec-remove-typedef-befs_btree_node.patch
* hfsplus-fix-longname-handling.patch
* fs-proc-task_mmuc-dont-use-task-mm-in-m_start-and-show_map.patch
* fs-proc-task_mmuc-unify-simplify-do_maps_open-and-numa_maps_open.patch
* proc-introduce-proc_mem_open.patch
* fs-proc-task_mmuc-shift-mm_access-from-m_start-to-proc_maps_open.patch
* fs-proc-task_mmuc-shift-mm_access-from-m_start-to-proc_maps_open-checkpatch-fixes.patch
* fs-proc-task_mmuc-simplify-the-vma_stop-logic.patch
* fs-proc-task_mmuc-simplify-the-vma_stop-logic-checkpatch-fixes.patch
* fs-proc-task_mmuc-cleanup-the-tail_vma-horror-in-m_next.patch
* fs-proc-task_mmuc-shift-priv-task-=-null-from-m_start-to-m_stop.patch
* fs-proc-task_mmuc-kill-the-suboptimal-and-confusing-m-version-logic.patch
* fs-proc-task_mmuc-simplify-m_start-to-make-it-readable.patch
* fs-proc-task_mmuc-introduce-m_next_vma-helper.patch
* fs-proc-task_mmuc-reintroduce-m-version-logic.patch
* fs-proc-task_mmuc-update-m-version-in-the-main-loop-in-m_start.patch
* fs-proc-task_nommuc-change-maps_open-to-use-__seq_open_private.patch
* fs-proc-task_nommuc-shift-mm_access-from-m_start-to-proc_maps_open.patch
* fs-proc-task_nommuc-shift-mm_access-from-m_start-to-proc_maps_open-checkpatch-fixes.patch
* fs-proc-task_nommuc-dont-use-priv-task-mm.patch
* kgdb-timeout-if-secondary-cpus-ignore-the-roundup.patch
* ipc-always-handle-a-new-value-of-auto_msgmni.patch
* build-trivia-scripts-headers_installsh.patch
  linux-next.patch
* drivers-gpio-gpio-zevioc-fix-build.patch
* x86-vdso-fix-vdso2cs-special_pages-error-checking.patch
* drivers-staging-unisys-fix-build.patch
* include-linux-remove-strict_strto-definitions.patch
* mm-replace-remap_file_pages-syscall-with-emulation.patch
* fat-add-i_disksize-to-represent-uninitialized-size-v4.patch
* fat-add-fat_fallocate-operation-v4.patch
* fat-zero-out-seek-range-on-_fat_get_block-v4.patch
* fat-fallback-to-buffered-write-in-case-of-fallocated-region-on-direct-io-v4.patch
* fat-permit-to-return-phy-block-number-by-fibmap-in-fallocated-region-v4.patch
* documentation-filesystems-vfattxt-update-the-limitation-for-fat-fallocate-v4.patch
* w1-call-put_device-if-device_register-fails.patch
* softlockup-make-detector-be-aware-of-task-switch-of-processes-hogging-cpu.patch
* watchdog-control-hard-lockup-detection-default.patch
* watchdog-control-hard-lockup-detection-default-fix.patch
* kvm-ensure-hard-lockup-detection-is-disabled-by-default.patch
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
