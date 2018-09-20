Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 89A748E0001
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 15:10:51 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 43-v6so11261ple.19
        for <linux-mm@kvack.org>; Thu, 20 Sep 2018 12:10:51 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c31-v6si5346429pgb.348.2018.09.20.12.10.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Sep 2018 12:10:49 -0700 (PDT)
Date: Thu, 20 Sep 2018 12:10:47 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2018-09-20-12-10 uploaded
Message-ID: <20180920191047.N7-CCe4vS%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: broonie@kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org, mhocko@suse.cz, mm-commits@vger.kernel.org, sfr@canb.auug.org.au

The mm-of-the-moment snapshot 2018-09-20-12-10 has been uploaded to

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


This mmotm tree contains the following patches against 4.19-rc4:
(patches marked "*" will be included in linux-next)

  origin.patch
* fork-report-pid-exhaustion-correctly.patch
* mm-disable-deferred-struct-page-for-32-bit-arches.patch
* proc-kcore-fix-invalid-memory-access-in-multi-page-read-optimization-v3.patch
* mm-shmem-correctly-annotate-new-inodes-for-lockdep.patch
* kernel-remove-duplicated-include-from-sysc.patch
* mm-slowly-shrink-slabs-with-a-relatively-small-number-of-objects.patch
* ocfs2-fix-ocfs2-read-block-panic.patch
* mm-migration-fix-migration-of-huge-pmd-shared-pages.patch
* mm-migration-fix-migration-of-huge-pmd-shared-pages-v7.patch
* hugetlb-take-pmd-sharing-into-account-when-flushing-tlb-caches.patch
* fix-crash-on-ocfs2_duplicate_clusters_by_page.patch
* fix-crash-on-ocfs2_duplicate_clusters_by_page-v5.patch
* fix-crash-on-ocfs2_duplicate_clusters_by_page-v5-checkpatch-fixes.patch
* mm-thp-fix-mlocking-thp-page-with-migration-enabled.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* linkageh-align-weak-symbols.patch
* arm64-lib-use-c-string-functions-with-kasan-enabled.patch
* lib-test_kasan-add-tests-for-several-string-memory-api-functions.patch
* scripts-tags-add-declare_hashtable.patch
* ocfs2-fix-a-gcc-compiled-warning.patch
* ocfs2-get-rid-of-ocfs2_is_o2cb_active-function.patch
* ocfs2-without-quota-support-try-to-avoid-calling-quota-recovery.patch
* ocfs2-dont-use-iocb-when-eiocbqueued-returns.patch
* ocfs2-fix-a-misuse-a-of-brelse-after-failing-ocfs2_check_dir_entry.patch
* ocfs2-dont-put-and-assigning-null-to-bh-allocated-outside.patch
* ocfs2-dlmglue-clean-up-timestamp-handling.patch
* fix-dead-lock-caused-by-ocfs2_defrag_extent.patch
* ocfs2-fix-dead-lock-caused-by-ocfs2_defrag_extent.patch
* fix-clusters-leak-in-ocfs2_defrag_extent.patch
* fix-clusters-leak-in-ocfs2_defrag_extent-fix.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* vfs-allow-dedupe-of-user-owned-read-only-files.patch
* vfs-dedupe-should-return-eperm-if-permission-is-not-granted.patch
* fs-iomap-change-return-type-to-vm_fault_t.patch
* xtensa-use-generic-vgah.patch
  mm.patch
