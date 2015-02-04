Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 28A926B009B
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 19:38:58 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so102807546pab.12
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 16:38:57 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id xq2si52847pbc.139.2015.02.03.16.38.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Feb 2015 16:38:56 -0800 (PST)
Date: Tue, 03 Feb 2015 16:38:55 -0800
From: akpm@linux-foundation.org
Subject: mmotm 2015-02-03-16-38 uploaded
Message-ID: <54d16a1f.oeieDoHfVjdA+0KA%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz

The mm-of-the-moment snapshot 2015-02-03-16-38 has been uploaded to

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


This mmotm tree contains the following patches against 3.19-rc7:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
* mm-pagewalk-call-pte_hole-for-vm_pfnmap-during-walk_page_range.patch
* mailmap-update-konstantin-khlebnikovs-email-address.patch
* mm-export-high_memory-symbol-on-mmu.patch
* memcg-shmem-fix-shmem-migration-to-use-lrucare.patch
* maintainers-remove-superh-website.patch
* mm-debug_pagealloc-fix-build-failure-on-ppc-and-some-other-archs.patch
* jffs2-bugfix-of-summary-length.patch
* fanotify-only-destroy-mark-when-both-mask-and-ignored_mask-are-cleared.patch
* fanotify-dont-recalculate-a-marks-mask-if-only-the-ignored-mask-changed.patch
* fanotify-dont-recalculate-a-marks-mask-if-only-the-ignored-mask-changed-checkpatch-fixes.patch
* fanotify-dont-set-fan_ondir-implicitly-on-a-marks-ignored-mask.patch
* fanotify-dont-set-fan_ondir-implicitly-on-a-marks-ignored-mask-checkpatch-fixes.patch
* input-route-kbd-leds-through-the-generic-leds-layer.patch
* build-superh-without-config_expert.patch
* sh-eliminate-unused-irq_reg_readlwritel-accessors.patch
* fs-ext4-fsyncc-generic_file_fsync-call-based-on-barrier-flag.patch
* ocfs2-dlm-add-missing-dlm_lock_put-when-recovery-master-down.patch
* ocfs2-remove-unnecessary-else-in-ocfs2_set_acl.patch
* ocfs2-fix-uninitialized-variable-access.patch
* ocfs2-fix-wrong-comment.patch
* ocfs2-fix-snprintf-format-specifier-in-dlmdebugc.patch
* ocfs2-xattr-remove-unused-function.patch
* ocfs2-quota_local-remove-unused-function.patch
* ocfs2-dlm-dlmdomain-remove-unused-function.patch
* ocfs2-fix-journal-commit-deadlock-in-ocfs2_convert_inline_data_to_extents.patch
* ocfs2-add-a-mount-option-journal_async_commit-on-ocfs2-filesystem.patch
* ocfs2-remove-pointless-assignment-from-ocfs2_calc_refcount_meta_credits.patch
* ocfs2-o2net-silence-uninitialized-variable-warning.patch
* ocfs2-remove-unreachable-code.patch
* ocfs2-removes-mlog_errno-call-twice-in-ocfs2_find_dir_space_el.patch
* ocfs2-remove-unreachable-code-in-__ocfs2_recovery_thread.patch
* ocfs2-prune-the-dcache-before-deleting-the-dentry-of-directory.patch
* o2dlm-fix-null-pointer-dereference-in-o2dlm_blocking_ast_wrapper.patch
* ocfs2-call-ocfs2_journal_access_di-before-ocfs2_journal_dirty-in-ocfs2_write_end_nolock.patch
* ocfs2-avoid-access-invalid-address-when-read-o2dlm-debug-messages.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* fs-make-generic_block_fiemap-sig-tolerant.patch
* fs-make-generic_block_fiemap-sig-tolerant-fix.patch
  mm.patch
