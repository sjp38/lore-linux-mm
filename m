Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 3798E6B0035
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 19:25:15 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id w10so3797243pde.6
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 16:25:14 -0800 (PST)
Received: from mail-pb0-f74.google.com (mail-pb0-f74.google.com [209.85.160.74])
        by mx.google.com with ESMTPS id bc9si5289460pbd.131.2014.01.09.16.25.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 09 Jan 2014 16:25:13 -0800 (PST)
Received: by mail-pb0-f74.google.com with SMTP id uo5so533224pbc.1
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 16:25:13 -0800 (PST)
Subject: mmotm 2014-01-09-16-23 uploaded
From: akpm@linux-foundation.org
Date: Thu, 09 Jan 2014 16:25:11 -0800
Message-Id: <20140110002512.3A5C55A42E7@corp2gmr1-2.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

The mm-of-the-moment snapshot 2014-01-09-16-23 has been uploaded to

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


This mmotm tree contains the following patches against 3.13-rc7:
(patches marked "*" will be included in linux-next)

  origin.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  i-need-old-gcc.patch
* nilfs2-fix-segctor-bug-that-causes-file-system-corruption.patch
* mips-fix-case-mismatch-in-local_r4k_flush_icache_range.patch
* mips-fix-blast_icache32-on-loongson2.patch
* mm-fix-crash-when-using-xfs-on-loopback.patch
* crash_dump-fix-compilation-error-on-mips-at-least.patch
* mm-remove-bug_on-from-mlock_vma_page.patch
* arch-x86-mm-sratc-skip-numa_no_node-while-parsing-slit.patch
* arch-x86-mm-sratc-skip-numa_no_node-while-parsing-slit-fix.patch
* x86-mm-account-for-tlb-flushes-only-when-debugging.patch
* x86-mm-clean-up-inconsistencies-when-flushing-tlb-ranges.patch
* x86-mm-eliminate-redundant-page-table-walk-during-tlb-range-flushing.patch
* x86-mm-change-tlb_flushall_shift-for-ivybridge.patch
* mm-x86-revisit-tlb_flushall_shift-tuning-for-page-flushes-except-on-ivybridge.patch
* arm-move-arm_dma_limit-to-setup_dma_zone.patch
* audit-correct-a-type-mismatch-in-audit_syscall_exit.patch
* inotify-provide-function-for-name-length-rounding.patch
* fsnotify-do-not-share-events-between-notification-groups.patch
* fsnotify-remove-should_send_event-callback.patch
* fsnotify-remove-pointless-null-initializers.patch
* drm-fb-helper-dont-sleep-for-screen-unblank-when-an-oopps-is-in-progress.patch
* drm-cirrus-correct-register-values-for-16bpp.patch
* drm-nouveau-make-vga_switcheroo-code-depend-on-vga_switcheroo.patch
* video-mmp-delete-a-stray-mutex_unlock.patch
* video-mmp-using-plain-integer-as-null-pointer.patch
* intel-iommu-fix-off-by-one-in-pagetable-freeing.patch
* sched_clock-document-4mhz-vs-1mhz-decision.patch
* kernel-time-timekeepingc-fix-comment-for-tk_setup_internals.patch
* input-route-kbd-leds-through-the-generic-leds-layer.patch
* input-route-kbd-leds-through-the-generic-leds-layer-fix.patch
* microblaze-extable-sort-the-exception-table-at-build-time.patch
* jffs2-unlock-f-sem-on-error-in-jffs2_new_inode.patch
* drivers-net-irda-donauboe-convert-to-module_pci_driver.patch
* ocfs2-fix-ocfs2_sync_file-if-filesystem-is-readonly.patch
* ocfs2-remove-versioning-information.patch
* ocfs2-free-allocated-clusters-if-error-occurs-after-ocfs2_claim_clusters.patch
* ocfs2-o2net-incorrect-to-terminate-accepting-connections-loop-upon-rejecting-an-invalid-one.patch
* ocfs2-add-clustername-to-cluster-connection.patch
* ocfs2-add-dlm-recovery-callbacks.patch
* ocfs2-shift-allocation-ocfs2_live_connection-to-user_connect.patch
* ocfs2-pass-ocfs2_cluster_connection-to-ocfs2_this_node.patch
* ocfs2-framework-for-version-lvb.patch
* ocfs2-use-the-new-dlm-operation-callbacks-while-requesting-new-lockspace.patch
* ocfs2-use-the-new-dlm-operation-callbacks-while-requesting-new-lockspace-fix.patch
* ocfs2-remove-redundant-ocfs2_alloc_dinode_update_counts-and-ocfs2_block_group_set_bits.patch
* ocfs2-return-eopnotsupp-if-the-device-does-not-support-discard.patch
* ocfs2-return-einval-if-the-given-range-to-discard-is-less-than-block-size.patch
* ocfs2-adjust-minlen-with-discard_granularity-in-the-fitrim-ioctl.patch
* ocfs2-fix-a-tiny-race-when-running-dirop_fileop_racer.patch
* ocfs2-fix-sparse-non-static-symbol-warning.patch
* ocfs2-punch-hole-should-return-einval-if-the-length-argument-in-ioctl-is-negative.patch
* ocfs2-o2net-o2net_listen_data_ready-should-do-nothing-if-socket-state-is-not-tcp_listen.patch
* ocfs2-check-existence-of-old-dentry-in-ocfs2_link.patch
* ocfs2-fix-null-pointer-dereference-when-dismount-and-ocfs2rec-simultaneously.patch
* ocfs2-should-call-ocfs2_journal_access_di-before-ocfs2_delete_entry-in-ocfs2_orphan_del.patch
* ocfs2-llseek-requires-ocfs2-inode-lock-for-the-file-in-seek_end.patch
* ocfs2-fix-issue-that-ocfs2_setattr-does-not-deal-with-new_i_size==i_size.patch
* ocfs2-update-inode-size-after-zeronig-the-hole.patch
* drivers-scsi-megaraid-megaraid_mmc-missing-bounds-check-in-mimd_to_kioc.patch
* drivers-block-sx8c-use-module_pci_driver.patch
* drivers-block-sx8c-remove-unnecessary-pci_set_drvdata.patch
* drivers-block-paride-pgc-underflow-bug-in-pg_write.patch
* drivers-block-ccissc-cciss_init_one-use-proper-errnos.patch
* drivers-block-loopc-fix-comment-typo-in-loop_config_discard.patch
* block-remove-unrelated-header-files-and-export-symbol.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* posix_acl-uninlining.patch
* fs-compat_ioctlc-fix-an-underflow-issue-harmless.patch
* fs-read_writec-compat_readv-remove-bogus-area-verify.patch
* fs-superc-fix-warn-on-alloc_super-fail-path.patch
* watchdog-trigger-all-cpu-backtrace-when-locked-up-and-going-to-panic.patch
  mm.patch
