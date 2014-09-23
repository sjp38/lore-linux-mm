Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 0DB886B0035
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 20:02:58 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fb1so5493486pad.13
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 17:02:58 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id gn1si17689758pbd.191.2014.09.22.17.02.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Sep 2014 17:02:57 -0700 (PDT)
Date: Mon, 22 Sep 2014 17:02:56 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2014-09-22-16-57 uploaded
Message-ID: <5420b8b0.9HdYLyyuTikszzH8%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz

The mm-of-the-moment snapshot 2014-09-22-16-57 has been uploaded to

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


This mmotm tree contains the following patches against 3.17-rc6:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  maintainers-akpm-maintenance.patch
* ocfs2-free-vol_lable-in-ocfs2_delete_osb.patch
* nilfs2-fix-data-loss-with-mmap.patch
* nilfs2-fix-data-loss-with-mmap-fix.patch
* ocfs2-dlm-do-not-get-resource-spinlock-if-lockres-is-new.patch
* mm-softdirty-addresses-before-vmas-in-pte-holes-arent-softdirty.patch
* mm-page_alloc-fix-zone-allocation-fairness-on-up.patch
* mn10300-use-kbuild-logic-to-include-asm-generic-sectionsh.patch
* cris-use-kbuild-logic-to-include-asm-generic-sectionsh.patch
* fs-cifs-remove-obsolete-__constant.patch
* fs-cifs-filec-replace-countsize-kzalloc-by-kcalloc.patch
* fs-cifs-smb2filec-replace-countsize-kzalloc-by-kcalloc.patch
* efi-bgrt-add-error-handling-inform-the-user-when-ignoring-the-bgrt.patch
* fs-notify-groupc-make-fsnotify_final_destroy_group-static.patch
* fsnotify-dont-put-user-context-if-it-was-never-assigned.patch
* kernel-posix-timersc-code-clean-up.patch
* kernel-posix-timersc-code-clean-up-checkpatch-fixes.patch
* input-route-kbd-leds-through-the-generic-leds-layer.patch
* input-route-kbd-leds-through-the-generic-leds-layer-fix.patch
* m32r-use-kbuild-logic-to-include-asm-generic-sectionsh.patch
* use-find_get_page_flags-to-mark-page-accessed-as-it-is-no-longer-marked-later-on.patch
* score-use-kbuild-logic-to-include-asm-generic-sectionsh.patch
* fs-ext4-fsyncc-generic_file_fsync-call-based-on-barrier-flag.patch
* fs-ocfs2-stack_userc-fix-typo-in-ocfs2_control_release.patch
* ocfs2-dlm-refactor-error-handling-in-dlm_alloc_ctxt.patch
* ocfs2-fix-shift-left-operations-overflow.patch
* ocfs2-call-o2quo_exit-if-malloc-failed-in-o2net_init.patch
* o2dlm-fix-null-pointer-dereference-in-o2dlm_blocking_ast_wrapper.patch
* o2dlm-fix-null-pointer-dereference-in-o2dlm_blocking_ast_wrapper-checkpatch-fixes.patch
* ocfs2-remove-unused-code-in-dlm_new_lockres.patch
* fs-ocfs2-dlm-dlmdebugc-use-seq_open_private-not-seq_open.patch
* fs-ocfs2-cluster-netdebugc-use-seq_open_private-not-seq_open.patch
* fs-ocfs2-dlmgluec-use-__seq_open_private-not-seq_open.patch
* ocfs2-dont-fire-quorum-before-connection-established.patch
* ocfs2-free-inode-when-i_count-becomes-zero.patch
* ocfs2-call-ocfs2_journal_access_di-before-ocfs2_journal_dirty-in-ocfs2_write_end_nolock.patch
* ocfs2-avoid-access-invalid-address-when-read-o2dlm-debug-messages.patch
* ocfs2-avoid-access-invalid-address-when-read-o2dlm-debug-messages-v2.patch
* ocfs2-dlm-fix-race-between-dispatched_work-and-dlm_lockres_grab_inflight_worker.patch
* ocfs2-reflink-fix-slow-unlink-for-refcounted-file.patch
* ocfs2-fix-journal-commit-deadlock.patch
* ocfs2-fix-deadlock-between-o2hb-thread-and-o2net_wq.patch
* ocfs2-fix-deadlock-due-to-wrong-locking-order.patch
* bio-integrity-remove-the-needless-fail-handle-of-bip_slab-creating.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* softlockup-make-detector-be-aware-of-task-switch-of-processes-hogging-cpu.patch
* softlockup-make-detector-be-aware-of-task-switch-of-processes-hogging-cpu-fix.patch
  mm.patch
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
* fs-proc-task_nommuc-change-maps_open-to-use-__seq_open_private-fix.patch
* fs-proc-task_nommuc-shift-mm_access-from-m_start-to-proc_maps_open.patch
* fs-proc-task_nommuc-shift-mm_access-from-m_start-to-proc_maps_open-checkpatch-fixes.patch
* fs-proc-task_nommuc-dont-use-priv-task-mm.patch
* proc-maps-replace-proc_maps_private-pid-with-struct-inode-inode.patch
* proc-maps-make-vm_is_stack-logic-namespace-friendly.patch
* not-adding-modules-range-to-kcore-if-its-equal-to-vmcore-range.patch
* not-adding-modules-range-to-kcore-if-its-equal-to-vmcore-range-checkpatch-fixes.patch
* mm-slab_commonc-suppress-warning.patch
* mm-slab_common-move-kmem_cache-definition-to-internal-header.patch
* mm-slab_common-move-kmem_cache-definition-to-internal-header-fix.patch
* mm-slab_common-move-kmem_cache-definition-to-internal-header-fix-2.patch
* mm-slab_common-move-kmem_cache-definition-to-internal-header-fix-2-fix.patch
* mm-slb-always-track-caller-in-kmalloc_node_track_caller.patch
* mm-slab-move-cache_flusharray-out-of-unlikelytext-section.patch
* mm-slab-noinline-__ac_put_obj.patch
* mm-slab-factor-out-unlikely-part-of-cache_free_alien.patch
* slub-disable-tracing-and-failslab-for-merged-slabs.patch
* topology-add-support-for-node_to_mem_node-to-determine-the-fallback-node.patch
* slub-fallback-to-node_to_mem_node-node-if-allocating-on-memoryless-node.patch
* partial-revert-of-81c98869faa5-kthread-ensure-locality-of-task_struct-allocations.patch
* slab-fix-for_each_kmem_cache_node.patch
* mm-slab_common-commonize-slab-merge-logic.patch
* mm-slab_common-commonize-slab-merge-logic-fix.patch
* mm-slab-support-slab-merge.patch
* mm-slab-use-percpu-allocator-for-cpu-cache.patch
* fix-checkpatch-errors-for-mm-mmapc.patch
* memory-hotplug-add-sysfs-zones_online_to-attribute.patch
* memory-hotplug-add-sysfs-zones_online_to-attribute-fix.patch
* memory-hotplug-add-sysfs-zones_online_to-attribute-fix-2.patch
* memory-hotplug-add-sysfs-zones_online_to-attribute-fix-3.patch
* memory-hotplug-add-sysfs-zones_online_to-attribute-fix-3-fix.patch
* memory-hotplug-add-sysfs-zones_online_to-attribute-fix-4.patch
* mm-remove-misleading-arch_uses_numa_prot_none.patch
* lib-genallocc-add-power-aligned-algorithm.patch
* lib-genallocc-add-genpool-range-check-function.patch
* common-dma-mapping-introduce-common-remapping-functions.patch
* common-dma-mapping-introduce-common-remapping-functions-fix.patch
* common-dma-mapping-introduce-common-remapping-functions-fix-2.patch
* common-dma-mapping-introduce-common-remapping-functions-fix-4.patch
* arm-use-genalloc-for-the-atomic-pool.patch
* arm64-add-atomic-pool-for-non-coherent-and-cma-allocations.patch
* mm-cma-adjust-address-limit-to-avoid-hitting-low-high-memory-boundary.patch
* arm-mm-dont-limit-default-cma-region-only-to-low-memory.patch
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
* prctl-pr_set_mm-introduce-pr_set_mm_map-operation-v4.patch
* prctl-pr_set_mm-introduce-pr_set_mm_map-operation-v3-fix.patch
* prctl-pr_set_mm-introduce-pr_set_mm_map-operation-v4-fix.patch
* prctl-pr_set_mm-introduce-pr_set_mm_map-operation-v4-fix-2.patch
* mm-remove-noisy-remainder-of-the-scan_unevictable-interface.patch
* mempolicy-change-alloc_pages_vma-to-use-mpol_cond_put.patch
* mempolicy-change-get_task_policy-to-return-default_policy-rather-than-null.patch
* mempolicy-sanitize-the-usage-of-get_task_policy.patch
* mempolicy-remove-the-task-arg-of-vma_policy_mof-and-simplify-it.patch
* mempolicy-introduce-__get_vma_policy-export-get_task_policy.patch
* mempolicy-fix-show_numa_map-vs-exec-do_set_mempolicy-race.patch
* mempolicy-kill-do_set_mempolicy-down_writemm-mmap_sem.patch
* mempolicy-unexport-get_vma_policy-and-remove-its-task-arg.patch
* include-linux-migrateh-remove-migratepage-define.patch
* mm-use-seq_open_private-instead-of-seq_open.patch
* mm-use-__seq_open_private-instead-of-seq_open.patch
* introduce-dump_vma.patch
* introduce-dump_vma-fix.patch
* introduce-dump_vma-fix-2.patch
* introduce-vm_bug_on_vma.patch
* convert-a-few-vm_bug_on-callers-to-vm_bug_on_vma.patch
* convert-a-few-vm_bug_on-callers-to-vm_bug_on_vma-checkpatch-fixes.patch
* mm-page_alloc-avoid-wakeup-kswapd-on-the-unintended-node.patch
* mm-use-min3-max3-macros-to-avoid-shadow-warnings.patch
* mm-clean-up-zone-flags.patch
* mm-mmapc-clean-up-config_debug_vm_rb-checks.patch
* mm-compaction-fix-warning-of-flags-may-be-used-uninitialized.patch
* mm-clear-__gfp_fs-when-pf_memalloc_noio-is-set.patch
* ocfs2-fix-a-deadlock-while-o2net_wq-doing-direct-memory-reclaim.patch
* mm-page_alloc-make-paranoid-check-in-move_freepages-a-vm_bug_on.patch
* mm-page_alloc-default-node-ordering-on-64-bit-numa-zone-ordering-on-32-bit-v2.patch
* mm-softdirty-enable-write-notifications-on-vmas-after-vm_softdirty-cleared.patch
* mm-softdirty-unmapped-addresses-between-vmas-are-clean.patch
* mm-softdirty-unmapped-addresses-between-vmas-are-clean-v2.patch
* mm-move-debug-code-out-of-page_allocc.patch
* mm-introduce-vm_bug_on_mm.patch
* mm-introduce-vm_bug_on_mm-checkpatch-fixes.patch
* mm-use-vm_bug_on_mm-where-possible.patch
* mm-debugc-use-pr_emerg.patch
* free-the-reserved-memblock-when-free-cma-pages.patch
* memcg-move-memcg_allocfree_cache_params-to-slab_commonc.patch
* memcg-dont-call-memcg_update_all_caches-if-new-cache-id-fits.patch
* memcg-move-memcg_update_cache_size-to-slab_commonc.patch
* mm-dmapool-add-remove-sysfs-file-outside-of-the-pool-lock-lock.patch
* mm-hugetlb-reduce-arch-dependent-code-around-follow_huge_.patch
* mm-hugetlb-take-page-table-lock-in-follow_huge_pmd.patch
* mm-hugetlb-fix-getting-refcount-0-page-in-hugetlb_fault.patch
* mm-hugetlb-add-migration-hwpoisoned-entry-check-in-hugetlb_change_protection.patch
* mm-hugetlb-add-migration-entry-check-in-__unmap_hugepage_range.patch
* vmstat-on-demand-vmstat-workers-v8.patch
* vmstat-on-demand-vmstat-workers-v8-fix.patch
* vmstat-on-demand-vmstat-workers-v8-do-not-open-code-alloc_cpumask_var.patch
* vmstat-on-demand-vmstat-workers-v8-fix-2.patch
* mm-introduce-do_shared_fault-and-drop-do_fault-fix-fix.patch
* fs-mpagec-forgotten-write_sync-in-case-of-data-integrity-write.patch
* m68k-call-find_vma-with-the-mmap_sem-held-in-sys_cacheflush.patch
* m68k-call-find_vma-with-the-mmap_sem-held-in-sys_cacheflush-v2.patch
* zsmalloc-move-pages_allocated-to-zs_pool.patch
* zsmalloc-change-return-value-unit-of-zs_get_total_size_bytes.patch
* zram-zram-memory-size-limitation.patch
* zram-zram-memory-size-limitation-fix.patch
* zram-zram-memory-size-limitation-fix-fix.patch
* zram-zram-memory-size-limitation-fix-2.patch
* zram-report-maximum-used-memory.patch
* zram-use-notify_free-to-account-all-free-notifications.patch
* mm-correct-comment-for-fullness-group-computation-in-zsmallocc.patch
* zsmalloc-simplify-init_zspage-free-obj-linking.patch
* zbud-avoid-accessing-in-last-unused-freelist.patch
* do_shared_fault-check-that-mmap_sem-is-held.patch
* frv-remove-unused-cpuinfo_frv-and-friends-to-fix-future-build-error.patch
* alpha-use-kbuild-logic-to-include-asm-generic-sectionsh.patch
* include-kernelh-rewrite-min3-max3-and-clamp-using-min-and-max.patch
* blkdev-use-null-instead-of-zero.patch
* kernel-async-fixed-coding-style-issues.patch
* acct-eliminate-compile-warning.patch
* acct-eliminate-compile-warning-fix.patch
* kernel-fix-for-checkpatch-errors-in-sys-file.patch
* kern-sys-compat-sysinfo-syscall-fix-undefined-behavior.patch
* include-linux-screen_infoh-remove-unused-orig_-macros.patch
* nosave-consolidate-__nosave_beginend-in-asm-sectionsh.patch
* drivers-misc-ti-st-st_corec-fix-null-dereference-on-protocol-type-check.patch
* printk-dont-bother-using-log_cpu_max_buf_shift-on-smp.patch
* lib-vsprintf-add-%pt-format-specifier.patch
* maintainers-assing-systemace-driver-to-xilinx.patch
* remove-non-existent-files-from-maintainerspatch-added-to-mm-tree.patch
* maintainers-linaro-mm-sig-is-moderated.patch
* maintainers-add-entry-for-kernel-selftest-framework.patch
* drivers-video-backlight-backlightc-remove-backlight-sysfs-uevent.patch
* list-include-linux-kernelh.patch
* lib-use-seq_open_private-instead-of-seq_open.patch
* removing-textsearch_put-reference-from-the-comments.patch
* lib-remove-prio_heap.patch
* mm-utilc-add-kstrimdup.patch
* lib-add-crc64-ecma-module.patch
* checkpatch-fix-spello.patch
* checkpatch-remove-debugging-message.patch
* checkpatch-update-allowed_asm_includes-macros-add-rebooth-and-timeh.patch
* checkpatch-enable-whitespace-checks-for-dts-files.patch
* checkpatch-allow-optional-shorter-config-descriptions.patch
* checkpatch-allow-optional-shorter-config-descriptions-v4.patch
* checkpatch-add-strict-test-for-concatenated-string-elements.patch
* checkpatch-remove-unnecessary-after-88.patch
* checkpatch-warn-on-macros-with-flow-control-statements.patch
* checkpatch-look-for-common-misspellings.patch
* binfmt_misc-expand-the-register-format-limit-to-1920-bytes.patch
* binfmt_misc-touch-up-documentation-a-bit.patch
* binfmt_misc-work-around-gcc-49-warning.patch
* kernel-kallsymsc-use-__seq_open_private.patch
* autofs4-allow-rcu-walk-to-walk-through-autofs4.patch
* autofs4-factor-should_expire-out-of-autofs4_expire_indirect.patch
* autofs4-make-autofs4_can_expire-idempotent.patch
* autofs4-avoid-taking-fs_lock-during-rcu-walk.patch
* autofs4-d_manage-should-return-eisdir-when-appropriate-in-rcu-walk-mode.patch
* autofs4-d_manage-should-return-eisdir-when-appropriate-in-rcu-walk-mode-fix.patch
* autofs-the-documentation-i-wanted-to-read.patch
* rtc-use-c99-initializers-in-structures.patch
* rtc-s3c-define-s3c_rtc-structure-to-remove-global-variables.patch
* rtc-s3c-remove-warning-message-when-checking-coding-style-with-checkpatch-script.patch
* rtc-s3c-add-s3c_rtc_data-structure-to-use-variant-data-instead-of-s3c_cpu_type.patch
* rtc-s3c-add-support-for-rtc-of-exynos3250-soc.patch
* arm-dts-fix-wrong-compatible-string-of-exynos3250-rtc-dt-node.patch
* rtc-make-of_device_ids-const.patch
* rtc-rk808-add-rtc-driver-for-rk808.patch
* rtc-rk808-add-rtc-driver-for-rk808-fix.patch
* rtc-rk808-add-rtc-driver-for-rk808-fix-2.patch
* clk-rk808-add-clkout-driver-for-rk808.patch
* documentation-dt-bindings-trickle-charger-dt-binding-document-for-ds1339.patch
* rtc-ds1307-add-trickle-charger-device-tree-binding.patch
* rtc-bq32000-add-trickle-charger-option-with-device-tree-binding.patch
* rtc-bq32000-add-trickle-charger-option-with-device-tree-binding-checkpatch-fixes.patch
* rtc-bq32000-add-trickle-charger-device-tree-binding.patch
* rtc-max77686-allow-the-max77686-rtc-to-wakeup-the-system.patch
* rtc-max77686-remove-dead-code-for-smpl-and-wtsr.patch
* rtc-max77686-fail-to-probe-if-no-rtc-regmap-irqchip-is-set.patch
* rtc-max77686-remove-unneded-info-log.patch
* rtc-max77686-use-ffs-to-calculate-tm_wday.patch
* rtc-max77686-use-ffs-to-calculate-tm_wday-fix.patch
* rtc-add-driver-for-maxim-77802-pmic-real-time-clock.patch
* rtc-add-driver-for-maxim-77802-pmic-real-time-clock-v10.patch
* rtc-add-driver-for-maxim-77802-pmic-real-time-clock-v10-fix.patch
* rtc-pm8xxx-rework-to-support-pm8941-rtc.patch
* rtc-pm8xxx-rework-to-support-pm8941-rtc-checkpatch-fixes.patch
* fs-befs-btreec-remove-typedef-befs_btree_node.patch
* nilfs2-add-missing-blkdev_issue_flush-to-nilfs_sync_fs.patch
* hfsplus-fix-longname-handling.patch
* fs-reiserfs-journalc-fix-sparse-context-imbalance-warning.patch
* try-to-use-automatic-variable-in-kexec-purgatory-makefile.patch
* take-the-segment-adding-out-of-locate_mem_hole-functions.patch
* check-if-crashk_res_low-exists-when-exclude-it-from-crash-mem-ranges.patch
* kexec-remove-the-unused-function-parameter.patch
* kexec-bzimage64-fix-sparse-warnings.patch
* rbtree-add-comment-to-rb_insert_augmented.patch
* kgdb-timeout-if-secondary-cpus-ignore-the-roundup.patch
* x86-optimize-resource-lookups-for-ioremap.patch
* x86-optimize-resource-lookups-for-ioremap-fix.patch
* x86-use-optimized-ioresource-lookup-in-ioremap-function.patch
* init-resolve-shadow-warnings.patch
* init-resolve-shadow-warnings-checkpatch-fixes.patch
* ipc-always-handle-a-new-value-of-auto_msgmni.patch
* ipc-shm-kill-the-historical-wrong-mm-start_stack-check.patch
* ipc-use-__seq_open_private-instead-of-seq_open.patch
* ipc-resolve-shadow-warnings.patch
* build-trivia-scripts-headers_installsh.patch
* scripts-sortextable-suppress-warning-relocs_size-may-be-used-uninitialized.patch
  linux-next.patch
  linux-next-rejects.patch
