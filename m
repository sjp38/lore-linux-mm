Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 2270D6B0032
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 00:19:41 -0500 (EST)
Received: by pdbfp1 with SMTP id fp1so10302925pdb.9
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 21:19:40 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id oo10si3052685pdb.105.2015.02.25.21.19.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Feb 2015 21:19:40 -0800 (PST)
Date: Wed, 25 Feb 2015 21:19:39 -0800
From: akpm@linux-foundation.org
Subject: mmotm 2015-02-25-21-19 uploaded
Message-ID: <54eeaceb.gWfyhW4BeYkMh+Bz%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz

The mm-of-the-moment snapshot 2015-02-25-21-19 has been uploaded to

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


This mmotm tree contains the following patches against 4.0-rc1:
(patches marked "*" will be included in linux-next)

  origin.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  i-need-old-gcc.patch
* ocfs2-update-web-page-git-tree-in-documentation.patch
* mm-nommu-fix-memory-leak.patch
* memcg-fix-low-limit-calculation.patch
* rtc-ds1685-fix-ds1685_rtc_alarm_irq_enable-build-error.patch
* rtc-ds1685-remove-superfluous-checks-for-out-of-range-u8-values.patch
* scripts-gdb-add-empty-package-initialization-script.patch
* nilfs2-fix-potential-memory-overrun-on-inode.patch
* nilfs2-fix-potential-memory-overrun-on-inode-fix.patch
* rtc-ds1685-fix-conditional-in-ds1685_rtc_sysfs_time_regs_showstore.patch
* zram-use-proper-type-to-update-max_used_pages.patch
* mm-memcontrol-use-max-instead-of-infinity-in-control-knobs.patch
* kernel-sysc-fix-uname26-for-40.patch
* kernel-sysc-fix-uname26-for-40-fix.patch
* mm-page_alloc-revert-inadvertent-__gfp_fs-retry-behavior-change.patch
* fs-ext4-fsyncc-generic_file_fsync-call-based-on-barrier-flag.patch
* ocfs2-remove-unneeded-rc-for-kfree.patch
* ocfs2-deletion-of-unnecessary-checks-before-three-function-calls.patch
* ocfs2-less-function-calls-in-ocfs2_convert_inline_data_to_extents-after-error-detection.patch
* ocfs2-less-function-calls-in-ocfs2_figure_merge_contig_type-after-error-detection.patch
* ocfs2-one-function-call-less-in-ocfs2_merge_rec_left-after-error-detection.patch
* ocfs2-one-function-call-less-in-ocfs2_merge_rec_right-after-error-detection.patch
* ocfs2-one-function-call-less-in-ocfs2_init_slot_info-after-error-detection.patch
* ocfs2-one-function-call-less-in-user_cluster_connect-after-error-detection.patch
* ocfs2-avoid-a-pointless-delay-in-o2cb_cluster_check.patch
* ocfs2-use-64bit-variables-to-track-heartbeat-time.patch
* ocfs2-call-ocfs2_journal_access_di-before-ocfs2_journal_dirty-in-ocfs2_write_end_nolock.patch
* ocfs2-avoid-access-invalid-address-when-read-o2dlm-debug-messages.patch
* ocfs2-avoid-access-invalid-address-when-read-o2dlm-debug-messages-v3.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* watchdog-new-definitions-and-variables-initialization.patch
* watchdog-introduce-the-proc_watchdog_update-function.patch
* watchdog-move-definition-of-watchdog_proc_mutex-outside-of-proc_dowatchdog.patch
* watchdog-introduce-the-proc_watchdog_common-function.patch
* watchdog-introduce-separate-handlers-for-parameters-in-proc-sys-kernel.patch
* watchdog-implement-error-handling-for-failure-to-set-up-hardware-perf-events.patch
* watchdog-enable-the-new-user-interface-of-the-watchdog-mechanism.patch
* watchdog-clean-up-some-function-names-and-arguments.patch
* watchdog-introduce-the-hardlockup_detector_disable-function.patch
  mm.patch
