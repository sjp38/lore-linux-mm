Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id EB1A32802C8
	for <linux-mm@kvack.org>; Mon,  6 Jul 2015 19:25:36 -0400 (EDT)
Received: by iebmu5 with SMTP id mu5so123403885ieb.1
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 16:25:36 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g6si18550092icv.14.2015.07.06.16.25.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jul 2015 16:25:35 -0700 (PDT)
Date: Mon, 06 Jul 2015 16:25:34 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2015-07-06-16-25 uploaded
Message-ID: <559b0e6e.lK7yCR5YMKIZ9JAq%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz

The mm-of-the-moment snapshot 2015-07-06-16-25 has been uploaded to

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


This mmotm tree contains the following patches against 4.2-rc1:
(patches marked "*" will be included in linux-next)

  origin.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
* openrisc-fix-config_uid16-setting.patch
* revert-s390-mm-change-hpage_shift-type-to-int.patch
* revert-s390-mm-make-hugepages_supported-a-boot-time-decision.patch
* mm-hugetlb-allow-hugepages_supported-to-be-architecture-specific.patch
* s390-hugetlb-add-hugepages_supported-define.patch
* ocfs2-fix-bug-in-ocfs2_downconvert_thread_do_work.patch
* ocfs2-fix-bug-in-ocfs2_downconvert_thread_do_work-v2.patch
* ntfs-deletion-of-unnecessary-checks-before-the-function-call-iput.patch
* fs-ext4-fsyncc-generic_file_fsync-call-based-on-barrier-flag.patch
* ocfs2-set-filesytem-read-only-when-ocfs2_delete_entry-failed.patch
* ocfs2-set-filesytem-read-only-when-ocfs2_delete_entry-failed-v2.patch
* ocfs2-trusted-xattr-missing-cap_sys_admin-check.patch
* ocfs2-flush-inode-data-to-disk-and-free-inode-when-i_count-becomes-zero.patch
* add-errors=continue.patch
* acknowledge-return-value-of-ocfs2_error.patch
* clear-the-rest-of-the-buffers-on-error.patch
* ocfs2-fix-a-tiny-case-that-inode-can-not-removed.patch
* ocfs2-add-ip_alloc_sem-in-direct-io-to-protect-allocation-changes.patch
* ocfs2-extend-transaction-for-ocfs2_remove_rightmost_path-and-ocfs2_update_edge_lengths-before-to-avoid-inconsistency-between-inode-and-et.patch
* ocfs2-do-not-set-fs-read-only-if-rec-is-empty-while-committing-truncate.patch
* extend-enough-credits-for-freeing-one-truncate-record-while-replaying-truncate-records.patch
* resubmit-bug_onlockres-l_level-=-dlm_lock_ex-checkpointed-tripped-in-ocfs2_ci_checkpointed.patch
* resubmit-ocfs2_iop_set-get_acl-called-from-the-vfs-so-take-inode-lock-v2second-version.patch
* ocfs2-fix-race-between-crashed-dio-and-rm.patch
* ocfs2-use-64bit-variables-to-track-heartbeat-time.patch
* ocfs2-call-ocfs2_journal_access_di-before-ocfs2_journal_dirty-in-ocfs2_write_end_nolock.patch
* ocfs2-avoid-access-invalid-address-when-read-o2dlm-debug-messages.patch
* ocfs2-neaten-do_error-ocfs2_error-and-ocfs2_abort.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
  mm.patch
