Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id ABC0B6B0649
	for <linux-mm@kvack.org>; Thu, 10 May 2018 19:35:22 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e3-v6so1907042pfe.15
        for <linux-mm@kvack.org>; Thu, 10 May 2018 16:35:22 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q23-v6si1949253pfj.8.2018.05.10.16.35.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 May 2018 16:35:20 -0700 (PDT)
Date: Thu, 10 May 2018 16:35:19 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2018-05-10-16-34 uploaded
Message-ID: <20180510233519.eYStA%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org

The mm-of-the-moment snapshot 2018-05-10-16-34 has been uploaded to

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


This mmotm tree contains the following patches against 4.17-rc4:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
* maintainers-update-email-address-in-maintainers-entries.patch
* kasan-prohibit-kasanstructleak-combination.patch
* lib-avoid-soft-lockup-in-test_find_first_bit.patch
* memcg-remove-memcg_cgroup-id-from-idr-on-mem_cgroup_css_alloc-failure.patch
* ocfs2-submit-another-bio-if-current-bio-is-full.patch
* init-fix-false-positives-in-wx-checking.patch
* z3fold-fix-reclaim-lock-ups.patch
* z3fold-fix-reclaim-lock-ups-checkpatch-fixes.patch
* mm-sections-are-not-offlined-during-memory-hotremove.patch
* mm-dont-show-nr_indirectly_reclaimable-in-proc-vmstat.patch
* proc-kcore-dont-bounds-check-against-address-0.patch
* mm-migrate-fix-double-call-of-radix_tree_replace_slot.patch
* mm-oom-fix-concurrent-munlock-and-oom-reaper-unmap.patch
* ocfs2-take-inode-cluster-lock-before-moving-reflinked-inode-from-orphan-dir.patch
* scripts-faddr2line-fix-error-when-addr2line-output-contains-discriminator.patch
* rbtree-include-rcuh-because-we-use-it.patch
* mm-memory_hotplug-fix-leftover-use-of-struct-page-during-hotplug.patch
* mm-allow-deferred-page-init-for-vmemmap-only.patch
* lib-test_bitmapc-fix-bitmap-optimisation-tests-to-report-errors-correctly.patch
* include-mm-adding-new-inline-function-vmf_error.patch
* radix-tree-test-suite-fix-mapshift-build-target.patch
* radix-tree-test-suite-fix-compilation-issue.patch
* radix-tree-test-suite-add-item_delete_rcu.patch
* radix-tree-test-suite-multi-order-iteration-race.patch
* radix-tree-fix-multi-order-iteration-race.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* fs-dax-adding-new-return-type-vm_fault_t.patch
* prctl-add-pr_et_pdeathsig_proc.patch
* ocfs2-clean-up-redundant-function-declarations.patch
* ocfs2-correct-the-offset-comments-of-the-structure-ocfs2_dir_block_trailer.patch
* ocfs2-ocfs2_inode_lock_tracker-does-not-distinguish-lock-level.patch
* ocfs2-eliminate-a-misreported-warning.patch
* ocfs2-get-rid-of-ocfs2_is_o2cb_active-function.patch
* ocfs2-without-quota-support-try-to-avoid-calling-quota-recovery.patch
* ocfs2-without-quota-support-try-to-avoid-calling-quota-recovery-checkpatch-fixes.patch
* ocfs2-dont-put-and-assign-null-to-bh-allocated-outside.patch
* ocfs2-dont-use-iocb-when-eiocbqueued-returns.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* net-9p-detecting-invalid-options-as-much-as-possible.patch
* fs-9p-detecting-invalid-options-as-much-as-possible.patch
* dentry-fix-kmemcheck-splat-at-take_dentry_name_snapshot.patch
* namei-allow-restricted-o_creat-of-fifos-and-regular-files.patch
* namei-allow-restricted-o_creat-of-fifos-and-regular-files-fix.patch
  mm.patch
