Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 62DDB6B0007
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 20:04:00 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id ba8-v6so2016171plb.4
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 17:04:00 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k184-v6si2043334pge.209.2018.07.03.17.03.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 17:03:58 -0700 (PDT)
Date: Tue, 03 Jul 2018 17:03:57 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2018-07-03-17-03 uploaded
Message-ID: <20180704000357._wBJL%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org

The mm-of-the-moment snapshot 2018-07-03-17-03 has been uploaded to

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


This mmotm tree contains the following patches against 4.18-rc3:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
* userfaultfd-hugetlbfs-fix-userfaultfd_huge_must_wait-pte-access.patch
* mm-hugetlb-yield-when-prepping-struct-pages.patch
* kasan-fix-shadow_size-calculation-error-in-kasan_module_alloc.patch
* arm-disable-kcov-for-trusted-foundations-code.patch
* mm-teach-dump_page-to-correctly-output-poisoned-struct-pages.patch
* kvm-mm-account-shadow-page-tables-to-kmemcg.patch
* memcg-remove-memcg_cgroup-id-from-idr-on-mem_cgroup_css_alloc-failure.patch
* slub-track-number-of-slabs-irrespective-of-config_slub_debug.patch
* mm-do-not-drop-unused-pages-when-userfaultd-is-running.patch
* mm-fix-locked-field-in-proc-pid-smaps.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* dax-remove-vm_mixedmap-for-fsdax-and-device-dax.patch
* prctl-add-pr_et_pdeathsig_proc.patch
* ntfs-dont-disable-interrupts-during-kmap_atomic.patch
* ntfs-aops-remove-vla-usage.patch
* ntfs-decompress-remove-vla-usage.patch
* ntfs-mft-remove-vla-usage.patch
* sh-make-use-of-for_each_node_by_type.patch
* h8300-correct-signature-of-test_bit.patch
* ocfs2-return-erofs-when-filesystem-becomes-read-only.patch
* ocfs2-return-erofs-when-filesystem-becomes-read-only-checkpatch-fixes.patch
* ocfs2-clean-up-some-unnecessary-code.patch
* ocfs2-make-several-functions-and-variables-static-and-some-const.patch
* ocfs2-get-rid-of-ocfs2_is_o2cb_active-function.patch
* ocfs2-without-quota-support-try-to-avoid-calling-quota-recovery.patch
* ocfs2-dont-use-iocb-when-eiocbqueued-returns.patch
* ocfs2-fix-a-misuse-a-of-brelse-after-failing-ocfs2_check_dir_entry.patch
* ocfs2-dont-put-and-assigning-null-to-bh-allocated-outside.patch
* ocfs2-dlmglue-clean-up-timestamp-handling.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* fs-9p-adding-new-return-type-vm_fault_t.patch
* dentry-fix-kmemcheck-splat-at-take_dentry_name_snapshot.patch
* namei-allow-restricted-o_creat-of-fifos-and-regular-files.patch
* vfs-discard-attr_attr_flag.patch
* vfs-simplify-seq_file-iteration-code-and-interface.patch
  mm.patch
