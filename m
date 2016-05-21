Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 251B86B007E
	for <linux-mm@kvack.org>; Fri, 20 May 2016 20:12:21 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 77so247862713pfz.3
        for <linux-mm@kvack.org>; Fri, 20 May 2016 17:12:21 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t88si31284739pfj.44.2016.05.20.17.12.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 May 2016 17:12:19 -0700 (PDT)
Date: Fri, 20 May 2016 17:12:18 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2016-05-20-17-11 uploaded
Message-ID: <573fa7e2.oDomblONAZiSwiPm%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2016-05-20-17-11 has been uploaded to

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


This mmotm tree contains the following patches against 4.6:
(patches marked "*" will be included in linux-next)

  origin.patch
* mm-workingset-only-do-workingset-activations-on-reads.patch
* mm-filemap-only-do-access-activations-on-reads.patch
* mm-vmscan-reduce-size-of-inactive-file-list.patch
* vmscan-consider-classzone_idx-in-compaction_ready.patch
* mm-compaction-change-compact_-constants-into-enum.patch
* mm-compaction-cover-all-compaction-mode-in-compact_zone.patch
* mm-compaction-distinguish-compact_deferred-from-compact_skipped.patch
* mm-compaction-distinguish-between-full-and-partial-compact_complete.patch
* mm-compaction-update-compaction_result-ordering.patch
* mm-compaction-simplify-__alloc_pages_direct_compact-feedback-interface.patch
* mm-compaction-abstract-compaction-feedback-to-helpers.patch
* mm-oom-rework-oom-detection.patch
* mm-throttle-on-io-only-when-there-are-too-many-dirty-and-writeback-pages.patch
* mm-oom-protect-costly-allocations-some-more.patch
* mm-consider-compaction-feedback-also-for-costly-allocation.patch
* mm-oom-compaction-prevent-from-should_compact_retry-looping-for-ever-for-costly-orders.patch
* mm-oom-protect-costly-allocations-some-more-for-config_compaction.patch
* mm-oom_reaper-hide-oom-reaped-tasks-from-oom-killer-more-carefully.patch
* mm-oom_reaper-do-not-mmput-synchronously-from-the-oom-reaper-context.patch
* oom-consider-multi-threaded-tasks-in-task_will_free_mem.patch
* mmoom-speed-up-select_bad_process-loop.patch
* mm-thp-simplify-the-implementation-of-mk_huge_pmd.patch
* memory-failure-replace-mce-with-memory-failure.patch
* mm-memblock-move-memblock_addreserve_region-into-memblock_addreserve.patch
* mm-vmalloc-keep-a-separate-lazy-free-list.patch
* mm-fix-incorrect-pfn-passed-to-untrack_pfn-in-remap_pfn_range-v2.patch
* mm-enable-rlimit_data-by-default-with-workaround-for-valgrind.patch
* tmpfs-fix-vm_mayshare-mappings-for-nommu.patch
* mm-hugetlb_cgroup-round-limit_in_bytes-down-to-hugepage-size.patch
* mm-tighten-fault_in_pages_writeable.patch
* mm-put-activate_page_pvecs-and-others-pagevec-together.patch
* include-linux-hugetlb-clean-up-code.patch
* include-linux-hugetlbh-use-bool-instead-of-int-for-hugepage_migration_supported.patch
* mm-fix-commmets-if-sparsemem-pgdata-doesnt-have-page_ext.patch
* documentation-vm-fix-spelling-mistakes.patch
* mmwriteback-dont-use-memory-reserves-for-wb_start_writeback.patch
* use-existing-helper-to-convert-on-off-to-boolean.patch
* mm-use-unsigned-long-constant-for-page-flags.patch
* memcg-fix-stale-mem_cgroup_force_empty-comment.patch
* vmstat-get-rid-of-the-ugly-cpu_stat_off-variable-v2.patch
* mm-thp-microoptimize-compound_mapcount.patch
* mm-thp-split_huge_pmd_address-comment-improvement.patch
* z3fold-the-3-fold-allocator-for-compressed-pages.patch
* mm-memblockc-remove-unnecessary-always-true-comparison.patch
* userfaultfd-dont-pin-the-user-memory-in-userfaultfd_file_create.patch
* mm-use-phys_addr_t-for-reserve_bootmem_region-arguments.patch
* mm-make-faultaround-produce-old-ptes.patch
* mm-disable-fault-around-on-emulated-access-bit-architecture.patch
* mm-kasan-fix-to-call-kasan_free_pages-after-poisoning-page.patch
* mm-check_new_page_bad-directly-returns-in-__pg_hwpoison-case.patch
* mm-increase-safety-margin-provided-by-pf_less_throttle.patch
* mm-thp-khugepaged-should-scan-when-sleep-value-is-written.patch
* mm-page_is_guard-return-false-when-page_ext-arrays-are-not-allocated-yet.patch
* mm-compact-fix-zoneindex-in-compact.patch
* mm-migrate-increment-fail-count-on-enomem.patch
* mm-move-page_ext_init-after-all-struct-pages-are-initialized-v2.patch
* mm-kasan-initial-memory-quarantine-implementation.patch
* mm-kasan-dont-call-kasan_krealloc-from-ksize.patch
* mm-kasan-add-a-ksize-test.patch
* mm-kasan-print-name-of-mem-caller-in-report.patch
* mm-kasan-add-api-to-check-memory-regions.patch
* x86-kasan-instrument-user-memory-access-api.patch
* kasan-tests-add-tests-for-user-memory-access-functions.patch
* zsmalloc-use-first_page-rather-than-page.patch
* zsmalloc-clean-up-many-bug_on.patch
* zsmalloc-reordering-function-parameter.patch
* zsmalloc-remove-unused-pool-param-in-obj_free.patch
* zsmalloc-require-gfp-in-zs_malloc.patch
* zram-user-per-cpu-compression-streams.patch
* mm-zswap-use-workqueue-to-destroy-pool.patch
* mm-zsmalloc-dont-fail-if-cant-create-debugfs-info.patch
* zram-remove-max_comp_streams-internals.patch
* zram-introduce-per-device-debug_stat-sysfs-node.patch
* procfs-expose-umask-in-proc-pid-status.patch
* procfs-fixes-pthread-cross-thread-naming-if-pr_dumpable.patch
* mn10300-let-exit_fpu-accept-a-task.patch
* exit_thread-remove-empty-bodies.patch
* exit_thread-accept-a-task-parameter-to-be-exited.patch
* fork-free-thread-in-copy_process-on-failure.patch
* use-pid_t-instead-of-int.patch
* printk-nmi-generic-solution-for-safe-printk-in-nmi.patch
* printk-nmi-warn-when-some-message-has-been-lost-in-nmi-context.patch
* printk-nmi-increase-the-size-of-nmi-buffer-and-make-it-configurable.patch
* printk-nmi-flush-nmi-messages-on-the-system-panic.patch
* maintainers-remove-linux-listsopenriscnet.patch
* maintainers-remove-defunct-spear-mailing-list.patch
* maintainers-remove-koichi-yasutake.patch
* lib-vsprintf-simplify-uuid-printing.patch
* ima-use-%pu-to-output-uuid-in-printable-format.patch
* lib-uuid-move-generate_random_uuid-to-uuidc.patch
* lib-uuid-introduce-few-more-generic-helpers-for-uuid.patch
* lib-uuid-remove-fsf-address.patch
* sysctl-use-generic-uuid-library.patch
* efi-redefine-type-constant-macro-from-generic-code.patch
* efivars-use-generic-uuid-library.patch
* genhd-move-to-use-generic-uuid-library.patch
* ldm-use-generic-uuid-library.patch
* wmi-use-generic-uuid-library.patch
* radix-tree-introduce-radix_tree_empty.patch
* radix-tree-test-suite-fix-build.patch
* radix-tree-test-suite-add-tests-for-radix_tree_locate_item.patch
* radix-tree-test-suite-allow-testing-other-fan-out-values.patch
* radix-tree-test-suite-keep-regression-test-runs-short.patch
* radix-tree-test-suite-rebuild-when-headers-change.patch
* radix-tree-remove-unused-looping-macros.patch
* introduce-config_radix_tree_multiorder.patch
* radix-tree-add-missing-sibling-entry-functionality.patch
* radix-tree-fix-sibling-entry-insertion.patch
* radix-tree-fix-deleting-a-multi-order-entry-through-an-alias.patch
* radix-tree-remove-restriction-on-multi-order-entries.patch
* radix-tree-introduce-radix_tree_load_root.patch
* radix-tree-fix-extending-the-tree-for-multi-order-entries-at-offset-0.patch
* radix-tree-test-suite-start-adding-multiorder-tests.patch
* radix-tree-fix-several-shrinking-bugs-with-multiorder-entries.patch
* radix-tree-rewrite-__radix_tree_lookup.patch
* radix-tree-fix-multiorder-bug_on-in-radix_tree_insert.patch
* radix-tree-add-support-for-multi-order-iterating.patch
* radix-tree-test-suite-multi-order-iteration-test.patch
* radix-tree-rewrite-radix_tree_tag_set.patch
* radix-tree-rewrite-radix_tree_tag_clear.patch
* radix-tree-rewrite-radix_tree_tag_get.patch
* radix-tree-test-suite-add-multi-order-tag-test.patch
* radix-tree-fix-radix_tree_create-for-sibling-entries.patch
* radix-tree-rewrite-radix_tree_locate_item.patch
* radix-tree-add-test-for-radix_tree_locate_item.patch
* radix-tree-fix-radix_tree_range_tag_if_tagged-for-multiorder-entries.patch
* radix-tree-fix-radix_tree_dump-for-multi-order-entries.patch
* radix-tree-add-copyright-statements.patch
* drivers-hwspinlock-use-correct-radix-tree-api.patch
* radix-tree-miscellaneous-fixes.patch
* radix-tree-split-node-path-into-offset-and-height.patch
* radix-tree-replace-node-height-with-node-shift.patch
* radix-tree-remove-a-use-of-root-height-from-delete_node.patch
* radix-tree-test-suite-remove-dependencies-on-height.patch
* radix-tree-remove-root-height.patch
* radix-tree-rename-indirect_ptr-to-internal_node.patch
* radix-tree-rename-ptr_to_indirect-to-node_to_entry.patch
* radix-tree-rename-indirect_to_ptr-to-entry_to_node.patch
* radix-tree-rename-radix_tree_is_indirect_ptr.patch
* radix-tree-change-naming-conventions-in-radix_tree_shrink.patch
* radix-tree-tidy-up-next_chunk.patch
* radix-tree-tidy-up-range_tag_if_tagged.patch
* radix-tree-tidy-up-__radix_tree_create.patch
* radix-tree-introduce-radix_tree_replace_clear_tags.patch
* radix-tree-make-radix_tree_descend-more-useful.patch
* dax-move-radix_dax_-definitions-to-daxc.patch
* radix-tree-free-up-the-bottom-bit-of-exceptional-entries-for-reuse.patch
* lib-gcd-use-binary-gcd-algorithm-instead-of-euclidean.patch
* checkpatch-add-prefer_is_enabled-test.patch
* checkpatch-improve-constant_comparison-test-for-structure-members.patch
* checkpatch-add-test-for-keywords-not-starting-on-tabstops.patch
* checkpatch-whine-about-access_once.patch
* checkpatch-advertise-the-fix-and-fix-inplace-options-more.patch
* checkpatch-add-list-types-to-show-message-types-to-show-or-ignore.patch
* checkpatch-add-support-to-check-already-applied-git-commits.patch
* checkpatch-reduce-number-of-git-log-calls-with-git.patch
* checkpatch-improve-git-commit-count-shortcut.patch
* fs-efs-fix-return-value.patch
* init-mainc-simplify-initcall_blacklisted.patch
* kprobes-add-the-tls-argument-for-j_do_fork.patch
* kprobes-add-a-new-module-parameter.patch
* kprobes-print-out-the-symbol-name-for-the-hooks.patch
  i-need-old-gcc.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* fs-ext4-fsyncc-generic_file_fsync-call-based-on-barrier-flag.patch
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
  mm.patch
