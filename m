Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 396EF6B025D
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 17:37:54 -0400 (EDT)
Received: by igvi1 with SMTP id i1so21172171igv.1
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 14:37:54 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 32si4852163iop.36.2015.07.23.14.37.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jul 2015 14:37:53 -0700 (PDT)
Date: Thu, 23 Jul 2015 14:37:51 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2015-07-23-14-37 uploaded
Message-ID: <55b15eaf.eaHKxeKSTWEwtYEF%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz

The mm-of-the-moment snapshot 2015-07-23-14-37 has been uploaded to

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


This mmotm tree contains the following patches against 4.2-rc3:
(patches marked "*" will be included in linux-next)

  origin.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
* ipc-modify-message-queue-accounting-to-not-take-kernel-data-structures-into-account.patch
* mm-meminit-allow-early_pfn_to_nid-to-be-used-during-runtime.patch
* mm-meminit-replace-rwsem-with-completion.patch
* fs-file-table-reinit-files_statmax_files-after-deferred-memory-initialisation.patch
* mm-vmscan-do-not-wait-for-page-writeback-for-gfp_nofs-allocations.patch
* ocfs2-fix-bug-in-ocfs2_downconvert_thread_do_work.patch
* ocfs2-fix-bug-in-ocfs2_downconvert_thread_do_work-v2.patch
* signal-fix-information-leak-in-copy_siginfo_from_user32.patch
* signal-fix-information-leak-in-copy_siginfo_to_user.patch
* signalfd-fix-information-leak-in-signalfd_copyinfo.patch
* mm-slub-allow-merging-when-slab_debug_free-is-set.patch
* iommu-common-do-not-use-64-bit-constant-0xffffffffffffffffl-for-computing-align_mask.patch
* fsnotify-fix-oops-in-fsnotify_clear_marks_by_group_flags.patch
* ipc-use-private-shmem-or-hugetlbfs-inodes-for-shm-segments.patch
* mm-memory-failure-unlock_page-before-put_page.patch
* mm-memory-failure-fix-race-in-counting-num_poisoned_pages.patch
* mm-memory-failure-give-up-error-handling-for-non-tail-refcounted-thp.patch
* mm-memory-failure-check-__pg_hwpoison-separately-from-page_flags_check_at_.patch
* kernel-kthreadc-kthread_create_on_node-clarify-documentation.patch
* kernel-kthreadc-kthread_create_on_node-clarify-documentation-fix.patch
* capabilities-ambient-capabilities.patch
* capabilities-add-a-securebit-to-disable-pr_cap_ambient_raise.patch
* fs-optimize-inotify-fsnotify-code-for-unwatched-files.patch
* fsnotify-fix-check-in-inotify-fdinfo-printing.patch
* scripts-spellingtxt-adding-misspelled-word-for-check.patch
* scripts-spellingtxt-adding-misspelled-word-for-check-fix.patch
* kerneldoc-convert-error-messages-to-gnu-error-message-format.patch
* lindent-handle-missing-indent-gracefully.patch
* scripts-decode_stacktrace-fix-arm-architecture-decoding.patch
* ntfs-deletion-of-unnecessary-checks-before-the-function-call-iput.patch
* fs-ext4-fsyncc-generic_file_fsync-call-based-on-barrier-flag.patch
* ocfs2-fix-race-between-dio-and-recover-orphan.patch
* ocfs2-fix-several-issues-of-append-dio.patch
* ocfs2-do-not-bug-if-buffer-not-uptodate-in-__ocfs2_journal_access.patch
* ocfs2-do-not-log-twice-error-messages.patch
* ocfs2-clean-up-unused-local-variables-in-ocfs2_file_write_iter.patch
* ocfs2-set-filesytem-read-only-when-ocfs2_delete_entry-failed.patch
* ocfs2-set-filesytem-read-only-when-ocfs2_delete_entry-failed-v2.patch
* ocfs2-trusted-xattr-missing-cap_sys_admin-check.patch
* ocfs2-flush-inode-data-to-disk-and-free-inode-when-i_count-becomes-zero.patch
* add-errors=continue.patch
* acknowledge-return-value-of-ocfs2_error.patch
* clear-the-rest-of-the-buffers-on-error.patch
* ocfs2-fix-a-tiny-case-that-inode-can-not-removed.patch
* ocfs2-add-ip_alloc_sem-in-direct-io-to-protect-allocation-changes.patch
* ocfs2-extend-transaction-for-ocfs2_remove_rightmost_path-and-ocfs2_update_edge_lengths-before-to-avoid-inconsistency-between-inode-and-et.patch
* ocfs2-do-not-set-fs-read-only-if-rec-is-empty-while-committing-truncate.patch
* extend-enough-credits-for-freeing-one-truncate-record-while-replaying-truncate-records.patch
* resubmit-bug_onlockres-l_level-=-dlm_lock_ex-checkpointed-tripped-in-ocfs2_ci_checkpointed.patch
* resubmit-ocfs2_iop_set-get_acl-called-from-the-vfs-so-take-inode-lock-v2second-version.patch
* ocfs2-fix-race-between-crashed-dio-and-rm.patch
* ocfs2-use-64bit-variables-to-track-heartbeat-time.patch
* ocfs2-call-ocfs2_journal_access_di-before-ocfs2_journal_dirty-in-ocfs2_write_end_nolock.patch
* ocfs2-avoid-access-invalid-address-when-read-o2dlm-debug-messages.patch
* ocfs2-neaten-do_error-ocfs2_error-and-ocfs2_abort.patch
* ocfs2-export-ocfs2_kset-for-online-file-check.patch
* ocfs2-sysfile-interfaces-for-online-file-check.patch
* ocfs2-sysfile-interfaces-for-online-file-check-fix.patch
* ocfs2-create-remove-sysfile-for-online-file-check.patch
* ocfs2-check-fix-inode-block-for-online-file-check.patch
* ocfs2-add-feature-document-for-online-file-check.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* smpboot-fix-memory-leak-on-error-handling.patch
* smpboot-make-cleanup-to-mirror-setup.patch
* smpboot-allow-to-pass-the-cpumask-on-per-cpu-thread-registration.patch
* smpboot-allow-to-pass-the-cpumask-on-per-cpu-thread-registration-fix.patch
* watchdog-simplify-housekeeping-affinity-with-the-appropriate-mask.patch
  mm.patch
