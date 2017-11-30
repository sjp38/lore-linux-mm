Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id A8F126B0261
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 19:59:29 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id t92so2965344wrc.13
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 16:59:29 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p75si2120528wrc.194.2017.11.29.16.59.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 16:59:28 -0800 (PST)
Date: Wed, 29 Nov 2017 16:59:25 -0800
From: akpm@linux-foundation.org
Subject: mmotm 2017-11-29-16-58 uploaded
Message-ID: <5a1f57ed.4Rv5FrsgMTOi/6KY%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2017-11-29-16-58 has been uploaded to

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


This mmotm tree contains the following patches against 4.15-rc1:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
* mm-memory_hotplug-do-not-back-off-draining-pcp-free-pages-from-kworker-context.patch
* mm-oom_reaper-gather-each-vma-to-prevent-leaking-tlb-entry.patch
* mm-cma-fix-alloc_contig_range-ret-code-potential-leak-v2.patch
* mm-fix-device-dax-pud-write-faults-triggered-by-get_user_pages.patch
* mm-switch-to-define-pmd_write-instead-of-__have_arch_pmd_write.patch
* mm-replace-pud_write-with-pud_access_permitted-in-fault-gup-paths.patch
* mm-replace-pmd_write-with-pmd_access_permitted-in-fault-gup-paths.patch
* mm-replace-pte_write-with-pte_access_permitted-in-fault-gup-paths.patch
* scripts-faddr2line-extend-usage-on-generic-arch.patch
* mm-hugetlbfs-introduce-split-to-vm_operations_struct.patch
* device-dax-implement-split-to-catch-invalid-munmap-attempts.patch
* mm-introduce-get_user_pages_longterm.patch
* mm-fail-get_vaddr_frames-for-filesystem-dax-mappings.patch
* v4l2-disable-filesystem-dax-mapping-support.patch
* ib-core-disable-memory-registration-of-fileystem-dax-vmas.patch
* exec-avoid-rlimit_stack-races-with-prlimit.patch
* mmmadvise-bugfix-of-madvise-systemcall-infinite-loop-under-special-circumstances.patch
* revert-mm-page-writebackc-print-a-warning-if-the-vm-dirtiness-settings-are-illogical-was-re-mm-print-a-warning-once-the-vm-dirtiness-settings-is-illogical.patch
* fs-mbcache-make-count_objects-more-robust.patch
* bloat-o-meter-dont-fail-with-division-by-0.patch
* kmemleak-add-scheduling-point-to-kmemleak_scan.patch
* mm-migrate-fix-an-incorrect-call-of-prep_transhuge_page.patch
* mm-memcg-fix-mem_cgroup_swapout-for-thps.patch
* fat-fix-sb_rdonly-change.patch
* autofs-revert-take-more-care-to-not-update-last_used-on-path-walk.patch
* autofs-revert-fix-at_no_automount-not-being-honored.patch
* mm-hugetlb-fix-null-pointer-dereference-on-5-level-paging-machine.patch
* hugetlbfs-change-put_page-unlock_page-order-in-hugetlbfs_fallocate.patch
* frv-fix-build-failure.patch
* scripts-decodecode-fix-decoding-for-aarch64-arm64-instructions.patch
* mm-skip-hwpoisoned-pages-when-onlining-pages.patch
* lib-rbtreedrm-mm-add-rbtree_replace_node_cached.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* prctl-add-pr_et_pdeathsig_proc.patch
* ocfs2-dlm-clean-dead-code-up.patch
* ocfs2-get-rid-of-ocfs2_is_o2cb_active-function.patch
* ocfs2-give-an-obvious-tip-for-dismatch-cluster-names.patch
* ocfs2-give-an-obvious-tip-for-dismatch-cluster-names-v2.patch
* ocfs2-move-some-definitions-to-header-file.patch
* ocfs2-fix-some-small-problems.patch
* ocfs2-add-kobject-for-online-file-check.patch
* ocfs2-add-duplicative-ino-number-check.patch
* ocfs2-fix-qs_holds-may-could-not-be-zero.patch
* ocfs2-dlm-wait-for-dlm-recovery-done-when-migrating-all-lockres.patch
* ocfs2-add-ocfs2_try_rw_lock-and-ocfs2_try_inode_lock.patch
* ocfs2-add-ocfs2_try_rw_lock-and-ocfs2_try_inode_lock-v2.patch
* ocfs2-add-ocfs2_overwrite_io-function.patch
* ocfs2-add-ocfs2_overwrite_io-function-v2.patch
* ocfs2-nowait-aio-support.patch
* ocfs2-nowait-aio-support-v2.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* dentry-fix-kmemcheck-splat-at-take_dentry_name_snapshot.patch
  mm.patch
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
* mm-filemap-remove-include-of-hardirqh.patch
* mm-memcontrol-eliminate-raw-access-to-stat-and-event-counters.patch
* mm-memcontrol-implement-lruvec-stat-functions-on-top-of-each-other.patch
* mm-memcontrol-fix-excessive-complexity-in-memorystat-reporting.patch
* mm-swap-clean-up-swap-readahead.patch
* mm-swap-unify-cluster-based-and-vma-based-swap-readahead.patch
* mm-page_owner-use-ptr_err_or_zero.patch
* mm-page_alloc-fix-comment-is-__get_free_pages.patch
* mmoom-move-last-second-allocation-to-inside-the-oom-killer.patch
* mmoom-use-alloc_oom-for-oom-victims-last-second-allocation.patch
* mmoom-remove-oom_lock-serialization-from-the-oom-reaper.patch
* mm-do-not-stall-register_shrinker.patch
* mm-do-not-stall-register_shrinker-fix.patch
* selftest-vm-move-128tb-mmap-boundary-test-to-generic-directory.patch
* selftest-vm-move-128tb-mmap-boundary-test-to-generic-directory-fix.patch
* mm-use-vma_pages-helper.patch
* mm-remove-unused-pgdat_reclaimable_pages.patch
* list_lru-prefetch-neighboring-list-entries-before-acquiring-lock.patch
* mm-make-count-list_lru_one-nr_items-lockless.patch
* mm-madvise-enable-soft-offline-of-hugetlb-pages-at-pud-level.patch
* mm-readahead-increase-maximum-readahead-window.patch
* proc-do-not-show-vmexe-bigger-than-total-executable-virtual-memory.patch
* mm-hugetlb-drop-hugepages_treat_as_movable-sysctl.patch
* mm-vmscan-do-not-pass-reclaimed-slab-to-vmpressure.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* mm-walk-the-zone-in-pageblock_nr_pages-steps.patch
* proc-use-%u-for-pid-printing-and-slightly-less-stack.patch
* proc-dont-use-read_once-write_once-for-proc-fail-nth.patch
* proc-fix-proc-map_files-lookup.patch
* proc-simpler-proc-vmcore-cleanup.patch
* proc-less-memory-for-proc-map_files-readdir.patch
* proc-delete-children_seq_release.patch
* makefile-move-stack-protector-compiler-breakage-test-earlier.patch
* makefile-move-stack-protector-availability-out-of-kconfig.patch
* makefile-introduce-config_cc_stackprotector_auto.patch
* docs-correct-documentation-for-%pk.patch
* vsprintf-refactor-%pk-code-out-of-pointer.patch
* printk-hash-addresses-printed-with-%p.patch
* vsprintf-add-printk-specifier-%px.patch
* kasan-use-%px-to-print-addresses-instead-of-%p.patch
* revert-async-simplify-lowest_in_progress.patch
* lib-stackdepot-use-a-non-instrumented-version-of-memcmp.patch
* lib-test_find_bitc-rename-to-find_bit_benchmarkc.patch
* lib-find_bit_benchmarkc-improvements.patch
* lib-optimize-cpumask_next_and.patch
* lib-optimize-cpumask_next_and-v6.patch
* checkpatch-allow-long-lines-containing-url.patch
* seq_file-delete-small-value-optimization.patch
* forkc-check-error-and-return-early.patch
* forkc-add-doc-about-usage-of-clone_fs-flags-and-namespaces.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* uapi-fix-linux-sysctlh-userspace-compilation-errors.patch
* pids-introduce-find_get_task_by_vpid-helper.patch
  linux-next.patch
  linux-next-rejects.patch
* tools-objtool-makefile-dont-assume-sync-checksh-is-executable.patch
* vfs-remove-might_sleep-from-clear_inode.patch
* sparc64-ng4-memset-32-bits-overflow.patch
* lib-crc-ccitt-add-ccitt-false-crc16-variant.patch
  mm-add-strictlimit-knob-v2.patch
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
