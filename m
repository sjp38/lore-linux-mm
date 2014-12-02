Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id B59B66B0038
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 18:56:40 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id eu11so14469690pac.36
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 15:56:40 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id hd2si35684115pac.185.2014.12.02.15.56.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Dec 2014 15:56:38 -0800 (PST)
Date: Tue, 02 Dec 2014 15:56:36 -0800
From: akpm@linux-foundation.org
Subject: mmotm 2014-12-02-15-55 uploaded
Message-ID: <547e51b4.z4E3IJk3dmE7Ynha%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz

The mm-of-the-moment snapshot 2014-12-02-15-55 has been uploaded to

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


This mmotm tree contains the following patches against 3.18-rc7:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
* mm-do-not-overwrite-reserved-pages-counter-at-show_mem.patch
* mm-frontswap-invalidate-expired-data-on-a-dup-store-failure.patch
* mm-vmpressurec-fix-race-in-vmpressure_work_fn.patch
* drivers-input-evdevc-dont-kfree-a-vmalloc-address.patch
* ipc-semc-fully-initialize-sem_array-before-making-it-visible.patch
* fat-fix-oops-on-corrupted-vfat-fs.patch
* mm-fix-swapoff-hang-after-page-migration-and-fork.patch
* mm-fix-anon_vma_clone-error-treatment.patch
* lib-genallocc-export-devm_gen_pool_create-for-modules.patch
* slab-fix-nodeid-bounds-check-for-non-contiguous-node-ids.patch
* fs-cifs-remove-obsolete-__constant.patch
* fs-cifs-filec-replace-countsize-kzalloc-by-kcalloc.patch
* fs-cifs-smb2filec-replace-countsize-kzalloc-by-kcalloc.patch
* dma-debug-introduce-dma_debug_disabled.patch
* dma-debug-prevent-early-callers-from-crashing.patch
* input-route-kbd-leds-through-the-generic-leds-layer.patch
* input-route-kbd-leds-through-the-generic-leds-layer-fix.patch
* input-route-kbd-leds-through-the-generic-leds-layer-fix-2.patch
* input-route-kbd-leds-through-the-generic-leds-layer-fix-3.patch
* scripts-kernel-doc-dont-eat-struct-members-with-__aligned.patch
* fs-ext4-fsyncc-generic_file_fsync-call-based-on-barrier-flag.patch
* ocfs2-dlm-let-sender-retry-if-dlm_dispatch_assert_master-failed-with-enomem.patch
* ocfs2-fix-an-off-by-one-bug_on-statement.patch
* ocfs2-fix-xattr-check-in-ocfs2_get_xattr_nolock.patch
* ocfs2-remove-bogus-test-from-ocfs2_read_locked_inode.patch
* ocfs2-report-error-from-o2hb_do_disk_heartbeat-to-user.patch
* o2dlm-fix-a-race-between-purge-and-master-query.patch
* ocfs2-o2net-fix-connect-expired.patch
* remove-filesize-checks-for-sync-i-o-journal-commit.patch
* ocfs2-fix-error-handling-when-creating-debugfs-root-in-ocfs2_init.patch
* ocfs2-do-not-set-ocfs2_lock_upconvert_finishing-if-nonblocking-lock-can-not-be-granted-at-once.patch
* ocfs2-do-not-set-filesystem-readonly-if-link-down.patch
* ocfs2-remove-bogus-null-check-in-ocfs2_move_extents.patch
* ocfs2-remove-unneeded-null-check.patch
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
* ocfs2-add-functions-to-add-and-remove-inode-in-orphan-dir.patch
* ocfs2-add-functions-to-add-and-remove-inode-in-orphan-dir-fix.patch
* ocfs2-add-orphan-recovery-types-in-ocfs2_recover_orphans.patch
* ocfs2-implement-ocfs2_direct_io_write.patch
* ocfs2-allocate-blocks-in-ocfs2_direct_io_get_blocks.patch
* ocfs2-do-not-fallback-to-buffer-i-o-write-if-appending.patch
* ocfs2-do-not-fallback-to-buffer-i-o-write-if-fill-holes.patch
* ocfs2-fix-leftover-orphan-entry-caused-by-append-o_direct-write-crash.patch
* bio-modify-__bio_add_page-to-accept-pages-that-dont-start-a-new-segment.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* char_dev-remove-pointless-assignment-from-__register_chrdev_region.patch
  mm.patch
