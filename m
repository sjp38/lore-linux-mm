Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id C8BFC6B0254
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 20:05:19 -0500 (EST)
Received: by wmww144 with SMTP id w144so45301837wmw.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 17:05:19 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w9si14968121wjf.245.2015.12.03.17.05.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Dec 2015 17:05:18 -0800 (PST)
Date: Thu, 03 Dec 2015 17:05:15 -0800
From: akpm@linux-foundation.org
Subject: mmotm 2015-12-03-17-04 uploaded
Message-ID: <5660e6cb.UJdUKBAOdxvcCAmW%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz

The mm-of-the-moment snapshot 2015-12-03-17-04 has been uploaded to

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


This mmotm tree contains the following patches against 4.4-rc3:
(patches marked "*" will be included in linux-next)

  origin.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  drivers-gpu-drm-i915-intel_spritec-fix-build.patch
  drivers-gpu-drm-i915-intel_tvc-fix-build.patch
  arm-mm-do-not-use-virt_to_idmap-for-nommu-systems.patch
* mm-hugetlb-fix-hugepage-memory-leak-caused-by-wrong-reserve-count.patch
* memcg-fix-memoryhigh-target.patch
* mm-fix-swapped-movable-and-reclaimable-in-proc-pagetypeinfo.patch
* mm-vmstat-allow-wq-concurrency-to-discover-memory-reclaim-doesnt-make-any-progress.patch
* maintainers-make-vladimir-co-maintainer-of-the-memory-controller.patch
* maintainers-update-a-file-name-in-drivers-acpi.patch
* osd-fs-__r4w_get_page-rely-on-pageuptodate-for-uptodate.patch
* mm-fix-kerneldoc-on-mem_cgroup_replace_page.patch
* kernel-remove-stop_machine-kconfig-dependency.patch
* mm-hugetlb-call-huge_pte_alloc-only-if-ptep-is-null.patch
* mm-hugetlb-resv-map-memory-leak-for-placeholder-entries.patch
* mm-hugetlb-resv-map-memory-leak-for-placeholder-entries-v2.patch
* tmpfs-fix-shmem_evict_inode-warnings-on-i_blocks.patch
* drivers-memory-prohibit-offlining-of-memory-blocks-with-missing-sections.patch
* oom-kill-init-lead-panic.patch
* fsnotify-use-list_next_entry-in-fsnotify_unmount_inodes.patch
* fsnotify-destroy-marks-with-call_srcu-instead-of-dedicated-thread.patch
* virtio-do-not-drop-__gfp_high-in-alloc_indirect.patch
* fs-ext4-fsyncc-generic_file_fsync-call-based-on-barrier-flag.patch
* ocfs2-optimize-bad-declarations-and-redundant-assignment.patch
* ocfs2-return-non-zero-st_blocks-for-inline-data.patch
* o2hb-increase-unsteady-iterations.patch
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
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
  mm.patch
