Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id ED8206B0031
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 19:41:24 -0400 (EDT)
Received: by mail-gg0-f201.google.com with SMTP id 21so356115ggh.4
        for <linux-mm@kvack.org>; Thu, 18 Jul 2013 16:41:24 -0700 (PDT)
Subject: mmotm 2013-07-18-16-40 uploaded
From: akpm@linux-foundation.org
Date: Thu, 18 Jul 2013 16:41:22 -0700
Message-Id: <20130718234123.4170F31C022@corp2gmr1-1.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

The mm-of-the-moment snapshot 2013-07-18-16-40 has been uploaded to

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


This mmotm tree contains the following patches against 3.11-rc1:
(patches marked "*" will be included in linux-next)

  origin.patch
* revert-include-linux-smph-on_each_cpu-switch-back-to-a-macro.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  i-need-old-gcc.patch
* mm-mempolicy-fix-mbind_range-vma_adjust-interaction.patch
* ocfs2-refcounttree-add-the-missing-null-check-of-the-return-value-of-find_or_create_page.patch
* ocfs2-refcounttree-add-the-missing-null-check-of-the-return-value-of-find_or_create_page-fix.patch
* dmi_scan-add-comments-on-dmi_present-and-the-loop-in-dmi_scan_machine.patch
* maintainers-dynamic-debug-jasons-not-there.patch
* gitignore-ignore-lz4-files.patch
* rapidio-fix-use-after-free-in-rio_unregister_scan.patch
* mm-sched-numa-fix-numa-balancing-when-sched_debug.patch
* arch-x86-platform-ce4100-ce4100c-include-rebooth.patch
* mm-swapc-clear-pageactive-before-adding-pages-onto-unevictable-list.patch
* thp-mm-avoid-pageunevictable-on-active-inactive-lru-lists.patch
* drivers-thermal-x86_pkg_temp_thermalc-fix-lockup-of-cpu_down.patch
* mm-zbud-fix-condition-check-on-allocation-size.patch
* documentation-development-process-update-mm-and-next-urls.patch
* printk-move-to-separate-directory-for-easier-modification.patch
* printk-add-console_cmdlineh.patch
* printk-move-braille-console-support-into-separate-braille-files.patch
* printk-use-pointer-for-console_cmdline-indexing.patch
* printk-rename-struct-log-to-struct-printk_log.patch
* x86-make-mem=-option-to-work-for-efi-platform.patch
* drivers-pcmcia-pd6729c-convert-to-module_pci_driver.patch
* drivers-pcmcia-yenta_socketc-convert-to-module_pci_driver.patch
* drm-fb-helper-dont-sleep-for-screen-unblank-when-an-oopps-is-in-progress.patch
* drm-cirrus-correct-register-values-for-16bpp.patch
* drm-nouveau-make-vga_switcheroo-code-depend-on-vga_switcheroo.patch
* drivers-video-acornfbc-remove-dead-code.patch
* cyber2000fb-avoid-palette-corruption-at-higher-clocks.patch
* include-linux-interrupth-add-dummy-irq_set_irq_wake-for-generic_hardirqs.patch
* hrtimer-one-more-expiry-time-overflow-check-in-hrtimer_interrupt.patch
* drivers-infiniband-core-cmc-convert-to-using-idr_alloc_cyclic.patch
* drivers-mtd-chips-gen_probec-refactor-call-to-request_module.patch
* drivers-net-ethernet-ibm-ehea-ehea_mainc-add-alias-entry-for-portn-properties.patch
* misdn-add-support-for-group-membership-check.patch
* drivers-atm-he-convert-to-module_pci_driver.patch
* isdn-clean-up-debug-format-string-usage.patch
* ocfs2-should-call-ocfs2_journal_access_di-before-ocfs2_delete_entry-in-ocfs2_orphan_del.patch
* ocfs2-llseek-requires-ocfs2-inode-lock-for-the-file-in-seek_end.patch
* ocfs2-fix-issue-that-ocfs2_setattr-does-not-deal-with-new_i_size==i_size.patch
* ocfs2-fix-issue-that-ocfs2_setattr-does-not-deal-with-new_i_size==i_size-v2.patch
* ocfs2-update-inode-size-after-zeronig-the-hole.patch
* include-linux-schedh-dont-use-task-pid-tgid-in-same_thread_group-has_group_leader_pid.patch
* lockdep-introduce-lock_acquire_exclusive-shared-helper-macros.patch
* lglock-update-lockdep-annotations-to-report-recursive-local-locks.patch
* drivers-scsi-a100u2w-convert-to-module_pci_driver.patch
* drivers-scsi-dc395x-convert-to-module_pci_driver.patch
* drivers-scsi-dmx3191d-convert-to-module_pci_driver.patch
* drivers-scsi-initio-convert-to-module_pci_driver.patch
* drivers-scsi-mvumi-convert-to-module_pci_driver.patch
* drivers-net-irda-donauboe-convert-to-module_pci_driver.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* watchdog-trigger-all-cpu-backtrace-when-locked-up-and-going-to-panic.patch
* ssb-fix-alignment-of-struct-bcma_device_id.patch
  mm.patch
