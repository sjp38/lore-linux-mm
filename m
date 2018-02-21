Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 37A4E6B0003
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 17:48:45 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id j21so2577480wre.20
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 14:48:45 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d15si16749173wrb.312.2018.02.21.14.48.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Feb 2018 14:48:42 -0800 (PST)
Date: Wed, 21 Feb 2018 14:48:39 -0800
From: akpm@linux-foundation.org
Subject: mmotm 2018-02-21-14-48 uploaded
Message-ID: <20180221224839.MqsDtkGCK%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: broonie@kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org, mhocko@suse.cz, mm-commits@vger.kernel.org, sfr@canb.auug.org.au

The mm-of-the-moment snapshot 2018-02-21-14-48 has been uploaded to

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


This mmotm tree contains the following patches against 4.16-rc2:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
* tools-fix-cross-compile-var-clobbering.patch
* include-linux-sched-mmh-re-inline-mmdrop.patch
* kbuild-always-define-endianess-in-kconfigh.patch
* mm-memcontrol-fix-nr_writeback-leak-in-memcg-and-system-stats.patch
* mm-mlock-vmscan-no-more-skipping-pagevecs.patch
* kernel-relay-limit-kmalloc-size-to-kmalloc_max_size.patch
* fix-const-confusion-in-certs-blacklist.patch
* mm-swap-frontswap-fix-thp-swap-if-frontswap-enabled-v3.patch
* ida-do-zeroing-in-ida_pre_get.patch
* mm-zpool-zpool_evictable-fix-mismatch-in-parameter-name-and-kernel-doc.patch
* mm-swapc-make-functions-and-their-kernel-doc-agree-again.patch
* bugh-work-around-gcc-pr82365-in-bug.patch
* selftests-memfd-add-run_fuse_testsh-to-test_files.patch
* vmalloc-fix-__gfp_highmem-usage-for-vmalloc_32-on-32b-systems.patch
* lib-kconfigdebug-enable-runtime_testing_menu.patch
* mm-dont-defer-struct-page-initialization-for-xen-pv-guests.patch
* hugetlb-fix-surplus-pages-accounting.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* prctl-add-pr_et_pdeathsig_proc.patch
* tile-pci_gx-make-setup_pcie_rc_delay-__init.patch
* ocfs2-use-osb-instead-of-ocfs2_sb.patch
* ocfs2-use-oi-instead-of-ocfs2_i.patch
* ocfs2-clean-up-some-unused-function-declaration.patch
* ocfs2-keep-the-trace-point-consistent-with-the-function-name.patch
* ocfs2-get-rid-of-ocfs2_is_o2cb_active-function.patch
* ocfs2-move-some-definitions-to-header-file.patch
* ocfs2-fix-some-small-problems.patch
* ocfs2-add-kobject-for-online-file-check.patch
* ocfs2-add-duplicative-ino-number-check.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* dentry-fix-kmemcheck-splat-at-take_dentry_name_snapshot.patch
  mm.patch
