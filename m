Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1D8A86B0069
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 19:37:53 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id x24so217130046pfa.0
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 16:37:53 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e186si6224270pfc.146.2016.09.09.16.37.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Sep 2016 16:37:51 -0700 (PDT)
Date: Fri, 09 Sep 2016 16:37:50 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2016-09-09-16-37 uploaded
Message-ID: <57d347ce.eUFXIfowjgXlmixO%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2016-09-09-16-37 has been uploaded to

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


This mmotm tree contains the following patches against 4.8-rc5:
(patches marked "*" will be included in linux-next)

  origin.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  i-need-old-gcc.patch
* mem-hotplug-dont-clear-the-only-node-in-new_node_page.patch
* ocfs2-dlm-fix-race-between-convert-and-migration.patch
* maintainers-modify-maintainers-email-of-intelfb.patch
* khugepaged-fix-use-after-free-in-collapse_huge_page.patch
* mm-slab-improve-performance-of-gathering-slabinfo-stats.patch
* mm-page_alloc-replace-set_dma_reserve-to-set_memory_reserve.patch
* stackdepot-fix-mempolicy-use-after-free.patch
* mm-thp-fix-leaking-mapped-pte-in-__collapse_huge_page_swapin.patch
* mm-avoid-endless-recursion-in-dump_page.patch
* maintainers-update-email-for-vlynq-bus-entry.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* kbuild-simpler-generation-of-assembly-constants.patch
* fs-ocfs2-dlmfs-remove-deprecated-create_singlethread_workqueue.patch
* fs-ocfs2-cluster-remove-deprecated-create_singlethread_workqueue.patch
* fs-ocfs2-super-remove-deprecated-create_singlethread_workqueue.patch
* fs-ocfs2-dlm-remove-deprecated-create_singlethread_workqueue.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* kernel-watchdog-use-nmi-registers-snapshot-in-hardlockup-handler.patch
  mm.patch
