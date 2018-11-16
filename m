Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A41016B0BDD
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 17:53:23 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id o28-v6so17073389pfk.10
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 14:53:23 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 31-v6si33337562plc.140.2018.11.16.14.53.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 14:53:22 -0800 (PST)
Date: Fri, 16 Nov 2018 14:53:17 -0800
From: akpm@linux-foundation.org
Subject: mmotm 2018-11-16-14-52 uploaded
Message-ID: <20181116225317.CcsXrZ5MG%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: broonie@kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org, mhocko@suse.cz, mm-commits@vger.kernel.org, sfr@canb.auug.org.au

The mm-of-the-moment snapshot 2018-11-16-14-52 has been uploaded to

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


This mmotm tree contains the following patches against 4.20-rc2:
(patches marked "*" will be included in linux-next)

  origin.patch
* z3fold-fix-possible-reclaim-races.patch
* psi-simplify-cgroup_move_task.patch
* hugetlbfs-fix-kernel-bug-at-fs-hugetlbfs-inodec-444.patch
* maintainers-update-omap-mmc-entry.patch
* mm-use-kvzalloc-for-swap_info_struct-allocation.patch
* sh-provide-prototypes-for-pci-i-o-mapping-in-asm-ioh.patch
* mm-memory_hotplug-check-zone_movable-in-has_unmovable_pages.patch
* mm-dont-reclaim-inodes-with-many-attached-pages.patch
* scripts-faddr2line-fix-location-of-start_kernel-in-comment.patch
* mm-thp-always-specify-disabled-vmas-as-nh-in-smaps.patch
* ocfs2-free-up-write-context-when-direct-io-failed.patch
* ocfs2-fix-dead-lock-caused-by-ocfs2_defrag_extent.patch
* mm-gup-fix-follow_page_mask-kernel-doc-comment.patch
* mm-fix-numa-statistics-updates.patch
* ubsan-dont-mark-__ubsan_handle_builtin_unreachable-as-noreturn.patch
* mm-fix-a-typo-in-__next_mem_pfn_range-comments.patch
* tmpfs-let-lseek-return-enxio-with-a-negative-offset.patch
* scripts-spdxcheck-make-python3-compliant.patch
* compiler-gcc-hide-compiler_has_generic_builtin_overflow-from-sparse.patch
* kernelh-hide-__is_constexpr-from-sparse.patch
* mm-page_alloc-check-for-max-order-in-hot-path.patch
* mm-cleancache-fix-corruption-on-missed-inode-invalidation.patch
* mm-cleancache-fix-corruption-on-missed-inode-invalidation-fix.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* bloat-o-meter-ignore-__addressable_-symbols.patch
* arch-sh-mach-kfr2r09-fix-struct-mtd_oob_ops-build-warning.patch
* ocfs2-optimize-the-reading-of-heartbeat-data.patch
* ocfs2-dlmfs-remove-set-but-not-used-variable-status.patch
* ocfs2-remove-set-but-not-used-variable-lastzero.patch
* ocfs2-improve-ocfs2-makefile.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
  mm.patch