* mm-slubc-switch-to-bitmap_zalloc.patch
* mm-rework-memcg-kernel-stack-accounting.patch
* mm-drain-memcg-stocks-on-css-offlining.patch
* mm-dont-miss-the-last-page-because-of-round-off-error.patch
* mm-dont-miss-the-last-page-because-of-round-off-error-fix.patch
* mmpage_alloc-pf_wq_worker-threads-must-sleep-at-should_reclaim_retry.patch
* mmpage_alloc-pf_wq_worker-threads-must-sleep-at-should_reclaim_retry-fix.patch
* mm-mmu_notifier-be-explicit-about-range-invalition-non-blocking-mode.patch
* revert-mm-mmu_notifier-annotate-mmu-notifiers-with-blockable-invalidate-callbacks.patch
* kmemleak-add-module-param-to-print-warnings-to-dmesg.patch
* swap-use-__try_to_reclaim_swap-in-free_swap_and_cache.patch
* swap-call-free_swap_slot-in-__swap_entry_free.patch
* swap-clear-si-swap_map-in-swap_free_cluster.patch
* mm-page_alloc-clean-up-check_for_memory.patch
* mm-conveted-to-use-vm_fault_t.patch
* cramfs-convert-to-use-vmf_insert_mixed-v2.patch
* mm-remove-vm_insert_mixed.patch
* mm-introduce-vmf_insert_pfn_prot.patch
* x86-convert-vdso-to-use-vm_fault_t.patch
* mm-make-vm_insert_pfn_prot-static.patch
* mm-remove-references-to-vm_insert_pfn.patch
* mm-remove-vm_insert_pfn.patch
* mm-inline-vm_insert_pfn_prot-into-caller.patch
* mm-convert-__vm_insert_mixed-to-vm_fault_t.patch
* mm-convert-insert_pfn-to-vm_fault_t.patch
* hexagon-switch-to-no_bootmem.patch
* of-ignore-sub-page-memory-regions.patch
* nios2-use-generic-early_init_dt_add_memory_arch.patch
* nios2-switch-to-no_bootmem.patch
* um-setup_physmem-stop-using-global-variables.patch
* um-switch-to-no_bootmem.patch
* unicore32-switch-to-no_bootmem.patch
* alpha-switch-to-no_bootmem.patch
* userfaultfd-allow-get_mempolicympol_f_nodempol_f_addr-to-trigger-userfaults.patch
* arm-arm64-introduce-config_have_memblock_pfn_valid.patch
* mm-page_alloc-remain-memblock_next_valid_pfn-on-arm-arm64.patch
* mm-page_alloc-reduce-unnecessary-binary-search-in-memblock_next_valid_pfn.patch
* mm-slab-combine-kmalloc_caches-and-kmalloc_dma_caches.patch
* mm-slab-slub-introduce-kmalloc-reclaimable-caches.patch
* dcache-allocate-external-names-from-reclaimable-kmalloc-caches.patch
* mm-rename-and-change-semantics-of-nr_indirectly_reclaimable_bytes.patch
* mm-proc-add-kreclaimable-to-proc-meminfo.patch
* mm-slab-shorten-kmalloc-cache-names-for-large-sizes.patch
* mm-workingset-dont-drop-refault-information-prematurely.patch
* mm-workingset-tell-cache-transitions-from-workingset-thrashing.patch
* delayacct-track-delays-from-thrashing-cache-pages.patch
* sched-loadavg-consolidate-load_int-load_frac-calc_load.patch
* sched-loadavg-consolidate-load_int-load_frac-calc_load-fix.patch
* sched-loadavg-consolidate-load_int-load_frac-calc_load-fix-fix.patch
* sched-loadavg-make-calc_load_n-public.patch
* sched-schedh-make-rq-locking-and-clock-functions-available-in-statsh.patch
* sched-introduce-this_rq_lock_irq.patch
* psi-pressure-stall-information-for-cpu-memory-and-io.patch
* psi-pressure-stall-information-for-cpu-memory-and-io-fix.patch
* psi-pressure-stall-information-for-cpu-memory-and-io-fix-2.patch
* psi-pressure-stall-information-for-cpu-memory-and-io-fix-3.patch
* psi-pressure-stall-information-for-cpu-memory-and-io-fix-4.patch
* psi-cgroup-support.patch
* mm-page_alloc-drop-should_suppress_show_mem.patch
* mm-swap-remove-duplicated-include-from-swapc.patch
* mm-use-match_string-helper-to-simplify-the-code.patch
* kvfree-fix-misleading-comment.patch
* mm-vmalloc-improve-vfree-kerneldoc.patch
* vfree-kvfree-add-debug-might-sleeps.patch
* vfree-kvfree-add-debug-might-sleeps-fix.patch
* mm-mmap-zap-pages-with-read-mmap_sem-in-munmap.patch
* mm-unmap-vm_hugetlb-mappings-with-optimized-path.patch
* mm-unmap-vm_pfnmap-mappings-with-optimized-path.patch
* mm-filemapc-use-existing-variable.patch
* mm-memory_hotplug-spare-unnecessary-calls-to-node_set_state.patch
* mm-memory_hotplug-avoid-node_set-clear_staten_high_memory-when-config_highmem.patch
* mm-memory_hotplug-tidy-up-node_states_clear_node.patch
* mm-memory_hotplug-simplify-node_states_check_changes_online.patch
* mm-memory_hotplug-clean-up-node_states_check_changes_offline.patch
* memcg-remove-memcg_kmem_skip_account.patch
* z3fold-fix-wrong-handling-of-headless-pages.patch
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
* fs-proc-vmcorec-convert-to-use-vmf_error.patch
* include-linux-compilerh-add-version-detection-to-asm_volatile_goto.patch
* treewide-remove-current_text_addr.patch
* lib-bitmapc-remove-wrong-documentation.patch
* linux-bitmaph-handle-constant-zero-size-bitmaps-correctly.patch
* linux-bitmaph-remove-redundant-uses-of-small_const_nbits.patch
* linux-bitmaph-fix-type-of-nbits-in-bitmap_shift_right.patch
* linux-bitmaph-relax-comment-on-compile-time-constant-nbits.patch
* lib-bitmapc-fix-remaining-space-computation-in-bitmap_print_to_pagebuf.patch
* lib-bitmapc-fix-remaining-space-computation-in-bitmap_print_to_pagebuf-fix.patch
* lib-bitmapc-fix-remaining-space-computation-in-bitmap_print_to_pagebuf-fix-fix.patch
* lib-bitmapc-simplify-bitmap_print_to_pagebuf.patch
* lib-parserc-switch-match_strdup-over-to-use-kmemdup_nul.patch
* lib-parserc-switch-match_u64int-over-to-use-match_strdup.patch
* lib-parserc-switch-match_number-over-to-use-match_strdup.patch
* zlib-remove-fall-through-warnings.patch
* radix-tree-use-div_round_up-instead-of-reimplementing-its-function.patch
* lib-sg_pool-remove-unnecessary-null-check-when-free-the-object.patch
* checkpatch-remove-gcc_binary_constant-warning.patch
* init-do_mountsc-add-root=partlabel=name-support.patch
* hfsplus-prevent-btree-data-loss-on-root-split.patch
* hfsplus-fix-bug-on-bnode-parent-update.patch
* hfs-prevent-btree-data-loss-on-root-split.patch
* hfs-fix-bug-on-bnode-parent-update.patch
* hfsplus-prevent-btree-data-loss-on-enospc.patch
* hfs-prevent-btree-data-loss-on-enospc.patch
* reiserfs-propagate-errors-from-fill_with_dentries-properly.patch
* bfs-add-sanity-check-at-bfs_fill_super.patch
* ipc-ipcmni-limit-check-for-msgmni-and-shmmni.patch
* ipc-ipcmni-limit-check-for-semmni.patch
* ipc-allow-boot-time-extension-of-ipcmni-from-32k-to-8m.patch
* ipc-allow-boot-time-extension-of-ipcmni-from-32k-to-8m-checkpatch-fixes.patch
* ipc-conserve-sequence-numbers-in-extended-ipcmni-mode.patch
* ipc-shm-use-err_cast-for-shm_lock-error-return.patch
* lib-lz4-update-lz4-decompressor-module.patch
  linux-next.patch
  linux-next-rejects.patch
  linux-next-git-rejects.patch
