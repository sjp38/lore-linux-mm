Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 0781F6B0253
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 18:54:11 -0500 (EST)
Received: by padhx2 with SMTP id hx2so11987952pad.1
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 15:54:10 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j6si8231396pbq.165.2015.11.10.15.54.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Nov 2015 15:54:09 -0800 (PST)
Date: Tue, 10 Nov 2015 15:54:08 -0800
From: akpm@linux-foundation.org
Subject: mmotm 2015-11-10-15-53 uploaded
Message-ID: <564283a0.beR7/+fS68wfuK2o%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz

The mm-of-the-moment snapshot 2015-11-10-15-53 has been uploaded to

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


This mmotm tree contains the following patches against 4.3:
(patches marked "*" will be included in linux-next)

  origin.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  drivers-gpu-drm-i915-intel_spritec-fix-build.patch
  drivers-gpu-drm-i915-intel_tvc-fix-build.patch
  arm-mm-do-not-use-virt_to_idmap-for-nommu-systems.patch
* selftests-mlock2-add-missing-define-_gnu_source.patch
* selftests-mlock2-add-ull-prefix-to-64-bit-constants.patch
* hugetlb-trivial-comment-fix.patch
* lib-string-add-ull-suffix-to-the-constant-definition.patch
* pcnet32-use-pci_set_dma_mask-insted-of-pci_dma_supported.patch
* tw68-core-use-pci_set_dma_mask-insted-of-pci_dma_supported.patch
* saa7164-use-pci_set_dma_mask-insted-of-pci_dma_supported.patch
* saa7134-use-pci_set_dma_mask-insted-of-pci_dma_supported.patch
* cx88-use-pci_set_dma_mask-insted-of-pci_dma_supported.patch
* cx25821-use-pci_set_dma_mask-insted-of-pci_dma_supported.patch
* cx23885-use-pci_set_dma_mask-insted-of-pci_dma_supported.patch
* netup_unidvb-use-pci_set_dma_mask-insted-of-pci_dma_supported.patch
* nouveau-dont-call-pci_dma_supported.patch
* sfc-dont-call-dma_supported.patch
* kaweth-remove-ifdefed-out-call-to-dma_supported.patch
* usbnet-remove-ifdefed-out-call-to-dma_supported.patch
* pci-remove-pci_dma_supported.patch
* configfs-allow-dynamic-group-creation.patch
* instmem-gk20a-do-not-use-non-portable-dma_to_phys.patch
* iio-core-introduce-iio-configfs-support.patch
* iio-core-introduce-iio-software-triggers.patch
* iio-core-introduce-iio-software-triggers-fix.patch
* iio-trigger-introduce-iio-hrtimer-based-trigger.patch
* iio-documentation-add-iio-configfs-documentation.patch
* fs-ext4-fsyncc-generic_file_fsync-call-based-on-barrier-flag.patch
* ocfs2-add-ocfs2_write_type_t-type-to-identify-the-caller-of-write.patch
* ocfs2-use-c_new-to-indicate-newly-allocated-extents.patch
* ocfs2-test-target-page-before-change-it.patch
* ocfs2-do-not-change-i_size-in-write_end-for-direct-io.patch
* ocfs2-return-the-physical-address-in-ocfs2_write_cluster.patch
* ocfs2-record-unwritten-extents-when-populate-write-desc.patch
* ocfs2-fix-sparse-file-data-ordering-issue-in-direct-io.patch
* ocfs2-code-clean-up-for-direct-io.patch
* ocfs2-dlm-fix-race-between-convert-and-recovery.patch
* ocfs2-dlm-fix-race-between-convert-and-recovery-v2.patch
* ocfs2-dlm-fix-race-between-convert-and-recovery-v3.patch
* ocfs2-dlm-fix-bug-in-dlm_move_lockres_to_recovery_list.patch
* ocfs2-extend-transaction-for-ocfs2_remove_rightmost_path-and-ocfs2_update_edge_lengths-before-to-avoid-inconsistency-between-inode-and-et.patch
* extend-enough-credits-for-freeing-one-truncate-record-while-replaying-truncate-records.patch
* ocfs2-avoid-occurring-deadlock-by-changing-ocfs2_wq-from-global-to-local.patch
* ocfs2-solve-a-problem-of-crossing-the-boundary-in-updating-backups.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
  mm.patch