* mm-hugetlbfs-add-some-vm_bug_ons-to-catch-non-hugetlbfs-pages.patch
* mm-hugetlb-use-get_page_foll-in-follow_hugetlb_page.patch
* mm-hugetlbfs-move-the-put-get_page-slab-and-hugetlbfs-optimization-in-a-faster-path.patch
* mm-hugetlbfs-move-the-put-get_page-slab-and-hugetlbfs-optimization-in-a-faster-path-fix-2.patch
* mm-thp-optimize-compound_trans_huge.patch
* mm-tail-page-refcounting-optimization-for-slab-and-hugetlbfs.patch
* mm-hugetlbfs-use-__compound_tail_refcounted-in-__get_page_tail-too.patch
* mm-hugetlbc-simplify-pageheadhuge-and-pagehuge.patch
* mm-swapc-reorganize-put_compound_page.patch
* mm-hugetlbc-defer-pageheadhuge-symbol-export.patch
* mm-thp-__get_page_tail_foll-can-use-get_huge_page_tail.patch
* mm-thp-turn-compound_head-into-bug_onpagetail-in-get_huge_page_tail.patch
* proc-meminfo-provide-estimated-available-memory.patch
* mm-get-rid-of-unnecessary-pageblock-scanning-in-setup_zone_migrate_reserve.patch
* mm-get-rid-of-unnecessary-pageblock-scanning-in-setup_zone_migrate_reserve-fix.patch
* mm-create-a-separate-slab-for-page-ptl-allocation-try-two.patch
* mm-memory-failure-fix-the-typo-in-me_pagecache_dirty.patch
* mm-memory-failure-fix-the-typo-in-me_pagecache_dirty-fix.patch
* mm-call-mmu-notifiers-when-copying-a-hugetlb-page-range.patch
* mm-mempolicy-remove-unneeded-functions-for-uma-configs.patch
* mm-vmalloc-interchage-the-implementation-of-vmalloc_to_pfnpage.patch
* mm-vmalloc-interchage-the-implementation-of-vmalloc_to_pfnpage-fix.patch
* mm-show_mem-remove-show_mem_filter_page_count.patch
* mm-show_mem-remove-show_mem_filter_page_count-fix.patch
* mm-add-overcommit_kbytes-sysctl-variable.patch
* mm-add-overcommit_kbytes-sysctl-variable-checkpatch-fixes.patch
* mm-add-overcommit_kbytes-sysctl-variable-fix.patch
* mm-add-overcommit_kbytes-sysctl-variable-fix-2.patch
* mm-mmapc-add-mlock_future_check-helper.patch
* mm-mlock-prepare-params-outside-critical-region.patch
* mm-memblock-debug-correct-displaying-of-upper-memory-boundary.patch
* memblock-numa-introduce-flags-field-into-memblock.patch
* memblock-mem_hotplug-introduce-memblock_hotplug-flag-to-mark-hotpluggable-regions.patch
* memblock-mem_hotplug-introduce-memblock_hotplug-flag-to-mark-hotpluggable-regions-checkpatch-fixes.patch
* memblock-make-memblock_set_node-support-different-memblock_type.patch
* memblock-make-memblock_set_node-support-different-memblock_type-fix.patch
* acpi-numa-mem_hotplug-mark-hotpluggable-memory-in-memblock.patch
* acpi-numa-mem_hotplug-mark-hotpluggable-memory-in-memblock-checkpatch-fixes.patch
* acpi-numa-mem_hotplug-mark-all-nodes-the-kernel-resides-un-hotpluggable.patch
* memblock-mem_hotplug-make-memblock-skip-hotpluggable-regions-if-needed.patch
* memblock-mem_hotplug-make-memblock-skip-hotpluggable-regions-if-needed-checkpatch-fixes.patch
* x86-numa-acpi-memory-hotplug-make-movable_node-have-higher-priority.patch
* memcg-fix-kmem_account_flags-check-in-memcg_can_account_kmem.patch
* memcg-make-memcg_update_cache_sizes-static.patch
* mm-rmap-recompute-pgoff-for-huge-page.patch
* mm-rmap-factor-nonlinear-handling-out-of-try_to_unmap_file.patch
* mm-rmap-factor-lock-function-out-of-rmap_walk_anon.patch
* mm-rmap-make-rmap_walk-to-get-the-rmap_walk_control-argument.patch
* mm-rmap-extend-rmap_walk_xxx-to-cope-with-different-cases.patch
* mm-rmap-use-rmap_walk-in-try_to_unmap.patch
* mm-rmap-use-rmap_walk-in-try_to_munlock.patch
* mm-rmap-use-rmap_walk-in-page_referenced.patch
* mm-rmap-use-rmap_walk-in-page_referenced-fix.patch
* mm-rmap-use-rmap_walk-in-page_mkclean.patch
* introduce-for_each_thread-to-replace-the-buggy-while_each_thread.patch
* oom_kill-change-oom_killc-to-use-for_each_thread.patch
* oom_kill-has_intersects_mems_allowed-needs-rcu_read_lock.patch
* oom_kill-add-rcu_read_lock-into-find_lock_task_mm.patch
* mm-page_alloc-allow-__gfp_nofail-to-allocate-below-watermarks-after-reclaim.patch
* x86-memblock-set-current-limit-to-max-low-memory-address.patch
* mm-memblock-debug-dont-free-reserved-array-if-arch_discard_memblock.patch
* mm-bootmem-remove-duplicated-declaration-of-__free_pages_bootmem.patch
* mm-memblock-remove-unnecessary-inclusions-of-bootmemh.patch
* mm-memblock-drop-warn-and-use-smp_cache_bytes-as-a-default-alignment.patch
* mm-memblock-reorder-parameters-of-memblock_find_in_range_node.patch
* mm-memblock-switch-to-use-numa_no_node-instead-of-max_numnodes.patch
* mm-memblock-add-memblock-memory-allocation-apis.patch
* mm-memblock-add-memblock-memory-allocation-apis-fix.patch
* mm-memblock-add-memblock-memory-allocation-apis-fix-2.patch
* mm-memblock-add-memblock-memory-allocation-apis-fix-3.patch
* mm-memblock-add-memblock-memory-allocation-apis-fix-4.patch
* mm-init-use-memblock-apis-for-early-memory-allocations.patch
* mm-printk-use-memblock-apis-for-early-memory-allocations.patch
* mm-page_alloc-use-memblock-apis-for-early-memory-allocations.patch
* mm-power-use-memblock-apis-for-early-memory-allocations.patch
* lib-swiotlbc-use-memblock-apis-for-early-memory-allocations.patch
* lib-cpumaskc-use-memblock-apis-for-early-memory-allocations.patch
* mm-sparse-use-memblock-apis-for-early-memory-allocations.patch
* mm-hugetlb-use-memblock-apis-for-early-memory-allocations.patch
* mm-page_cgroup-use-memblock-apis-for-early-memory-allocations.patch
* mm-percpu-use-memblock-apis-for-early-memory-allocations.patch
* mm-memory_hotplug-use-memblock-apis-for-early-memory-allocations.patch
* drivers-firmware-memmapc-use-memblock-apis-for-early-memory-allocations.patch
* arch-arm-kernel-use-memblock-apis-for-early-memory-allocations.patch
* arch-arm-mm-initc-use-memblock-apis-for-early-memory-allocations.patch
* arch-arm-mach-omap2-omap_hwmodc-use-memblock-apis-for-early-memory-allocations.patch
* x86-mm-memblock-switch-to-use-numa_no_node.patch
* mm-memblock-use-warn_once-when-max_numnodes-passed-as-input-parameter.patch
* mm-arm-fix-arms-__ffs-to-conform-to-avoid-warning-with-no_bootmem.patch
* mm-hwpoison-add-to-hwpoison_inject.patch
* lib-show_memc-show-num_poisoned_pages-when-oom.patch
* mm-numa-make-numa-migrate-related-functions-static.patch
* mm-numa-limit-scope-of-lock-for-numa-migrate-rate-limiting.patch
* mm-numa-trace-tasks-that-fail-migration-due-to-rate-limiting.patch
* mm-numa-do-not-automatically-migrate-ksm-pages.patch
* sched-add-tracepoints-related-to-numa-task-migration.patch
* sched-add-tracepoints-related-to-numa-task-migration-fix.patch
* memcg-oom-lock-mem_cgroup_print_oom_info.patch
* mm-compaction-trace-compaction-begin-and-end.patch
* mm-compaction-encapsulate-defer-reset-logic.patch
* mm-compaction-reset-cached-scanner-pfns-before-reading-them.patch
* mm-compaction-detect-when-scanners-meet-in-isolate_freepages.patch
* mm-compaction-do-not-mark-unmovable-pageblocks-as-skipped-in-async-compaction.patch
* mm-compaction-reset-scanner-positions-immediately-when-they-meet.patch
* mm-page_alloc-warn-for-non-blockable-__gfp_nofail-allocation-failure.patch
* mm-migrate-add-comment-about-permanent-failure-path.patch
* mm-migrate-correct-failure-handling-if-hugepage_migration_support.patch
* mm-migrate-remove-putback_lru_pages-fix-comment-on-putback_movable_pages.patch
* mm-migrate-remove-unused-function-fail_migrate_page.patch
* mm-documentation-remove-hopelessly-out-of-date-locking-doc.patch
* mm-zswapc-change-params-from-hidden-to-ro.patch
* mm-print-more-details-for-bad_page.patch
* mm-print-more-details-for-bad_page-fix.patch
* mm-munlock-fix-potential-race-with-thp-page-split.patch
* mm-munlock-fix-potential-race-with-thp-page-split-fix.patch
* memcg-do-not-use-vmalloc-for-mem_cgroup-allocations.patch
* fs-proc-pagec-add-pageanon-check-to-surely-detect-thp.patch
* mm-dump-page-when-hitting-a-vm_bug_on-using-vm_bug_on_page.patch
* mm-dump-page-when-hitting-a-vm_bug_on-using-vm_bug_on_page-fix.patch
* mm-dump-page-when-hitting-a-vm_bug_on-using-vm_bug_on_page-fix-fix.patch
* mm-fix-the-theoretical-compound_lock-vs-prep_new_page-race.patch
* slab-clean-up-kmem_cache_create_memcg-error-handling.patch
* memcg-slab-kmem_cache_create_memcg-fix-memleak-on-fail-path.patch
* memcg-slab-kmem_cache_create_memcg-fix-memleak-on-fail-path-fix.patch
* memcg-slab-clean-up-memcg-cache-initialization-destruction.patch
* memcg-slab-fix-barrier-usage-when-accessing-memcg_caches.patch
* memcg-fix-possible-null-deref-while-traversing-memcg_slab_caches-list.patch
* memcg-slab-fix-races-in-per-memcg-cache-creation-destruction.patch
* memcg-get-rid-of-kmem_cache_dup.patch
* slab-do-not-panic-if-we-fail-to-create-memcg-cache.patch
* memcg-slab-rcu-protect-memcg_params-for-root-caches.patch
* memcg-remove-kmem_accounted_activated-flag.patch
* memcg-rework-memcg_update_kmem_limit-synchronization.patch
* mm-nobootmemc-add-return-value-check-in-__alloc_memory_core_early.patch
* mm-free-memblockmemory-in-free_all_bootmem.patch
* mm-free-memblockmemory-in-free_all_bootmem-fix.patch
* numa-add-a-sysctl-for-numa_balancing.patch
* numa-add-a-sysctl-for-numa_balancing-fix.patch
* mm-memory-failurec-shift-page-lock-from-head-page-to-tail-page-after-thp-split.patch
* mm-new_vma_page-cannot-see-null-vma-for-hugetlb-pages.patch
* mm-prevent-setting-of-a-value-less-than-0-to-min_free_kbytes.patch
* mm-blk-mq-uses-page-list-incorrectly.patch
* documentation-trace-postprocess-trace-vmscan-postprocesspl-fix-the-traceevent-regex.patch
* memcg-do-not-hang-on-oom-when-killed-by-userspace-oom-access-to-memory-reserves.patch
* swap-fix-setting-page_size-blocksize-during-swapoff-swapon-race.patch
* swap-add-a-simple-detector-for-inappropriate-swapin-readahead.patch
* swap-add-a-simple-detector-for-inappropriate-swapin-readahead-fix.patch
* kernel-use-lockless-list-for-smp_call_function_single.patch
* asm-typesh-remove-include-asm-generic-int-l64h.patch
* drivers-mailbox-omap-make-mbox-irq-signed-for-error-handling.patch
* drivers-block-kconfig-update-ram-block-device-module-name.patch
* logfs-check-for-the-return-value-after-calling-find_or_create_page.patch
* add-generic-fixmaph.patch
* x86-use-generic-fixmaph.patch
* arm-use-generic-fixmaph.patch
* hexagon-use-generic-fixmaph.patch
* metag-use-generic-fixmaph.patch
* microblaze-use-generic-fixmaph.patch
* mips-use-generic-fixmaph.patch
* powerpc-use-generic-fixmaph.patch
* sh-use-generic-fixmaph.patch
* tile-use-generic-fixmaph.patch
* um-use-generic-fixmaph.patch
* conditionally-define-u32_max.patch
* kernelh-define-u8-s8-u32-etc-limits.patch
* remove-extra-definitions-of-u32_max.patch
* include-linux-ofh-make-for_each_child_of_node-reference-its-args-when-config_of=n.patch
* drivers-gpu-drm-gma500-backlightc-fix-a-defined-but-not-used-warning-for-do_gma_backlight_set.patch
* drivers-mfd-max8998c-fix-pointer-integer-size-mismatch-warning-in-max8998_i2c_get_driver_data.patch
* drivers-mfd-tps65217c-fix-pointer-integer-size-mismatch-warning-in-tps65217_probe.patch
* drivers-video-aty-aty128fbc-fix-a-warning-pertaining-to-the-aty128fb-backlight-variable.patch
* kernel-smpc-remove-cpumask_ipi.patch
* drivers-misc-mei-ratelimit-several-error-messages.patch
* drivers-misc-ti-st-st_corec-fix-null-dereference-on-protocol-type-check.patch
* lib-parserc-add-match_wildcard-function.patch
* lib-parserc-put-export_symbols-in-the-conventional-place.patch
* dynamic_debug-add-wildcard-support-to-filter-files-functions-modules.patch
* dynamic-debug-howtotxt-update-since-new-wildcard-support.patch
* printk-cache-mark-printk_once-test-variable-__read_mostly.patch
* printk-cache-mark-printk_once-test-variable-__read_mostly-fix.patch
* vsprintf-add-%pad-extension-for-dma_addr_t-use.patch
* printk-flush-conflicting-continuation-line.patch
* printk-flush-conflicting-continuation-line-fix.patch
* get_maintainer-add-commit-author-information-to-rolestats.patch
* maintainers-add-an-entry-for-the-macintosh-hfsplus-filesystem.patch
* maintainers-describe-differences-between-f-and-n-patterns.patch
* backlight-jornada720-use-devm_backlight_device_register.patch
* backlight-hp680_bl-use-devm_backlight_device_register.patch
* backlight-omap1-use-devm_backlight_device_register.patch
* backlight-ot200_bl-use-devm_backlight_device_register.patch
* backlight-tosa-use-devm_backlight_device_register.patch
* backlight-jornada720-use-devm_lcd_device_register.patch
* backlight-l4f00242t03-use-devm_lcd_device_register.patch
* backlight-tosa-use-devm_lcd_device_register.patch
* drivers-video-backlight-backlightc-remove-backlight-sysfs-uevent.patch
* backlight-kb3886_bl-fix-incorrect-placement-of-__initdata-marker.patch
* backlight-lp855x-remove-unnecessary-parentheses.patch
* backlight-lp8788-remove-unnecessary-parentheses.patch
* kstrtox-remove-redundant-cleanup.patch
* cmdline-fix-style-issues.patch
* lib-cmdlinec-declare-exported-symbols-immediately.patch
* test-add-minimal-module-for-verification-testing.patch
* test-check-copy_to-from_user-boundary-validation.patch
* test-check-copy_to-from_user-boundary-validation-fix.patch
* lib-assoc_arrayc-remove-global-variable.patch
* lib-percpu_counterc-disable-local-irq-when-updating-percpu-couter.patch
* lib-add-crc64-ecma-module.patch
* firmware-dmi_scan-generalize-for-use-by-other-archs.patch
* checkpatch-more-comprehensive-split-strings-warning.patch
* checkpatch-warn-only-on-space-before-semicolon-at-end-of-line.patch
* checkpatch-add-warning-of-future-__gfp_nofail-use.patch
* checkpatch-attempt-to-find-missing-switch-case-break.patch
* checkpatch-add-a-fix-inplace-option.patch
* checkpatch-improve-space-before-tab-fix-option.patch
* checkpatch-check-for-ifs-with-unnecessary-parentheses.patch
* checkpatch-update-the-fsf-gpl-address-check.patch
* checkpatch-add-tests-for-function-pointer-style-misuses.patch
* checkpatch-only-flag-fsf-address-not-gnuorg-url.patch
* fs-binfmt_elf-remove-unused-defines-interpreter_none-and-interpreter_elf.patch
* binfmt_elfc-use-get_random_int-to-fix-entropy-depleting.patch
* fs-ramfs-file-nommuc-make-ramfs_nommu_get_unmapped_area-and-ramfs_nommu_mmap-static.patch
* fs-ramfs-move-ramfs_aops-to-inodec.patch
* init-mainc-remove-unused-declaration-of-tc_init.patch
* autofs4-allow-autofs-to-work-outside-the-initial-pid-namespace.patch
* autofs4-translate-pids-to-the-right-namespace-for-the-daemon.patch
* autofs-fix-the-return-value-of-autofs4_fill_super.patch
* autofs-use-is_root-to-replace-root-dentry-checks.patch
* autofs-fix-symlinks-arent-checked-for-expiry.patch
* drivers-rtc-rtc-as3722-use-devm-for-rtc-and-irq-registration.patch
* rtc-ds1305-remove-unnecessary-spi_set_drvdata.patch
* drivers-rtc-rtc-mxcc-remove-unneeded-label.patch
* drivers-rtc-rtc-mxcc-check-the-return-value-from-clk_prepare_enable.patch
* drivers-rtc-rtc-ds1742c-add-devicetree-support.patch
* rtc-rtc-twl-use-devm_-functions.patch
* rtc-rtc-vr41xx-use-devm_-functions.patch
* dt-bindings-add-hym8563-binding.patch
* rtc-add-hym8563-rtc-driver.patch
* rtc-add-hym8563-rtc-driver-fix.patch
* rtc-rtc-cmos-remove-superfluous-name-cast.patch
* rtc-disable-rtc_drv_cmos-on-atari.patch
* drivers-rtc-rtc-pcf2127c-replace-is_err-and-ptr_err-with-ptr_err_or_zero.patch
* rtc-honor-device-tree-alias-entries-when-assigning-ids.patch
* rtc-honor-device-tree-alias-entries-when-assigning-ids-v2.patch
* drivers-rtc-rtc-cmosc-propagate-hpet_register_irq_handler-failure.patch
* drivers-rtc-rtc-ds1742c-remove-redundant-of_match_ptr-helper.patch
* drivers-rtc-rtc-hym8563c-remove-redundant-of_match_ptr-helper.patch
* drivers-rtc-rtc-hym8563c-staticize-local-symbol.patch
* drivers-rtc-rtc-s5mc-s5m_rtc_suspendresume-should-depend-on-config_pm_sleep.patch
* fs-pipec-skip-file_update_time-on-frozen-fs.patch
* fs-nilfs2-fix-integer-overflow-in-nilfs_ioctl_wrap_copy.patch
* fs-nilfs2-fix-integer-overflow-in-nilfs_ioctl_wrap_copy-fix.patch
* nilfs2-add-comments-for-ioctls.patch
* hfsplus-remove-hfsplus_file_lookup.patch
* ufs-sb-mutex-merge-mutex_destroy.patch
* fat-add-i_disksize-to-represent-uninitialized-size.patch
* fat-add-fat_fallocate-operation.patch
* fat-zero-out-seek-range-on-_fat_get_block.patch
* fat-fallback-to-buffered-write-in-case-of-fallocated-region-on-direct-io.patch
* fat-permit-to-return-phy-block-number-by-fibmap-in-fallocated-region.patch
* fat-update-the-limitation-for-fat-fallocate.patch
* documentation-filesystems-sysfstxt-fix-device_attribute-declaration.patch
* documentation-blockdev-ramdisktxt-updates.patch
* doc-kmemcheck-add-kmemcheck-to-kernel-parameterstxt.patch
* documentation-filesystems-00-index-updates.patch
* kconfig-update-flightly-outdated-config_smp-documentation.patch
* documentation-update-firewire-debugging-documentation.patch
* kmod-run-usermodehelpers-only-on-cpus-allowed-for-kthreadd-v2.patch
* kmod-run-usermodehelpers-only-on-cpus-allowed-for-kthreadd-v2-fix.patch
* kmod-run-usermodehelpers-only-on-cpus-allowed-for-kthreadd-v2-checkpatch-fixes.patch
* coredump-set_dumpable-fix-the-theoretical-race-with-itself.patch
* coredump-kill-mmf_dumpable-and-mmf_dump_securely.patch
* coredump-make-__get_dumpable-get_dumpable-inline-kill-fs-coredumph.patch
* proc-cleanup-simplify-get_task_state-task_state_array.patch
* proc-fix-the-potential-use-after-free-in-first_tid.patch
* proc-change-first_tid-to-use-while_each_thread-rather-than-next_thread.patch
* proc-dont-abuse-group_leader-in-proc_task_readdir-paths.patch
* proc-fix-f_pos-overflows-in-first_tid.patch
* proc-set-attributes-of-pde-using-accessor-functions.patch
* fs-proc-proc_devtreec-remove-empty-proc-device-tree-when-no-openfirmware-exists.patch
* kernel-forkc-make-dup_mm-static.patch
* kernel-forkc-fix-coding-style-issues.patch
* kernel-forkc-remove-redundant-null-check-in-dup_mm.patch
* exec-check_unsafe_exec-use-while_each_thread-rather-than-next_thread.patch
* exec-check_unsafe_exec-kill-the-dead-eagain-and-clear_in_exec-logic.patch
* exec-move-the-final-allow_write_access-fput-into-free_bprm.patch
* exec-kill-task_struct-did_exec.patch
* fs-proc-arrayc-change-do_task_stat-to-use-while_each_thread.patch
* kernel-sysc-k_getrusage-can-use-while_each_thread.patch
* kernel-signalc-change-do_signal_stop-do_sigaction-to-use-while_each_thread.patch
* kexec-add-sysctl-to-disable-kexec_load.patch
* partitions-efi-complete-documentation-of-gpt-kernel-param-purpose.patch
* rapidio-add-modular-rapidio-core-build-into-powerpc-and-mips-branches.patch
* rbtree-test-move-rb_node-to-the-middle-of-the-test-struct.patch
* rbtree-test-test-rbtree_postorder_for_each_entry_safe.patch
* net-netfilter-ipset-ip_set_hash_netifacec-use-rbtree-postorder-iteration-instead-of-opencoding.patch
* fs-ubifs-use-rbtree-postorder-iteration-helper-instead-of-opencoding.patch
* fs-ext4-use-rbtree-postorder-iteration-helper-instead-of-opencoding.patch
* fs-jffs2-use-rbtree-postorder-iteration-helper-instead-of-opencoding.patch
* fs-ext3-use-rbtree-postorder-iteration-helper-instead-of-opencoding.patch
* fs-ext3-use-rbtree-postorder-iteration-helper-instead-of-opencoding-fix.patch
* arch-sh-kernel-dwarfc-use-rbtree-postorder-iteration-helper-instead-of-solution-using-repeated-rb_erase.patch
* userns-relax-the-posix_acl_valid-checks.patch
* futex-switch-to-user_ds-for-futex-test.patch
* afs-proc-cells-and-rootcell-are-writeable.patch
* pps-add-non-blocking-option-to-pps_fetch-ioctl.patch
* drivers-memstick-host-rtsx_pci_msc-fix-ms-card-data-transfer-bug.patch
* drivers-w1-masters-w1-gpioc-add-strong-pullup-emulation.patch
* romfs-fix-returm-err-while-getting-inode-in-fill_super.patch
* lib-decompress_unlz4c-always-set-an-error-return-code-on-failures.patch
* ipc-semc-avoid-overflow-of-semop-undo-semadj-value.patch
* ipc-semc-avoid-overflow-of-semop-undo-semadj-value-fix.patch
* ipc-semc-avoid-overflow-of-semop-undo-semadj-value-fix-2.patch
* ipc-introduce-ipc_valid_object-helper-to-sort-out-ipc_rmid-races.patch
* ipc-change-kern_ipc_permdeleted-type-to-bool.patch
* ipc-whitespace-cleanup.patch
  linux-next.patch
* net-ipv6-ip6_vtic-fix-build.patch
* kernel-kexecc-use-vscnprintf-instead-of-vsnprintf-in-vmcoreinfo_append_str.patch
* softirq-use-ffs-in-__do_softirq.patch
* softirq-convert-printks-to-pr_level.patch
* softirq-use-const-char-const-for-softirq_to_name-whitespace-neatening.patch
* mm-migratec-fix-set-cpupid-on-page-migration-twice-against-thp.patch
* mm-migratec-fix-setting-of-cpupid-on-page-migration-twice-against-normal-page.patch
* zsmalloc-move-it-under-mm.patch
* zram-promote-zram-from-staging.patch
* w1-call-put_device-if-device_register-fails.patch
* backlight-lcd-call-put_device-if-device_register-fails.patch
* net-phy-call-put_device-on-device_register-failure.patch
* checkpatchpl-check-for-function-declarations-without-arguments.patch
* zram-remove-old-private-project-comment.patch
* zram-add-copyright.patch
* zsmalloc-add-copyright.patch
* zram-add-zram-maintainers.patch
* zsmalloc-add-maintainers.patch
* block-blk-mq-cpuc-use-hotcpu_notifier.patch
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
