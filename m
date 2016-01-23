Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 6431D6B0005
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 19:44:21 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id 65so50198420pff.2
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 16:44:21 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 193si13003139pfa.204.2016.01.22.16.44.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jan 2016 16:44:20 -0800 (PST)
Date: Fri, 22 Jan 2016 16:44:19 -0800
From: akpm@linux-foundation.org
Subject: mmotm 2016-01-22-16-43 uploaded
Message-ID: <56a2cce3.aevfWDcpVKNmSN3s%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2016-01-22-16-43 has been uploaded to

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


This mmotm tree contains the following patches against 4.4:
(patches marked "*" will be included in linux-next)

  origin.patch
* dax-fix-null-pointer-dereference-in-__dax_dbg.patch
* dax-fix-conversion-of-holes-to-pmds.patch
* pmem-add-wb_cache_pmem-to-the-pmem-api.patch
* dax-support-dirty-dax-entries-in-radix-tree.patch
* mm-add-find_get_entries_tag.patch
* dax-add-support-for-fsync-sync.patch
* ext2-call-dax_pfn_mkwrite-for-dax-fsync-msync.patch
* ext4-call-dax_pfn_mkwrite-for-dax-fsync-msync.patch
* xfs-call-dax_pfn_mkwrite-for-dax-fsync-msync.patch
* dax-never-rely-on-bhb_dev-being-set-by-get_block.patch
* tree-wide-use-kvfree-than-conditional-kfree-vfree.patch
* maintainers-return-arch-sh-to-maintained-state-with-new-maintainers.patch
  i-need-old-gcc.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  drivers-gpu-drm-i915-intel_spritec-fix-build.patch
  drivers-gpu-drm-i915-intel_tvc-fix-build.patch
  arm-mm-do-not-use-virt_to_idmap-for-nommu-systems.patch
* thp-make-split_queue-per-node.patch
* thp-change-deferred_split_count-to-return-number-of-thp-in-queue.patch
* thp-change-deferred_split_count-to-return-number-of-thp-in-queue-fix.patch
* thp-limit-number-of-object-to-scan-on-deferred_split_scan.patch
* lib-test-string_helpersc-fix-and-improve-string_get_size-tests.patch
* phys_to_pfn_t-use-phys_addr_t.patch
* ocfs2-cluster-fix-memory-leak-in-o2hb_region_release.patch
* vmstat-remove-bug_on-from-vmstat_update.patch
* proc-revert-proc-pid-maps-annotation.patch
* proc-fix-missing-reference-of-mm.patch
* kallsyms-add-support-for-relative-offsets-in-kallsyms-address-table.patch
* kallsyms-add-support-for-relative-offsets-in-kallsyms-address-table-fix.patch
* fs-ext4-fsyncc-generic_file_fsync-call-based-on-barrier-flag.patch
* ocfs2-add-ocfs2_write_type_t-type-to-identify-the-caller-of-write.patch
* ocfs2-use-c_new-to-indicate-newly-allocated-extents.patch
* ocfs2-test-target-page-before-change-it.patch
* ocfs2-do-not-change-i_size-in-write_end-for-direct-io.patch
* ocfs2-return-the-physical-address-in-ocfs2_write_cluster.patch
* ocfs2-record-unwritten-extents-when-populate-write-desc.patch
* ocfs2-fix-sparse-file-data-ordering-issue-in-direct-io.patch
* ocfs2-code-clean-up-for-direct-io.patch
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
* ocfs2-export-ocfs2_kset-for-online-file-check.patch
* ocfs2-sysfile-interfaces-for-online-file-check.patch
* ocfs2-create-remove-sysfile-for-online-file-check.patch
* ocfs2-check-fix-inode-block-for-online-file-check.patch
* ocfs2-add-feature-document-for-online-file-check.patch
* ocfs2-o2hb-add-negotiate-timer.patch
* ocfs2-o2hb-add-nego_timeout-message.patch
* ocfs2-o2hb-add-negotiate_approve-message.patch
* ocfs2-o2hb-add-some-user-debug-log.patch
* ocfs2-o2hb-dont-negotiate-if-last-hb-fail.patch
* ocfs2-o2hb-fix-hb-hung-time.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
  mm.patch
* fs-mpagec-mpage_readpages-use-lru_to_page-helper.patch
* mm-page_allocc-calculate-zone_start_pfn-at-zone_spanned_pages_in_node.patch
* mm-page_allocc-introduce-kernelcore=mirror-option.patch
* mm-page_allocc-introduce-kernelcore=mirror-option-fix.patch
* mm-page_allocc-rework-code-layout-in-memmap_init_zone.patch
* ksm-introduce-ksm_max_page_sharing-per-page-deduplication-limit.patch
* ksm-introduce-ksm_max_page_sharing-per-page-deduplication-limit-fix-2.patch
* ksm-introduce-ksm_max_page_sharing-per-page-deduplication-limit-fix-3.patch
* mm-make-optimistic-check-for-swapin-readahead.patch
* mm-make-optimistic-check-for-swapin-readahead-fix-2.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-2.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-3.patch
* mm-oom-rework-oom-detection.patch
* mm-oom-rework-oom-detection-checkpatch-fixes.patch
* mm-throttle-on-io-only-when-there-are-too-many-dirty-and-writeback-pages.patch
* mm-use-watermak-checks-for-__gfp_repeat-high-order-allocations.patch
* mm-use-watermak-checks-for-__gfp_repeat-high-order-allocations-checkpatch-fixes.patch
* sched-add-schedule_timeout_idle.patch
* mm-oom-introduce-oom-reaper.patch
* mm-oom-introduce-oom-reaper-v4.patch
* oom-reaper-handle-anonymous-mlocked-pages.patch
* oom-clear-tif_memdie-after-oom_reaper-managed-to-unmap-the-address-space.patch
* mm-oom_killc-dont-skip-pf_exiting-tasks-when-searching-for-a-victim.patch
* mm-memblock-if-nr_new-is-0-just-return.patch
* kernel-hung_taskc-use-timeout-diff-when-timeout-is-updated.patch
* printk-nmi-generic-solution-for-safe-printk-in-nmi.patch
* printk-nmi-use-irq-work-only-when-ready.patch
* printk-nmi-warn-when-some-message-has-been-lost-in-nmi-context.patch
* printk-nmi-increase-the-size-of-nmi-buffer-and-make-it-configurable.patch
* mm-utilc-add-kstrimdup.patch
* lib-add-crc64-ecma-module.patch
* kexec-introduce-a-protection-mechanism-for-the-crashkernel-reserved-memory.patch
* kexec-provide-arch_kexec_protectunprotect_crashkres.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* ipc-semc-fix-complex_count-vs-simple-op-race.patch
* ipc-msgc-msgsnd-use-freezable-blocking-call.patch
* msgrcv-use-freezable-blocking-call.patch
  linux-next.patch
* drivers-net-wireless-intel-iwlwifi-dvm-calibc-fix-min-warning.patch
* include-linux-huge_mmh-pmd_trans_huge_lock-returns-a-spinlock_t.patch
* lib-string_helpers-export-string_units_210-for-others.patch
* lib-string_helpers-fix-indentation-in-few-places.patch
* x86-efi-print-size-and-base-in-binary-units-in-efi_print_memmap.patch
* x86-efi-use-proper-units-in-efi_find_mirror.patch
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