* mm-oom-deduplicate-victim-selection-code-for-memcg-and-global-oom.patch
* mm-zsmalloc-add-trace-events-for-zs_compact.patch
* mm-zsmalloc-add-per-class-compact-trace-event.patch
* mm-vmalloc-fix-align-value-calculation-error.patch
* mm-vmalloc-fix-align-value-calculation-error-fix.patch
* mm-vmalloc-fix-align-value-calculation-error-v2.patch
* mm-vmalloc-fix-align-value-calculation-error-v2-fix.patch
* mm-vmalloc-fix-align-value-calculation-error-v2-fix-fix.patch
* mm-vmalloc-fix-align-value-calculation-error-v2-fix-fix-fix.patch
* mm-memcontrol-add-sanity-checks-for-memcg-idref-on-get-put.patch
* mm-oom_killc-fix-task_will_free_mem-comment.patch
* mm-compaction-make-whole_zone-flag-ignore-cached-scanner-positions.patch
* mm-compaction-make-whole_zone-flag-ignore-cached-scanner-positions-checkpatch-fixes.patch
* mm-compaction-cleanup-unused-functions.patch
* mm-compaction-rename-compact_partial-to-compact_success.patch
* mm-compaction-dont-recheck-watermarks-after-compact_success.patch
* mm-compaction-add-the-ultimate-direct-compaction-priority.patch
* mm-compaction-add-the-ultimate-direct-compaction-priority-fix.patch
* mm-compaction-use-correct-watermark-when-checking-compaction-success.patch
* mm-compaction-create-compact_gap-wrapper.patch
* mm-compaction-create-compact_gap-wrapper-fix.patch
* mm-compaction-use-proper-alloc_flags-in-__compaction_suitable.patch
* mm-compaction-require-only-min-watermarks-for-non-costly-orders.patch
* mm-compaction-require-only-min-watermarks-for-non-costly-orders-fix.patch
* mm-vmscan-make-compaction_ready-more-accurate-and-readable.patch
* mem-hotplug-fix-node-spanned-pages-when-we-have-a-movable-node.patch
* mm-fix-set-pageblock-migratetype-in-deferred-struct-page-init.patch
* mm-vmscan-get-rid-of-throttle_vm_writeout.patch
* mm-debug_pagealloc-clean-up-guard-page-handling-code.patch
* mm-debug_pagealloc-dont-allocate-page_ext-if-we-dont-use-guard-page.patch
* mm-page_owner-move-page_owner-specific-function-to-page_ownerc.patch
* mm-page_ext-rename-offset-to-index.patch
* mm-page_ext-support-extra-space-allocation-by-page_ext-user.patch
* mm-page_owner-dont-define-fields-on-struct-page_ext-by-hard-coding.patch
* do_generic_file_read-fail-immediately-if-killed.patch
* mm-pagewalk-fix-the-comment-for-test_walk.patch
* mm-unrig-vma-cache-hit-ratio.patch
* mm-swap-add-swap_cluster_list.patch
* mm-swap-add-swap_cluster_list-checkpatch-fixes.patch
* mmoom_reaper-reduce-find_lock_task_mm-usage.patch
* mmoom_reaper-do-not-attempt-to-reap-a-task-twice.patch
* oom-keep-mm-of-the-killed-task-available.patch
* kernel-oom-fix-potential-pgd_lock-deadlock-from-__mmdrop.patch
* mm-oom-get-rid-of-signal_struct-oom_victims.patch
* oom-suspend-fix-oom_killer_disable-vs-pm-suspend-properly.patch
* mm-oom-enforce-exit_oom_victim-on-current-task.patch
* mm-make-sure-that-kthreads-will-not-refault-oom-reaped-memory.patch
* oom-oom_reaper-allow-to-reap-mm-shared-by-the-kthreads.patch
* mm-use-zonelist-name-instead-of-using-hardcoded-index.patch
* mm-introduce-arch_reserved_kernel_pages.patch
* mm-memblock-expose-total-reserved-memory.patch
* powerpc-implement-arch_reserved_kernel_pages.patch
* mm-nobootmemc-remove-duplicate-macro-arch_low_address_limit-statements.patch
* mm-bootmemc-replace-kzalloc-by-kzalloc_node.patch
* mm-dont-use-radix-tree-writeback-tags-for-pages-in-swap-cache.patch
* mm-check-that-we-havent-used-more-than-32-bits-in-address_spaceflags.patch
* oom-warn-if-we-go-oom-for-higher-order-and-compaction-is-disabled.patch
* mm-mlock-check-against-vma-for-actual-mlock-size.patch
* mm-mlock-check-against-vma-for-actual-mlock-size-fix.patch
* mm-mlock-check-against-vma-for-actual-mlock-size-fix-2.patch
* mm-mlock-avoid-increase-mm-locked_vm-on-mlock-when-already-mlock2mlock_onfault.patch
* selftest-split-mlock2_-funcs-into-separate-mlock2h.patch
* selftests-vm-add-test-for-mlock-when-areas-are-intersected.patch
* selftest-move-seek_to_smaps_entry-out-of-mlock2-testsc.patch
* selftests-expanding-more-mlock-selftest.patch
* thp-dax-add-thp_get_unmapped_area-for-pmd-mappings.patch
* ext2-4-xfs-call-thp_get_unmapped_area-for-pmd-mappings.patch
* cpu-fix-node-state-for-whether-it-contains-cpu.patch
* mm-proc-make-the-task_mmu-walk_page_range-limit-in-clear_refs_write-obvious.patch
* thp-reduce-usage-of-huge-zero-pages-atomic-counter.patch
* mm-memcontrol-make-the-walk_page_range-limit-obvious.patch
* memory-hotplug-fix-store_mem_state-return-value.patch
* mm-fix-cache-mode-tracking-in-vm_insert_mixed.patch
* mm-swap-use-offset-of-swap-entry-as-key-of-swap-cache.patch
* mm-remove-page_file_index.patch
* revert-mm-oom-prevent-premature-oom-killer-invocation-for-high-order-request.patch
* mm-compaction-more-reliably-increase-direct-compaction-priority.patch
* mm-compaction-restrict-full-priority-to-non-costly-orders.patch
* mm-compaction-make-full-priority-ignore-pageblock-suitability.patch
* mm-dont-emit-warning-from-pagefault_out_of_memory.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* mm-walk-the-zone-in-pageblock_nr_pages-steps.patch
* proc-much-faster-proc-vmstat.patch
* proc-faster-proc-status.patch
* seq-proc-modify-seq_put_decimal_ll-to-take-a-const-char-not-char.patch
* seq-proc-modify-seq_put_decimal_ll-to-take-a-const-char-not-char-fix.patch
* meminfo-break-apart-a-very-long-seq_printf-with-ifdefs.patch
* proc-relax-proc-tid-timerslack_ns-capability-requirements.patch
* proc-add-lsm-hook-checks-to-proc-tid-timerslack_ns.patch
* proc-fix-timerslack_ns-cap_sys_nice-check-when-adjusting-self.patch
* proc-unsigned-file-descriptors.patch
* min-max-remove-sparse-warnings-when-theyre-nested.patch
* nmi_backtrace-add-more-trigger__cpu_backtrace-methods.patch
* nmi_backtrace-do-a-local-dump_stack-instead-of-a-self-nmi.patch
* arch-tile-adopt-the-new-nmi_backtrace-framework.patch
* nmi_backtrace-generate-one-line-reports-for-idle-cpus.patch
* spellingtxt-modeled-is-spelt-correctly.patch
* uprobes-remove-function-declarations-from-arch-mipss390.patch
* set-git-diff-driver-for-c-source-code-files.patch
* cred-simpler-1d-supplementary-groups.patch
* console-dont-prefer-first-registered-if-dt-specifies-stdout-path.patch
* radix-tree-slot-can-be-null-in-radix_tree_next_slot.patch
* radix-tree-tests-add-iteration-test.patch
* radix-tree-tests-properly-initialize-mutex.patch
* lib-harden-strncpy_from_user.patch
* make-isdigit-table-lookupless.patch
* kstrtox-smaller-_parse_integer.patch
* lib-add-crc64-ecma-module.patch
* compat-remove-compat_printk.patch
* checkpatch-see-if-modified-files-are-marked-obsolete-in-maintainers.patch
* checkpatch-look-for-symbolic-permissions-and-suggest-octal-instead.patch
* checkpatch-test-multiple-line-block-comment-alignment.patch
* checkpatch-dont-test-for-prefer-ether_addr_foo.patch
* checkpatch-externalize-the-structs-that-should-be-const.patch
* const_structscheckpatch-add-frequently-used-from-julia-lawalls-list.patch
* checkpatch-speed-up-checking-for-filenames-in-sections-marked-obsolete.patch
* checkpatch-improve-the-block-comment-alignment-test.patch
* autofs-fix-typos-in-documentation-filesystems-autofs4txt.patch
* autofs-drop-unnecessary-extern-in-autofs_ih.patch
* autofs-test-autofs-versions-first-on-sb-initialization.patch
* autofs-fix-autofs4_fill_super-error-exit-handling.patch
* autofs-add-warn_on1-for-non-dir-link-inode-case.patch
* autofs-remove-ino-free-in-autofs4_dir_symlink.patch
* autofs-use-autofs4_free_ino-to-kfree-dentry-data.patch
* autofs-remove-obsolete-sb-fields.patch
* autofs-dont-fail-to-free_dev_ioctlparam.patch
* autofs-remove-autofs_devid_len.patch
* autofs-fix-documentation-regarding-devid-on-ioctl.patch
* autofs-update-struct-autofs_dev_ioctl-in-documentation.patch
* autofs-fix-pr_debug-message.patch
* autofs-fix-dev-ioctl-number-range-check.patch
* autofs-fix-dev-ioctl-number-range-check-fix.patch
* autofs-add-autofs_dev_ioctl_version-for-autofs_dev_ioctl_version_cmd.patch
* autofs-fix-print-format-for-ioctl-warning-message.patch
* autofs-move-inclusion-of-linux-limitsh-to-uapi.patch
* autofs4-move-linux-auto_dev-ioctlh-to-uapi-linux.patch
* autofs-remove-possibly-misleading-define-debug.patch
* autofs-refactor-ioctl-fn-vector-in-iookup_dev_ioctl.patch
* pipe-relocate-round_pipe_size-above-pipe_set_size.patch
* pipe-move-limit-checking-logic-into-pipe_set_size.patch
* pipe-refactor-argument-for-account_pipe_buffers.patch
* pipe-fix-limit-checking-in-pipe_set_size.patch
* pipe-simplify-logic-in-alloc_pipe_info.patch
* pipe-fix-limit-checking-in-alloc_pipe_info.patch
* pipe-make-account_pipe_buffers-return-a-value-and-use-it.patch
* pipe-cap-initial-pipe-capacity-according-to-pipe-max-size-limit.patch
* ptrace-clear-tif_syscall_trace-on-ptrace-detach.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* rapidio-rio_cm-use-memdup_user-instead-of-duplicating-code.patch
* random-simplify-api-for-random-address-requests.patch
* x86-use-simpler-api-for-random-address-requests.patch
* arm-use-simpler-api-for-random-address-requests.patch
* arm64-use-simpler-api-for-random-address-requests.patch
* tile-use-simpler-api-for-random-address-requests.patch
* unicore32-use-simpler-api-for-random-address-requests.patch
* random-remove-unused-randomize_range.patch
* dma-mapping-introduce-the-dma_attr_no_warn-attribute.patch
* powerpc-implement-the-dma_attr_no_warn-attribute.patch
* nvme-use-the-dma_attr_no_warn-attribute.patch
* x86-panic-replace-smp_send_stop-with-kdump-friendly-version-in-panic-path.patch
* mips-panic-replace-smp_send_stop-with-kdump-friendly-version-in-panic-path.patch
* relay-use-irq_work-instead-of-plain-timer-for-deferred-wakeup.patch
* relay-use-irq_work-instead-of-plain-timer-for-deferred-wakeup-checkpatch-fixes.patch
* config-android-remove-config_ipv6_privacy.patch
* config-android-move-device-mapper-options-to-recommended.patch
* config-android-set-selinux-as-default-security-mode.patch
* config-android-enable-config_seccomp.patch
* ipc-semc-fix-complex_count-vs-simple-op-race.patch
* ipc-msg-implement-lockless-pipelined-wakeups.patch
* ipc-msg-batch-queue-sender-wakeups.patch
* ipc-msg-make-ss_wakeup-kill-arg-boolean.patch
* ipc-msg-lockless-security-checks-for-msgsnd.patch
* ipc-msg-avoid-waking-sender-upon-full-queue.patch
* ipc-msg-avoid-waking-sender-upon-full-queue-checkpatch-fixes.patch
  linux-next.patch
  linux-next-rejects.patch
