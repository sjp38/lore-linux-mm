Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id DAFAA6B0031
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 19:40:01 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id et14so1450856pad.13
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 16:40:01 -0700 (PDT)
Received: from mail-pa0-f74.google.com (mail-pa0-f74.google.com [209.85.220.74])
        by mx.google.com with ESMTPS id hs1si2681353pac.33.2014.06.12.16.40.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 16:40:00 -0700 (PDT)
Received: by mail-pa0-f74.google.com with SMTP id lj1so230195pab.1
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 16:40:00 -0700 (PDT)
Subject: mmotm 2014-06-12-16-38 uploaded
From: akpm@linux-foundation.org
Date: Thu, 12 Jun 2014 16:39:59 -0700
Message-Id: <20140612233959.981AF31C561@corp2gmr1-1.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

The mm-of-the-moment snapshot 2014-06-12-16-38 has been uploaded to

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


This mmotm tree contains the following patches against 3.15:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  maintainers-akpm-maintenance.patch
  checkpatch-check-git-commit-descriptions.patch
* mm-nommu-per-thread-vma-cache-fix.patch
* cpu-hotplug-smp-flush-any-pending-ipi-callbacks-before-cpu-offline.patch
* cpu-hotplug-smp-flush-any-pending-ipi-callbacks-before-cpu-offline-v2.patch
* kexec-save-pg_head_mask-in-vmcoreinfo.patch
* mm-hotplug-probe-interface-is-available-on-several-platforms.patch
* tell-gcc-optimizer-to-never-introduce-new-data-races.patch
* lib-kconfigdebug-let-frame_pointer-exclude-score-just-like-exclude-most-of-other-architectures.patch
* x86-vdso-remove-one-final-use-of-htole16.patch
* mm-pcp-allow-restoring-percpu_pagelist_fraction-default.patch
* memorystick-rtsx-add-cancel_work-when-remove-driver.patch
* documentation-accounting-getdelaysc-cleaning-up-missing-null-terminate-after-strncpy-call.patch
* ocfs2-should-add-inode-into-orphan-dir-after-updating-entry-in-ocfs2_rename.patch
* deadlock-when-two-nodes-are-converting-same-lock-from-pr-to-ex-and-idletimeout-closes-conn.patch
* ocfs2-revert-the-patch-fix-null-pointer-dereference-when-dismount-and-ocfs2rec-simultaneously.patch
* kernel-auditfilterc-replace-countsize-kmalloc-by-kcalloc.patch
* fs-cifs-remove-obsolete-__constant.patch
* kernel-posix-timersc-code-clean-up.patch
* kernel-posix-timersc-code-clean-up-checkpatch-fixes.patch
* input-route-kbd-leds-through-the-generic-leds-layer.patch
* input-route-kbd-leds-through-the-generic-leds-layer-fix.patch
* drivers-net-irda-donauboe-convert-to-module_pci_driver.patch
* fs-ext4-fsyncc-generic_file_fsync-call-based-on-barrier-flag.patch
* ocfs2-correctly-check-the-return-value-of-ocfs2_search_extent_list.patch
* ocfs2-remove-convertion-of-total_backoff-in-dlm_join_domain.patch
* ocfs2-do-not-write-error-flag-to-user-structure-we-cannot-copy-from-to.patch
* ocfs2-free-inode-when-i_count-becomes-zero.patch
* ocfs2-free-inode-when-i_count-becomes-zero-checkpatch-fixes.patch
* ocfs2-dlm-do-not-purge-lockres-that-is-queued-for-assert-master.patch
* refcount-take-inode_lock-until-write-io-issued.patch
* ocfs2-fix-a-tiny-race-when-running-dirop_fileop_racer.patch
* ocfs2-do-not-return-dlm_migrate_response_mastery_ref-to-avoid-endlessloop-during-umount.patch
* ocfs2-manually-do-the-iput-once-ocfs2_add_entry-failed-in-ocfs2_symlink-and-ocfs2_mknod.patch
* maintainers-update-ibm-serveraid-raid-info.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
  mm.patch