* mm-slub-optimize-alloc-free-fastpath-by-removing-preemption-on-off.patch
* mm-slub-optimize-alloc-free-fastpath-by-removing-preemption-on-off-v3.patch
* mm-dont-use-compound_head-in-virt_to_head_page.patch
* mm-dont-use-compound_head-in-virt_to_head_page-v3.patch
* mm-slub-fix-typo.patch
* mm-vmstatc-fix-cleanup-ifdefs.patch
* mm-vmstatc-fix-cleanup-ifdefs-fix-2.patch
* mm-replace-remap_file_pages-syscall-with-emulation.patch
* mm-drop-support-of-non-linear-mapping-from-unmap-zap-codepath.patch
* mm-drop-support-of-non-linear-mapping-from-fault-codepath.patch
* mm-drop-vm_ops-remap_pages-and-generic_file_remap_pages-stub.patch
* mm-drop-vm_ops-remap_pages-and-generic_file_remap_pages-stub-fix.patch
* proc-drop-handling-non-linear-mappings.patch
* rmap-drop-support-of-non-linear-mappings.patch
* mm-replace-vma-shareadlinear-with-vma-shared.patch
* mm-remove-rest-usage-of-vm_nonlinear-and-pte_file.patch
* mm-remove-rest-usage-of-vm_nonlinear-and-pte_file-fix.patch
* asm-generic-drop-unused-pte_file-helpers.patch
* alpha-drop-_page_file-and-pte_file-related-helpers.patch
* arc-drop-_page_file-and-pte_file-related-helpers.patch
* arc-drop-_page_file-and-pte_file-related-helpers-fix.patch
* arm64-drop-pte_file-and-pte_file-related-helpers.patch
* arm-drop-l_pte_file-and-pte_file-related-helpers.patch
* avr32-drop-_page_file-and-pte_file-related-helpers.patch
* blackfin-drop-pte_file.patch
* c6x-drop-pte_file.patch
* cris-drop-_page_file-and-pte_file-related-helpers.patch
* frv-drop-_page_file-and-pte_file-related-helpers.patch
* hexagon-drop-_page_file-and-pte_file-related-helpers.patch
* ia64-drop-_page_file-and-pte_file-related-helpers.patch
* m32r-drop-_page_file-and-pte_file-related-helpers.patch
* m68k-drop-_page_file-and-pte_file-related-helpers.patch
* metag-drop-_page_file-and-pte_file-related-helpers.patch
* microblaze-drop-_page_file-and-pte_file-related-helpers.patch
* mips-drop-_page_file-and-pte_file-related-helpers.patch
* mn10300-drop-_page_file-and-pte_file-related-helpers.patch
* nios2-drop-_page_file-and-pte_file-related-helpers.patch
* openrisc-drop-_page_file-and-pte_file-related-helpers.patch
* parisc-drop-_page_file-and-pte_file-related-helpers.patch
* s390-drop-pte_file-related-helpers.patch
* score-drop-_page_file-and-pte_file-related-helpers.patch
* sh-drop-_page_file-and-pte_file-related-helpers.patch
* sparc-drop-pte_file-related-helpers.patch
* tile-drop-pte_file-related-helpers.patch
* um-drop-_page_file-and-pte_file-related-helpers.patch
* unicore32-drop-pte_file-related-helpers.patch
* x86-drop-_page_file-and-pte_file-related-helpers.patch
* xtensa-drop-_page_file-and-pte_file-related-helpers.patch
* mm-memory-remove-vm_file-check-on-shared-writable-vmas.patch
* mm-memory-merge-shared-writable-dirtying-branches-in-do_wp_page.patch
* hugetlb-sysctl-pass-extra1-=-null-rather-then-extra1-=-zero.patch
* mm-hugetlb-fix-type-of-hugetlb_treat_as_movable-variable.patch
* mm-page_alloc-place-zone_id-check-before-vm_bug_on_page-check.patch
* memcg-zap-__memcg_chargeuncharge_slab.patch
* memcg-zap-memcg_name-argument-of-memcg_create_kmem_cache.patch
* memcg-zap-memcg_slab_caches-and-memcg_slab_mutex.patch
* mm-add-fields-for-compound-destructor-and-order-into-struct-page.patch
* mm-add-vm_bug_on_page-for-page_mapcount.patch
* mm-add-kpf_zero_page-flag-for-proc-kpageflags.patch
* oom-dont-count-on-mm-less-current-process.patch
* oom-make-sure-that-tif_memdie-is-set-under-task_lock.patch
* swap-remove-unused-mem_cgroup_uncharge_swapcache-declaration.patch
* mm-memcontrol-track-move_lock-state-internally.patch
* mm-memcontrol-track-move_lock-state-internally-fix.patch
* mm-page_allocc-__alloc_pages_nodemask-dont-alter-arg-gfp_mask.patch
* kmemcheck-move-hook-into-__alloc_pages_nodemask-for-the-page-allocator.patch
* mm-fix-a-typo-of-migrate_reserve-in-comment.patch
* mm-vmscan-wake-up-all-pfmemalloc-throttled-processes-at-once.patch
* mm-hugetlb-reduce-arch-dependent-code-around-follow_huge_.patch
* mm-hugetlb-reduce-arch-dependent-code-around-follow_huge_-fix.patch
* mm-hugetlb-pmd_huge-returns-true-for-non-present-hugepage.patch
* mm-hugetlb-take-page-table-lock-in-follow_huge_pmd.patch
* mm-hugetlb-fix-getting-refcount-0-page-in-hugetlb_fault.patch
* mm-hugetlb-add-migration-hwpoisoned-entry-check-in-hugetlb_change_protection.patch
* mm-hugetlb-add-migration-entry-check-in-__unmap_hugepage_range.patch
* sparc32-fix-broken-set_pte.patch
* mm-numa-do-not-dereference-pmd-outside-of-the-lock-during-numa-hinting-fault.patch
* mm-add-p-protnone-helpers-for-use-by-numa-balancing.patch
* mm-convert-p_numa-users-to-p_protnone_numa.patch
* ppc64-add-paranoid-warnings-for-unexpected-dsisr_protfault.patch
* mm-convert-p_mknonnuma-and-remaining-page-table-manipulations.patch
* mm-remove-remaining-references-to-numa-hinting-bits-and-helpers.patch
* mm-remove-remaining-references-to-numa-hinting-bits-and-helpers-fix.patch
* mm-numa-do-not-trap-faults-on-the-huge-zero-page.patch
* x86-mm-restore-original-pte_special-check.patch
* mm-numa-add-paranoid-check-around-pte_protnone_numa.patch
* mm-numa-avoid-unnecessary-tlb-flushes-when-setting-numa-hinting-entries.patch
* mm-set-page-pfmemalloc-in-prep_new_page.patch
* mm-page_alloc-reduce-number-of-alloc_pages-functions-parameters.patch
* mm-reduce-try_to_compact_pages-parameters.patch
* mm-microoptimize-zonelist-operations.patch
* list_lru-introduce-list_lru_shrink_countwalk.patch
* fs-consolidate-nrfree_cached_objects-args-in-shrink_control.patch
* vmscan-per-memory-cgroup-slab-shrinkers.patch
* memcg-rename-some-cache-id-related-variables.patch
* memcg-add-rwsem-to-synchronize-against-memcg_caches-arrays-relocation.patch
* list_lru-get-rid-of-active_nodes.patch
* list_lru-organize-all-list_lrus-to-list.patch
* list_lru-introduce-per-memcg-lists.patch
* fs-make-shrinker-memcg-aware.patch
* mm-page_allocc-drop-dead-destroy_compound_page.patch
* mm-more-checks-on-free_pages_prepare-for-tail-pages.patch
* mm-more-checks-on-free_pages_prepare-for-tail-pages-fix-2.patch
* vmscan-force-scan-offline-memory-cgroups.patch
* vmscan-force-scan-offline-memory-cgroups-fix.patch
* memcg-add-build_bug_on-for-string-tables.patch
* mm-use-correct-format-specifiers-when-printing-address-ranges.patch
* mm-page_counter-pull-1-handling-out-of-page_counter_memparse.patch
* mm-memcontrol-default-hierarchy-interface-for-memory.patch
* mm-memcontrol-fold-move_anon-and-move_file.patch
* mm-memcontrol-fold-move_anon-and-move_file-fix.patch
* oom-add-helpers-for-setting-and-clearing-tif_memdie.patch
* oom-thaw-the-oom-victim-if-it-is-frozen.patch
* pm-convert-printk-to-pr_-equivalent.patch
* sysrq-convert-printk-to-pr_-equivalent.patch
* oom-pm-make-oom-detection-in-the-freezer-path-raceless.patch
* mm-cma-fix-totalcma_pages-to-include-dt-defined-cma-regions.patch
* mm-memcontrol-simplify-soft-limit-tree-init-code.patch
* mm-memcontrol-consolidate-memory-controller-initialization.patch
* mm-memcontrol-consolidate-swap-controller-code.patch
* fs-shrinker-always-scan-at-least-one-object-of-each-type.patch
* fs-shrinker-always-scan-at-least-one-object-of-each-type-fix.patch
* mm-pagemap-limit-scan-to-virtual-region-being-asked.patch
* microblaze-define-__pagetable_pmd_folded.patch
* mm-make-first_user_address-unsigned-long-on-all-archs.patch
* mm-asm-generic-define-pud_shift-in-asm-generic-4level-fixuph.patch
* arm-define-__pagetable_pmd_folded-for-lpae.patch
* mm-account-pmd-page-tables-to-the-process.patch
* mm-account-pmd-page-tables-to-the-process-fix.patch
* mm-account-pmd-page-tables-to-the-process-fix-2.patch
* mm-fix-false-positive-warning-on-exit-due-mm_nr_pmdsmm.patch
* mm-fix-false-positive-warning-on-exit-due-mm_nr_pmdsmm-fix.patch
* page_writeback-put-account_page_redirty-after-set_page_dirty.patch
* mm-compaction-change-tracepoint-format-from-decimal-to-hexadecimal.patch
* mm-compaction-enhance-tracepoint-output-for-compaction-begin-end.patch
* mm-compaction-enhance-tracepoint-output-for-compaction-begin-end-v4.patch
* mm-compaction-enhance-tracepoint-output-for-compaction-begin-end-v4-fix.patch
* mm-compaction-print-current-range-where-compaction-work.patch
* mm-compaction-more-trace-to-understand-when-why-compaction-start-finish.patch
* mm-compaction-add-tracepoint-to-observe-behaviour-of-compaction-defer.patch
* mm-compaction-add-tracepoint-to-observe-behaviour-of-compaction-defer-v4.patch
* mm-vmscan-fix-the-page-state-calculation-in-too_many_isolated.patch
* mm-vmscan-fix-the-page-state-calculation-in-too_many_isolated-fix.patch
* mm-thp-allocate-transparent-hugepages-on-local-node.patch
* mm-thp-allocate-transparent-hugepages-on-local-node-fix.patch
* mm-mempolicy-merge-alloc_hugepage_vma-to-alloc_pages_vma.patch
* mm-gup-add-get_user_pages_locked-and-get_user_pages_unlocked.patch
* mm-gup-add-__get_user_pages_unlocked-to-customize-gup_flags.patch
* mm-gup-use-get_user_pages_unlocked-within-get_user_pages_fast.patch
* mm-gup-use-get_user_pages_unlocked.patch
* mm-gup-kvm-use-get_user_pages_unlocked.patch
* proc-pagemap-walk-page-tables-under-pte-lock.patch
* mm-pagewalk-remove-pgd_entry-and-pud_entry.patch
* pagewalk-improve-vma-handling.patch
* pagewalk-add-walk_page_vma.patch
* smaps-remove-mem_size_stats-vma-and-use-walk_page_vma.patch
* clear_refs-remove-clear_refs_private-vma-and-introduce-clear_refs_test_walk.patch
* pagemap-use-walk-vma-instead-of-calling-find_vma.patch
* numa_maps-fix-typo-in-gather_hugetbl_stats.patch
* numa_maps-remove-numa_maps-vma.patch
* memcg-cleanup-preparation-for-page-table-walk.patch
* arch-powerpc-mm-subpage-protc-use-walk-vma-and-walk_page_vma.patch
* mempolicy-apply-page-table-walker-on-queue_pages_range.patch
* mm-pagewalk-fix-misbehavior-of-walk_page_range-for-vmavm_pfnmap-re-pagewalk-improve-vma-handling.patch
* mm-proc-pid-clear_refs-avoid-split_huge_page.patch
* mincore-apply-page-table-walker-on-do_mincore.patch
* mincore-apply-page-table-walker-on-do_mincore-fix.patch
* mincore-apply-page-table-walker-on-do_mincore-fix-fix.patch
* slab-embed-memcg_cache_params-to-kmem_cache.patch
* slab-embed-memcg_cache_params-to-kmem_cache-fix.patch
* slab-link-memcg-caches-of-the-same-kind-into-a-list.patch
* slab-link-memcg-caches-of-the-same-kind-into-a-list-fix.patch
* cgroup-release-css-id-after-css_free.patch
* slab-use-css-id-for-naming-per-memcg-caches.patch
* memcg-free-memcg_caches-slot-on-css-offline.patch
* list_lru-add-helpers-to-isolate-items.patch
* memcg-reparent-list_lrus-and-free-kmemcg_id-on-css-offline.patch
* slub-never-fail-to-shrink-cache.patch
* slub-fix-kmem_cache_shrink-return-value.patch
* slub-make-dead-caches-discard-free-slabs-immediately.patch
* mm-when-stealing-freepages-also-take-pages-created-by-splitting-buddy-page.patch
* mm-always-steal-split-buddies-in-fallback-allocations.patch
* mm-more-aggressive-page-stealing-for-unmovable-allocations.patch
* vmstat-do-not-use-deferrable-delayed-work-for-vmstat_update.patch
* mm-incorporate-read-only-pages-into-transparent-huge-pages.patch
* mm-incorporate-read-only-pages-into-transparent-huge-pages-v4.patch
* docs-procs-describe-proc-pid-map_files-entry.patch
* docs-procs-describe-proc-pid-map_files-entry-fix.patch
* mm-page_ext-remove-unnecessary-stack_trace-field.patch
* mm-page_ext-remove-unnecessary-stack_trace-field-fix.patch
* vmstat-reduce-time-interval-to-stat-update-on-idle-cpu.patch
* mm-fix-arithmetic-overflow-in-__vm_enough_memory.patch
* mm-fix-arithmetic-overflow-in-__vm_enough_memory-fix.patch
* mm-nommuc-fix-arithmetic-overflow-in-__vm_enough_memory.patch
* mm-compaction-fix-wrong-order-check-in-compact_finished.patch
* mm-compaction-stop-the-isolation-when-we-isolate-enough-freepage.patch
* memcg-cleanup-static-keys-decrement.patch
* mm-do-not-use-mm-nr_pmds-on-mmu-configurations.patch
* mm-page_isolation-check-pfn-validity-before-access.patch
* mm-fix-invalid-use-of-pfn_valid_within-in-test_pages_in_a_zone.patch
* fs-mpagec-forgotten-write_sync-in-case-of-data-integrity-write.patch
* mm-support-madvisemadv_free.patch
* mm-support-madvisemadv_free-fix.patch
* x86-add-pmd_-for-thp.patch
* x86-add-pmd_-for-thp-fix.patch
* sparc-add-pmd_-for-thp.patch
* sparc-add-pmd_-for-thp-fix.patch
* powerpc-add-pmd_-for-thp.patch
* arm-add-pmd_mkclean-for-thp.patch
* arm64-add-pmd_-for-thp.patch
* mm-dont-split-thp-page-when-syscall-is-called.patch
* mm-dont-split-thp-page-when-syscall-is-called-fix.patch
* mm-dont-split-thp-page-when-syscall-is-called-fix-2.patch
* zram-clean-up-zram_meta_alloc.patch
* zram-free-meta-table-in-zram_meta_free.patch
* zram-fix-umount-reset_store-mount-race-condition.patch
* zram-rework-reset-and-destroy-path.patch
* zram-rework-reset-and-destroy-path-fix.patch
* zram-check-bd_openers-instead-bd_holders.patch
* mm-zpool-add-name-argument-to-create-zpool.patch
* mm-zsmalloc-add-statistics-support.patch
* arch-frv-mm-extablec-remove-unused-function.patch
* task_mmu-add-user-space-support-for-resetting-mm-hiwater_rss-peak-rss.patch
* fs-proc-use-the-pde-to-to-get-proc_dir_entry.patch
* documentation-proc-add-proc-pid-numa_maps-interface-explanation-snippet.patch
* fs-proc-task_mmu-show-page-size-in-proc-pid-numa_maps.patch
* fs-proc-task_mmu-show-page-size-in-proc-pid-numa_maps-fix.patch
* fs-proc-arrayc-convert-to-use-string_escape_str.patch
* all-arches-signal-move-restart_block-to-struct-task_struct.patch
* all-arches-signal-move-restart_block-to-struct-task_struct-fix.patch
* gitignore-ignore-tar-install-build-directory.patch
* linux-typesh-always-use-unsigned-long-for-pgoff_t.patch
* add-another-clock-for-use-with-the-soft-lockup-watchdog.patch
* powerpc-add-running_clock-for-powerpc-to-prevent-spurious-softlockup-warnings.patch
* powerpc-add-running_clock-for-powerpc-to-prevent-spurious-softlockup-warnings-checkpatch-fixes.patch
* printk-correct-timeout-comment-neaten-module_parm_desc.patch
* lib-vsprintfc-consume-p-in-format_decode.patch
* lib-vsprintfc-improve-sanity-check-in-vsnprintf.patch
* lib-vsprintfc-replace-while-with-do-while-in-skip_atoi.patch
* lib-vsprintf-add-%pt-format-specifier.patch
* lib-string_get_size-remove-redundant-prefixes.patch
* lib-string_get_size-use-32-bit-arithmetic-when-possible.patch
* lib-string_get_size-return-void.patch
* lib-bitmap-more-signed-unsigned-conversions.patch
* linux-nodemaskh-update-bitmap-wrappers-to-take-unsigned-int.patch
* linux-cpumaskh-update-bitmap-wrappers-to-take-unsigned-int.patch
* lib-bitmap-update-bitmap_onto-to-unsigned.patch
* lib-bitmap-update-bitmap_onto-to-unsigned-checkpatch-fixes.patch
* lib-bitmap-change-parameters-of-bitmap_fold-to-unsigned.patch
* lib-bitmap-change-parameters-of-bitmap_fold-to-unsigned-fix.patch
* lib-bitmap-simplify-bitmap_pos_to_ord.patch
* lib-bitmap-simplify-bitmap_ord_to_pos.patch
* lib-bitmap-make-the-bits-parameter-of-bitmap_remap-unsigned.patch
* lib-remove-strnicmp.patch
* lib-genallocc-fix-the-end-addr-check-in-addr_in_gen_pool.patch
* hexdump-introduce-test-suite.patch
* hexdump-fix-ascii-column-for-the-tail-of-a-dump.patch
* hexdump-do-few-calculations-ahead.patch
* hexdump-makes-it-return-amount-of-bytes-placed-in-buffer.patch
* hexdump-makes-it-return-amount-of-bytes-placed-in-buffer-fix.patch
* lib-interval_treec-simplify-includes.patch
* lib-sortc-use-simpler-includes.patch
* lib-dynamic_queue_limitsc-simplify-includes.patch
* lib-halfmd4c-simplify-includes.patch
* lib-idrc-remove-redundant-include.patch
* lib-genallocc-remove-redundant-include.patch
* lib-list_sortc-rearrange-includes.patch
* lib-md5c-simplify-include.patch
* lib-llistc-remove-redundant-include.patch
* lib-kobject_ueventc-remove-redundant-include.patch
* lib-nlattrc-remove-redundant-include.patch
* lib-plistc-remove-redundant-include.patch
* lib-radix-treec-change-to-simpler-include.patch
* lib-show_memc-remove-redundant-include.patch
* lib-sortc-move-include-inside-if-0.patch
* lib-stmp_devicec-replace-moduleh-include.patch
* lib-strncpy_from_userc-replace-moduleh-include.patch
* lib-percpu_idac-remove-redundant-includes.patch
* lib-lcmc-replace-include.patch
* lib-bitmapc-change-prototype-of-bitmap_copy_le.patch
* lib-bitmapc-elide-bitmap_copy_le-on-little-endian.patch
* lib-bitmap-change-bitmap_shift_right-to-take-unsigned-parameters.patch
* lib-bitmap-eliminate-branch-in-__bitmap_shift_right.patch
* lib-bitmap-remove-redundant-code-from-__bitmap_shift_right.patch
* lib-bitmap-yet-another-simplification-in-__bitmap_shift_right.patch
* lib-bitmap-change-bitmap_shift_left-to-take-unsigned-parameters.patch
* lib-bitmap-eliminate-branch-in-__bitmap_shift_left.patch
* lib-bitmap-remove-redundant-code-from-__bitmap_shift_left.patch
* lib-crc32-constify-crc32-lookup-table.patch
* mm-util-add-kstrdup_const.patch
* kernfs-convert-node-name-allocation-to-kstrdup_const.patch
* kernfs-remove-kernfs_static_name.patch
* clk-convert-clock-name-allocations-to-kstrdup_const.patch
* mm-slab-convert-cache-name-allocations-to-kstrdup_const.patch
* mm-slab-convert-cache-name-allocations-to-kstrdup_const-fix.patch
* fs-namespace-convert-devname-allocation-to-kstrdup_const.patch
* lib-stringc-improve-strrchr.patch
* genalloc-check-result-of-devres_alloc.patch
* cpumask-always-use-nr_cpu_ids-in-formatting-and-parsing-functions.patch
* lib-vsprintf-implement-bitmap-printing-through-%pb.patch
* cpumask-nodemask-implement-cpumask-nodemask_pr_args.patch
* bitmap-use-%pb-to-print-bitmaps-including-cpumasks-and-nodemasks.patch
* mips-use-%pb-to-print-bitmaps-including-cpumasks-and-nodemasks.patch
* powerpc-use-%pb-to-print-bitmaps-including-cpumasks-and-nodemasks.patch
* tile-use-%pb-to-print-bitmaps-including-cpumasks-and-nodemasks.patch
* x86-use-%pb-to-print-bitmaps-including-cpumasks-and-nodemasks.patch
* ia64-use-%pb-to-print-bitmaps-including-cpumasks-and-nodemasks.patch
* xtensa-use-%pb-to-print-bitmaps-including-cpumasks-and-nodemasks.patch
* arm-use-%pb-to-print-bitmaps-including-cpumasks-and-nodemasks.patch
* cpuset-use-%pb-to-print-bitmaps-including-cpumasks-and-nodemasks.patch
* rcu-use-%pb-to-print-bitmaps-including-cpumasks-and-nodemasks.patch
* sched-use-%pb-to-print-bitmaps-including-cpumasks-and-nodemasks.patch
* time-use-%pb-to-print-bitmaps-including-cpumasks-and-nodemasks.patch
* percpu-use-%pb-to-print-bitmaps-including-cpumasks-and-nodemasks.patch
* workqueue-use-%pb-to-format-bitmaps-including-cpumasks-and-nodemasks.patch
* tracing-use-%pb-to-print-bitmaps-including-cpumasks-and-nodemasks.patch
* net-use-%pb-to-print-bitmaps-including-cpumasks-and-nodemasks.patch
* wireless-use-%pb-to-print-bitmaps-including-cpumasks-and-nodemasks.patch
* input-use-%pb-to-print-bitmaps-including-cpumasks-and-nodemasks.patch
* scsi-use-%pb-to-print-bitmaps-including-cpumasks-and-nodemasks.patch
* usb-use-%pb-to-print-bitmaps-including-cpumasks-and-nodemasks.patch
* drivers-base-use-%pb-to-print-bitmaps-including-cpumasks-and-nodemasks.patch
* slub-use-%pb-to-print-bitmaps-including-cpumasks-and-nodemasks.patch
* mm-use-%pb-to-print-bitmaps-including-cpumasks-and-nodemasks.patch
* padata-use-%pb-to-print-bitmaps-including-cpumasks-and-nodemasks.patch
* proc-use-%pb-to-print-bitmaps-including-cpumasks-and-nodemasks.patch
* irq-use-%pb-to-print-bitmaps-including-cpumasks-and-nodemasks.patch
* profile-use-%pb-to-print-bitmaps-including-cpumasks-and-nodemasks.patch
* bitmap-cpumask-nodemask-remove-dedicated-formatting-functions.patch
* mm-utilc-add-kstrimdup.patch
* lib-add-crc64-ecma-module.patch
* checkpatch-emit-an-error-when-using-predefined-timestamp-macros.patch
* checkpatch-improve-octal-permissions-tests.patch
* checkpatch-ignore-__pure-attribute.patch
* checkpatch-fix-unnecessary_kern_level-false-positive.patch
* checkpatch-add-check-for-keyword-boolean-in-kconfig-definitions.patch
* checkpatch-allow-comments-in-macros-tested-for-single-statements.patch
* checkpatch-update-git-commit-message.patch
* checkpatch-add-likely-unlikely-comparison-misuse-test.patch
* checkpatch-add-ability-to-coalesce-commit-descriptions-on-multiple-lines.patch
* checkpatch-add-types-for-other-os-typedefs.patch
* checkpatch-add-ability-to-fix-unnecessary-blank-lines-around-braces.patch
* checkpatch-improve-seq_print-seq_puts-suggestion.patch
* checkpatch-improve-no-space-necessary-after-cast-test.patch
* checkpatch-neaten-printk_ratelimited-message-position.patch
* checkpatch-add-strict-test-for-spaces-around-arithmetic.patch
* checkpatch-make-sure-a-commit-reference-description-uses-parentheses.patch
* module_device_table-fix-some-callsites.patch
* compiler-introduce-__aliassymbol-shortcut.patch
* add-kernel-address-sanitizer-infrastructure.patch
* kasan-disable-memory-hotplug.patch
* x86_64-add-kasan-support.patch
* mm-page_alloc-add-kasan-hooks-on-alloc-and-free-paths.patch
* mm-slub-introduce-virt_to_obj-function.patch
* mm-slub-share-object_err-function.patch
* mm-slub-introduce-metadata_access_enable-metadata_access_disable.patch
* mm-slub-add-kernel-address-sanitizer-support-for-slub-allocator.patch
* fs-dcache-manually-unpoison-dname-after-allocation-to-shut-up-kasans-reports.patch
* kmemleak-disable-kasan-instrumentation-for-kmemleak.patch
* lib-add-kasan-test-module.patch
* x86_64-kasan-add-interceptors-for-memset-memmove-memcpy-functions.patch
* kasan-enable-stack-instrumentation.patch
* mm-vmalloc-add-flag-preventing-guard-hole-allocation.patch
* mm-vmalloc-pass-additional-vm_flags-to-__vmalloc_node_range.patch
* kernel-add-support-for-init_array-constructors.patch
* module-fix-types-of-device-tables-aliases.patch
* kasan-enable-instrumentation-of-global-variables.patch
* init-remove-config_init_fallback.patch
* rtc-rtc-pfc2123-add-support-for-devicetree.patch
* drivers-rtc-interfacec-check-the-error-after-__rtc_read_time.patch
* rtc-rtc-isl12057-add-alarm-support-to-intersil-isl12057-rtc-driver.patch
* rtc-rtc-isl12057-add-alarm-support-to-intersil-isl12057-rtc-driver-update.patch
* rtc-rtc-isl12057-add-isilirq2-can-wakeup-machine-property-for-in-tree-users.patch
* arm-mvebu-isl12057-rtc-chip-can-now-wake-up-rn102-rn102-and-rn2120.patch
* rtc-imx-dryice-trivial-clean-up-code.patch
* rtc-imx-dryice-add-more-known-register-bits.patch
* rtc-at91sam9-constify-struct-regmap_config.patch
* rtc-isl12057-constify-struct-regmap_config.patch
* rtc-rk808-fix-the-rtc-time-reading-issue.patch
* rtc-rk808-fix-the-rtc-time-reading-issue-fix.patch
* of-add-vendor-prefix-for-abracon-corporation.patch
* rtc-add-support-for-abracon-ab-rtcmc-32768khz-b5ze-s3-i2c-rtc-chip.patch
* rtc-add-support-for-abracon-ab-rtcmc-32768khz-b5ze-s3-i2c-rtc-chip-v2.patch
* rtc-rtc-ab-b5ze-s3-add-sub-minute-alarm-support.patch
* rtc-restore-alarm-after-resume.patch
* fs-befs-linuxvfsc-remove-unnecessary-casting.patch
* fs-befs-linuxvfsc-remove-unnecessary-casting-fix.patch
* fs-coda-dirc-forward-declaration-clean-up.patch
* fs-ufs-superc-remove-unnecessary-casting.patch
* fs-ufs-superc-fix-potential-race-condition.patch
* fs-reiserfs-inodec-replace-0-by-null-for-pointers.patch
* fs-fat-use-msdos_sb-macro-to-get-msdos_sb_info.patch
* fat-add-fat_fallocate-operation.patch
* fat-skip-cluster-allocation-on-fallocated-region.patch
* fat-permit-to-return-phy-block-number-by-fibmap-in-fallocated-region.patch
* documentation-filesystems-vfattxt-update-the-limitation-for-fat-fallocate.patch
* ptrace-remove-linux-compath-inclusion-under-config_compat.patch
* signal-use-current-state-helpers.patch
* kexec-remove-never-used-member-destination-in-kimage.patch
* kexec-fix-a-typo-in-comment.patch
* kexec-fix-make-headers_check.patch
* kexec-simplify-conditional.patch
* kexec-add-bit-definitions-for-kimage-entry-flags.patch
* kexec-add-ind_flags-macro.patch
* vmcore-fix-pt_note-n_namesz-n_descsz-overflow-issue.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* rbtree-fix-typo-in-comment.patch
* eventfd-dont-take-the-spinlock-in-eventfd_poll.patch
* eventfd-dont-take-the-spinlock-in-eventfd_poll-fix.patch
* eventfd-dont-take-the-spinlock-in-eventfd_poll-fix-2.patch
* fs-affs-fix-casting-in-printed-messages.patch
* fs-affs-filec-replace-if-bug-by-bug_on.patch
* fs-affs-filec-fix-direct-io-writes-beyond-eof.patch
* fs-affs-superc-destroy-sbi-mutex-in-affs_kill_sb.patch
* debug-prevent-entering-debug-mode-on-panic-exception.patch
* scripts-gdb-add-infrastructure.patch
* scripts-gdb-add-cache-for-type-objects.patch
* scripts-gdb-add-container_of-helper-and-convenience-function.patch
* scripts-gdb-add-module-iteration-class.patch
* scripts-gdb-add-lx-symbols-command.patch
* module-do-not-inline-do_init_module.patch
* scripts-gdb-add-automatic-symbol-reloading-on-module-insertion.patch
* scripts-gdb-add-internal-helper-and-convenience-function-to-look-up-a-module.patch
* scripts-gdb-add-get_target_endianness-helper.patch
* scripts-gdb-add-read_u16-32-64-helpers.patch
* scripts-gdb-add-lx-dmesg-command.patch
* scripts-gdb-add-task-iteration-class.patch
* scripts-gdb-add-helper-and-convenience-function-to-look-up-tasks.patch
* scripts-gdb-add-is_target_arch-helper.patch
* scripts-gdb-add-internal-helper-and-convenience-function-to-retrieve-thread_info.patch
* scripts-gdb-add-get_gdbserver_type-helper.patch
* scripts-gdb-add-internal-helper-and-convenience-function-for-per-cpu-lookup.patch
* scripts-gdb-add-lx_current-convenience-function.patch
* scripts-gdb-add-class-to-iterate-over-cpu-masks.patch
* scripts-gdb-add-lx-lsmod-command.patch
* scripts-gdb-add-basic-documentation.patch
* scripts-gdb-port-to-python3-gdb77.patch
* scripts-gdb-ignore-byte-compiled-python-files.patch
* scripts-gdb-use-a-generator-instead-of-iterator-for-task-list.patch
* scripts-gdb-convert-modulelist-to-generator-function.patch
* scripts-gdb-convert-cpulist-to-generator-function.patch
* scripts-gdb-define-maintainer.patch
* scripts-gdb-disable-pagination-while-printing-from-breakpoint-handler.patch
* ipcsem-use-current-state-helpers.patch
* samples-seccomp-improve-label-helper.patch
* samples-seccomp-improve-label-helper-fix.patch
  linux-next.patch
  linux-next-rejects.patch
