Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 546B28E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 16:40:48 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id j8so4955167plb.1
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 13:40:48 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c136si70468247pfc.141.2019.01.09.13.40.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 13:40:46 -0800 (PST)
Date: Wed, 09 Jan 2019 13:40:44 -0800
From: akpm@linux-foundation.org
Subject: mmotm 2019-01-09-13-40 uploaded
Message-ID: <20190109214044.pamoB%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org

The mm-of-the-moment snapshot 2019-01-09-13-40 has been uploaded to

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


This mmotm tree contains the following patches against 5.0-rc1:
(patches marked "*" will be included in linux-next)

  origin.patch
* memory_hotplug-free-pages-as-higher-order.patch
* memory_hotplug-free-pages-as-higher-order-fix.patch
* memory_hotplug-free-pages-as-higher-order-fix-fix.patch
* mm-page_allocc-memory_hotplug-free-pages-as-higher-order-v8.patch
* mm-balloon-update-comment-about-isolation-migration-compaction.patch
* mm-convert-pg_balloon-to-pg_offline.patch
* mm-convert-pg_balloon-to-pg_offline-fix.patch
* kexec-export-pg_offline-to-vmcoreinfo.patch
* xen-balloon-mark-inflated-pages-pg_offline.patch
* hv_balloon-mark-inflated-pages-pg_offline.patch
* vmw_balloon-mark-inflated-pages-pg_offline.patch
* vmw_balloon-mark-inflated-pages-pg_offline-v2.patch
* pm-hibernate-use-pfn_to_online_page.patch
* pm-hibernate-exclude-all-pageoffline-pages.patch
* pm-hibernate-exclude-all-pageoffline-pages-v2.patch
* checkpatch-dont-interpret-stack-dumps-as-commit-ids.patch
* mm-memory_hotplug-dont-bail-out-in-do_migrate_range-prematurely.patch
* mm-thp-always-specify-disabled-vmas-as-nh-in-smaps.patch
* mm-page_owner-fix-for-deferred-struct-page-init.patch
* mm-mempolicy-fix-uninit-memory-access.patch
* proc-fix-proc-net-after-setns2.patch
* proc-fix-proc-net-after-setns2-checkpatch-fixes.patch
* proc-fix-proc-net-after-setns2-checkpatch-fixes-fix.patch
* proc-fix-proc-net-after-setns2-v2.patch
* arch-unexport-asm-shmparamh-for-all-architectures.patch
* mm-hugetlbc-teach-follow_hugetlb_page-to-handle-foll_nowait.patch
* scripts-decode_stacktracesh-handle-rip-address-with-segment.patch
* sh-remove-nargs-from-__syscall.patch
* sh-generate-uapi-header-and-syscall-table-header-files.patch
* debugobjects-move-printk-out-of-db-lock-critical-sections.patch
* ocfs2-clear-zero-in-unaligned-direct-io.patch
* ocfs2-clear-zero-in-unaligned-direct-io-checkpatch-fixes.patch
* ocfs2-dlm-clean-dlm_lksb_get_lvb-and-dlm_lksb_put_lvb-when-the-cancel_pending-is-set.patch
* ocfs2-dlm-return-dlm_cancelgrant-if-the-lock-is-on-granted-list-and-the-operation-is-canceled.patch
* fs-filec-initialize-init_filesresize_wait.patch
  mm.patch