* mm-slabc-add-__init-to-init_lock_keys.patch
* mm-readaheadc-remove-unused-file_ra_state-from-count_history_pages.patch
* mm-memory_hotplugc-add-__meminit-to-grow_zone_span-grow_pgdat_span.patch
* mm-page_alloc-add-__meminit-to-alloc_pages_exact_nid.patch
* mm-page_allocc-unexport-alloc_pages_exact_nid.patch
* mm-vmscanc-avoid-recording-the-original-scan-targets-in-shrink_lruvec.patch
* hwpoison-fix-the-handling-path-of-the-victimized-page-frame-that-belong-to-non-lur.patch
* include-linux-memblockh-add-__init-to-memblock_set_bottom_up.patch
* vmalloc-use-rcu-list-iterator-to-reduce-vmap_area_lock-contention.patch
* mm-memoryc-use-entry-=-access_oncepte-in-handle_pte_fault.patch
* mem-hotplug-avoid-illegal-state-prefixed-with-legal-state-when-changing-state-of-memory_block.patch
* mem-hotplug-introduce-mmop_offline-to-replace-the-hard-coding-1.patch
* mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff.patch
* mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff-v2.patch
* mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff-v3.patch
* mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff-v3-fix.patch
* pagewalk-update-page-table-walker-core.patch
* pagewalk-update-page-table-walker-core-fix-end-address-calculation-in-walk_page_range.patch
* pagewalk-update-page-table-walker-core-fix-end-address-calculation-in-walk_page_range-fix.patch
* pagewalk-update-page-table-walker-core-fix.patch
* pagewalk-add-walk_page_vma.patch
* smaps-redefine-callback-functions-for-page-table-walker.patch
* clear_refs-redefine-callback-functions-for-page-table-walker.patch
* pagemap-redefine-callback-functions-for-page-table-walker.patch
* pagemap-redefine-callback-functions-for-page-table-walker-fix.patch
* numa_maps-redefine-callback-functions-for-page-table-walker.patch
* memcg-redefine-callback-functions-for-page-table-walker.patch
* arch-powerpc-mm-subpage-protc-use-walk_page_vma-instead-of-walk_page_range.patch
* pagewalk-remove-argument-hmask-from-hugetlb_entry.patch
* pagewalk-remove-argument-hmask-from-hugetlb_entry-fix.patch
* pagewalk-remove-argument-hmask-from-hugetlb_entry-fix-fix.patch
* mempolicy-apply-page-table-walker-on-queue_pages_range.patch
* mm-pagewalkc-move-pte-null-check.patch
* mm-prom-pid-clear_refs-avoid-split_huge_page.patch
* mm-pagewalk-remove-pgd_entry-and-pud_entry.patch
* mm-pagewalk-replace-mm_walk-skip-with-more-general-mm_walk-control.patch
* mm-pagewalk-replace-mm_walk-skip-with-more-general-mm_walk-control-fix.patch
* madvise-cleanup-swapin_walk_pmd_entry.patch
* madvise-cleanup-swapin_walk_pmd_entry-fix.patch
* memcg-separate-mem_cgroup_move_charge_pte_range.patch
* memcg-separate-mem_cgroup_move_charge_pte_range-checkpatch-fixes.patch
* arch-powerpc-mm-subpage-protc-cleanup-subpage_walk_pmd_entry.patch
* mm-pagewalk-move-pmd_trans_huge_lock-from-callbacks-to-common-code.patch
* mm-pagewalk-move-pmd_trans_huge_lock-from-callbacks-to-common-code-checkpatch-fixes.patch
* mincore-apply-page-table-walker-on-do_mincore.patch
* mincore-apply-page-table-walker-on-do_mincore-fix.patch
* mm-introduce-do_shared_fault-and-drop-do_fault-fix-fix.patch
* mm-compactionc-isolate_freepages_block-small-tuneup.patch
* fs-mpagec-forgotten-write_sync-in-case-of-data-integrity-write.patch
* m68k-call-find_vma-with-the-mmap_sem-held-in-sys_cacheflush.patch
* mm-zswapc-add-__init-to-zswap_entry_cache_destroy.patch
* do_shared_fault-check-that-mmap_sem-is-held.patch
* drivers-misc-ti-st-st_corec-fix-null-dereference-on-protocol-type-check.patch
* lib-vsprintf-add-%pt-format-specifier.patch
* drivers-video-backlight-backlightc-remove-backlight-sysfs-uevent.patch
* list-use-argument-hlist_add_after-names-from-rcu-variant.patch
* list-fix-order-of-arguments-for-hlist_add_after_rcu.patch
* list-fix-order-of-arguments-for-hlist_add_after_rcu-checkpatch-fixes.patch
* klist-use-same-naming-scheme-as-hlist-for-klist_add_after.patch
* mm-utilc-add-kstrimdup.patch
* add-lib-globc.patch
* lib-globc-add-config_glob_selftest.patch
* libata-use-glob_match-from-lib-globc.patch
* lib-add-crc64-ecma-module.patch
* fs-compatc-remove-unnecessary-test-on-unsigned-value.patch
* checkpatch-attempt-to-find-unnecessary-out-of-memory-messages.patch
* checkpatch-warn-on-unnecessary-else-after-return-or-break.patch
* checkpatch-fix-complex-macro-false-positive-for-escaped-constant-char.patch
* checkpatch-fix-function-pointers-in-blank-line-needed-after-declarations-test.patch
* binfmt_elfc-use-get_random_int-to-fix-entropy-depleting.patch
* kernel-test_kprobesc-use-current-logging-functions.patch
* rtc-add-support-of-nvram-for-maxim-dallas-rtc-ds1343.patch
* fs-isofs-logging-clean-up.patch
* fs-nilfs2-superc-remove-unnecessary-test-on-unsigned-value.patch
* hfsplus-fix-longname-handling.patch
* fs-proc-kcorec-use-page_align-instead-of-alignpage_size.patch
* sysctl-remove-now-unused-typedef-ctl_table.patch
* sysctl-remove-now-unused-typedef-ctl_table-fix.patch
* fs-cachefiles-daemonc-remove-unnecessary-tests-on-unsigned-values.patch
* fs-cachefiles-bindc-remove-unnecessary-assertions.patch
* fs-qnx6-convert-printk-to-pr_foo.patch
* fs-qnx6-use-pr_fmt-and-__func__-in-logging.patch
* fs-qnx6-update-debugging-to-current-functions.patch
* lib-scatterlist-make-arch_has_sg_chain-an-actual-kconfig.patch
* lib-scatterlist-make-arch_has_sg_chain-an-actual-kconfig-fix.patch
* lib-scatterlist-make-arch_has_sg_chain-an-actual-kconfig-fix-2.patch
* lib-scatterlist-make-arch_has_sg_chain-an-actual-kconfig-fix-3.patch
* lib-scatterlist-clean-up-useless-architecture-versions-of-scatterlisth.patch
  linux-next.patch
  linux-next-rejects.patch
  linux-next-git-rejects.patch
