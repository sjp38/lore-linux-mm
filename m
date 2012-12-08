Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 960286B0070
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 19:54:51 -0500 (EST)
Received: by mail-we0-f201.google.com with SMTP id t11so62840wey.2
        for <linux-mm@kvack.org>; Fri, 07 Dec 2012 16:54:49 -0800 (PST)
Subject: mmotm 2012-12-07-16-53 uploaded
From: akpm@linux-foundation.org
Date: Fri, 07 Dec 2012 16:54:47 -0800
Message-Id: <20121208005447.ED80D20004E@hpza10.eem.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

The mm-of-the-moment snapshot 2012-12-07-16-53 has been uploaded to

   http://www.ozlabs.org/~akpm/mmotm/

mmotm-readme.txt says

README for mm-of-the-moment:

http://www.ozlabs.org/~akpm/mmotm/

This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
more than once a week.

You will need quilt to apply these patches to the latest Linus release (3.x
or 3.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
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

http://git.cmpxchg.org/?p=linux-mmotm.git;a=summary

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

	http://git.cmpxchg.org/?p=linux-mmots.git;a=summary

and use of this tree is similar to
http://git.cmpxchg.org/?p=linux-mmotm.git, described above.


This mmotm tree contains the following patches against 3.7-rc8:
(patches marked "*" will be included in linux-next)

  origin.patch
  linux-next.patch
  i-need-old-gcc.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
* thp-fix-update_mmu_cache_pmd-calls.patch
* cris-fix-i-o-macros.patch
* vfs-d_obtain_alias-needs-to-use-as-default-name.patch
* fs-block_devc-page-cache-wrongly-left-invalidated-after-revalidate_disk.patch
* arch-x86-platform-iris-irisc-register-a-platform-device-and-a-platform-driver.patch
* x86-numa-dont-check-if-node-is-numa_no_node.patch
* arch-x86-tools-insn_sanityc-identify-source-of-messages.patch
* uv-fix-incorrect-tlb-flush-all-issue.patch
* olpc-fix-olpc-xo1-scic-build-errors.patch
* x86-convert-update_mmu_cache-and-update_mmu_cache_pmd-to-functions.patch
* x86-fix-the-argument-passed-to-sync_global_pgds.patch
* x86-fix-a-compile-error-a-section-type-conflict.patch
* x86-make-mem=-option-to-work-for-efi-platform.patch
* audit-create-explicit-audit_seccomp-event-type.patch
* audit-catch-possible-null-audit-buffers.patch
* ceph-fix-dentry-reference-leak-in-ceph_encode_fh.patch
* cris-use-int-for-ssize_t-to-match-size_t.patch
* pcmcia-move-unbind-rebind-into-dev_pm_opscomplete.patch
* drivers-video-add-support-for-the-solomon-ssd1307-oled-controller.patch
* drivers-video-console-softcursorc-remove-redundant-null-check-before-kfree.patch
* fb-rework-locking-to-fix-lock-ordering-on-takeover.patch
* fb-rework-locking-to-fix-lock-ordering-on-takeover-fix.patch
* cyber2000fb-avoid-palette-corruption-at-higher-clocks.patch
* irq-tsk-comm-is-an-array.patch
* timeconstpl-remove-deprecated-defined-array.patch
* time-dont-inline-export_symbol-functions.patch
* coccinelle-add-api-d_find_aliascocci.patch
* h8300-select-generic-atomic64_t-support.patch
* mm-mempolicy-introduce-spinlock-to-read-shared-policy-tree.patch
* drivers-message-fusion-mptscsihc-missing-break.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* block-remove-deadlock-in-disk_clear_events.patch
* block-remove-deadlock-in-disk_clear_events-fix.patch
* block-prevent-race-cleanup.patch
* block-prevent-race-cleanup-fix.patch
* vfs-increment-iversion-when-a-file-is-truncated.patch
* fs-change-return-values-from-eacces-to-eperm.patch
* fs-block_devc-need-not-to-check-inode-i_bdev-in-bd_forget.patch
* watchdog-trigger-all-cpu-backtrace-when-locked-up-and-going-to-panic.patch
* mm-slab-remove-duplicate-check.patch
  mm.patch
* writeback-remove-nr_pages_dirtied-arg-from-balance_dirty_pages_ratelimited_nr.patch
* mm-show-migration-types-in-show_mem.patch
* mm-memcg-make-mem_cgroup_out_of_memory-static.patch
* mm-use-is_enabledconfig_numa-instead-of-numa_build.patch
* mm-use-is_enabledconfig_compaction-instead-of-compaction_build.patch
* thp-clean-up-__collapse_huge_page_isolate.patch
* thp-clean-up-__collapse_huge_page_isolate-v2.patch
* mm-introduce-mm_find_pmd.patch
* mm-introduce-mm_find_pmd-fix.patch
* thp-introduce-hugepage_vma_check.patch
* thp-cleanup-introduce-mk_huge_pmd.patch
* memory-hotplug-suppress-device-memoryx-does-not-have-a-release-function-warning.patch
* memory-hotplug-skip-hwpoisoned-page-when-offlining-pages.patch
* memory-hotplug-update-mce_bad_pages-when-removing-the-memory.patch
* memory-hotplug-update-mce_bad_pages-when-removing-the-memory-fix.patch
* memory-hotplug-auto-offline-page_cgroup-when-onlining-memory-block-failed.patch
* memory-hotplug-fix-nr_free_pages-mismatch.patch
* memory-hotplug-fix-nr_free_pages-mismatch-fix.patch
* numa-convert-static-memory-to-dynamically-allocated-memory-for-per-node-device.patch
* memory-hotplug-suppress-device-nodex-does-not-have-a-release-function-warning.patch
* memory-hotplug-mm-sparsec-clear-the-memory-to-store-struct-page.patch
* memory-hotplug-allocate-zones-pcp-before-onlining-pages.patch
* memory-hotplug-allocate-zones-pcp-before-onlining-pages-fix.patch
* memory-hotplug-allocate-zones-pcp-before-onlining-pages-fix-2.patch
* memory_hotplug-fix-possible-incorrect-node_states.patch
* slub-hotplug-ignore-unrelated-nodes-hot-adding-and-hot-removing.patch
* mm-memory_hotplugc-update-start_pfn-in-zone-and-pg_data-when-spanned_pages-==-0.patch
* mm-add-comment-on-storage-key-dirty-bit-semantics.patch
* mmvmscan-only-evict-file-pages-when-we-have-plenty.patch
* mmvmscan-only-evict-file-pages-when-we-have-plenty-fix.patch
* mm-refactor-reinsert-of-swap_info-in-sys_swapoff.patch
* mm-do-not-call-frontswap_init-during-swapoff.patch
* mm-highmem-use-pkmap_nr-to-calculate-an-index-of-pkmap.patch
* mm-highmem-remove-useless-pool_lock.patch
* mm-highmem-remove-page_address_pool-list.patch
* mm-highmem-remove-page_address_pool-list-v2.patch
* mm-highmem-get-virtual-address-of-the-page-using-pkmap_addr.patch
* mm-thp-set-the-accessed-flag-for-old-pages-on-access-fault.patch
* mm-memmap_init_zone-performance-improvement.patch
* documentation-cgroups-memorytxt-s-mem_cgroup_charge-mem_cgroup_change_common.patch
* mm-oom-allow-exiting-threads-to-have-access-to-memory-reserves.patch
* memcg-make-it-possible-to-use-the-stock-for-more-than-one-page.patch
* memcg-reclaim-when-more-than-one-page-needed.patch
* memcg-change-defines-to-an-enum.patch
* memcg-kmem-accounting-basic-infrastructure.patch
* mm-add-a-__gfp_kmemcg-flag.patch
* memcg-kmem-controller-infrastructure.patch
* memcg-kmem-controller-infrastructure-replace-__always_inline-with-plain-inline.patch
* mm-allocate-kernel-pages-to-the-right-memcg.patch
* res_counter-return-amount-of-charges-after-res_counter_uncharge.patch
* memcg-kmem-accounting-lifecycle-management.patch
* memcg-use-static-branches-when-code-not-in-use.patch
* memcg-allow-a-memcg-with-kmem-charges-to-be-destructed.patch
* memcg-execute-the-whole-memcg-freeing-in-free_worker.patch
* fork-protect-architectures-where-thread_size-=-page_size-against-fork-bombs.patch
* memcg-add-documentation-about-the-kmem-controller.patch
* slab-slub-struct-memcg_params.patch
* slab-annotate-on-slab-caches-nodelist-locks.patch
* slab-slub-consider-a-memcg-parameter-in-kmem_create_cache.patch
* memcg-allocate-memory-for-memcg-caches-whenever-a-new-memcg-appears.patch
* memcg-allocate-memory-for-memcg-caches-whenever-a-new-memcg-appears-simplify-ida-initialization.patch
* memcg-infrastructure-to-match-an-allocation-to-the-right-cache.patch
* memcg-skip-memcg-kmem-allocations-in-specified-code-regions.patch
* memcg-skip-memcg-kmem-allocations-in-specified-code-regions-remove-test-for-current-mm-in-memcg_stop-resume_kmem_account.patch
* slb-always-get-the-cache-from-its-page-in-kmem_cache_free.patch
* slb-allocate-objects-from-memcg-cache.patch
* memcg-destroy-memcg-caches.patch
* memcg-destroy-memcg-caches-move-include-of-workqueueh-to-top-of-slabh-file.patch
* memcg-slb-track-all-the-memcg-children-of-a-kmem_cache.patch
* memcg-slb-shrink-dead-caches.patch
* memcg-slb-shrink-dead-caches-get-rid-of-once-per-second-cache-shrinking-for-dead-memcgs.patch
* memcg-aggregate-memcg-cache-values-in-slabinfo.patch
* slab-propagate-tunable-values.patch
* slub-slub-specific-propagation-changes.patch
* slub-slub-specific-propagation-changes-fix.patch
* kmem-add-slab-specific-documentation-about-the-kmem-controller.patch
* memcg-add-comments-clarifying-aspects-of-cache-attribute-propagation.patch
* slub-drop-mutex-before-deleting-sysfs-entry.patch
* dmapool-make-dmapool_debug-detect-corruption-of-free-marker.patch
* dmapool-make-dmapool_debug-detect-corruption-of-free-marker-fix.patch
* hwpoison-fix-action_result-to-print-out-dirty-clean.patch
* mm-print-out-information-of-file-affected-by-memory-error.patch
* mm-support-more-pagesizes-for-map_hugetlb-shm_hugetlb-v7.patch
* mm-support-more-pagesizes-for-map_hugetlb-shm_hugetlb-v7-fix.patch
* mm-support-more-pagesizes-for-map_hugetlb-shm_hugetlb-v7-fix-fix.patch
* mm-support-more-pagesizes-for-map_hugetlb-shm_hugetlb-v7-fix-fix-fix.patch
* mm-support-more-pagesizes-for-map_hugetlb-shm_hugetlb-v7-fix-fix-fix-fix.patch
* mm-support-more-pagesizes-for-map_hugetlb-shm_hugetlb-v7-fix-fix-fix-fix-checkpatch-fixes.patch
* selftests-add-a-test-program-for-variable-huge-page-sizes-in-mmap-shmget.patch
* mm-augment-vma-rbtree-with-rb_subtree_gap.patch
* mm-augment-vma-rbtree-with-rb_subtree_gap-ensure-safe-rb_subtree_gap-update-when-inserting-new-vma.patch
* mm-augment-vma-rbtree-with-rb_subtree_gap-ensure-safe-rb_subtree_gap-update-when-removing-vma.patch
* mm-augment-vma-rbtree-with-rb_subtree_gap--debug-code-to-verify-rb_subtree_gap-updates-are-safe.patch
* mm-augment-vma-rbtree-with-rb_subtree_gap-fix.patch
* mm-check-rb_subtree_gap-correctness.patch
* mm-check-rb_subtree_gap-correctness-fix.patch
* mm-rearrange-vm_area_struct-for-fewer-cache-misses.patch
* mm-rearrange-vm_area_struct-for-fewer-cache-misses-checkpatch-fixes.patch
* mm-vm_unmapped_area-lookup-function.patch
* mm-vm_unmapped_area-lookup-function-checkpatch-fixes.patch
* mm-use-vm_unmapped_area-on-x86_64-architecture.patch
* mm-fix-cache-coloring-on-x86_64-architecture.patch
* mm-use-vm_unmapped_area-in-hugetlbfs.patch
* mm-use-vm_unmapped_area-in-hugetlbfs-on-i386-architecture.patch
* mm-use-vm_unmapped_area-in-hugetlbfs-on-i386-architecture-fix.patch
* mm-use-vm_unmapped_area-on-mips-architecture.patch
* mm-use-vm_unmapped_area-on-mips-architecture-fix.patch
* mm-use-vm_unmapped_area-on-arm-architecture.patch
* mm-use-vm_unmapped_area-on-arm-architecture-fix.patch
* mm-use-vm_unmapped_area-on-arm-architecture-fix-fix.patch
* mm-use-vm_unmapped_area-on-sh-architecture.patch
* mm-use-vm_unmapped_area-on-sh-architecture-fix.patch
* mm-use-vm_unmapped_area-on-sh-architecture-fix2.patch
* mm-use-vm_unmapped_area-on-sparc32-architecture.patch
* mm-use-vm_unmapped_area-on-sparc32-architecture-fix.patch
* mm-use-vm_unmapped_area-on-sparc32-architecture-fix-fix.patch
* mm-use-vm_unmapped_area-in-hugetlbfs-on-tile-architecture.patch
* mm-use-vm_unmapped_area-in-hugetlbfs-on-tile-architecture-fix.patch
* mm-use-vm_unmapped_area-on-sparc64-architecture.patch
* mm-use-vm_unmapped_area-on-sparc64-architecture-fix.patch
* mm-use-vm_unmapped_area-on-sparc64-architecture-fix-fix.patch
* mm-use-vm_unmapped_area-in-hugetlbfs-on-sparc64-architecture.patch
* mm-use-vm_unmapped_area-in-hugetlbfs-on-sparc64-architecture-fix.patch
* arch-sparc-kernel-sys_sparc_64c-s-colour-color.patch
* mm-adjust-address_space_operationsmigratepage-return-code.patch
* mm-redefine-address_spaceassoc_mapping.patch
* mm-introduce-a-common-interface-for-balloon-pages-mobility.patch
* mm-introduce-a-common-interface-for-balloon-pages-mobility-mm-fix-balloon_page_movable-page-flags-check.patch
* mm-introduce-a-common-interface-for-balloon-pages-mobility-mm-fix-balloon_page_movable-page-flags-check-fix.patch
* mm-introduce-a-common-interface-for-balloon-pages-mobility-fix.patch
* mm-introduce-compaction-and-migration-for-ballooned-pages.patch
* virtio_balloon-introduce-migration-primitives-to-balloon-pages.patch
* virtio_balloon-introduce-migration-primitives-to-balloon-pages-fix.patch
* virtio_balloon-introduce-migration-primitives-to-balloon-pages-fix-fix.patch
* virtio_balloon-introduce-migration-primitives-to-balloon-pages-fix-fix-fix.patch
* mm-introduce-putback_movable_pages.patch
* mm-add-vm-event-counters-for-balloon-pages-compaction.patch
* mm-vmscanc-try_to_freeze-returns-boolean.patch
* mm-mempolicy-remove-duplicate-code.patch
* mm-cleanup-register_node.patch
* mm-oom-change-type-of-oom_score_adj-to-short.patch
* mm-oom-fix-race-when-specifying-a-thread-as-the-oom-origin.patch
* mm-cma-skip-watermarks-check-for-already-isolated-blocks-in-split_free_page.patch
* mm-cma-skip-watermarks-check-for-already-isolated-blocks-in-split_free_page-fix.patch
* mm-cma-skip-watermarks-check-for-already-isolated-blocks-in-split_free_page-fix-fix.patch
* mm-cma-remove-watermark-hacks.patch
* mm-cma-remove-watermark-hacks-fix.patch
* bootmem-remove-not-implemented-function-call-bootmem_arch_preferred_node.patch
* avr32-kconfig-remove-have_arch_bootmem.patch
* bootmem-remove-alloc_arch_preferred_bootmem.patch
* bootmem-fix-wrong-call-parameter-for-free_bootmem.patch
* bootmem-fix-wrong-call-parameter-for-free_bootmem-fix.patch
* mm-cma-warn-if-freed-memory-is-still-in-use.patch
* drivers-base-nodec-cleanup-node_state_attr.patch
* mm-memory-hotplug-dynamic-configure-movable-memory-and-portion-memory.patch
* mm-memory-hotplug-dynamic-configure-movable-memory-and-portion-memory-fix.patch
* memory_hotplug-handle-empty-zone-when-online_movable-online_kernel.patch
* memory_hotplug-ensure-every-online-node-has-normal-memory.patch
* thp-huge-zero-page-basic-preparation.patch
* thp-huge-zero-page-basic-preparation-v6.patch
* thp-zap_huge_pmd-zap-huge-zero-pmd.patch
* thp-copy_huge_pmd-copy-huge-zero-page.patch
* thp-copy_huge_pmd-copy-huge-zero-page-v6.patch
* thp-copy_huge_pmd-copy-huge-zero-page-v6-fix.patch
* thp-do_huge_pmd_wp_page-handle-huge-zero-page.patch
* thp-do_huge_pmd_wp_page-handle-huge-zero-page-v6.patch
* thp-do_huge_pmd_wp_page-handle-huge-zero-page-thp-fix-anononymous-page-accounting-in-fallback-path-for-cow-of-hzp.patch
* thp-change_huge_pmd-make-sure-we-dont-try-to-make-a-page-writable.patch
* thp-change-split_huge_page_pmd-interface.patch
* thp-change-split_huge_page_pmd-interface-v6.patch
* thp-implement-splitting-pmd-for-huge-zero-page.patch
* thp-implement-splitting-pmd-for-huge-zero-page-fix.patch
* thp-implement-splitting-pmd-for-huge-zero-page-v6.patch
* thp-setup-huge-zero-page-on-non-write-page-fault.patch
* thp-setup-huge-zero-page-on-non-write-page-fault-fix.patch
* thp-lazy-huge-zero-page-allocation.patch
* thp-implement-refcounting-for-huge-zero-page.patch
* thp-vmstat-implement-hzp_alloc-and-hzp_alloc_failed-events.patch
* thp-vmstat-implement-hzp_alloc-and-hzp_alloc_failed-events-v6.patch
* thp-introduce-sysfs-knob-to-disable-huge-zero-page.patch
* thp-avoid-race-on-multiple-parallel-page-faults-to-the-same-page.patch
* mm-compaction-fix-compiler-warning.patch
* mm-use-migrate_prep-instead-of-migrate_prep_local.patch
* node_states-introduce-n_memory.patch
* cpuset-use-n_memory-instead-n_high_memory.patch
* procfs-use-n_memory-instead-n_high_memory.patch
* memcontrol-use-n_memory-instead-n_high_memory.patch
* oom-use-n_memory-instead-n_high_memory.patch
* mmmigrate-use-n_memory-instead-n_high_memory.patch
* mempolicy-use-n_memory-instead-n_high_memory.patch
* hugetlb-use-n_memory-instead-n_high_memory.patch
* vmstat-use-n_memory-instead-n_high_memory.patch
* kthread-use-n_memory-instead-n_high_memory.patch
* init-use-n_memory-instead-n_high_memory.patch
* vmscan-use-n_memory-instead-n_high_memory.patch
* page_alloc-use-n_memory-instead-n_high_memory-change-the-node_states-initialization.patch
* hotplug-update-nodemasks-management.patch
* res_counter-delete-res_counter_write.patch
* mm-warn_on_once-if-f_op-mmap-change-vmas-start-address.patch
* mm-add-a-reminder-comment-for-__gfp_bits_shift.patch
* mm-memcg-avoid-unnecessary-function-call-when-memcg-is-disabled.patch
* mm-memcg-avoid-unnecessary-function-call-when-memcg-is-disabled-fix.patch
* numa-add-config_movable_node-for-movable-dedicated-node.patch
* numa-add-config_movable_node-for-movable-dedicated-node-fix.patch
* memory_hotplug-allow-online-offline-memory-to-result-movable-node.patch
* mm-oom-cleanup-pagefault-oom-handler.patch
* mm-oom-remove-redundant-sleep-in-pagefault-oom-handler.patch
* mm-oom-remove-statically-defined-arch-functions-of-same-name.patch
* mm-introduce-new-field-managed_pages-to-struct-zone.patch
* mm-introduce-new-field-managed_pages-to-struct-zone-fix.patch
* mm-trace-filemap-add-and-del.patch
* writeback-fix-a-typo-in-comment.patch
* fs-bufferc-do-not-inline-exported-function.patch
* fs-bufferc-remove-redundant-initialization-in-alloc_page_buffers.patch
* mm-provide-more-accurate-estimation-of-pages-occupied-by-memmap.patch
* mm-provide-more-accurate-estimation-of-pages-occupied-by-memmap-fix.patch
* tmpfs-support-seek_data-and-seek_hole-reprise.patch
* memcg-do-not-check-for-mm-in-mem_cgroup_count_vm_event-disabled.patch
* mm-protect-against-concurrent-vma-expansion.patch
* hwpoison-hugetlbfs-fix-bad-pmd-warning-in-unmapping-hwpoisoned-hugepage.patch
* hwpoison-hugetlbfs-fix-rss-counter-warning.patch
* hwpoison-hugetlbfs-fix-rss-counter-warning-fix.patch
* hwpoison-hugetlbfs-fix-rss-counter-warning-fix-fix.patch
* hwpoison-hugetlbfs-fix-warning-on-freeing-hwpoisoned-hugepage.patch
* asm-generic-mm-pgtable-consolidate-zero-page-helpers.patch
* drop_caches-add-some-documentation-and-info-messsge.patch
* drop_caches-add-some-documentation-and-info-messsge-checkpatch-fixes.patch
* swap-add-a-simple-detector-for-inappropriate-swapin-readahead.patch
* swap-add-a-simple-detector-for-inappropriate-swapin-readahead-fix.patch
* mm-memblock-reduce-overhead-in-binary-search.patch
* drivers-usb-gadget-amd5536udcc-avoid-calling-dma_pool_create-with-null-dev.patch
* mm-dmapoolc-fix-null-dev-in-dma_pool_create.patch
* memcg-debugging-facility-to-access-dangling-memcgs.patch
* memcg-debugging-facility-to-access-dangling-memcgs-fix.patch
* frv-fix-use-of-extinct-_sbss-and-_ebss-in-debug-code.patch
* frv-properly-use-the-declarations-provided-by-asm-sectionsh.patch
* scripts-pnmtologo-fix-for-plain-pbm-checkpatch-fixes.patch
* documentation-kernel-parameterstxt-update-mem=-options-spec-according-to-its-implementation.patch
* include-linux-inith-use-the-stringify-operator-for-the-__define_initcall-macro.patch
* scripts-tagssh-add-magic-for-declarations-of-popular-kernel-type.patch
* documentation-remove-reference-to-feature-removal-scheduletxt.patch
* kernel-remove-reference-to-feature-removal-scheduletxt.patch
* sound-remove-reference-to-feature-removal-scheduletxt.patch
* drivers-remove-reference-to-feature-removal-scheduletxt.patch
* lseek-the-whence-argument-is-called-whence.patch
* kconfig-centralise-config_arch_no_virt_to_bus.patch
* fs-notify-inode_markc-make-fsnotify_find_inode_mark_locked-static.patch
* remove-stale-entry-for-generated-versionh-file-in-gitignore.patch
* sendfile-allows-bypassing-of-notifier-events.patch
* watchdog-store-the-watchdog-sample-period-as-a-variable.patch
* printk-boot_delay-should-only-affect-output.patch
* lib-vsprintfc-fix-handling-of-%zd-when-using-ssize_t.patch
* maintainers-chinese-maintainers-mailing-list-is-subscribers-only.patch
* maintainers-remove-include-linux-ext3.patch
* corentin-has-moved.patch
* backlight-da903x_bl-use-dev_get_drvdata-instead-of-platform_get_drvdata.patch
* backlight-88pm860x_bl-fix-checkpatch-warning.patch
* backlight-atmel-pwm-bl-fix-checkpatch-warning.patch
* backlight-corgi_lcd-fix-checkpatch-error-and-warning.patch
* backlight-da903x_bl-fix-checkpatch-warning.patch
* backlight-generic_bl-fix-checkpatch-warning.patch
* backlight-hp680_bl-fix-checkpatch-error-and-warning.patch
* backlight-ili9320-fix-checkpatch-error-and-warning.patch
* backlight-jornada720-fix-checkpatch-error-and-warning.patch
* backlight-l4f00242t03-fix-checkpatch-warning.patch
* backlight-lm3630-fix-checkpatch-warning.patch
* backlight-locomolcd-fix-checkpatch-error-and-warning.patch
* backlight-omap1-fix-checkpatch-warning.patch
* backlight-pcf50633-fix-checkpatch-warning.patch
* backlight-platform_lcd-fix-checkpatch-error.patch
* backlight-tdo24m-fix-checkpatch-warning.patch
* backlight-tosa-fix-checkpatch-error-and-warning.patch
* backlight-vgg2432a4-fix-checkpatch-warning.patch
* backlight-lms283gf05-use-devm_gpio_request_one.patch
* backlight-tosa-use-devm_gpio_request_one.patch
* drivers-video-backlight-lp855x_blc-use-generic-pwm-functions.patch
* drivers-video-backlight-lp855x_blc-use-generic-pwm-functions-fix.patch
* drivers-video-backlight-lp855x_blc-remove-unnecessary-mutex-code.patch
* drivers-video-backlight-da9052_blc-add-missing-const.patch
* drivers-video-backlight-lms283gf05c-add-missing-const.patch
* drivers-video-backlight-tdo24mc-add-missing-const.patch
* drivers-video-backlight-vgg2432a4c-add-missing-const.patch
* drivers-video-backlight-s6e63m0c-remove-unnecessary-cast-of-void-pointer.patch
* drivers-video-backlight-88pm860x_blc-drop-devm_kfree-of-devm_kzallocd-data.patch
* drivers-video-backlight-max8925_blc-drop-devm_kfree-of-devm_kzallocd-data.patch
* drivers-video-backlight-lm3639_blc-fix-up-world-writable-sysfs-file.patch
* drivers-video-backlight-ep93xx_blc-fix-section-mismatch.patch
* drivers-video-backlight-hp680_blc-add-missing-__devexit-macros-for-remove.patch
* drivers-video-backlight-ili9320c-add-missing-__devexit-macros-for-remove.patch
* backlight-add-of_find_backlight_by_node-function.patch
* backlight-add-of_find_backlight_by_node-function-fix.patch
* backlight-add-of_find_backlight_by_node-function-fix-2.patch
* drivers-video-backlight-pandora_blc-change-twl4030_module_pwm0-to-twl_module_pwm.patch
* backlight-88pm860x_bl-remove-an-unnecessary-line-continuation.patch
* backlight-88pm860x_bl-remove-an-unnecessary-line-continuation-fix.patch
* backlight-lcd-return-enxio-when-ops-functions-cannot-be-called.patch
* drivers-video-backlight-lms283gf05c-use-gpiof_init-flags-when-using-devm_gpio_request_one.patch
* backlight-corgi_lcd-use-gpio_set_value_cansleep-to-avoid-warn_on.patch
* string-introduce-helper-to-get-base-file-name-from-given-path.patch
* lib-dynamic_debug-use-kbasename.patch
* mm-use-kbasename.patch
* procfs-use-kbasename.patch
* procfs-use-kbasename-fix.patch
* trace-use-kbasename.patch
* drivers-of-fdtc-re-use-kernels-kbasename.patch
* sscanf-dont-ignore-field-widths-for-numeric-conversions.patch
* percpu_rw_semaphore-reimplement-to-not-block-the-readers-unnecessarily.patch
* percpu_rw_semaphore-reimplement-to-not-block-the-readers-unnecessari-lyfix.patch
* percpu_rw_semaphore-kill-writer_mutex-add-write_ctr.patch
* percpu_rw_semaphore-add-the-lockdep-annotations.patch
* percpu_rw_semaphore-introduce-config_percpu_rwsem.patch
* compat-generic-compat_sys_sched_rr_get_interval-implementation.patch
* drivers-firmware-dmi_scanc-check-dmi-version-when-get-system-uuid.patch
* drivers-firmware-dmi_scanc-check-dmi-version-when-get-system-uuid-fix.patch
* drivers-firmware-dmi_scanc-fetch-dmi-version-from-smbios-if-it-exists.patch
* drivers-firmware-dmi_scanc-fetch-dmi-version-from-smbios-if-it-exists-checkpatch-fixes.patch
* checkpatch-warn-on-unnecessary-line-continuations.patch
* checkpatch-warn-about-using-config_experimental.patch
* checkpatch-remove-reference-to-feature-removal-scheduletxt.patch
* checkpatch-consolidate-if-foo-barfoo-checks-and-add-debugfs_remove.patch
* checkpatch-allow-control-over-line-length-warning-default-remains-80.patch
* checkpatch-extend-line-continuation-test.patch
* checkpatch-add-strict-messages-for-blank-lines-around-braces.patch
* checkpatch-warn-when-declaring-struct-spinlock-foo.patch
* epoll-support-for-disabling-items-and-a-self-test-app.patch
* binfmt_elf-fix-corner-case-kfree-of-uninitialized-data.patch
* binfmt_elf-fix-corner-case-kfree-of-uninitialized-data-checkpatch-fixes.patch
* binfmt_elfc-use-get_random_int-to-fix-entropy-depleting.patch
* rtc-omap-kicker-mechanism-support.patch
* arm-davinci-remove-rtc-kicker-release.patch
* rtc-omap-dt-support.patch
* rtc-omap-depend-on-am33xx.patch
* rtc-omap-add-runtime-pm-support.patch
* rtc-imxdi-support-for-imx53.patch
* rtc-imxdi-add-devicetree-support.patch
* drivers-rtc-rtc-vt8500c-convert-to-use-devm_kzalloc.patch
* rtc-avoid-calling-platform_device_put-twice-in-test_init.patch
* rtc-avoid-calling-platform_device_put-twice-in-test_init-fix.patch
* rtc-rtc-spear-use-devm_-routines.patch
* rtc-rtc-spear-use-devm_-routines-fix.patch
* rtc-rtc-spear-add-clk_unprepare-support.patch
* rtc-rtc-spear-provide-flag-for-no-support-of-uie-mode.patch
* drivers-rtc-rtc-tps65910c-rename-irq-to-match-device.patch
* rtc-rtc-davinci-return-correct-error-code-if-rtc_device_register-fails.patch
* rtc-rtc-davinci-use-devm_kzalloc.patch
* rtc-add-nxp-pcf8523-support.patch
* rtc-add-nxp-pcf8523-support-v2.patch
* drivers-rtc-rtc-s3cc-remove-unnecessary-err_nores-label.patch
* drivers-rtc-rtc-s3cc-convert-to-use-devm_-api.patch
* rtc-remove-unused-code-from-rtc-devc.patch
* drivers-rtc-rtc-tps65910c-enable-rtc-power-domain-on-initialization.patch
* hfsplus-avoid-crash-on-failed-block-map-free.patch
* hfsplus-add-osx-prefix-for-handling-namespace-of-mac-os-x-extended-attributes.patch
* hfsplus-add-osx-prefix-for-handling-namespace-of-mac-os-x-extended-attributes-checkpatch-fixes.patch
* hfsplus-add-on-disk-layout-declarations-related-to-attributes-tree.patch
* hfsplus-add-functionality-of-manipulating-by-records-in-attributes-tree.patch
* hfsplus-rework-functionality-of-getting-setting-and-deleting-of-extended-attributes.patch
* hfsplus-rework-functionality-of-getting-setting-and-deleting-of-extended-attributes-fix.patch
* hfsplus-add-support-of-manipulation-by-attributes-file.patch
* hfsplus-rework-processing-errors-in-hfsplus_free_extents.patch
* hfsplus-rework-processing-of-hfs_btree_write-returned-error.patch
* hfsplus-rework-processing-of-hfs_btree_write-returned-error-fix.patch
* hfsplus-rework-processing-of-hfs_btree_write-returned-error-fix-fix.patch
* hfsplus-add-error-message-for-the-case-of-failure-of-sync-fs-in-delayed_sync_fs-method.patch
* fat-notify-when-discard-is-not-supported.patch
* fat-provide-option-for-setting-timezone-offset.patch
* fat-fix-mount-option-parsing.patch
* fs-fat-strip-cp-prefix-from-codepage-in-display.patch
* documentation-dma-api-howtotxt-minor-grammar-corrections.patch
* documentation-fixed-documentation-security-00-index.patch
* kstrto-add-documentation.patch
* simple_strto-annotate-function-as-obsolete.patch
* ptrace-introduce-ptrace_o_exitkill.patch
* proc-dont-show-nonexistent-capabilities.patch
* procfs-add-vmflags-field-in-smaps-output-v4.patch
* procfs-add-vmflags-field-in-smaps-output-v4-fix.patch
* proc-pid-status-add-seccomp-field.patch
* proc-pid-status-show-all-supplementary-groups.patch
* fork-unshare-remove-dead-code.patch
* exec-do-not-leave-bprm-interp-on-stack.patch
* exec-use-eloop-for-max-recursion-depth.patch
* ipc-remove-forced-assignment-of-selected-message.patch
* ipc-add-sysctl-to-specify-desired-next-object-id.patch
* ipc-add-sysctl-to-specify-desired-next-object-id-checkpatch-fixes.patch
* ipc-add-sysctl-to-specify-desired-next-object-id-wrap-new-sysctls-for-criu-inside-config_checkpoint_restore.patch
* ipc-add-sysctl-to-specify-desired-next-object-id-documentation-update-sysctl-kerneltxt.patch
* ipc-message-queue-receive-cleanup.patch
* ipc-message-queue-receive-cleanup-checkpatch-fixes.patch
* ipc-message-queue-copy-feature-introduced.patch
* ipc-message-queue-copy-feature-introduced-remove-redundant-msg_copy-check.patch
* ipc-message-queue-copy-feature-introduced-cleanup-do_msgrcv-aroung-msg_copy-feature.patch
* selftests-ipc-message-queue-copy-feature-test.patch
* selftests-ipc-message-queue-copy-feature-test-update.patch
* ipc-simplify-free_copy-call.patch
* ipc-convert-prepare_copy-from-macro-to-function.patch
* ipc-convert-prepare_copy-from-macro-to-function-fix.patch
* ipc-simplify-message-copying.patch
* ipc-add-more-comments-to-message-copying-related-code.patch
* documentation-sysctl-kerneltxt-document-proc-sys-shmall.patch
* ipc-semc-alternatives-to-preempt_disable.patch
* pidns-remove-unused-is_container_init.patch
* linux-compilerh-add-__must_hold-macro-for-functions-called-with-a-lock-held.patch
* documentation-sparsetxt-document-context-annotations-for-lock-checking.patch
* aoe-describe-the-behavior-of-the-err-character-device.patch
* aoe-print-warning-regarding-a-common-reason-for-dropped-transmits.patch
* aoe-print-warning-regarding-a-common-reason-for-dropped-transmits-v2.patch
* aoe-print-warning-regarding-a-common-reason-for-dropped-transmits-fix.patch
* aoe-update-cap-on-outstanding-commands-based-on-config-query-response.patch
* aoe-support-the-forgetting-flushing-of-a-user-specified-aoe-target.patch
* aoe-support-larger-i-o-requests-via-aoe_maxsectors-module-param.patch
* aoe-payload-sysfs-file-exports-per-aoe-command-data-transfer-size.patch
* aoe-cleanup-remove-unused-ata_scnt-function.patch
* aoe-whitespace-cleanup.patch
* aoe-update-driver-internal-version-number-to-60.patch
* aoe-provide-ata-identify-device-content-to-user-on-request.patch
* aoe-improve-network-congestion-handling.patch
* aoe-err-device-include-mac-addresses-for-unexpected-responses.patch
* aoe-manipulate-aoedev-network-stats-under-lock.patch
* aoe-use-high-resolution-rtts-with-fallback-to-low-res.patch
* aoe-commands-in-retransmit-queue-use-new-destination-on-failure.patch
* aoe-update-driver-internal-version-to-64.patch
* aoe-copy-fallback-timing-information-on-destination-failover.patch
* aoe-remove-vestigial-request-queue-allocation.patch
* aoe-increase-default-cap-on-outstanding-aoe-commands-in-the-network.patch
* aoe-cleanup-correct-comment-for-aoetgt-nout.patch
* aoe-remove-call-to-request-handler-from-i-o-completion.patch
* aoe-make-error-messages-more-specific-in-static-minor-allocation.patch
* aoe-initialize-sysminor-to-avoid-compiler-warning.patch
* aoe-return-real-minor-number-for-static-minors.patch
* aoe-improve-handling-of-misbehaving-network-paths.patch
* aoe-avoid-races-between-device-destruction-and-discovery.patch
* aoe-use-dynamic-number-of-remote-ports-for-aoe-storage-target.patch
* aoe-allow-user-to-disable-target-failure-timeout.patch
* aoe-allow-comma-separator-in-aoe_iflist-value.patch
* aoe-identify-source-of-runt-aoe-packets.patch
* aoe-update-internal-version-number-to-81.patch
* aoe-fix-use-after-free-in-aoedev_by_aoeaddr.patch
* random32-rename-random32-to-prandom.patch
* prandom-introduce-prandom_bytes-and-prandom_bytes_state.patch
* bnx2x-use-prandom_bytes.patch
* mtd-nandsim-use-prandom_bytes.patch
* ubifs-use-prandom_bytes.patch
* mtd-mtd_nandecctest-use-prandom_bytes-instead-of-get_random_bytes.patch
* mtd-mtd_oobtest-convert-to-use-prandom-library.patch
* mtd-mtd_pagetest-convert-to-use-prandom-library.patch
* mtd-mtd_speedtest-use-prandom_bytes.patch
* mtd-mtd_subpagetest-convert-to-use-prandom-library.patch
* mtd-mtd_stresstest-use-prandom_bytes.patch
* dma-debug-new-interfaces-to-debug-dma-mapping-errors-fix-fix.patch
* vm-selftests-print-failure-status-instead-of-cause-make-error.patch
* mqueue-selftests-print-failure-status-instead-of-cause-make-error.patch
* cpu-hotplug-selftests-print-failure-status-instead-of-cause-make-error.patch
* mem-hotplug-selftests-print-failure-status-instead-of-cause-make-error.patch
* kcmp-selftests-make-run_tests-fix.patch
* kcmp-selftests-print-fail-status-instead-of-cause-make-error.patch
* breakpoint-selftests-print-failure-status-instead-of-cause-make-error.patch
* tools-testing-selftests-kcmp-kcmp_testc-print-reason-for-failure-in-kcmp_test.patch
* procfs-add-ability-to-plug-in-auxiliary-fdinfo-providers.patch
* fs-eventfd-add-procfs-fdinfo-helper.patch
* fs-epoll-add-procfs-fdinfo-helper-v2.patch
* fs-epoll-add-procfs-fdinfo-helper-v2-fs-epoll-drop-enabled-field-from-fdinfo-output.patch
* fdinfo-show-sigmask-for-signalfd-fd-v3.patch
* fs-exportfs-escape-nil-dereference-if-no-s_export_op-present.patch
* fs-exportfs-add-exportfs_encode_inode_fh-helper.patch
* fs-notify-add-procfs-fdinfo-helper-v7.patch
* fs-notify-add-procfs-fdinfo-helper-v7-fix-fix.patch
* fs-notify-add-procfs-fdinfo-helper-v7-add-missing-space-after-prefix.patch
* fs-notify-add-procfs-fdinfo-helper-v7-dont-forget-to-provide-fhandle-for-inode-fanotify.patch
* fs-notify-add-procfs-fdinfo-helper-v7-fs-fanotify-ddd-missing-pieces-in-fdinfo-for-ability-to-call-fanotify_init.patch
* docs-add-documentation-about-proc-pid-fdinfo-fd-output.patch
* docs-add-documentation-about-proc-pid-fdinfo-fd-output-fix.patch
* fs-fanotify-add-mflags-field-to-fanotify-output.patch
* docs-update-documentation-about-proc-pid-fdinfo-fd-fanotify-output.patch
* fs-notify-add-procfs-fdinfo-helper-v7-fix.patch
* scatterlist-dont-bug-when-we-can-trivially-return-a-proper-error.patch
* scatterlist-dont-bug-when-we-can-trivially-return-a-proper-error-fix.patch
  debugging-keep-track-of-page-owners.patch
  debugging-keep-track-of-page-owners-fix.patch
  make-sure-nobodys-leaking-resources.patch
  journal_add_journal_head-debug.patch
  releasing-resources-with-children.patch
  make-frame_pointer-default=y.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  mutex-subsystem-synchro-test-module.patch
  mutex-subsystem-synchro-test-module-fix.patch
  mutex-subsystem-synchro-test-module-fix-2.patch
  mutex-subsystem-synchro-test-module-fix-3.patch
  slab-leaks3-default-y.patch
  put_bh-debug.patch
  add-debugging-aid-for-memory-initialisation-problems.patch
  workaround-for-a-pci-restoring-bug.patch
  single_open-seq_release-leak-diagnostics.patch
  add-a-refcount-check-in-dput.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
