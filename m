Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id AC0C46B007E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 18:34:52 -0400 (EDT)
Received: by mail-pf0-f179.google.com with SMTP id n5so328695752pfn.2
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 15:34:52 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n90si10422949pfj.124.2016.03.22.15.34.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Mar 2016 15:34:51 -0700 (PDT)
Date: Tue, 22 Mar 2016 15:34:50 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2016-03-22-15-34 uploaded
Message-ID: <56f1c88a.yEZmtb3XUuDzB4om%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2016-03-22-15-34 has been uploaded to

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


This mmotm tree contains the following patches against 4.5:
(patches marked "*" will be included in linux-next)

  origin.patch
* ocfs2-export-ocfs2_kset-for-online-file-check.patch
* ocfs2-sysfile-interfaces-for-online-file-check.patch
* ocfs2-create-remove-sysfile-for-online-file-check.patch
* ocfs2-check-fix-inode-block-for-online-file-check.patch
* ocfs2-add-feature-document-for-online-file-check.patch
* zram-revive-swap_slot_free_notify.patch
* kernel-hung_taskc-use-timeout-diff-when-timeout-is-updated.patch
* compat-add-in_compat_syscall-to-ask-whether-were-in-a-compat-syscall.patch
* sparc-compat-provide-an-accurate-in_compat_syscall-implementation.patch
* sparc-syscall-fix-syscall_get_arch.patch
* seccomp-check-in_compat_syscall-not-is_compat_task-in-strict-mode.patch
* ptrace-in-peek_siginfo-check-syscall-bitness-not-task-bitness.patch
* auditsc-for-seccomp-events-log-syscall-compat-state-using-in_compat_syscall.patch
* staging-lustre-switch-from-is_compat_task-to-in_compat_syscall.patch
* ext4-in-ext4_dir_llseek-check-syscall-bitness-directly.patch
* net-sctp-use-in_compat_syscall-for-sctp_getsockopt_connectx3.patch
* net-xfrm_user-use-in_compat_syscall-to-deny-compat-syscalls.patch
* firewire-use-in_compat_syscall-to-check-ioctl-compatness.patch
* efivars-use-in_compat_syscall-to-check-for-compat-callers.patch
* amdkfd-use-in_compat_syscall-to-check-open-caller-type.patch
* input-redefine-input_compat_test-as-in_compat_syscall.patch
* uhid-check-write-bitness-using-in_compat_syscall.patch
* x86-compat-remove-is_compat_task.patch
* fat-add-config-option-to-set-utf-8-mount-option-by-default.patch
* ptrace-change-__ptrace_unlink-to-clear-ptrace-under-siglock.patch
* fs-coredump-prevent-fsuid=0-dumps-into-user-controlled-directories.patch
* cpumask-remove-incorrect-information-from-comment.patch
* rapidio-rionet-fix-deadlock-on-smp.patch
* rapidio-rionet-add-capability-to-change-mtu.patch
* rapidio-tsi721-fix-hardcoded-mrrs-setting.patch
* rapidio-tsi721-add-check-for-overlapped-ib-window-mappings.patch
* rapidio-tsi721-add-option-to-configure-direct-mapping-of-ib-window.patch
* rapidio-tsi721_dma-fix-pending-transaction-queue-handling.patch
* rapidio-add-query_mport-operation.patch
* rapidio-tsi721-add-query_mport-callback.patch
* rapidio-add-shutdown-notification-for-rapidio-devices.patch
* rapidio-tsi721-add-shutdown-notification-callback.patch
* rapidio-rionet-add-shutdown-event-handling.patch
* rapidio-rework-common-rio-device-add-delete-routines.patch
* rapidio-move-net-allocation-into-core-code.patch
* rapidio-add-core-mport-removal-support.patch
* rapidio-tsi721-add-hw-specific-mport-removal.patch
* powerpc-fsl_rio-changes-to-mport-registration.patch
* rapidio-rionet-add-locking-into-add-remove-device.patch
* rapidio-rionet-add-mport-removal-handling.patch
* rapidio-add-lock-protection-for-doorbell-list.patch
* rapidio-move-rio_local_set_device_id-function-to-the-common-core.patch
* rapidio-move-rio_pw_enable-into-core-code.patch
* rapidio-add-global-inbound-port-write-interfaces.patch
* rapidio-tsi721-fix-locking-in-ob_msg-processing.patch
* rapidio-add-outbound-window-support.patch
* rapidio-tsi721-add-outbound-windows-mapping-support.patch
* rapidio-tsi721-add-filtered-debug-output.patch
* rapidio-tsi721_dma-update-error-reporting-from-prep_sg-callback.patch
* rapidio-tsi721_dma-fix-synchronization-issues.patch
* rapidio-tsi721_dma-fix-hardware-error-handling.patch
* rapidio-add-mport-char-device-driver.patch
* cred-userns-define-current_user_ns-as-a-function.patch
* eventfd-document-lockless-access-in-eventfd_poll.patch
* panic-change-nmi_panic-from-macro-to-function.patch
* ipmi-watchdog-use-nmi_panic-when-kernel-panics-in-nmi-handler.patch
* hpwdt-use-nmi_panic-when-kernel-panics-in-nmi-handler.patch
* profile-hide-unused-functions-when-config_proc_fs.patch
* kernel-add-kcov-code-coverage.patch
* scripts-gdb-add-version-command.patch
* scripts-gdb-add-cmdline-reader-command.patch
* scripts-gdb-account-for-changes-in-module-data-structure.patch
* kfifo-fix-sparse-complains.patch
* ubsan-fix-tree-wide-wmaybe-uninitialized-false-positives.patch
* ipc-sem-make-semctl-setting-sempid-consistent.patch
* mm-mprotectc-dont-imply-prot_exec-on-non-exec-fs.patch
* add-compile-time-check-for-__arch_si_preamble_size.patch
* memremap-dont-modify-flags.patch
* memremap-add-memremap_wc-flag.patch
* drivers-dma-coherent-use-memremap_wc-for-dma_memory_map.patch
* drivers-dma-coherent-use-memset_io-for-dma_memory_io-mappings.patch
* kernel-convert-pr_warning-to-pr_warn.patch
* alpha-extable-use-generic-search-and-sort-routines.patch
* s390-extable-use-generic-search-and-sort-routines.patch
* x86-extable-use-generic-search-and-sort-routines.patch
* ia64-extable-use-generic-search-and-sort-routines.patch
  i-need-old-gcc.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  drivers-gpu-drm-i915-intel_spritec-fix-build.patch
  drivers-gpu-drm-i915-intel_tvc-fix-build.patch
