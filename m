Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 4979C6B005D
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 19:16:33 -0500 (EST)
Received: by mail-vc0-f201.google.com with SMTP id p1so430152vcq.4
        for <linux-mm@kvack.org>; Thu, 20 Dec 2012 16:16:32 -0800 (PST)
Subject: mmotm 2012-12-20-16-15 uploaded
From: akpm@linux-foundation.org
Date: Thu, 20 Dec 2012 16:16:30 -0800
Message-Id: <20121221001631.74ECA82004A@wpzn4.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

The mm-of-the-moment snapshot 2012-12-20-16-15 has been uploaded to

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


This mmotm tree contains the following patches against 3.7:
(patches marked "*" will be included in linux-next)

  origin.patch
* compaction-fix-build-error-in-cma-compaction.patch
* mm-fix-calculation-of-dirtyable-memory.patch
* documentation-kernel-parameterstxt-remove-capabilitydisable.patch
* drivers-firmware-dmi_scanc-check-dmi-version-when-get-system-uuid.patch
* drivers-firmware-dmi_scanc-fetch-dmi-version-from-smbios-if-it-exists.patch
* exec-do-not-leave-bprm-interp-on-stack.patch
* mm-cma-warn-if-freed-memory-is-still-in-use.patch
* rtc-imx-dryice-must-include-linux-spinlockh.patch
* kcmp-include-linux-ptraceh.patch
* hfsplus-avoid-crash-on-failed-block-map-free.patch
* hfsplus-rework-processing-errors-in-hfsplus_free_extents.patch
* hfsplus-rework-processing-of-hfs_btree_write-returned-error.patch
* hfsplus-add-error-message-for-the-case-of-failure-of-sync-fs-in-delayed_sync_fs-method.patch
* mm-clean-up-transparent-hugepage-sysfs-error-messages.patch
* revert-rtc-recycle-id-when-unloading-a-rtc-driver.patch
* checkpatch-warn-on-uapi-includes-that-include-uapi.patch
* memcg-dont-register-hotcpu-notifier-from-css_alloc.patch
* linux-kernelh-fix-div_round_closest-with-unsigned-divisors.patch
* proc-fix-inconsistent-lock-state.patch
* documentation-abi-remove-testing-sysfs-devices-node.patch
* fat-fix-incorrect-function-comment.patch
* lib-atomic64-initialize-locks-statically-to-fix-early-users.patch
* sgi-xp-handle-non-fatal-traps.patch
* sendfile-allows-bypassing-of-notifier-events.patch
* keys-fix-unreachable-code.patch
* keys-use-keyring_alloc-to-create-module-signing-keyring.patch
  linux-next.patch
  linux-next-git-rejects.patch
  make-my-i386-build-work.patch
  i-need-old-gcc.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
* drivers-rtc-rtc-tegrac-convert-to-dt-driver.patch
* mm-cond_resched-in-tlb_flush_mmu-to-fix-soft-lockups-on-config_preempt.patch
* mm-fix-zone_watermark_ok_safe-accounting-of-isolated-pages.patch
* mm-limit-mmu_gather-batching-to-fix-soft-lockups-on-config_preempt.patch
* vfs-d_obtain_alias-needs-to-use-as-default-name.patch
* fs-block_devc-page-cache-wrongly-left-invalidated-after-revalidate_disk.patch
* x86-numa-dont-check-if-node-is-numa_no_node.patch
* arch-x86-tools-insn_sanityc-identify-source-of-messages.patch
* uv-fix-incorrect-tlb-flush-all-issue.patch
* olpc-fix-olpc-xo1-scic-build-errors.patch
* x86-convert-update_mmu_cache-and-update_mmu_cache_pmd-to-functions.patch
* x86-fix-the-argument-passed-to-sync_global_pgds.patch
* x86-fix-a-compile-error-a-section-type-conflict.patch
* x86-make-mem=-option-to-work-for-efi-platform.patch
* audit-create-explicit-audit_seccomp-event-type.patch
* audit-catch-possible-null-audit-buffers.patch
* cris-use-int-for-ssize_t-to-match-size_t.patch
* pcmcia-move-unbind-rebind-into-dev_pm_opscomplete.patch
* drivers-gpu-drm-drm_fb_helperc-avoid-sleeping-in-unblank_screen-if-oops-in-progress.patch
* fb-rework-locking-to-fix-lock-ordering-on-takeover.patch
* fb-rework-locking-to-fix-lock-ordering-on-takeover-fix.patch
* fb-rework-locking-to-fix-lock-ordering-on-takeover-fix-2.patch
* cyber2000fb-avoid-palette-corruption-at-higher-clocks.patch
* timeconstpl-remove-deprecated-defined-array.patch
* time-dont-inline-export_symbol-functions.patch
* mm-mempolicy-introduce-spinlock-to-read-shared-policy-tree.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* fs-change-return-values-from-eacces-to-eperm.patch
* fs-block_devc-need-not-to-check-inode-i_bdev-in-bd_forget.patch
* watchdog-trigger-all-cpu-backtrace-when-locked-up-and-going-to-panic.patch
  mm.patch