* percpu-cleanup-per_cpu_def_attributes-macro.patch
* mm-remove-config_no_bootmem.patch
* mm-remove-config_have_memblock.patch
* mm-remove-config_have_memblock-fix.patch
* mm-remove-bootmem-allocator-implementation.patch
* mm-nobootmem-remove-dead-code.patch
* memblock-rename-memblock_alloc_nid_try_nid-to-memblock_phys_alloc.patch
* memblock-remove-_virt-from-apis-returning-virtual-address.patch
* memblock-replace-alloc_bootmem_align-with-memblock_alloc.patch
* memblock-replace-alloc_bootmem_low-with-memblock_alloc_low.patch
* memblock-replace-__alloc_bootmem_node_nopanic-with-memblock_alloc_try_nid_nopanic.patch
* memblock-replace-alloc_bootmem_pages_nopanic-with-memblock_alloc_nopanic.patch
* memblock-replace-alloc_bootmem_low-with-memblock_alloc_low-2.patch
* memblock-replace-__alloc_bootmem_nopanic-with-memblock_alloc_from_nopanic.patch
* memblock-add-align-parameter-to-memblock_alloc_node.patch
* memblock-replace-alloc_bootmem_pages_node-with-memblock_alloc_node.patch
* memblock-replace-__alloc_bootmem_node-with-appropriate-memblock_-api.patch
* memblock-replace-alloc_bootmem_node-with-memblock_alloc_node.patch
* memblock-replace-alloc_bootmem_low_pages-with-memblock_alloc_low.patch
* memblock-replace-alloc_bootmem_pages-with-memblock_alloc.patch
* memblock-replace-__alloc_bootmem-with-memblock_alloc_from.patch
* memblock-replace-alloc_bootmem-with-memblock_alloc.patch
* mm-nobootmem-remove-bootmem-allocation-apis.patch
* memblock-replace-free_bootmem_node-with-memblock_free.patch
* memblock-replace-free_bootmem_late-with-memblock_free_late.patch
* memblock-rename-free_all_bootmem-to-memblock_free_all.patch
* memblock-rename-__free_pages_bootmem-to-memblock_free_pages.patch
* mm-remove-nobootmem.patch
* memblock-replace-bootmem_alloc_-with-memblock-variants.patch
* mm-remove-include-linux-bootmemh.patch
* docs-boot-time-mm-remove-bootmem-documentation.patch
* android-binder-replace-vm_insert_page-with-vmf_insert_page.patch
* vfs-replace-current_kernel_time64-with-ktime-equivalent.patch
* fix-read-buffer-overflow-in-delta-ipc.patch
  make-sure-nobodys-leaking-resources.patch
  releasing-resources-with-children.patch
  mutex-subsystem-synchro-test-module.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  slab-leaks3-default-y.patch
  workaround-for-a-pci-restoring-bug.patch
