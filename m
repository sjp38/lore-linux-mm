Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 079556B0037
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 18:25:32 -0500 (EST)
Received: by mail-ie0-f169.google.com with SMTP id to1so655859ieb.0
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 15:25:31 -0800 (PST)
Received: from mail-ie0-f201.google.com (mail-ie0-f201.google.com [209.85.223.201])
        by mx.google.com with ESMTPS id mu10si27330138icc.16.2014.03.03.15.25.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Mar 2014 15:25:31 -0800 (PST)
Received: by mail-ie0-f201.google.com with SMTP id rd18so158086iec.0
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 15:25:31 -0800 (PST)
Subject: mmotm 2014-03-03-15-24 uploaded
From: akpm@linux-foundation.org
Date: Mon, 03 Mar 2014 15:25:29 -0800
Message-Id: <20140303232530.2AC4131C2A3@corp2gmr1-1.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

The mm-of-the-moment snapshot 2014-03-03-15-24 has been uploaded to

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


This mmotm tree contains the following patches against 3.14-rc5:
(patches marked "*" will be included in linux-next)

  arch-alpha-kernel-systblss-remove-debug-check.patch
  i-need-old-gcc.patch
  maintainers-akpm-maintenance.patch
* maintainers-add-mauro-and-borislav-as-interim-patch-collectors.patch
* mm-close-pagetail-race.patch
* mm-page_alloc-make-first_page-visible-before-pagetail.patch
* dma-debug-account-for-cachelines-and-read-only-mappings-in-overlap-tracking.patch
* dma-debug-account-for-cachelines-and-read-only-mappings-in-overlap-tracking-v2.patch
* swapoff-tmpfs-radix_tree-remember-to-rcu_read_unlock.patch
* memcg-fix-endless-loop-in-__mem_cgroup_iter_next.patch
* memcg-reparent-charges-of-children-before-processing-parent.patch
* mm-include-vm_mixedmap-flag-in-the-vm_special-list-to-avoid-munlocking.patch
* scripts-gen_initramfs_listsh-fix-flags-for-initramfs-lz4-compression.patch
* kallsyms-fix-absolute-addresses-for-kaslr.patch
* drivers-rtc-rtc-s3cc-fix-incorrect-way-of-save-restore-of-s3c2410_ticnt-for-type_s3c64xx.patch
* ocfs2-fix-quota-file-corruption.patch
* sh-prefix-sh-specific-ccr-and-ccr2-by-sh_.patch
* zram-avoid-null-access-when-fail-to-alloc-meta.patch
* hfsplus-fix-remount-issue.patch
* rapidio-tsi721-fix-tasklet-termination-in-dma-channel-release.patch
* rapidio-tsi721-fix-tasklet-termination-in-dma-channel-release-v2.patch
* maintainers-use-tab-for-separator.patch
* maintainers-add-and-correct-types-of-some-t-entries.patch
* mm-numa-bugfix-for-last_cpupid_not_in_page_flags-v3.patch
* mm-page_alloc-reset-aging-cycle-with-gfp_thisnode-v2.patch
* backing_dev-fix-hung-task-on-sync.patch
* audit-use-struct-net-not-pid_t-to-remember-the-network-namespce-to-reply-in.patch
* kthread-ensure-locality-of-task_struct-allocations.patch
* arch-x86-mm-kmemcheck-kmemcheckc-use-kstrtoint-instead-of-sscanf.patch
* arm-use-generic-fixmaph.patch
* fs-cifs-cifsfsc-add-__init-to-cifs_init_inodecache.patch
* sched_clock-document-4mhz-vs-1mhz-decision.patch
* input-route-kbd-leds-through-the-generic-leds-layer.patch
* sh-push-extra-copy-of-r0-r2-for-syscall-parameters.patch
* sh-remove-unused-do_fpu_error.patch
* sh-dont-pass-saved-userspace-state-to-exception-handlers.patch
* arch-sh-boards-board-sh7757lcrc-fixup-sdhi-register-size.patch
* fs-udf-superc-add-__init-to-init_inodecache.patch
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
* ocfs2-flock-drop-cross-node-lock-when-failed-locally.patch
* ocfs2-flock-drop-cross-node-lock-when-failed-locally-checkpatch-fixes.patch
* ocfs2-should-call-ocfs2_journal_access_di-before-ocfs2_delete_entry-in-ocfs2_orphan_del.patch
* ocfs2-llseek-requires-ocfs2-inode-lock-for-the-file-in-seek_end.patch
* drivers-scsi-megaraid-megaraid_mmc-missing-bounds-check-in-mimd_to_kioc.patch
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
* memcg-slab-never-try-to-merge-memcg-caches.patch
* memcg-slab-cleanup-memcg-cache-creation.patch
* memcg-slab-separate-memcg-vs-root-cache-creation-paths.patch
* memcg-slab-unregister-cache-from-memcg-before-starting-to-destroy-it.patch
* memcg-slab-do-not-destroy-children-caches-if-parent-has-aliases.patch
* slub-adjust-memcg-caches-when-creating-cache-alias.patch
* slub-rework-sysfs-layout-for-memcg-caches.patch
* mm-compaction-disallow-high-order-page-for-migration-target.patch
* mm-compaction-do-not-call-suitable_migration_target-on-every-page.patch
* mm-compaction-change-the-timing-to-check-to-drop-the-spinlock.patch
* mm-compaction-check-pageblock-suitability-once-per-pageblock.patch
* mm-compaction-clean-up-code-on-success-of-ballon-isolation.patch
* mm-fix-gfp_thisnode-callers-and-clarify.patch
* mm-revert-thp-make-madv_hugepage-check-for-mm-def_flags.patch
* mm-revert-thp-make-madv_hugepage-check-for-mm-def_flags-ignore-madv_hugepage-on-s390-to-prevent-sigsegv-in-qemu.patch
* mm-thp-add-vm_init_def_mask-and-prctl_thp_disable.patch
* exec-kill-the-unnecessary-mm-def_flags-setting-in-load_elf_binary.patch
* mm-disable-split-page-table-lock-for-mmu.patch
* tools-vm-page-typesc-page-cache-sniffing-feature.patch
* drivers-lguest-page_tablesc-rename-do_set_pte.patch
* mm-introduce-vm_ops-map_pages.patch
* mm-implement-map_pages-for-page-cache.patch
* mm-implement-map_pages-for-page-cache-fix.patch
* mm-cleanup-size-checks-in-filemap_fault-and-filemap_map_pages.patch
* mm-add-debugfs-tunable-for-fault_around_order.patch
* mm-add-debugfs-tunable-for-fault_around_order-checkpatch-fixes.patch
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
* mm-zswap-fix-trivial-typo-and-arrange-indentation.patch
* mm-zswap-update-zsmalloc-in-comment-to-zbud.patch
* mm-zswap-support-multiple-swap-devices.patch
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
* fs-minix-inodec-add-__init-to-init_inodecache.patch
* befs-replace-kmalloc-memset-0-by-kzalloc.patch
* fs-befs-linuxvfsc-add-__init-to-befs_init_inodecache.patch
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
* hfsplus-add-hfsx-subfolder-count-support.patch
* hfsplus-remove-unused-variable-in-hfsplus_get_block.patch
* hfsplus-fix-concurrent-acess-of-alloc_blocks.patch
* hfsplus-fix-concurrent-acess-of-alloc_blocks-fix.patch
* hfsplus-fix-concurrent-acess-of-alloc_blocks-fix-fix.patch
* hfsplus-fix-longname-handling.patch
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
* rapidio-tsi721_dma-optimize-use-of-bdma-descriptors.patch
* rapidio-rework-device-hierarchy-and-introduce-mport-class-of-devices.patch
* fs-adfs-superc-add-__init-to-init_inodecache.patch
* affs-add-__init-to-init_inodecache.patch
* fs-affs-dirc-unlock-brelse-dir-on-failure-code-clean-up.patch
* kernel-panicc-display-reason-at-end-pr_emerg.patch
* kernel-panicc-display-reason-at-end-pr_emerg-fix.patch
* pps-add-non-blocking-option-to-pps_fetch-ioctl.patch
* drivers-misc-sgi-gru-grukdumpc-cleanup-gru_dump_context-a-little.patch
* kconfig-make-allnoconfig-disable-options-behind-embedded-and-expert.patch
* bug-when-config_bug-simplify-warn_on_once-and-family.patch
* include-asm-generic-bugh-style-fix-s-while0-while-0.patch
* bug-when-config_bug-make-warn-call-no_printk-to-check-format-and-args.patch
* bug-use-a-common-definition-of-bug_on-regardless-of-config_bug.patch
* fault-injection-set-bounds-on-what-proc-self-make-it-fail-accepts.patch
* fault-injection-set-bounds-on-what-proc-self-make-it-fail-accepts-fix.patch
* initramfs-debug-detected-compression-method.patch
* initramfs-debug-detected-compression-method-fix.patch
* ipccompat-remove-sc_semopm-macro.patch
* ipc-use-device_initcall.patch
  linux-next.patch
* kconfig-rename-has_ioport-to-has_ioport_map.patch
* kernel-used-macros-from-compilerh-instead-of-__attribute__.patch
* asm-systemh-clean-asm-systemh-from-docs.patch
* asm-systemh-um-arch_align_stack-moved-to-asm-exech.patch
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
