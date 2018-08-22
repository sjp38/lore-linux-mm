Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C6E7E6B22E9
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 02:24:14 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id l15-v6so631502pff.1
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 23:24:14 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d20-v6si894259pls.179.2018.08.21.23.24.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Aug 2018 23:24:12 -0700 (PDT)
Date: Tue, 21 Aug 2018 23:24:10 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2018-08-21-23-23 uploaded
Message-ID: <20180822062410.UZXY6cL_6%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: broonie@kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org, mhocko@suse.cz, mm-commits@vger.kernel.org, sfr@canb.auug.org.au

The mm-of-the-moment snapshot 2018-08-21-23-23 has been uploaded to

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


This mmotm tree contains the following patches against 4.18:
(patches marked "*" will be included in linux-next)

  origin.patch
* autofs-fix-autofs_sbi-does-not-check-super-block-type.patch
* mm-check-shrinker-is-memcg-aware-in-register_shrinker_prepared.patch
* mm-keep-int-fields-in-struct-shrink_control-together.patch
* mm-make-flags-of-unsigned-type-in-struct-shrinker.patch
* swap-add-comments-to-lock_cluster_or_swap_info.patch
* mm-swapfilec-replace-some-ifdef-with-is_enabled.patch
* swap-use-swap_count-in-swap_page_trans_huge_swapped.patch
* swap-unify-normal-huge-code-path-in-swap_page_trans_huge_swapped.patch
* swap-unify-normal-huge-code-path-in-put_swap_page.patch
* swap-get_swap_pages-use-entry_size-instead-of-cluster-in-parameter.patch
* swap-add-__swap_entry_free_locked.patch
* swap-put_swap_page-share-more-between-huge-normal-code-path.patch
* mm-oom-distinguish-blockable-mode-for-mmu-notifiers.patch
* mm-oom-remove-oom_lock-from-oom_reaper.patch
* mm-oom-describe-task-memory-unit-larger-pid-pad.patch
* mm-oom_killc-clean-up-oom_reap_task_mm.patch
* mm-proc-pid-maps-remove-is_pid-and-related-wrappers.patch
* mm-proc-pid-smaps-factor-out-mem-stats-gathering.patch
* mm-proc-pid-smaps-factor-out-common-stats-printing.patch
* mm-proc-pid-smaps_rollup-convert-to-single-value-seq_file.patch
* mm-mempool-add-missing-parameter-description.patch
* mm-zero-out-the-vma-in-vma_init.patch
* mm-clarify-config_page_poisoning-and-usage.patch
* mm-fix-page_freeze_refs-and-page_unfreeze_refs-in-comments.patch
* memcg-reduce-memcg-tree-traversals-for-stats-collection.patch
* update-documents-__vm_enough_memory-function-path.patch
* mm-remove-zone_id-and-make-use-of-zone_idx-in-is_dev_zone.patch
* mm-page_alloc-move-ifdefery-out-of-free_area_init_core.patch
* mm-access-zone-node-via-zone_to_nid-and-zone_set_nid.patch
* mm-remove-__paginginit.patch
* mm-page_alloc-inline-function-to-handle-config_deferred_struct_page_init.patch
* mm-page_alloc-introduce-free_area_init_core_hotplug.patch
* mm-selftest-add-map_populate-test.patch
* mm-oom-refactor-oom_kill_process.patch
* mm-oom-introduce-memoryoomgroup.patch
* proc-add-percpu-populated-pages-count-to-meminfo.patch
* zram-fix-bug-storing-backing_dev.patch
* mm-fix-comment-for-nodemask_alloc.patch
* proc-fixup-pde-allocation-bloat.patch
* procfs-uptime-use-ktime_get_boottime_ts64.patch
* proc-test-proc-self-symlink.patch
* proc-test-proc-thread-self-symlink.patch
* proc-smaller-readlock-section-in-readdir-proc.patch
* proc-put-task-earlier-in-proc-fail-nth.patch
* proc-save-2-atomic-ops-on-write-to-proc-attr.patch
* proc-use-macro-in-proc-latency-hook.patch
* proc-spread-const-a-bit.patch
* proc-use-unsigned-int-in-proc-stat-hook.patch
* fs-proc-adding-new-typedef-vm_fault_t.patch
* proc-kcore-use-__pa_symbol-for-kcore_text-list-entries.patch
* proc-kcore-dont-grab-lock-for-kclist_add.patch
* proc-kcore-dont-grab-lock-for-memory-hotplug-notifier.patch
* proc-kcore-replace-kclist_lock-rwlock-with-rwsem.patch
* proc-kcore-fix-memory-hotplug-vs-multiple-opens-race.patch
* proc-kcore-hold-lock-during-read.patch
* proc-kcore-clean-up-elf-header-generation.patch
* proc-kcore-optimize-multiple-page-reads.patch
* crash_core-use-vmcoreinfo_symbol_array-for-swapper_pg_dir.patch
* proc-kcore-add-vmcoreinfo-note-to-proc-kcore.patch
* include-asm-generic-bugh-clarify-valid-uses-of-warn.patch
* kernelh-documentation-for-roundup-vs-round_up.patch
* bdi-use-refcount_t-for-reference-counting-instead-atomic_t.patch
* bdi-use-irqsave-variant-of-refcount_dec_and_lock.patch
* userns-use-refcount_t-for-reference-counting-instead-atomic_t.patch
* userns-use-irqsave-variant-of-refcount_dec_and_lock.patch
* linux-compilerh-dont-use-bool.patch
* crash-print-timestamp-using-time64_t.patch
* kernel-hung_taskc-allow-to-set-checking-interval-separately-from-timeout.patch
* spellingtxt-add-more-spellings-to-spellingtxt.patch
* arch-enable-relative-relocations-for-arm64-power-and-x86.patch
* module-allow-symbol-exports-to-be-disabled.patch
* module-use-relative-references-for-__ksymtab-entries.patch
* init-allow-initcall-tables-to-be-emitted-using-relative-references.patch
* pci-add-support-for-relative-addressing-in-quirk-tables.patch
* kernel-tracepoints-add-support-for-relative-references.patch
* epoll-use-the-waitqueue-lock-to-protect-ep-wq.patch
* userfaultfd-use-fault_wqh-lock.patch
* sched-wait-assert-the-wait_queue_head-lock-is-held-in-__wake_up_common.patch
* fs-epoll-loosen-irq-safety-in-ep_scan_ready_list.patch
* fs-epoll-loosen-irq-safety-in-epoll_insert-and-epoll_remove.patch
* fs-epoll-robustify-irq-safety-with-lockdep_assert_irqs_enabled.patch
* get_maintainer-allow-usage-outside-of-kernel-tree.patch
* get_maintainerpl-add-mpath=path-or-file-for-maintainers-file-location.patch
* get_maintainer-allow-option-mpath-directory-to-read-all-files-in-directory.patch
* bitmap-drop-unnecessary-0-check-for-u32-array-operations.patch
* bitops-introduce-bits_per_type.patch
* lib-make-struct-pointer-foo-static.patch
* lib-add-crc64-calculation-routines.patch
* bcache-use-routines-from-lib-crc64c-for-crc64-calculation.patch
* lib-remove-default-n-in-kconfig-for-tests.patch
* lib-test_hexdump-fix-failure-on-big-endian-cpu.patch
* checkpatch-add-a-strict-test-for-structs-with-bool-member-definitions.patch
* checkpatch-add-fix-for-concatenated_string-and-string_fragments.patch
* checkpatch-improve-runtime-execution-speed-a-little.patch
* checkpatch-update-section-keywords.patch
* checkpatch-warn-if-missing-author-signed-off-by.patch
* checkpatch-fix-macro-argument-reuse-test.patch
* checkpatch-validate-spdx-license-with-spdxcheckpy.patch
* checkpatch-fix-krealloc-reuse-test.patch
* checkpatch-check-for-functions-with-passed-by-value-structs-or-unions.patch
* checkpatch-check-for-if-0-if-1.patch
* checkpatch-warn-when-a-patch-doesnt-have-a-description.patch
* checkpatch-fix-spdx-license-check-with-root=path.patch
* checkpatch-check-for-space-after-else-keyword.patch
* checkpatch-warn-on-unnecessary-int-declarations.patch
* checkpatch-dt-bindings-should-be-a-separate-patch.patch
* fs-epoll-simply-config_net_rx_busy_poll-ifdefery.patch
* fs-epoll-loosen-irq-safety-in-ep_poll.patch
* fs-eventpoll-simplify-ep_is_linked-callers.patch
* sparse-remove-uneffective-sparse-disabling.patch
* init-kconfig-fix-its-typos.patch
* init-main-log-init-process-file-name.patch
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
* hfsplus-avoid-deadlock-on-file-truncation.patch
* hfsplus-fix-decomposition-of-hangul-characters.patch
* hfsplus-drop-acl-support.patch
* reiserfs-use-monotonic-time-for-j_trans_start_time.patch
* reiserfs-remove-obsolete-print_time-function.patch
* reiserfs-change-j_timestamp-type-to-time64_t.patch
* reiserfs-fix-broken-xattr-handling-heap-corruption-bad-retval.patch
* fat-add-fitrim-ioctl-for-fat-file-system.patch
* fat-validate-i_start-before-using.patch
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
* rapidio-remove-redundant-pointer-md.patch
* sysctl-fix-typos-in-comments.patch
* adfs-use-timespec64-for-time-conversion.patch
* sysvfs-use-ktime_get_real_seconds-for-superblock-stamp.patch
* kconfig-remove-expert-from-checkpoint_restore.patch
* ipc-ipc-compute-kern_ipc_permid-under-the-ipc-lock.patch
* ipc-reorganize-initialization-of-kern_ipc_permseq.patch
* ipc-utilc-use-ipc_rcu_putref-for-failues-in-ipc_addid.patch
* ipc-rename-ipcctl_pre_down_nolock.patch
* ipc-utilc-correct-comment-in-ipc_obtain_object_check.patch
* ipc-drop-ipc_lock.patch
* lib-rhashtable-simplify-bucket_table_alloc.patch
* lib-rhashtable-guarantee-initial-hashtable-allocation.patch
* ipc-get-rid-of-ids-tables_initialized-hack.patch
* ipc-simplify-ipc-initialization.patch
* ipc-utilc-further-variable-name-cleanups.patch
* ipc-utilc-update-return-value-of-ipc_getref-from-int-to-bool.patch
* mm-memcontrol-print-proper-oom-header-when-no-eligible-victim-left.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* prctl-add-pr_et_pdeathsig_proc.patch
* ocfs2-get-rid-of-ocfs2_is_o2cb_active-function.patch
* ocfs2-without-quota-support-try-to-avoid-calling-quota-recovery.patch
* ocfs2-dont-use-iocb-when-eiocbqueued-returns.patch
* ocfs2-fix-a-misuse-a-of-brelse-after-failing-ocfs2_check_dir_entry.patch
* ocfs2-dont-put-and-assigning-null-to-bh-allocated-outside.patch
* ocfs2-dlmglue-clean-up-timestamp-handling.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* namei-allow-restricted-o_creat-of-fifos-and-regular-files.patch
  mm.patch
