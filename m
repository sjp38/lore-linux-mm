Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 20D7F6B0031
	for <linux-mm@kvack.org>; Mon, 10 Mar 2014 18:37:03 -0400 (EDT)
Received: by mail-qg0-f41.google.com with SMTP id i50so18177287qgf.0
        for <linux-mm@kvack.org>; Mon, 10 Mar 2014 15:37:02 -0700 (PDT)
Received: from mail-qa0-f74.google.com (mail-qa0-f74.google.com [209.85.216.74])
        by mx.google.com with ESMTPS id a79si10269433qgf.45.2014.03.10.15.37.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 10 Mar 2014 15:37:01 -0700 (PDT)
Received: by mail-qa0-f74.google.com with SMTP id w5so1025707qac.3
        for <linux-mm@kvack.org>; Mon, 10 Mar 2014 15:37:01 -0700 (PDT)
Subject: mmotm 2014-03-10-15-35 uploaded
From: akpm@linux-foundation.org
Date: Mon, 10 Mar 2014 15:37:00 -0700
Message-Id: <20140310223701.0969C31C2AA@corp2gmr1-1.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

The mm-of-the-moment snapshot 2014-03-10-15-35 has been uploaded to

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


This mmotm tree contains the following patches against 3.14-rc6:
(patches marked "*" will be included in linux-next)

  arch-alpha-kernel-systblss-remove-debug-check.patch
  i-need-old-gcc.patch
  maintainers-akpm-maintenance.patch