* mm-add-config-option-to-select-the-initial-overcommit-mode.patch
* memory-hotplug-add-move_pfn_range.patch
* memory-hotplug-more-general-validation-of-zone-during-online.patch
* memory-hotplug-use-zone_can_shift-for-sysfs-valid_zones-attribute.patch
* mm-memblock-if-nr_new-is-0-just-return.patch
* mm-make-optimistic-check-for-swapin-readahead.patch
* mm-make-optimistic-check-for-swapin-readahead-fix-2.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-2.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-3.patch
* mm-vmstat-calculate-particular-vm-event.patch
* mm-thp-avoid-unnecessary-swapin-in-khugepaged.patch
* mm-thp-avoid-unnecessary-swapin-in-khugepaged-fix.patch
* lib-switch-config_printk_time-to-int.patch
* printk-allow-different-timestamps-for-printktime.patch
* lib-add-crc64-ecma-module.patch
* fs-befs-datastreamc-befs_read_datastream-remove-unneeded-initialization-to-null.patch
* fs-befs-datastreamc-befs_read_lsymlink-remove-unneeded-initialization-to-null.patch
* fs-befs-datastreamc-befs_find_brun_dblindirect-remove-unneeded-initializations-to-null.patch
* fs-befs-linuxvfsc-befs_get_block-remove-unneeded-initialization-to-null.patch
* fs-befs-linuxvfsc-befs_iget-remove-unneeded-initialization-to-null.patch
* fs-befs-linuxvfsc-befs_iget-remove-unneeded-raw_inode-initialization-to-null.patch
* fs-befs-linuxvfsc-befs_iget-remove-unneeded-befs_nio-initialization-to-null.patch
* fs-befs-ioc-befs_bread_iaddr-remove-unneeded-initialization-to-null.patch
* fs-befs-ioc-befs_bread-remove-unneeded-initialization-to-null.patch
* nilfs2-constify-nilfs_sc_operations-structures.patch
* nilfs2-fix-white-space-issue-in-nilfs_mount.patch
* nilfs2-remove-space-before-comma.patch
* nilfs2-remove-fsf-mailing-address-from-gpl-notices.patch
* nilfs2-clean-up-old-e-mail-addresses.patch
* maintainers-add-web-link-for-nilfs-project.patch
* nilfs2-clarify-permission-to-replicate-the-design.patch
* nilfs2-get-rid-of-nilfs_mdt_mark_block_dirty.patch
* nilfs2-move-cleanup-code-of-metadata-file-from-inode-routines.patch
* nilfs2-replace-__attribute__packed-with-__packed.patch
* nilfs2-add-missing-line-spacing.patch
* nilfs2-clean-trailing-semicolons-in-macros.patch
* nilfs2-clean-trailing-semicolons-in-macros-fix.patch
* nilfs2-do-not-emit-extra-newline-on-nilfs_warning-and-nilfs_error.patch
* nilfs2-remove-space-before-semicolon.patch
* nilfs2-fix-code-indent-coding-style-issue.patch
* nilfs2-avoid-bare-use-of-unsigned.patch
* nilfs2-remove-unnecessary-else-after-return-or-break.patch
* nilfs2-remove-loops-of-single-statement-macros.patch
* nilfs2-fix-block-comments.patch
* wait-ptrace-assume-__wall-if-the-child-is-traced.patch
* wait-allow-sys_waitid-to-accept-__wnothread-__wclone-__wall.patch
* signal-make-oom_flags-a-bool.patch
* kernel-signalc-convert-printkkern_level-to-pr_level.patch
* signal-move-the-sig-sigrtmin-check-into-siginmasksig.patch
* allocate-idle-task-for-a-cpu-always-on-its-local-node.patch
* allocate-idle-task-for-a-cpu-always-on-its-local-node-fix.patch
* exec-remove-the-no-longer-needed-remove_arg_zero-free_arg_page.patch
* kexec-introduce-a-protection-mechanism-for-the-crashkernel-reserved-memory.patch
* kexec-provide-arch_kexec_protectunprotect_crashkres.patch
* kexec-make-a-pair-of-map-unmap-reserved-pages-in-error-path.patch
* kexec-do-a-cleanup-for-function-kexec_load.patch
* s390-kexec-consolidate-crash_map-unmap_reserved_pages-and-arch_kexec_protectunprotect_crashkres.patch
* kdump-fix-gdb-macros-work-work-with-newer-and-64-bit-kernels.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* futex-fix-shared-futex-operations-on-nommu.patch
* rtsx_usb_ms-use-schedule_timeout_idle-in-polling-loop-v2.patch
* arch-defconfig-remove-config_resource_counters.patch
* scripts-gdb-adjust-module-reference-counter-reported-by-lx-lsmod.patch
* scripts-gdb-provide-linux-constants.patch
* scripts-gdb-provide-kernel-list-item-generators.patch
* scripts-gdb-convert-modules-usage-to-lists-functions.patch
* scripts-gdb-provide-exception-catching-parser.patch
* scripts-gdb-support-config_modules-gracefully.patch
* scripts-gdb-provide-a-dentry_name-vfs-path-helper.patch
* scripts-gdb-add-io-resource-readers.patch
* scripts-gdb-add-mount-point-list-command.patch
* scripts-gdb-add-cpu-iterators.patch
* scripts-gdb-cast-cpu-numbers-to-integer.patch
* scripts-gdb-add-a-radix-tree-parser.patch
* scripts-gdb-add-documentation-example-for-radix-tree.patch
* scripts-gdb-add-lx_thread_info_by_pid-helper.patch
* scripts-gdb-improve-types-abstraction-for-gdb-python-scripts.patch
* scripts-gdb-fix-issue-with-dmesgpy-and-python-3x.patch
* scripts-gdb-decode-bytestream-on-dmesg-for-python3.patch
* maintainers-add-co-maintainer-for-scripts-gdb.patch
* ipc-semc-fix-complex_count-vs-simple-op-race.patch
* ipc-msgc-msgsnd-use-freezable-blocking-call.patch
* msgrcv-use-freezable-blocking-call.patch
  linux-next.patch
  linux-next-git-rejects.patch
  linux-next-rejects.patch
