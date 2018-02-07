Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8E64C6B02AF
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 19:42:30 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id x188so1698188wmg.2
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 16:42:30 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g8si410909wmf.45.2018.02.06.16.42.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Feb 2018 16:42:28 -0800 (PST)
Date: Tue, 06 Feb 2018 16:42:25 -0800
From: akpm@linux-foundation.org
Subject: mmotm 2018-02-06-16-41 uploaded
Message-ID: <5a7a4b71.HAtX9yinrx1GndbX%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2018-02-06-16-41 has been uploaded to

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


This mmotm tree contains the following patches against 4.15:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
* kasan-dont-emit-builtin-calls-when-sanitization-is-off.patch
* kasan-add-compiler-support-for-clang.patch
* kasan-makefile-support-llvm-style-asan-parameters.patch
* kasan-support-alloca-poisoning.patch
* kasan-add-tests-for-alloca-poisoning.patch
* kasan-added-functions-for-unpoisoning-stack-variables.patch
* kasan-detect-invalid-frees-for-large-objects.patch
* kasan-dont-use-__builtin_return_address1.patch
* kasan-detect-invalid-frees-for-large-mempool-objects.patch
* kasan-unify-code-between-kasan_slab_free-and-kasan_poison_kfree.patch
* kasan-detect-invalid-frees.patch
* kasan-fix-prototype-author-email-address.patch
* kasan-clean-up-kasan_shadow_scale_shift-usage.patch
* kasan-remove-redundant-initialization-of-variable-real_size.patch
* proc-use-%u-for-pid-printing-and-slightly-less-stack.patch
* proc-dont-use-read_once-write_once-for-proc-fail-nth.patch
* proc-fix-proc-map_files-lookup.patch
* proc-simpler-proc-vmcore-cleanup.patch
* proc-less-memory-for-proc-map_files-readdir.patch
* proc-delete-children_seq_release.patch
* fs-proc-kcorec-use-probe_kernel_read-instead-of-memcpy.patch
* proc-rearrange-struct-proc_dir_entry.patch
* proc-fixup-comment.patch
* proc-spread-__ro_after_init.patch
* proc-spread-likely-unlikely-a-bit.patch
* proc-rearrange-args.patch
* fs-proc-use-seq_putc-in-show_console_dev.patch
* makefile-move-stack-protector-compiler-breakage-test-earlier.patch
* makefile-move-stack-protector-availability-out-of-kconfig.patch
* makefile-introduce-config_cc_stackprotector_auto.patch
* uuid-cleanup-uapi-linux-uuidh.patch
* tools-lib-subcmd-do-not-alias-select-params.patch
* revert-async-simplify-lowest_in_progress.patch
* maintainers-update-sboyds-email-address.patch
* bitmap-new-bitmap_copy_safe-and-bitmap_fromto_arr32.patch
* bitmap-replace-bitmap_fromto_u32array.patch
* bitmap-add-bitmap_zero-bitmap_clear-test-cases.patch
* bitmap-add-bitmap_fill-bitmap_set-test-cases.patch
* bitmap-clean-up-test_zero_fill_copy-test-case-and-rename.patch
* bitmap-make-bitmap_fill-and-bitmap_zero-consistent.patch
* lib-stackdepot-use-a-non-instrumented-version-of-memcmp.patch
* lib-test_find_bitc-rename-to-find_bit_benchmarkc.patch
* lib-find_bit_benchmarkc-improvements.patch
* lib-optimize-cpumask_next_and.patch
* make-runtime_tests-a-menuconfig-to-ease-disabling-it-all.patch
* lib-add-module-unload-support-to-sort-tests.patch
* checkpatch-allow-long-lines-containing-url.patch
* checkpatch-ignore-some-octal-permissions-of-0.patch
* checkpatch-improve-quoted-string-and-line-continuation-test.patch
* checkpatch-add-a-few-device_attr-style-tests.patch
* checkpatch-improve-the-tabstop-test-to-include-declarations.patch
* checkpatch-exclude-drivers-staging-from-if-with-unnecessary-parentheses-test.patch
* checkpatch-avoid-some-false-positives-for-tabstop-declaration-test.patch
* checkpatch-improve-open_brace-test.patch
* elf-fix-nt_file-integer-overflow.patch
* kallsyms-let-print_ip_sym-print-raw-addresses.patch
* nilfs2-use-time64_t-internally.patch
* hfsplus-honor-setgid-flag-on-directories.patch
* asm-generic-siginfoh-fix-language-in-comments.patch
* forkc-check-error-and-return-early.patch
* forkc-add-doc-about-usage-of-clone_fs-flags-and-namespaces.patch
* cpumask-make-cpumask_size-return-unsigned-int.patch
* rapidio-delete-an-error-message-for-a-failed-memory-allocation-in-rio_init_mports.patch
* rapidio-adjust-12-checks-for-null-pointers.patch
* rapidio-adjust-five-function-calls-together-with-a-variable-assignment.patch
* rapidio-improve-a-size-determination-in-five-functions.patch
* rapidio-delete-an-unnecessary-variable-initialisation-in-three-functions.patch
* rapidio-return-an-error-code-only-as-a-constant-in-two-functions.patch
* rapidio-move-12-export_symbol_gpl-calls-to-function-implementations.patch
* rapidio-tsi721_dma-delete-an-error-message-for-a-failed-memory-allocation-in-tsi721_alloc_chan_resources.patch
* rapidio-tsi721_dma-delete-an-unnecessary-variable-initialisation-in-tsi721_alloc_chan_resources.patch
* rapidio-tsi721_dma-adjust-six-checks-for-null-pointers.patch
* pids-introduce-find_get_task_by_vpid-helper.patch
* pps-parport-use-timespec64-instead-of-timespec.patch
* revert-kernel-relayc-fix-potential-memory-leak.patch
* kcov-detect-double-association-with-a-single-task.patch
* genl_magic-remove-own-build_bug_on-defines.patch
* build_bugh-remove-build_bug_on_null.patch
* lib-ubsanc-s-missaligned-misaligned.patch
* lib-ubsan-add-type-mismatch-handler-for-new-gcc-clang.patch
* lib-ubsan-remove-returns-nonnull-attribute-checks.patch
* ipc-fix-ipc-data-structures-inconsistency.patch
* ipc-mqueue-wq_add-priority-changed-to-dynamic-priority.patch
* score-setup-combine-two-seq_printf-calls-into-one-call-in-show_cpuinfo.patch
* vfs-remove-might_sleep-from-clear_inode.patch
* mm-remove-duplicate-includes.patch
* mm-remove-unneeded-kallsyms-include.patch
* hrtimer-remove-unneeded-kallsyms-include.patch
* genirq-remove-unneeded-kallsyms-include.patch
* mm-memblock-memblock_is_map-region_memory-can-be-boolean.patch
* lib-lockref-__lockref_is_dead-can-be-boolean.patch
* kernel-cpuset-current_cpuset_is_being_rebound-can-be-boolean.patch
* kernel-resource-iomem_is_exclusive-can-be-boolean.patch
* kernel-module-module_is_live-can-be-boolean.patch
* kernel-mutex-mutex_is_locked-can-be-boolean.patch
* crash_dump-is_kdump_kernel-can-be-boolean.patch
* kasan-rework-kconfig-settings.patch
* pipe-sysctl-drop-min-parameter-from-pipe-max-size-converter.patch
* pipe-sysctl-remove-pipe_proc_fn.patch
* pipe-actually-allow-root-to-exceed-the-pipe-buffer-limits.patch
* pipe-fix-off-by-one-error-when-checking-buffer-limits.patch
* pipe-reject-f_setpipe_sz-with-size-over-uint_max.patch
* pipe-simplify-round_pipe_size.patch
* pipe-read-buffer-limits-atomically.patch
* mm-docs-fixup-punctuation.patch
* mm-docs-fix-parameter-names-mismatch.patch
* mm-docs-add-blank-lines-to-silence-sphinx-unexpected-indentation-errors.patch
* maintainers-remove-android-ion-pattern.patch
* maintainers-remove-arm-clkdev-support-file-pattern.patch
* maintainers-update-cortina-gemini-patterns.patch
* maintainers-update-arm-oxnas-platform-support-patterns.patch
* maintainers-update-various-palm-patterns.patch
* maintainers-update-arm-qualcomm-support-patterns.patch
* fix-a-typo-in-documentation-sysctl-usertxt.patch
* tools-fix-cross-compile-var-clobbering.patch
* mm-skip-hwpoisoned-pages-when-onlining-pages.patch
* include-linux-sched-mmh-re-inline-mmdrop.patch
* locking-qrwlock-include-asm-byteorderh-as-needed.patch
* kbuild-always-define-endianess-in-kconfigh.patch
* mm-memcontrol-fix-nr_writeback-leak-in-memcg-and-system-stats.patch
* fontswap-thp-fix.patch
* mm-mlock-vmscan-no-more-skipping-pagevecs.patch
* kernel-relay-limit-kmalloc-size-to-kmalloc_max_size.patch
* fix-const-confusion-in-certs-blacklist.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* prctl-add-pr_et_pdeathsig_proc.patch
* ocfs2-get-rid-of-ocfs2_is_o2cb_active-function.patch
* ocfs2-move-some-definitions-to-header-file.patch
* ocfs2-fix-some-small-problems.patch
* ocfs2-add-kobject-for-online-file-check.patch
* ocfs2-add-duplicative-ino-number-check.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* dentry-fix-kmemcheck-splat-at-take_dentry_name_snapshot.patch
  mm.patch