* mm-slab-remove-unnecessary-unlikely.patch
* mm-slab-remove-unnecessary-unlikely-fix.patch
* mm-slub-remove-validation-on-cpu_slab-in-__flush_cpu_slab.patch
* mm-slub-page-is-always-non-null-for-node_match.patch
* mm-slub-record-final-state-of-slub-action-in-deactivate_slab.patch
* mm-slub-record-final-state-of-slub-action-in-deactivate_slab-fix.patch
* mm-page_owner-clamp-read-count-to-page_size.patch
* mm-page_owner-clamp-read-count-to-page_size-fix.patch
* mm-hotplug-optimize-clear_hwpoisoned_pages.patch
* mm-hotplug-optimize-clear_hwpoisoned_pages-fix.patch
* mm-mmu_notifier-remove-mmu_notifier_synchronize.patch
* mm-use-mm_zero_struct_page-from-sparc-on-all-64b-architectures.patch
* mm-drop-meminit_pfn_in_nid-as-it-is-redundant.patch
* mm-implement-new-zone-specific-memblock-iterator.patch
* mm-initialize-max_order_nr_pages-at-a-time-instead-of-doing-larger-sections.patch
* mm-move-hot-plug-specific-memory-init-into-separate-functions-and-optimize.patch
* mm-add-reserved-flag-setting-to-set_page_links.patch
* mm-use-common-iterator-for-deferred_init_pages-and-deferred_free_pages.patch
* writeback-dont-decrement-wb-refcnt-if-wb-bdi.patch
* mm-simplify-get_next_ra_size.patch
* mm-vmscan-skip-ksm-page-in-direct-reclaim-if-priority-is-low.patch
* mm-ksm-do-not-block-on-page-lock-when-searching-stable-tree.patch
* mm-ksm-do-not-block-on-page-lock-when-searching-stable-tree-fix.patch
* mm-print-more-information-about-mapping-in-__dump_page.patch
* mm-lower-the-printk-loglevel-for-__dump_page-messages.patch
* mm-memory_hotplug-drop-pointless-block-alignment-checks-from-__offline_pages.patch
* mm-memory_hotplug-print-reason-for-the-offlining-failure.patch
* mm-memory_hotplug-print-reason-for-the-offlining-failure-fix.patch
* mm-memory_hotplug-be-more-verbose-for-memory-offline-failures.patch
* mm-memory_hotplug-be-more-verbose-for-memory-offline-failures-fix.patch
* xxhash-create-arch-dependent-32-64-bit-xxhash.patch
* ksm-replace-jhash2-with-xxhash.patch
* mm-treewide-remove-unused-address-argument-from-pte_alloc-functions-v2.patch
* mm-speed-up-mremap-by-20x-on-large-regions-v5.patch
* mm-speed-up-mremap-by-20x-on-large-regions-v5-fix.patch
* mm-select-have_move_pmd-in-x86-for-faster-mremap.patch
* mm-mmap-remove-verify_mm_writelocked.patch
* mm-memory_hotplug-do-not-clear-numa_node-association-after-hot_remove.patch
* mm-add-an-f_seal_future_write-seal-to-memfd.patch
* selftests-memfd-add-tests-for-f_seal_future_write-seal.patch
* mm-remove-reset-of-pcp-counter-in-pageset_init.patch
* ksm-assist-buddy-allocator-to-assemble-1-order-pages.patch
* mm-reference-totalram_pages-and-managed_pages-once-per-function.patch
* mm-convert-zone-managed_pages-to-atomic-variable.patch
* mm-convert-totalram_pages-and-totalhigh_pages-variables-to-atomic.patch
* mm-convert-totalram_pages-and-totalhigh_pages-variables-to-atomic-checkpatch-fixes.patch
* mm-remove-managed_page_count-spinlock.patch
* vmscan-return-node_reclaim_noscan-in-node_reclaim-when-config_numa-is-n.patch
* mm-swap-use-nr_node_ids-for-avail_lists-in-swap_info_struct.patch
* userfaultfd-convert-userfaultfd_ctx-refcount-to-refcount_t.patch
* memory_hotplug-free-pages-as-higher-order.patch
* memory_hotplug-free-pages-as-higher-order-fix.patch
* memory_hotplug-free-pages-as-higher-order-fix-fix.patch
* mm-page_alloc-remove-software-prefetching-in-__free_pages_core.patch
* mm-swap-fix-race-between-swapoff-and-some-swap-operations.patch
* mm-swap-fix-race-between-swapoff-and-some-swap-operations-v6.patch
* mm-fix-race-between-swapoff-and-mincore.patch
* mm-dont-expose-page-to-fast-gup-before-its-ready.patch
* mm-page_owner-align-with-pageblock_nr_pages.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* info-task-hung-in-generic_file_write_iter.patch
* proc-use-ns_capable-instead-of-capable-for-timerslack_ns.patch
* fs-proc-utilc-include-fs-proc-internalh-for-name_to_int.patch
* coding-style-dont-use-extern-with-function-prototypes.patch
* udmabuf-convert-to-use-vm_fault_t.patch
* fls-change-parameter-to-unsigned-int.patch
* lib-genaloc-fix-allocation-of-aligned-buffer-from-non-aligned-chunk.patch
* checkpatch-warn-on-const-char-foo-=-bar-declarations.patch
* fs-epoll-remove-max_nests-argument-from-ep_call_nested.patch
* fs-epoll-simplify-ep_send_events_proc-ready-list-loop.patch
* fs-epoll-drop-ovflist-branch-prediction.patch
* fs-epoll-robustify-ep-mtx-held-checks.patch
* fs-epoll-reduce-the-scope-of-wq-lock-in-epoll_wait.patch
* fs-epoll-reduce-the-scope-of-wq-lock-in-epoll_wait-fix.patch
* fs-epoll-avoid-barrier-after-an-epoll_wait2-timeout.patch
* fs-epoll-avoid-barrier-after-an-epoll_wait2-timeout-fix.patch
* fs-epoll-rename-check_events-label-to-send_events.patch
* fs-epoll-deal-with-wait_queue-only-once.patch
* fs-epoll-deal-with-wait_queue-only-once-fix.patch
* hfsplus-return-file-attributes-on-statx.patch
* fork-fix-some-wmissing-prototypes-warnings.patch
* exec-load_script-dont-blindly-truncate-shebang-string.patch
* exec-increase-binprm_buf_size-to-256.patch
* exec-separate-mm_anonpages-and-rlimit_stack-accounting.patch
* exec-separate-mm_anonpages-and-rlimit_stack-accounting-checkpatch-fixes.patch
* bfs-extra-sanity-checking-and-static-inode-bitmap.patch
* initramfs-cleanup-incomplete-rootfs.patch
* ipc-allow-boot-time-extension-of-ipcmni-from-32k-to-8m.patch
* ipc-allow-boot-time-extension-of-ipcmni-from-32k-to-8m-checkpatch-fixes.patch
* ipc-conserve-sequence-numbers-in-extended-ipcmni-mode.patch
  linux-next.patch
  linux-next-git-rejects.patch
* scripts-atomic-check-atomicssh-dont-assume-that-scripts-are-executable.patch
* drivers-net-ethernet-qlogic-qed-qed_rdmah-fix-typo.patch
* mm-introduce-common-struct_page_max_shift-define.patch
* mm-sparse-add-common-helper-to-mark-all-memblocks-present.patch
* vfs-replace-current_kernel_time64-with-ktime-equivalent.patch
* fix-read-buffer-overflow-in-delta-ipc.patch
  make-sure-nobodys-leaking-resources.patch
  releasing-resources-with-children.patch
  mutex-subsystem-synchro-test-module.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  slab-leaks3-default-y.patch
  workaround-for-a-pci-restoring-bug.patch