* drivers-net-wireless-intel-iwlwifi-dvm-calibc-fix-min-warning.patch
* include-linux-mlx5-deviceh-kill-build_bug_ons.patch
* kdump-vmcoreinfo-report-memory-sections-virtual-addresses.patch
* mm-kmemleak-avoid-using-__va-on-addresses-that-dont-have-a-lowmem-mapping.patch
* enable-code-completion-in-vim.patch
* kthread-rename-probe_kthread_data-to-kthread_probe_data.patch
* kthread-kthread-worker-api-cleanup.patch
* kthread-kthread-worker-api-cleanup-fix.patch
* kthread-smpboot-do-not-park-in-kthread_create_on_cpu.patch
* kthread-allow-to-call-__kthread_create_on_node-with-va_list-args.patch
* kthread-add-kthread_create_worker.patch
* kthread-add-kthread_destroy_worker.patch
* kthread-detect-when-a-kthread-work-is-used-by-more-workers.patch
* kthread-initial-support-for-delayed-kthread-work.patch
* kthread-allow-to-cancel-kthread-work.patch
* kthread-allow-to-modify-delayed-kthread-work.patch
* kthread-better-support-freezable-kthread-workers.patch
* kthread-add-kerneldoc-for-kthread_create.patch
* hung_task-allow-hung_task_panic-when-hung_task_warnings-is-0.patch
* hung_task-allow-hung_task_panic-when-hung_task_warnings-is-0-fix.patch
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
