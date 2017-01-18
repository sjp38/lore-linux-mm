Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 88BA46B0038
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 17:58:19 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id z67so34839880pgb.0
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 14:58:19 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j16si255819pli.308.2017.01.18.14.58.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 14:58:18 -0800 (PST)
Date: Wed, 18 Jan 2017 14:58:17 -0800
From: akpm@linux-foundation.org
Subject: mmotm 2017-01-18-14-57 uploaded
Message-ID: <587ff309.bINNK+AbAwZVL26P%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2017-01-18-14-57 has been uploaded to

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


This mmotm tree contains the following patches against 4.10-rc4:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
* memory_hotplug-zone_can_shift-returns-boolean-value.patch
* mm-respect-foll_force-foll_cow-for-thp.patch
* mm-respect-foll_force-foll_cow-for-thp-checkpatch-fixes.patch
* dax-fix-build-warnings-with-fs_dax-and-fs_iomap.patch
* memstick-core-avoid-wnonnull-warning.patch
* userfaultfd-fix-sigbus-resulting-from-false-rwsem-wakeups.patch
* slub-trace-free-objects-at-kern_info.patch
* mm-alloc_contig-re-allow-cma-to-compact-fs-pages.patch
* proc-add-a-schedule-point-in-proc_pid_readdir.patch
* proc-add-a-schedule-point-in-proc_pid_readdir-fix.patch
* mm-memcg-do-not-retry-precharge-charges.patch
* documentation-filesystems-proctxt-add-vmpin.patch
* radix-tree-fix-private-list-warnings.patch
* mm-mempolicyc-do-not-put-mempolicy-before-using-its-nodemask.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* tracing-add-__print_flags_u64.patch
* dax-add-tracepoint-infrastructure-pmd-tracing.patch
* dax-update-maintainers-entries-for-fs-dax.patch
* dax-add-tracepoints-to-dax_pmd_load_hole.patch
* dax-add-tracepoints-to-dax_pmd_insert_mapping.patch
* mm-dax-make-pmd_fault-and-friends-to-be-the-same-as-fault.patch
* mm-dax-make-pmd_fault-and-friends-to-be-the-same-as-fault-v7.patch
* mm-dax-move-pmd_fault-to-take-only-vmf-parameter.patch
* dax-enable-iostat-for-read-write.patch
* dax-enable-iostat-for-read-write-fix.patch
* dma-debug-add-comment-for-failed-to-check-map-error.patch
* tools-vm-add-missing-makefile-rules.patch
* scripts-spellingtxt-add-several-more-common-spelling-mistakes.patch
* scripts-lindent-clean-up-and-optimize.patch
* scripts-checkstackpl-add-support-for-nios2.patch
* m32r-use-generic-currenth.patch
* m32r-fix-build-warning.patch
* debugobjects-track-number-of-kmem_cache_alloc-kmem_cache_free-done.patch
* debugobjects-scale-thresholds-with-of-cpus.patch
* debugobjects-reduce-contention-on-the-global-pool_lock.patch
* ocfs2-dlmglue-prepare-tracking-logic-to-avoid-recursive-cluster-lock.patch
* ocfs2-fix-deadlock-issue-when-taking-inode-lock-at-vfs-entry-points.patch
* ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called.patch
* ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called-fix.patch
* ocfs2-dlm-optimization-of-code-while-free-dead-node-locks.patch
* ocfs2-dlm-optimization-of-code-while-free-dead-node-locks-checkpatch-fixes.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* kernel-watchdog-prevent-false-hardlockup-on-overloaded-system.patch
* kernel-watchdog-prevent-false-hardlockup-on-overloaded-system-fix.patch
* kernel-watchdogc-do-not-hardcode-cpu-0-as-the-initial-thread.patch
  mm.patch