* mm-slab-slub-coding-style-whitespaces-and-tabs-mixture.patch
* slab-print-slabinfo-header-in-seq-show.patch
* mm-slab-reverse-iteration-on-find_mergeable.patch
* mm-slub-fix-format-mismatches-in-slab_err-callers.patch
* slab-improve-checking-for-invalid-gfp_flags.patch
* slab-replace-smp_read_barrier_depends-with-lockless_dereference.patch
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
* mm-compaction-pass-classzone_idx-and-alloc_flags-to-watermark-checking-fix.patch
* mm-compaction-simplify-deferred-compaction.patch
* mm-compaction-simplify-deferred-compaction-fix.patch
* mm-compaction-defer-only-on-compact_complete.patch
* mm-compaction-always-update-cached-scanner-positions.patch
* mm-compaction-always-update-cached-scanner-positions-fix.patch
* mm-compaction-always-update-cached-scanner-positions-fix-checkpatch-fixes.patch
* mm-compaction-more-focused-lru-and-pcplists-draining.patch
* mm-compaction-more-focused-lru-and-pcplists-draining-fix.patch
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
* memcg-remove-mem_cgroup_reclaimable-check-from-soft-reclaim.patch
* memcg-use-generic-slab-iterators-for-showing-slabinfo.patch
* thp-do-not-mark-zero-page-pmd-write-protected-explicitly.patch
* mm-memcontrol-shorten-the-page-statistics-update-slowpath.patch
* mm-memcontrol-remove-bogus-null-check-after-mem_cgroup_from_task.patch
* mm-memcontrol-pull-the-null-check-from-__mem_cgroup_same_or_subtree.patch
* mm-memcontrol-drop-bogus-rcu-locking-from-mem_cgroup_same_or_subtree.patch
* mm-fix-huge-zero-page-accounting-in-smaps-report.patch
* mm-fix-huge-zero-page-accounting-in-smaps-report-fix.patch
* mm-fix-huge-zero-page-accounting-in-smaps-report-fix-2.patch
* mm-fix-huge-zero-page-accounting-in-smaps-report-fix-2-fix.patch
* mm-memcg-fix-potential-undefined-when-for-page-stat-accounting.patch
* mm-hugetlb-fix-__unmap_hugepage_range.patch
* mm-fix-a-spelling-mistake.patch
* frontswap-fix-the-condition-in-bug_on.patch
* mm-memcontrol-remove-stale-page_cgroup_lock-comment.patch
* mm-embed-the-memcg-pointer-directly-into-struct-page.patch
* mm-embed-the-memcg-pointer-directly-into-struct-page-fix.patch
* mm-page_cgroup-rename-file-to-mm-swap_cgroupc.patch
* mm-move-page-mem_cgroup-bad-page-handling-into-generic-code.patch
* mm-move-page-mem_cgroup-bad-page-handling-into-generic-code-fix.patch
* mm-move-page-mem_cgroup-bad-page-handling-into-generic-code-fix-2.patch
* mmfs-introduce-helpers-around-the-i_mmap_mutex.patch
* mm-use-new-helper-functions-around-the-i_mmap_mutex.patch
* mm-convert-i_mmap_mutex-to-rwsem.patch
* mm-convert-i_mmap_mutex-to-rwsem-fix.patch
* mm-rmap-share-the-i_mmap_rwsem.patch
* uprobes-share-the-i_mmap_rwsem.patch
* mm-xip-share-the-i_mmap_rwsem.patch
* mm-memory-failure-share-the-i_mmap_rwsem.patch
* mm-nommu-share-the-i_mmap_rwsem.patch
* mm-memoryc-share-the-i_mmap_rwsem.patch
* lib-bitmap-added-alignment-offset-for-bitmap_find_next_zero_area.patch
* mm-cma-align-to-physical-address-not-cma-region-position.patch
* memcg-__mem_cgroup_free-remove-stale-disarm_static_keys-comment.patch
* memcg-dont-check-mm-in-__memcg_kmem_get_cachenewpage_charge.patch
* memcg-do-not-abuse-memcg_kmem_skip_account.patch
* memblock-refactor-functions-to-set-clear-memblock_hotplug.patch
* mm-page_isolation-check-pfn-validity-before-access.patch
* mm-page_allocc-__alloc_pages_nodemask-dont-alter-arg-gfp_mask.patch
* mm-debug-pagealloc-cleanup-page-guard-code.patch
* mm-rmap-calculate-page-offset-when-needed.patch
* mm-mincore-add-hwpoison-page-handle.patch
* mm-mincore-add-hwpoison-page-handle-checkpatch-fixes.patch
* ksm-replace-smp_read_barrier_depends-with-lockless_dereference.patch
* memcg-zap-kmem_account_flags.patch
* memcg-only-check-memcg_kmem_skip_account-in-__memcg_kmem_get_cache.patch
* memcg-turn-memcg_kmem_skip_account-into-a-bit-field.patch
* hugetlb-fix-hugepages=-entry-in-kernel-parameterstxt.patch
* hugetlb-alloc_bootmem_huge_page-use-is_aligned.patch
* hugetlb-hugetlb_register_all_nodes-add-__init-marker.patch
* mm-export-find_extend_vma-and-handle_mm_fault-for-driver-use.patch
* iommu-amd-use-handle_mm_fault-directly-v2.patch
* memory-hotplug-remove-redundant-call-of-page_to_pfn.patch
* mm-move-swp_entry_t-definition-to-include-linux-mm_typesh.patch
* mm-remove-the-useless-gfp-in-__memcg_kmem_get_cache.patch
* remove-unnecessary-is_valid_nodemask.patch
* include-linux-kmemleakh-needs-slabh.patch
* mm-gfp-escalatedly-define-gfp_highuser-and-gfp_highuser_movable.patch
* mm-support-madvisemadv_free.patch
* mm-support-madvisemadv_free-fix.patch
* x86-add-pmd_-for-thp.patch
* x86-add-pmd_-for-thp-fix.patch
* sparc-add-pmd_-for-thp.patch
* sparc-add-pmd_-for-thp-fix.patch
* powerpc-add-pmd_-for-thp.patch
* arm-add-pmd_mkclean-for-thp.patch
* arm64-add-pmd_-for-thp.patch
* mm-dont-split-thp-page-when-syscall-is-called.patch
* mm-dont-split-thp-page-when-syscall-is-called-fix.patch
* mm-dont-split-thp-page-when-syscall-is-called-fix-2.patch
* mm-page_ext-resurrect-struct-page-extending-code-for-debugging.patch
* mm-debug-pagealloc-prepare-boottime-configurable-on-off.patch
* mm-debug-pagealloc-make-debug-pagealloc-boottime-configurable.patch
* mm-debug-pagealloc-make-debug-pagealloc-boottime-configurable-fix.patch
* mm-nommu-use-alloc_pages_exact-rather-than-its-own-implementation.patch
* mm-nommu-use-alloc_pages_exact-rather-than-its-own-implementation-fix.patch
* stacktrace-introduce-snprint_stack_trace-for-buffer-output.patch
* mm-page_owner-keep-track-of-page-owners.patch
* mm-page_owner-correct-owner-information-for-early-allocated-pages.patch
* documentation-add-new-page_owner-document.patch
* mmvmacache-count-number-of-system-wide-flushes.patch
* mm-vmscan-invoke-slab-shrinkers-from-shrink_zone.patch
* fs-seq_file-fallback-to-vmalloc-instead-of-oom-kill-processes.patch
* fs-seq_file-fallback-to-vmalloc-instead-of-oom-kill-processes-fix.patch
* mm-oom-remove-gfp-helper-function.patch
* mm-unmapped-page-migration-avoid-unmapremap-overhead.patch
* mm-remove-the-highmem-zones-memmap-in-the-highmem-zone.patch
* oom-dont-assume-that-a-coredumping-thread-will-exit-soon.patch
* oom-kill-the-insufficient-and-no-longer-needed-pt_trace_exit-check.patch
* fix-memory-ordering-bug-in-mm-vmallocc.patch
* mm-introduce-do_shared_fault-and-drop-do_fault-fix-fix.patch
* fs-mpagec-forgotten-write_sync-in-case-of-data-integrity-write.patch
* zsmalloc-merge-size_class-to-reduce-fragmentation.patch
* zram-remove-bio-parameter-from-zram_bvec_rw.patch
* zram-change-parameter-from-vaild_io_request.patch
* zram-implement-rw_page-operation-of-zram.patch
* zram-implement-rw_page-operation-of-zram-fix.patch
* zram-implement-rw_page-operation-of-zram-fix-2.patch
* zram-implement-rw_page-operation-of-zram-fix-2-cleanup.patch
* zram-implement-rw_page-operation-of-zram-fix-3.patch
* zsmalloc-fix-zs_init-cpu-notifier-error-handling.patch
* zsmalloc-fix-zs_init-cpu-notifier-error-handling-fix-2.patch
* zsmalloc-fix-zs_init-cpu-notifier-error-handling-fix.patch
* zsmalloc-correct-fragile-_atomic-use.patch
* mm-zsmalloc-support-allocating-obj-with-size-of-zs_max_alloc_size.patch
* mm-zsmalloc-support-allocating-obj-with-size-of-zs_max_alloc_size-fix.patch
* mm-zram-correct-zram_zero-flag-bit-position.patch
* mm-zsmalloc-avoid-duplicate-assignment-of-prev_class.patch
* mm-zsmalloc-avoid-duplicate-assignment-of-prev_class-fix.patch
* mm-zsmalloc-allocate-exactly-size-of-struct-zs_pool.patch
* mm-zswap-add-__init-to-some-functions-in-zswap.patch
* mm-zswap-deletion-of-an-unnecessary-check-before-the-function-call-free_percpu.patch
* mm-zbud-init-user-ops-only-when-it-is-needed.patch
* do_shared_fault-check-that-mmap_sem-is-held.patch
* fs-proc-use-a-rb-tree-for-the-directory-entries.patch
* fs-proc-use-a-rb-tree-for-the-directory-entries-fix.patch
* procfs-fix-error-handling-of-proc_register.patch
* fs-proc-use-rb_entry_safe-instead-of-rb_entry.patch
* proc-task_state-read-cred-group_info-outside-of-task_lock.patch
* proc-task_state-deuglify-the-max_fds-calculation.patch
* proc-task_state-move-the-main-seq_printf-outside-of-rcu_read_lock.patch
* proc-task_state-ptrace_parent-doesnt-need-pid_alive-check.patch
* sched_show_task-fix-unsafe-usage-of-real_parent.patch
* exit-reparent-use-ptrace_entry-rather-than-sibling-for-exit_dead-tasks.patch
* exit-reparent-cleanup-the-changing-of-parent.patch
* exit-reparent-cleanup-the-changing-of-parent-fix.patch
* exit-reparent-cleanup-the-usage-of-reparent_leader.patch
* exit-ptrace-shift-reap-dead-code-from-exit_ptrace-to-forget_original_parent.patch
* ia64-trivial-replace-get_unused_fd-by-get_unused_fd_flags0.patch
* ppc-cell-trivial-replace-get_unused_fd-by-get_unused_fd_flags0.patch
* binfmt_misc-trivial-replace-get_unused_fd-by-get_unused_fd_flags0.patch
* file-trivial-replace-get_unused_fd-by-get_unused_fd_flags0.patch
* file-remove-get_unused_fd-macro.patch
* kernel-add-panic_on_warn.patch
* kernel-add-panic_on_warn-v7.patch
* kernel-add-panic_on_warn-v9.patch
* drivers-misc-ti-st-st_corec-fix-null-dereference-on-protocol-type-check.patch
* printk-remove-used-once-early_vprintk.patch
* tile-neaten-early_printk-uses.patch
* tile-use-pr_warn-instead-of-pr_warning.patch
* printk-add-and-use-loglevel_level-defines-for-kern_level-equivalents.patch
* printk-drop-logbuf_cpu-volatile-qualifier.patch
* lib-vsprintf-add-%pt-format-specifier.patch
* maintainers-update-ivtv-mailing-lists-as-subscriber-only.patch
* drivers-video-backlight-backlightc-remove-backlight-sysfs-uevent.patch
* mm-utilc-add-kstrimdup.patch
* lib-add-crc64-ecma-module.patch
* checkpatch-add-an-error-test-for-no-space-before-comma.patch
* checkpatch-add-error-on-use-of-attributeweak-or-__weak-declarations.patch
* checkpatch-improve-test-for-no-space-after-cast.patch
* checkpatch-improve-warning-message-for-needless-if-case.patch
* checkpatch-fix-use-via-symlink-make-missing-spelling-file-non-fatal.patch
* checkpatch-try-to-avoid-mask-and-shift-errors.patch
* checkpatch-reduce-maintainers-update-message-frequency.patch
* checkpatch-add-strict-test-for-function-pointer-calling-style.patch
* checkpatch-allow-certain-si-units-with-three-characters.patch
* checkpatch-add-strict-preference-for-defines-using-bitfoo.patch
* checkpatch-add-test-for-consecutive-string-fragments.patch
* checkpatch-add-strict-pointer-comparison-to-null-test.patch
* checkpatch-add-ability-to-fix-coalesce-string-fragments-on-multiple-lines.patch
* binfmt_misc-add-comments-debug-logs.patch
* binfmt_misc-clean-up-code-style-a-bit.patch
* fs-binfmt_miscc-use-gfp_kernel-instead-of-gfp_user.patch
* fs-binfmt_elfc-fix-internal-inconsistency-relating-to-vma-dump-size.patch
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
* rtc-omap-add-support-for-pmic_power_en-v3.patch
* rtc-omap-add-support-for-pmic_power_en-v3-fix.patch
* rtc-omap-add-support-for-pmic_power_en-v4.patch
* rtc-omap-enable-wake-up-from-power-off.patch
* rtc-omap-fix-minor-coding-style-issues.patch
* rtc-omap-add-copyright-entry.patch
* arm-dts-am33xx-update-rtc-node-compatible-property.patch
* arm-dts-am335x-boneblack-enable-power-off-and-rtc-wake-up.patch
* rtc-pcf8563-remove-leftover-code.patch
* rtc-pcf8563-fix-write-of-invalid-bits-to-st2-reg.patch
* rtc-pcf8563-fix-wrong-time-from-read_alarm.patch
* rtc-pcf8563-handle-consequeces-of-lacking-second-alarm-reg.patch
* rtc-pcf8563-save-battery-power.patch
* rtc-pcf8563-clear-expired-alarm-at-boot-time.patch
* drivers-rtc-rtc-sirfsocc-add-alarm_irq_enable-support.patch
* drivers-rtc-rtc-sirfsocc-add-alarm_irq_enable-support-fix.patch
* drivers-rtc-rtc-sirfsocc-replace-local_irq_disable-by-spin_lock_irq-for-smp-safety.patch
* rtc-ds1374-add-watchdog-support.patch
* rtc-ds1374-add-watchdog-support-checkpatch-fixes.patch
* rtc-ds1307-add-support-for-mcp7940x-chips.patch
* of-add-vendor-prefix-for-pericom-technology.patch
* rtc-rtc-isl12057-fix-masking-of-register-values.patch
* rtc-rtc-isl12057-add-support-for-century-bit.patch
* rtc-rtc-isl12057-add-proper-handling-of-oscillator-failure-bit.patch
* rtc-rtc-isl12057-fix-isil-vs-isl-naming-for-intersil.patch
* rtc-rtc-isl12057-report-error-code-upon-failure-in-dev_err-calls.patch
* rtc-rtc-isl12057-add-alarm-support-to-intersil-isl12057-rtc-driver.patch
* rtc-omap-drop-vendor-prefix-from-power-controller-dt-property.patch
* befs-remove-dead-code.patch
* nilfs2-avoid-duplicate-segment-construction-for-fsync.patch
* nilfs2-deletion-of-an-unnecessary-check-before-the-function-call-iput.patch
* nilfs2-fix-the-nilfs_iget-vs-nilfs_new_inode-races.patch
* hfsplus-fix-longname-handling.patch
* fat-add-fat_fallocate-operation.patch
* fat-skip-cluster-allocation-on-fallocated-region.patch
* fat-permit-to-return-phy-block-number-by-fibmap-in-fallocated-region.patch
* documentation-filesystems-vfattxt-update-the-limitation-for-fat-fallocate.patch
* fat-fix-data-past-eof-resulting-from-fsx-testsuite.patch
* fat-fix-data-past-eof-resulting-from-fsx-testsuite-v2.patch
* usermodehelper-dont-use-clone_vfork-for-____call_usermodehelper.patch
* usermodehelper-kill-the-kmod_thread_locker-logic.patch
* exit-wait-cleanup-the-ptrace_reparented-checks.patch
* exit-wait-cleanup-the-ptrace_reparented-checks-fix.patch
* exit-wait-dont-use-zombie-real_parent.patch
* exit-wait-drop-tasklist_lock-before-psig-c-accounting.patch
* exit-release_task-fix-the-comment-about-group-leader-accounting.patch
* exit-proc-dont-try-to-flush-proc-tgid-task-tgid.patch
* exit-reparent-fix-the-dead-parent-pr_set_child_subreaper-reparenting.patch
* exit-reparent-fix-the-cross-namespace-pr_set_child_subreaper-reparenting.patch
* exit-reparent-s-while_each_thread-for_each_thread-in-find_new_reaper.patch
* exit-reparent-document-the-has_child_subreaper-checks.patch
* exit-reparent-introduce-find_child_reaper.patch
* exit-reparent-introduce-find_alive_thread.patch
* exit-reparent-avoid-find_new_reaper-if-no-children.patch
* exit-reparent-call-forget_original_parent-under-tasklist_lock.patch
* exit-exit_notify-re-use-dead-list-to-autoreap-current.patch
* exit-pidns-alloc_pid-leaks-pid_namespace-if-child_reaper-is-exiting.patch
* exit-pidns-fix-update-the-comments-in-zap_pid_ns_processes.patch
* syscalls-implement-execveat-system-call.patch
* x86-hook-up-execveat-system-call.patch
* syscalls-add-selftest-for-execveat2.patch
* sparc-hook-up-execveat-system-call.patch
* sparc-hook-up-execveat-system-call-v10.patch
* kexec-remove-unnecessary-kern_err-from-kexecc.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* sysctl-terminate-strings-also-on-r.patch
* sysctl-terminate-strings-also-on-r-fix.patch
* gcov-enable-gcov_profile_all-from-arch-kconfigs.patch
* fs-affs-filec-forward-declaration-clean-up.patch
* fs-affs-amigaffsc-use-va_format-instead-of-buffer-vnsprintf.patch
* fs-affs-filec-adding-support-to-o_direct.patch
* fs-affs-filec-remove-obsolete-pagesize-check.patch
* ratelimit-add-initialization-macro.patch
* fault-inject-add-ratelimit-option-v2.patch
* make-initrd-compression-algorithm-selection-not-expert.patch
* decompress_bunzip2-off-by-one-in-get_next_block.patch
* lib-consistency-of-compress-formats-for-kernel-image.patch
* ipc-semc-chance-memory-barrier-in-sem_lock-to-smp_rmb.patch
* ipc-semc-chance-memory-barrier-in-sem_lock-to-smp_rmb-fix.patch
* ipc-semc-chance-memory-barrier-in-sem_lock-to-smp_rmb-fix-fix.patch
* ipc-semc-increase-semmsl-semmni-semopm.patch
* ipc-msg-increase-msgmni-remove-scaling.patch
* ipc-msg-increase-msgmni-remove-scaling-checkpatch-fixes.patch
* mm-fix-overly-aggressive-shmdt-when-calls-span-multiple-segments.patch
* shmdt-use-i_size_read-instead-of-i_size.patch
  linux-next.patch
  linux-next-rejects.patch