* mm-rename-foll_mlock-to-foll_populate.patch
* mm-rename-__mlock_vma_pages_range-to-populate_vma_page_range.patch
* mm-move-gup-posix-mlock-error-conversion-out-of-__mm_populate.patch
* mm-move-mm_populate-related-code-to-mm-gupc.patch
* mm-memblockc-name-the-local-variable-of-memblock_type-as-type.patch
* mm-memcontrol-update-copyright-notice.patch
* memory-hotplug-use-macro-to-switch-between-section-and-pfn.patch
* mm-cma-debugfs-interface.patch
* mm-cma-allocation-trigger.patch
* mm-cma-release-trigger.patch
* mm-cma-release-trigger-checkpatch-fixes.patch
* mm-cma-allocation-trigger-fix.patch
* mm-hotplug-fix-concurrent-memory-hot-add-deadlock.patch
* mm-cma-change-fallback-behaviour-for-cma-freepage.patch
* mm-page_alloc-factor-out-fallback-freepage-checking.patch
* mm-compaction-enhance-compaction-finish-condition.patch
* mm-compaction-enhance-compaction-finish-condition-fix.patch
* mm-incorporate-zero-pages-into-transparent-huge-pages.patch
* mm-incorporate-zero-pages-into-transparent-huge-pages-fix.patch
* page_writeback-cleanup-mess-around-cancel_dirty_page.patch
* page_writeback-cleanup-mess-around-cancel_dirty_page-checkpatch-fixes.patch
* mm-hide-per-cpu-lists-in-output-of-show_mem.patch
* mm-hide-per-cpu-lists-in-output-of-show_mem-fix.patch
* alpha-expose-number-of-page-table-levels-on-kconfig-level.patch
* arm64-expose-number-of-page-table-levels-on-kconfig-level.patch
* arm-expose-number-of-page-table-levels-on-kconfig-level.patch
* frv-mark-pud-and-pmd-folded.patch
* ia64-expose-number-of-page-table-levels-on-kconfig-level.patch
* m32r-mark-pmd-folded.patch
* m68k-mark-pmd-folded-and-expose-number-of-page-table-levels.patch
* mips-expose-number-of-page-table-levels-on-kconfig-level.patch
* mn10300-mark-pud-and-pmd-folded.patch
* parisc-expose-number-of-page-table-levels-on-kconfig-level.patch
* powerpc-expose-number-of-page-table-levels-on-kconfig-level.patch
* s390-expose-number-of-page-table-levels.patch
* sh-expose-number-of-page-table-levels.patch
* sparc-expose-number-of-page-table-levels.patch
* tile-expose-number-of-page-table-levels.patch
* um-expose-number-of-page-table-levels.patch
* x86-expose-number-of-page-table-levels-on-kconfig-level.patch
* mm-define-default-pgtable_levels-to-two.patch
* mm-do-not-add-nr_pmds-into-mm_struct-if-pmd-is-folded.patch
* mm-refactor-do_wp_page-extract-the-reuse-case.patch
* mm-refactor-do_wp_page-extract-the-reuse-case-fix.patch
* mm-refactor-do_wp_page-rewrite-the-unlock-flow.patch
* mm-refactor-do_wp_page-extract-the-page-copy-flow.patch
* mm-refactor-do_wp_page-handling-of-shared-vma-into-a-function.patch
* ocfs2-copy-fs-uuid-to-superblock.patch
* cleancache-zap-uuid-arg-of-cleancache_init_shared_fs.patch
* cleancache-forbid-overriding-cleancache_ops.patch
* cleancache-remove-limit-on-the-number-of-cleancache-enabled-filesystems.patch
* cleancache-remove-limit-on-the-number-of-cleancache-enabled-filesystems-fix.patch
* mm-vmscan-fix-the-page-state-calculation-in-too_many_isolated.patch
* mm-page_isolation-check-pfn-validity-before-access.patch
* mm-fix-invalid-use-of-pfn_valid_within-in-test_pages_in_a_zone.patch
* fs-mpagec-forgotten-write_sync-in-case-of-data-integrity-write.patch
* mm-support-madvisemadv_free.patch
* mm-support-madvisemadv_free-fix.patch
* x86-add-pmd_-for-thp.patch
* x86-add-pmd_-for-thp-fix.patch
* sparc-add-pmd_-for-thp.patch
* sparc-add-pmd_-for-thp-fix.patch
* powerpc-add-pmd_-for-thp.patch
* arm-add-pmd_mkclean-for-thp.patch
* arm64-add-pmd_-for-thp.patch
* mm-dont-split-thp-page-when-syscall-is-called.patch
* mm-dont-split-thp-page-when-syscall-is-called-fix.patch
* mm-dont-split-thp-page-when-syscall-is-called-fix-2.patch
* proc-pid-status-show-all-sets-of-pid-according-to-ns.patch
* docs-add-missing-and-new-proc-pid-status-file-entries-fix-typos.patch
* kernel-conditionally-support-non-root-users-groups-and-capabilities.patch
* kernel-conditionally-support-non-root-users-groups-and-capabilities-checkpatch-fixes.patch
* printk-comment-pr_cont-stating-it-is-only-to-continue-a-line.patch
* lib-vsprintfc-eliminate-some-branches.patch
* lib-vsprintfc-reduce-stack-use-in-number.patch
* lib-vsprintfc-eliminate-duplicate-hex-string-array.patch
* lib-vsprintfc-another-small-hack.patch
* lib-vsprintf-add-%pt-format-specifier.patch
* linux-bitmaph-improve-bitmap_lastfirst_word_mask.patch
* staging-lustre-convert-return-seq_printf-uses.patch
* staging-lustre-convert-seq_-hash-functions-to-return-void.patch
* staging-lustre-convert-uses-of-int-rc-=-seq_printf.patch
* staging-lustre-convert-remaining-uses-of-=-seq_printf.patch
* x86-mtrr-if-remove-use-of-seq_printf-return-value.patch
* power-wakeup-remove-use-of-seq_printf-return-value.patch
* rtc-remove-use-of-seq_printf-return-value.patch
* ipc-remove-use-of-seq_printf-return-value.patch
* pxa27x_udc-remove-use-of-seq_printf-return-value.patch
* microblaze-mb-remove-use-of-seq_printf-return-value.patch
* nios2-cpuinfo-remove-use-of-seq_printf-return-value.patch
* arm-plat-pxa-remove-use-of-seq_printf-return-value.patch
* openrisc-remove-use-of-seq_printf-return-value.patch
* cris-remove-use-of-seq_printf-return-value.patch
* mfd-ab8500-debugfs-remove-use-of-seq_printf-return-value.patch
* staging-i2o-remove-use-of-seq_printf-return-value.patch
* staging-rtl8192x-remove-use-of-seq_printf-return-value.patch
* s390-remove-use-of-seq_printf-return-value.patch
* i8k-remove-use-of-seq_printf-return-value.patch
* watchdog-bcm281xx-remove-use-of-seq_printf-return-value.patch
* proc-remove-use-of-seq_printf-return-value.patch
* cgroup-remove-use-of-seq_printf-return-value.patch
* tracing-remove-use-of-seq_printf-return-value.patch
* lru_cache-remove-use-of-seq_printf-return-value.patch
* parisc-remove-use-of-seq_printf-return-value.patch
* lib-find__bit-reimplementation.patch
* lib-find__bit-reimplementation-fix.patch
* lib-move-find_last_bit-to-lib-find_next_bitc.patch
* lib-rename-lib-find_next_bitc-to-lib-find_bitc.patch
* mm-utilc-add-kstrimdup.patch
* lib-add-crc64-ecma-module.patch
* checkpatch-improve-no-space-is-necessary-after-a-cast-test.patch
* rtc-pcf8563-simplify-return-from-function.patch
* rtc-stmp3xxx-use-optional-crystal-in-low-power-states.patch
* rtc-mc13xxx-fix-obfuscated-and-wrong-format-string.patch
* rtc-s5m-remove-unused-watchdog-and-sudden-momentary-power-loss.patch
* rtc-mediatek-add-mt63xx-rtc-driver.patch
* drivers-rtc-rtc-em3027c-add-device-tree-support.patch
* rtc-add-rtc-abx805-a-driver-for-the-abracon-ab-1805-i2c-rtc.patch
* rtc-x1205-use-sign_extend32-for-sign-extension.patch
* rtc-hctosys-do-not-treat-lack-of-rtc-device-as-error.patch
* drivers-rtc-interfacec-check-the-error-after-__rtc_read_time.patch
* rtc-s3c-fix-the-duplicate-clock-control.patch
* rtc-restore-alarm-after-resume.patch
* fs-fat-remove-unnecessary-defintion.patch
* fs-fat-remove-unnecessary-includes.patch
* fs-fat-remove-unnecessary-includes-fix.patch
* fs-fat-comment-fix-fat_bits-can-be-also-32.patch
* fat-add-fat_fallocate-operation.patch
* fat-skip-cluster-allocation-on-fallocated-region.patch
* fat-permit-to-return-phy-block-number-by-fibmap-in-fallocated-region.patch
* documentation-filesystems-vfattxt-update-the-limitation-for-fat-fallocate.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* fs-affs-use-affs_mount-prefix-for-mount-options.patch
* fs-affs-affsh-add-mount-option-manipulation-macros.patch
* fs-affs-superc-use-affs_set_opt.patch
* fs-affs-use-affs_test_opt.patch
* arc-do-not-export-symbols-in-troubleshootc.patch
* lib-lz4-pull-out-constant-tables.patch
  linux-next.patch
  linux-next-rejects.patch
* lib-kconfig-fix-up-have_arch_bitreverse-help-text.patch
* mips-ip32-add-platform-data-hooks-to-use-ds1685-driver.patch
* w1-call-put_device-if-device_register-fails.patch
* mm-add-strictlimit-knob-v2.patch
  do_shared_fault-check-that-mmap_sem-is-held.patch
  make-sure-nobodys-leaking-resources.patch
  journal_add_journal_head-debug.patch
  journal_add_journal_head-debug-fix.patch
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
