Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1FA176B0003
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 20:03:00 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b16so35376pfi.5
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 17:03:00 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p3-v6si3792472plk.166.2018.04.10.17.02.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Apr 2018 17:02:58 -0700 (PDT)
Date: Tue, 10 Apr 2018 17:02:56 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2018-04-10-17-02 uploaded
Message-ID: <20180411000256.gjPZB%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org

The mm-of-the-moment snapshot 2018-04-10-17-02 has been uploaded to

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


This mmotm tree contains the following patches against 4.16:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
* mm-introduce-nr_indirectly_reclaimable_bytes.patch
* mm-treat-indirectly-reclaimable-memory-as-available-in-memavailable.patch
* dcache-account-external-names-as-indirectly-reclaimable-memory.patch
* mm-treat-indirectly-reclaimable-memory-as-free-in-overcommit-logic.patch
* mm-vmscan-update-stale-comments.patch
* mm-vmscan-remove-redundant-current_may_throttle-check.patch
* mm-vmscan-dont-change-pgdat-state-on-base-of-a-single-lru-list-state-v2.patch
* mm-vmscan-dont-mess-with-pgdat-flags-in-memcg-reclaim-v2.patch
* mm-vmscan-tracing-use-pointer-to-reclaim_stat-struct-in-trace-event.patch
* mm-hmm-documentation-editorial-update-to-hmm-documentation.patch
* mm-hmm-fix-header-file-if-else-endif-maze-v2.patch
* mm-hmm-hmm-should-have-a-callback-before-mm-is-destroyed-v3.patch
* mm-hmm-unregister-mmu_notifier-when-last-hmm-client-quit-v3.patch
* mm-hmm-hmm_pfns_bad-was-accessing-wrong-struct.patch
* mm-hmm-use-struct-for-hmm_vma_fault-hmm_vma_get_pfns-parameters-v2.patch
* mm-hmm-remove-hmm_pfn_read-flag-and-ignore-peculiar-architecture-v2.patch
* mm-hmm-use-uint64_t-for-hmm-pfn-instead-of-defining-hmm_pfn_t-to-ulong-v2.patch
* mm-hmm-cleanup-special-vma-handling-vm_special.patch
* mm-hmm-do-not-differentiate-between-empty-entry-or-missing-directory-v3.patch
* mm-hmm-rename-hmm_pfn_device_unaddressable-to-hmm_pfn_device_private.patch
* mm-hmm-move-hmm_pfns_clear-closer-to-where-it-is-use.patch
* mm-hmm-factor-out-pte-and-pmd-handling-to-simplify-hmm_vma_walk_pmd-v2.patch
* mm-hmm-change-hmm_vma_fault-to-allow-write-fault-on-page-basis.patch
* mm-hmm-use-device-driver-encoding-for-hmm-pfn-v2.patch
* hmm-remove-superflous-rcu-protection-around-radix-tree-lookup.patch
* mm-hmm-fix-header-file-if-else-endif-maze-again.patch
* documentation-vm-hmmtxt-typos-and-syntaxes-fixes.patch
* sched-numa-avoid-trapping-faults-and-attempting-migration-of-file-backed-dirty-pages.patch
* mm-check-__highest_present_sectioin_nr-directly-in-memory_dev_init.patch
* mm-migrate-properly-preserve-write-attribute-in-special-migrate-entry.patch
* memcg-thp-do-not-invoke-oom-killer-on-thp-charges.patch
* z3fold-fix-memory-leak.patch
* z3fold-use-gfpflags_allow_blocking.patch
* mm-ksm-fix-inconsistent-accounting-of-zero-pages.patch
* mm-memcg-make-sure-memoryevents-is-uptodate-when-waking-pollers.patch
* swap-divide-by-zero-when-zero-length-swap-file-on-ssd.patch
* memcg-fix-per_node_info-cleanup.patch
* mm-swap-make-pointer-swap_avail_heads-static.patch
* mm-numa-rework-do_pages_move.patch
* mm-migrate-remove-reason-argument-from-new_page_t.patch
* mm-unclutter-thp-migration.patch
* mm-page_alloc-dont-reserve-zone_highmem-for-zone_movable-request.patch
* mm-cma-manage-the-memory-of-the-cma-area-by-using-the-zone_movable.patch
* mm-cma-remove-alloc_cma.patch
* arm-cma-avoid-double-mapping-to-the-cma-area-if-config_highmem-=-y.patch
* mm-thp-dont-count-zone_movable-as-the-target-for-freepage-reserving.patch
* kasan-slub-fix-handling-of-kasan_slab_free-hook.patch
* kasan-fix-invalid-free-test-crashing-the-kernel.patch
* kasan-disallow-compiler-to-optimize-away-memset-in-tests.patch
* procfs-add-seq_put_hex_ll-to-speed-up-proc-pid-maps.patch
* procfs-optimize-seq_pad-to-speed-up-proc-pid-maps.patch
* proc-get-rid-of-task-lock-unlock-pair-to-read-umask-for-the-status-file.patch
* proc-do-less-stuff-under-pde_unload_lock.patch
* proc-move-proc-sysvipc-creation-to-where-it-belongs.patch
* proc-faster-open-close-of-files-without-release-hook.patch
* proc-randomize-struct-pde_opener.patch
* proc-move-struct-pde_opener-to-kmem-cache.patch
* proc-account-struct-pde_opener.patch
* proc-add-seq_put_decimal_ull_width-to-speed-up-proc-pid-smaps.patch
* proc-replace-seq_printf-on-seq_putc-to-speed-up-proc-pid-smaps.patch
* proc-optimize-single-symbol-delimiters-to-spead-up-seq_put_decimal_ull.patch
* proc-replace-seq_printf-by-seq_put_smth-to-speed-up-proc-pid-status.patch
* proc-check-permissions-earlier-for-proc-wchan.patch
* proc-use-set_puts-at-proc-wchan.patch
* fs-sysctl-fix-potential-page-fault-while-unregistering-sysctl-table.patch
* fs-sysctl-remove-redundant-link-check-in-proc_sys_link_fill_cache.patch
* proc-test-proc-self-wchan.patch
* proc-test-proc-self-syscall.patch
* proc-move-struct-proc_dir_entry-into-kmem-cache.patch
* proc-fix-proc-map_files-lookup-some-more.patch
* proc-register-filesystem-last.patch
* proc-faster-proc-cmdline.patch
* proc-do-mmput-asap-for-proc-map_files.patch
* proc-test-last-field-of-proc-loadavg.patch
* proc-reject-and-as-filenames.patch
* proc-switch-struct-proc_dir_entry-count-to-refcount.patch
* proc-shotgun-test-read-readdir-readlink-a-little-write.patch
* proc-use-slower-rb_first.patch
* proc-test-proc-uptime.patch
* taint-convert-to-indexed-initialization.patch
* taint-consolidate-documentation.patch
* taint-add-taint-for-randstruct.patch
* uts-create-struct-uts_namespace-from-kmem_cache.patch
* clang-format-add-configuration-file.patch
* task_struct-only-use-anon-struct-under-randstruct-plugin.patch
* maintainers-update-email-address-for-alexandre-bounine.patch
* lib-kconfigdebug-debug-lockups-and-hangs-keep-softlockup-options-together.patch
* test_bitmap-do-not-accidentally-use-stack-vla.patch
* lib-add-testing-module-for-ubsan.patch
* lib-add-testing-module-for-ubsan-fix.patch
* list_debug-print-unmangled-addresses.patch
* checkpatch-improve-parse_email-signature-checking.patch
* checkpatchpl-add-spdx-license-tag-check.patch
* checkpatch-add-crypto-on_stack-to-declaration_macros.patch
* checkpatch-add-sub-routine-get_stat_real.patch
* checkpatch-remove-unused-variable-declarations.patch
* checkpatch-add-sub-routine-get_stat_here.patch
* checkpatch-warn-for-use-of-%px.patch
* checkpatch-improve-get_quoted_string-for-trace_event-macros.patch
* checkpatch-two-spelling-fixes.patch
* checkpatch-test-symbolic_perms-multiple-times-per-line.patch
* checkpatch-add-test-for-assignment-at-start-of-line.patch
* checkpatch-allow-space-between-colon-and-bracket.patch
* checkpatch-whinge-about-bool-bitfields.patch
* init-ramdisk-use-pr_cont-at-the-end-of-ramdisk-loading.patch
* autofs4-use-wait_event_killable.patch
* fs-reiserfs-journalc-add-missing-resierfs_warning-arg.patch
* seq_file-allocate-seq_file-from-kmem_cache.patch
* seq_file-account-everything.patch
* exec-pass-stack-rlimit-into-mm-layout-functions.patch
* exec-introduce-finalize_exec-before-start_thread.patch
* exec-pin-stack-limit-during-exec.patch
* rapidio-fix-typo-in-comment.patch
* rapidio-use-a-reference-count-for-struct-mport_dma_req.patch
* sysctl-fix-sizeof-argument-to-match-variable-name.patch
* kernel-downgrade-warning-for-unsafe-parameters.patch
* ipc-shm-introduce-shmctlshm_stat_any.patch
* ipc-sem-introduce-semctlsem_stat_any.patch
* ipc-msg-introduce-msgctlmsg_stat_any.patch
* proc-sysctl-fix-typo-in-sysctl_check_table_array.patch
* sysctl-add-kdoc-comments-to-do_proc_douintvec_minmax_conv_param.patch
* ipc-shmc-shm_split-remove-unneeded-test-for-null-shm_file_datavm_ops.patch
* kfifo-fix-comment.patch
* dcache-add-cond_resched-in-shrink_dentry_list.patch
* maintainers-update-bouncing-aacraid-adapteccom-addresses.patch
* mm-introduce-map_fixed_safe.patch
* fs-elf-drop-map_fixed-usage-from-elf_map.patch
* elf-enforce-map_fixed-on-overlaying-elf-segments.patch
* xen-mm-allow-deferred-page-initialization-for-xen-pv-domains.patch
* linux-consth-prefix-include-guard-of-uapi-linux-consth-with-_uapi.patch
* linux-consth-move-ul-macro-to-include-linux-consth.patch
* linux-consth-refactor-_bitul-and-_bitull-a-bit.patch
* radix-tree-use-gfp_zonemask-bits-of-gfp_t-for-flags.patch
* mac80211_hwsim-use-define_ida.patch
* arm64-turn-flush_dcache_mmap_lock-into-a-no-op.patch
* unicore32-turn-flush_dcache_mmap_lock-into-a-no-op.patch
* export-__set_page_dirty.patch
* fscache-use-appropriate-radix-tree-accessors.patch
* xarray-add-the-xa_lock-to-the-radix_tree_root.patch
* page-cache-use-xa_lock.patch
* resource-fix-integer-overflow-at-reallocation-v1.patch
* resource-fix-integer-overflow-at-reallocation.patch
* mm-gup_benchmark-handle-gup-failures.patch
* mm-gup_benchmark-handle-gup-failures-fix.patch
* gup-return-efault-on-access_ok-failure.patch
* mm-gup-document-return-value.patch
* mm-filemap-provide-dummy-filemap_page_mkwrite-for-nommu.patch
* mm-pagemap-fix-swap-offset-value-for-pmd-migration-entry.patch
* mm-pagemap-fix-swap-offset-value-for-pmd-migration-entry-fix.patch
* ipc-shm-fix-use-after-free-of-shm-file-via-remap_file_pages.patch
* ipc-shm-fix-use-after-free-of-shm-file-via-remap_file_pages-v2.patch
* writeback-safer-lock-nesting.patch
* writeback-safer-lock-nesting-fix.patch
* kexec-export-pg_swapbacked-to-vmcoreinfo.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* prctl-add-pr_et_pdeathsig_proc.patch
* ocfs2-get-rid-of-ocfs2_is_o2cb_active-function.patch
* ocfs2-without-quota-support-try-to-avoid-calling-quota-recovery.patch
* ocfs2-without-quota-support-try-to-avoid-calling-quota-recovery-checkpatch-fixes.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* dentry-fix-kmemcheck-splat-at-take_dentry_name_snapshot.patch
  mm.patch