* mm-make-optimistic-check-for-swapin-readahead-fix.patch
* drivers-net-wireless-intel-iwlwifi-dvm-calibc-fix-min-warning.patch
* mm-make-mmap_sem-for-write-waits-killable-for-mm-syscalls.patch
* mm-make-vm_mmap-killable.patch
* mm-make-vm_munmap-killable.patch
* mm-aout-handle-vm_brk-failures.patch
* mm-elf-handle-vm_brk-error.patch
* mm-make-vm_brk-killable.patch
* mm-proc-make-clear_refs-killable.patch
* mm-fork-make-dup_mmap-wait-for-mmap_sem-for-write-killable.patch
* ipc-shm-make-shmem-attach-detach-wait-for-mmap_sem-killable.patch
* vdso-make-arch_setup_additional_pages-wait-for-mmap_sem-for-write-killable.patch
* coredump-make-coredump_wait-wait-for-mmap_sem-for-write-killable.patch
* aio-make-aio_setup_ring-killable.patch
* exec-make-exec-path-waiting-for-mmap_sem-killable.patch
* prctl-make-pr_set_thp_disable-wait-for-mmap_sem-killable.patch
* uprobes-wait-for-mmap_sem-for-write-killable.patch
* drm-i915-make-i915_gem_mmap_ioctl-wait-for-mmap_sem-killable.patch
* drm-radeon-make-radeon_mn_get-wait-for-mmap_sem-killable.patch
* drm-amdgpu-make-amdgpu_mn_get-wait-for-mmap_sem-killable.patch
* drm-amdgpu-make-amdgpu_mn_get-wait-for-mmap_sem-killable-fix.patch
* kgdb-depends-on-vt.patch
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