* drivers-gpio-gpio-zevioc-fix-build.patch
* x86-vdso-fix-vdso2cs-special_pages-error-checking.patch
* arch-x86-kernel-cpu-commonc-fix-unused-symbol-warning.patch
* lib-string-remove-duplicated-function.patch
* lib-string-make-all-calls-to-strnicmp-into-calls-to-strncasecmp.patch
* arm-replace-strnicmp-with-strncasecmp.patch
* block-replace-strnicmp-with-strncasecmp.patch
* netfilter-replace-strnicmp-with-strncasecmp.patch
* video-fbdev-replace-strnicmp-with-strncasecmp.patch
* cifs-replace-strnicmp-with-strncasecmp.patch
* ocfs2-replace-strnicmp-with-strncasecmp.patch
* isofs-replace-strnicmp-with-strncasecmp.patch
* batman-adv-replace-strnicmp-with-strncasecmp.patch
* acpi-battery-replace-strnicmp-with-strncasecmp.patch
* cpufreq-replace-strnicmp-with-strncasecmp.patch
* cpuidle-replace-strnicmp-with-strncasecmp.patch
* scsi-replace-strnicmp-with-strncasecmp.patch
* ib_srpt-replace-strnicmp-with-strncasecmp.patch
* input-edt-ft5x06-replace-strnicmp-with-strncasecmp.patch
* altera-stapl-replace-strnicmp-with-strncasecmp.patch
* thinkpad_acpi-replace-strnicmp-with-strncasecmp.patch
* pnp-replace-strnicmp-with-strncasecmp.patch
* s390-cio-replace-strnicmp-with-strncasecmp.patch
* staging-r8188eu-replace-strnicmp-with-strncasecmp.patch
* thermal-replace-strnicmp-with-strncasecmp.patch
* kdb-replace-strnicmp-with-strncasecmp.patch
* fs-check-bh-blocknr-earlier-when-searching-lru.patch
* mem-hotplug-fix-boot-failed-in-case-all-the-nodes-are-hotpluggable.patch
* mem-hotplug-fix-boot-failed-in-case-all-the-nodes-are-hotpluggable-checkpatch-fixes.patch
* include-linux-remove-strict_strto-definitions.patch
* lib-string_helpers-move-documentation-to-c-file.patch
* lib-string_helpers-refactoring-the-test-suite.patch
* lib-string_helpers-introduce-string_escape_mem.patch
* lib-string_helpers-introduce-string_escape_mem-fix.patch
* lib-vsprintf-add-%pe-format-specifier.patch
* lib-vsprintf-add-%pe-format-specifier-fix.patch
* wireless-libertas-print-esaped-string-via-%pe.patch
* wireless-ipw2x00-print-ssid-via-%pe.patch
* wireless-hostap-proc-print-properly-escaped-ssid.patch
* wireless-hostap-proc-print-properly-escaped-ssid-fix.patch
* wireless-hostap-proc-print-properly-escaped-ssid-fix-2.patch
* lib80211-remove-unused-print_ssid.patch
* staging-wlan-ng-use-%pehp-to-print-sn.patch
* staging-rtl8192e-use-%pen-to-escape-buffer.patch
* staging-rtl8192u-use-%pen-to-escape-buffer.patch
* watchdog-control-hard-lockup-detection-default.patch
* watchdog-control-hard-lockup-detection-default-fix.patch
* watchdog-control-hard-lockup-detection-default-fix-2.patch
* kvm-ensure-hard-lockup-detection-is-disabled-by-default.patch
* kernel-add-support-for-kernel-restart-handler-call-chain.patch
* power-restart-call-machine_restart-instead-of-arm_pm_restart.patch
* arm64-support-restart-through-restart-handler-call-chain.patch
* arm-support-restart-through-restart-handler-call-chain.patch
* watchdog-moxart-register-restart-handler-with-kernel-restart-handler.patch
* watchdog-alim7101-register-restart-handler-with-kernel-restart-handler.patch
* watchdog-sunxi-register-restart-handler-with-kernel-restart-handler.patch
* arm-arm64-unexport-restart-handlers.patch
* watchdog-s3c2410-add-restart-handler.patch
* clk-samsung-register-restart-handlers-for-s3c2412-and-s3c2443.patch
* clk-rockchip-add-restart-handler.patch
* frv-remove-unused-declarations-of-__start___ex_table-and-__stop___ex_table.patch
* ia64-remove-duplicate-declarations-of-__per_cpu_start-and-__per_cpu_end.patch
* kernel-param-consolidate-__startstop___param-in-linux-moduleparamh.patch
* mm-replace-remap_file_pages-syscall-with-emulation.patch
* fat-add-i_disksize-to-represent-uninitialized-size-v4.patch
* fat-add-fat_fallocate-operation-v4.patch
* fat-zero-out-seek-range-on-_fat_get_block-v4.patch
* fat-fallback-to-buffered-write-in-case-of-fallocated-region-on-direct-io-v4.patch
* fat-permit-to-return-phy-block-number-by-fibmap-in-fallocated-region-v4.patch
* documentation-filesystems-vfattxt-update-the-limitation-for-fat-fallocate-v4.patch
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
