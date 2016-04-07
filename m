Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 4E0B46B007E
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 23:41:09 -0400 (EDT)
Received: by mail-pf0-f182.google.com with SMTP id e128so46769501pfe.3
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 20:41:09 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b27si8696780pfj.77.2016.04.06.20.41.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 20:41:08 -0700 (PDT)
Date: Wed, 06 Apr 2016 20:41:07 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2016-04-06-20-40 uploaded
Message-ID: <5705d6d3.Ix5Gp7ywNKWu24Dh%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2016-04-06-20-40 has been uploaded to

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


This mmotm tree contains the following patches against 4.6-rc2:
(patches marked "*" will be included in linux-next)

  origin.patch
* ksm-introduce-ksm_max_page_sharing-per-page-deduplication-limit.patch
  i-need-old-gcc.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
* kexec-update-vmcoreinfo-for-compound_order-dtor.patch
* kexec-export-offsetpagecompound_head-to-find-out-compound-tail-page.patch
* mm-exclude-hugetlb-pages-from-thp-page_mapped-logic.patch
* thp-keep-huge-zero-page-pinned-until-tlb-flush.patch
* mailmap-fix-krzysztof-kozlowskis-misspelled-name.patch
* mm-huge_memory-replace-vm_no_thp-vm_bug_on-with-actual-vma-check.patch
* numa-fix-proc-pid-numa_maps-for-thp.patch
* mm-vmscan-reclaim-highmem-zone-if-buffer_heads-is-over-limit.patch
* mm-call-swap_slot_free_notify-with-holding-page-lock.patch
* mm-hwpoison-fix-wrong-num_poisoned_pages-account.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* fs-ext4-fsyncc-generic_file_fsync-call-based-on-barrier-flag.patch
* ocfs2-error-code-comments-and-amendments-the-comment-of-ocfs2_extended_slot-should-be-0x08.patch
* ocfs2-clean-up-an-unused-variable-wants_rotate-in-ocfs2_truncate_rec.patch
* ocfs2-o2hb-add-negotiate-timer.patch
* ocfs2-o2hb-add-negotiate-timer-v2.patch
* ocfs2-o2hb-add-nego_timeout-message.patch
* ocfs2-o2hb-add-nego_timeout-message-v2.patch
* ocfs2-o2hb-add-negotiate_approve-message.patch
* ocfs2-o2hb-add-negotiate_approve-message-v2.patch
* ocfs2-o2hb-add-some-user-debug-log.patch
* ocfs2-o2hb-add-some-user-debug-log-v2.patch
* ocfs2-o2hb-dont-negotiate-if-last-hb-fail.patch
* ocfs2-o2hb-fix-hb-hung-time.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* padata-removed-unused-code.patch
  mm.patch