* memcg-oom-provide-more-precise-dump-info-while-memcg-oom-happening.patch
* mm-memcontrolc-convert-printkkern_foo-to-pr_foo.patch
* mm-hugetlbc-convert-to-pr_foo.patch
* cma-make-putback_lru_pages-call-conditional.patch
* cma-make-putback_lru_pages-call-conditional-fix.patch
* mm-memcg-only-evict-file-pages-when-we-have-plenty.patch
* mm-vmscan-save-work-scanning-almost-empty-lru-lists.patch
* mm-vmscan-clarify-how-swappiness-highest-priority-memcg-interact.patch
* mm-vmscan-improve-comment-on-low-page-cache-handling.patch
* mm-vmscan-clean-up-get_scan_count.patch
* mm-vmscan-clean-up-get_scan_count-fix.patch
* mm-vmscan-compaction-works-against-zones-not-lruvecs.patch
* mm-vmscan-compaction-works-against-zones-not-lruvecs-fix.patch
* mm-reduce-rmap-overhead-for-ex-ksm-page-copies-created-on-swap-faults.patch
* mm-page_allocc-__setup_per_zone_wmarks-make-min_pages-unsigned-long.patch
* mm-vmscanc-__zone_reclaim-replace-max_t-with-max.patch
* mm-compaction-do-not-accidentally-skip-pageblocks-in-the-migrate-scanner.patch
* cma-use-unsigned-type-for-count-argument.patch
* cma-use-unsigned-type-for-count-argument-fix.patch
* mm-memmap_init_zone-performance-improvement.patch
* drop_caches-add-some-documentation-and-info-messsge.patch
* drivers-usb-gadget-amd5536udcc-avoid-calling-dma_pool_create-with-null-dev.patch
* mm-dmapoolc-fix-null-dev-in-dma_pool_create.patch
* memcg-debugging-facility-to-access-dangling-memcgs.patch
* memcg-debugging-facility-to-access-dangling-memcgs-fix.patch
* mm-add-vm-event-counters-for-balloon-pages-compaction.patch
* ext3-ext4-ocfs2-remove-unused-macro-namei_ra_index.patch
* scripts-pnmtologo-fix-for-plain-pbm-checkpatch-fixes.patch
* scripts-tagssh-add-magic-for-declarations-of-popular-kernel-type.patch
* backlight-add-lms501kf03-lcd-driver.patch
* backlight-add-lms501kf03-lcd-driver-fix.patch
* backlight-ld9040-use-sleep-instead-of-delay.patch
* backlight-ld9040-remove-unnecessary-null-deference-check.patch
* backlight-ld9040-replace-efault-with-einval.patch
* backlight-ld9040-remove-redundant-return-variables.patch
* backlight-ld9040-reorder-inclusions-of-linux-xxxh.patch
* backlight-s6e63m0-use-lowercase-names-of-structs.patch
* backlight-s6e63m0-use-sleep-instead-of-delay.patch
* backlight-s6e63m0-remove-unnecessary-null-deference-check.patch
* backlight-s6e63m0-replace-efault-with-einval.patch
* backlight-s6e63m0-remove-redundant-variable-before_power.patch
* backlight-s6e63m0-reorder-inclusions-of-linux-xxxh.patch
* backlight-ams369fg06-use-sleep-instead-of-delay.patch
* backlight-ams369fg06-remove-unnecessary-null-deference-check.patch
* backlight-ams369fg06-replace-efault-with-einval.patch
* backlight-ams369fg06-remove-redundant-variable-before_power.patch
* backlight-ams369fg06-reorder-inclusions-of-linux-xxxh.patch
* epoll-support-for-disabling-items-and-a-self-test-app.patch
* binfmt_elfc-use-get_random_int-to-fix-entropy-depleting.patch
* drivers-rtc-dump-small-buffers-via-%ph.patch
* drivers-rtc-rtc-pxac-fix-alarm-not-match-issue.patch
* drivers-rtc-rtc-pxac-fix-alarm-cant-wake-up-system-issue.patch
* drivers-rtc-rtc-pxac-fix-set-time-sync-time-issue.patch
* rtc-ds1307-long-block-operations-bugfix.patch
* rtc-ds1307-long-block-operations-bugfix-fix.patch
* rtc-max77686-add-maxim-77686-driver.patch
* rtc-max77686-add-maxim-77686-driver-fix.patch
* rtc-pcf8523-add-low-battery-voltage-support.patch
* rtc-pcf8523-add-low-battery-voltage-support-fix.patch
* drivers-rtc-use-of_match_ptr-macro.patch
* drivers-rtc-rtc-pxac-avoid-cpuid-checking.patch
* drivers-rtc-remove-unnecessary-semicolons.patch
* rtc-ds2404-use-module_platform_driver-macro.patch
* hfsplus-add-osx-prefix-for-handling-namespace-of-mac-os-x-extended-attributes.patch
* hfsplus-add-on-disk-layout-declarations-related-to-attributes-tree.patch
* hfsplus-add-functionality-of-manipulating-by-records-in-attributes-tree.patch
* hfsplus-rework-functionality-of-getting-setting-and-deleting-of-extended-attributes.patch
* hfsplus-add-support-of-manipulation-by-attributes-file.patch
* documentation-dma-api-howtotxt-minor-grammar-corrections.patch
* fork-unshare-remove-dead-code.patch
* kexec-add-the-values-related-to-buddy-system-for-filtering-free-pages.patch
* ipc-remove-forced-assignment-of-selected-message.patch
* ipc-add-sysctl-to-specify-desired-next-object-id.patch
* ipc-message-queue-receive-cleanup.patch
* ipc-message-queue-copy-feature-introduced.patch
* selftests-ipc-message-queue-copy-feature-test.patch
* ipc-simplify-free_copy-call.patch
* ipc-convert-prepare_copy-from-macro-to-function.patch
* ipc-simplify-message-copying.patch
* ipc-add-more-comments-to-message-copying-related-code.patch
* documentation-sysctl-kerneltxt-document-proc-sys-shmall.patch
* ipc-semc-alternatives-to-preempt_disable.patch
* drivers-char-miscc-misc_register-do-not-loop-on-misc_list-unconditionally.patch
* drivers-char-miscc-misc_register-do-not-loop-on-misc_list-unconditionally-fix.patch
* mtd-mtd_nandecctest-use-prandom_bytes-instead-of-get_random_bytes.patch
* mtd-mtd_oobtest-convert-to-use-prandom-library.patch
* mtd-mtd_pagetest-convert-to-use-prandom-library.patch
* mtd-mtd_speedtest-use-prandom_bytes.patch
* mtd-mtd_subpagetest-convert-to-use-prandom-library.patch
* mtd-mtd_stresstest-use-prandom_bytes.patch
* dma-debug-new-interfaces-to-debug-dma-mapping-errors-fix-fix.patch
  debugging-keep-track-of-page-owners.patch
  debugging-keep-track-of-page-owners-fix.patch
  make-sure-nobodys-leaking-resources.patch
  journal_add_journal_head-debug.patch
  releasing-resources-with-children.patch
  make-frame_pointer-default=y.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  mutex-subsystem-synchro-test-module.patch
  mutex-subsystem-synchro-test-module-fix.patch
  mutex-subsystem-synchro-test-module-fix-2.patch
  mutex-subsystem-synchro-test-module-fix-3.patch
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