* mm-sparse-add-a-static-variable-nr_present_sections.patch
* mm-sparsemem-defer-the-ms-section_mem_map-clearing.patch
* mm-sparse-add-a-new-parameter-data_unit_size-for-alloc_usemap_and_memmap.patch
* mm-swap-fix-race-between-swapoff-and-some-swap-operations.patch
* mm-swap-fix-race-between-swapoff-and-some-swap-operations-v6.patch
* mm-fix-race-between-swapoff-and-mincore.patch
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
* mm-dont-expose-page-to-fast-gup-before-its-ready.patch
* mm-page_owner-align-with-pageblock_nr_pages.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* mm-kasan-dont-vfree-nonexistent-vm_area.patch
* proc-revalidate-misc-dentries.patch
* rslib-remove-vlas-by-setting-upper-bound-on-nroots.patch
* checkpatch-add-a-strict-test-for-structs-with-bool-member-definitions.patch
* coredump-fix-spam-with-zero-vma-process.patch
* seq_file-delete-small-value-optimization.patch
* fork-unconditionally-clear-stack-on-fork.patch
* exofs-avoid-vla-in-structures.patch
  linux-next.patch
  linux-next-rejects.patch
  linux-next-fixup.patch
* kexec_file-make-an-use-of-purgatory-optional.patch
* kexec_file-make-an-use-of-purgatory-optional-fix.patch
* kexec_filex86powerpc-factor-out-kexec_file_ops-functions.patch
* x86-kexec_file-purge-system-ram-walking-from-prepare_elf64_headers.patch
* x86-kexec_file-remove-x86_64-dependency-from-prepare_elf64_headers.patch
* x86-kexec_file-lift-crash_max_ranges-limit-on-crash_mem-buffer.patch
* x86-kexec_file-clean-up-prepare_elf64_headers.patch
* kexec_file-x86-move-re-factored-code-to-generic-side.patch
* kexec_file-silence-compile-warnings.patch
* kexec_file-remove-checks-in-kexec_purgatory_load.patch
* kexec_file-make-purgatory_info-ehdr-const.patch
* kexec_file-search-symbols-in-read-only-kexec_purgatory.patch
* kexec_file-use-read-only-sections-in-arch_kexec_apply_relocations.patch
* kexec_file-split-up-__kexec_load_puragory.patch
* kexec_file-remove-unneeded-for-loop-in-kexec_purgatory_setup_sechdrs.patch
* kexec_file-remove-unneeded-variables-in-kexec_purgatory_setup_sechdrs.patch
* kexec_file-remove-mis-use-of-sh_offset-field-during-purgatory-load.patch
* kexec_file-allow-archs-to-set-purgatory-load-address.patch
* kexec_file-move-purgatories-sha256-to-common-code.patch
* resource-add-walk_system_ram_res_rev.patch
* kexec_file-load-kernel-at-top-of-system-ram-if-required.patch
* mm-memcg-remote-memcg-charging-for-kmem-allocations.patch
* mm-memcg-remote-memcg-charging-for-kmem-allocations-fix.patch
* fs-fsnotify-account-fsnotify-metadata-to-kmemcg.patch
* fs-fsnotify-account-fsnotify-metadata-to-kmemcg-fix.patch
* fix-read-buffer-overflow-in-delta-ipc.patch
* sparc64-ng4-memset-32-bits-overflow.patch
  make-sure-nobodys-leaking-resources.patch
  releasing-resources-with-children.patch
  mutex-subsystem-synchro-test-module.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  slab-leaks3-default-y.patch
  workaround-for-a-pci-restoring-bug.patch