* mm-mempolicy-turn-vma_set_policy-into-vma_dup_policy.patch
* mm-madvisec-fix-coding-style-errors.patch
* swap-warn-when-a-swap-area-overflows-the-maximum-size.patch
* swap-warn-when-a-swap-area-overflows-the-maximum-size-fix.patch
* mm-swapfilec-convert-to-pr_foo.patch
* mm-shift-vm_grows-check-from-mmap_region-to-do_mmap_pgoff.patch
* mm-do_mmap_pgoff-cleanup-the-usage-of-file_inode.patch
* mm-mmap_region-kill-correct_wcount-inode-use-allow_write_access.patch
* mm-zswapc-get-swapper-address_space-by-using-macro.patch
* mm-drop-actor-argument-of-do_generic_file_read.patch
* mm-drop-actor-argument-of-do_shmem_file_read.patch
* thp-account-anon-transparent-huge-pages-into-nr_anon_pages.patch
* mm-cleanup-add_to_page_cache_locked.patch
* thp-move-maybe_pmd_mkwrite-out-of-mk_huge_pmd.patch
* thp-do_huge_pmd_anonymous_page-cleanup.patch
* thp-consolidate-code-between-handle_mm_fault-and-do_huge_pmd_anonymous_page.patch
* mm-vmstats-tlb-flush-counters.patch
* thp-mm-locking-tail-page-is-a-bug.patch
* swap-add-a-simple-detector-for-inappropriate-swapin-readahead.patch
* swap-add-a-simple-detector-for-inappropriate-swapin-readahead-fix.patch
* kernel-wide-fix-missing-validations-on-__get-__put-__copy_to-__copy_from_user.patch
* kernel-smpc-free-related-resources-when-failure-occurs-in-hotplug_cfd.patch
* smp-give-warning-when-calling-smp_call_function_many-single-in-serving-irq.patch
* binfmt_elfc-use-get_random_int-to-fix-entropy-depleting.patch
* firmware-dmi_scan-drop-obsolete-comment.patch
* firmware-dmi_scan-fix-most-checkpatch-errors-and-warnings.patch
* firmware-dmi_scan-constify-strings.patch
* firmware-dmi_scan-drop-oom-messages.patch
* autofs4-allow-autofs-to-work-outside-the-initial-pid-namespace.patch
* autofs4-translate-pids-to-the-right-namespace-for-the-daemon.patch
* drivers-rtc-rtc-hid-sensor-timec-add-module-alias-to-let-the-module-load-automatically.patch
* fat-additions-to-support-fat_fallocate.patch
* fat-additions-to-support-fat_fallocate-fix.patch
* signals-eventpoll-set-saved_sigmask-at-the-start.patch
* move-exit_task_namespaces-outside-of-exit_notify-fix.patch
* memstick-add-support-for-legacy-memorysticks.patch
* relay-fix-timer-madness.patch
* relay-fix-timer-madness-v2.patch
* ipcshm-introduce-lockless-functions-to-obtain-the-ipc-object.patch
* ipcshm-shorten-critical-region-in-shmctl_down.patch
* ipc-drop-ipcctl_pre_down.patch
* ipc-drop-ipcctl_pre_down-fix.patch
* ipcshm-introduce-shmctl_nolock.patch
* ipcshm-make-shmctl_nolock-lockless.patch
* ipcshm-make-shmctl_nolock-lockless-checkpatch-fixes.patch
* ipcshm-shorten-critical-region-for-shmctl.patch
* ipcshm-cleanup-do_shmat-pasta.patch
* ipcshm-shorten-critical-region-for-shmat.patch
* ipc-rename-ids-rw_mutex.patch
* ipcmsg-drop-msg_unlock.patch
* ipc-document-general-ipc-locking-scheme.patch
* staging-lustre-ldlm-convert-to-shrinkers-to-count-scan-api.patch
* staging-lustre-obdclass-convert-lu_object-shrinker-to-count-scan-api.patch
* staging-lustre-ptlrpc-convert-to-new-shrinker-api.patch
* staging-lustre-libcfs-cleanup-linux-memh.patch
* staging-lustre-replace-num_physpages-with-totalram_pages.patch
  linux-next.patch
  linux-next-git-rejects.patch