* arm-arm64-introduce-config_have_memblock_pfn_valid.patch
* mm-page_alloc-remain-memblock_next_valid_pfn-on-arm-arm64.patch
* mm-page_alloc-reduce-unnecessary-binary-search-in-memblock_next_valid_pfn.patch
* mm-page_alloc-reduce-unnecessary-binary-search-in-memblock_next_valid_pfn-fix.patch
* mm-memblock-introduce-memblock_search_pfn_regions.patch
* mm-memblock-introduce-memblock_search_pfn_regions-fix.patch
* mm-memblock-introduce-pfn_valid_region.patch
* mm-page_alloc-reduce-unnecessary-binary-search-in-early_pfn_valid.patch
* z3fold-fix-wrong-handling-of-headless-pages.patch
* mm-fix-race-on-soft-offlining-free-huge-pages.patch
* mm-soft-offline-close-the-race-against-page-allocation.patch
* mm-soft-offline-close-the-race-against-page-allocation-fix.patch
* mm-adjust-max-read-count-in-generic_file_buffered_read.patch
* mm-make-memmap_init-a-proper-function.patch
* mm-calculate-deferred-pages-after-skipping-mirrored-memory.patch
* mm-calculate-deferred-pages-after-skipping-mirrored-memory-v2.patch
* mm-calculate-deferred-pages-after-skipping-mirrored-memory-fix.patch
* mm-move-mirrored-memory-specific-code-outside-of-memmap_init_zone.patch
* mm-move-mirrored-memory-specific-code-outside-of-memmap_init_zone-v2.patch
* mm-swap-fix-race-between-swapoff-and-some-swap-operations.patch
* mm-swap-fix-race-between-swapoff-and-some-swap-operations-v6.patch
* mm-fix-race-between-swapoff-and-mincore.patch
* list_lru-prefetch-neighboring-list-entries-before-acquiring-lock.patch
* list_lru-prefetch-neighboring-list-entries-before-acquiring-lock-fix.patch
* mm-add-strictlimit-knob-v2.patch
* mm-dont-expose-page-to-fast-gup-before-its-ready.patch
* mm-page_owner-align-with-pageblock_nr_pages.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* info-task-hung-in-generic_file_write_iter.patch
* hfsplus-prevent-crash-on-exit-from-failed-search.patch
* hfs-prevent-crash-on-exit-from-failed-search.patch
* hfsplus-fix-null-dereference-in-hfsplus_lookup.patch
* bfs-add-sanity-check-at-bfs_fill_super.patch
  linux-next.patch
  linux-next-rejects.patch
  linux-next-git-rejects.patch