* slub-fix-spelling-succedd-to-succeed.patch
* slab-infrastructure-for-bulk-object-allocation-and-freeing.patch
* slub-bulk-alloc-extract-objects-from-the-per-cpu-slab.patch
* slub-improve-bulk-alloc-strategy.patch
* slub-initial-bulk-free-implementation.patch
* slub-add-support-for-kmem_cache_debug-in-bulk-calls.patch
* mm-slub-move-slab-initialization-into-irq-enabled-region.patch
* mm-slub-fix-slab-double-free-in-case-of-duplicate-sysfs-filename.patch
* userfaultfd-linux-documentation-vm-userfaultfdtxt.patch
* userfaultfd-linux-documentation-vm-userfaultfdtxt-fix.patch
* userfaultfd-waitqueue-add-nr-wake-parameter-to-__wake_up_locked_key.patch
* userfaultfd-uapi.patch
* userfaultfd-uapi-add-missing-include-typesh.patch
* userfaultfd-linux-userfaultfd_kh.patch
* userfaultfd-add-vm_userfaultfd_ctx-to-the-vm_area_struct.patch
* userfaultfd-add-vm_uffd_missing-and-vm_uffd_wp.patch
* userfaultfd-call-handle_userfault-for-userfaultfd_missing-faults.patch
* userfaultfd-teach-vma_merge-to-merge-across-vma-vm_userfaultfd_ctx.patch
* userfaultfd-prevent-khugepaged-to-merge-if-userfaultfd-is-armed.patch
* userfaultfd-add-new-syscall-to-provide-memory-externalization.patch
* userfaultfd-add-new-syscall-to-provide-memory-externalization-fix.patch
* userfaultfd-add-new-syscall-to-provide-memory-externalization-fix-fix.patch
* userfaultfd-add-new-syscall-to-provide-memory-externalization-fix-fix-fix.patch
* userfaultfd-rename-uffd_apibits-into-features.patch
* userfaultfd-rename-uffd_apibits-into-features-fixup.patch
* userfaultfd-change-the-read-api-to-return-a-uffd_msg.patch
* userfaultfd-change-the-read-api-to-return-a-uffd_msg-fix.patch
* userfaultfd-change-the-read-api-to-return-a-uffd_msg-fix-2.patch
* userfaultfd-change-the-read-api-to-return-a-uffd_msg-fix-2-fix.patch
* userfaultfd-wake-pending-userfaults.patch
* userfaultfd-optimize-read-and-poll-to-be-o1.patch
* userfaultfd-optimize-read-and-poll-to-be-o1-fix.patch
* userfaultfd-allocate-the-userfaultfd_ctx-cacheline-aligned.patch
* userfaultfd-solve-the-race-between-uffdio_copyzeropage-and-read.patch
* userfaultfd-buildsystem-activation.patch
* userfaultfd-activate-syscall.patch
* userfaultfd-activate-syscall-fix.patch
* userfaultfd-uffdio_copyuffdio_zeropage-uapi.patch
* userfaultfd-mcopy_atomicmfill_zeropage-uffdio_copyuffdio_zeropage-preparation.patch
* userfaultfd-avoid-mmap_sem-read-recursion-in-mcopy_atomic.patch
* userfaultfd-avoid-mmap_sem-read-recursion-in-mcopy_atomic-fix.patch
* userfaultfd-uffdio_copy-and-uffdio_zeropage.patch
* userfaultfd-require-uffdio_api-before-other-ioctls.patch
* userfaultfd-allow-signals-to-interrupt-a-userfault.patch
* userfaultfd-propagate-the-full-address-in-thp-faults.patch
* userfaultfd-avoid-missing-wakeups-during-refile-in-userfaultfd_read.patch
* userfaultfd-selftest.patch
* mm-mlock-refactor-mlock-munlock-and-munlockall-code.patch
* mm-mlock-refactor-mlock-munlock-and-munlockall-code-checkpatch-fixes.patch
* mm-mlock-add-new-mlock-munlock-and-munlockall-system-calls.patch
* mm-mlock-add-new-mlock-munlock-and-munlockall-system-calls-v4.patch
* mm-mlock-add-new-mlock-munlock-and-munlockall-system-calls-fix.patch
* mm-mlock-add-new-mlock-munlock-and-munlockall-system-calls-fix-2.patch
* mm-gup-add-mm_lock_present.patch
* mm-gup-add-mm_lock_present-checkpatch-fixes.patch
* mm-mlock-introduce-vm_lockonfault-and-add-mlock-flags-to-enable-it.patch
* mm-mlock-introduce-vm_lockonfault-and-add-mlock-flags-to-enable-it-v4.patch
* mm-mlock-introduce-vm_lockonfault-and-add-mlock-flags-to-enable-it-v4-checkpatch-fixes.patch
* mm-mmap-add-mmap-flag-to-request-vm_lockonfault.patch
* mm-mmap-add-mmap-flag-to-request-vm_lockonfault-v4.patch
* mm-mmap-add-mmap-flag-to-request-vm_lockonfault-v4-fix.patch
* selftests-vm-add-tests-for-lock-on-fault.patch
* selftests-vm-add-tests-for-lock-on-fault-v4.patch
* x86-mm-trace-when-an-ipi-is-about-to-be-sent.patch
* mm-send-one-ipi-per-cpu-to-tlb-flush-all-entries-after-unmapping-pages.patch
* mm-send-one-ipi-per-cpu-to-tlb-flush-all-entries-after-unmapping-pages-fix.patch
* mm-defer-flush-of-writable-tlb-entries.patch
* documentation-features-vm-add-feature-description-and-arch-support-status-for-batched-tlb-flush-after-unmap.patch
* mm-memblock-warn_on-when-nid-differs-from-overlap-region.patch
* genalloc-add-name-arg-to-gen_pool_get-and-devm_gen_pool_create.patch
* genalloc-add-name-arg-to-gen_pool_get-and-devm_gen_pool_create-fix.patch
* genalloc-add-name-arg-to-gen_pool_get-and-devm_gen_pool_create-v2.patch
* genalloc-add-support-of-multiple-gen_pools-per-device.patch
* genalloc-add-support-of-multiple-gen_pools-per-device-fix.patch
* genalloc-add-support-of-multiple-gen_pools-per-device-fix-2.patch
* mm-memcontrol-bring-back-the-vm_bug_on-in-mem_cgroup_swapout.patch
* mm-fix-status-code-move_pages-returns-for-zero-page.patch
* mm-make-gup-handle-pfn-mapping-unless-foll_get-is-requested.patch
* mm-make-gup-handle-pfn-mapping-unless-foll_get-is-requested-fix.patch
* hugetlb-make-the-function-vma_shareable-bool.patch
* mremap-dont-leak-new_vma-if-f_op-mremap-fails.patch
* mm-move-mremap-from-file_operations-to-vm_operations_struct.patch
* mm-move-mremap-from-file_operations-to-vm_operations_struct-v3.patch
* mremap-dont-do-mm_populatenew_addr-on-failure.patch
* mremap-dont-do-uneccesary-checks-if-new_len-==-old_len.patch
* mremap-simplify-the-overlap-check-in-mremap_to.patch
* mm-remove-struct-node_active_region.patch
* mm-change-function-return-from-int-to-bool-for-the-function-is_page_busy.patch
* memory-make-the-function-tlb_next_batch-bool-now.patch
* mm-make-the-function-madvise_behaviour_valid-bool.patch
* mm-make-the-function-vma_has_reserves-bool.patch
* mm-introduce-vma_is_anonymousvma-helper.patch
* mmap-fix-the-usage-of-vm_pgoff-in-special_mapping-paths.patch
* mremap-fix-the-wrong-vma-vm_file-check-in-copy_vma.patch
* thp-vma_adjust_trans_huge-adjust-file-backed-vma-too.patch
* dax-move-dax-related-functions-to-a-new-header.patch
* dax-revert-userfaultfd-change.patch
* thp-prepare-for-dax-huge-pages.patch
* thp-prepare-for-dax-huge-pages-fix.patch
* mm-add-a-pmd_fault-handler.patch
* mm-export-various-functions-for-the-benefit-of-dax.patch
* mm-add-vmf_insert_pfn_pmd.patch
* dax-add-huge-page-fault-support.patch
* ext2-huge-page-fault-support.patch
* ext4-huge-page-fault-support.patch
* xfs-huge-page-fault-support.patch
* fs-daxc-fix-typo-in-endif-comment.patch
* mm-page-refine-the-calculation-of-highest-possible-node-id.patch
* mm-page-remove-unused-variable-of-free_area_init_core.patch
* mm-memblock-warn_on-when-flags-differs-from-overlap-region.patch
* mm-rip-put_page_unless_one-as-it-has-no-callers.patch
* pagemap-check-permissions-and-capabilities-at-open-time.patch
* pagemap-switch-to-the-new-format-and-do-some-cleanup.patch
* pagemap-rework-hugetlb-and-thp-report.patch
* pagemap-hide-physical-addresses-from-non-privileged-users.patch
* pagemap-add-mmap-exclusive-bit-for-marking-pages-mapped-only-here.patch
* pagemap-add-mmap-exclusive-bit-for-marking-pages-mapped-only-here-fix.patch
* pagemap-update-documentation.patch
* pagemap-update-documentation-fix.patch
* memtest-use-kstrtouint-instead-of-simple_strtoul.patch
* memtest-cleanup-log-messages.patch
* memtest-cleanup-log-messages-fix.patch
* memtest-remove-unused-header-files.patch
* mm-show-proportional-swap-share-of-the-mapping.patch
* mm-show-proportional-swap-share-of-the-mapping-fix.patch
* fs-do-not-prefault-sys_write-user-buffer-pages.patch
* mm-improve-__gfp_noretry-comment-based-on-implementation.patch
* mm-improve-__gfp_noretry-comment-based-on-implementation-fix.patch
* mm-make-the-function-set_recommended_min_free_kbytes-have-a-return-type-of-void.patch
* mm-oom-organize-oom-context-into-struct.patch
* mm-oom-pass-an-oom-order-of-1-when-triggered-by-sysrq.patch
* mm-oom-do-not-panic-for-oom-kills-triggered-from-sysrq.patch
* mm-oom-add-description-of-struct-oom_control.patch
* mm-oom-remove-unnecessary-variable.patch
* mm-slab_common-allow-null-cache-pointer-in-kmem_cache_destroy.patch
* mm-mempool-allow-null-pool-pointer-in-mempool_destroy.patch
* mm-dmapool-allow-null-pool-pointer-in-dma_pool_destroy.patch
* memcg-export-struct-mem_cgroup.patch
* memcg-export-struct-mem_cgroup-fix.patch
* memcg-export-struct-mem_cgroup-fix-2.patch
* memcg-get-rid-of-mem_cgroup_root_css-for-config_memcg.patch
* memcg-get-rid-of-extern-for-functions-in-memcontrolh.patch
* memcg-restructure-mem_cgroup_can_attach.patch
* memcg-tcp_kmem-check-for-cg_proto-in-sock_update_memcg.patch
* lib-show_memc-correct-reserved-memory-calculation.patch
* mm-page_isolation-remove-bogus-tests-for-isolated-pages.patch
* mm-page_isolation-remove-bogus-tests-for-isolated-pages-fix.patch
* mm-rename-and-move-get-set_freepage_migratetype.patch
* mm-rename-and-move-get-set_freepage_migratetype-v2.patch
* mm-hugetlb-add-cache-of-descriptors-to-resv_map-for-region_add.patch
* mm-hugetlb-add-cache-of-descriptors-to-resv_map-for-region_add-fix.patch
* mm-hugetlb-add-region_del-to-delete-a-specific-range-of-entries.patch
* mm-hugetlb-expose-hugetlb-fault-mutex-for-use-by-fallocate.patch
* hugetlbfs-hugetlb_vmtruncate_list-needs-to-take-a-range-to-delete.patch
* hugetlbfs-truncate_hugepages-takes-a-range-of-pages.patch
* mm-hugetlb-vma_has_reserves-needs-to-handle-fallocate-hole-punch.patch
* mm-hugetlb-alloc_huge_page-handle-areas-hole-punched-by-fallocate.patch
* hugetlbfs-new-huge_add_to_page_cache-helper-routine.patch
* hugetlbfs-add-hugetlbfs_fallocate.patch
* mm-madvise-allow-remove-operation-for-hugetlbfs.patch
* memblock-make-memblock_overlaps_region-return-bool.patch
* mem-hotplug-handle-node-hole-when-initializing-numa_meminfo.patch
* mm-srcu-ify-shrinkers.patch
* mempolicy-get-rid-of-duplicated-check-for-vmavm_pfnmap-in-queue_pages_range.patch
* page-flags-trivial-cleanup-for-pagetrans-helpers.patch
* page-flags-introduce-page-flags-policies-wrt-compound-pages.patch
* page-flags-define-pg_locked-behavior-on-compound-pages.patch
* page-flags-define-behavior-of-fs-io-related-flags-on-compound-pages.patch
* page-flags-define-behavior-of-lru-related-flags-on-compound-pages.patch
* page-flags-define-behavior-of-lru-related-flags-on-compound-pages-fix.patch
* page-flags-define-behavior-of-lru-related-flags-on-compound-pages-fix-fix.patch
* page-flags-define-behavior-slb-related-flags-on-compound-pages.patch
* page-flags-define-behavior-of-xen-related-flags-on-compound-pages.patch
* page-flags-define-pg_reserved-behavior-on-compound-pages.patch
* page-flags-define-pg_swapbacked-behavior-on-compound-pages.patch
* page-flags-define-pg_swapcache-behavior-on-compound-pages.patch
* page-flags-define-pg_mlocked-behavior-on-compound-pages.patch
* page-flags-define-pg_uncached-behavior-on-compound-pages.patch
* page-flags-define-pg_uptodate-behavior-on-compound-pages.patch
* page-flags-look-on-head-page-if-the-flag-is-encoded-in-page-mapping.patch
* mm-sanitize-page-mapping-for-tail-pages.patch
* include-linux-page-flagsh-rename-macros-to-avoid-collisions.patch
* memcg-add-page_cgroup_ino-helper.patch
* memcg-add-page_cgroup_ino-helper-fix.patch
* hwpoison-use-page_cgroup_ino-for-filtering-by-memcg.patch
* memcg-zap-try_get_mem_cgroup_from_page.patch
* proc-add-kpagecgroup-file.patch
* mmu-notifier-add-clear_young-callback.patch
* mmu-notifier-add-clear_young-callback-fix.patch
* proc-add-kpageidle-file.patch
* proc-add-kpageidle-file-fix.patch
* proc-export-idle-flag-via-kpageflags.patch
* proc-add-cond_resched-to-proc-kpage-read-write-loop.patch
* mm-increase-swap_cluster_max-to-batch-tlb-flushes.patch
* mm-vmscan-fix-the-page-state-calculation-in-too_many_isolated.patch
* mm-page_isolation-check-pfn-validity-before-access.patch
* mm-fix-invalid-use-of-pfn_valid_within-in-test_pages_in_a_zone.patch
* fs-mpagec-forgotten-write_sync-in-case-of-data-integrity-write.patch
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
* mm-dont-split-thp-page-when-syscall-is-called.patch
* mm-dont-split-thp-page-when-syscall-is-called-fix.patch
* mm-dont-split-thp-page-when-syscall-is-called-fix-2.patch
* mm-dont-split-thp-page-when-syscall-is-called-fix-3.patch
* mm-free-swp_entry-in-madvise_free.patch
* mm-move-lazy-free-pages-to-inactive-list.patch
* mm-move-lazy-free-pages-to-inactive-list-fix.patch
* mm-move-lazy-free-pages-to-inactive-list-fix-fix.patch
* mm-move-lazy-free-pages-to-inactive-list-fix-fix-fix.patch
* zsmalloc-drop-unused-variable-nr_to_migrate.patch
* zsmalloc-always-keep-per-class-stats.patch
* zsmalloc-introduce-zs_can_compact-function.patch
* zsmalloc-cosmetic-compaction-code-adjustments.patch
* zsmalloc-zram-introduce-zs_pool_stats-api.patch
* zsmalloc-account-the-number-of-compacted-pages.patch
* zsmalloc-use-shrinker-to-trigger-auto-compaction.patch
* zsmalloc-partial-page-ordering-within-a-fullness_list.patch
* zsmalloc-consider-zs_almost_full-as-migrate-source.patch
* zsmalloc-use-class-pages_per_zspage.patch
* zsmalloc-do-not-take-class-lock-in-zs_shrinker_count.patch
* mm-swap-zswap-maybe_preload-refactoring.patch
* mm-zpool-constify-the-zpool_ops.patch
* mm-zbud-constify-the-zbud_ops.patch
* procfs-always-expose-proc-pid-map_files-and-make-it-readable.patch
* procfs-always-expose-proc-pid-map_files-and-make-it-readable-fix.patch
* procfs-always-expose-proc-pid-map_files-and-make-it-readable-fix-fix.patch
* extable-remove-duplicated-include-from-extablec.patch
* printk-include-pr_fmt-in-pr_debug_ratelimited.patch
* lib-vsprintf-add-%pt-format-specifier.patch
* kstrto-accept-0-for-signed-conversion.patch
* add-parse_integer-replacement-for-simple_strto.patch
* parse_integer-add-runtime-testsuite.patch
* parse-integer-rewrite-kstrto.patch
* parse_integer-convert-scanf.patch
* scanf-fix-type-range-overflow.patch
* parse_integer-convert-lib.patch
* parse_integer-convert-mm.patch
* parse_integer-convert-mm-fix.patch
* parse_integer-convert-fs.patch
* parse_integer-convert-fs-cachefiles.patch
* parse_integer-convert-ext2-ext3-ext4.patch
* parse_integer-convert-fs-ocfs2.patch
* parse_integer-convert-fs-9p.patch
* parse_integer-convert-fs-exofs.patch
* parse_integer-convert-sound.patch
* parse_integer-add-checkpatchpl-notice.patch
* lib-bitmapc-correct-a-code-style-and-do-some-optimization.patch
* lib-bitmapc-fix-a-special-string-handling-bug-in-__bitmap_parselist.patch
* lib-bitmapc-bitmap_parselist-can-accept-string-with-whitespaces-on-head-or-tail.patch
* hexdump-do-not-print-debug-dumps-for-config_debug.patch
* mm-utilc-add-kstrimdup.patch
* lib-add-crc64-ecma-module.patch
* checkpatch-warn-on-bare-sha-1-commit-ids-in-commit-logs.patch
* checkpatch-add-warning-on-bug-bug_on-use.patch
* checkpatch-improve-suspect_code_indent-test.patch
* checkpatch-allow-longer-declaration-macros.patch
* checkpatch-add-some-foo_destroy-functions-to-needless_if-tests.patch
* checkpatch-report-the-right-line-when-using-emacs-and-file.patch
* checkpatch-always-check-block-comment-styles.patch
* hfshfsplus-cache-pages-correctly-between-bnode_create-and-bnode_free.patch
* hfs-fix-b-tree-corruption-after-insertion-at-position-0.patch
* fat-add-fat_fallocate-operation.patch
* fat-skip-cluster-allocation-on-fallocated-region.patch
* fat-permit-to-return-phy-block-number-by-fibmap-in-fallocated-region.patch
* documentation-filesystems-vfattxt-update-the-limitation-for-fat-fallocate.patch
* seq_file-provide-an-analogue-of-print_hex_dump.patch
* crypto-qat-use-seq_hex_dump-to-dump-buffers.patch
* parisc-use-seq_hex_dump-to-dump-buffers.patch
* zcrypt-use-seq_hex_dump-to-dump-buffers.patch
* kmemleak-use-seq_hex_dump-to-dump-buffers.patch
* wil6210-use-seq_hex_dump-to-dump-buffers.patch
* kexec-split-kexec_file-syscall-code-to-kexec_filec.patch
* kexec-split-kexec_load-syscall-from-kexec-core-code.patch
* kexec-split-kexec_load-syscall-from-kexec-core-code-checkpatch-fixes.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* sysctl-fix-int-unsigned-long-assignments-in-int_min-case.patch
* make-affs-root-lookup-from-blkdev-logical-size.patch
* w1-masters-omap_hdq-add-support-for-1-wire-mode.patch
* ipc-convert-invalid-scenarios-to-use-warn_on.patch
* ipc-msgc-msgsnd-use-freezable-blocking-call.patch
* msgrcv-use-freezable-blocking-call.patch
  linux-next.patch
  linux-next-rejects.patch
  linux-next-git-rejects.patch
* drivers-gpu-drm-i915-intel_spritec-fix-build.patch
* drivers-gpu-drm-i915-intel_tvc-fix-build.patch
* net-netfilter-ipset-work-around-gcc-444-initializer-bug.patch
* arm-mm-do-not-use-virt_to_idmap-for-nommu-systems.patch
* namei-fix-warning-while-make-xmldocs-caused-by-nameic.patch
* fs-seq_file-convert-int-seq_vprint-seq_printf-etc-returns-to-void.patch
* fs-seq_file-convert-int-seq_vprint-seq_printf-etc-returns-to-void-fix.patch
* mm-mark-most-vm_operations_struct-const.patch
* mm-mpx-add-vm_flags_t-vm_flags-arg-to-do_mmap_pgoff.patch
* mm-make-sure-all-file-vmas-have-vm_ops-set.patch
* mm-use-vma_is_anonymous-in-create_huge_pmd-and-wp_huge_pmd.patch
* mm-madvise-use-vma_is_anonymous-to-check-for-anon-vma.patch
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