* drivers-gpio-gpio-zevioc-fix-build.patch
* slab-fix-cpuset-check-in-fallback_alloc.patch
* slub-fix-cpuset-check-in-get_any_partial.patch
* mm-cma-make-kmemleak-ignore-cma-regions.patch
* mm-cma-split-cma-reserved-in-dmesg-log.patch
* fs-proc-include-cma-info-in-proc-meminfo.patch
* lib-show_mem-this-patch-adds-cma-reserved-infromation.patch
* lib-show_mem-this-patch-adds-cma-reserved-infromation-fix.patch
* fallocate-create-fan_modify-and-in_modify-events.patch
* tools-testing-selftests-makefile-alphasort-the-targets-list.patch
* fsnotify-unify-inode-and-mount-marks-handling.patch
* fsnotify-remove-destroy_list-from-fsnotify_mark.patch
* remove-__get_cpu_var-and-__raw_get_cpu_var-macros.patch
* update-local_opstxt-to-reflect-this_cpu-operations.patch
* ia64-update-comment-that-references-__get_cpu_var.patch
* parisc-update-comments-refereing-to-__get_cpu_var.patch
* mm-replace-remap_file_pages-syscall-with-emulation.patch
* w1-call-put_device-if-device_register-fails.patch
* mm-add-strictlimit-knob-v2.patch
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