* mm-fix-gfp_thisnode-callers-and-clarify.patch
* mm-compaction-break-out-of-loop-on-pagebuddy-in-isolate_freepages_block.patch
* fs-proc-basec-fix-gpf-in-proc-pid-map_files.patch
* mm-kconfig-fix-url-for-zsmalloc-benchmark.patch
* revert-kallsyms-fix-absolute-addresses-for-kaslr.patch
* maintainers-blackfin-add-git-repository.patch
* tools-testing-selftests-ipc-msgquec-handle-msgget-failure-return-correctly.patch
* hfsplus-add-hfsx-subfolder-count-support.patch
* cris-convert-ffs-from-an-object-like-macro-to-a-function-like-macro.patch
* backing_dev-fix-hung-task-on-sync.patch
* audit-use-struct-net-not-pid_t-to-remember-the-network-namespce-to-reply-in.patch
* kthread-ensure-locality-of-task_struct-allocations.patch
* arch-x86-mm-kmemcheck-kmemcheckc-use-kstrtoint-instead-of-sscanf.patch
* arm-use-generic-fixmaph.patch
* fs-cifs-cifsfsc-add-__init-to-cifs_init_inodecache.patch
* fanotify-remove-useless-bypass_perm-check.patch
* fanotify-use-fanotify-event-structure-for-permission-response-processing.patch
* fanotify-convert-access_mutex-to-spinlock.patch
* fanotify-reorganize-loop-in-fanotify_read.patch
* fanotify-move-unrelated-handling-from-copy_event_to_user.patch
* sched_clock-document-4mhz-vs-1mhz-decision.patch
* input-route-kbd-leds-through-the-generic-leds-layer.patch
* score-remove-unused-cpu_score7-kconfig-parameter.patch
* sh-push-extra-copy-of-r0-r2-for-syscall-parameters.patch
* sh-remove-unused-do_fpu_error.patch
* sh-dont-pass-saved-userspace-state-to-exception-handlers.patch
* arch-sh-boards-board-sh7757lcrc-fixup-sdhi-register-size.patch
* drivers-net-irda-donauboe-convert-to-module_pci_driver.patch
* net-core-rtnetlinkc-copy-paste-error-in-rtnl_bridge_notify.patch
* ocfs2-fix-null-pointer-dereference-when-access-dlm_state-before-launching-dlm-thread.patch
* ocfs2-change-ip_unaligned_aio-to-of-type-mutex-from-atomit_t.patch
* ocfs2-remove-unused-variable-uuid_net_key-in-ocfs2_initialize_super.patch
* ocfs2-improve-fsync-efficiency-and-fix-deadlock-between-aio_write-and-sync_file.patch
* ocfs2-o2net-incorrect-to-terminate-accepting-connections-loop-upon-rejecting-an-invalid-one.patch
* ocfs2-dlm-fix-lock-migration-crash.patch
* ocfs2-dlm-fix-recovery-hung.patch
* ocfs2-add-dlm_recover_callback_support-in-sysfs.patch
* ocfs2-add-dlm_recover_callback_support-in-sysfs-fix.patch
* ocfs2-fix-a-tiny-race-when-running-dirop_fileop_racer.patch
* ocfs2-o2net-o2net_listen_data_ready-should-do-nothing-if-socket-state-is-not-tcp_listen.patch
* ocfs2-remove-ocfs2_inode_skip_delete-flag.patch
* ocfs2-move-dquot_initialize-in-ocfs2_delete_inode-somewhat-later.patch
* quota-provide-function-to-grab-quota-structure-reference.patch
* ocfs2-implement-delayed-dropping-of-last-dquot-reference.patch
* ocfs2-avoid-blocking-in-ocfs2_mark_lockres_freeing-in-downconvert-thread.patch
* ocfs2-revert-iput-deferring-code-in-ocfs2_drop_dentry_lock.patch
* ocfs2-alloc_dinode-counts-and-group-bitmap-should-be-update-simultaneously.patch
* ocfs2-flock-drop-cross-node-lock-when-failed-locally.patch
* ocfs2-flock-drop-cross-node-lock-when-failed-locally-checkpatch-fixes.patch
* ocfs2-call-ocfs2_update_inode_fsync_trans-when-updating-any-inode.patch
* ocfs2-do-not-return-dlm_migrate_response_mastery_ref-to-avoid-endlessloop-during-umount.patch
* ocfs2-do-not-return-dlm_migrate_response_mastery_ref-to-avoid-endlessloop-during-umount-checkpatch-fixes.patch
* ocfs2-manually-do-the-iput-once-ocfs2_add_entry-failed-in-ocfs2_symlink-and-ocfs2_mknod.patch
* ocfs2-should-call-ocfs2_journal_access_di-before-ocfs2_delete_entry-in-ocfs2_orphan_del.patch
* ocfs2-llseek-requires-ocfs2-inode-lock-for-the-file-in-seek_end.patch
* drivers-scsi-megaraid-megaraid_mmc-missing-bounds-check-in-mimd_to_kioc.patch
* maintainers-update-ibm-serveraid-raid-info.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* fs-direct-io-remove-redundant-comparison.patch
* direct-io-remove-some-left-over-checks.patch
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
* mm-vmstat-fix-up-zone-state-accounting.patch
* mm-vmstat-fix-up-zone-state-accounting-fix.patch
* fs-cachefiles-use-add_to_page_cache_lru.patch
* lib-radix-tree-radix_tree_delete_item.patch
* mm-shmem-save-one-radix-tree-lookup-when-truncating-swapped-pages.patch
* mm-filemap-move-radix-tree-hole-searching-here.patch
* mm-fs-prepare-for-non-page-entries-in-page-cache-radix-trees.patch
* mm-fs-prepare-for-non-page-entries-in-page-cache-radix-trees-fix.patch
* mm-fs-store-shadow-entries-in-page-cache.patch
* mm-thrash-detection-based-file-cache-sizing.patch
* lib-radix_tree-tree-node-interface.patch
* lib-radix_tree-tree-node-interface-fix.patch
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
* mm-process_vm_accessc-mark-function-as-static-fix.patch
* mm-page_cgroupc-mark-functions-as-static.patch
* mm-nobootmemc-mark-function-as-static.patch
* include-linux-mmh-remove-ifdef-condition.patch
* mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff.patch
* mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff-v2.patch
* mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff-v3.patch
* mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff-v3-fix.patch
* pagewalk-update-page-table-walker-core.patch
* pagewalk-update-page-table-walker-core-fix-end-address-calculation-in-walk_page_range.patch
* pagewalk-update-page-table-walker-core-fix-end-address-calculation-in-walk_page_range-fix.patch
* pagewalk-add-walk_page_vma.patch
* smaps-redefine-callback-functions-for-page-table-walker.patch
* clear_refs-redefine-callback-functions-for-page-table-walker.patch
* pagemap-redefine-callback-functions-for-page-table-walker.patch
* numa_maps-redefine-callback-functions-for-page-table-walker.patch
* memcg-redefine-callback-functions-for-page-table-walker.patch
* madvise-redefine-callback-functions-for-page-table-walker.patch
* arch-powerpc-mm-subpage-protc-use-walk_page_vma-instead-of-walk_page_range.patch
* pagewalk-remove-argument-hmask-from-hugetlb_entry.patch
* pagewalk-remove-argument-hmask-from-hugetlb_entry-fix.patch
* pagewalk-remove-argument-hmask-from-hugetlb_entry-fix-fix.patch
* mempolicy-apply-page-table-walker-on-queue_pages_range.patch
* mm-call-vma_adjust_trans_huge-only-for-thp-enabled-vma.patch
* mm-rename-__do_fault-do_fault.patch
* mm-do_fault-extract-to-call-vm_ops-do_fault-to-separate-function.patch
* mm-introduce-do_read_fault.patch
* mm-introduce-do_cow_fault.patch
* mm-introduce-do_shared_fault-and-drop-do_fault.patch
* mm-introduce-do_shared_fault-and-drop-do_fault-fix.patch
* mm-introduce-do_shared_fault-and-drop-do_fault-fix-fix.patch
* mm-consolidate-code-to-call-vm_ops-page_mkwrite.patch
* mm-consolidate-code-to-call-vm_ops-page_mkwrite-fix.patch
* mm-consolidate-code-to-setup-pte.patch
* mm-thp-drop-do_huge_pmd_wp_zero_page_fallback.patch
* mm-remove-read_cache_page_async.patch
* drop_caches-add-some-documentation-and-info-message.patch
* kobject-dont-block-for-each-kobject_uevent.patch
* kobject-dont-block-for-each-kobject_uevent-v2.patch
* slub-do-not-drop-slab_mutex-for-sysfs_slab_add.patch
* mm-readaheadc-fix-readahead-failure-for-memoryless-numa-nodes-and-limit-readahead-pages.patch
* mmnuma-reorganize-change_pmd_range.patch
* mmnuma-reorganize-change_pmd_range-fix.patch
* move-mmu-notifier-call-from-change_protection-to-change_pmd_range.patch
* mm-vmscan-restore-sc-gfp_mask-after-promoting-it-to-__gfp_highmem.patch
* mm-vmscan-do-not-check-compaction_ready-on-promoted-zones.patch
* mm-memoryc-update-comment-in-unmap_single_vma.patch
* mm-exclude-memory-less-nodes-from-zone_reclaim.patch
* mm-compaction-disallow-high-order-page-for-migration-target.patch
* mm-compaction-do-not-call-suitable_migration_target-on-every-page.patch
* mm-compaction-change-the-timing-to-check-to-drop-the-spinlock.patch
* mm-compaction-check-pageblock-suitability-once-per-pageblock.patch
* mm-compaction-clean-up-code-on-success-of-ballon-isolation.patch
* mm-revert-thp-make-madv_hugepage-check-for-mm-def_flags.patch
* mm-revert-thp-make-madv_hugepage-check-for-mm-def_flags-ignore-madv_hugepage-on-s390-to-prevent-sigsegv-in-qemu.patch
* mm-thp-add-vm_init_def_mask-and-prctl_thp_disable.patch
* exec-kill-the-unnecessary-mm-def_flags-setting-in-load_elf_binary.patch
* mm-disable-split-page-table-lock-for-mmu.patch
* tools-vm-page-typesc-page-cache-sniffing-feature.patch
* drivers-lguest-page_tablesc-rename-do_set_pte.patch
* mm-introduce-vm_ops-map_pages.patch
* mm-introduce-vm_ops-map_pages-fix.patch
* mm-implement-map_pages-for-page-cache.patch
* mm-implement-map_pages-for-page-cache-fix.patch
* mm-cleanup-size-checks-in-filemap_fault-and-filemap_map_pages.patch
* mm-add-debugfs-tunable-for-fault_around_order.patch
* mm-add-debugfs-tunable-for-fault_around_order-checkpatch-fixes.patch
* mm-per-thread-vma-caching.patch
* mm-per-thread-vma-caching-fix-3.patch
* mm-use-macros-from-compilerh-instead-of-__attribute__.patch
* mm-use-macros-from-compilerh-instead-of-__attribute__-fix.patch
* fork-collapse-copy_flags-into-copy_process.patch
* mm-mempolicy-rename-slab_node-for-clarity.patch
* mm-mempolicy-remove-per-process-flag.patch
* res_counter-remove-interface-for-locked-charging-and-uncharging.patch
* mm-compactionc-isolate_freepages_block-small-tuneup.patch
* mm-compaction-determine-isolation-mode-only-once.patch
* mempool-add-unlikely-and-likely-hints.patch
* mm-fix-error-do-not-initialise-globals-to-0-or-null-and-coding-style.patch
* mm-fix-coding-style.patch
* drivers-base-nodec-fix-null-pointer-access-and-memory-leak-in-unregister_one_node.patch
* mm-vmallocc-enhance-vm_map_ram-comment.patch
* mm-vmallocc-enhance-vm_map_ram-comment-fix.patch
* mm-disable-mm-balloon_compactionc-completely-when-config_balloon_compaction.patch
* zram-drop-init_done-struct-zram-member.patch
* zram-do-not-pass-rw-argument-to-__zram_make_request.patch
* zram-remove-good-and-bad-compress-stats.patch
* zram-use-atomic64_t-for-all-zram-stats.patch
* zram-remove-zram-stats-code-duplication.patch
* zram-report-failed-read-and-write-stats.patch
* zram-drop-not-used-table-count-member.patch
* zram-move-zram-size-warning-to-documentation.patch
* zram-document-failed_reads-failed_writes-stats.patch
* zram-delete-zram_init_device.patch
* zram-delete-zram_init_device-fix.patch
* zram-introduce-compressing-backend-abstraction.patch
* zram-use-zcomp-compressing-backends.patch
* zram-use-zcomp-compressing-backends-fix.patch
* zram-factor-out-single-stream-compression.patch
* zram-add-multi-stream-functionality.patch
* zram-add-set_max_streams-knob.patch
* zram-make-compression-algorithm-selection-possible.patch
* zram-add-lz4-algorithm-backend.patch
* zram-move-comp-allocation-out-of-init_lock.patch
* zram-return-error-valued-pointer-from-zcomp_create.patch
* zram-return-error-valued-pointer-from-zcomp_create-fix.patch
* zram-propagate-error-to-user.patch
* zram-propagate-error-to-user-fix.patch
* zram-use-scnprintf-in-attrs-show-methods.patch
* mm-zswap-fix-trivial-typo-and-arrange-indentation.patch
* mm-zswap-update-zsmalloc-in-comment-to-zbud.patch
* mm-zswap-support-multiple-swap-devices.patch
* mm-zswapc-remove-unnecessary-parentheses.patch
* do_shared_fault-check-that-mmap_sem-is-held.patch
* include-linux-syscallsh-add-sys32_quotactl-prototype.patch
* include-linux-syscallsh-add-sys32_quotactl-prototype-fix.patch
* sys_sysfs-add-config_sysfs_syscall.patch
* sys_sysfs-add-config_sysfs_syscall-fix.patch
* kernel-groupsc-remove-return-value-of-set_groups.patch
* kernel-groupsc-remove-return-value-of-set_groups-fix.patch
* fs-kernel-permit-disabling-the-uselib-syscall.patch
* fs-kernel-permit-disabling-the-uselib-syscall-v2.patch
* submittingpatches-add-style-recommendation-to-use-imperative-descriptions.patch
* submittingpatches-add-recommendation-for-mailing-list-references.patch
* submittingpatches-document-the-use-of-git.patch
* errh-use-bool-for-is_err-and-is_err_or_null.patch
* kernel-audit-fix-non-modular-users-of-module_init-in-core-code.patch
* kernel-resourcec-make-reallocate_resource-static.patch
* lglock-map-to-spinlock-when-config_smp.patch
* drivers-misc-ti-st-st_corec-fix-null-dereference-on-protocol-type-check.patch
* vsprintf-remove-%n-handling.patch
* printk-remove-duplicated-check-for-log-level.patch
* printk-remove-obsolete-check-for-log-level-c.patch
* printk-add-comment-about-tricky-check-for-text-buffer-size.patch
* printk-use-also-the-last-bytes-in-the-ring-buffer.patch
* printk-do-not-compute-the-size-of-the-message-twice.patch
* lib-vsprintf-add-%pt-format-specifier.patch
* maintainers-add-backlight-co-maintainers.patch
* maintainers-mark-superh-orphan.patch
* maintainers-add-xtensa-irqchips-to-xtensa-port-entry.patch
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
* lib-random32c-minor-cleanups-and-kdoc-fix.patch
* lib-clz_ctzc-add-prototype-declarations-in-lib-clz_ctzc.patch
* lib-decompress_inflatec-include-appropriate-header-file.patch
* lib-xz-enable-all-filters-by-default-in-kconfig.patch
* mm-utilc-add-kstrimdup.patch
* lib-add-crc64-ecma-module.patch
* checkpatch-add-test-for-long-udelay.patch
* checkpatch-dont-warn-on-some-function-pointer-return-styles.patch
* checkpatch-add-checks-for-constant-non-octal-permissions.patch
* checkpatch-warn-on-uses-of-__constant_foo-functions.patch
* checkpatch-update-octal-permissions-warning.patch
* checkpatch-avoid-sscanf-test-duplicated-messages.patch
* checkpatch-fix-jiffies-comparison-and-others.patch
* checkpatch-add-test-for-char-arrays-that-could-be-static-const.patch
* checkpatch-use-a-more-consistent-function-argument-style.patch
* checkpatch-ignore-networking-block-comment-style-first-lines-in-file.patch
* checkpatch-make-return-is-not-a-function-test-quieter.patch
* checkpatchpl-modify-warning-message-for-printk-usage.patch
* checkpatch-net-and-drivers-net-warn-on-missing-blank-line-after-variable-declaration.patch
* checkpatch-always-warn-on-missing-blank-line-after-variable-declaration-block.patch
* checkpatch-check-vendor-compatible-with-dashes.patch
* checkpatch-fix-spurious-vendor-compatible-warnings.patch
* checkpatch-check-compatible-strings-in-c-and-h-too.patch
* checkpatch-improve-the-compatible-vendor-match.patch
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
* ncpfs-cleanup-indenting-in-ncp_lookup.patch
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
* drivers-rtc-rtc-sirfsocc-fix-kernel-panic-of-backing-from-hibernation.patch
* drivers-rtc-rtc-ds1307c-fix-sysfs-wakealarm-attribute-creation.patch
* drivers-rtc-rtc-ds1307c-add-alarm-support-for-mcp7941x-chips.patch
* rtc-mc13xxx-remove-__exit_p.patch
* rtc-mc13xxx-request-irqs-after-rtc-registration.patch
* rtc-mc13xxx-simplify-alarm_irq_enable.patch
* rtc-mc13xxx-fix-1hz-interrupt.patch
* rtc-mc13xxx-change-rtc-validation-scheme.patch
* rtc-mc13xxx-make-rtc_read_time-more-readable.patch
* rtc-sunxi-change-compatibles.patch
* arch-arm-boot-dts-sun4i-a10dtsi-convert-to-the-new-rtc-compatibles.patch
* drivers-rtc-rtc-ds3232c-make-it-possible-to-share-an-irq.patch
* drivers-rtc-rtc-cmosc-fix-compilation-warning-when-config_pm_sleep.patch
* drivers-rtc-rtc-as3722c-use-simple_dev_pm_ops-macro.patch
* drivers-rtc-rtc-palmasc-use-simple_dev_pm_ops-macro.patch
* drivers-rtc-rtc-ds3232c-enable-ds3232-to-work-as-wakeup-source.patch
* rtc-verify-a-critical-argument-to-rtc_update_irq-before-using-it.patch
* rtc-pm8xxx-fixup-checkpatch-style-issues.patch
* rtc-pm8xxx-use-regmap-api-for-register-accesses.patch
* rtc-pm8xxx-use-devm_request_any_context_irq.patch
* rtc-pm8xxx-add-support-for-devicetree.patch
* rtc-pm8xxx-move-device_init_wakeup-before-rtc_register.patch
* documentation-bindings-document-pmic8921-8058-rtc.patch
* fs-minix-inodec-add-__init-to-init_inodecache.patch
* befs-replace-kmalloc-memset-0-by-kzalloc.patch
* fs-befs-linuxvfsc-add-__init-to-befs_init_inodecache.patch
* fs-isofs-inodec-add-__init-to-init_inodecache.patch
* coda-add-__init-to-init_inodecache.patch
* nilfs2-update-maintainers-file-entries.patch
* nilfs2-add-struct-nilfs_suinfo_update-and-flags.patch
* nilfs2-add-nilfs_sufile_set_suinfo-to-update-segment-usage.patch
* nilfs2-add-nilfs_sufile_set_suinfo-to-update-segment-usage-fix.patch
* nilfs2-implementation-of-nilfs_ioctl_set_suinfo-ioctl.patch
* nilfs2-implementation-of-nilfs_ioctl_set_suinfo-ioctl-fix.patch
* nilfs2-add-nilfs_sufile_trim_fs-to-trim-clean-segs.patch
* nilfs2-add-fitrim-ioctl-support-for-nilfs2.patch
* nilfs2-verify-metadata-sizes-read-from-disk.patch
* nilfs2-update-maintainers-file-entries-fix.patch
* nilfs2-update-projects-web-site-in-nilfs2txt.patch
* hfsplus-remove-unused-variable-in-hfsplus_get_block.patch
* hfsplus-fix-concurrent-acess-of-alloc_blocks.patch
* hfsplus-fix-concurrent-acess-of-alloc_blocks-fix.patch
* hfsplus-fix-concurrent-acess-of-alloc_blocks-fix-fix.patch
* hfsplus-fix-longname-handling.patch
* hfsplus-add-__init-to-hfsplus_create_attr_tree_cache.patch
* fs-ufs-superc-add-__init-to-init_inodecache.patch
* fs-ufs-remove-unused-ufs_super_block_first-pointer.patch
* fs-ufs-remove-unused-ufs_super_block_second-pointer.patch
* fs-ufs-remove-unused-ufs_super_block_third-pointer.patch
* ufs-sb-mutex-merge-mutex_destroy.patch
* fs-reiserfs-move-prototype-declaration-to-header-file.patch
* fat-add-i_disksize-to-represent-uninitialized-size-v4.patch
* fat-add-fat_fallocate-operation-v4.patch
* fat-zero-out-seek-range-on-_fat_get_block-v4.patch
* fat-fallback-to-buffered-write-in-case-of-fallocated-region-on-direct-io-v4.patch
* fat-permit-to-return-phy-block-number-by-fibmap-in-fallocated-region-v4.patch
* documentation-filesystems-vfattxt-update-the-limitation-for-fat-fallocate-v4.patch
* documentation-update-kmemleaktxt.patch
* documentation-filesystems-ntfstxt-remove-changelog-reference.patch
* kmod-run-usermodehelpers-only-on-cpus-allowed-for-kthreadd-v2.patch
* kmod-run-usermodehelpers-only-on-cpus-allowed-for-kthreadd-v2-fix.patch
* kmod-run-usermodehelpers-only-on-cpus-allowed-for-kthreadd-v2-checkpatch-fixes.patch
* exitc-call-proc_exit_connector-after-exit_state-is-set.patch
* fs-proc-meminfo-meminfo_proc_show-fix-typo-in-comment.patch
* wait-fix-reparent_leader-vs-exit_dead-exit_zombie-race.patch
* wait-introduce-exit_trace-to-avoid-the-racy-exit_dead-exit_zombie-transition.patch
* wait-use-exit_trace-only-if-thread_group_leaderzombie.patch
* wait-completely-ignore-the-exit_dead-tasks.patch
* wait-swap-exit_zombie-and-exit_dead-to-hide-exit_trace-from-user-space.patch
* wait-wstoppedwcontinued-hangs-if-a-zombie-child-is-traced-by-real_parent.patch
* wait-wstoppedwcontinued-doesnt-work-if-a-zombie-leader-is-traced-by-another-process.patch
* include-linux-crash_dumph-add-vmcore_cleanup-prototype.patch
* include-linux-crash_dumph-add-vmcore_cleanup-prototype-fix.patch
* idr-remove-dead-code-v2.patch
* rapidio-tsi721_dma-optimize-use-of-bdma-descriptors.patch
* rapidio-rework-device-hierarchy-and-introduce-mport-class-of-devices.patch
* fs-adfs-superc-add-__init-to-init_inodecache.patch
* affs-add-__init-to-init_inodecache.patch
* fs-affs-dirc-unlock-brelse-dir-on-failure-code-clean-up.patch
* fs-bfs-inodec-add-__init-to-init_inodecache.patch
* kernel-panicc-display-reason-at-end-pr_emerg.patch
* kernel-panicc-display-reason-at-end-pr_emerg-fix.patch
* pps-add-non-blocking-option-to-pps_fetch-ioctl.patch
* pstore-clarify-clearing-of-_read_cnt-in-ramoops_context.patch
* pstore-skip-zero-size-persistent-ram-buffer-in-traverse.patch
* drivers-misc-sgi-gru-grukdumpc-cleanup-gru_dump_context-a-little.patch
* cris-make-etrax_arch_v10-select-tty-for-use-in-debugport.patch
* cris-cpuinfo_op-should-depend-on-config_proc_fs.patch
* ia64-select-config_tty-for-use-of-tty_write_message-in-unaligned.patch
* ppc-make-ppc_book3s_64-select-irq_work.patch
* s390-select-config_tty-for-use-of-tty-in-unconditional-keyboard-driver.patch
* kconfig-make-allnoconfig-disable-options-behind-embedded-and-expert.patch
* bug-when-config_bug-simplify-warn_on_once-and-family.patch
* include-asm-generic-bugh-style-fix-s-while0-while-0.patch
* bug-when-config_bug-make-warn-call-no_printk-to-check-format-and-args.patch
* bug-make-bug-always-stop-the-machine.patch
* x86-always-define-bug-and-have_arch_bug-even-with-config_bug.patch
* fault-injection-set-bounds-on-what-proc-self-make-it-fail-accepts.patch
* fault-injection-set-bounds-on-what-proc-self-make-it-fail-accepts-fix.patch
* initramfs-debug-detected-compression-method.patch
* initramfs-debug-detected-compression-method-fix.patch
* ipccompat-remove-sc_semopm-macro.patch
* ipc-use-device_initcall.patch
  linux-next.patch
  linux-next-git-rejects.patch