* mm-convert-return-type-of-handle_mm_fault-caller-to-vm_fault_t.patch
* mm-skip-invalid-pages-block-at-a-time-in-zero_resv_unresv.patch
* thp-use-mm_file_counter-to-determine-update-which-rss-counter.patch
* tools-modifying-page-types-to-include-shared-map-counts.patch
* tools-modifying-page-types-to-include-shared-map-counts-checkpatch-fixes.patch
* tools-adding-support-for-idle-page-tracking-to-tool.patch
* tools-adding-support-for-idle-page-tracking-to-tool-fix.patch
* mm-page_alloc-actually-ignore-mempolicies-for-high-priority-allocations.patch
* shmem-use-monotonic-time-for-i_generation.patch
* mm-page_ext-drop-definition-of-unused-page_ext_debug_poison.patch
* mm-page_ext-constify-lookup_page_ext-argument.patch
* mm-condense-scan_control.patch
* mm-mempool-remove-unused-argument-in-kasan_unpoison_element-and-remove_element.patch
* mm-thp-register-mm-for-khugepaged-when-merging-vma-for-shmem-v3.patch
* mm-thp-inc-counter-for-collapsed-shmem-thp.patch
* mpage-add-argument-structure-for-do_mpage_readpage.patch
* mpage-mpage_readpages-should-submit-io-as-read-ahead.patch
* btrfs-readpages-should-submit-io-as-read-ahead.patch
* ext4-readpages-should-submit-io-as-read-ahead.patch
* mm-clear_huge_page-move-order-algorithm-into-a-separate-function.patch
* mm-huge-page-copy-target-sub-page-last-when-copy-huge-page.patch
* mm-hugetlbfs-rename-address-to-haddr-in-hugetlb_cow.patch
* mm-hugetlbfs-pass-fault-address-to-cow-handler.patch
* mm-drop-vm_bug_on-from-__get_free_pages.patch
* mm-drop-vm_bug_on-from-__get_free_pages-fix.patch
* mm-workingset-remove-local_irq_disable-from-count_shadow_nodes.patch
* mm-workingset-make-shadow_lru_isolate-use-locking-suffix.patch
* mm-list_lruc-fold-__list_lru_count_one-into-its-caller.patch
* mm-memory_hotplug-make-add_memory_resource-use-__try_online_node.patch
* mm-memory_hotplug-call-register_mem_sect_under_node.patch
* mm-memory_hotplug-make-register_mem_sect_under_node-a-cb-of-walk_memory_range.patch
* mm-memory_hotplug-drop-unnecessary-checks-from-register_mem_sect_under_node.patch
* mm-provide-a-fallback-for-page_kernel_ro-for-architectures.patch
* mm-provide-a-fallback-for-page_kernel_exec-for-architectures.patch
* mm-introduce-mem_cgroup_put-helper.patch
* fs-fsnotify-account-fsnotify-metadata-to-kmemcg.patch
* fs-fsnotify-account-fsnotify-metadata-to-kmemcg-fix.patch
* fs-mm-account-buffer_head-to-kmemcg.patch
* fs-mm-account-buffer_head-to-kmemcgpatchfix.patch
* writeback-update-stale-account_page_redirty-comment.patch
* mm-memblock-add-missing-include-linux-bootmemh.patch
* mm-zsmalloc-make-several-functions-and-a-struct-static.patch
* mm-swap-make-swap_slots_cache_mutex-and-swap_slots_cache_enable_mutex-static.patch
* mm-fadvise-fix-signed-overflow-ubsan-complaint.patch
* mm-fadvise-fix-signed-overflow-ubsan-complaint-fix.patch
* mm-thp-passing-correct-vm_flags-to-hugepage_vma_check.patch
* kernel-memremap-kasan-make-zone_device-with-work-with-kasan.patch
* mm-make-deferred_struct_page_init-explicitly-depend-on-sparsemem.patch
* memcg-oom-move-out_of_memory-back-to-the-charge-path.patch
* mm-sparse-make-sparse_init_one_section-void-and-remove-check.patch
* mm-memblock-replace-u64-with-phys_addr_t-where-appropriate.patch
* list_lru-combine-code-under-the-same-define.patch
* mm-introduce-config_memcg_kmem-as-combination-of-config_memcg-config_slob.patch
* mm-assign-id-to-every-memcg-aware-shrinker.patch
* memcg-move-up-for_each_mem_cgroup-_tree-defines.patch
* mm-assign-memcg-aware-shrinkers-bitmap-to-memcg.patch
* mm-refactoring-in-workingset_init.patch
* fs-refactoring-in-alloc_super.patch
* fs-propagate-shrinker-id-to-list_lru.patch
* list_lru-add-memcg-argument-to-list_lru_from_kmem.patch
* list_lru-pass-dst_memcg-argument-to-memcg_drain_list_lru_node.patch
* list_lru-pass-lru-argument-to-memcg_drain_list_lru_node.patch
* mm-export-mem_cgroup_is_root.patch
* mm-set-bit-in-memcg-shrinker-bitmap-on-first-list_lru-item-apearance.patch
* mm-iterate-only-over-charged-shrinkers-during-memcg-shrink_slab.patch
* mm-generalize-shrink_slab-calls-in-shrink_node.patch
* mm-add-shrink_empty-shrinker-methods-return-value.patch
* mm-clear-shrinker-bit-if-there-are-no-objects-related-to-memcg.patch
* mm-clear-shrinker-bit-if-there-are-no-objects-related-to-memcg-checkpatch-fixes.patch
* mm-sparse-add-a-static-variable-nr_present_sections.patch
* mm-sparsemem-defer-the-ms-section_mem_map-clearing.patch
* mm-sparsemem-defer-the-ms-section_mem_map-clearing-fix.patch
* mm-sparse-add-a-new-parameter-data_unit_size-for-alloc_usemap_and_memmap.patch
* mm-swap-fix-race-between-swapoff-and-some-swap-operations.patch
* mm-swap-fix-race-between-swapoff-and-some-swap-operations-v6.patch
* mm-fix-race-between-swapoff-and-mincore.patch
* list_lru-prefetch-neighboring-list-entries-before-acquiring-lock.patch
* list_lru-prefetch-neighboring-list-entries-before-acquiring-lock-fix.patch
* mm-oom-refactor-the-oom_kill_process-function.patch
* mm-implement-mem_cgroup_scan_tasks-for-the-root-memory-cgroup.patch
* mm-oom-cgroup-aware-oom-killer.patch
* mm-oom-cgroup-aware-oom-killer-fix.patch
* mm-oom-cgroup-aware-oom-killer-fix-2.patch
* mm-oom-cgroup-aware-oom-killer-fix-3.patch
* mm-oom-introduce-memoryoom_group.patch
* mm-oom-introduce-memoryoom_group-fix.patch
* mm-oom-add-cgroup-v2-mount-option-for-cgroup-aware-oom-killer.patch
* mm-oom-docs-describe-the-cgroup-aware-oom-killer.patch
* mm-oom-docs-describe-the-cgroup-aware-oom-killer-fix.patch
* mm-oom-docs-describe-the-cgroup-aware-oom-killer-fix-2.patch
* mm-oom-docs-describe-the-cgroup-aware-oom-killer-fix-2-fix.patch
* cgroup-list-groupoom-in-cgroup-features.patch
* mm-add-strictlimit-knob-v2.patch
* mm-dont-expose-page-to-fast-gup-before-its-ready.patch
* mm-page_owner-align-with-pageblock_nr_pages.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* proc-fixup-pde-allocation-bloat.patch
* proc-fixup-pde-allocation-bloat-fix.patch
* procfs-uptime-use-ktime_get_boottime_ts64.patch
* proc-test-proc-self-symlink.patch
* proc-test-proc-thread-self-symlink.patch
* proc-smaller-readlock-section-in-readdir-proc.patch
* proc-put-task-earlier-in-proc-fail-nth.patch
* proc-save-2-atomic-ops-on-write-to-proc-attr.patch
* proc-use-macro-in-proc-latency-hook.patch
* proc-spread-const-a-bit.patch
* proc-use-unsigned-int-in-proc-stat-hook.patch
* proc-use-%02u-format.patch
* fs-proc-adding-new-typedef-vm_fault_t.patch
* include-asm-generic-bugh-clarify-valid-uses-of-warn.patch
* crash-print-timestamp-using-time64_t.patch
* kernel-hung_taskc-allow-to-set-checking-interval-separately-from-timeout.patch
* kernel-hung_taskc-allow-to-set-checking-interval-separately-from-timeout-fix.patch
* iomap-use-non-raw-io-functions-for-ioreadwritexxbe.patch
* parisc-iomap-introduce-ioreadwrite64.patch
* iomap-introduce-ioreadwrite64_lo_hihi_lo.patch
* io-64-nonatomic-add-ioreadwrite64_lo_hi_hi_lo-macros.patch
* ntb-ntb_hw_intel-use-io-64-nonatomic-instead-of-in-driver-hacks.patch
* crypto-caam-cleanup-config_64bit-ifdefs-when-using-ioreadwrite64.patch
* ntb-ntb_hw_switchtec-cleanup-64bit-io-defines-to-use-the-common-header.patch
* spellingtxt-add-more-spellings-to-spellingtxt.patch
* bitmap-drop-unnecessary-0-check-for-u32-array-operations.patch
* lib-make-struct-pointer-foo-static.patch
* checkpatch-add-a-strict-test-for-structs-with-bool-member-definitions.patch
* checkpatch-add-fix-for-concatenated_string-and-string_fragments.patch
* checkpatch-improve-runtime-execution-speed-a-little.patch
* sparse-remove-uneffective-sparse-disabling.patch
* autofs-fix-directory-and-symlink-access.patch
* autofs-fix-inconsistent-use-of-now-variable.patch
* autofs-fix-clearing-autofs_exp_leaves-in-autofs_expire_indirect.patch
* autofs-make-autofs_expire_direct-static.patch
* autofs-make-autofs_expire_indirect-static.patch
* autofs-make-expire-flags-usage-consistent-with-v5-params.patch
* autofs-add-autofs_exp_forced-flag.patch
* nilfs2-use-64-bit-superblock-timstamps.patch
* fs-nilfs2-adding-new-return-type-vm_fault_t.patch
* hfsplus-dont-return-0-when-fill_super-failed.patch
* hfsplus-prevent-crash-on-exit-from-failed-search.patch
* hfs-prevent-crash-on-exit-from-failed-search.patch
* reiserfs-use-monotonic-time-for-j_trans_start_time.patch
* reiserfs-remove-obsolete-print_time-function.patch
* reiserfs-change-j_timestamp-type-to-time64_t.patch
* fat-propagate-64-bit-inode-timestamps.patch
* signal-make-force_sigsegv-void.patch
* signal-make-kill_as_cred_perm-return-bool.patch
* signal-make-may_ptrace_stop-return-bool.patch
* signal-make-do_sigpending-void.patch
* signal-simplify-rt_sigaction.patch
* signal-make-kill_ok_by_cred-return-bool.patch
* signal-make-sig_handler_ignored-return-bool.patch
* signal-make-sig_task_ignored-return-bool.patch
* signal-make-sig_ignored-return-bool.patch
* signal-make-has_pending_signals-return-bool.patch
* signal-make-recalc_sigpending_tsk-return-bool.patch
* signal-make-unhandled_signal-return-bool.patch
* signal-make-flush_sigqueue_mask-void.patch
* signal-make-wants_signal-return-bool.patch
* signal-make-legacy_queue-return-bool.patch
* signal-make-sigkill_pending-return-bool.patch
* signal-make-get_signal-return-bool.patch
* fork-dont-copy-inconsistent-signal-handler-state-to-child.patch
* sysctl-fix-typos-in-comments.patch
* adfs-use-timespec64-for-time-conversion.patch
* bfs-add-sanity-check-at-bfs_fill_super.patch
  linux-next.patch
  linux-next-rejects.patch
* hwtracing-intel_th-change-return-type-to-vm_fault_t.patch
* fs-nfs-adding-new-return-type-vm_fault_t.patch
* fs-afs-adding-new-return-type-vm_fault_t.patch
* treewide-correct-differenciate-and-instanciate-typos.patch
* vmcore-hide-vmcoredd_mmap_dumps-for-nommu-builds.patch
* resource-add-walk_system_ram_res_rev.patch
* kexec_file-load-kernel-at-top-of-system-ram-if-required.patch
* fix-read-buffer-overflow-in-delta-ipc.patch
* sparc64-ng4-memset-32-bits-overflow.patch
  make-sure-nobodys-leaking-resources.patch
  releasing-resources-with-children.patch
  mutex-subsystem-synchro-test-module.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  slab-leaks3-default-y.patch
  workaround-for-a-pci-restoring-bug.patch
