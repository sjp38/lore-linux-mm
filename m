Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 020B96B0031
	for <linux-mm@kvack.org>; Tue, 15 Apr 2014 19:15:51 -0400 (EDT)
Received: by mail-ig0-f177.google.com with SMTP id ur14so394375igb.16
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 16:15:51 -0700 (PDT)
Received: from mail-ie0-f201.google.com (mail-ie0-f201.google.com [209.85.223.201])
        by mx.google.com with ESMTPS id u6si13732275icp.146.2014.04.15.16.15.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Apr 2014 16:15:51 -0700 (PDT)
Received: by mail-ie0-f201.google.com with SMTP id rd18so2156135iec.4
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 16:15:50 -0700 (PDT)
Subject: mmotm 2014-04-15-16-14 uploaded
From: akpm@linux-foundation.org
Date: Tue, 15 Apr 2014 16:15:49 -0700
Message-Id: <20140415231550.2D2F05A4260@corp2gmr1-2.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

The mm-of-the-moment snapshot 2014-04-15-16-14 has been uploaded to

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


This mmotm tree contains the following patches against 3.15-rc1:
(patches marked "*" will be included in linux-next)

  origin.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  i-need-old-gcc.patch
  maintainers-akpm-maintenance.patch
* vmscan-reclaim_clean_pages_from_list-must-use-mod_zone_page_state.patch
* init-kconfig-move-the-trusted-keyring-config-option-to-general-setup.patch
* wait-explain-the-shadowing-and-type-inconsistencies.patch
* mm-hugetlbc-add-cond_resched_lock-in-return_unused_surplus_pages.patch
* mips-export-flush_icache_range.patch
* mips-export-flush_icache_range-fix.patch
* mm-use-paravirt-friendly-ops-for-numa-hinting-ptes.patch
* mm-fix-config_debug_vm_rb-description.patch
* x86-require-x86-64-for-automatic-numa-balancing.patch
* x86-define-_page_numa-by-reusing-software-bits-on-the-pmd-and-pte-levels.patch
* arm-use-generic-fixmaph.patch
* sched_clock-document-4mhz-vs-1mhz-decision.patch
* input-route-kbd-leds-through-the-generic-leds-layer.patch
* input-route-kbd-leds-through-the-generic-leds-layer-fix.patch
* drivers-input-misc-da9055_onkeyc-remove-use-of-regmap_irq_get_virq.patch
* ntfs-remove-null-value-assignments.patch
* drivers-net-irda-donauboe-convert-to-module_pci_driver.patch
* ocfs2-remove-null-assignments-on-static.patch
* fs-ocfs2-superc-use-ocfs2_max_vol_label_len-and-strlcpy.patch
* ocfs2-o2net-incorrect-to-terminate-accepting-connections-loop-upon-rejecting-an-invalid-one.patch
* ocfs2-o2net-incorrect-to-terminate-accepting-connections-loop-upon-rejecting-an-ivalid-one-orabug-17489469.patch
* ocfs2-fix-a-tiny-race-when-running-dirop_fileop_racer.patch
* ocfs2-do-not-return-dlm_migrate_response_mastery_ref-to-avoid-endlessloop-during-umount.patch
* ocfs2-manually-do-the-iput-once-ocfs2_add_entry-failed-in-ocfs2_symlink-and-ocfs2_mknod.patch
* maintainers-update-ibm-serveraid-raid-info.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* watchdog-trigger-all-cpu-backtrace-when-locked-up-and-going-to-panic.patch
  mm.patch