* slab-infrastructure-for-bulk-object-allocation-and-freeing-v3.patch
* slab-infrastructure-for-bulk-object-allocation-and-freeing-v3-fix.patch
* slub-bulk-alloc-extract-objects-from-the-per-cpu-slab.patch
* userfaultfd-linux-documentation-vm-userfaultfdtxt.patch
* userfaultfd-linux-documentation-vm-userfaultfdtxt-fix.patch
* userfaultfd-waitqueue-add-nr-wake-parameter-to-__wake_up_locked_key.patch
* userfaultfd-uapi.patch
* userfaultfd-uapi-add-missing-include-typesh.patch
* userfaultfd-linux-userfaultfd_kh.patch
* userfaultfd-add-vm_userfaultfd_ctx-to-the-vm_area_struct.patch
* userfaultfd-add-vm_uffd_missing-and-vm_uffd_wp.patch
* userfaultfd-call-handle_userfault-for-userfaultfd_missing-faults.patch
* userfaultfd-teach-vma_merge-to-merge-across-vma-vm_userfaultfd_ctx.patch
* userfaultfd-prevent-khugepaged-to-merge-if-userfaultfd-is-armed.patch
* userfaultfd-add-new-syscall-to-provide-memory-externalization.patch
* userfaultfd-add-new-syscall-to-provide-memory-externalization-fix.patch
* userfaultfd-add-new-syscall-to-provide-memory-externalization-fix-fix.patch
* userfaultfd-add-new-syscall-to-provide-memory-externalization-fix-fix-fix.patch
* userfaultfd-rename-uffd_apibits-into-features.patch
* userfaultfd-rename-uffd_apibits-into-features-fixup.patch
* userfaultfd-change-the-read-api-to-return-a-uffd_msg.patch
* userfaultfd-change-the-read-api-to-return-a-uffd_msg-fix.patch
* userfaultfd-change-the-read-api-to-return-a-uffd_msg-fix-2.patch
* userfaultfd-change-the-read-api-to-return-a-uffd_msg-fix-2-fix.patch
* userfaultfd-wake-pending-userfaults.patch
* userfaultfd-optimize-read-and-poll-to-be-o1.patch
* userfaultfd-optimize-read-and-poll-to-be-o1-fix.patch
* userfaultfd-allocate-the-userfaultfd_ctx-cacheline-aligned.patch
* userfaultfd-solve-the-race-between-uffdio_copyzeropage-and-read.patch
* userfaultfd-buildsystem-activation.patch
* userfaultfd-activate-syscall.patch
* userfaultfd-activate-syscall-fix.patch
* userfaultfd-uffdio_copyuffdio_zeropage-uapi.patch
* userfaultfd-mcopy_atomicmfill_zeropage-uffdio_copyuffdio_zeropage-preparation.patch
* userfaultfd-avoid-mmap_sem-read-recursion-in-mcopy_atomic.patch
* userfaultfd-avoid-mmap_sem-read-recursion-in-mcopy_atomic-fix.patch
* userfaultfd-uffdio_copy-and-uffdio_zeropage.patch
* fs-userfaultfdc-work-around-i386-build-error.patch
* page-flags-trivial-cleanup-for-pagetrans-helpers.patch
* page-flags-introduce-page-flags-policies-wrt-compound-pages.patch
* page-flags-define-pg_locked-behavior-on-compound-pages.patch
* page-flags-define-behavior-of-fs-io-related-flags-on-compound-pages.patch
* page-flags-define-behavior-of-lru-related-flags-on-compound-pages.patch
* page-flags-define-behavior-of-lru-related-flags-on-compound-pages-fix.patch
* page-flags-define-behavior-of-lru-related-flags-on-compound-pages-fix-fix.patch
* page-flags-define-behavior-slb-related-flags-on-compound-pages.patch
* page-flags-define-behavior-of-xen-related-flags-on-compound-pages.patch
* page-flags-define-pg_reserved-behavior-on-compound-pages.patch
* page-flags-define-pg_swapbacked-behavior-on-compound-pages.patch
* page-flags-define-pg_swapcache-behavior-on-compound-pages.patch
* page-flags-define-pg_mlocked-behavior-on-compound-pages.patch
* page-flags-define-pg_uncached-behavior-on-compound-pages.patch
* page-flags-define-pg_uptodate-behavior-on-compound-pages.patch
* page-flags-look-on-head-page-if-the-flag-is-encoded-in-page-mapping.patch
* mm-sanitize-page-mapping-for-tail-pages.patch
* include-linux-page-flagsh-rename-macros-to-avoid-collisions.patch
* mm-vmscan-fix-the-page-state-calculation-in-too_many_isolated.patch
* mm-page_isolation-check-pfn-validity-before-access.patch
* mm-fix-invalid-use-of-pfn_valid_within-in-test_pages_in_a_zone.patch
* fs-mpagec-forgotten-write_sync-in-case-of-data-integrity-write.patch
* x86-add-pmd_-for-thp.patch
* x86-add-pmd_-for-thp-fix.patch
* sparc-add-pmd_-for-thp.patch
* sparc-add-pmd_-for-thp-fix.patch
* powerpc-add-pmd_-for-thp.patch
* arm-add-pmd_mkclean-for-thp.patch
* arm64-add-pmd_-for-thp.patch
* mm-support-madvisemadv_free.patch
* mm-support-madvisemadv_free-fix.patch
* mm-support-madvisemadv_free-fix-2.patch
* mm-dont-split-thp-page-when-syscall-is-called.patch
* mm-dont-split-thp-page-when-syscall-is-called-fix.patch
* mm-dont-split-thp-page-when-syscall-is-called-fix-2.patch
* mm-dont-split-thp-page-when-syscall-is-called-fix-3.patch
* mm-free-swp_entry-in-madvise_free.patch
* mm-move-lazy-free-pages-to-inactive-list.patch
* mm-move-lazy-free-pages-to-inactive-list-fix.patch
* mm-move-lazy-free-pages-to-inactive-list-fix-fix.patch
* mm-move-lazy-free-pages-to-inactive-list-fix-fix-fix.patch
* lib-vsprintf-add-%pt-format-specifier.patch
* mm-utilc-add-kstrimdup.patch
* lib-add-crc64-ecma-module.patch
* fat-add-fat_fallocate-operation.patch
* fat-skip-cluster-allocation-on-fallocated-region.patch
* fat-permit-to-return-phy-block-number-by-fibmap-in-fallocated-region.patch
* documentation-filesystems-vfattxt-update-the-limitation-for-fat-fallocate.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* w1-masters-omap_hdq-add-support-for-1-wire-mode.patch
* ipc-msgc-msgsnd-use-freezable-blocking-call.patch
* msgrcv-use-freezable-blocking-call.patch
  linux-next.patch
* drivers-gpu-drm-i915-intel_spritec-fix-build.patch
* drivers-gpu-drm-i915-intel_tvc-fix-build.patch
* net-netfilter-ipset-work-around-gcc-444-initializer-bug.patch
* fs-seq_file-convert-int-seq_vprint-seq_printf-etc-returns-to-void.patch
* w1-call-put_device-if-device_register-fails.patch
  mm-add-strictlimit-knob-v2.patch
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