* slub-create-new-___slab_alloc-function-that-can-be-called-with-irqs-disabled.patch
* slub-avoid-irqoff-on-in-bulk-allocation.patch
* slub-mark-the-dangling-ifdef-else-of-config_slub_debug.patch
* slab-implement-bulking-for-slab-allocator.patch
* slub-support-for-bulk-free-with-slub-freelists.patch
* slub-optimize-bulk-slowpath-free-by-detached-freelist.patch
* slub-optimize-bulk-slowpath-free-by-detached-freelist-fix.patch
* slabh-sprinkle-__assume_aligned-attributes.patch
* mm-add-tracepoint-for-scanning-pages.patch
* mm-add-tracepoint-for-scanning-pages-fix.patch
* mm-make-optimistic-check-for-swapin-readahead.patch
* mm-make-optimistic-check-for-swapin-readahead-fix.patch
* mm-make-optimistic-check-for-swapin-readahead-fix-2.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-2.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-3.patch
* osd-fs-__r4w_get_page-rely-on-pageuptodate-for-uptodate.patch
* mm-hugetlbfs-fix-bugs-in-fallocate-hole-punch-of-areas-with-holes.patch
* page-flags-trivial-cleanup-for-pagetrans-helpers.patch
* page-flags-move-code-around.patch
* page-flags-introduce-page-flags-policies-wrt-compound-pages.patch
* page-flags-introduce-page-flags-policies-wrt-compound-pages-fix.patch
* page-flags-introduce-page-flags-policies-wrt-compound-pages-fix-fix.patch
* page-flags-introduce-page-flags-policies-wrt-compound-pages-fix-3.patch
* page-flags-define-pg_locked-behavior-on-compound-pages.patch
* page-flags-define-pg_locked-behavior-on-compound-pages-fix.patch
* page-flags-define-behavior-of-fs-io-related-flags-on-compound-pages.patch
* page-flags-define-behavior-of-lru-related-flags-on-compound-pages.patch
* page-flags-define-behavior-slb-related-flags-on-compound-pages.patch
* page-flags-define-behavior-of-xen-related-flags-on-compound-pages.patch
* page-flags-define-pg_reserved-behavior-on-compound-pages.patch
* page-flags-define-pg_reserved-behavior-on-compound-pages-fix.patch
* page-flags-define-pg_swapbacked-behavior-on-compound-pages.patch
* page-flags-define-pg_swapcache-behavior-on-compound-pages.patch
* page-flags-define-pg_mlocked-behavior-on-compound-pages.patch
* page-flags-define-pg_uncached-behavior-on-compound-pages.patch
* page-flags-define-pg_uptodate-behavior-on-compound-pages.patch
* page-flags-look-at-head-page-if-the-flag-is-encoded-in-page-mapping.patch
* mm-sanitize-page-mapping-for-tail-pages.patch
* mm-proc-adjust-pss-calculation.patch
* rmap-add-argument-to-charge-compound-page.patch
* memcg-adjust-to-support-new-thp-refcounting.patch
* mm-thp-adjust-conditions-when-we-can-reuse-the-page-on-wp-fault.patch
* mm-adjust-foll_split-for-new-refcounting.patch
* mm-handle-pte-mapped-tail-pages-in-gerneric-fast-gup-implementaiton.patch
* thp-mlock-do-not-allow-huge-pages-in-mlocked-area.patch
* khugepaged-ignore-pmd-tables-with-thp-mapped-with-ptes.patch
* thp-rename-split_huge_page_pmd-to-split_huge_pmd.patch
* mm-vmstats-new-thp-splitting-event.patch
* mm-temporally-mark-thp-broken.patch
* thp-drop-all-split_huge_page-related-code.patch
* mm-drop-tail-page-refcounting.patch
* futex-thp-remove-special-case-for-thp-in-get_futex_key.patch
* futex-thp-remove-special-case-for-thp-in-get_futex_key-fix.patch
* ksm-prepare-to-new-thp-semantics.patch
* mm-thp-remove-compound_lock.patch
* arm64-thp-remove-infrastructure-for-handling-splitting-pmds.patch
* arm-thp-remove-infrastructure-for-handling-splitting-pmds.patch
* arm-thp-remove-infrastructure-for-handling-splitting-pmds-fix.patch
* mips-thp-remove-infrastructure-for-handling-splitting-pmds.patch
* powerpc-thp-remove-infrastructure-for-handling-splitting-pmds.patch
* s390-thp-remove-infrastructure-for-handling-splitting-pmds.patch
* sparc-thp-remove-infrastructure-for-handling-splitting-pmds.patch
* tile-thp-remove-infrastructure-for-handling-splitting-pmds.patch
* x86-thp-remove-infrastructure-for-handling-splitting-pmds.patch
* mm-thp-remove-infrastructure-for-handling-splitting-pmds.patch
* mm-thp-remove-infrastructure-for-handling-splitting-pmds-fix.patch
* mm-rework-mapcount-accounting-to-enable-4k-mapping-of-thps.patch
* mm-rework-mapcount-accounting-to-enable-4k-mapping-of-thps-fix.patch
* mm-rework-mapcount-accounting-to-enable-4k-mapping-of-thps-fix-2.patch
* mm-rework-mapcount-accounting-to-enable-4k-mapping-of-thps-fix-3.patch
* mm-rework-mapcount-accounting-to-enable-4k-mapping-of-thps-fix-4.patch
* mm-differentiate-page_mapped-from-page_mapcount-for-compound-pages.patch
* mm-numa-skip-pte-mapped-thp-on-numa-fault.patch
* thp-implement-split_huge_pmd.patch
* thp-add-option-to-setup-migration-entries-during-pmd-split.patch
* thp-mm-split_huge_page-caller-need-to-lock-page.patch
* mm-hwpoison-adjust-for-new-thp-refcounting.patch
* mm-hwpoison-adjust-for-new-thp-refcounting-fix.patch
* thp-reintroduce-split_huge_page.patch
* thp-reintroduce-split_huge_page-fix-2.patch
* thp-reintroduce-split_huge_page-fix-3.patch
* migrate_pages-try-to-split-pages-on-qeueuing.patch
* thp-introduce-deferred_split_huge_page.patch
* mm-re-enable-thp.patch
* thp-update-documentation.patch
* thp-allow-mlocked-thp-again.patch
* mm-prepare-page_referenced-and-page_idle-to-new-thp-refcounting.patch
* mm-prepare-page_referenced-and-page_idle-to-new-thp-refcounting-fix.patch
* mm-prepare-page_referenced-and-page_idle-to-new-thp-refcounting-checkpatch-fixes.patch
* mm-prepare-page_referenced-and-page_idle-to-new-thp-refcounting-fix-fix.patch
* mm-increase-swap_cluster_max-to-batch-tlb-flushes.patch
* mm-increase-swap_cluster_max-to-batch-tlb-flushes-fix.patch
* mm-increase-swap_cluster_max-to-batch-tlb-flushes-fix-fix.patch
* use-poison_pointer_delta-for-poison-pointers.patch
* string_helpers-fix-precision-loss-for-some-inputs.patch
* mm-utilc-add-kstrimdup.patch
* lib-add-crc64-ecma-module.patch
* checkpatch-warn-when-casting-constants-to-c90-int-or-longer-types.patch
* checkpatch-improve-macros-with-flow-control-test.patch
* fat-add-fat_fallocate-operation.patch
* fat-skip-cluster-allocation-on-fallocated-region.patch
* fat-permit-to-return-phy-block-number-by-fibmap-in-fallocated-region.patch
* documentation-filesystems-vfattxt-update-the-limitation-for-fat-fallocate.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* dma-debug-allow-poisoning-nonzero-allocations.patch
* ipc-msgc-msgsnd-use-freezable-blocking-call.patch
* msgrcv-use-freezable-blocking-call.patch
  linux-next.patch
  linux-next-git-rejects.patch
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
