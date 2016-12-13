Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7A44B6B0038
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 20:02:40 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id e9so286464571pgc.5
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 17:02:40 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s198si45581830pgc.258.2016.12.12.17.02.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Dec 2016 17:02:38 -0800 (PST)
Date: Mon, 12 Dec 2016 17:03:21 -0800
From: akpm@linux-foundation.org
Subject: mmotm 2016-12-12-17-02 uploaded
Message-ID: <584f48d9.dfBrttZ3CZ8rJ1M2%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2016-12-12-17-02 has been uploaded to

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


This mmotm tree contains the following patches against 4.9:
(patches marked "*" will be included in linux-next)

  origin.patch
* kthread-add-__printf-attributes.patch
* prctl-remove-one-shot-limitation-for-changing-exe-link.patch
* scripts-bloat-o-meter-dont-use-readlines.patch
* scripts-bloat-o-meter-compile-number-regex.patch
* scripts-tagssh-handle-omap-platforms-properly.patch
* m32r-add-simple-dma.patch
* m32r-fix-build-warning.patch
* pcmcia-m32r_pcc-check-return-from-request_irq.patch
* pcmcia-m32r_pcc-use-common-error-path.patch
* pcmcia-m32r_pcc-check-return-from-add_pcc_socket.patch
* ocfs2-dlm-clean-up-useless-bug_on-default-case-in-dlm_finalize_reco_handler.patch
* ocfs2-delete-redundant-code-and-set-the-node-bit-into-maybe_map-directly.patch
* ocfs2-dlm-clean-up-deadcode-in-dlm_master_request_handler.patch
* ocfs2-clean-up-unused-page-parameter-in-ocfs2_write_end_nolock.patch
* ocfs2-fix-double-put-of-recount-tree-in-ocfs2_lock_refcount_tree.patch
* fs-ocfs2-use-time64_t-to-represent-orphan-scan-times.patch
* fs-ocfs2-replace-current_time-macro.patch
* mm-memcontrol-use-special-workqueue-for-creating-per-memcg-caches.patch
* slub-move-synchronize_sched-out-of-slab_mutex-on-shrink.patch
* slub-avoid-false-postive-warning.patch
* mm-check-kmem_create_cache-flags-are-commons.patch
* mm-slab-faster-active-and-free-stats.patch
* mm-slab-maintain-total-slab-count-instead-of-active-count.patch
* dont-touch-single-threaded-ptes-which-are-on-the-right-node.patch
* vmscan-set-correct-defer-count-for-shrinker.patch
* mm-gup-make-unnecessarily-global-vma_permits_fault-static.patch
* mm-hugetlb-use-the-right-pte-val-for-compare-in-hugetlb_cow.patch
* mm-hugetlb-use-huge_pte_lock-instead-of-opencoding-the-lock.patch
* kmemleak-fix-reference-to-documentation.patch
* mm-dont-steal-highatomic-pageblock.patch
* mm-prevent-double-decrease-of-nr_reserved_highatomic.patch
* mm-try-to-exhaust-highatomic-reserve-before-the-oom.patch
* mm-make-unreserve-highatomic-functions-reliable.patch
* mm-vmallocc-simplify-proc-vmallocinfo-implementation.patch
* mm-thp-avoid-unlikely-branches-for-split_huge_pmd.patch
* mm-mempolicy-clean-up-__gfp_thisnode-confusion-in-policy_zonelist.patch
* mm-compaction-fix-nr_isolated_-stats-for-pfn-based-migration.patch
* shmem-avoid-maybe-uninitialized-warning.patch
* mm-use-the-correct-page-size-when-removing-the-page.patch
* mm-update-mmu_gather-range-correctly.patch
* mm-hugetlb-add-tlb_remove_hugetlb_entry-for-handling-hugetlb-pages.patch
* mm-add-tlb_remove_check_page_size_change-to-track-page-size-change.patch
* mm-remove-the-page-size-change-check-in-tlb_remove_page.patch
* mm-fixup-get_user_pages-comments.patch
* mm-mempolicyc-forbid-static-or-relative-flags-for-local-numa-mode.patch
* powerpc-mm-allow-memory-hotplug-into-a-memoryless-node.patch
* mm-remove-x86-only-restriction-of-movable_node.patch
* mm-enable-config_movable_node-on-non-x86-arches.patch
* of-fdt-mark-hotpluggable-memory.patch
* dt-add-documentation-of-hotpluggable-memory-property.patch
* mm-pkeys-generate-pkey-system-call-code-only-if-arch_has_pkeys-is-selected.patch
* mm-disable-numa-migration-faults-for-dax-vmas.patch
* mm-cma-make-linux-cmah-standalone-includible.patch
* filemap-add-comment-for-confusing-logic-in-page_cache_tree_insert.patch
* writeback-remove-redundant-if-check.patch
* shmem-fix-compilation-warnings-on-unused-functions.patch
* mm-dont-cap-request-size-based-on-read-ahead-setting.patch
* include-linux-backing-dev-defsh-shrink-struct-backing_dev_info.patch
* mm-khugepaged-close-use-after-free-race-during-shmem-collapsing.patch
* mm-khugepaged-fix-radix-tree-node-leak-in-shmem-collapse-error-path.patch
* mm-workingset-turn-shadow-node-shrinker-bugs-into-warnings.patch
* lib-radix-tree-native-accounting-of-exceptional-entries.patch
* lib-radix-tree-check-accounting-of-existing-slot-replacement-users.patch
* lib-radix-tree-add-entry-deletion-support-to-__radix_tree_replace.patch
* lib-radix-tree-update-callback-for-changing-leaf-nodes.patch
* mm-workingset-move-shadow-entry-tracking-to-radix-tree-exceptional-tracking.patch
* mm-workingset-restore-refault-tracking-for-single-page-files.patch
* mm-workingset-update-shadow-limit-to-reflect-bigger-active-list.patch
* mm-remove-free_unmap_vmap_area_noflush.patch
* mm-remove-free_unmap_vmap_area_addr.patch
* mm-refactor-__purge_vmap_area_lazy.patch
* mm-add-vfree_atomic.patch
* kernel-fork-use-vfree_atomic-to-free-thread-stack.patch
* x86-ldt-use-vfree_atomic-to-free-ldt-entries.patch
* mm-mark-all-calls-into-the-vmalloc-subsystem-as-potentially-sleeping.patch
* mm-turn-vmap_purge_lock-into-a-mutex.patch
* mm-add-preempt-points-into-__purge_vmap_area_lazy.patch
* mm-move-vma_is_anonymous-check-within-pmd_move_must_withdraw.patch
* mm-thp-page-cache-support-for-ppc64.patch
* mm-debug-print-raw-struct-page-data-in-__dump_page.patch
* mm-rmap-handle-anon_vma_prepare-common-case-inline.patch
* mm-page_alloc-keep-pcp-count-and-list-contents-in-sync-if-struct-page-is-corrupted.patch
* mm-add-three-more-cond_resched-in-swapoff.patch
* mm-add-cond_resched-in-gather_pte_stats.patch
* mm-make-transparent-hugepage-size-public.patch
* kasan-support-panic_on_warn.patch
* kasan-eliminate-long-stalls-during-quarantine-reduction.patch
* kasan-turn-on-fsanitize-address-use-after-scope.patch
* mm-percpuc-fix-panic-triggered-by-bug_on-falsely.patch
* proc-report-no_new_privs-state.patch
* proc-make-struct-pid_entry-len-unsigned.patch
* proc-make-struct-struct-map_files_info-len-unsigned-int.patch
* proc-just-list_del-struct-pde_opener.patch
* proc-fix-type-of-struct-pde_opener-closing-field.patch
* proc-kmalloc-struct-pde_opener.patch
* proc-tweak-comments-about-2-stage-open-and-everything.patch
* fs-proc-arrayc-slightly-improve-render_sigset_t.patch
* proc-save-decrement-during-lookup-readdir-in-proc-pid.patch
* proc-calculate-proc-and-proc-task-nlink-at-init-time.patch
* hung_task-decrement-sysctl_hung_task_warnings-only-if-it-is-positive.patch
* compiler-gcch-use-proved-instead-of-proofed.patch
* printk-nmi-fix-up-handling-of-the-full-nmi-log-buffer.patch
* printk-nmi-handle-continuous-lines-and-missing-newline.patch
* printk-kdb-handle-more-message-headers.patch
* printk-btrfs-handle-more-message-headers.patch
* printk-sound-handle-more-message-headers.patch
* printk-add-kconfig-option-to-set-default-console-loglevel.patch
* get_maintainer-look-for-arbitrary-letter-prefixes-in-sections.patch
* maintainers-add-b-for-uri-where-to-file-bugs.patch
* maintainers-add-drm-and-drm-i915-bug-filing-info.patch
* maintainers-add-c-for-uri-for-chat-where-developers-hang-out.patch
* maintainers-add-drm-and-drm-i915-irc-channels.patch
* let-config_strict_devmem-depends-on-config_devmem.patch
* lib-rbtreec-fix-typo-in-comment-of-____rb_erase_color.patch
* lib-ida-document-locking-requirements-a-bit-better-v2.patch
* checkpatch-dont-try-to-get-maintained-status-when-no-tree-is-given.patch
* scripts-checkpatchpl-fix-spelling.patch
* checkpatch-dont-check-pl-files-improve-absolute-path-commit-log-test.patch
* checkpatch-avoid-multiple-line-dereferences.patch
* checkpatch-dont-check-c99-types-like-uint8_t-under-tools.patch
* checkpatch-dont-emit-unified-diff-error-for-rename-only-patches.patch
* binfmt_elf-use-vmalloc-for-allocation-of-vma_filesz.patch
* init-reduce-rootwait-polling-interval-time-to-5ms.patch
  i-need-old-gcc.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* kbuild-simpler-generation-of-assembly-constants.patch
* ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called.patch
* ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called-fix.patch
* ocfs2-fix-crash-caused-by-stale-lvb-with-fsdlm-plugin.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* kernel-watchdog-use-nmi-registers-snapshot-in-hardlockup-handler.patch
  mm.patch
* mm-compaction-allow-compaction-for-gfp_nofs-requests.patch
* mm-compaction-allow-compaction-for-gfp_nofs-requests-fix.patch
* z3fold-limit-first_num-to-the-actual-range-of-possible-buddy-indexes.patch
* z3fold-make-pages_nr-atomic.patch
* z3fold-extend-compaction-function.patch
* z3fold-use-per-page-spinlock.patch
* z3fold-discourage-use-of-pages-that-werent-compacted.patch
* z3fold-fix-header-size-related-issues.patch
* z3fold-fix-locking-issues.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* mm-walk-the-zone-in-pageblock_nr_pages-steps.patch
* lib-add-crc64-ecma-module.patch
* signals-avoid-unnecessary-taking-of-sighand-siglock.patch
* coredump-clarify-unsafe-core_pattern-warning.patch
* revert-kdump-vmcoreinfo-report-memory-sections-virtual-addresses.patch
* kexec-change-to-export-the-value-of-phys_base-instead-of-symbol-address.patch
* kexec-add-cond_resched-into-kimage_alloc_crash_control_pages.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* sysctl-add-kern_cont-to-deprecated_sysctl_warning.patch
* arch-arc-add-option-to-skip-sync-on-dma-mapping.patch
* arch-arm-add-option-to-skip-sync-on-dma-map-and-unmap.patch
* arch-avr32-add-option-to-skip-sync-on-dma-map.patch
* arch-blackfin-add-option-to-skip-sync-on-dma-map.patch
* arch-c6x-add-option-to-skip-sync-on-dma-map-and-unmap.patch
* arch-frv-add-option-to-skip-sync-on-dma-map.patch
* arch-hexagon-add-option-to-skip-dma-sync-as-a-part-of-mapping.patch
* arch-m68k-add-option-to-skip-dma-sync-as-a-part-of-mapping.patch
* arch-metag-add-option-to-skip-dma-sync-as-a-part-of-map-and-unmap.patch
* arch-microblaze-add-option-to-skip-dma-sync-as-a-part-of-map-and-unmap.patch
* arch-mips-add-option-to-skip-dma-sync-as-a-part-of-map-and-unmap.patch
* arch-nios2-add-option-to-skip-dma-sync-as-a-part-of-map-and-unmap.patch
* arch-openrisc-add-option-to-skip-dma-sync-as-a-part-of-mapping.patch
* arch-parisc-add-option-to-skip-dma-sync-as-a-part-of-map-and-unmap.patch
* arch-powerpc-add-option-to-skip-dma-sync-as-a-part-of-mapping.patch
* arch-sh-add-option-to-skip-dma-sync-as-a-part-of-mapping.patch
* arch-sparc-add-option-to-skip-dma-sync-as-a-part-of-map-and-unmap.patch
* arch-tile-add-option-to-skip-dma-sync-as-a-part-of-map-and-unmap.patch
* arch-xtensa-add-option-to-skip-dma-sync-as-a-part-of-mapping.patch
* dma-add-calls-for-dma_map_page_attrs-and-dma_unmap_page_attrs.patch
* mm-add-support-for-releasing-multiple-instances-of-a-page.patch
* igb-update-driver-to-make-use-of-dma_attr_skip_cpu_sync.patch
* igb-update-code-to-better-handle-incrementing-page-count.patch
* relay-check-array-offset-before-using-it.patch
* kconfig-lib-kconfigdebug-fix-references-to-documenation.patch
* kconfig-lib-kconfigubsan-fix-reference-to-ubsan-documentation.patch
* kcov-add-more-missing-include.patch
* debug-more-properly-delay-for-secondary-cpus.patch
* debug-more-properly-delay-for-secondary-cpus-fix.patch
* kdb-remove-unused-kdb_event-handling.patch
* kdb-properly-synchronize-vkdb_printf-calls-with-other-cpus.patch
* kdb-call-vkdb_printf-from-vprintk_default-only-when-wanted.patch
* initramfs-select-builtin-initram-compression-algorithm-on-kconfig-instead-of-makefile.patch
* initramfs-allow-again-choice-of-the-embedded-initram-compression-algorithm.patch
* ipc-semc-avoid-using-spin_unlock_wait.patch
* ipc-sem-add-hysteresis.patch
* ipc-msg-make-msgrcv-work-with-long_min.patch
* ipc-fixed-warnings.patch
  linux-next.patch
  linux-next-rejects.patch