* fs-bump-inode-and-dentry-counters-to-long.patch
* super-fix-calculation-of-shrinkable-objects-for-small-numbers.patch
* dcache-convert-dentry_statnr_unused-to-per-cpu-counters.patch
* dentry-move-to-per-sb-lru-locks.patch
* dcache-remove-dentries-from-lru-before-putting-on-dispose-list.patch
* mm-new-shrinker-api.patch
* shrinker-convert-superblock-shrinkers-to-new-api.patch
* shrinker-convert-superblock-shrinkers-to-new-api-fix.patch
* list-add-a-new-lru-list-type.patch
* inode-convert-inode-lru-list-to-generic-lru-list-code.patch
* inode-convert-inode-lru-list-to-generic-lru-list-code-inode-move-inode-to-a-different-list-inside-lock.patch
* dcache-convert-to-use-new-lru-list-infrastructure.patch
* list_lru-per-node-list-infrastructure.patch
* list_lru-per-node-list-infrastructure-fix.patch
* list_lru-per-node-list-infrastructure-fix-broken-lru_retry-behaviour.patch
* list_lru-per-node-api.patch
* list_lru-remove-special-case-function-list_lru_dispose_all.patch
* shrinker-add-node-awareness.patch
* vmscan-per-node-deferred-work.patch
* fs-convert-inode-and-dentry-shrinking-to-be-node-aware.patch
* xfs-convert-buftarg-lru-to-generic-code.patch
* xfs-convert-buftarg-lru-to-generic-code-fix.patch
* xfs-rework-buffer-dispose-list-tracking.patch
* xfs-convert-dquot-cache-lru-to-list_lru.patch
* xfs-convert-dquot-cache-lru-to-list_lru-fix.patch
* xfs-convert-dquot-cache-lru-to-list_lru-fix-dquot-isolation-hang.patch
* fs-convert-fs-shrinkers-to-new-scan-count-api.patch
* fs-convert-fs-shrinkers-to-new-scan-count-api-fix.patch
* fs-convert-fs-shrinkers-to-new-scan-count-api-fix-fix.patch
* drivers-convert-shrinkers-to-new-count-scan-api.patch
* drivers-convert-shrinkers-to-new-count-scan-api-fix.patch
* drivers-convert-shrinkers-to-new-count-scan-api-fix-2.patch
* i915-bail-out-earlier-when-shrinker-cannot-acquire-mutex.patch
* shrinker-convert-remaining-shrinkers-to-count-scan-api.patch
* shrinker-convert-remaining-shrinkers-to-count-scan-api-fix.patch
* hugepage-convert-huge-zero-page-shrinker-to-new-shrinker-api.patch
* hugepage-convert-huge-zero-page-shrinker-to-new-shrinker-api-fix.patch
* shrinker-kill-old-shrink-api.patch
* shrinker-kill-old-shrink-api-fix.patch
* list_lru-dynamically-adjust-node-arrays.patch
* list_lru-dynamically-adjust-node-arrays-super-fix-for-destroy-lrus.patch
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
