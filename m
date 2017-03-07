Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 90BE96B038B
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 19:53:08 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id b2so226034765pgc.6
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 16:53:08 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e5si20595968pgg.25.2017.03.06.16.53.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 16:53:07 -0800 (PST)
Date: Mon, 06 Mar 2017 16:53:06 -0800
From: akpm@linux-foundation.org
Subject: mmotm 2017-03-06-16-52 uploaded
Message-ID: <58be0472.psWRZiN5XRSmRqWR%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2017-03-06-16-52 has been uploaded to

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


This mmotm tree contains the following patches against 4.11-rc1:
(patches marked "*" will be included in linux-next)

  i-need-old-gcc.patch
* userfaultfd-shmem-__do_fault-requires-vm_fault_nopage.patch
* scripts-spellingtxt-add-disbled-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-overide-pattern-and-fix-typo-instances.patch
* powerpc-mm-handle-protnone-ptes-on-fork.patch
* power-mm-update-pte_write-and-pte_wrprotect-to-handle-savedwrite.patch
* x86-mm-fix-gup_pte_range-vs-dax-mappings.patch
* x86-mm-unify-exit-paths-in-gup_pte_range.patch
* userfaultfd-non-cooperative-rollback-userfaultfd_exit.patch
* userfaultfd-non-cooperative-rollback-userfaultfd_exit-fix.patch
* userfaultfd-non-cooperative-robustness-check.patch
* userfaultfd-non-cooperative-release-all-ctx-in-dup_userfaultfd_complete.patch
* fs-fix-unsigned-enum-warning-with-gcc-42.patch
* mm-vmstats-add-thp_split_pud-event-for-clarify.patch
* bcache-remove-duplicate-inclusion-of-blkdevh.patch
* mm-cgroup-avoid-panic-when-init-with-low-memory.patch
* userfaultfd-non-cooperative-fix-fork-fctx-new-memleak.patch
* userfaultfd-non-cooperative-userfaultfd_remove-revalidate-vma-in-madv_dontneed.patch
* userfaultfd-selftest-vm-allow-to-build-in-vm-directory.patch
* memblock-fix-memblock_next_valid_pfn.patch
* rmap-fix-null-pointer-dereference-on-thp-munlocking.patch
* thp-fix-another-corner-case-of-munlock-vs-thps.patch
* scatterlist-dont-overflow-length-field.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* dax-add-tracepoints-to-dax_iomap_pte_fault.patch
* dax-add-tracepoints-to-dax_pfn_mkwrite.patch
* dax-add-tracepoints-to-dax_load_hole.patch
* dax-add-tracepoints-to-dax_writeback_mapping_range.patch
* dax-add-tracepoint-to-dax_writeback_one.patch
* dax-add-tracepoint-to-dax_insert_mapping.patch
* ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called.patch
* ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called-fix.patch
* ocfs2-dlm-optimization-of-code-while-free-dead-node-locks.patch
* ocfs2-dlm-optimization-of-code-while-free-dead-node-locks-checkpatch-fixes.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
  mm.patch