* mm-slab-use-list_first_entry_or_null.patch
* mm-slab-use-list_for_each_entry-in-cache_flusharray.patch
* revert-kernfs-do-not-account-ino_ida-allocations-to-memcg.patch
* revert-gfp-add-__gfp_noaccount.patch
* memcg-only-account-kmem-allocations-marked-as-__gfp_account.patch
* slab-add-slab_account-flag.patch
* vmalloc-allow-to-account-vmalloc-to-memcg.patch
* account-certain-kmem-allocations-to-memcg.patch
* account-certain-kmem-allocations-to-memcg-checkpatch-fixes.patch
* mm-mlockc-drop-unneeded-initialization-in-munlock_vma_pages_range.patch
* mm-mmapc-remove-redundant-local-variables-for-may_expand_vm.patch
* mm-mmapc-remove-redundant-local-variables-for-may_expand_vm-fix.patch
* mm-change-trace_mm_vmscan_writepage-proto-type.patch
* include-define-__phys_to_pfn-as-phys_pfn.patch
* include-define-__phys_to_pfn-as-phys_pfn-fix.patch
* include-define-__phys_to_pfn-as-phys_pfn-fix-2.patch
* mempolicy-convert-the-shared_policy-lock-to-a-rwlock.patch
* mempolicy-convert-the-shared_policy-lock-to-a-rwlock-fix.patch
* mempolicy-convert-the-shared_policy-lock-to-a-rwlock-fix-2.patch
* mm-page_isolation-return-last-tested-pfn-rather-than-failure-indicator.patch
* mm-page_isolation-add-new-tracepoint-test_pages_isolated.patch
* mm-cma-always-check-which-page-cause-allocation-failure.patch
* mm-cma-always-check-which-page-cause-allocation-failure-v2.patch
* mm-change-mm_vmscan_lru_shrink_inactive-proto-types.patch
* mm-hugetlb-is_file_hugepages-can-be-boolean.patch
* mm-memblock-memblock_is_memory-reserved-can-be-boolean.patch
* mm-lru-remove-unused-is_unevictable_lru-function.patch
* mm-zonelist-enumerate-zonelists-array-index.patch
* mm-zonelist-enumerate-zonelists-array-index-checkpatch-fixes.patch
* mm-zonelist-enumerate-zonelists-array-index-fix.patch
* mm-zonelist-enumerate-zonelists-array-index-fix-fix.patch
* mm-zonelist-enumerate-zonelists-array-index-fix-fix-fix.patch
* mm-get-rid-of-__alloc_pages_high_priority.patch
* mm-get-rid-of-__alloc_pages_high_priority-checkpatch-fixes.patch
* mm-do-not-loop-over-alloc_no_watermarks-without-triggering-reclaim.patch
* mm-vmalloc-use-list_nextfirst_entry.patch
* mm-mmzone-memmap_valid_within-can-be-boolean.patch
* mm-documentation-clarify-proc-pid-status-vmswap-limitations-for-shmem.patch
* mm-proc-account-for-shmem-swap-in-proc-pid-smaps.patch
* mm-proc-reduce-cost-of-proc-pid-smaps-for-shmem-mappings.patch
* mm-proc-reduce-cost-of-proc-pid-smaps-for-unpopulated-shmem-mappings.patch
* mm-shmem-add-internal-shmem-resident-memory-accounting.patch
* mm-procfs-breakdown-rss-for-anon-shmem-and-file-in-proc-pid-status.patch
* mm-thp-use-list_first_entry_or_null.patch
* tree-wide-use-kvfree-than-conditional-kfree-vfree.patch
* mm-vmalloc-remove-vm_vpages.patch
* vmscan-do-not-force-scan-file-lru-if-its-absolute-size-is-small.patch
* vmscan-do-not-force-scan-file-lru-if-its-absolute-size-is-small-v2.patch
* memcg-do-not-allow-to-disable-tcp-accounting-after-limit-is-set.patch
* fs-block_devc-bdev_write_page-use-blk_queue_enter-gfp_noio.patch
* mm-vmscan-consider-isolated-pages-in-zone_reclaimable_pages.patch
* mm-mmapc-remove-incorrect-map_fixed-flag-comparison-from-mmap_region.patch
* mm-mmap-add-new-proc-tunable-for-mmap_base-aslr.patch
* mm-mmap-add-new-proc-tunable-for-mmap_base-aslr-v4.patch
* mm-mmap-add-new-proc-tunable-for-mmap_base-aslr-v5.patch
* mm-mmap-add-new-proc-tunable-for-mmap_base-aslr-v5-fix.patch
* arm-mm-support-arch_mmap_rnd_bits.patch
* arm-mm-support-arch_mmap_rnd_bits-fix.patch
* arm-mm-support-arch_mmap_rnd_bits-v5.patch
* arm64-mm-support-arch_mmap_rnd_bits.patch
* arm64-mm-support-arch_mmap_rnd_bits-v4.patch
* arm64-mm-support-arch_mmap_rnd_bits-v5.patch
* x86-mm-support-arch_mmap_rnd_bits.patch
* x86-mm-support-arch_mmap_rnd_bits-v5.patch
* mm-compaction-improve-comment-for-compact_memory-tunable-knob-handler.patch
* mm-allow-gfp_iofs-for-page_cache_read-page-cache-allocation.patch
* mm-page_alloc-generalize-the-dirty-balance-reserve.patch
* proc-meminfo-estimate-available-memory-more-conservatively.patch
* drivers-memory-clean-up-section-counting.patch
* drivers-memory-rename-remove_memory_block-to-remove_memory_section.patch
* mm-page_alloc-remove-unnecessary-parameter-from-__rmqueue.patch
* mm-page_allocc-use-list_firstlast_entry-instead-of-list_entry.patch
* mm-page_allocc-use-list_for_each_entry-in-mark_free_pages.patch
* mm-oom-give-__gfp_nofail-allocations-access-to-memory-reserves.patch
* mm-add-tracepoint-for-scanning-pages.patch
* mm-add-tracepoint-for-scanning-pages-fix.patch
* mm-make-optimistic-check-for-swapin-readahead.patch
* mm-make-optimistic-check-for-swapin-readahead-fix.patch
* mm-make-optimistic-check-for-swapin-readahead-fix-2.patch
* mm-fix-kernel-crash-in-khugepaged-thread.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-2.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-3.patch
* zram-zcomp-use-gfp_noio-to-allocate-streams.patch
* zram-try-vmalloc-after-kmalloc.patch
* zram-pass-gfp-from-zcomp-frontend-to-backend.patch
* zram-zcomp-do-not-zero-out-zcomp-private-pages.patch
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
* page-flags-drop-__testclearpage-helpers.patch
* mm-proc-adjust-pss-calculation.patch
* rmap-add-argument-to-charge-compound-page.patch
* rmap-add-argument-to-charge-compound-page-fix.patch
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
* thp-reintroduce-split_huge_page-fix-4.patch
* migrate_pages-try-to-split-pages-on-qeueuing.patch
* thp-introduce-deferred_split_huge_page.patch
* thp-introduce-deferred_split_huge_page-fix.patch
* mm-re-enable-thp.patch
* thp-update-documentation.patch
* thp-allow-mlocked-thp-again.patch
* mm-prepare-page_referenced-and-page_idle-to-new-thp-refcounting.patch
* mm-prepare-page_referenced-and-page_idle-to-new-thp-refcounting-fix.patch
* mm-prepare-page_referenced-and-page_idle-to-new-thp-refcounting-checkpatch-fixes.patch
* mm-prepare-page_referenced-and-page_idle-to-new-thp-refcounting-fix-fix.patch
* mm-prepare-page_referenced-and-page_idle-to-new-thp-refcounting-fix-fix-fix.patch
* mm-add-page_check_address_transhuge-helper.patch
* mm-add-page_check_address_transhuge-helper-fix.patch
* mm-add-page_check_address_transhuge-helper-fix-fix.patch
* mm-debug-fix-wrongly-filtered-flags-in-dump_vma.patch
* mm-debug-fix-wrongly-filtered-flags-in-dump_vma-fix.patch
* mm-page_owner-print-symbolic-migratetype-of-both-page-and-pageblock.patch
* mm-page_owner-convert-page_owner_inited-to-static-key.patch
* mm-page_owner-copy-page-owner-info-during-migration.patch
* mm-page_owner-track-and-print-last-migrate-reason.patch
* mm-page_owner-track-and-print-last-migrate-reason-fix.patch
* mm-debug-introduce-dump_gfpflag_names-for-symbolic-printing-of-gfp_flags.patch
* mm-page_owner-dump-page-owner-info-from-dump_page.patch
* mm-page_owner-dump-page-owner-info-from-dump_page-fix.patch
* mm-page_alloc-print-symbolic-gfp_flags-on-allocation-failure.patch
* mm-oom-print-symbolic-gfp_flags-in-oom-warning.patch
* mm-increase-swap_cluster_max-to-batch-tlb-flushes.patch
* mm-increase-swap_cluster_max-to-batch-tlb-flushes-fix.patch
* mm-increase-swap_cluster_max-to-batch-tlb-flushes-fix-fix.patch
* mm-support-madvisemadv_free.patch
* mm-support-madvisemadv_free-fix.patch
* mm-define-madv_free-for-some-arches.patch
* arch-uapi-asm-mmanh-let-madv_free-have-same-value-for-all-architectures.patch
* mm-free-swp_entry-in-madvise_free.patch
* mm-move-lazily-freed-pages-to-inactive-list.patch
* mm-mark-stable-page-dirty-in-ksm.patch
* x86-add-pmd_-for-thp.patch
* sparc-add-pmd_-for-thp.patch
* powerpc-add-pmd_-for-thp.patch
* arm-add-pmd_mkclean-for-thp.patch
* arm64-add-pmd_mkclean-for-thp.patch
* mm-dont-split-thp-page-when-syscall-is-called.patch
* use-poison_pointer_delta-for-poison-pointers.patch
* include-kernelh-change-abs-macro-so-it-uses-consistent-return-type.patch
* fs-statc-drop-the-last-new_valid_dev-check.patch
* include-linux-kdev_th-remove-new_valid_dev.patch
* kconfig-remove-have_latencytop_support.patch
* errh-add-missing-unlikely-to-is_err_or_null.patch
* uselib-default-depending-if-libc5-was-used.patch
* asm-sections-add-helpers-to-check-for-section-data.patch
* printk-only-unregister-boot-consoles-when-necessary.patch
* printk-do-cond_resched-between-lines-while-outputting-to-consoles.patch
* lib-vsprintfc-pull-out-padding-code-from-dentry_name.patch
* lib-vsprintfc-move-string-below-widen_string.patch
* lib-vsprintfc-eliminate-potential-race-in-string.patch
* lib-vsprintfc-expand-field_width-to-24-bits.patch
* lib-vsprintfc-expand-field_width-to-24-bits-fix.patch
* lib-vsprintfc-help-gcc-make-number-smaller.patch
* lib-vsprintfc-warn-about-too-large-precisions-and-field-widths.patch
* lib-kasprintfc-add-sanity-check-to-kvasprintf.patch
* lib-test_printfc-dont-bug.patch
* lib-test_printfc-check-for-out-of-bound-writes.patch
* lib-test_printfc-test-precision-quirks.patch
* lib-test_printfc-add-a-few-number-tests.patch
* lib-test_printfc-account-for-kvasprintf-tests.patch
* lib-test_printfc-add-test-for-large-bitmaps.patch
* string_helpers-fix-precision-loss-for-some-inputs.patch
* test_hexdump-rename-to-test_hexdump.patch
* test_hexdump-introduce-test_hexdump_prepare_test-helper.patch
* test_hexdump-go-through-all-possible-lengths-of-buffer.patch
* test_hexdump-replace-magic-numbers-by-their-meaning.patch
* test_hexdump-check-all-bytes-in-real-buffer.patch
* test_hexdump-test-all-possible-group-sizes-for-overflow.patch
* test_hexdump-print-statistics-at-the-end.patch
* frv-io-accept-const-void-pointers-for-readbwl.patch
* lib-iomap_copy-add-__ioread32_copy.patch
* soc-qcom-smd-use-__ioread32_copy-instead-of-open-coding-it.patch
* firmware-bcm47xx_nvram-use-__ioread32_copy-instead-of-open-coding.patch
* mm-utilc-add-kstrimdup.patch
* lib-add-crc64-ecma-module.patch
* checkpatch-warn-when-casting-constants-to-c90-int-or-longer-types.patch
* checkpatch-improve-macros-with-flow-control-test.patch
* checkpatch-fix-a-number-of-complex_macro-false-positives.patch
* init-mainc-obsolete_checksetup-can-be-boolean.patch
* init-do_mounts-initrd_load-can-be-boolean.patch
* fat-allow-time_offset-to-be-upto-24-hours.patch
* fat-add-simple-validation-for-directory-inode.patch
* fat-add-fat_fallocate-operation.patch
* fat-skip-cluster-allocation-on-fallocated-region.patch
* fat-permit-to-return-phy-block-number-by-fibmap-in-fallocated-region.patch
* documentation-filesystems-vfattxt-update-the-limitation-for-fat-fallocate.patch
* ptrace-make-wait_on_bitjobctl_trapping_bit-in-ptrace_attach-killable.patch
* ptrace-task_stopped_codeptrace-=-true-cant-see-task_stopped-task.patch
* ptrace-task_stopped_codeptrace-=-true-cant-see-task_stopped-task-fix.patch
* powerpc-fadump-rename-cpu_online_mask-member-of-struct-fadump_crash_info_header.patch
* kernel-cpuc-change-type-of-cpu_possible_bits-and-friends.patch
* kernel-cpuc-export-__cpu__mask.patch
* drivers-base-cpuc-use-__cpu__mask-directly.patch
* kernel-cpuc-eliminate-cpu__mask.patch
* kernel-cpuc-make-set_cpu_-static-inlines.patch
* kexec-set-kexec_type_crash-before-sanity_check_segment_list.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* sysctl-enable-strict-writes.patch
* lz4-fix-wrong-compress-buffer-size-for-64-bits.patch
* ipc-shm-is_file_shm_hugepages-can-be-boolean.patch
* ipc-msgc-msgsnd-use-freezable-blocking-call.patch
* msgrcv-use-freezable-blocking-call.patch
  linux-next.patch
  linux-next-git-rejects.patch