* drivers-gpio-gpio-zevioc-fix-build.patch
* mm-page_ioc-work-around-gcc-bug.patch
* init-mainc-code-clean-up.patch
* kernel-kprobesc-convert-printk-to-pr_foo.patch
* memcg-mm-introduce-lowlimit-reclaim.patch
* memcg-mm-introduce-lowlimit-reclaim-fix.patch
* memcg-mm-introduce-lowlimit-reclaim-fix2patch.patch
* memcg-allow-setting-low_limit.patch
* memcg-doc-clarify-global-vs-limit-reclaims.patch
* memcg-doc-clarify-global-vs-limit-reclaims-fix.patch
* memcg-document-memorylow_limit_in_bytes.patch
* vmscan-memcg-check-whether-the-low-limit-should-be-ignored.patch
* mm-replace-remap_file_pages-syscall-with-emulation.patch
* mm-replace-remap_file_pages-syscall-with-emulation-fix.patch
* mm-replace-remap_file_pages-syscall-with-emulation-fix-2.patch
* mm-replace-remap_file_pages-syscall-with-emulation-fix-3.patch
* memcg-deprecate-memoryforce_empty-knob.patch
* memcg-deprecate-memoryforce_empty-knob-fix.patch
* fat-add-i_disksize-to-represent-uninitialized-size-v4.patch
* fat-add-fat_fallocate-operation-v4.patch
* fat-zero-out-seek-range-on-_fat_get_block-v4.patch
* fat-fallback-to-buffered-write-in-case-of-fallocated-region-on-direct-io-v4.patch
* fat-permit-to-return-phy-block-number-by-fibmap-in-fallocated-region-v4.patch
* documentation-filesystems-vfattxt-update-the-limitation-for-fat-fallocate-v4.patch
* nmi-provide-the-option-to-issue-an-nmi-back-trace-to-every-cpu-but-current.patch
* nmi-provide-the-option-to-issue-an-nmi-back-trace-to-every-cpu-but-current-fix.patch
* kernel-watchdogc-print-traces-for-all-cpus-on-lockup-detection.patch
* kernel-watchdogc-print-traces-for-all-cpus-on-lockup-detection-fix.patch
* kernel-watchdogc-print-traces-for-all-cpus-on-lockup-detection-fix-2.patch
* kernel-watchdogc-convert-printk-pr_warning-to-pr_foo.patch
* bio-modify-__bio_add_page-to-accept-pages-that-dont-start-a-new-segment.patch
* w1-call-put_device-if-device_register-fails.patch
* mm-add-strictlimit-knob-v2.patch
  debugging-keep-track-of-page-owners.patch
  page-owners-correct-page-order-when-to-free-page.patch
  make-sure-nobodys-leaking-resources.patch
  journal_add_journal_head-debug.patch
  journal_add_journal_head-debug-fix.patch
  releasing-resources-with-children.patch
  make-frame_pointer-default=y.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  mutex-subsystem-synchro-test-module.patch
  slab-leaks3-default-y.patch
  put_bh-debug.patch
  add-debugging-aid-for-memory-initialisation-problems.patch
  workaround-for-a-pci-restoring-bug.patch
  single_open-seq_release-leak-diagnostics.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