* drivers-gpio-gpio-zevioc-fix-build.patch
* kconfig-rename-has_ioport-to-has_ioport_map.patch
* kernel-used-macros-from-compilerh-instead-of-__attribute__.patch
* asm-systemh-clean-asm-systemh-from-docs.patch
* asm-systemh-um-arch_align_stack-moved-to-asm-exech.patch
* memcg-slab-never-try-to-merge-memcg-caches.patch
* memcg-slab-cleanup-memcg-cache-creation.patch
* memcg-slab-separate-memcg-vs-root-cache-creation-paths.patch
* memcg-slab-unregister-cache-from-memcg-before-starting-to-destroy-it.patch
* memcg-slab-do-not-destroy-children-caches-if-parent-has-aliases.patch
* slub-adjust-memcg-caches-when-creating-cache-alias.patch
* slub-rework-sysfs-layout-for-memcg-caches.patch
* slub-fix-leak-of-name-in-sysfs_slab_add.patch
* w1-call-put_device-if-device_register-fails.patch
* arm-move-arm_dma_limit-to-setup_dma_zone.patch
* percpu-add-raw_cpu_ops.patch
* mm-use-raw_cpu-ops-for-determining-current-numa-node.patch
* modules-use-raw_cpu_write-for-initialization-of-per-cpu-refcount.patch
* net-replace-__this_cpu_inc-in-routec-with-raw_cpu_inc.patch
* percpu-add-preemption-checks-to-__this_cpu-ops.patch
* mm-add-strictlimit-knob-v2.patch
  debugging-keep-track-of-page-owners.patch
  make-sure-nobodys-leaking-resources.patch
  journal_add_journal_head-debug.patch
  journal_add_journal_head-debug-fix.patch
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