* mm-slab-hold-a-slab_mutex-when-calling-__kmem_cache_shrink.patch
* mm-slab-remove-bad_alien_magic-again.patch
* mm-slab-drain-the-free-slab-as-much-as-possible.patch
* mm-slab-factor-out-kmem_cache_node-initialization-code.patch
* mm-slab-clean-up-kmem_cache_node-setup.patch
* mm-slab-dont-keep-free-slabs-if-free_objects-exceeds-free_limit.patch
* mm-slab-racy-access-modify-the-slab-color.patch
* mm-slab-make-cache_grow-handle-the-page-allocated-on-arbitrary-node.patch
* mm-slab-separate-cache_grow-to-two-parts.patch
* mm-slab-refill-cpu-cache-through-a-new-slab-without-holding-a-node-lock.patch
* mm-slab-lockless-decision-to-grow-cache.patch
* mm-slub-replace-kick_all_cpus_sync-with-synchronize_sched-in-kmem_cache_shrink.patch
* mm-page_ref-use-page_ref-helper-instead-of-direct-modification-of-_count.patch
* mm-rename-_count-field-of-the-struct-page-to-_refcount.patch
* mm-rename-_count-field-of-the-struct-page-to-_refcount-fix.patch
* mm-rename-_count-field-of-the-struct-page-to-_refcount-fix-fix.patch
* mm-rename-_count-field-of-the-struct-page-to-_refcount-fix-fix-fix.patch
* compilerh-add-support-for-malloc-attribute.patch
* include-linux-apply-__malloc-attribute.patch
* include-linux-apply-__malloc-attribute-checkpatch-fixes.patch
* include-linux-nodemaskh-create-next_node_in-helper.patch
* include-linux-nodemaskh-create-next_node_in-helper-fix.patch
* include-linux-nodemaskh-create-next_node_in-helper-fix-fix.patch
* mm-hugetlb-optimize-minimum-size-min_size-accounting.patch
* mm-hugetlb-introduce-hugetlb_bad_size.patch
* arm64-mm-use-hugetlb_bad_size.patch
* metag-mm-use-hugetlb_bad_size.patch
* powerpc-mm-use-hugetlb_bad_size.patch
* tile-mm-use-hugetlb_bad_size.patch
* x86-mm-use-hugetlb_bad_size.patch
* mm-hugetlb-is_vm_hugetlb_page-can-be-boolean.patch
* mm-memory_hotplug-is_mem_section_removable-can-be-boolean.patch
* mm-vmalloc-is_vmalloc_addr-can-be-boolean.patch
* mm-mempolicy-vma_migratable-can-be-boolean.patch
* mm-memcontrolc-mem_cgroup_select_victim_node-clarify-comment.patch
* mm-page_alloc-remove-useless-parameter-of-__free_pages_boot_core.patch
* zsmalloc-use-first_page-rather-than-page.patch
* zsmalloc-clean-up-many-bug_on.patch
* zsmalloc-reordering-function-parameter.patch
* zsmalloc-remove-unused-pool-param-in-obj_free.patch
* mm-hugetlbc-use-first_memory_node.patch
* mm-mempolicyc-offset_il_node-document-and-clarify.patch
* mm-rmap-replace-bug_onanon_vma-degree-with-vm_warn_on.patch
* mm-compaction-wrap-calculating-first-and-last-pfn-of-pageblock.patch
* mm-compaction-reduce-spurious-pcplist-drains.patch
* mm-compaction-skip-blocks-where-isolation-fails-in-async-direct-compaction.patch
* mm-compaction-direct-freepage-allocation-for-async-direct-compaction.patch
* mm-compaction-direct-freepage-allocation-for-async-direct-compaction-checkpatch-fixes.patch
* mm-highmem-simplify-is_highmem.patch
* mm-uninline-page_mapped.patch
* mm-uninline-page_mapped-checkpatch-fixes.patch
* mm-hugetlb-add-same-zone-check-in-pfn_range_valid_gigantic.patch
* mm-memory_hotplug-add-comment-to-some-functions-related-to-memory-hotplug.patch
* mm-vmstat-add-zone-range-overlapping-check.patch
* mm-page_owner-add-zone-range-overlapping-check.patch
* power-add-zone-range-overlapping-check.patch
* mm-workingset-only-do-workingset-activations-on-reads.patch
* mm-filemap-only-do-access-activations-on-reads.patch
* mm-vmscan-reduce-size-of-inactive-file-list.patch
* mm-writeback-correct-dirty-page-calculation-for-highmem.patch
* mm-page_alloc-correct-highmem-memory-statistics.patch
* mm-highmem-make-nr_free_highpages-handles-all-highmem-zones-by-itself.patch
* mm-vmstat-make-node_page_state-handles-all-zones-by-itself.patch
* mm-mmap-kill-hook-arch_rebalance_pgtables.patch
* mm-update_lru_size-warn-and-reset-bad-lru_size.patch
* mm-update_lru_size-do-the-__mod_zone_page_state.patch
* mm-use-__setpageswapbacked-and-dont-clearpageswapbacked.patch
* tmpfs-preliminary-minor-tidyups.patch
* tmpfs-mem_cgroup-charge-fault-to-vm_mm-not-current-mm.patch
* mm-proc-sys-vm-stat_refresh-to-force-vmstat-update.patch
* huge-mm-move_huge_pmd-does-not-need-new_vma.patch
* huge-pagecache-extend-mremap-pmd-rmap-lockout-to-files.patch
* huge-pagecache-mmap_sem-is-unlocked-when-truncation-splits-pmd.patch
* arch-fix-has_transparent_hugepage.patch
* huge-tmpfs-prepare-counts-in-meminfo-vmstat-and-sysrq-m.patch
* huge-tmpfs-include-shmem-freeholes-in-available-memory.patch
* huge-tmpfs-huge=n-mount-option-and-proc-sys-vm-shmem_huge.patch
* huge-tmpfs-try-to-allocate-huge-pages-split-into-a-team.patch
* huge-tmpfs-avoid-team-pages-in-a-few-places.patch
* huge-tmpfs-shrinker-to-migrate-and-free-underused-holes.patch
* huge-tmpfs-get_unmapped_area-align-fault-supply-huge-page.patch
* huge-tmpfs-get_unmapped_area-align-fault-supply-huge-page-fix.patch
* huge-tmpfs-get_unmapped_area-align-fault-supply-huge-page-fix-fix-2.patch
* huge-tmpfs-try_to_unmap_one-use-page_check_address_transhuge.patch
* huge-tmpfs-avoid-premature-exposure-of-new-pagetable.patch
* huge-tmpfs-map-shmem-by-huge-page-pmd-or-by-page-team-ptes.patch
* huge-tmpfs-disband-split-huge-pmds-on-race-or-memory-failure.patch
* huge-tmpfs-extend-get_user_pages_fast-to-shmem-pmd.patch
* huge-tmpfs-use-unevictable-lru-with-variable-hpage_nr_pages.patch
* huge-tmpfs-fix-mlocked-meminfo-track-huge-unhuge-mlocks.patch
* huge-tmpfs-fix-mapped-meminfo-track-huge-unhuge-mappings.patch
* kvm-plumb-return-of-hva-when-resolving-page-fault.patch
* kvm-teach-kvm-to-map-page-teams-as-huge-pages.patch
* huge-tmpfs-mem_cgroup-move-charge-on-shmem-huge-pages.patch
* huge-tmpfs-mem_cgroup-shmem_pmdmapped-accounting.patch
* huge-tmpfs-mem_cgroup-shmem_hugepages-accounting.patch
* huge-tmpfs-show-page-team-flag-in-pageflags.patch
* huge-tmpfs-proc-pid-smaps-show-shmemhugepages.patch
* huge-tmpfs-recovery-framework-for-reconstituting-huge-pages.patch
* huge-tmpfs-recovery-shmem_recovery_populate-to-fill-huge-page.patch
* huge-tmpfs-recovery-shmem_recovery_remap-remap_team_by_pmd.patch
* huge-tmpfs-recovery-shmem_recovery_swapin-to-read-from-swap.patch
* huge-tmpfs-recovery-tweak-shmem_getpage_gfp-to-fill-team.patch
* huge-tmpfs-recovery-debugfs-stats-to-complete-this-phase.patch
* huge-tmpfs-recovery-page-migration-call-back-into-shmem.patch
* memory_hotplug-introduce-config_memory_hotplug_default_online.patch
* memory_hotplug-introduce-config_memory_hotplug_default_online-fix.patch
* memory_hotplug-introduce-memhp_default_state=-command-line-parameter.patch
* mm-oom-move-gfp_nofs-check-to-out_of_memory.patch
* oom-oom_reaper-try-to-reap-tasks-which-skip-regular-oom-killer-path.patch
* mm-oom_reaper-clear-tif_memdie-for-all-tasks-queued-for-oom_reaper.patch
* mm-make-optimistic-check-for-swapin-readahead.patch
* mm-make-optimistic-check-for-swapin-readahead-fix-2.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-2.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-3.patch
* mm-kasan-initial-memory-quarantine-implementation.patch
* mm-kasan-initial-memory-quarantine-implementation-v8.patch
* mm-oom-rework-oom-detection.patch
* mm-throttle-on-io-only-when-there-are-too-many-dirty-and-writeback-pages.patch
* mm-compaction-change-compact_-constants-into-enum.patch
* mm-compaction-cover-all-compaction-mode-in-compact_zone.patch
* mm-compaction-distinguish-compact_deferred-from-compact_skipped.patch
* mm-compaction-distinguish-between-full-and-partial-compact_complete.patch
* mm-compaction-update-compaction_result-ordering.patch
* mm-compaction-simplify-__alloc_pages_direct_compact-feedback-interface.patch
* mm-compaction-abstract-compaction-feedback-to-helpers.patch
* mm-oom-protect-costly-allocations-some-more.patch
* mm-consider-compaction-feedback-also-for-costly-allocation.patch
* mm-memblock-if-nr_new-is-0-just-return.patch
* mn10300-let-exit_fpu-accept-a-task.patch
* exit_thread-remove-empty-bodies.patch
* exit_thread-remove-empty-bodies-fix.patch
* exit_thread-accept-a-task-parameter-to-be-exited.patch
* exit_thread-accept-a-task-parameter-to-be-exited-checkpatch-fixes.patch
* fork-free-thread-in-copy_process-on-failure.patch
* maintainers-remove-linux-listsopenriscnet.patch
* lib-vsprintf-simplify-uuid-printing.patch
* ima-use-%pu-to-output-uuid-in-printable-format.patch
* lib-uuid-move-generate_random_uuid-to-uuidc.patch
* lib-uuid-introduce-few-more-generic-helpers-for-uuid.patch
* lib-uuid-introduce-few-more-generic-helpers-for-uuid-fix.patch
* lib-uuid-remove-fsf-address.patch
* sysctl-use-generic-uuid-library.patch
* efi-redefine-type-constant-macro-from-generic-code.patch
* efivars-use-generic-uuid-library.patch
* genhd-move-to-use-generic-uuid-library.patch
* lib-add-crc64-ecma-module.patch
* checkpatch-add-prefer_is_enabled-test.patch
* checkpatch-improve-constant_comparison-test-for-structure-members.patch
* init-mainc-simplify-initcall_blacklisted.patch
* wait-ptrace-assume-__wall-if-the-child-is-traced.patch
* wait-allow-sys_waitid-to-accept-__wnothread-__wclone-__wall.patch
* signal-make-oom_flags-a-bool.patch
* kexec-introduce-a-protection-mechanism-for-the-crashkernel-reserved-memory.patch
* kexec-provide-arch_kexec_protectunprotect_crashkres.patch
* kexec-make-a-pair-of-map-unmap-reserved-pages-in-error-path.patch
* kexec-do-a-cleanup-for-function-kexec_load.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* ipc-semc-fix-complex_count-vs-simple-op-race.patch
* ipc-msgc-msgsnd-use-freezable-blocking-call.patch
* msgrcv-use-freezable-blocking-call.patch
  linux-next.patch
  linux-next-rejects.patch
* drivers-net-wireless-intel-iwlwifi-dvm-calibc-fix-min-warning.patch
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