* rtc-isl12022-deprecate-use-of-isl-in-compatible-string-for-isil.patch
* rtc-isl12057-deprecate-use-of-isl-in-compatible-string-for-isil.patch
* staging-iio-isl29028-deprecate-use-of-isl-in-compatible-string-for-isil.patch
* arm-dts-zynq-update-isl9305-compatible-string-to-use-isil-vendor-prefix.patch
* mm-fix-xip-fault-vs-truncate-race.patch
* mm-fix-xip-fault-vs-truncate-race-fix.patch
* mm-fix-xip-fault-vs-truncate-race-fix-fix.patch
* mm-allow-page-fault-handlers-to-perform-the-cow.patch
* mm-allow-page-fault-handlers-to-perform-the-cow-fix.patch
* mm-allow-page-fault-handlers-to-perform-the-cow-fix-fix-3.patch
* mm-allow-page-fault-handlers-to-perform-the-cow-fix-fix.patch
* vfsext2-introduce-is_daxinode.patch
* daxext2-replace-xip-read-and-write-with-dax-i-o.patch
* daxext2-replace-ext2_clear_xip_target-with-dax_clear_blocks.patch
* daxext2-replace-the-xip-page-fault-handler-with-the-dax-page-fault-handler.patch
* daxext2-replace-the-xip-page-fault-handler-with-the-dax-page-fault-handler-fix.patch
* daxext2-replace-the-xip-page-fault-handler-with-the-dax-page-fault-handler-fix-2.patch
* daxext2-replace-the-xip-page-fault-handler-with-the-dax-page-fault-handler-fix-3.patch
* daxext2-replace-xip_truncate_page-with-dax_truncate_page.patch
* dax-replace-xip-documentation-with-dax-documentation.patch
* vfs-remove-get_xip_mem.patch
* ext2-remove-ext2_xip_verify_sb.patch
* ext2-remove-ext2_use_xip.patch
* ext2-remove-xipc-and-xiph.patch
* vfsext2-remove-config_ext2_fs_xip-and-rename-config_fs_xip-to-config_fs_dax.patch
* ext2-remove-ext2_aops_xip.patch
* ext2-get-rid-of-most-mentions-of-xip-in-ext2.patch
* dax-add-dax_zero_page_range.patch
* dax-add-dax_zero_page_range-fix.patch
* ext4-add-dax-functionality.patch
* ext4-add-dax-functionality-fix.patch
* brd-rename-xip-to-dax.patch
* maintainers-fixed-spelling-mistake-removed-trailing-ws.patch
* ocfs2-prepare-some-interfaces-used-in-append-direct-io.patch
* ocfs2-add-functions-to-add-and-remove-inode-in-orphan-dir.patch
* ocfs2-add-functions-to-add-and-remove-inode-in-orphan-dir-fix.patch
* ocfs2-add-orphan-recovery-types-in-ocfs2_recover_orphans.patch
* ocfs2-implement-ocfs2_direct_io_write.patch
* ocfs2-implement-ocfs2_direct_io_write-fix.patch
* ocfs2-allocate-blocks-in-ocfs2_direct_io_get_blocks.patch
* ocfs2-do-not-fallback-to-buffer-i-o-write-if-appending.patch
* ocfs2-complete-the-rest-request-through-buffer-io.patch
* ocfs2-wait-for-orphan-recovery-first-once-append-o_direct-write-crash.patch
* ocfs2-set-append-dio-as-a-ro-compat-feature.patch
* ocfs2-use-64bit-variables-to-track-heartbeat-time.patch
* powerpc-drop-_page_file-and-pte_file-related-helpers.patch
* lib-kconfig-fix-up-have_arch_bitreverse-help-text.patch
* lib-kconfig-use-bool-instead-of-boolean.patch
* w1-call-put_device-if-device_register-fails.patch
* mm-add-strictlimit-knob-v2.patch
  do_shared_fault-check-that-mmap_sem-is-held.patch
  make-sure-nobodys-leaking-resources.patch
  journal_add_journal_head-debug.patch
  journal_add_journal_head-debug-fix.patch
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
