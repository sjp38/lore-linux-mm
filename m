Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 41D1B6B0035
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 18:16:09 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id lj1so7362030pab.28
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 15:16:08 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v11si1948525pas.219.2014.08.29.15.16.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Aug 2014 15:16:08 -0700 (PDT)
Date: Fri, 29 Aug 2014 15:16:01 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2014-08-29-15-15 uploaded
Message-ID: <5400fba1.732YclygYZprDXeI%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz

The mm-of-the-moment snapshot 2014-08-29-15-15 has been uploaded to

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


This mmotm tree contains the following patches against 3.17-rc2:
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
* mem-hotplug-let-memblock-skip-the-hotpluggable-memory-regions-in-__next_mem_range-fix.patch
* fix-faulty-logic-in-the-case-of-recursive-printk.patch
* mm-slab_commonc-suppress-warning.patch
* mm-cma-adjust-address-limit-to-avoid-hitting-low-high-memory-boundary.patch
* arm-mm-dont-limit-default-cma-region-only-to-low-memory.patch
* eventpoll-fix-uninitialized-variable-in-epoll_ctl.patch
* sh-get_user_pages_fast-must-flush-cache-the-way.patch
* checkpatch-allow-commit-descriptions-on-separate-line-from-commit-id.patch
* x86mem-hotplug-pass-sync_global_pgds-a-correct-argument-in-remove_pagetable.patch
* x86mem-hotplug-modify-pgd-entry-when-removing-memory.patch
* x86-numa-setup_node_data-drop-dead-code-and-rename-function.patch
* mem-hotplug-fix-boot-failed-in-case-all-the-nodes-are-hotpluggable.patch
* mem-hotplug-fix-boot-failed-in-case-all-the-nodes-are-hotpluggable-checkpatch-fixes.patch
* mn10300-use-kbuild-logic-to-include-asm-generic-sectionsh.patch
* cris-use-kbuild-logic-to-include-asm-generic-sectionsh.patch
* fs-cifs-remove-obsolete-__constant.patch
* fs-cifs-filec-replace-countsize-kzalloc-by-kcalloc.patch
* fs-cifs-smb2filec-replace-countsize-kzalloc-by-kcalloc.patch
* efi-bgrt-add-error-handling-inform-the-user-when-ignoring-the-bgrt.patch
* kernel-posix-timersc-code-clean-up.patch
* kernel-posix-timersc-code-clean-up-checkpatch-fixes.patch
* input-route-kbd-leds-through-the-generic-leds-layer.patch
* input-route-kbd-leds-through-the-generic-leds-layer-fix.patch
* m32r-use-kbuild-logic-to-include-asm-generic-sectionsh.patch
* score-use-kbuild-logic-to-include-asm-generic-sectionsh.patch
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
* ocfs2-fix-deadlock-between-o2hb-thread-and-o2net_wq.patch
* bio-integrity-remove-the-needless-fail-handle-of-bip_slab-creating.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* softlockup-make-detector-be-aware-of-task-switch-of-processes-hogging-cpu.patch
* softlockup-make-detector-be-aware-of-task-switch-of-processes-hogging-cpu-fix.patch
  mm.patch
