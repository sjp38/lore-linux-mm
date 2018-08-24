Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 395DB6B2CC1
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 20:27:35 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id d22-v6so4570784pfn.3
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 17:27:35 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p21-v6si5635024pgd.56.2018.08.23.17.27.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 17:27:33 -0700 (PDT)
Date: Thu, 23 Aug 2018 17:27:31 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2018-08-23-17-26 uploaded
Message-ID: <20180824002731.XMNCl%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org

The mm-of-the-moment snapshot 2018-08-23-17-26 has been uploaded to

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


This mmotm tree contains the following patches against 4.18:
(patches marked "*" will be included in linux-next)

  origin.patch
* hfsplus-fix-null-dereference-in-hfsplus_lookup.patch
* hfsplus-prevent-crash-on-exit-from-failed-search.patch
* hfs-prevent-crash-on-exit-from-failed-search.patch
* namei-allow-restricted-o_creat-of-fifos-and-regular-files.patch
* mm-fix-race-on-soft-offlining-free-huge-pages.patch
* mm-soft-offline-close-the-race-against-page-allocation.patch
* hwtracing-intel_th-change-return-type-to-vm_fault_t.patch
* fs-afs-adding-new-return-type-vm_fault_t.patch
* treewide-correct-differenciate-and-instanciate-typos.patch
* vmcore-hide-vmcoredd_mmap_dumps-for-nommu-builds.patch
* mm-util-make-strndup_user-description-a-kernel-doc-comment.patch
* mm-util-add-kernel-doc-for-kvfree.patch
* docs-core-api-kill-trailing-whitespace-in-kernel-apirst.patch
* docs-core-api-move-strmemdup-to-string-manipulation.patch
* docs-core-api-split-memory-management-api-to-a-separate-file.patch
* docs-mm-make-gfp-flags-descriptions-usable-as-kernel-doc.patch
* docs-core-api-mm-api-add-section-about-gfp-flags.patch
* gpu-drm-gma500-change-return-type-to-vm_fault_t.patch
* treewide-convert-iso_8859-1-text-comments-to-utf-8.patch
* s390-ebcdic-convert-comments-to-utf-8.patch
* lib-fonts-convert-comments-to-utf-8.patch
* mm-change-return-type-int-to-vm_fault_t-for-fault-handlers.patch
* mm-memcontrol-print-proper-oom-header-when-no-eligible-victim-left.patch
* mm-migration-fix-migration-of-huge-pmd-shared-pages.patch
* hugetlb-take-pmd-sharing-into-account-when-flushing-tlb-caches.patch
* mm-oom-fix-missing-tlb_finish_mmu-in-__oom_reap_task_mm.patch
* mm-respect-arch_dup_mmap-return-value.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* ocfs2-get-rid-of-ocfs2_is_o2cb_active-function.patch
* ocfs2-without-quota-support-try-to-avoid-calling-quota-recovery.patch
* ocfs2-dont-use-iocb-when-eiocbqueued-returns.patch
* ocfs2-fix-a-misuse-a-of-brelse-after-failing-ocfs2_check_dir_entry.patch
* ocfs2-dont-put-and-assigning-null-to-bh-allocated-outside.patch
* ocfs2-dlmglue-clean-up-timestamp-handling.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
  mm.patch
* arm-arm64-introduce-config_have_memblock_pfn_valid.patch
* mm-page_alloc-remain-memblock_next_valid_pfn-on-arm-arm64.patch
* mm-page_alloc-reduce-unnecessary-binary-search-in-memblock_next_valid_pfn.patch
* mm-page_alloc-reduce-unnecessary-binary-search-in-memblock_next_valid_pfn-fix.patch
* mm-page_alloc-reduce-unnecessary-binary-search-in-memblock_next_valid_pfn-fix-fix.patch
* mm-memblock-introduce-memblock_search_pfn_regions.patch
* mm-memblock-introduce-memblock_search_pfn_regions-fix.patch
* mm-memblock-introduce-pfn_valid_region.patch
* mm-page_alloc-reduce-unnecessary-binary-search-in-early_pfn_valid.patch
* z3fold-fix-wrong-handling-of-headless-pages.patch
* mm-adjust-max-read-count-in-generic_file_buffered_read.patch
* mm-make-memmap_init-a-proper-function.patch
* mm-calculate-deferred-pages-after-skipping-mirrored-memory.patch
* mm-calculate-deferred-pages-after-skipping-mirrored-memory-v2.patch
* mm-calculate-deferred-pages-after-skipping-mirrored-memory-fix.patch
* mm-move-mirrored-memory-specific-code-outside-of-memmap_init_zone.patch
* mm-move-mirrored-memory-specific-code-outside-of-memmap_init_zone-v2.patch
* mm-swap-fix-race-between-swapoff-and-some-swap-operations.patch
* mm-swap-fix-race-between-swapoff-and-some-swap-operations-v6.patch
* mm-fix-race-between-swapoff-and-mincore.patch
* list_lru-prefetch-neighboring-list-entries-before-acquiring-lock.patch
* list_lru-prefetch-neighboring-list-entries-before-acquiring-lock-fix.patch
* mm-add-strictlimit-knob-v2.patch
* mm-dont-expose-page-to-fast-gup-before-its-ready.patch
* mm-page_owner-align-with-pageblock_nr_pages.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* info-task-hung-in-generic_file_write_iter.patch
* bfs-add-sanity-check-at-bfs_fill_super.patch
  linux-next.patch
  linux-next-git-rejects.patch
* vfs-replace-current_kernel_time64-with-ktime-equivalent.patch
* fix-read-buffer-overflow-in-delta-ipc.patch
  make-sure-nobodys-leaking-resources.patch
  releasing-resources-with-children.patch
  mutex-subsystem-synchro-test-module.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  slab-leaks3-default-y.patch
  workaround-for-a-pci-restoring-bug.patch