* mm-slubc-freelist-is-ensured-to-be-null-when-new_slab-fails.patch
* mm-refactor-readahead-defines-in-mmh.patch
* mm-vmallocc-dont-dereference-possible-null-pointer-in-__vunmap.patch
* mm-replace-all-open-encodings-for-numa_no_node.patch
* tools-replace-open-encodings-for-numa_no_node.patch
* tools-replace-open-encodings-for-numa_no_node-fix.patch
* mm-reuse-only-pte-mapped-ksm-page-in-do_wp_page.patch
* mm-reuse-only-pte-mapped-ksm-page-in-do_wp_page-fix.patch
* powerpc-prefer-memblock-apis-returning-virtual-address.patch
* microblaze-prefer-memblock-api-returning-virtual-address.patch
* sh-prefer-memblock-apis-returning-virtual-address.patch
* openrisc-simplify-pte_alloc_one_kernel.patch
* arch-simplify-several-early-memory-allocations.patch
* arm-s390-unicore32-remove-oneliner-wrappers-for-memblock_alloc.patch
* mm-slub-make-the-comment-of-put_cpu_partial-complete.patch
* memcg-localize-memcg_kmem_enabled-check.patch
* mm-vmalloc-make-vmalloc_32_user-align-base-kernel-virtual-address-to-shmlba.patch
* mm-vmalloc-fix-size-check-for-remap_vmalloc_range_partial.patch
* mm-vmalloc-do-not-call-kmemleak_free-on-not-yet-accounted-memory.patch
* mm-vmalloc-pass-vm_usermap-flags-directly-to-__vmalloc_node_range.patch
* vmalloc-export-__vmalloc_node_range-for-config_test_vmalloc_module.patch
* vmalloc-add-test-driver-to-analyse-vmalloc-allocator.patch
* vmalloc-add-test-driver-to-analyse-vmalloc-allocator-fix.patch
* selftests-vm-add-script-helper-for-config_test_vmalloc_module.patch
* mm-remove-sysctl_extfrag_handler.patch
* openvswitch-convert-to-kvmalloc.patch
* md-convert-to-kvmalloc.patch
* selinux-convert-to-kvmalloc.patch
* generic-radix-trees.patch
* proc-commit-to-genradix.patch
* sctp-convert-to-genradix.patch
* drop-flex_arrays.patch
* mm-hugetlb-distinguish-between-migratability-and-movability.patch
* mm-hugetlb-enable-pud-level-huge-page-migration.patch
* mm-hugetlb-enable-arch-specific-huge-page-size-support-for-migration.patch
* arm64-mm-enable-hugetlb-migration.patch
* arm64-mm-enable-hugetlb-migration-for-contiguous-bit-hugetlb-pages.patch
* mm-remove-extra-drain-pages-on-pcp-list.patch
* page_poison-plays-nicely-with-kasan.patch
* mm-compaction-shrink-compact_control.patch
* mm-compaction-rearrange-compact_control.patch
* mm-compaction-remove-last_migrated_pfn-from-compact_control.patch
* mm-compaction-remove-unnecessary-zone-parameter-in-some-instances.patch
* mm-compaction-rename-map_pages-to-split_map_pages.patch
* mm-compaction-skip-pageblocks-with-reserved-pages.patch
* mm-migrate-immediately-fail-migration-of-a-page-with-no-migration-handler.patch
* mm-compaction-always-finish-scanning-of-a-full-pageblock.patch
* mm-compaction-use-the-page-allocator-bulk-free-helper-for-lists-of-pages.patch
* mm-compaction-ignore-the-fragmentation-avoidance-boost-for-isolation-and-compaction.patch
* mm-compaction-use-free-lists-to-quickly-locate-a-migration-source.patch
* mm-compaction-keep-migration-source-private-to-a-single-compaction-instance.patch
* mm-compaction-use-free-lists-to-quickly-locate-a-migration-target.patch
* mm-compaction-use-free-lists-to-quickly-locate-a-migration-target-fix.patch
* mm-compaction-avoid-rescanning-the-same-pageblock-multiple-times.patch
* mm-compaction-finish-pageblock-scanning-on-contention.patch
* mm-compaction-finish-pageblock-scanning-on-contention-fix.patch
* mm-compaction-check-early-for-huge-pages-encountered-by-the-migration-scanner.patch
* mm-compaction-keep-cached-migration-pfns-synced-for-unusable-pageblocks.patch
* mm-compaction-rework-compact_should_abort-as-compact_check_resched.patch
* mm-compaction-do-not-consider-a-need-to-reschedule-as-contention.patch
* mm-compaction-reduce-unnecessary-skipping-of-migration-target-scanner.patch
* mm-compaction-round-robin-the-order-while-searching-the-free-lists-for-a-target.patch
* mm-compaction-round-robin-the-order-while-searching-the-free-lists-for-a-target-fix.patch
* mm-compaction-sample-pageblocks-for-free-pages.patch
* mm-compaction-be-selective-about-what-pageblocks-to-clear-skip-hints.patch
* mm-compaction-capture-a-page-under-direct-compaction.patch
* mm-compaction-do-not-direct-compact-remote-memory.patch
* mm-create-the-new-vm_fault_t-type.patch
* mm-create-the-new-vm_fault_t-type-fix.patch
* include-linux-nodemaskh-use-nr_node_ids-not-max_numnodes-in-__nodemask_pr_numnodes.patch
* mm-memcontrol-use-struct_size-in-kmalloc.patch
* mm-remove-redundant-test-from-find_get_pages_contig.patch
* memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work.patch
* mm-oom-marks-all-killed-tasks-as-oom-victims.patch
* memcg-do-not-report-racy-no-eligible-oom-tasks.patch
* mm-use-mm_zero_struct_page-from-sparc-on-all-64b-architectures.patch
* mm-drop-meminit_pfn_in_nid-as-it-is-redundant.patch
* mm-implement-new-zone-specific-memblock-iterator.patch
* mm-initialize-max_order_nr_pages-at-a-time-instead-of-doing-larger-sections.patch
* mm-move-hot-plug-specific-memory-init-into-separate-functions-and-optimize.patch
* mm-add-reserved-flag-setting-to-set_page_links.patch
* mm-use-common-iterator-for-deferred_init_pages-and-deferred_free_pages.patch
* mm-page_alloc-calculate-first_deferred_pfn-directly.patch
* mm-mmu_notifier-contextual-information-for-event-triggering-invalidation-v2.patch
* mm-mmu_notifier-contextual-information-for-event-triggering-invalidation-v2-fix.patch
* mm-mmu_notifier-contextual-information-for-event-triggering-invalidation-v2-fix-fix.patch
* filemap-kill-page_cache_read-usage-in-filemap_fault.patch
* filemap-kill-page_cache_read-usage-in-filemap_fault-fix.patch
* filemap-pass-vm_fault-to-the-mmap-ra-helpers.patch
* filemap-drop-the-mmap_sem-for-all-blocking-operations.patch
* filemap-drop-the-mmap_sem-for-all-blocking-operations-v6.patch
* filemap-drop-the-mmap_sem-for-all-blocking-operations-fix.patch
* filemap-drop-the-mmap_sem-for-all-blocking-operations-checkpatch-fixes.patch
* mm-swap-fix-race-between-swapoff-and-some-swap-operations.patch
* mm-swap-fix-race-between-swapoff-and-some-swap-operations-v6.patch
* mm-dont-expose-page-to-fast-gup-before-its-ready.patch
* mm-page_owner-align-with-pageblock_nr_pages.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* info-task-hung-in-generic_file_write_iter.patch
* info-task-hung-in-generic_file_write-fix.patch
* lockdep-add-debug-printk-for-downgrade_write-warning.patch
* proc-return-exit-code-4-for-skipped-tests.patch
* kernelh-unconditionally-include-asm-div64h-for-do_div.patch
* taint-fix-debugfs_simple_attrcocci-warnings.patch
* lib-genallocc-export-symbol-addr_in_gen_pool.patch
* lib-genallocc-rename-addr_in_gen_pool-to-gen_pool_has_addr.patch
* lib-genallocc-rename-addr_in_gen_pool-to-gen_pool_has_addr-fix.patch
* epoll-make-sure-all-elements-in-ready-list-are-in-fifo-order.patch
* epoll-unify-awaking-of-wakeup-source-on-ep_poll_callback-path.patch
* epoll-use-rwlock-in-order-to-reduce-ep_poll_callback-contention.patch
* ptrace-take-into-account-saved_sigmask-in-ptrace_getsetsigmask.patch
* signal-allow-the-null-signal-in-rt_sigqueueinfo.patch
* kernel-release-ptraced-tasks-before-zap_pid_ns_processes.patch
* exec-increase-binprm_buf_size-to-256.patch
* sysctl-handle-overflow-in-proc_get_long.patch
* sysctl-handle-overflow-for-file-max.patch
* ipc-allow-boot-time-extension-of-ipcmni-from-32k-to-8m.patch
* ipc-allow-boot-time-extension-of-ipcmni-from-32k-to-8m-checkpatch-fixes.patch
* ipc-conserve-sequence-numbers-in-extended-ipcmni-mode.patch
  linux-next.patch
* scripts-atomic-check-atomicssh-dont-assume-that-scripts-are-executable.patch
* include-replace-tsk-to-task-in-linux-sched-signalh.patch
* locking-atomics-build-atomic-headers-as-required.patch
* fork-remove-duplicated-include-from-forkc.patch
* fix-read-buffer-overflow-in-delta-ipc.patch
  make-sure-nobodys-leaking-resources.patch
  releasing-resources-with-children.patch
  mutex-subsystem-synchro-test-module.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  slab-leaks3-default-y.patch
  workaround-for-a-pci-restoring-bug.patch