* slb-charge-slabs-to-kmemcg-explicitly.patch
* mm-get-rid-of-__gfp_kmemcg.patch
* mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff.patch
* mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff-v2.patch
* mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff-v3.patch
* mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff-v3-fix.patch
* pagewalk-update-page-table-walker-core.patch
* pagewalk-update-page-table-walker-core-fix-end-address-calculation-in-walk_page_range.patch
* pagewalk-update-page-table-walker-core-fix-end-address-calculation-in-walk_page_range-fix.patch
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
* mm-add-pte_present-check-on-existing-hugetlb_entry-callbacks.patch
* mm-pagewalkc-move-pte-null-check.patch
* mm-softdirty-make-freshly-remapped-file-pages-being-softdirty-unconditionally.patch
* mm-softdirty-dont-forget-to-save-file-map-softdiry-bit-on-unmap.patch
* mm-softdirty-clear-vm_softdirty-flag-inside-clear_refs_write-instead-of-clear_soft_dirty.patch
* mm-introduce-do_shared_fault-and-drop-do_fault-fix-fix.patch
* mm-compactionc-isolate_freepages_block-small-tuneup.patch
* fs-mpagec-forgotten-write_sync-in-case-of-data-integrity-write.patch
* mm-rmap-dont-try-to-add-an-unevictable-page-to-lru-list.patch
* mm-only-force-scan-in-reclaim-when-none-of-the-lrus-are-big-enough.patch
* mmvmacache-add-debug-data.patch
* mmvmacache-optimize-overflow-system-wide-flushing.patch
* do_shared_fault-check-that-mmap_sem-is-held.patch
* drivers-misc-ti-st-st_corec-fix-null-dereference-on-protocol-type-check.patch
* lib-vsprintf-add-%pt-format-specifier.patch
* drivers-video-backlight-backlightc-remove-backlight-sysfs-uevent.patch
* lib-stringc-use-the-name-c-string-in-comments.patch
* lib-xz-enable-all-filters-by-default-in-kconfig.patch
* mm-utilc-add-kstrimdup.patch
* lib-add-crc64-ecma-module.patch
* checkpatch-always-warn-on-missing-blank-line-after-variable-declaration-block.patch
* checkpatch-reduce-false-positives-for-missing-blank-line-after-declarations-test.patch
* checkpatch-reduce-false-positives-for-missing-blank-line-after-declarations-test-fix.patch
* binfmt_elfc-use-get_random_int-to-fix-entropy-depleting.patch
* init-mainc-dont-use-pr_debug.patch
* init-mainc-add-initcall_blacklist-kernel-parameter.patch
* init-mainc-add-initcall_blacklist-kernel-parameter-fix.patch
* drivers-rtc-interfacec-fix-infinite-loop-in-initializing-the-alarm.patch
* documentation-devicetree-bindings-add-documentation-for-the-apm-x-gene-soc-rtc-dts-binding.patch
* drivers-rtc-add-apm-x-gene-soc-rtc-driver.patch
* arm64-add-apm-x-gene-soc-rtc-dts-entry.patch
* fs-befs-linuxvfsc-replace-strncpy-by-strlcpy.patch
* hfsplus-fix-longname-handling.patch
* fat-add-i_disksize-to-represent-uninitialized-size-v4.patch
* fat-add-fat_fallocate-operation-v4.patch
* fat-zero-out-seek-range-on-_fat_get_block-v4.patch
* fat-fallback-to-buffered-write-in-case-of-fallocated-region-on-direct-io-v4.patch
* fat-permit-to-return-phy-block-number-by-fibmap-in-fallocated-region-v4.patch
* documentation-filesystems-vfattxt-update-the-limitation-for-fat-fallocate-v4.patch
* documentation-submittingpatches-describe-the-fixes-tag.patch
* signals-kill-sigfindinword.patch
* signals-s-siginitset-sigemptyset-in-do_sigtimedwait.patch
* signals-kill-rm_from_queue-change-prepare_signal-to-use-for_each_thread.patch
* signals-rename-rm_from_queue_full-to-flush_sigqueue_mask.patch
* signals-cleanup-the-usage-of-t-current-in-do_sigaction.patch
* signals-mv-disallow_signal-from-schedh-exitc-to-signal.patch
* signals-jffs2-fix-the-wrong-usage-of-disallow_signal.patch
* signals-kill-the-obsolete-sigdelset-and-recalc_sigpending-in-allow_signal.patch
* signals-disallow_signal-should-flush-the-potentially-pending-signal.patch
* signals-introduce-kernel_sigaction.patch
* signals-change-wait_for_helper-to-use-kernel_sigaction.patch
* pps-add-non-blocking-option-to-pps_fetch-ioctl.patch
* initramfs-remove-compression-mode-choice.patch
* ipc-constify-ipc_ops.patch
* lib-scatterlist-make-arch_has_sg_chain-an-actual-kconfig.patch
* lib-scatterlist-clean-up-useless-architecture-versions-of-scatterlisth.patch
  linux-next.patch
* drivers-gpio-gpio-zevioc-fix-build.patch
* w1-call-put_device-if-device_register-fails.patch
* arm-move-arm_dma_limit-to-setup_dma_zone.patch
* ufs-sb-mutex-merge-mutex_destroy.patch
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
