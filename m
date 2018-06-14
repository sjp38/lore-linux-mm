Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0B4B76B0005
	for <linux-mm@kvack.org>; Thu, 14 Jun 2018 19:21:34 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id k13-v6so2595037pgr.11
        for <linux-mm@kvack.org>; Thu, 14 Jun 2018 16:21:34 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w17-v6si6245364plq.221.2018.06.14.16.21.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jun 2018 16:21:32 -0700 (PDT)
Date: Thu, 14 Jun 2018 16:21:30 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2018-06-14-16-20 uploaded
Message-ID: <20180614232130.2jd8c%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org

The mm-of-the-moment snapshot 2018-06-14-16-20 has been uploaded to

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


This mmotm tree contains the following patches against 4.17:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
* mm-ksm-ignore-stable_flag-of-rmap_item-address-in-rmap_walk_ksm.patch
* mm-fix-null-pointer-dereference-in-mem_cgroup_protected.patch
* mm-swap-fix-swap_count-comment-about-nonexistent-swap_has_cont.patch
* mm-fix-devmem_is_allowed-for-sub-page-system-ram-intersections.patch
* mm-fix-race-between-kmem_cache-destroy-create-and-deactivate.patch
* kexec-yield-to-scheduler-when-loading-kimage-segments.patch
* mm-check-for-sigkill-inside-dup_mmap-loop.patch
* mm-memblock-add-missing-include-linux-bootmemh.patch
* mremap-remove-latency_limit-from-mremap-to-reduce-the-number-of-tlb-shootdowns.patch
* proc-skip-branch-in-proc-lookup.patch
* fat-use-fat_fs_error-instead-of-bug_on-in-__fat_get_block.patch
* coredump-fix-spam-with-zero-vma-process.patch
* exofs-avoid-vla-in-structures.patch
* kernel-relay-change-return-type-to-vm_fault_t.patch
* kcov-ensure-irq-code-sees-a-valid-area.patch
* kcov-prefault-the-kcov_area.patch
* sched-core-kcov-avoid-kcov_area-during-task-switch.patch
* arm-port-kcov-to-arm.patch
* fault-injection-reorder-config-entries.patch
* ipc-sem-mitigate-semnum-index-against-spectre-v1.patch
* ipc-adding-new-return-type-vm_fault_t.patch
* mm-use-octal-not-symbolic-permissions.patch
* treewide-use-phys_addr_max-to-avoid-type-casting-ullong_max.patch
* mm-fix-oom_kill-event-handling.patch
* hexagon-fix-printk-format-warning-in-setupc.patch
* hexagon-drop-the-unused-variable-zero_page_mask.patch
* lib-test_printfc-call-wait_for_random_bytes-before-plain-%p-tests.patch
* memcg-remove-memcg_cgroup-id-from-idr-on-mem_cgroup_css_alloc-failure.patch
* lib-percpu_idac-dont-do-alloc-from-per-cpu-list-if-there-is-none.patch
* mm-zero-remaining-unavailable-struct-pages.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* prctl-add-pr_et_pdeathsig_proc.patch
* ocfs2-get-rid-of-ocfs2_is_o2cb_active-function.patch
* ocfs2-without-quota-support-try-to-avoid-calling-quota-recovery.patch
* ocfs2-dont-use-iocb-when-eiocbqueued-returns.patch
* ocfs2-fix-a-misuse-a-of-brelse-after-failing-ocfs2_check_dir_entry.patch
* ocfs2-dont-put-and-assigning-null-to-bh-allocated-outside.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* dentry-fix-kmemcheck-splat-at-take_dentry_name_snapshot.patch
* namei-allow-restricted-o_creat-of-fifos-and-regular-files.patch
* namei-allow-restricted-o_creat-of-fifos-and-regular-files-fix.patch
  mm.patch
* mm-devm_memremap_pages-mark-devm_memremap_pages-export_symbol_gpl.patch
* mm-devm_memremap_pages-handle-errors-allocating-final-devres-action.patch
* mm-hmm-use-devm-semantics-for-hmm_devmem_add-remove.patch
* mm-hmm-replace-hmm_devmem_pages_create-with-devm_memremap_pages.patch
* mm-hmm-mark-hmm_devmem_add-add_resource-export_symbol_gpl.patch
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
* cgroup-list-groupoom-in-cgroup-features.patch
* mm-add-strictlimit-knob-v2.patch
* mm-dont-expose-page-to-fast-gup-before-its-ready.patch
* mm-page_owner-align-with-pageblock_nr_pages.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* checkpatch-add-a-strict-test-for-structs-with-bool-member-definitions.patch
* checkpatch-add-fix-for-concatenated_string-and-string_fragments.patch
* bfs-add-sanity-check-at-bfs_fill_super.patch
  linux-next.patch
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