* posix-timers-give-lazy-compilers-some-help-optimizing-code-away.patch
* drivers-net-wireless-intel-iwlwifi-dvm-calibc-fix-min-warning.patch
* radix-tree-test-suite-fix-compilation.patch
* ktestpl-fix-english.patch
* watchdog-move-shared-definitions-to-nmih.patch
* watchdog-move-hardlockup-detector-to-separate-file.patch
* sparc-implement-watchdog_nmi_enable-and-watchdog_nmi_disable.patch
* ipc-sem-do-not-call-wake_sem_queue_do-prematurely.patch
* ipc-sem-rework-task-wakeups.patch
* ipc-sem-rework-task-wakeups-fix.patch
* ipc-sem-rework-task-wakeups-checkpatch-fixes.patch
* ipc-sem-optimize-perform_atomic_semop.patch
* ipc-sem-optimize-perform_atomic_semop-fix.patch
* ipc-sem-optimize-perform_atomic_semop-checkpatch-fixes.patch
* ipc-sem-explicitly-inline-check_restart.patch
* ipc-sem-use-proper-list-api-for-pending_list-wakeups.patch
* ipc-sem-simplify-wait-wake-loop.patch
* ipc-sem-simplify-wait-wake-loop-checkpatch-fixes.patch
* ipc-sem-avoid-idr-tree-lookup-for-interrupted-semop.patch
* mm-add-locked-parameter-to-get_user_pages_remote.patch
* mm-add-locked-parameter-to-get_user_pages_remote-fix.patch
* mm-unexport-__get_user_pages_unlocked.patch
* mm-unexport-__get_user_pages_unlocked-checkpatch-fixes.patch
* mm-join-struct-fault_env-and-vm_fault.patch
* mm-use-vmf-address-instead-of-of-vmf-virtual_address.patch
* mm-use-pgoff-in-struct-vm_fault-instead-of-passing-it-separately.patch
* mm-use-passed-vm_fault-structure-in-__do_fault.patch
* mm-trim-__do_fault-arguments.patch
* mm-use-passed-vm_fault-structure-for-in-wp_pfn_shared.patch
* mm-add-orig_pte-field-into-vm_fault.patch
* mm-allow-full-handling-of-cow-faults-in-fault-handlers.patch
* mm-factor-out-functionality-to-finish-page-faults.patch
* mm-move-handling-of-cow-faults-into-dax-code.patch
* mm-factor-out-common-parts-of-write-fault-handling.patch
* mm-pass-vm_fault-structure-into-do_page_mkwrite.patch
* mm-use-vmf-page-during-wp-faults.patch
* mm-move-part-of-wp_page_reuse-into-the-single-call-site.patch
* mm-provide-helper-for-finishing-mkwrite-faults.patch
* mm-change-return-values-of-finish_mkwrite_fault.patch
* mm-export-follow_pte.patch
* dax-make-cache-flushing-protected-by-entry-lock.patch
* dax-protect-pte-modification-on-wp-fault-by-radix-tree-entry-lock.patch
* dax-clear-dirty-entry-tags-on-cache-flush.patch
* powerpc-ima-get-the-kexec-buffer-passed-by-the-previous-kernel.patch
* ima-on-soft-reboot-restore-the-measurement-list.patch
* ima-permit-duplicate-measurement-list-entries.patch
* ima-maintain-memory-size-needed-for-serializing-the-measurement-list.patch
* powerpc-ima-send-the-kexec-buffer-to-the-next-kernel.patch
* ima-on-soft-reboot-save-the-measurement-list.patch
* ima-store-the-builtin-custom-template-definitions-in-a-list.patch
* ima-support-restoring-multiple-template-formats.patch
* ima-define-a-canonical-binary_runtime_measurements-list-format.patch
* ima-platform-independent-hash-value.patch
* tools-add-warn_on_once.patch
* radix-tree-test-suite-allow-gfp_atomic-allocations-to-fail.patch
* radix-tree-test-suite-track-preempt_count.patch
* radix-tree-test-suite-free-preallocated-nodes.patch
* radix-tree-test-suite-make-runs-more-reproducible.patch
* radix-tree-test-suite-iteration-test-misuses-rcu.patch
* radix-tree-test-suite-benchmark-for-iterator.patch
* radix-tree-test-suite-use-rcu_barrier.patch
* radix-tree-test-suite-handle-exceptional-entries.patch
* radix-tree-test-suite-record-order-in-each-item.patch
* tools-add-more-bitmap-functions.patch
* radix-tree-test-suite-use-common-find-bit-code.patch
* radix-tree-fix-typo.patch
* radix-tree-move-rcu_head-into-a-union-with-private_list.patch
* radix-tree-create-node_tag_set.patch
* radix-tree-make-radix_tree_find_next_bit-more-useful.patch
* radix-tree-improve-dump-output.patch
* btrfs-fix-race-in-btrfs_free_dummy_fs_info.patch
* radix-tree-improve-multiorder-iterators.patch
* radix-tree-delete-radix_tree_locate_item.patch
* radix-tree-delete-radix_tree_range_tag_if_tagged.patch
* radix-tree-add-radix_tree_join.patch
* radix-tree-add-radix_tree_split.patch
* radix-tree-add-radix_tree_split_preload.patch
* radix-tree-fix-replacement-for-multiorder-entries.patch
* radix-tree-test-suite-check-multiorder-iteration.patch
* idr-add-ida_is_empty.patch
* tpm-use-idr_find-not-idr_find_slowpath.patch
* rxrpc-abstract-away-knowledge-of-idr-internals.patch
* idr-reduce-the-number-of-bits-per-level-from-8-to-6.patch
* radix-tree-test-suite-add-some-more-functionality.patch
* reimplement-idr-and-ida-using-the-radix-tree.patch
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