* mm-ksm-make-function-stable_node_dup-static.patch
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
* mm-introduce-map_fixed_safe-fix.patch
* fs-elf-drop-map_fixed-usage-from-elf_map.patch
* fs-elf-drop-map_fixed-usage-from-elf_map-fix.patch
* fs-elf-drop-map_fixed-usage-from-elf_map-checkpatch-fixes.patch
* fs-elf-drop-map_fixed-usage-from-elf_map-fix-fix.patch
* mm-dont-expose-page-to-fast-gup-before-its-ready.patch
* mm-swap-make-pointer-swap_avail_heads-static.patch
* mm-numa-rework-do_pages_move.patch
* mm-migrate-remove-reason-argument-from-new_page_t.patch
* mm-migrate-remove-reason-argument-from-new_page_t-fix.patch
* mm-migrate-remove-reason-argument-from-new_page_t-fix-fix.patch
* mm-migrate-remove-reason-argument-from-new_page_t-fix-3.patch
* mm-unclutter-thp-migration.patch
* mm-page_owner-align-with-pageblock_nr_pages.patch
* mm-make-count-list_lru_one-nr_items-lockless.patch
* mm-make-count-list_lru_one-nr_items-lockless-v2.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* mm-hwpoison-disable-memory-error-handling-on-1gb-hugepage.patch
* mm-hwpoison-disable-memory-error-handling-on-1gb-hugepage-v2.patch
* mm-kasan-dont-vfree-nonexistent-vm_area.patch
* procfs-add-seq_put_hex_ll-to-speed-up-proc-pid-maps.patch
* procfs-add-seq_put_hex_ll-to-speed-up-proc-pid-maps-v2.patch
* procfs-optimize-seq_pad-to-speed-up-proc-pid-maps.patch
* bugh-work-around-gcc-pr82365-in-bug.patch
* seq_file-delete-small-value-optimization.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* ida-do-zeroing-in-ida_pre_get.patch
* uapi-fix-linux-sysctlh-userspace-compilation-errors.patch
  linux-next.patch
  linux-next-rejects.patch
* ipc-mqueue-add-missing-error-code-in-init_mqueue_fs.patch
* net-netfilter-x_tablesc-remove-size-check.patch
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