* mm-fix-100%-cpu-kswapd-busyloop-on-unreclaimable-nodes.patch
* mm-fix-check-for-reclaimable-pages-in-pf_memalloc-reclaim-throttling.patch
* mm-remove-seemingly-spurious-reclaimability-check-from-laptop_mode-gating.patch
* mm-remove-unnecessary-reclaimability-check-from-numa-balancing-target.patch
* mm-dont-avoid-high-priority-reclaim-on-unreclaimable-nodes.patch
* mm-dont-avoid-high-priority-reclaim-on-memcg-limit-reclaim.patch
* mm-delete-nr_pages_scanned-and-pgdat_reclaimable.patch
* revert-mm-vmscan-account-for-skipped-pages-as-a-partial-scan.patch
* mm-remove-unnecessary-back-off-function-when-retrying-page-reclaim.patch
* writeback-use-setup_deferrable_timer.patch
* mm-delete-unnecessary-ttu_-flags.patch
* mm-dont-assume-anonymous-pages-have-swapbacked-flag.patch
* mm-move-madv_free-pages-into-lru_inactive_file-list.patch
* mm-move-madv_free-pages-into-lru_inactive_file-list-checkpatch-fixes.patch
* mm-reclaim-madv_free-pages.patch
* mm-reclaim-madv_free-pages-fix.patch
* mm-enable-madv_free-for-swapless-system.patch
* proc-show-madv_free-pages-info-in-smaps.patch
* mm-memcontrol-provide-shmem-statistics.patch
* thp-reduce-indentation-level-in-change_huge_pmd.patch
* thp-fix-madv_dontneed-vs-numa-balancing-race.patch
* mm-drop-unused-pmdp_huge_get_and_clear_notify.patch
* thp-fix-madv_dontneed-vs-madv_free-race.patch
* thp-fix-madv_dontneed-vs-madv_free-race-fix.patch
* thp-fix-madv_dontneed-vs-clear-soft-dirty-race.patch
* mm-swap-fix-a-race-in-free_swap_and_cache.patch
* mm-use-is_migrate_highatomic-to-simplify-the-code.patch
* mm-use-is_migrate_highatomic-to-simplify-the-code-fix.patch
* mm-use-is_migrate_isolate_page-to-simplify-the-code.patch
* mm-vmstat-print-non-populated-zones-in-zoneinfo.patch
* mm-vmstat-suppress-pcp-stats-for-unpopulated-zones-in-zoneinfo.patch
* sparc64-ng4-memset-32-bits-overflow.patch
* mm-zeroing-hash-tables-in-allocator.patch
* mm-updated-callers-to-use-hash_zero-flag.patch
* mm-adaptive-hash-table-scaling.patch
* zram-reduce-load-operation-in-page_same_filled.patch
* lockdep-teach-lockdep-about-memalloc_noio_save.patch
* lockdep-allow-to-disable-reclaim-lockup-detection.patch
* xfs-abstract-pf_fstrans-to-pf_memalloc_nofs.patch
* mm-introduce-memalloc_nofs_saverestore-api.patch
* mm-introduce-memalloc_nofs_saverestore-api-fix.patch
* xfs-use-memalloc_nofs_saverestore-instead-of-memalloc_noio.patch
* jbd2-mark-the-transaction-context-with-the-scope-gfp_nofs-context.patch
* jbd2-mark-the-transaction-context-with-the-scope-gfp_nofs-context-fix.patch
* jbd2-make-the-whole-kjournald2-kthread-nofs-safe.patch
* jbd2-make-the-whole-kjournald2-kthread-nofs-safe-checkpatch-fixes.patch
* mm-tighten-up-the-fault-path-a-little.patch
* mm-page_alloc-return-0-in-case-this-node-has-no-page-within-the-zone.patch
* mm-vmscan-do-not-pass-reclaimed-slab-to-vmpressure.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* mm-walk-the-zone-in-pageblock_nr_pages-steps.patch
* kasan-introduce-helper-functions-for-determining-bug-type.patch
* kasan-unify-report-headers.patch
* kasan-change-allocation-and-freeing-stack-traces-headers.patch
* kasan-simplify-address-description-logic.patch
* kasan-change-report-header.patch
* kasan-improve-slab-object-description.patch
* kasan-print-page-description-after-stacks.patch
* kasan-improve-double-free-report-format.patch
* kasan-separate-report-parts-by-empty-lines.patch
* proc-remove-cast-from-memory-allocation.patch
* drivers-virt-use-get_user_pages_unlocked.patch
* revert-lib-test_sortc-make-it-explicitly-non-modular.patch
* lib-add-module-support-to-array-based-sort-tests.patch
* lib-add-module-support-to-linked-list-sorting-tests.patch
* firmware-makefile-force-recompilation-if-makefile-changes.patch
* checkpatch-remove-obsolete-config_experimental-checks.patch
* checkpatch-add-ability-to-find-bad-uses-of-vsprintf-%pfoo-extensions.patch
* checkpatch-add-ability-to-find-bad-uses-of-vsprintf-%pfoo-extensions-fix.patch
* checkpatch-add-ability-to-find-bad-uses-of-vsprintf-%pfoo-extensions-fix-fix.patch
* checkpatch-improve-embedded_function_name-test.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* uapi-fix-linux-sysctlh-userspace-compilation-errors.patch
* taskstats-add-e-u-stime-for-tgid-command.patch
* taskstats-add-e-u-stime-for-tgid-command-fix.patch
* taskstats-add-e-u-stime-for-tgid-command-fix-fix.patch
* scripts-gdb-add-lx-fdtdump-command.patch
* initramfs-provide-a-way-to-ignore-image-provided-by-bootloader.patch
  linux-next.patch
  linux-next-rejects.patch
* treewide-move-set_memory_-functions-away-from-cacheflushh.patch
* treewide-move-set_memory_-functions-away-from-cacheflushh-fix.patch
* arm-use-set_memoryh-header.patch
* arm64-use-set_memoryh-header.patch
* arm64-use-set_memoryh-header-fix.patch
* s390-use-set_memoryh-header.patch
* x86-use-set_memoryh-header.patch
* agp-use-set_memoryh-header.patch
* drm-use-set_memoryh-header.patch
* intel_th-use-set_memoryh-header.patch
* watchdog-hpwdt-use-set_memoryh-header.patch
* bpf-use-set_memoryh-header.patch
* module-use-set_memoryh-header.patch
* pm-hibernate-use-set_memoryh-header.patch
* alsa-hda-use-set_memoryh-header.patch
* treewide-decouple-cacheflushh-and-set_memoryh.patch
* treewide-decouple-cacheflushh-and-set_memoryh-fix.patch
* treewide-decouple-cacheflushh-and-set_memoryh-fix-fix.patch
* treewide-decouple-cacheflushh-and-set_memoryh-fix-fix-fix.patch
* treewide-decouple-cacheflushh-and-set_memoryh-fix-fix-fix-fix.patch
* treewide-decouple-cacheflushh-and-set_memoryh-fix-fix-fix-fix-fix.patch
* treewide-decouple-cacheflushh-and-set_memoryh-fix-fix-fix-fix-fix-fix.patch
* mm-introduce-kvalloc-helpers.patch
* mm-support-__gfp_repeat-in-kvmalloc_node-for-32kb.patch
* rhashtable-simplify-a-strange-allocation-pattern.patch
* ila-simplify-a-strange-allocation-pattern.patch
* xattr-zero-out-memory-copied-to-userspace-in-getxattr.patch
* treewide-use-kvalloc-rather-than-opencoded-variants.patch
* net-use-kvmalloc-with-__gfp_repeat-rather-than-open-coded-variant.patch
* md-use-kvmalloc-rather-than-opencoded-variant.patch
* bcache-use-kvmalloc.patch
* scripts-spellingtxt-add-intialised-pattern-and-fix-typo-instances.patch
  mm-add-strictlimit-knob-v2.patch
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