* slub-do-not-merge-cache-if-slub_debug-contains-a-never-merge-flag.patch
* mm-slub-add-a-dump_stack-to-the-unexpected-gfp-check.patch
* tmpfs-change-shmem_mapping-to-test-shmem_aops.patch
* mm-throttle-show_mem-from-warn_alloc.patch
* mm-throttle-show_mem-from-warn_alloc-fix.patch
* mm-page_alloc-dont-convert-pfn-to-idx-when-merging.patch
* mm-page_alloc-avoid-page_to_pfn-when-merging-buddies.patch
* mm-vmallocc-use-rb_entry_safe.patch
* mm-page_alloc-convert-page_group_by_mobility_disable-to-static-key.patch
* mm-trace-extract-compaction_status-and-zone_type-to-a-common-header.patch
* oom-trace-add-oom-detection-tracepoints.patch
* oom-trace-add-compaction-retry-tracepoint.patch
* userfaultfd-document-_ior-_iow.patch
* userfaultfd-correct-comment-about-uffd_feature_pagefault_flag_wp.patch
* userfaultfd-convert-bug-to-warn_on_once.patch
* userfaultfd-use-vma_is_anonymous.patch
* userfaultfd-non-cooperative-split-the-find_userfault-routine.patch
* userfaultfd-non-cooperative-add-ability-to-report-non-pf-events-from-uffd-descriptor.patch
* userfaultfd-non-cooperative-report-all-available-features-to-userland.patch
* userfaultfd-non-cooperative-add-fork-event.patch
* userfaultfd-non-cooperative-add-fork-event-build-warning-fix.patch
* userfaultfd-non-cooperative-dup_userfaultfd-use-mm_count-instead-of-mm_users.patch
* userfaultfd-non-cooperative-add-mremap-event.patch
* userfaultfd-non-cooperative-optimize-mremap_userfaultfd_complete.patch
* userfaultfd-non-cooperative-add-madvise-event-for-madv_dontneed-request.patch
* userfaultfd-non-cooperative-avoid-madv_dontneed-race-condition.patch
* userfaultfd-non-cooperative-wake-userfaults-after-uffdio_unregister.patch
* userfaultfd-hugetlbfs-add-copy_huge_page_from_user-for-hugetlb-userfaultfd-support.patch
* userfaultfd-hugetlbfs-add-hugetlb_mcopy_atomic_pte-for-userfaultfd-support.patch
* userfaultfd-hugetlbfs-add-__mcopy_atomic_hugetlb-for-huge-page-uffdio_copy.patch
* userfaultfd-hugetlbfs-fix-__mcopy_atomic_hugetlb-retry-error-processing.patch
* userfaultfd-hugetlbfs-fix-__mcopy_atomic_hugetlb-retry-error-processing-fix.patch
* userfaultfd-hugetlbfs-fix-__mcopy_atomic_hugetlb-retry-error-processing-fix-fix.patch
* userfaultfd-hugetlbfs-add-userfaultfd-hugetlb-hook.patch
* userfaultfd-hugetlbfs-allow-registration-of-ranges-containing-huge-pages.patch
* userfaultfd-hugetlbfs-add-userfaultfd_hugetlb-test.patch
* userfaultfd-hugetlbfs-userfaultfd_huge_must_wait-for-hugepmd-ranges.patch
* userfaultfd-hugetlbfs-gup-support-vm_fault_retry.patch
* userfaultfd-hugetlbfs-reserve-count-on-error-in-__mcopy_atomic_hugetlb.patch
* userfaultfd-hugetlbfs-uffd_feature_missing_hugetlbfs.patch
* userfaultfd-introduce-vma_can_userfault.patch
* userfaultfd-shmem-add-shmem_mcopy_atomic_pte-for-userfaultfd-support.patch
* userfaultfd-shmem-introduce-vma_is_shmem.patch
* userfaultfd-shmem-add-tlbflushh-header-for-microblaze.patch
* userfaultfd-shmem-use-shmem_mcopy_atomic_pte-for-shared-memory.patch
* userfaultfd-shmem-add-userfaultfd-hook-for-shared-memory-faults.patch
* userfaultfd-shmem-allow-registration-of-shared-memory-ranges.patch
* userfaultfd-shmem-add-userfaultfd_shmem-test.patch
* userfaultfd-shmem-lock-the-page-before-adding-it-to-pagecache.patch
* userfaultfd-shmem-avoid-a-lockup-resulting-from-corrupted-page-flags.patch
* userfaultfd-shmem-avoid-leaking-blocks-and-used-blocks-in-uffdio_copy.patch
* userfaultfd-hugetlbfs-uffd_feature_missing_shmem.patch
* userfaultfd-non-cooperative-selftest-introduce-userfaultfd_open.patch
* userfaultfd-non-cooperative-selftest-add-ufd-parameter-to-copy_page.patch
* userfaultfd-non-cooperative-selftest-add-test-for-fork-madvdontneed-and-remap-events.patch
* userfaultfd-selftest-test-uffdio_zeropage-on-all-memory-types.patch
* mm-mprotect-use-pmd_trans_unstable-instead-of-taking-the-pmd_lock.patch
* mm-vmscan-remove-unused-mm_vmscan_memcg_isolate.patch
* mm-vmscan-add-active-list-aging-tracepoint.patch
* mm-vmscan-add-active-list-aging-tracepoint-update.patch
* mm-vmscan-show-the-number-of-skipped-pages-in-mm_vmscan_lru_isolate.patch
* mm-vmscan-show-lru-name-in-mm_vmscan_lru_isolate-tracepoint.patch
* mm-vmscan-extract-shrink_page_list-reclaim-counters-into-a-struct.patch
* mm-vmscan-enhance-mm_vmscan_lru_shrink_inactive-tracepoint.patch
* mm-vmscan-add-mm_vmscan_inactive_list_is_low-tracepoint.patch
* trace-vmscan-postprocess-sync-with-tracepoints-updates.patch
* nfs-no-pg_private-waiters-remain-remove-waker.patch
* mm-un-export-wake_up_page-functions.patch
* mm-fix-filemapc-kernel-doc-warnings.patch
* mm-page_alloc-swap-likely-to-unlikely-as-code-logic-is-different-for-next_zones_zonelist.patch
* mm-compaction-add-vmstats-for-kcompactd-work.patch
* mm-page_alloc-skip-over-regions-of-invalid-pfns-where-possible.patch
* mmcompaction-serialize-waitqueue_active-checks.patch
* mm-bootmemc-cosmetic-improvement-of-code-readability.patch
* mm-fix-some-typos-in-mm-zsmallocc.patch
* mm-memblockc-trivial-code-refine-in-memblock_is_region_memory.patch
* mm-memblockc-check-return-value-of-memblock_reserve-in-memblock_virt_alloc_internal.patch
* mm-sparse-use-page_private-to-get-page-private-value.patch
* mm-memory_hotplug-set-magic-number-to-page-freelsit-instead-of-page-lrunext.patch
* powerpc-do-not-make-the-entire-heap-executable.patch
* mm-swap-fix-kernel-message-in-swap_info_get.patch
* mm-swap-add-cluster-lock.patch
* mm-swap-add-cluster-lock-v5.patch
* mm-swap-split-swap-cache-into-64mb-trunks.patch
* mm-swap-skip-read-ahead-for-unreferenced-swap-slots.patch
* mm-swap-allocate-swap-slots-in-batches.patch
* mm-swap-free-swap-slots-in-batch.patch
* mm-swap-add-cache-for-swap-slots-allocation.patch
* mm-swap-add-cache-for-swap-slots-allocation-fix.patch
* mm-swap-add-cache-for-swap-slots-allocation-fix-2.patch
* mm-swap-enable-swap-slots-cache-usage.patch
* mm-swap-skip-readahead-only-when-swap-slot-cache-is-enabled.patch
* mm-thp-add-new-defermadvise-defrag-option.patch
* writeback-use-rb_entry.patch
* mm-vmscan-do-not-count-freed-pages-as-pgdeactivate.patch
* mm-vmscan-cleanup-lru-size-claculations.patch
* mm-vmscan-consider-eligible-zones-in-get_scan_count.patch
* revert-mm-bail-out-in-shrink_inactive_list.patch
* mm-page_alloc-do-not-report-all-nodes-in-show_mem.patch
* mm-page_alloc-warn_alloc-print-nodemask.patch
* arch-mm-remove-arch-specific-show_mem.patch
* lib-show_memc-teach-show_mem-to-work-with-the-given-nodemask.patch
* lib-show_memc-teach-show_mem-to-work-with-the-given-nodemask-checkpatch-fixes.patch
* mm-consolidate-gfp_nofail-checks-in-the-allocator-slowpath.patch
* mm-oom-do-not-enfore-oom-killer-for-__gfp_nofail-automatically.patch
* mm-help-__gfp_nofail-allocations-which-do-not-trigger-oom-killer.patch
* mm-page_alloc-warn_alloc-nodemask-is-null-when-cpusets-are-disabled.patch
* mm-drop-zap_details-ignore_dirty.patch
* mm-drop-zap_details-check_swap_entries.patch
* mm-drop-unused-argument-of-zap_page_range.patch
* oom-reaper-use-madvise_dontneed-logic-to-decide-if-unmap-the-vma.patch
* z3fold-limit-first_num-to-the-actual-range-of-possible-buddy-indexes.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* mm-walk-the-zone-in-pageblock_nr_pages-steps.patch
* kasan-drain-quarantine-of-memcg-slab-objects.patch
* kasan-add-memcg-kmem_cache-test.patch
* frv-pci-frv-fix-build-warning.patch
* proc-use-rb_entry.patch
* proc-less-code-duplication-in-proc-cmdline.patch
* notifier-simplify-expression.patch
* timerqueue-use-rb_entry_safe.patch
* lib-add-module-support-to-crc32-tests.patch
* lib-add-module-support-to-glob-tests.patch
* lib-add-module-support-to-atomic64-tests.patch
* find_bit-micro-optimise-find_next__bit.patch
* find_bit-micro-optimise-find_next__bit-v2.patch
* linux-kernelh-fix-div_round_closest-to-support-negative-divisors.patch
* linux-kernelh-fix-div_round_closest-to-support-negative-divisors-fix.patch
* rbtree-use-designated-initializers.patch
* lib-add-config_test_sort-to-enable-self-test-of-sort.patch
* lib-add-config_test_sort-to-enable-self-test-of-sort-fix.patch
* checkpatch-warn-on-embedded-function-names.patch
* checkpatch-warn-on-logging-continuations.patch
* checkpatch-update-logfunctions.patch
* hfs-fix-fix-hfs_readdir.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* rapidio-use-get_user_pages_unlocked.patch
* fs-affs-remove-reference-to-affs_parent_ino.patch
* fs-affs-add-validation-block-function.patch
* fs-affs-make-affs-exportable.patch
* fs-affs-use-octal-for-permissions.patch
* fs-affs-add-prefix-to-some-functions.patch
* fs-affs-nameic-forward-declarations-clean-up.patch
* fs-affs-make-export-work-with-cold-dcache.patch
* config-android-recommended-disable-aio-support.patch
* config-android-base-enable-hardened-usercopy-and-kernel-aslr.patch
* fonts-keep-non-sparc-fonts-listed-together.patch
* scripts-gdb-add-lx-fdtdump-command.patch
* ipc-semc-avoid-using-spin_unlock_wait.patch
* ipc-sem-add-hysteresis.patch
  linux-next.patch
  linux-next-rejects.patch