* drivers-input-eliminate-input_compat_test-macro.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* fs-ext4-fsyncc-generic_file_fsync-call-based-on-barrier-flag.patch
* ocfs2-add-ocfs2_write_type_t-type-to-identify-the-caller-of-write.patch
* ocfs2-use-c_new-to-indicate-newly-allocated-extents.patch
* ocfs2-test-target-page-before-change-it.patch
* ocfs2-do-not-change-i_size-in-write_end-for-direct-io.patch
* ocfs2-return-the-physical-address-in-ocfs2_write_cluster.patch
* ocfs2-record-unwritten-extents-when-populate-write-desc.patch
* ocfs2-fix-sparse-file-data-ordering-issue-in-direct-io.patch
* ocfs2-code-clean-up-for-direct-io.patch
* ocfs2-code-clean-up-for-direct-io-fix.patch
* ocfs2-fix-ip_unaligned_aio-deadlock-with-dio-work-queue.patch
* ocfs2-fix-ip_unaligned_aio-deadlock-with-dio-work-queue-fix.patch
* ocfs2-take-ip_alloc_sem-in-ocfs2_dio_get_block-ocfs2_dio_end_io_write.patch
* ocfs2-fix-disk-file-size-and-memory-file-size-mismatch.patch
* ocfs2-fix-a-deadlock-issue-in-ocfs2_dio_end_io_write.patch
* ocfs2-dlm-fix-race-between-convert-and-recovery.patch
* ocfs2-dlm-fix-race-between-convert-and-recovery-v2.patch
* ocfs2-dlm-fix-race-between-convert-and-recovery-v3.patch
* ocfs2-dlm-fix-bug-in-dlm_move_lockres_to_recovery_list.patch
* ocfs2-extend-transaction-for-ocfs2_remove_rightmost_path-and-ocfs2_update_edge_lengths-before-to-avoid-inconsistency-between-inode-and-et.patch
* extend-enough-credits-for-freeing-one-truncate-record-while-replaying-truncate-records.patch
* ocfs2-avoid-occurring-deadlock-by-changing-ocfs2_wq-from-global-to-local.patch
* ocfs2-solve-a-problem-of-crossing-the-boundary-in-updating-backups.patch
* ocfs2-o2hb-add-negotiate-timer.patch
* ocfs2-o2hb-add-nego_timeout-message.patch
* ocfs2-o2hb-add-negotiate_approve-message.patch
* ocfs2-o2hb-add-some-user-debug-log.patch
* ocfs2-o2hb-dont-negotiate-if-last-hb-fail.patch
* ocfs2-o2hb-fix-hb-hung-time.patch
* ocfs2-dlm-move-lock-to-the-tail-of-grant-queue-while-doing-in-place-convert.patch
* ocfs2-dlm-move-lock-to-the-tail-of-grant-queue-while-doing-in-place-convert-fix.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
  mm.patch