* mm-slab_common-move-kmem_cache-definition-to-internal-header.patch
* mm-slab_common-move-kmem_cache-definition-to-internal-header-fix.patch
* mm-slb-always-track-caller-in-kmalloc_node_track_caller.patch
* mm-slab-move-cache_flusharray-out-of-unlikelytext-section.patch
* mm-slab-noinline-__ac_put_obj.patch
* mm-slab-factor-out-unlikely-part-of-cache_free_alien.patch
* slub-disable-tracing-and-failslab-for-merged-slabs.patch
* fix-checkpatch-errors-for-mm-mmapc.patch
* memory-hotplug-add-sysfs-zones_online_to-attribute.patch
* memory-hotplug-add-sysfs-zones_online_to-attribute-fix.patch
* memory-hotplug-add-sysfs-zones_online_to-attribute-fix-2.patch
* memory-hotplug-add-sysfs-zones_online_to-attribute-fix-3.patch
* memory-hotplug-add-sysfs-zones_online_to-attribute-fix-4.patch
* mm-remove-misleading-arch_uses_numa_prot_none.patch
* lib-genallocc-add-power-aligned-algorithm.patch
* lib-genallocc-add-genpool-range-check-function.patch
* common-dma-mapping-introduce-common-remapping-functions.patch
* common-dma-mapping-introduce-common-remapping-functions-fix.patch
* common-dma-mapping-introduce-common-remapping-functions-fix-2.patch
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
* mm-use-memblock_alloc_range.patch
* include-linux-migrateh-remove-migratepage-define.patch
* mm-balloon_compaction-ignore-anonymous-pages.patch
* mm-balloon_compaction-keep-ballooned-pages-away-from-normal-migration-path.patch
* mm-balloon_compaction-isolate-balloon-pages-without-lru_lock.patch
* selftests-vm-transhuge-stress-stress-test-for-memory-compaction.patch
* mm-introduce-common-page-state-for-ballooned-memory.patch
* mm-introduce-common-page-state-for-ballooned-memory-fix.patch
* mm-balloon_compaction-use-common-page-ballooning.patch
* mm-balloon_compaction-general-cleanup.patch
* mm-balloon_compaction-general-cleanup-fix.patch
* mm-balloon_compaction-general-cleanup-checkpatch-fixes.patch
* mm-use-seq_open_private-instead-of-seq_open.patch
* mm-use-__seq_open_private-instead-of-seq_open.patch
* introduce-dump_vma.patch
* introduce-dump_vma-fix.patch
* introduce-vm_bug_on_vma.patch
* convert-a-few-vm_bug_on-callers-to-vm_bug_on_vma.patch
* convert-a-few-vm_bug_on-callers-to-vm_bug_on_vma-checkpatch-fixes.patch
* mm-page_alloc-avoid-wakeup-kswapd-on-the-unintended-node.patch
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
* zram-add-num_discard_req-discarded-for-discard-stat.patch
* do_shared_fault-check-that-mmap_sem-is-held.patch
* alpha-use-kbuild-logic-to-include-asm-generic-sectionsh.patch
* include-kernelh-rewrite-min3-max3-and-clamp-using-min-and-max.patch
* include-kernelh-rewrite-min3-max3-and-clamp-using-min-and-max-fix.patch
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
* kernel-async-fixed-coding-style-issues.patch
* acct-eliminate-compile-warning.patch
* acct-eliminate-compile-warning-fix.patch
* kernel-fix-for-checkpatch-errors-in-sys-file.patch
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
* mm-utilc-add-kstrimdup.patch
* lib-add-crc64-ecma-module.patch
* checkpatch-fix-spello.patch
* checkpatch-remove-debugging-message.patch
* checkpatch-update-allowed_asm_includes-macros-add-rebooth-and-timeh.patch
* checkpatch-enable-whitespace-checks-for-dts-files.patch
* init-kconfig-move-rcu_nocb_cpu-dependencies-to-choice.patch
* autofs4-allow-rcu-walk-to-walk-through-autofs4.patch
* autofs4-factor-should_expire-out-of-autofs4_expire_indirect.patch
* autofs4-make-autofs4_can_expire-idempotent.patch
* autofs4-avoid-taking-fs_lock-during-rcu-walk.patch
* autofs4-d_manage-should-return-eisdir-when-appropriate-in-rcu-walk-mode.patch
* autofs-the-documentation-i-wanted-to-read.patch
* rtc-use-c99-initializers-in-structures.patch
* rtc-s3c-define-s3c_rtc-structure-to-remove-global-variables.patch
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
* proc-maps-replace-proc_maps_private-pid-with-struct-inode-inode.patch
* proc-maps-make-vm_is_stack-logic-namespace-friendly.patch
* not-adding-modules-range-to-kcore-if-its-equal-to-vmcore-range.patch
* not-adding-modules-range-to-kcore-if-its-equal-to-vmcore-range-checkpatch-fixes.patch
* try-to-use-automatic-variable-in-kexec-purgatory-makefile.patch
* kgdb-timeout-if-secondary-cpus-ignore-the-roundup.patch
* x86-optimize-resource-lookups-for-ioremap.patch
* x86-optimize-resource-lookups-for-ioremap-fix.patch
* x86-use-optimized-ioresource-lookup-in-ioremap-function.patch
* init-resolve-shadow-warnings.patch
* init-resolve-shadow-warnings-checkpatch-fixes.patch
* ipc-always-handle-a-new-value-of-auto_msgmni.patch
* ipc-shm-kill-the-historical-wrong-mm-start_stack-check.patch
* ipc-use-__seq_open_private-instead-of-seq_open.patch
* build-trivia-scripts-headers_installsh.patch
  linux-next.patch
* drivers-gpio-gpio-zevioc-fix-build.patch
* x86-vdso-fix-vdso2cs-special_pages-error-checking.patch
* include-linux-remove-strict_strto-definitions.patch
* lib-string_helpers-move-documentation-to-c-file.patch
* lib-string_helpers-refactoring-the-test-suite.patch
* lib-string_helpers-introduce-string_escape_mem.patch
* lib-vsprintf-add-%pe-format-specifier.patch
* lib-vsprintf-add-%pe-format-specifier-fix.patch
* wireless-libertas-print-esaped-string-via-%pe.patch
* wireless-ipw2x00-print-ssid-via-%pe.patch
* wireless-hostap-proc-print-properly-escaped-ssid.patch
* lib80211-remove-unused-print_ssid.patch
* staging-wlan-ng-use-%pehp-to-print-sn.patch
* staging-rtl8192e-use-%pen-to-escape-buffer.patch
* staging-rtl8192u-use-%pen-to-escape-buffer.patch
* watchdog-control-hard-lockup-detection-default.patch
* watchdog-control-hard-lockup-detection-default-fix.patch
* watchdog-control-hard-lockup-detection-default-fix-2.patch
* kvm-ensure-hard-lockup-detection-is-disabled-by-default.patch
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