* fs-add-i_blocksize.patch
* reimplement-idr-and-ida-using-the-radix-tree.patch
* reimplement-idr-and-ida-using-the-radix-tree-support-storing-null-in-the-idr.patch
* reimplement-idr-and-ida-using-the-radix-tree-support-storing-null-in-the-idr-checkpatch-fixes.patch
* reimplement-idr-and-ida-using-the-radix-tree-fix.patch
* scripts-spellingtxt-add-swith-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-swithc-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-an-user-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-an-union-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-an-one-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-partiton-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-aligment-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-algined-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-efective-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-varible-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-embeded-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-againt-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-neded-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-unneded-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-intialization-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-initialiazation-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-intialised-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-comsumer-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-disbled-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-overide-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-overrided-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-configuartion-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-applys-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-explictely-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-omited-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-disassocation-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-deintialized-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-overwritting-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-overwriten-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-therfore-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-followings-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-some-typo-words.patch
* lib-vsprintfc-remove-%z-support.patch
* checkpatchpl-warn-against-using-%z.patch
* checkpatchpl-warn-against-using-%z-fix.patch
* kernel-exit-compute-current-directly.patch
* drivers-tty-compute-current-directly.patch
* kernel-locking-compute-current-directly.patch
* sched-remove-set_task_state.patch
* mm-add-new-mmgrab-helper.patch
* mm-add-new-mmget-helper.patch
* mm-use-mmget_not_zero-helper.patch
* mm-clarify-mm_structmm_userscount-documentation.patch
  mm-add-strictlimit-knob-v2.patch
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