* mm-ksm-make-function-stable_node_dup-static.patch
* mm-always-print-rlimit_data-warning.patch
* mm-migrate-change-migration-reason-mr_cma-as-mr_contig_range.patch
* mm-hugetlbfs-move-hugetlbfs_i-outside-ifdef-config_hugetlbfs.patch
* mm-memfd-split-out-memfd-for-use-by-multiple-filesystems.patch
* mm-memfd-remove-memfd-code-from-shmem-files-and-use-new-memfd-files.patch
* mm-swap_slots-use-conditional-compilation-for-swap_slotsc.patch
* mm-initialize-pages-on-demand-during-boot.patch
* mm-initialize-pages-on-demand-during-boot-fix-3.patch
* mm-thp-fix-potential-clearing-to-referenced-flag-in-page_idle_clear_pte_refs_one.patch
* mm-memory_hotplug-enforce-block-size-aligned-range-check.patch
* x86-mm-memory_hotplug-determine-block-size-based-on-the-end-of-boot-memory.patch
* x86-mm-memory_hotplug-determine-block-size-based-on-the-end-of-boot-memory-v4.patch
* mm-uninitialized-struct-page-poisoning-sanity-checking.patch
* mm-uninitialized-struct-page-poisoning-sanity-checking-v4.patch
* mm-memory_hotplug-optimize-probe-routine.patch
* mm-memory_hotplug-dont-read-nid-from-struct-page-during-hotplug.patch
* mm-memory_hotplug-optimize-memory-hotplug.patch
* mm-hwpoison-disable-memory-error-handling-on-1gb-hugepage.patch
* mm-page_alloc-extend-kernelcore-and-movablecore-for-percent.patch
* mm-page_alloc-extend-kernelcore-and-movablecore-for-percent-fix.patch
* mm-page_alloc-move-mirrored_kernelcore-to-__meminitdata.patch
* mm-re-use-define_show_attribute-macro.patch
* mm-re-use-define_show_attribute-macro-v2.patch
* mm-fix-races-between-address_space-dereference-and-free-in-page_evicatable.patch
* mm-page_ref-use-atomic_set_release-in-page_ref_unfreeze.patch
* mm-huge_memoryc-reorder-operations-in-__split_huge_page_tail.patch
* z3fold-limit-use-of-stale-list-for-allocation.patch
* mmvmscan-dont-pretend-forward-progress-upon-shrinker_rwsem-contention.patch
* mm-swap-clean-up-swap-readahead.patch
* mm-swap-unify-cluster-based-and-vma-based-swap-readahead.patch
* mm-page_alloc-skip-over-regions-of-invalid-pfns-on-uma.patch
* mm-kmemleak-make-kmemleak_boot_config-__init.patch
* mm-page_owner-make-early_page_owner_param-__init.patch
* mm-page_poison-make-early_page_poison_param-__init.patch
* mm-memcg-plumbing-memcg-for-kmem-cache-allocations.patch
* mm-memcg-plumbing-memcg-for-kmalloc-allocations.patch
* fs-fsnotify-account-fsnotify-metadata-to-kmemcg.patch
* mm-swap-fix-race-between-swapoff-and-some-swap-operations.patch
* mmvmscan-mark-register_shrinker-as-__must_check.patch
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
* mm-oom-docs-describe-the-cgroup-aware-oom-killer-fix-2.patch
* mm-oom-docs-describe-the-cgroup-aware-oom-killer-fix-2-fix.patch
* cgroup-list-groupoom-in-cgroup-features.patch
* mm-add-strictlimit-knob-v2.patch
* mm-page_alloc-dont-reserve-zone_highmem-for-zone_movable-request.patch
* mm-cma-manage-the-memory-of-the-cma-area-by-using-the-zone_movable.patch
* mm-cma-remove-alloc_cma.patch
* arm-cma-avoid-double-mapping-to-the-cma-area-if-config_highmem-=-y.patch
* mm-introduce-map_fixed_safe.patch
* fs-elf-drop-map_fixed-usage-from-elf_map.patch
* elf-enforce-map_fixed-on-overlaying-elf-segments.patch
* mm-dont-expose-page-to-fast-gup-before-its-ready.patch
* mm-swap-make-pointer-swap_avail_heads-static.patch
* mm-numa-rework-do_pages_move.patch
* mm-migrate-remove-reason-argument-from-new_page_t.patch
* mm-unclutter-thp-migration.patch
* mm-page_owner-align-with-pageblock_nr_pages.patch
* mm-make-count-list_lru_one-nr_items-lockless.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* mm-kasan-dont-vfree-nonexistent-vm_area.patch
* procfs-add-seq_put_hex_ll-to-speed-up-proc-pid-maps.patch
* procfs-add-seq_put_hex_ll-to-speed-up-proc-pid-maps-v3.patch
* procfs-optimize-seq_pad-to-speed-up-proc-pid-maps.patch
* proc-get-rid-of-task-lock-unlock-pair-to-read-umask-for-the-status-file.patch
* proc-do-less-stuff-under-pde_unload_lock.patch
* proc-move-proc-sysvipc-creation-to-where-it-belongs.patch
* proc-faster-open-close-of-files-without-release-hook.patch
* proc-randomize-struct-pde_opener.patch
* proc-move-struct-pde_opener-to-kmem-cache.patch
* proc-account-struct-pde_opener.patch
* proc-add-seq_put_decimal_ull_width-to-speed-up-proc-pid-smaps.patch
* proc-add-seq_put_decimal_ull_width-to-speed-up-proc-pid-smaps-fix.patch
* proc-replace-seq_printf-on-seq_putc-to-speed-up-proc-pid-smaps.patch
* proc-optimize-single-symbol-delimiters-to-spead-up-seq_put_decimal_ull.patch
* proc-replace-seq_printf-by-seq_put_smth-to-speed-up-proc-pid-status.patch
* proc-fix-proc-map_files-lookup-some-more.patch
* proc-check-permissions-earlier-for-proc-wchan.patch
* proc-use-set_puts-at-proc-wchan.patch
* headers-untangle-kmemleakh-from-mmh.patch
* taint-convert-to-indexed-initialization.patch
* taint-consolidate-documentation.patch
* taint-add-taint-for-randstruct.patch
* checkpatch-improve-parse_email-signature-checking.patch
* checkpatchpl-add-spdx-license-tag-check.patch
* checkpatch-add-crypto-on_stack-to-declaration_macros.patch
* seq_file-delete-small-value-optimization.patch
* fork-unconditionally-clear-stack-on-fork.patch
* exec-pass-stack-rlimit-into-mm-layout-functions.patch
* exec-introduce-finalize_exec-before-start_thread.patch
* exec-pin-stack-limit-during-exec.patch
* ipc-shm-introduce-shmctlshm_stat_any.patch
* ipc-sem-introduce-semctlsem_stat_any.patch
* ipc-msg-introduce-msgctlmsg_stat_any.patch
* sysctl-add-range-clamping-intvec-helper-functions.patch
* sysctl-warn-when-a-clamped-sysctl-parameter-is-set-out-of-range.patch
* ipc-clamp-msgmni-and-shmmni-to-the-real-ipc_mni-limit.patch
  linux-next.patch
* ipc-mqueue-add-missing-error-code-in-init_mqueue_fs.patch
* fix-double-s-in-code.patch
* fix-read-buffer-overflow-in-delta-ipc.patch
* sparc64-ng4-memset-32-bits-overflow.patch
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
