Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 470D982F69
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 19:16:31 -0400 (EDT)
Received: by qkbi190 with SMTP id i190so4757274qkb.1
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 16:16:31 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 21si3008548qhg.85.2015.09.30.16.16.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Sep 2015 16:16:30 -0700 (PDT)
Date: Wed, 30 Sep 2015 16:16:28 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2015-09-30-16-16 uploaded
Message-ID: <560c6d4c.ya/7b78XrP7iyek1%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz

The mm-of-the-moment snapshot 2015-09-30-16-16 has been uploaded to

   http://www.ozlabs.org/~akpm/mmotm/

mmotm-readme.txt says

README for mm-of-the-moment:

http://www.ozlabs.org/~akpm/mmotm/

This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
more than once a week.

You will need quilt to apply these patches to the latest Linus release (4.x
or 4.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
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

http://git.cmpxchg.org/cgit.cgi/linux-mmotm.git/

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

	http://git.cmpxchg.org/cgit.cgi/linux-mmots.git/

and use of this tree is similar to
http://git.cmpxchg.org/cgit.cgi/linux-mmotm.git/, described above.


This mmotm tree contains the following patches against 4.3-rc3:
(patches marked "*" will be included in linux-next)

  origin.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  drivers-gpu-drm-i915-intel_spritec-fix-build.patch
  drivers-gpu-drm-i915-intel_tvc-fix-build.patch
  arm-mm-do-not-use-virt_to_idmap-for-nommu-systems.patch
* x86-fix-build-failure.patch
* userfaultfd-remove-kernel-header-include-from-uapi-header.patch
* mm-slab-fix-unexpected-index-mapping-result-of-kmalloc_sizeindex_node1.patch
* mm-hugetlbfs-skip-shared-vmas-when-unmapping-private-pages-to-satisfy-a-fault.patch
* dax-fix-null-pointer-in-__dax_pmd_fault.patch
* memcg-fix-dirty-page-migration.patch
* memcg-make-mem_cgroup_read_stat-unsigned.patch
* memcg-make-mem_cgroup_read_stat-unsigned-fix.patch
* drivers-input-joystick-kconfig-zhenhuac-needs-bitreverse.patch
* kprobe-use-_do_fork-in-samples-to-make-them-work-again.patch
* dax-fix-deadlock-in-__dax_fault.patch
* memcg-remove-pcp_counter_lock.patch
* thermal-avoid-division-by-zero-in-power-allocator.patch
* dmapool-fix-overflow-condition-in-pool_find_page.patch
* mm-fs-obey-gfp_mapping-for-add_to_page_cache.patch
* inotify-hide-internal-kernel-bits-from-fdinfo.patch
* inotify-actually-check-for-invalid-bits-in-sys_inotify_add_watch.patch
* inotify-actually-check-for-invalid-bits-in-sys_inotify_add_watch-v2.patch
* fs-ext4-fsyncc-generic_file_fsync-call-based-on-barrier-flag.patch
* ocfs2_direct_io_write-misses-ocfs2_is_overwrite-error-code.patch
* ocfs2-fill-in-the-unused-portion-of-the-block-with-zeros-by-dio_zero_block.patch
* ocfs2-improve-performance-for-localalloc.patch
* ocfs2-do-not-include-dio-entry-in-case-of-orphan-scan.patch
* ocfs2-only-take-lock-if-dio-entry-when-recover-orphans.patch
* ocfs2-add-ocfs2_write_type_t-type-to-identify-the-caller-of-write.patch
* ocfs2-use-c_new-to-indicate-newly-allocated-extents.patch
* ocfs2-test-target-page-before-change-it.patch
* ocfs2-do-not-change-i_size-in-write_end-for-direct-io.patch
* ocfs2-return-the-physical-address-in-ocfs2_write_cluster.patch
* ocfs2-record-unwritten-extents-when-populate-write-desc.patch
* ocfs2-fix-sparse-file-data-ordering-issue-in-direct-io.patch
* ocfs2-code-clean-up-for-direct-io.patch
* ocfs2-dlm-fix-race-between-convert-and-recovery.patch
* ocfs2-dlm-fix-race-between-convert-and-recovery-v2.patch
* ocfs2-dlm-fix-race-between-convert-and-recovery-v3.patch
* ocfs2-dlm-fix-bug-in-dlm_move_lockres_to_recovery_list.patch
* ocfs2-extend-transaction-for-ocfs2_remove_rightmost_path-and-ocfs2_update_edge_lengths-before-to-avoid-inconsistency-between-inode-and-et.patch
* extend-enough-credits-for-freeing-one-truncate-record-while-replaying-truncate-records.patch
* rcu-force-alignment-on-struct-callback_head-rcu_head.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* 9p-do-not-overwrite-return-code-when-locking-fails.patch
* kernel-watchdog-is_hardlockup-can-be-boolean.patch
* watchdog-fix-error-handling-in-proc_watchdog_thresh.patch
* watchdog-move-watchdog_disable_all_cpus-outside-of-ifdef.patch
* watchdog-implement-error-handling-in-update_watchdog_all_cpus-and-callers.patch
* watchdog-implement-error-handling-in-lockup_detector_suspend.patch
* watchdog-do-not-unpark-threads-in-watchdog_park_threads-on-error.patch
  mm.patch
* mm-slab-convert-slab_is_available-to-boolean.patch
* slub-create-new-___slab_alloc-function-that-can-be-called-with-irqs-disabled.patch
* slub-avoid-irqoff-on-in-bulk-allocation.patch
* mm-kmemleak-remove-unneeded-initialization-of-object-to-null.patch
* syscall-mlockall-reorganize-return-values-and-remove-goto-out-label.patch
* x86-numa-acpi-online-node-earlier-when-doing-cpu-hot-addition.patch
* kernel-profilec-replace-cpu_to_mem-with-cpu_to_node.patch
* sgi-xp-replace-cpu_to_node-with-cpu_to_mem-to-support-memoryless-node.patch
* openvswitch-replace-cpu_to_node-with-cpu_to_mem-to-support-memoryless-node.patch
* i40e-use-numa_mem_id-to-better-support-memoryless-node.patch
* i40evf-use-numa_mem_id-to-better-support-memoryless-node.patch
* x86-numa-kill-useless-code-to-improve-code-readability.patch
* mm-update-_mem_id_-for-every-possible-cpu-when-memory-configuration-changes.patch
* mm-x86-enable-memoryless-node-support-to-better-support-cpu-memory-hotplug.patch
* uaccess-reimplement-probe_kernel_address-using-probe_kernel_read.patch
* uaccess-reimplement-probe_kernel_address-using-probe_kernel_read-fix.patch
* uaccess-reimplement-probe_kernel_address-using-probe_kernel_read-fix-fix.patch
* mm-mmapc-remove-useless-statement-vma-=-null-in-find_vma.patch
* memcg-flatten-task_struct-memcg_oom.patch
* memcg-punt-high-overage-reclaim-to-return-to-userland-path.patch
* memcg-collect-kmem-bypass-conditions-into-__memcg_kmem_bypass.patch
* memcg-ratify-and-consolidate-over-charge-handling.patch
* memcg-drop-unnecessary-cold-path-tests-from-__memcg_kmem_bypass.patch
* mm-fix-docbook-comment-for-get_vaddr_frames.patch
* mm-add-tracepoint-for-scanning-pages.patch
* mm-add-tracepoint-for-scanning-pages-fix.patch
* mm-make-optimistic-check-for-swapin-readahead.patch
* mm-make-optimistic-check-for-swapin-readahead-fix.patch
* mm-make-optimistic-check-for-swapin-readahead-fix-2.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-2.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-3.patch
* mm-replace-nr_node_ids-for-loop-with-for_each_node-in-list-lru.patch
* powerpc-numa-do-not-allocate-bootmem-memory-for-non-existing-nodes.patch
* mm-msync-use-offset_in_page-macro.patch
* mm-nommu-use-offset_in_page-macro.patch
* mm-mincore-use-offset_in_page-macro.patch
* mm-early_ioremap-use-offset_in_page-macro.patch
* mm-percpu-use-offset_in_page-macro.patch
* mm-util-use-offset_in_page-macro.patch
* mm-mlock-use-offset_in_page-macro.patch
* mm-vmalloc-use-offset_in_page-macro.patch
* mm-mmap-use-offset_in_page-macro.patch
* mm-mremap-use-offset_in_page-macro.patch
* mm-memblock-make-memblock_remove_range-static.patch
* mm-migrate-count-pages-failing-all-retries-in-vmstat-and-tracepoint.patch
* mm-page_alloc-remove-unused-parameter-in-init_currently_empty_zone.patch
* mm-use-only-per-device-readahead-limit.patch
* mm-hugetlb-proc-add-hugetlb-related-fields-to-proc-pid-smaps.patch
* mm-hugetlb-proc-add-hugetlbpages-field-to-proc-pid-status.patch
* mm-vmscan-make-inactive_anon_is_low_global-return-directly.patch
* mm-oom_kill-introduce-is_sysrq_oom-helper.patch
* mm-compaction-add-an-is_via_compact_memory-helper-function.patch
* fs-global-sync-to-not-clear-error-status-of-individual-inodes.patch
* mm-hwpoison-ratelimit-messages-from-unpoison_memory.patch
* mm-memcontrol-fix-order-calculation-in-try_charge.patch
* doc-add-information-about-max_ptes_swap.patch
* mm-vmscan-make-inactive_anon-file_is_low-return-bool.patch
* mm-memcontrol-make-mem_cgroup_inactive_anon_is_low-return-bool.patch
* mmoom-reverse-the-order-of-setting-tif_memdie-and-sending-sigkill.patch
* mmoom-reverse-the-order-of-setting-tif_memdie-and-sending-sigkill-v2.patch
* mmoom-fix-potentially-killing-unrelated-process.patch
* mmoom-suppress-unnecessary-sharing-same-memory-message.patch
* mm-compaction-export-tracepoints-status-strings-to-userspace.patch
* mm-compaction-export-tracepoints-zone-names-to-userspace.patch
* mm-compaction-export-tracepoints-zone-names-to-userspace-fix.patch
* mm-compaction-disginguish-contended-status-in-tracepoints.patch
* mm-oom-remove-task_lock-protecting-comm-printing.patch
* mm-page_alloc-remove-unnecessary-parameter-from-zone_watermark_ok_safe.patch
* mm-page_alloc-remove-unnecessary-recalculations-for-dirty-zone-balancing.patch
* mm-page_alloc-remove-unnecessary-taking-of-a-seqlock-when-cpusets-are-disabled.patch
* mm-page_alloc-use-masks-and-shifts-when-converting-gfp-flags-to-migrate-types.patch
* mm-page_alloc-distinguish-between-being-unable-to-sleep-unwilling-to-sleep-and-avoiding-waking-kswapd.patch
* mm-page_alloc-rename-__gfp_wait-to-__gfp_reclaim.patch
* mm-page_alloc-rename-__gfp_wait-to-__gfp_reclaim-fix.patch
* mm-page_alloc-rename-__gfp_wait-to-__gfp_reclaim-checkpatch-fixes.patch
* mm-page_alloc-delete-the-zonelist_cache.patch
* mm-page_alloc-remove-migrate_reserve.patch
* mm-page_alloc-reserve-pageblocks-for-high-order-atomic-allocations-on-demand.patch
* mm-page_alloc-reserve-pageblocks-for-high-order-atomic-allocations-on-demand-fix.patch
* mm-page_alloc-only-enforce-watermarks-for-order-0-allocations.patch
* mm-page_alloc-only-enforce-watermarks-for-order-0-allocations-fix.patch
* mm-page_alloc-only-enforce-watermarks-for-order-0-allocations-fix-fix.patch
* mm-page_alloc-hide-some-GFP-internals-and-document-the-bit-and-flag-combinations.patch
* mm-fix-declarations-of-nr-delta-and-nr_pagecache_reclaimable.patch
* mm-fix-declarations-of-nr-delta-and-nr_pagecache_reclaimable-fix.patch
* mm-fix-overflow-in-find_zone_movable_pfns_for_nodes.patch
* mm-kasan-rename-kasan_enabled-to-kasan_report_enabled.patch
* mm-kasan-module_vaddr-is-not-available-on-all-archs.patch
* mm-kasan-dont-use-kasan-shadow-pointer-in-generic-functions.patch
* mm-kasan-prevent-deadlock-in-kasan-reporting.patch
* kasan-update-reported-bug-types-for-not-user-nor-kernel-memory-accesses.patch
* kasan-update-reported-bug-types-for-kernel-memory-accesses.patch
* kasan-accurately-determine-the-type-of-the-bad-access.patch
* kasan-update-log-messages.patch
* kasan-various-fixes-in-documentation.patch
* kasan-various-fixes-in-documentation-checkpatch-fixes.patch
* kasan-move-kasan_sanitize-in-arch-x86-boot-makefile.patch
* kasan-update-reference-to-kasan-prototype-repo.patch
* lib-test_kasan-add-some-testcases.patch
* kasan-fix-a-type-conversion-error.patch
* kasan-use-is_aligned-in-memory_is_poisoned_8.patch
* mm-mlock-refactor-mlock-munlock-and-munlockall-code.patch
* mm-mlock-add-new-mlock-system-call.patch
* mm-introduce-vm_lockonfault.patch
* mm-introduce-vm_lockonfault-v9.patch
* mm-mlock-add-mlock-flags-to-enable-vm_lockonfault-usage.patch
* mm-mlock-add-mlock-flags-to-enable-vm_lockonfault-usage-v9.patch
* selftests-vm-add-tests-for-lock-on-fault.patch
* selftests-vm-add-tests-for-lock-on-fault-v9.patch
* mips-add-entry-for-new-mlock2-syscall.patch
* zram-introduce-comp-algorithm-fallback-functionality.patch
* zram-keep-the-exact-overcommited-value-in-mem_used_max.patch
* mm-zswap-remove-unneeded-initialization-to-null-in-zswap_entry_find_get.patch
* module-export-param_free_charp.patch
* zswap-use-charp-for-zswap-param-strings.patch
* zpool-remove-redundant-zpool-type-string-const-ify-zpool_get_type.patch
* mm-zsmalloc-constify-struct-zs_pool-name.patch
* zsmalloc-add-comments-for-inuse-to-zspage.patch
* zsmalloc-add-comments-for-inuse-to-zspage-v2-fix.patch
* mm-drop-page-slab_page.patch
* slab-slub-use-page-rcu_head-instead-of-page-lru-plus-cast.patch
* zsmalloc-use-page-private-instead-of-page-first_page.patch
* mm-pack-compound_dtor-and-compound_order-into-one-word-in-struct-page.patch
* mm-make-compound_head-robust.patch
* mm-use-unsigned-int-for-page-order.patch
* mm-use-unsigned-int-for-page-order-fix.patch
* mm-use-unsigned-int-for-compound_dtor-compound_order-on-64bit.patch
* page-flags-trivial-cleanup-for-pagetrans-helpers.patch
* page-flags-move-code-around.patch
* page-flags-introduce-page-flags-policies-wrt-compound-pages.patch
* page-flags-define-pg_locked-behavior-on-compound-pages.patch
* page-flags-define-pg_locked-behavior-on-compound-pages-fix.patch
* page-flags-define-behavior-of-fs-io-related-flags-on-compound-pages.patch
* page-flags-define-behavior-of-lru-related-flags-on-compound-pages.patch
* page-flags-define-behavior-slb-related-flags-on-compound-pages.patch
* page-flags-define-behavior-of-xen-related-flags-on-compound-pages.patch
* page-flags-define-pg_reserved-behavior-on-compound-pages.patch
* page-flags-define-pg_swapbacked-behavior-on-compound-pages.patch
* page-flags-define-pg_swapcache-behavior-on-compound-pages.patch
* page-flags-define-pg_mlocked-behavior-on-compound-pages.patch
* page-flags-define-pg_uncached-behavior-on-compound-pages.patch
* page-flags-define-pg_uptodate-behavior-on-compound-pages.patch
* page-flags-look-at-head-page-if-the-flag-is-encoded-in-page-mapping.patch
* mm-sanitize-page-mapping-for-tail-pages.patch
* mm-increase-swap_cluster_max-to-batch-tlb-flushes.patch
* x86-add-pmd_-for-thp.patch
* x86-add-pmd_-for-thp-fix.patch
* sparc-add-pmd_-for-thp.patch
* sparc-add-pmd_-for-thp-fix.patch
* powerpc-add-pmd_-for-thp.patch
* arm-add-pmd_mkclean-for-thp.patch
* arm64-add-pmd_-for-thp.patch
* mm-support-madvisemadv_free.patch
* mm-support-madvisemadv_free-fix.patch
* mm-support-madvisemadv_free-fix-2.patch
* mm-support-madvisemadv_free-fix-3.patch
* mm-dont-split-thp-page-when-syscall-is-called.patch
* mm-dont-split-thp-page-when-syscall-is-called-fix.patch
* mm-dont-split-thp-page-when-syscall-is-called-fix-2.patch
* mm-dont-split-thp-page-when-syscall-is-called-fix-3.patch
* mm-free-swp_entry-in-madvise_free.patch
* mm-move-lazy-free-pages-to-inactive-list.patch
* mm-move-lazy-free-pages-to-inactive-list-fix.patch
* mm-move-lazy-free-pages-to-inactive-list-fix-fix.patch
* mm-move-lazy-free-pages-to-inactive-list-fix-fix-fix.patch
* fs-proc-arrayc-set-overflow-flag-in-case-of-error.patch
* fs-proc-dont-expose-absolute-kernel-addresses-via-wchan.patch
* fs-proc-dont-expose-absolute-kernel-addresses-via-wchan-fix.patch
* use-poison_pointer_delta-for-poison-pointers.patch
* include-linux-compiler-gcch-improve-__visible-documentation.patch
* fs-jffs2-wbufc-remove-stray-semicolon.patch
* lib-dynamic_debugc-use-kstrdup_const.patch
* lib-documentation-synchronize-%p-formatting-documentation.patch
* lib-documentation-synchronize-%p-formatting-documentation-fix.patch
* lib-documentation-synchronize-%p-formatting-documentation-fix-fix.patch
* lib-vsprintfc-handle-invalid-format-specifiers-more-robustly.patch
* lib-vsprintfc-also-improve-sanity-check-in-bstr_printf.patch
* lib-vsprintfc-remove-special-handling-in-pointer.patch
* test_printf-test-printf-family-at-runtime.patch
* selftests-run-test_printf-module.patch
* lib-halfmd4-use-rol32-inline-function-in-the-round-macro.patch
* lib-test-string_helpersc-add-string_get_size-tests.patch
* lib-test-string_helpersc-add-string_get_size-tests-v5.patch
* lib-fix-data-race-in-llist_del_first.patch
* lib-introduce-kvasprintf_const.patch
* kobject-use-kvasprintf_const-for-formatting-name.patch
* mm-utilc-add-kstrimdup.patch
* lib-add-crc64-ecma-module.patch
* nilfs2-drop-null-test-before-destroy-functions.patch
* nilfs2-use-nilfs_warning-in-allocator-implementation.patch
* nilfs2-do-not-call-nilfs_mdt_bgl_lock-needlessly.patch
* nilfs2-refactor-nilfs_palloc_find_available_slot.patch
* nilfs2-get-rid-of-nilfs_palloc_group_is_in.patch
* nilfs2-add-helper-functions-to-delete-blocks-from-dat-file.patch
* nilfs2-free-unused-dat-file-blocks-during-garbage-collection.patch
* fat-add-fat_fallocate-operation.patch
* fat-skip-cluster-allocation-on-fallocated-region.patch
* fat-permit-to-return-phy-block-number-by-fibmap-in-fallocated-region.patch
* documentation-filesystems-vfattxt-update-the-limitation-for-fat-fallocate.patch
* signals-kill-block_all_signals-and-unblock_all_signals.patch
* seq_file-re-use-string_escape_str.patch
* fs-seq_file-use-seq_-helpers-in-seq_hex_dump.patch
* fs-seqfile-always-allow-oom-killer.patch
* kexec-use-file-name-as-the-output-message-prefix.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* pidns-fix-set-getpriority-and-ioprio_set-get-in-prio_user-mode.patch
* dma-mapping-tidy-up-dma_parms-default-handling.patch
* dma-mapping-tidy-up-dma_parms-default-handling-fix.patch
* dma-debug-check-nents-in-dma_sync_sg.patch
* dma-debug-allow-poisoning-nonzero-allocations.patch
* w1-masters-omap_hdq-add-support-for-1-wire-mode.patch
* zlib-fix-usage-example-of-zlib_adler32.patch
* ipc-msgc-msgsnd-use-freezable-blocking-call.patch
* msgrcv-use-freezable-blocking-call.patch
  linux-next.patch
  linux-next-rejects.patch
* net-ipv4-routec-prevent-oops.patch
* mips-allocate-sys_membarrier-system-call-number.patch
* sparc-sparc64-allocate-sys_membarrier-system-call-number.patch
* kernelh-make-abs-work-with-64-bit-types.patch
* remove-abs64.patch
* remove-abs64-fix.patch
* mm-doc-fix-misleading-code-reference-of-overcommit_memory.patch
* w1-call-put_device-if-device_register-fails.patch
  mm-add-strictlimit-knob-v2.patch
  do_shared_fault-check-that-mmap_sem-is-held.patch
  make-sure-nobodys-leaking-resources.patch
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
