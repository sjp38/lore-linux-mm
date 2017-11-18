Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id ABF7A280253
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 19:18:28 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id 5so2803449wmk.8
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 16:18:28 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p76si3515054wmg.48.2017.11.17.16.18.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Nov 2017 16:18:26 -0800 (PST)
Date: Fri, 17 Nov 2017 16:18:23 -0800
From: akpm@linux-foundation.org
Subject: mmotm 2017-11-17-16-17 uploaded
Message-ID: <5a0f7c4f.T3UdVwuRSnDL5xp1%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2017-11-17-16-17 has been uploaded to

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


This mmotm tree contains the following patches against 4.14:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
* mm-fix-nodemask-printing.patch
* z3fold-use-kref-to-prevent-page-free-compact-race.patch
* dma-debug-fix-incorrect-pfn-calculation.patch
* mm-shmem-remove-unused-info-variable.patch
* mm-compaction-kcompactd-should-not-ignore-pageblock-skip.patch
* mm-compaction-persistently-skip-hugetlbfs-pageblocks.patch
* mm-compaction-extend-pageblock_skip_persistent-to-all-compound-pages.patch
* mm-compaction-split-off-flag-for-not-updating-skip-hints.patch
* mm-compaction-remove-unneeded-pageblock_skip_persistent-checks.patch
* proc-coredump-add-coredumping-flag-to-proc-pid-status.patch
* proc-uninline-name_to_int.patch
* proc-use-do-while-in-name_to_int.patch
* spellingtxt-add-unnecessary-typo-variants.patch
* sh-boot-add-static-stack-protector-to-pre-kernel.patch
* support-resetting-warn_once.patch
* support-resetting-warn_once-for-all-architectures.patch
* parse-maintainers-add-ability-to-specify-filenames.patch
* iopoll-avoid-wint-in-bool-context-warning.patch
* lkdtm-include-warn-format-string.patch
* bug-define-the-cut-here-string-in-a-single-place.patch
* bug-fix-cut-here-location-for-__warn_taint-architectures.patch
* compiler-clang-handle-randomizable-anonymous-structs.patch
* umh-optimize-proc_cap_handler.patch
* dynamic_debug-fix-optional-omitted-ending-line-number-to-be-large-instead-of-0.patch
* dynamic_debug-minor-fixes-to-documentation.patch
* scripts-warn-about-invalid-maintainers-patterns.patch
* get_maintainer-add-more-self-test-options.patch
* bitfieldh-include-linux-build_bugh-instead-of-linux-bugh.patch
* radix-tree-remove-unneeded-include-linux-bugh.patch
* lib-add-module-support-to-string-tests.patch
* lib-test-delete-five-error-messages-for-a-failed-memory-allocation.patch
* lib-int_sqrt-optimize-small-argument.patch
* lib-int_sqrt-optimize-initial-value-compute.patch
* lib-int_sqrt-adjust-comments.patch
* genalloc-make-the-avail-variable-an-atomic_long_t.patch
* lib_backtrace-fix-kernel-text-address-leak.patch
* lib-traceevent-clean-up-clang-build-warning.patch
* lib-rbtree-test-lower-default-params.patch
* lib-test-module-for-find__bit-functions.patch
* checkpatch-support-function-pointers-for-unnamed-function-definition-arguments.patch
* scripts-checkpatchpl-avoid-false-warning-missing-break.patch
* checkpatch-printks-always-need-a-kern_level.patch
* checkpatch-allow-define_per_cpu-definitions-to-exceed-line-length.patch
* checkpatch-add-tp_printk-to-list-of-logging-functions.patch
* checkpatch-add-strict-test-for-lines-ending-in-or.patch
* checkpatch-do-not-check-missing-blank-line-before-builtin__driver.patch
* epoll-account-epitem-and-eppoll_entry-to-kmemcg.patch
* epoll-avoid-calling-ep_call_nested-from-ep_poll_safewake.patch
* epoll-remove-ep_call_nested-from-ep_eventpoll_poll.patch
* init-version-include-linux-exporth-instead-of-linux-moduleh.patch
* autofs-dont-fail-mount-for-transient-error.patch
* pipe-match-pipe_max_size-data-type-with-procfs.patch
* pipe-avoid-round_pipe_size-nr_pages-overflow-on-32-bit.patch
* pipe-add-proc_dopipe_max_size-to-safely-assign-pipe_max_size.patch
* sysctl-check-for-uint_max-before-unsigned-int-min-max.patch
* fs-nilfs2-convert-timers-to-use-timer_setup.patch
* nilfs2-fix-race-condition-that-causes-file-system-corruption.patch
* fs-nilfs-convert-nilfs_rootcount-from-atomic_t-to-refcount_t.patch
* nilfs2-align-block-comments-of-nilfs_sufile_truncate_range-at.patch
* nilfs2-use-octal-for-unreadable-permission-macro.patch
* nilfs2-remove-inode-i_version-initialization.patch
* hfs-hfsplus-clean-up-unused-variables-in-bnodec.patch
* fat-remove-redundant-assignment-of-0-to-slots.patch
* protect-the-traced-signal_unkillable-tasks-from-sigkill.patch
* protect-the-signal_unkillable-tasks-from-sig_kernel_only-signals.patch
* remove-the-no-longer-needed-signal_unkillable-check-in-complete_signal.patch
* kdump-print-a-message-in-case-parse_crashkernel_mem-resulted-in-zero-bytes.patch
* rapidio-idt_gen2-constify-rio_device_id.patch
* rapidio-fix-resources-leak-in-error-handling-path-in-rio_dma_transfer.patch
* rapidio-fix-an-error-handling-in-rio_dma_transfer.patch
* fix-a-typo-in-documentation-sysctl-vmtxt.patch
* fix-code-style-warning.patch
* pid-replace-pid-bitmap-implementation-with-idr-api.patch
* pid-remove-pidhash.patch
* kernel-panic-add-taint_aux.patch
* kcov-remove-pointless-current-=-null-check.patch
* kcov-support-comparison-operands-collection.patch
* makefile-support-flag-fsanitizer-coverage=trace-cmp.patch
* kcov-update-documentation.patch
* kernel-reboot-add-devm_register_reboot_notifier.patch
* watchdog-core-make-use-of-devm_register_reboot_notifier.patch
* initramfs-use-time64_t-timestamps.patch
* sysvipc-unteach-ids-next_id-for-checkpoint_restore.patch
* sysvipc-duplicate-lock-comments-wrt-ipc_addid.patch
* sysvipc-properly-name-ipc_addid-limit-parameter.patch
* sysvipc-make-get_maxid-o1-again.patch
* mm-add-infrastructure-for-get_user_pages_fast-benchmarking.patch
* pcmcia-badge4-avoid-unused-function-warning.patch
* ia64-topology-remove-the-unused-parent_node-macro.patch
* sh-numa-remove-the-unused-parent_node-macro.patch
* sparc64-topology-remove-the-unused-parent_node-macro.patch
* tile-topology-remove-the-unused-parent_node-macro.patch
* asm-generic-numa-remove-the-unused-parent_node-macro.patch
* expert-kconfig-menu-fix-broken-expert-menu.patch
* scripts-decodecode-fix-decoding-for-aarch64-arm64-instructions.patch
* mm-skip-hwpoisoned-pages-when-onlining-pages.patch
* mm-memory_hotplug-do-not-back-off-draining-pcp-free-pages-from-kworker-context.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* prctl-add-pr_et_pdeathsig_proc.patch
* ocfs2-get-rid-of-ocfs2_is_o2cb_active-function.patch
* ocfs2-give-an-obvious-tip-for-dismatch-cluster-names.patch
* ocfs2-give-an-obvious-tip-for-dismatch-cluster-names-v2.patch
* ocfs2-move-some-definitions-to-header-file.patch
* ocfs2-fix-some-small-problems.patch
* ocfs2-add-kobject-for-online-file-check.patch
* ocfs2-add-duplicative-ino-number-check.patch
* ocfs2-fix-qs_holds-may-could-not-be-zero.patch
* ocfs2-dlm-wait-for-dlm-recovery-done-when-migrating-all-lockres.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* dentry-fix-kmemcheck-splat-at-take_dentry_name_snapshot.patch
  mm.patch