* sched-add-schedule_timeout_idle.patch
* mm-oom-introduce-oom-reaper.patch
* oom-reaper-handle-mlocked-pages.patch
* oom-clear-tif_memdie-after-oom_reaper-managed-to-unmap-the-address-space.patch
* oom-clear-tif_memdie-after-oom_reaper-managed-to-unmap-the-address-space-fix-2.patch
* mm-oom_reaper-report-success-failure.patch
* mm-oom_reaper-report-success-failure-fix.patch
* mm-oom_reaper-report-success-failure-fix-2.patch
* mm-oom_reaper-report-success-failure-fix-fix.patch
* mm-oom_reaper-implement-oom-victims-queuing.patch
* mm-oom_reaper-implement-oom-victims-queuing-fix.patch
* oom-make-oom_reaper-freezable.patch
* oom-oom_reaper-disable-oom_reaper-for-oom_kill_allocating_task.patch
* ksm-introduce-ksm_max_page_sharing-per-page-deduplication-limit.patch
* ksm-introduce-ksm_max_page_sharing-per-page-deduplication-limit-fix-2.patch
* ksm-introduce-ksm_max_page_sharing-per-page-deduplication-limit-fix-3.patch
* mm-make-optimistic-check-for-swapin-readahead.patch
* mm-make-optimistic-check-for-swapin-readahead-fix-2.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-2.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-3.patch
* kasan-modify-kmalloc_large_oob_right-add-kmalloc_pagealloc_oob_right.patch
* mm-kasan-slab-support.patch
* mm-kasan-added-gfp-flags-to-kasan-api.patch
* arch-ftrace-for-kasan-put-hard-soft-irq-entries-into-separate-sections.patch
* mm-kasan-stackdepot-implementation-enable-stackdepot-for-slab.patch
* mm-kasan-stackdepot-implementation-enable-stackdepot-for-slab-fix.patch
* mm-kasan-stackdepot-implementation-enable-stackdepot-for-slab-v8.patch
* kasan-test-fix-warn-if-the-uaf-could-not-be-detected-in-kmalloc_uaf2.patch
* mm-kasan-initial-memory-quarantine-implementation.patch
* mm-kasan-initial-memory-quarantine-implementation-v8.patch
* mm-oom-rework-oom-detection.patch
* mm-oom-rework-oom-detection-checkpatch-fixes.patch
* mm-throttle-on-io-only-when-there-are-too-many-dirty-and-writeback-pages.patch
* mm-use-watermak-checks-for-__gfp_repeat-high-order-allocations.patch
* mm-use-watermak-checks-for-__gfp_repeat-high-order-allocations-checkpatch-fixes.patch
* mm-memblock-if-nr_new-is-0-just-return.patch
* mm-utilc-add-kstrimdup.patch
* lib-add-crc64-ecma-module.patch
* kexec-introduce-a-protection-mechanism-for-the-crashkernel-reserved-memory.patch
* kexec-provide-arch_kexec_protectunprotect_crashkres.patch
* kexec-make-a-pair-of-map-unmap-reserved-pages-in-error-path.patch
* kexec-do-a-cleanup-for-function-kexec_load.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* ipc-semc-fix-complex_count-vs-simple-op-race.patch
* ipc-msgc-msgsnd-use-freezable-blocking-call.patch
* msgrcv-use-freezable-blocking-call.patch
  linux-next.patch
  linux-next-git-rejects.patch
* drivers-net-wireless-intel-iwlwifi-dvm-calibc-fix-min-warning.patch
* staging-goldfish-use-6-arg-get_user_pages.patch
  mm-add-strictlimit-knob-v2.patch
  do_shared_fault-check-that-mmap_sem-is-held.patch
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
