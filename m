Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 020FD6B0273
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 19:02:10 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 96so6722259wrk.7
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 16:02:09 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y66si1831382wmb.45.2017.12.08.16.02.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Dec 2017 16:02:07 -0800 (PST)
Date: Fri, 08 Dec 2017 16:02:04 -0800
From: akpm@linux-foundation.org
Subject: mmotm 2017-12-08-16-01 uploaded
Message-ID: <5a2b27fc.7kYTGVFOh2kyNcnC%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2017-12-08-16-01 has been uploaded to

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


This mmotm tree contains the following patches against 4.15-rc2:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
* idr-add-include-linux-bugh.patch
* frv-fix-build-failure.patch
* scripts-decodecode-fix-decoding-for-aarch64-arm64-instructions.patch
* mm-skip-hwpoisoned-pages-when-onlining-pages.patch
* lib-rbtreedrm-mm-add-rbtree_replace_node_cached.patch
* mm-kmemleakc-make-cond_resched-rate-limiting-more-efficient.patch
* stringh-work-around-for-increased-stack-usage.patch
* stringh-work-around-for-increased-stack-usage-fix.patch
* autofs-fix-careless-error-in-recent-commit.patch
* exec-avoid-gcc-8-warning-for-get_task_comm.patch
* zswap-update-with-same-value-filled-page-feature.patch
* kmemcheck-rip-it-out-for-real.patch
* scripts-faddr2line-fix-cross_compile-unset-error.patch
* mm-memoryc-mark-wp_huge_pmd-inline-to-prevent-build-failure.patch
* mm-memoryc-mark-wp_huge_pmd-inline-to-prevent-build-failure-fix.patch
* ubsan-dont-handle-misaligned-address-when-support-unaligned-access.patch
* ubsan-dont-handle-misaligned-address-when-support-unaligned-access-v2.patch
* mm-check-pfn_valid-first-in-zero_resv_unavail.patch
* mm-page_alloc-avoid-excessive-irq-disabled-times-in-free_unref_page_list.patch
* mm-slab-do-not-hash-pointers-when-debugging-slab.patch
* kcov-fix-comparison-callback-signature.patch
* tools-slabinfo-gnuplot-force-to-use-bash-shell.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* prctl-add-pr_et_pdeathsig_proc.patch
* ntfs-remove-i_version-handling.patch
* ocfs2-dlm-clean-dead-code-up.patch
* ocfs2-cluster-neaten-a-member-of-o2net_msg_handler.patch
* ocfs2-check-the-metadate-alloc-before-marking-extent-written.patch
* ocfs2-give-an-obvious-tip-for-dismatch-cluster-names.patch
* ocfs2-cluster-close-a-race-that-fence-cant-be-triggered.patch
* ocfs2-get-rid-of-ocfs2_is_o2cb_active-function.patch
* ocfs2-move-some-definitions-to-header-file.patch
* ocfs2-fix-some-small-problems.patch
* ocfs2-add-kobject-for-online-file-check.patch
* ocfs2-add-duplicative-ino-number-check.patch
* ocfs2-add-ocfs2_try_rw_lock-and-ocfs2_try_inode_lock.patch
* ocfs2-add-ocfs2_overwrite_io-function.patch
* ocfs2-nowait-aio-support.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* dentry-fix-kmemcheck-splat-at-take_dentry_name_snapshot.patch
  mm.patch
* mm-terminate-shrink_slab-loop-if-signal-is-pending.patch
* mm-terminate-shrink_slab-loop-if-signal-is-pending-fix.patch
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
* mm-hugetlbfs-introduce-pagesize-to-vm_operations_struct.patch
* device-dax-implement-pagesize-for-smaps-to-report-mmupagesize.patch
* mm-page_alloc-dont-reserve-zone_highmem-for-zone_movable-request.patch
* mm-cma-manage-the-memory-of-the-cma-area-by-using-the-zone_movable.patch
* mm-cma-remove-alloc_cma.patch
* arm-cma-avoid-double-mapping-to-the-cma-area-if-config_highmem-=-y.patch
* mm-page_owner-align-with-pageblock_nr_pages.patch
* mm-make-count-list_lru_one-nr_items-lockless.patch
* mm-make-count-list_lru_one-nr_items-lockless-v2.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* proc-use-%u-for-pid-printing-and-slightly-less-stack.patch
* proc-dont-use-read_once-write_once-for-proc-fail-nth.patch
* proc-fix-proc-map_files-lookup.patch
* proc-simpler-proc-vmcore-cleanup.patch
* proc-less-memory-for-proc-map_files-readdir.patch
* proc-delete-children_seq_release.patch
* fs-proc-kcorec-use-probe_kernel_read-instead-of-memcpy.patch
* makefile-move-stack-protector-compiler-breakage-test-earlier.patch
* makefile-move-stack-protector-availability-out-of-kconfig.patch
* makefile-introduce-config_cc_stackprotector_auto.patch
* kconfig-make-strict_devmem-default-y-on-x86-and-arm64.patch
* revert-async-simplify-lowest_in_progress.patch
* lib-stackdepot-use-a-non-instrumented-version-of-memcmp.patch
* lib-test_find_bitc-rename-to-find_bit_benchmarkc.patch
* lib-find_bit_benchmarkc-improvements.patch
* m68k-bitops-always-include-asm-generic-bitops-findh.patch
* lib-optimize-cpumask_next_and.patch
* lib-optimize-cpumask_next_and-v6.patch
* checkpatch-allow-long-lines-containing-url.patch
* hfsplus-honor-setgid-flag-on-directories.patch
* hpfs-dont-bother-with-the-i_version-counter-or-f_version.patch
* seq_file-delete-small-value-optimization.patch
* forkc-check-error-and-return-early.patch
* forkc-add-doc-about-usage-of-clone_fs-flags-and-namespaces.patch
* cpumask-make-cpumask_size-return-unsigned-int.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* uapi-fix-linux-sysctlh-userspace-compilation-errors.patch
* pids-introduce-find_get_task_by_vpid-helper.patch
* lib-ubsanc-s-missaligned-misaligned.patch
* ipc-fix-ipc-data-structures-inconsistency.patch
* lustre-dont-set-f_version-in-ll_readdir.patch
  linux-next.patch
  linux-next-rejects.patch
* tools-objtool-makefile-dont-assume-sync-checksh-is-executable.patch
* vfs-remove-might_sleep-from-clear_inode.patch
* mm-remove-duplicate-includes.patch
* ipc-mqueue-lazy-call-kern_mount_data-in-new-namespaces.patch
* epoll-use-the-waitqueue-lock-to-protect-ep-wq.patch
* sched-wait-assert-the-wait_queue_head-lock-is-held-in-__wake_up_common.patch
* sched-autogroup-remove-unneeded-kallsyms-include.patch
* mm-remove-unneeded-kallsyms-include.patch
* power-remove-unneeded-kallsyms-include.patch
* pci-remove-unneeded-kallsyms-include.patch
* pnp-remove-unneeded-kallsyms-include.patch
* workqueue-remove-unneeded-kallsyms-include.patch
* hrtimer-remove-unneeded-kallsyms-include.patch
* genirq-remove-unneeded-kallsyms-include.patch
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
