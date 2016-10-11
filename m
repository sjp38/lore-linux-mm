Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 91C946B0038
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 18:47:33 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id kc8so25707127pab.2
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 15:47:33 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m68si2555358pga.16.2016.10.11.15.47.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Oct 2016 15:47:32 -0700 (PDT)
Date: Tue, 11 Oct 2016 15:47:31 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2016-10-11-15-46 uploaded
Message-ID: <57fd6c03.MqL5gLzjGe1u5CBc%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2016-10-11-15-46 has been uploaded to

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


This mmotm tree contains the following patches against 4.8:
(patches marked "*" will be included in linux-next)

  origin.patch
* ocfs2-free-the-mle-while-the-res-had-one-to-avoid-mle-memory-leak.patch
* block-invalidate-the-page-cache-when-issuing-blkzeroout.patch
* block-require-write_same-and-discard-requests-align-to-logical-block-size.patch
* block-implement-some-of-fallocate-for-block-devices.patch
* fs-select-add-vmalloc-fallback-for-select2.patch
* radix-tree-slot-can-be-null-in-radix_tree_next_slot.patch
* radix-tree-tests-add-iteration-test.patch
* radix-tree-tests-properly-initialize-mutex.patch
* lib-harden-strncpy_from_user.patch
* make-isdigit-table-lookupless.patch
* kstrtox-smaller-_parse_integer.patch
* lib-bitmapc-enhance-bitmap-syntax.patch
* include-linux-provide-a-safe-version-of-container_of.patch
* llist-introduce-llist_entry_safe.patch
* checkpatch-see-if-modified-files-are-marked-obsolete-in-maintainers.patch
* checkpatch-look-for-symbolic-permissions-and-suggest-octal-instead.patch
* checkpatch-test-multiple-line-block-comment-alignment.patch
* checkpatch-dont-test-for-prefer-ether_addr_foo.patch
* checkpatch-externalize-the-structs-that-should-be-const.patch
* const_structscheckpatch-add-frequently-used-from-julia-lawalls-list.patch
* checkpatch-speed-up-checking-for-filenames-in-sections-marked-obsolete.patch
* checkpatch-improve-the-block-comment-alignment-test.patch
* checkpatch-add-strict-test-for-macro-argument-reuse.patch
* checkpatch-add-strict-test-for-precedence-challenged-macro-arguments.patch
* checkpatch-improve-macro_arg_precedence-test.patch
* checkpatch-add-warning-for-unnamed-function-definition-arguments.patch
* checkpatch-improve-the-octal-permissions-tests.patch
* kprobes-include-asm-sectionsh-instead-of-asm-generic-sectionsh.patch
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
* pps-kc-fix-non-tickless-system-config-dependency.patch
* relay-use-irq_work-instead-of-plain-timer-for-deferred-wakeup.patch
* config-android-remove-config_ipv6_privacy.patch
* config-android-move-device-mapper-options-to-recommended.patch
* config-android-set-selinux-as-default-security-mode.patch
* config-android-enable-config_seccomp.patch
* kcov-do-not-instrument-lib-stackdepotc.patch
* ipc-semc-fix-complex_count-vs-simple-op-race.patch
* ipc-msg-implement-lockless-pipelined-wakeups.patch
* ipc-msg-batch-queue-sender-wakeups.patch
* ipc-msg-make-ss_wakeup-kill-arg-boolean.patch
* ipc-msg-avoid-waking-sender-upon-full-queue.patch
* ipc-semc-add-cond_resched-in-exit_sme.patch
* kdump-vmcoreinfo-report-memory-sections-virtual-addresses.patch
* mm-kmemleak-avoid-using-__va-on-addresses-that-dont-have-a-lowmem-mapping.patch
* enable-code-completion-in-vim.patch
* kthread-rename-probe_kthread_data-to-kthread_probe_data.patch
* kthread-kthread-worker-api-cleanup.patch
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
* treewide-remove-redundant-include-linux-kconfigh.patch
* fs-use-mapping_set_error-instead-of-opencoded-set_bit.patch
* mm-split-gfp_mask-and-mapping-flags-into-separate-fields.patch
  i-need-old-gcc.patch
* mm-slab-fix-kmemcg-cache-creation-delayed-issue.patch
* kcov-properly-check-if-we-are-in-an-interrupt.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* kbuild-simpler-generation-of-assembly-constants.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* kernel-watchdog-use-nmi-registers-snapshot-in-hardlockup-handler.patch
  mm.patch
* mm-zsmalloc-add-trace-events-for-zs_compact.patch
* mm-zsmalloc-add-per-class-compact-trace-event.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* mm-walk-the-zone-in-pageblock_nr_pages-steps.patch
* lib-add-crc64-ecma-module.patch
* kexec_file-allow-arch-specific-memory-walking-for-kexec_add_buffer.patch
* kexec_file-change-kexec_add_buffer-to-take-kexec_buf-as-argument.patch
* kexec_file-factor-out-kexec_locate_mem_hole-from-kexec_add_buffer.patch
* powerpc-change-places-using-config_kexec-to-use-config_kexec_core-instead.patch
* powerpc-factor-out-relocation-code-from-module_64c-to-elf_util_64c.patch
* powerpc-generalize-elf64_apply_relocate_add.patch
* powerpc-adapt-elf64_apply_relocate_add-for-kexec_file_load.patch
* powerpc-add-functions-to-read-elf-files-of-any-endianness.patch
* powerpc-implement-kexec_file_load.patch
* powerpc-add-code-to-work-with-device-trees-in-kexec_file_load.patch
* powerpc-add-support-for-loading-elf-kernels-with-kexec_file_load.patch
* powerpc-add-support-for-loading-elf-kernels-with-kexec_file_load-fix.patch
* powerpc-add-purgatory-for-kexec_file_load-implementation.patch
* powerpc-add-purgatory-for-kexec_file_load-implementation-fix.patch
* powerpc-enable-config_kexec_file-in-powerpc-server-defconfigs.patch
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
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
  linux-next.patch
  linux-next-rejects.patch
  linux-next-git-rejects.patch
* drivers-net-wireless-intel-iwlwifi-dvm-calibc-fix-min-warning.patch
* include-linux-mlx5-deviceh-kill-build_bug_ons.patch
  mm-add-strictlimit-knob-v2.patch
  make-sure-nobodys-leaking-resources.patch
  releasing-resources-with-children.patch
  make-frame_pointer-default=y.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  mutex-subsystem-synchro-test-module.patch
  slab-leaks3-default-y.patch
  add-debugging-aid-for-memory-initialisation-problems.patch
  workaround-for-a-pci-restoring-bug.patch
  b.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