* fs-adfs-adfsh-tidy-up-comments.patch
* iio-core-introduce-iio-configfs-support.patch
* iio-core-introduce-iio-software-triggers.patch
* iio-core-introduce-iio-software-triggers-fix.patch
* iio-trigger-introduce-iio-hrtimer-based-trigger.patch
* iio-documentation-add-iio-configfs-documentation.patch
* dma-mapping-make-the-generic-coherent-dma-mmap-implementation-optional.patch
* arc-convert-to-dma_map_ops.patch
* arc-convert-to-dma_map_ops-fix.patch
* avr32-convert-to-dma_map_ops.patch
* blackfin-convert-to-dma_map_ops.patch
* c6x-convert-to-dma_map_ops.patch
* c6x-convert-to-dma_map_ops-fix.patch
* c6x-convert-to-dma_map_ops-fix-2.patch
* cris-convert-to-dma_map_ops.patch
* nios2-convert-to-dma_map_ops.patch
* nios2-convert-to-dma_map_ops-fix.patch
* frv-convert-to-dma_map_ops.patch
* parisc-convert-to-dma_map_ops.patch
* mn10300-convert-to-dma_map_ops.patch
* m68k-convert-to-dma_map_ops.patch
* metag-convert-to-dma_map_ops.patch
* sparc-use-generic-dma_set_mask.patch
* tile-uninline-dma_set_mask.patch
* dma-mapping-always-provide-the-dma_map_ops-based-implementation.patch
* dma-mapping-always-provide-the-dma_map_ops-based-implementation-fix.patch
* dma-mapping-remove-asm-generic-dma-coherenth.patch
* dma-mapping-use-offset_in_page-macro.patch
* memstick-use-sector_div-instead-of-do_div.patch
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
