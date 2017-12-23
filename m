Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 012AA6B0271
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 20:56:00 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id g26so6945332wrb.8
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 17:55:59 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h130si7058807wme.230.2017.12.22.17.55.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Dec 2017 17:55:58 -0800 (PST)
Date: Fri, 22 Dec 2017 17:55:54 -0800
From: akpm@linux-foundation.org
Subject: mmotm 2017-12-22-17-55 uploaded
Message-ID: <20171223015554.hUf4THsJR%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: broonie@kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org, mhocko@suse.cz, mm-commits@vger.kernel.org, sfr@canb.auug.org.au

The mm-of-the-moment snapshot 2017-12-22-17-55 has been uploaded to

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


This mmotm tree contains the following patches against 4.15-rc4:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
* scripts-decodecode-fix-decoding-for-aarch64-arm64-instructions.patch
* mm-skip-hwpoisoned-pages-when-onlining-pages.patch
* ubsan-dont-handle-misaligned-address-when-support-unaligned-access.patch
* ubsan-dont-handle-misaligned-address-when-support-unaligned-access-v2.patch
* mm-check-pfn_valid-first-in-zero_resv_unavail.patch
* acct-fix-the-acct-needcheck-check-in-check_free_space.patch
* mm-mprotect-add-a-cond_resched-inside-change_pmd_range.patch
* kernel-exitc-export-abort-to-modules.patch
* provide-useful-debugging-information-for-vm_bug.patch
* zsmalloc-add-fsh-include.patch
* mm-sparsec-wrong-allocation-for-mem_section.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* prctl-add-pr_et_pdeathsig_proc.patch
* scripts-decodecode-make-it-take-multiline-code-line.patch
* scripts-tags-change-find_other_sources-for-include-folders.patch
* ntfs-remove-i_version-handling.patch
* ocfs2-dlm-clean-dead-code-up.patch
* ocfs2-cluster-neaten-a-member-of-o2net_msg_handler.patch
* ocfs2-give-an-obvious-tip-for-dismatch-cluster-names.patch
* ocfs2-cluster-close-a-race-that-fence-cant-be-triggered.patch
* ocfs2-using-the-ocfs2_xattr_root_size-macro-in-ocfs2_reflink_xattr_header.patch
* ocfs2-clean-dead-code-in-suballocc.patch
* ocfs2-get-rid-of-ocfs2_is_o2cb_active-function.patch
* ocfs2-move-some-definitions-to-header-file.patch
* ocfs2-fix-some-small-problems.patch
* ocfs2-add-kobject-for-online-file-check.patch
* ocfs2-add-duplicative-ino-number-check.patch
* ocfs2-add-ocfs2_try_rw_lock-and-ocfs2_try_inode_lock.patch
* ocfs2-add-ocfs2_overwrite_io-function.patch
* ocfs2-nowait-aio-support.patch
* ocfs2-add-trimfs-dlm-lock-resource.patch
* ocfs2-add-trimfs-lock-to-avoid-duplicated-trims-in-cluster.patch
* ocfs2-dont-merge-rightmost-extent-block-if-it-was-locked.patch
* ocfs2-fall-back-to-buffer-io-when-append-dio-is-disabled-with-file-hole-existing.patch
* ocfs2-fall-back-to-buffer-io-when-append-dio-is-disabled-with-file-hole-existing-fix.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* dentry-fix-kmemcheck-splat-at-take_dentry_name_snapshot.patch
  mm.patch
