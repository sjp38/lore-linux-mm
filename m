Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 2ECEE6B005A
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 18:21:23 -0400 (EDT)
Received: by mail-ob0-f178.google.com with SMTP id wn1so140929obc.9
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 15:21:22 -0700 (PDT)
Received: from mail-ob0-f202.google.com (mail-ob0-f202.google.com [209.85.214.202])
        by mx.google.com with ESMTPS id e1si2037966obf.170.2014.04.22.15.21.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 15:21:22 -0700 (PDT)
Received: by mail-ob0-f202.google.com with SMTP id gq1so40257obb.5
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 15:21:21 -0700 (PDT)
Subject: mmotm 2014-04-22-15-20 uploaded
From: akpm@linux-foundation.org
Date: Tue, 22 Apr 2014 15:21:20 -0700
Message-Id: <20140422222121.2FAB45A431E@corp2gmr1-2.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

The mm-of-the-moment snapshot 2014-04-22-15-20 has been uploaded to

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


This mmotm tree contains the following patches against 3.15-rc2:
(patches marked "*" will be included in linux-next)

  origin.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  i-need-old-gcc.patch
  maintainers-akpm-maintenance.patch
* drivers-rtc-rtc-pcf8523c-fix-month-definition.patch
* slub-fix-memcg_propagate_slab_attrs.patch
* hugetlb-ensure-hugepage-access-is-denied-if-hugepages-are-not-supported.patch
* hugetlb-ensure-hugepage-access-is-denied-if-hugepages-are-not-supported-fix.patch
* mm-compaction-make-isolate_freepages-start-at-pageblock-boundary.patch
* mm-filemap-update-find_get_pages_tag-to-deal-with-shadow-entries.patch
* x86-require-x86-64-for-automatic-numa-balancing.patch
* x86-define-_page_numa-by-reusing-software-bits-on-the-pmd-and-pte-levels.patch
* x86-define-_page_numa-by-reusing-software-bits-on-the-pmd-and-pte-levels-fix-2.patch
* x86-mm-probe-memory-block-size-for-generic-x86-64bit.patch
* arm-use-generic-fixmaph.patch
* fanotify-fan_mark_flush-avoid-having-to-provide-a-fake-invalid-fd-and-path.patch
* fanotify-create-fan_access-event-for-readdir.patch
* fs-notify-markc-trivial-cleanup.patch
* sched_clock-document-4mhz-vs-1mhz-decision.patch
* input-route-kbd-leds-through-the-generic-leds-layer.patch
* input-route-kbd-leds-through-the-generic-leds-layer-fix.patch
* ntfs-remove-null-value-assignments.patch
* drivers-net-irda-donauboe-convert-to-module_pci_driver.patch
* ocfs2-remove-null-assignments-on-static.patch
* fs-ocfs2-superc-use-ocfs2_max_vol_label_len-and-strlcpy.patch
* ocfs2-limit-printk-when-journal-is-aborted.patch
* ocfs2-limit-printk-when-journal-is-aborted-fix.patch
* ocfs2-should-add-inode-into-orphan-dir-after-updating-entry-in-ocfs2_rename.patch
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
* mm-get-rid-of-__gfp_kmemcg-fix.patch
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
* x86-make-dma_alloc_coherent-return-zeroed-memory-if-cma-is-enabled.patch
* x86-make-dma_alloc_coherent-return-zeroed-memory-if-cma-is-enabled-fix.patch
* x86-enable-dma-cma-with-swiotlb.patch
* intel-iommu-integrate-dma-cma.patch
* memblock-introduce-memblock_alloc_range.patch
* cma-add-placement-specifier-for-cma=-kernel-parameter.patch
* arch-x86-kernel-pci-dmac-fix-dma_generic_alloc_coherent-when-config_dma_cma-is-enabled.patch
* thp-consolidate-assert-checks-in-__split_huge_page.patch
* mm-huge_memoryc-complete-conversion-to-pr_foo.patch
* mm-convert-some-level-less-printks-to-pr_.patch
* include-linux-mmdebugh-add-vm_warn_on-and-vm_warn_on_once.patch
* mm-mempool-warn-about-__gfp_zero-usage.patch
* mm-mempool-warn-about-__gfp_zero-usage-fix.patch
* mm-memcontrol-remove-hierarchy-restrictions-for-swappiness-and-oom_control.patch
* mm-memcontrol-remove-hierarchy-restrictions-for-swappiness-and-oom_control-fix.patch
* mm-pass-vm_bug_on-reason-to-dump_page.patch
* mm-pass-vm_bug_on-reason-to-dump_page-fix.patch
* memory-hotplug-update-documentation-to-hide-information-about-sections-and-remove-end_phys_index.patch
* slab-document-kmalloc_order.patch
* mm-mmapc-replace-is_err-and-ptr_err-with-ptr_err_or_zero.patch
* hugetlb-prep_compound_gigantic_page-drop-__init-marker.patch
* hugetlb-add-hstate_is_gigantic.patch
* hugetlb-update_and_free_page-dont-clear-pg_reserved-bit.patch
* hugetlb-move-helpers-up-in-the-file.patch
* hugetlb-add-support-for-gigantic-page-allocation-at-runtime.patch
* hugetlb-add-support-for-gigantic-page-allocation-at-runtime-checkpatch-fixes.patch
* mm-disable-zone_reclaim_mode-by-default.patch
* mm-page_alloc-do-not-cache-reclaim-distances.patch
* mm-page_alloc-do-not-cache-reclaim-distances-fix.patch
* memcg-un-export-__memcg_kmem_get_cache.patch
* mem-hotplug-implement-get-put_online_mems.patch
* slab-get_online_mems-for-kmem_cache_createdestroyshrink.patch
* fs-hugetlbfs-inodec-complete-conversion-to-pr_foo.patch
* mm-page_alloc-prevent-migrate_reserve-pages-from-being-misplaced.patch
* mm-page_alloc-debug_vm-checks-for-free_list-placement-of-cma-and-reserve-pages.patch
* mm-move-get_user_pages-related-code-to-separate-file.patch
* mm-extract-in_gate_area-case-from-__get_user_pages.patch
* mm-cleanup-follow_page_mask.patch
* mm-extract-code-to-fault-in-a-page-from-__get_user_pages.patch
* mm-extract-code-to-fault-in-a-page-from-__get_user_pages-fix.patch
* mm-cleanup-__get_user_pages.patch
* mm-gupc-tweaks.patch
* mm-gupc-tweaks-fix.patch
* mm-compaction-clean-up-unused-code-lines.patch
* mm-compaction-cleanup-isolate_freepages.patch
* mm-compaction-cleanup-isolate_freepages-fix.patch
* mm-compaction-cleanup-isolate_freepages-fix-2.patch
* mm-debug-make-bad_range-output-more-usable-and-readable.patch
* documentation-memcg-warn-about-incomplete-kmemcg-state.patch
* m68k-call-find_vma-with-the-mmap_sem-held-in-sys_cacheflush.patch
* mips-call-find_vma-with-the-mmap_sem-held.patch
* arc-call-find_vma-with-the-mmap_sem-held.patch
* arc-call-find_vma-with-the-mmap_sem-held-fix.patch
* drm-exynos-call-find_vma-with-the-mmap_sem-held.patch
* mm-memcontrolc-introduce-helper-mem_cgroup_zoneinfo_zone.patch
* mm-memcontrolc-introduce-helper-mem_cgroup_zoneinfo_zone-checkpatch-fixes.patch
* mm-swapc-clean-up-lru_cache_add-functions.patch
* mm-mmap-remove-the-first-mapping-check.patch
* memcg-kill-config_mm_owner.patch
* mm-vmscan-do-not-throttle-based-on-pfmemalloc-reserves-if-node-has-no-zone_normal.patch
* mm-vmscan-do-not-throttle-based-on-pfmemalloc-reserves-if-node-has-no-zone_normal-checkpatch-fixes.patch
* zram-correct-offset-usage-in-zram_bio_discard.patch
* do_shared_fault-check-that-mmap_sem-is-held.patch
* sys_sgetmask-sys_ssetmask-add-config_sgetmask_syscall.patch
* drivers-misc-ti-st-st_corec-fix-null-dereference-on-protocol-type-check.patch
* printk-split-code-for-making-free-space-in-the-log-buffer.patch
* printk-ignore-too-long-messages.patch
* printk-split-message-size-computation.patch
* printk-shrink-too-long-messages.patch
* printk-return-really-stored-message-length.patch
* lib-vsprintf-add-%pt-format-specifier.patch
* drivers-video-backlight-backlightc-remove-backlight-sysfs-uevent.patch
* lib-stringc-use-the-name-c-string-in-comments.patch
* lib-xz-add-comments-for-the-intentionally-missing-break-statements.patch
* lib-xz-enable-all-filters-by-default-in-kconfig.patch
* mm-utilc-add-kstrimdup.patch
* lib-add-crc64-ecma-module.patch
* checkpatch-fix-wildcard-dt-compatible-string-checking.patch
* checkpatch-always-warn-on-missing-blank-line-after-variable-declaration-block.patch
* checkpatch-reduce-false-positives-for-missing-blank-line-after-declarations-test.patch
* checkpatch-reduce-false-positives-for-missing-blank-line-after-declarations-test-fix.patch
* fs-binfmt_elfc-fix-bool-assignements.patch
* fs-binfmt_flatc-make-old_reloc-static.patch
* binfmt_elfc-use-get_random_int-to-fix-entropy-depleting.patch
* init-mainc-dont-use-pr_debug.patch
* init-mainc-add-initcall_blacklist-kernel-parameter.patch
* init-mainc-add-initcall_blacklist-kernel-parameter-fix.patch
* kthreads-kill-clone_kernel-change-kernel_threadkernel_init-to-avoid-clone_sighand.patch
* drivers-rtc-interfacec-fix-infinite-loop-in-initializing-the-alarm.patch
* documentation-devicetree-bindings-add-documentation-for-the-apm-x-gene-soc-rtc-dts-binding.patch
* drivers-rtc-add-apm-x-gene-soc-rtc-driver.patch
* arm64-add-apm-x-gene-soc-rtc-dts-entry.patch
* rtc-m41t80-remove-drv_version-macro.patch
* rtc-m41t80-clean-up-error-paths.patch
* rtc-m41t80-propagate-error-value-from-smbus-functions.patch
* rtc-m41t80-add-support-for-microcrystal-rv4162.patch
* drivers-rtc-rtc-efic-avoid-subtracting-day-twice-when-computing-year-days.patch
* rtc-rtc-cmos-drivers-char-rtcc-features-for-decstation-support.patch
* rtc-rtc-cmos-drivers-char-rtcc-features-for-decstation-support-fix.patch
* dec-switch-decstation-systems-to-rtc-cmos.patch
* fs-befs-linuxvfsc-replace-strncpy-by-strlcpy.patch
* fs-befs-btreec-replace-strncpy-by-strlcpy-coding-style-fixing.patch
* hfsplus-fixes-worst-case-unicode-to-char-conversion-of-file-names-and-attributes.patch
* hfsplus-fixes-worst-case-unicode-to-char-conversion-of-file-names-and-attributes-fix.patch
* hfsplus-correct-usage-of-hfsplus_attr_max_strlen-for-non-english-attributes.patch
* hfsplus-correct-usage-of-hfsplus_attr_max_strlen-for-non-english-attributes-fix.patch
* hfsplus-correct-usage-of-hfsplus_attr_max_strlen-for-non-english-attributes-fix-2.patch
* hfsplus-remove-unused-routine-hfsplus_attr_build_key_uni.patch
* hfsplus-fix-longname-handling.patch
* fs-reiserfs-bitmapc-coding-style-fixes.patch
* fs-fat-add-support-for-dos-1x-formatted-volumes.patch
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
* kernel-panicc-add-crash_kexec_post_notifiers-option-for-kdump-after-panic_notifers.patch
* kexec-save-pg_head_mask-in-vmcoreinfo.patch
* idr-fix-overflow-bug-during-maximum-id-calculation-at-maximum-height.patch
* idr-fix-unexpected-id-removal-when-idr_removeunallocated_id.patch
* idr-fix-null-pointer-dereference-when-ida_removeunallocated_id.patch
* idr-fix-idr_replaces-returned-error-code.patch
* idr-dont-need-to-shink-the-free-list-when-idr_remove.patch
* idr-reduce-the-unneeded-check-in-free_layer.patch
* idr-reorder-the-fields.patch
* fs-affs-filec-remove-unnecessary-function-parameters.patch
* fs-affs-convert-printk-to-pr_foo.patch
* fs-affs-pr_debug-cleanup.patch
* initramfs-remove-compression-mode-choice.patch
* ipc-constify-ipc_ops.patch
* ipc-kernel-use-linux-headers.patch
* ipc-kernel-clear-whitespace.patch
* lib-scatterlist-make-arch_has_sg_chain-an-actual-kconfig.patch
* lib-scatterlist-make-arch_has_sg_chain-an-actual-kconfig-fix.patch
* lib-scatterlist-make-arch_has_sg_chain-an-actual-kconfig-fix-2.patch
* lib-scatterlist-make-arch_has_sg_chain-an-actual-kconfig-fix-3.patch
* lib-scatterlist-clean-up-useless-architecture-versions-of-scatterlisth.patch
  linux-next.patch
  linux-next-git-rejects.patch
* drivers-gpio-gpio-zevioc-fix-build.patch
* arm-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* ia64-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* tile-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* cdrom-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* random-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* parport-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* scsi-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* coda-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* fscache-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* lockd-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* nfs-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* inotify-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* ntfs-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* fs-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* key-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* ipc-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* sysctl-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* mm-convert-use-of-typedef-ctl_table-to-struct-ctl_table.patch
* mfd-rtc-s5m-do-not-allocate-rtc-i2c-dummy-and-regmap-for-unsupported-chipsets.patch
* mfd-rtc-sec-s5m-rename-sec-symbols-to-s5m.patch
* rtc-s5m-remove-undocumented-time-init-on-first-boot.patch
* rtc-s5m-use-shorter-time-of-register-update.patch
* rtc-s5m-support-different-register-layout.patch
* rtc-s5m-add-support-for-s2mps14-rtc.patch
* rtc-s5m-consolidate-two-device-type-switch-statements.patch
* blackfin-ptrace-call-find_vma-with-the-mmap_sem-held.patch
* fs-bio-remove-bs-paramater-in-biovec_create_pool.patch
* fs-bioc-remove-nr_segs-unused-function-parameter.patch
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