* merge-fix-up-for-signal-pass-pid-type-into-group_send_sig_info.patch
* hwtracing-intel_th-change-return-type-to-vm_fault_t.patch
* fs-afs-adding-new-return-type-vm_fault_t.patch
* treewide-correct-differenciate-and-instanciate-typos.patch
* vmcore-hide-vmcoredd_mmap_dumps-for-nommu-builds.patch
* mm-util-make-strndup_user-description-a-kernel-doc-comment.patch
* mm-util-add-kernel-doc-for-kvfree.patch
* docs-core-api-kill-trailing-whitespace-in-kernel-apirst.patch
* docs-core-api-move-strmemdup-to-string-manipulation.patch
* docs-core-api-split-memory-management-api-to-a-separate-file.patch
* docs-mm-make-gfp-flags-descriptions-usable-as-kernel-doc.patch
* docs-core-api-mm-api-add-section-about-gfp-flags.patch
* gpu-drm-gma500-change-return-type-to-vm_fault_t.patch
* treewide-convert-iso_8859-1-text-comments-to-utf-8.patch
* s390-ebcdic-convert-comments-to-utf-8.patch
* lib-fonts-convert-comments-to-utf-8.patch
* mm-change-return-type-int-to-vm_fault_t-for-fault-handlers.patch
* mm-change-return-type-int-to-vm_fault_t-for-fault-handlers-fix.patch
* vfs-replace-current_kernel_time64-with-ktime-equivalent.patch
* fix-read-buffer-overflow-in-delta-ipc.patch
  make-sure-nobodys-leaking-resources.patch
  releasing-resources-with-children.patch
  mutex-subsystem-synchro-test-module.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  slab-leaks3-default-y.patch
  workaround-for-a-pci-restoring-bug.patch