* mm-terminate-shrink_slab-loop-if-signal-is-pending.patch
* mm-terminate-shrink_slab-loop-if-signal-is-pending-fix.patch
* mm-slab-make-calculate_alignment-function-static.patch
* mm-slab-remove-redundant-assignments-for-slab_state.patch
* include-linux-sched-mmh-uninline-mmdrop_async-etc.patch
* mm-kmemleak-remove-unused-hardirqh.patch
* zswap-same-filled-pages-handling.patch
* zswap-same-filled-pages-handling-v2.patch
* mm-relax-deferred-struct-page-requirements.patch
* mm-mempolicy-remove-redundant-check-in-get_nodes.patch
* mm-mempolicy-fix-the-check-of-nodemask-from-user.patch
* mm-mempolicy-add-nodes_empty-check-in-sysc_migrate_pages.patch
* mm-drop-hotplug-lock-from-lru_add_drain_all.patch
* mm-show-total-hugetlb-memory-consumption-in-proc-meminfo.patch
* mm-use-sc-priority-for-slab-shrink-targets.patch
* mm-mlock-vmscan-no-more-skipping-pagevecs.patch
* mmvmscan-mark-register_shrinker-as-__must_check.patch
* mm-split-deferred_init_range-into-initializing-and-freeing-parts.patch
* mm-split-deferred_init_range-into-initializing-and-freeing-parts-fix.patch
* mm-filemap-remove-include-of-hardirqh.patch
* mm-memcontrol-eliminate-raw-access-to-stat-and-event-counters.patch
* mm-memcontrol-implement-lruvec-stat-functions-on-top-of-each-other.patch
* mm-memcontrol-fix-excessive-complexity-in-memorystat-reporting.patch
* mm-memcontrol-fix-excessive-complexity-in-memorystat-reporting-fix.patch
* mm-swap-clean-up-swap-readahead.patch
* mm-swap-unify-cluster-based-and-vma-based-swap-readahead.patch
* mm-page_owner-use-ptr_err_or_zero.patch
* mm-page_alloc-fix-comment-is-__get_free_pages.patch
* mm-do-not-stall-register_shrinker.patch
* mm-do-not-stall-register_shrinker-fix.patch
* selftest-vm-move-128tb-mmap-boundary-test-to-generic-directory.patch
* selftest-vm-move-128tb-mmap-boundary-test-to-generic-directory-fix.patch
* mm-use-vma_pages-helper.patch
* mm-remove-unused-pgdat_reclaimable_pages.patch
* list_lru-prefetch-neighboring-list-entries-before-acquiring-lock.patch
* list_lru-prefetch-neighboring-list-entries-before-acquiring-lock-fix.patch
* mm-oom-refactor-the-oom_kill_process-function.patch
* mm-implement-mem_cgroup_scan_tasks-for-the-root-memory-cgroup.patch
* mm-oom-cgroup-aware-oom-killer.patch
* mm-oom-cgroup-aware-oom-killer-fix.patch
* mm-oom-introduce-memoryoom_group.patch
* mm-oom-introduce-memoryoom_group-fix.patch
* mm-oom-add-cgroup-v2-mount-option-for-cgroup-aware-oom-killer.patch
* mm-oom-docs-describe-the-cgroup-aware-oom-killer.patch
* mm-oom-docs-describe-the-cgroup-aware-oom-killer-fix.patch
* cgroup-list-groupoom-in-cgroup-features.patch
* mm-hugetlb-drop-hugepages_treat_as_movable-sysctl.patch
* mm-memory_hotplug-remove-unnecesary-check-from-register_page_bootmem_info_section.patch
* mm-update-comment-describing-tlb_gather_mmu.patch
* mm-readahead-increase-maximum-readahead-window.patch
* proc-do-not-show-vmexe-bigger-than-total-executable-virtual-memory.patch
* mm-add-strictlimit-knob-v2.patch
* mm-memory_hotplug-remove-second-__nr_to_section-in-register_page_bootmem_info_section.patch
* mm-huge_memory-fix-comment-in-__split_huge_pmd_locked.patch
* mm-userfaultfd-thp-avoid-waiting-when-pmd-under-thp-migration.patch
* mm-page_alloc-dont-reserve-zone_highmem-for-zone_movable-request.patch
* mm-cma-manage-the-memory-of-the-cma-area-by-using-the-zone_movable.patch
* mm-cma-remove-alloc_cma.patch
* arm-cma-avoid-double-mapping-to-the-cma-area-if-config_highmem-=-y.patch
* mm-add-unmap_mapping_pages.patch
* get-7%-more-pages-in-a-pagevec.patch
* asm-generic-provide-generic_pmdp_establish.patch
* arc-use-generic_pmdp_establish-as-pmdp_establish.patch
* arm-mm-provide-pmdp_establish-helper.patch
* arm64-provide-pmdp_establish-helper.patch
* mips-use-generic_pmdp_establish-as-pmdp_establish.patch
* powerpc-mm-update-pmdp_invalidate-to-return-old-pmd-value.patch
* s390-mm-modify-pmdp_invalidate-to-return-old-value.patch
* sparc64-update-pmdp_invalidate-to-return-old-pmd-value.patch
* sparc64-update-pmdp_invalidate-to-return-old-pmd-value-fix.patch
* x86-mm-provide-pmdp_establish-helper.patch
* x86-mm-provide-pmdp_establish-helper-fix.patch
* mm-do-not-lose-dirty-and-access-bits-in-pmdp_invalidate.patch
* mm-use-updated-pmdp_invalidate-interface-to-track-dirty-accessed-bits.patch
* mm-thp-remove-pmd_huge_split_prepare.patch
* mm-introduce-map_fixed_safe.patch
* mm-introduce-map_fixed_safe-fix.patch
* fs-elf-drop-map_fixed-usage-from-elf_map.patch
* fs-elf-drop-map_fixed-usage-from-elf_map-fix.patch
* fs-elf-drop-map_fixed-usage-from-elf_map-checkpatch-fixes.patch
* mm-thp-use-down_read_trylock-in-khugepaged-to-avoid-long-block.patch
* mm-thp-use-down_read_trylock-in-khugepaged-to-avoid-long-block-fix.patch
* mm-thp-use-down_read_trylock-in-khugepaged-to-avoid-long-block-fix-2.patch
* mm-thp-use-down_read_trylock-in-khugepaged-to-avoid-long-block-fix-checkpatch-fixes.patch
* mm-mmu_notifier-annotate-mmu-notifiers-with-blockable-invalidate-callbacks.patch
* mm-mmu_notifier-annotate-mmu-notifiers-with-blockable-invalidate-callbacks-fix.patch
* mm-oom-avoid-reaping-only-for-mms-with-blockable-invalidate-callbacks.patch
* mm-zsmalloc-simplify-shrinker-init-destroy.patch
* mm-zsmalloc-simplify-shrinker-init-destroy-fix.patch
* mm-vmalloc-replace-opencoded-4-level-page-walkers.patch
* mm-align-struct-page-more-aesthetically.patch
* mm-de-indent-struct-page.patch
* mm-remove-misleading-alignment-claims.patch
* mm-improve-comment-on-page-mapping.patch
* mm-introduce-_slub_counter_t.patch
* mm-store-compound_dtor-compound_order-as-bytes.patch
* mm-store-compound_dtor-compound_order-as-bytes-fix.patch
* mm-document-how-to-use-struct-page.patch
* mm-remove-reference-to-pg_buddy.patch
* shmem-unexport-shmem_add_seals-shmem_get_seals.patch
* shmem-rename-functions-that-are-memfd-related.patch
* hugetlb-expose-hugetlbfs_inode_info-in-header.patch
* hugetlb-implement-memfd-sealing.patch
* shmem-add-sealing-support-to-hugetlb-backed-memfd.patch
* memfd-test-test-hugetlbfs-sealing.patch
* memfd-test-add-memfd-hugetlb-prefix-when-testing-hugetlbfs.patch
* memfd-test-move-common-code-to-a-shared-unit.patch
* memfd-test-run-fuse-test-on-hugetlb-backend-memory.patch
* mm-page_owner-align-with-pageblock_nr_pages.patch
* mm-make-count-list_lru_one-nr_items-lockless.patch
* mm-make-count-list_lru_one-nr_items-lockless-v2.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* kasan-add-compiler-support-for-clang.patch
* kasan-makefile-support-llvm-style-asan-parameters.patch
* kasan-support-alloca-poisoning.patch
* kasan-add-tests-for-alloca-poisoning.patch
* kasan-added-functions-for-unpoisoning-stack-variables.patch
* proc-use-%u-for-pid-printing-and-slightly-less-stack.patch
* proc-dont-use-read_once-write_once-for-proc-fail-nth.patch
* proc-fix-proc-map_files-lookup.patch
* proc-simpler-proc-vmcore-cleanup.patch
* proc-less-memory-for-proc-map_files-readdir.patch
* proc-delete-children_seq_release.patch
* fs-proc-kcorec-use-probe_kernel_read-instead-of-memcpy.patch
* proc-rearrange-struct-proc_dir_entry.patch
* makefile-move-stack-protector-compiler-breakage-test-earlier.patch
* makefile-move-stack-protector-availability-out-of-kconfig.patch
* makefile-introduce-config_cc_stackprotector_auto.patch
* bugh-work-around-gcc-pr82365-in-bug.patch
* revert-async-simplify-lowest_in_progress.patch
* lib-stackdepot-use-a-non-instrumented-version-of-memcmp.patch
* lib-test_find_bitc-rename-to-find_bit_benchmarkc.patch
* lib-find_bit_benchmarkc-improvements.patch
* lib-optimize-cpumask_next_and.patch
* lib-optimize-cpumask_next_and-v6.patch
* lib-optimize-cpumask_next_and-v6-fix.patch
* make-runtime_tests-a-menuconfig-to-ease-disabling-it-all.patch
* lib-add-module-unload-support-to-sort-tests.patch
* checkpatch-allow-long-lines-containing-url.patch
* checkpatch-ignore-some-octal-permissions-of-0.patch
* checkpatch-improve-quoted-string-and-line-continuation-test.patch
* checkpatch-add-a-few-device_attr-style-tests.patch
* checkpatch-improve-the-tabstop-test-to-include-declarations.patch
* hfsplus-honor-setgid-flag-on-directories.patch
* seq_file-delete-small-value-optimization.patch
* forkc-check-error-and-return-early.patch
* forkc-add-doc-about-usage-of-clone_fs-flags-and-namespaces.patch
* cpumask-make-cpumask_size-return-unsigned-int.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* rapidio-delete-an-error-message-for-a-failed-memory-allocation-in-rio_init_mports.patch
* rapidio-adjust-12-checks-for-null-pointers.patch
* rapidio-adjust-five-function-calls-together-with-a-variable-assignment.patch
* rapidio-improve-a-size-determination-in-five-functions.patch
* rapidio-delete-an-unnecessary-variable-initialisation-in-three-functions.patch
* rapidio-return-an-error-code-only-as-a-constant-in-two-functions.patch
* rapidio-move-12-export_symbol_gpl-calls-to-function-implementations.patch
* rapidio-tsi721_dma-delete-an-error-message-for-a-failed-memory-allocation-in-tsi721_alloc_chan_resources.patch
* rapidio-tsi721_dma-delete-an-unnecessary-variable-initialisation-in-tsi721_alloc_chan_resources.patch
* rapidio-tsi721_dma-adjust-six-checks-for-null-pointers.patch
* uapi-fix-linux-sysctlh-userspace-compilation-errors.patch
* pids-introduce-find_get_task_by_vpid-helper.patch
* lib-ubsanc-s-missaligned-misaligned.patch
* ipc-fix-ipc-data-structures-inconsistency.patch
* ipc-mqueue-wq_add-priority-changed-to-dynamic-priority.patch
* lustre-dont-set-f_version-in-ll_readdir.patch
  linux-next.patch
  linux-next-rejects.patch
  linux-next-git-rejects.patch