* slab-__gfp_zero-is-incompatible-with-a-constructor.patch
* mm-slubc-add-__printf-verification-to-slab_err.patch
* mm-slub-remove-impertinent-comment.patch
* mm-introduce-arg_lock-to-protect-arg_startend-and-env_startend-in-mm_struct.patch
* mm-introduce-arg_lock-to-protect-arg_startend-and-env_startend-in-mm_struct-fix.patch
* mm-memcontrol-move-swap-charge-handling-into-get_swap_page.patch
* mm-memcontrol-implement-memoryswapevents.patch
* zram-correct-flag-name-of-zram_access.patch
* zram-mark-incompressible-page-as-zram_huge.patch
* zram-record-accessed-second.patch
* zram-introduce-zram-memory-tracking.patch
* zram-introduce-zram-memory-tracking-fix.patch
* zram-introduce-zram-memory-tracking-update.patch
* zram-introduce-zram-memory-tracking-update-fix.patch
* zram-introduce-zram-memory-tracking-update-fix-fix.patch
* zram-introduce-zram-memory-tracking-update-fix-fix-fix.patch
* mm-shmem-add-__rcu-annotations-and-properly-deref-radix-entry.patch
* mm-shmem-update-file-sealing-comments-and-file-checking.patch
* mm-restructure-memfd-code.patch
* mm-page_alloc-remove-realsize-in-free_area_init_core.patch
* mm-introduce-arch_has_pte_special.patch
* mm-remove-odd-have_pte_special.patch
* mm-check-for-sigkill-inside-dup_mmap-loop.patch
* mm-check-for-sigkill-inside-dup_mmap-loop-fix.patch
* mm-memcg-remote-memcg-charging-for-kmem-allocations.patch
* fs-fsnotify-account-fsnotify-metadata-to-kmemcg.patch
* mm-memblock-introduce-phys_addr_max.patch
* mm-rename-page_counters-count-limit-into-usage-max.patch
* mm-memorylow-hierarchical-behavior.patch
* mm-treat-memorylow-value-inclusive.patch
* mm-docs-describe-memorylow-refinements.patch
* mm-gup-prevent-pmd-checking-race-in-follow_pmd_mask.patch
* mm-sparse-check-__highest_present_section_nr-only-for-a-present-section.patch
* mm-sparse-pass-the-__highest_present_section_nr-1-to-alloc_func.patch
* mm-vmalloc-clean-up-vunmap-to-avoid-pgtable-ops-twice.patch
* mm-vmalloc-clean-up-vunmap-to-avoid-pgtable-ops-twice-v3.patch
* mm-vmalloc-avoid-racy-handling-of-debugobjects-in-vunmap.patch
* mm-vmalloc-pass-proper-vm_start-into-debugobjects.patch
* mm-vmalloc-pass-proper-vm_start-into-debugobjects-fix.patch
* mm-shmem-make-statst_blksize-return-huge-page-size-if-thp-is-on.patch
* mm-shmem-make-statst_blksize-return-huge-page-size-if-thp-is-on-fix.patch
* lockdep-fix-fs_reclaim-annotation.patch
* mm-ksm-remove-unused-page_referenced_ksm-declaration.patch
* mm-ksm-move-page_stable_node-from-ksmh-to-ksmc.patch
* mm-ksm-move-page_stable_node-from-ksmh-to-ksmc-fix.patch
* tmpfs-allow-decoding-a-file-handle-of-an-unlinked-file.patch
* memcg-writeback-use-memcg-cgwb_list-directly.patch
* memcg-replace-mm-owner-with-mm-memcg.patch
* memcg-replace-mm-owner-with-mm-memcg-fix.patch
* memcg-replace-mm-owner-with-mm-memcg-fix-2.patch
* mm-memcontrolc-add-mem_cgroup_from_task-as-a-local-helper.patch
* memcg-mark-memcg1_events-static-const.patch
* mm-memcontrol-drain-stocks-on-resize-limit.patch
* mm-memcontrol-drain-memcg-stock-on-force_empty.patch
* mm-memblock-print-memblock_remove.patch
* mm-pagemap-hide-swap-entry-for-unprivileged-users.patch
* mm-move-is_pageblock_removable_nolock-to-mm-memory_hotplugc.patch
* mm-introduce-memorymin.patch
* mm-introduce-memorymin-fix.patch
* mm-ksm-ignore-stable_flag-of-rmap_item-address-in-rmap_walk_ksm.patch
* mm-vmpressure-use-kstrndup-instead-of-kmallocstrncpy.patch
* mm-vmpressure-convert-to-use-match_string-helper.patch
* mm-page_allocc-remove-useless-parameter-of-finalise_ac.patch
* mm-sparse-add-a-static-variable-nr_present_sections.patch
* mm-sparsemem-defer-the-ms-section_mem_map-clearing.patch
* mm-sparse-add-a-new-parameter-data_unit_size-for-alloc_usemap_and_memmap.patch
* mm-swap-fix-race-between-swapoff-and-some-swap-operations.patch
* mm-swap-fix-race-between-swapoff-and-some-swap-operations-v6.patch
* mm-fix-race-between-swapoff-and-mincore.patch
* list_lru-prefetch-neighboring-list-entries-before-acquiring-lock.patch
* list_lru-prefetch-neighboring-list-entries-before-acquiring-lock-fix.patch
* mm-oom-refactor-the-oom_kill_process-function.patch
* mm-implement-mem_cgroup_scan_tasks-for-the-root-memory-cgroup.patch
* mm-oom-cgroup-aware-oom-killer.patch
* mm-oom-cgroup-aware-oom-killer-fix.patch
* mm-oom-cgroup-aware-oom-killer-fix-2.patch
* mm-oom-introduce-memoryoom_group.patch
* mm-oom-introduce-memoryoom_group-fix.patch
* mm-oom-add-cgroup-v2-mount-option-for-cgroup-aware-oom-killer.patch
* mm-oom-docs-describe-the-cgroup-aware-oom-killer.patch
* mm-oom-docs-describe-the-cgroup-aware-oom-killer-fix.patch
* mm-oom-docs-describe-the-cgroup-aware-oom-killer-fix-2.patch
* mm-oom-docs-describe-the-cgroup-aware-oom-killer-fix-2-fix.patch
* mm-oom-cgroup-aware-oom-killer-fix-fix.patch
* cgroup-list-groupoom-in-cgroup-features.patch
* mm-add-strictlimit-knob-v2.patch
* mm-dont-expose-page-to-fast-gup-before-its-ready.patch
* mm-page_owner-align-with-pageblock_nr_pages.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* mm-kasan-dont-vfree-nonexistent-vm_area.patch
* proc-more-unsigned-int-in-proc-cmdline.patch
* proc-somewhat-simpler-code-for-proc-cmdline.patch
* proc-simpler-iterations-for-proc-cmdline.patch
* proc-simpler-iterations-for-proc-cmdline-fix.patch
* proc-deduplicate-proc-cmdline-implementation.patch
* proc-smaller-rcu-section-in-getattr.patch
* proc-use-unsigned-int-in-proc_fill_cache.patch
* proc-skip-branch-in-proc-lookup.patch
* proc-use-unsigned-int-for-sigqueue-length.patch
* proc-use-unsigned-int-for-proc-stack.patch
* proc-test-proc-fd-a-bit-pf_kthread-is-abi.patch
* locking-hung_task-show-all-hung-tasks-before-panic.patch
* lib-micro-optimization-for-__bitmap_complement.patch
* ida-remove-simple_ida_lock.patch
* ida-remove-simple_ida_lock-fix.patch
* percpu_ida-use-_irqsave-instead-of-local_irq_save-spin_lock.patch
* checkpatch-add-a-strict-test-for-structs-with-bool-member-definitions.patch
* coredump-fix-spam-with-zero-vma-process.patch
* seq_file-delete-small-value-optimization.patch
* exofs-avoid-vla-in-structures.patch
* exofs-avoid-vla-in-structures-v2.patch
* bfs-add-sanity-check-at-bfs_fill_super.patch
* kernel-relay-change-return-type-to-vm_fault_t.patch
* kcov-ensure-irq-code-sees-a-valid-area.patch
* kcov-prefault-the-kcov_area.patch
* kcov-prefault-the-kcov_area-fix.patch
* kcov-prefault-the-kcov_area-fix-fix.patch
* kcov-prefault-the-kcov_area-fix-fix-fix.patch
* sched-core-kcov-avoid-kcov_area-during-task-switch.patch
* fault-injection-reorder-config-entries.patch
* ipc-sem-mitigate-semnum-index-against-spectre-v1.patch
* revert-ipc-shm-fix-shmat-mmap-nil-page-protection.patch
* ipc-shm-fix-shmat-nil-address-after-round-down-when-remapping.patch
  linux-next.patch
  linux-next-rejects.patch
* mm-use-octal-not-symbolic-permissions.patch
* treewide-use-phys_addr_max-to-avoid-type-casting-ullong_max.patch
* mm-fix-oom_kill-event-handling.patch
* resource-add-walk_system_ram_res_rev.patch
* kexec_file-load-kernel-at-top-of-system-ram-if-required.patch
* fix-read-buffer-overflow-in-delta-ipc.patch
* sparc64-ng4-memset-32-bits-overflow.patch
  make-sure-nobodys-leaking-resources.patch
  releasing-resources-with-children.patch
  mutex-subsystem-synchro-test-module.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  slab-leaks3-default-y.patch
  workaround-for-a-pci-restoring-bug.patch
