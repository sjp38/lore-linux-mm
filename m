Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 9CB466B0005
	for <linux-mm@kvack.org>; Fri,  1 Mar 2013 18:51:37 -0500 (EST)
Received: by mail-gh0-f202.google.com with SMTP id z10so397687ghb.3
        for <linux-mm@kvack.org>; Fri, 01 Mar 2013 15:51:36 -0800 (PST)
Subject: mmotm 2013-03-01-15-50 uploaded
From: akpm@linux-foundation.org
Date: Fri, 01 Mar 2013 15:51:35 -0800
Message-Id: <20130301235135.E9F105A41B2@corp2gmr1-2.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

The mm-of-the-moment snapshot 2013-03-01-15-50 has been uploaded to

   http://www.ozlabs.org/~akpm/mmotm/

mmotm-readme.txt says

README for mm-of-the-moment:

http://www.ozlabs.org/~akpm/mmotm/

This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
more than once a week.

You will need quilt to apply these patches to the latest Linus release (3.x
or 3.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
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

http://git.cmpxchg.org/?p=linux-mmotm.git;a=summary

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

	http://git.cmpxchg.org/?p=linux-mmots.git;a=summary

and use of this tree is similar to
http://git.cmpxchg.org/?p=linux-mmotm.git, described above.


This mmotm tree contains the following patches against 3.8:
(patches marked "*" will be included in linux-next)

  origin.patch
  linux-next.patch
  linux-next-git-rejects.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  i-need-old-gcc.patch
* ipc-fix-potential-oops-when-src-msg-4k-w-msg_copy.patch
* ipc-dont-allocate-a-copy-larger-than-max.patch
* mm-mempolicyc-fix-wrong-sp_node-insertion.patch
* mm-mempolicyc-fix-sp_node_init-argument-ordering.patch
* shmem-fix-build-regression.patch
* shmem-fix-build-regression-fix.patch
* idr-remove-warn_on_once-on-negative-ids.patch
* x86-acpi-mm-revert-movablemem_map-support.patch
* kmsg-honor-dmesg_restrict-sysctl-on-dev-kmsg.patch
* drivers-platform-x86-thinkpad_acpic-move-hotkey_thread_mutex-lock-after-set_freezable.patch
* arm-wire-up-kcmp-syscall.patch
* x86-make-mem=-option-to-work-for-efi-platform.patch
* mm-remove-free_area_cache-use-in-powerpc-architecture.patch
* mm-use-vm_unmapped_area-on-powerpc-architecture.patch
* drm-fb-helper-dont-sleep-for-screen-unblank-when-an-oopps-is-in-progress.patch
* matroxfb-convert-struct-i2c_msg-initialization-to-c99-format.patch
* cyber2000fb-avoid-palette-corruption-at-higher-clocks.patch
* timer_list-split-timer_list_show_tickdevices.patch
* timer_list-split-timer_list_show_tickdevices-v4.patch
* timer_list-convert-timer-list-to-be-a-proper-seq_file.patch
* timer_list-convert-timer-list-to-be-a-proper-seq_file-v3.patch
* timer_list-convert-timer-list-to-be-a-proper-seq_file-v3-fix.patch
* mkcapflagspl-convert-to-mkcapflagssh.patch
* headers_installpl-convert-to-headers_installsh.patch
* scripts-decodecode-make-faulting-insn-ptr-more-robust.patch
* ipvs-change-type-of-netns_ipvs-sysctl_sync_qlen_max.patch
* debug_locksh-make-warning-more-verbose.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* fs-block_devc-need-not-to-check-inode-i_bdev-in-bd_forget.patch
* fs-return-eagain-when-o_nonblock-write-should-block-on-frozen-fs.patch
* fs-fix-hang-with-bsd-accounting-on-frozen-filesystem.patch
* ocfs2-add-freeze-protection-to-ocfs2_file_splice_write.patch
* watchdog-trigger-all-cpu-backtrace-when-locked-up-and-going-to-panic.patch
  mm.patch
* hwpoison-check-dirty-flag-to-match-against-clean-page.patch
* mm-trace-filemap-add-and-del.patch
* mm-show_mem-suppress-page-counts-in-non-blockable-contexts.patch
* mm-remove-free_area_cache.patch
* include-linux-mmzoneh-cleanups.patch
* include-linux-mmzoneh-cleanups-fix.patch
* mm-memmap_init_zone-performance-improvement.patch
* drop_caches-add-some-documentation-and-info-messsge.patch
* drivers-usb-gadget-amd5536udcc-avoid-calling-dma_pool_create-with-null-dev.patch
* mm-dmapoolc-fix-null-dev-in-dma_pool_create.patch
* memcg-debugging-facility-to-access-dangling-memcgs.patch
* memcg-debugging-facility-to-access-dangling-memcgs-fix.patch
* mm-add-vm-event-counters-for-balloon-pages-compaction.patch
* early_printk-consolidate-random-copies-of-identical-code.patch
* smp-give-warning-when-calling-smp_call_function_many-single-in-serving-irq.patch
* include-linux-fsh-disable-preempt-when-acquire-i_size_seqcount-write-lock.patch
* kernel-smpc-cleanups.patch
* printk-avoid-softlockups-in-console_unlock.patch
* drivers-video-backlight-ams369fg06c-convert-ams369fg06-to-dev_pm_ops.patch
* drivers-video-backlight-ams369fg06c-convert-ams369fg06-to-dev_pm_ops-fix.patch
* backlight-platform_lcd-remove-unnecessary-ifdefs.patch
* drivers-leds-leds-ot200c-fix-error-caused-by-shifted-mask.patch
* lib-int_sqrtc-optimize-square-root-algorithm.patch
* epoll-support-for-disabling-items-and-a-self-test-app.patch
* epoll-support-for-disabling-items-and-a-self-test-app-fix.patch
* binfmt_elfc-use-get_random_int-to-fix-entropy-depleting.patch
* i2o-check-copy_from_user-size-parameter.patch
* rtc-rtc-mv-add-__init-annotation.patch
* rtc-rtc-davinci-add-__exit-annotation.patch
* rtc-rtc-ds1302-add-__exit-annotation.patch
* rtc-rtc-imxdi-add-__init-__exit-annotation.patch
* rtc-rtc-nuc900-add-__init-__exit-annotation.patch
* rtc-rtc-pcap-add-__init-__exit-annotation.patch
* rtc-rtc-tegra-add-__init-__exit-annotation.patch
* rtc-add-devm_rtc_device_registerunregister.patch
* rtc-max77686-use-module_platform_driver.patch
* rtc-max77686-add-missing-module-author-name.patch
* rtc-max77686-use-devm_kzalloc.patch
* rtc-max77686-fix-indentation-of-bit-definitions.patch
* rtc-max77686-use-dev_info-dev_emerg-instead-of-pr_info-pr_emerg.patch
* rtc-rtc-v3020-use-gpio_request_array.patch
* drivers-rtc-rtc-pxac-fix-set-time-sync-time-issue.patch
* drivers-rtc-rtc-pxac-fix-set-time-sync-time-issue-fix.patch
* rtc-ds1307-long-block-operations-bugfix.patch
* rtc-rtc-palmas-use-devm_request_threaded_irq.patch
* coredump-only-sigkill-should-interrupt-the-coredumping-task.patch
* coredump-ensure-that-sigkill-always-kills-the-dumping-thread.patch
* coredump-sanitize-the-setting-of-signal-group_exit_code.patch
* coredump-factor-out-the-setting-of-pf_dumpcore.patch
* freezer-do-not-send-a-fake-signal-to-a-pf_dumpcore-thread.patch
* coredump-make-wait_for_dump_helpers-freezable.patch
* procfs-improve-scaling-in-proc.patch
* kexec-fix-wrong-types-of-some-local-variables.patch
* kexec-use-min_t-to-simplify-logic.patch
* kexec-use-min_t-to-simplify-logic-fix.patch
* ipc-clamp-with-min.patch
* ipc-separate-msg-allocation-from-userspace-copy.patch
* ipc-tighten-msg-copy-loops.patch
* ipc-set-efault-as-default-error-in-load_msg.patch
* ipc-remove-msg-handling-from-queue-scan.patch
* ipc-implement-msg_copy-as-a-new-receive-mode.patch
* ipc-simplify-msg-list-search.patch
* ipc-refactor-msg-list-search-into-separate-function.patch
* ipc-semc-alternatives-to-preempt_disable.patch
* semaphore-give-an-unlikely-for-downs-timeout.patch
* semaphore-boolize-semaphore_waiters-up.patch
* mm-remove-old-aio-use_mm-comment.patch
* aio-remove-dead-code-from-aioh.patch
* gadget-remove-only-user-of-aio-retry.patch
* aio-remove-retry-based-aio.patch
* char-add-aio_readwrite-to-dev-nullzero.patch
* aio-kill-return-value-of-aio_complete.patch
* aio-kiocb_cancel.patch
* aio-kiocb_cancel-fix.patch
* aio-move-private-stuff-out-of-aioh.patch
* aio-dprintk-pr_debug.patch
* aio-do-fget-after-aio_get_req.patch
* aio-make-aio_put_req-lockless.patch
* aio-refcounting-cleanup.patch
* wait-add-wait_event_hrtimeout.patch
* wait-add-wait_event_hrtimeout-fix.patch
* aio-make-aio_read_evt-more-efficient-convert-to-hrtimers.patch
* aio-use-flush_dcache_page.patch
* aio-use-cancellation-list-lazily.patch
* aio-use-cancellation-list-lazily-fix.patch
* aio-use-cancellation-list-lazily-fix-fix.patch
* aio-change-reqs_active-to-include-unreaped-completions.patch
* aio-kill-batch-allocation.patch
* aio-kill-struct-aio_ring_info.patch
* aio-give-shared-kioctx-fields-their-own-cachelines.patch
* aio-give-shared-kioctx-fields-their-own-cachelines-fix.patch
* aio-reqs_active-reqs_available.patch
* aio-percpu-reqs_available.patch
* generic-dynamic-per-cpu-refcounting.patch
* generic-dynamic-per-cpu-refcounting-fix.patch
* generic-dynamic-per-cpu-refcounting-sparse-fixes.patch
* generic-dynamic-per-cpu-refcounting-sparse-fixes-fix.patch
* generic-dynamic-per-cpu-refcounting-doc.patch
* generic-dynamic-per-cpu-refcounting-doc-fix.patch
* aio-percpu-ioctx-refcount.patch
* aio-use-xchg-instead-of-completion_lock.patch
* aio-dont-include-aioh-in-schedh.patch
* aio-dont-include-aioh-in-schedh-fix.patch
* aio-dont-include-aioh-in-schedh-fix-fix.patch
* aio-dont-include-aioh-in-schedh-fix-3.patch
* aio-dont-include-aioh-in-schedh-fix-3-fix.patch
* aio-dont-include-aioh-in-schedh-fix-3-fix-fix.patch
* aio-kill-ki_key.patch
* aio-kill-ki_retry.patch
* aio-kill-ki_retry-fix.patch
* aio-kill-ki_retry-fix-fix.patch
* block-aio-batch-completion-for-bios-kiocbs.patch
* block-aio-batch-completion-for-bios-kiocbs-fix.patch
* block-aio-batch-completion-for-bios-kiocbs-fix-fix.patch
* block-aio-batch-completion-for-bios-kiocbs-fix-fix-fix.patch
* block-aio-batch-completion-for-bios-kiocbs-fix-fix-fix-fix.patch
* block-aio-batch-completion-for-bios-kiocbs-fix-fix-fix-fix-fix.patch
* block-aio-batch-completion-for-bios-kiocbs-fix-fix-fix-fix-fix-fix.patch
* block-aio-batch-completion-for-bios-kiocbs-fix-fix-fix-fix-fix-fix-fix.patch
* virtio-blk-convert-to-batch-completion.patch
* mtip32xx-convert-to-batch-completion.patch
* mtip32xx-convert-to-batch-completion-fix.patch
* aio-fix-aio_read_events_ring-types.patch
* aio-document-clarify-aio_read_events-and-shadow_tail.patch
* aio-correct-calculation-of-available-events.patch
* aio-v2-fix-kioctx-not-being-freed-after-cancellation-at-exit-time.patch
* aio-v3-fix-kioctx-not-being-freed-after-cancellation-at-exit-time.patch
* kconfig-consolidate-config_debug_strict_user_copy_checks.patch
* kernel-sysc-make-prctlpr_set_mm-generally-available.patch
  debugging-keep-track-of-page-owners.patch
  debugging-keep-track-of-page-owners-fix.patch
  debugging-keep-track-of-page-owners-fix-2.patch
  debugging-keep-track-of-page-owners-fix-2-fix.patch
  debugging-keep-track-of-page-owners-fix-2-fix-fix.patch
  debugging-keep-track-of-page-owners-fix-2-fix-fix-fix.patch
  debugging-keep-track-of-page-owner-now-depends-on-stacktrace_support.patch
  make-sure-nobodys-leaking-resources.patch
  journal_add_journal_head-debug.patch
  releasing-resources-with-children.patch
  make-frame_pointer-default=y.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  mutex-subsystem-synchro-test-module.patch
  slab-leaks3-default-y.patch
  put_bh-debug.patch
  add-debugging-aid-for-memory-initialisation-problems.patch
  workaround-for-a-pci-restoring-bug.patch
  single_open-seq_release-leak-diagnostics.patch
  add-a-refcount-check-in-dput.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