* tools-objtool-makefile-dont-assume-sync-checksh-is-executable.patch
* vfs-remove-might_sleep-from-clear_inode.patch
* mm-remove-duplicate-includes.patch
* ipc-mqueue-lazy-call-kern_mount_data-in-new-namespaces.patch
* mm-remove-unneeded-kallsyms-include.patch
* hrtimer-remove-unneeded-kallsyms-include.patch
* genirq-remove-unneeded-kallsyms-include.patch
* mm-memblock-memblock_is_map-region_memory-can-be-boolean.patch
* lib-lockref-__lockref_is_dead-can-be-boolean.patch
* kernel-cpuset-current_cpuset_is_being_rebound-can-be-boolean.patch
* kernel-resource-iomem_is_exclusive-can-be-boolean.patch
* kernel-module-module_is_live-can-be-boolean.patch
* kernel-mutex-mutex_is_locked-can-be-boolean.patch
* crash_dump-is_kdump_kernel-can-be-boolean.patch
* fix-const-confusion-in-certs-blacklist.patch
* fix-read-buffer-overflow-in-delta-ipc.patch
* fix-const-confusion-in-intel-mid-x86-platform-drivers.patch
* kasan-rework-kconfig-settings.patch
* sparc64-ng4-memset-32-bits-overflow.patch
* lib-crc-ccitt-add-ccitt-false-crc16-variant.patch
  make-sure-nobodys-leaking-resources.patch
  releasing-resources-with-children.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  mutex-subsystem-synchro-test-module.patch
  slab-leaks3-default-y.patch
  workaround-for-a-pci-restoring-bug.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