* include-linux-sched-mmh-uninline-mmdrop_async-etc.patch
* mm-make-count-list_lru_one-nr_items-lockless.patch
* mm-madvise-enable-soft-offline-of-hugetlb-pages-at-pud-level.patch
* mm-readahead-increase-maximum-readahead-window.patch
* proc-do-not-show-vmexe-bigger-than-total-executable-virtual-memory.patch
* mm-oom_reaper-gather-each-vma-to-prevent-leaking-tlb-entry.patch
* mm-fix-device-dax-pud-write-faults-triggered-by-get_user_pages.patch
* mm-replace-pud_write-with-pud_access_permitted-in-fault-gup-paths.patch
* mm-replace-pmd_write-with-pmd_access_permitted-in-fault-gup-paths.patch
* mm-replace-pte_write-with-pte_access_permitted-in-fault-gup-paths.patch
* mm-hugetlb-drop-hugepages_treat_as_movable-sysctl.patch
* mm-page_alloc-return-0-in-case-this-node-has-no-page-within-the-zone.patch
* mm-vmscan-do-not-pass-reclaimed-slab-to-vmpressure.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* mm-walk-the-zone-in-pageblock_nr_pages-steps.patch
* seq_file-delete-small-value-optimization.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* uapi-fix-linux-sysctlh-userspace-compilation-errors.patch
  linux-next.patch
  linux-next-rejects.patch
  linux-next-git-rejects.patch
* tools-objtool-makefile-dont-assume-sync-checksh-is-executable.patch
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
