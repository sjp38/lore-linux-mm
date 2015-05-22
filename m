Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9539C829CE
	for <linux-mm@kvack.org>; Fri, 22 May 2015 17:48:45 -0400 (EDT)
Received: by paza2 with SMTP id a2so19978189paz.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:48:45 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id uj9si5168247pbc.34.2015.05.22.14.48.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 14:48:44 -0700 (PDT)
Date: Fri, 22 May 2015 14:48:42 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2015-05-22-14-48 uploaded
Message-ID: <555fa43a.O+VvdA70yRRjg8LR%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz

The mm-of-the-moment snapshot 2015-05-22-14-48 has been uploaded to

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


This mmotm tree contains the following patches against 4.1-rc4:
(patches marked "*" will be included in linux-next)

  origin.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
* tracing-mm-dont-trace-kmem_cache_free-on-offline-cpus.patch
* tracing-mm-dont-trace-kmem_cache_free-on-offline-cpus-fix.patch
* tracing-mm-dont-trace-mm_page_free-on-offline-cpus.patch
* tracing-mm-dont-trace-mm_page_free-on-offline-cpus-fix.patch
* tracing-mm-dont-trace-mm_page_pcpu_drain-on-offline-cpus.patch
* tracing-mm-dont-trace-mm_page_pcpu_drain-on-offline-cpus-fix.patch
* fs-binfmt_elfc-load_elf_binary-return-einval-on-zero-length-mappings.patch
* maintainers-update-capabilities-pattern.patch
* fs-omfs-add-null-terminator-in-the-end-up-the-token-list.patch
* omfs-set-error-return-when-d_make_root-fails.patch
* omfs-fix-sign-confusion-for-bitmap-loop-counter.patch
* omfs-fix-potential-integer-overflow-in-allocator.patch
* scripts-gdb-fix-lx-lsmod-refcnt.patch
* ocfs2-fix-bug-in-ocfs2_downconvert_thread_do_work.patch
* ocfs2-fix-bug-in-ocfs2_downconvert_thread_do_work-v2.patch
  metag-use-for_each_sg.patch
* powerpc-use-for_each_sg.patch
* mips-use-for_each_sg.patch
* ntfs-use-kvfree-in-ntfs_free.patch
* configfs-unexport-make-static-config_item_init.patch
* fs-ext4-fsyncc-generic_file_fsync-call-based-on-barrier-flag.patch
* jbd2-revert-must-not-fail-allocation-loops-back-to-gfp_nofail.patch
* ocfs2-reduce-object-size-of-mlog-uses.patch
* ocfs2-reduce-object-size-of-mlog-uses-fix.patch
* ocfs2-remove-__mlog_cpu_guess.patch
* ocfs2-remove-__mlog_cpu_guess-fix.patch
* ocfs2-fix-a-tiny-race-when-truncate-dio-orohaned-entry.patch
* ocfs2-use-retval-instead-of-status-for-checking-error.patch
* ocfs2-dlm-cleanup-unused-function-__dlm_wait_on_lockres_flags_set.patch
* ocfs2-return-error-while-ocfs2_figure_merge_contig_type-failing.patch
* ocfs2-remove-bug_onempty_extent-in-__ocfs2_rotate_tree_left.patch
* ocfs2-do-not-bug-if-jbd2_journal_dirty_metadata-fails.patch
* ocfs2-do-not-bug-if-jbd2_journal_dirty_metadata-fails-v3.patch
* ocfs2-remove-ocfs2_iocb_sem-lock-type-in-direct-io.patch
* ocfs2-o2net-should-remove-debugfs-in-o2net_init-out-branch.patch
* ocfs2-fix-null-pointer-dereference-in-function-ocfs2_abort_trigger.patch
* ocfs2-fix-null-pointer-dereference-in-function-ocfs2_abort_trigger-fix.patch
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
* ocfs2-use-64bit-variables-to-track-heartbeat-time.patch
* ocfs2-call-ocfs2_journal_access_di-before-ocfs2_journal_dirty-in-ocfs2_write_end_nolock.patch
* ocfs2-avoid-access-invalid-address-when-read-o2dlm-debug-messages.patch
* ocfs2-neaten-do_error-ocfs2_error-and-ocfs2_abort.patch
* parisc-use-for_each_sg.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* sparc-use-for_each_sg.patch
* posix_acl-make-posix_acl_create-safer-and-cleaner.patch
* smpboot-allow-excluding-cpus-from-the-smpboot-threads.patch
* smpboot-allow-excluding-cpus-from-the-smpboot-threads-fix.patch
* watchdog-add-watchdog_cpumask-sysctl-to-assist-nohz.patch
* watchdog-add-watchdog_cpumask-sysctl-to-assist-nohz-fix-2.patch
* watchdog-add-watchdog_cpumask-sysctl-to-assist-nohz-fix-3.patch
* procfs-treat-parked-tasks-as-sleeping-for-task-state.patch
* xtensa-use-for_each_sg.patch
  mm.patch
* mm-slab_common-support-the-slub_debug-boot-option-on-specific-object-size.patch
* mm-slab_common-support-the-slub_debug-boot-option-on-specific-object-size-fix.patch
* slab-correct-size_index-table-before-replacing-the-bootstrap-kmem_cache_node.patch
* linux-slabh-fix-three-off-by-one-typos-in-comment.patch
* slab-infrastructure-for-bulk-object-allocation-and-freeing-v3.patch
* slub-bulk-alloc-extract-objects-from-the-per-cpu-slab.patch
* slub-bulk-allocation-from-per-cpu-partial-pages.patch
* slub-bulk-allocation-from-per-cpu-partial-pages-fix.patch
* mm-hwpoison-add-comment-describing-when-to-add-new-cases.patch
* mm-hwpoison-remove-obsolete-notebook-todo-list.patch
* thp-cleanup-how-khugepaged-enters-freezer.patch
* mm-fix-mprotect-behaviour-on-vm_locked-vmas.patch
* mm-fix-mprotect-behaviour-on-vm_locked-vmas-fix.patch
* mm-hugetlb-reduce-arch-dependent-code-about-huge_pmd_unshare.patch
* mm-new-mm-hook-framework.patch
* mm-new-arch_remap-hook.patch
* powerpc-mm-tracking-vdso-remap.patch
* mm-hugetlb-reduce-arch-dependent-code-about-hugetlb_prefault_arch_hook.patch
* memblock-introduce-a-for_each_reserved_mem_region-iterator.patch
* mm-meminit-move-page-initialization-into-a-separate-function.patch
* mm-meminit-only-set-page-reserved-in-the-memblock-region.patch
* mm-page_alloc-pass-pfn-to-__free_pages_bootmem.patch
* mm-page_alloc-pass-pfn-to-__free_pages_bootmem-fix.patch
* mm-meminit-make-__early_pfn_to_nid-smp-safe-and-introduce-meminit_pfn_in_nid.patch
* mm-meminit-inline-some-helper-functions.patch
* mm-meminit-inline-some-helper-functions-fix.patch
* mm-meminit-inline-some-helper-functions-fix2.patch
* mm-meminit-initialise-a-subset-of-struct-pages-if-config_deferred_struct_page_init-is-set.patch
* mm-meminit-initialise-a-subset-of-struct-pages-if-config_deferred_struct_page_init-is-set-fix.patch
* mm-meminit-initialise-remaining-struct-pages-in-parallel-with-kswapd.patch
* mm-meminit-minimise-number-of-pfn-page-lookups-during-initialisation.patch
* x86-mm-enable-deferred-struct-page-initialisation-on-x86-64.patch
* mm-meminit-free-pages-in-large-chunks-where-possible.patch
* mm-meminit-reduce-number-of-times-pageblocks-are-set-during-struct-page-init.patch
* mm-meminit-reduce-number-of-times-pageblocks-are-set-during-struct-page-init-fix.patch
* mm-meminit-remove-mminit_verify_page_links.patch
* mm-meminit-finish-initialisation-of-struct-pages-before-basic-setup.patch
* mm-meminit-finish-initialisation-of-struct-pages-before-basic-setup-fix.patch
* mm-only-define-hashdist-variable-when-needed.patch
* mm-drop-bogus-vm_bug_on_page-assert-in-put_page-codepath.patch
* mm-avoid-tail-page-refcounting-on-non-thp-compound-pages.patch
* mm-page_allocc-cleanup-obsolete-km_user.patch
* mm-vmscan-do-not-throttle-based-on-pfmemalloc-reserves-if-node-has-no-reclaimable-pages.patch
* rename-reclaim_swap-to-reclaim_unmap.patch
* mm-memory-failure-split-thp-earlier-in-memory-error-handling.patch
* mm-memory-failure-split-thp-earlier-in-memory-error-handling-v2.patch
* mm-memory-failure-introduce-get_hwpoison_page-for-consistent-refcount-handling.patch
* mm-memory-failure-introduce-get_hwpoison_page-for-consistent-refcount-handling-v2.patch
* mm-memory-failure-introduce-get_hwpoison_page-for-consistent-refcount-handling-fix.patch
* mm-soft-offline-dont-free-target-page-in-successful-page-migration.patch
* mm-memory-failure-me_huge_page-does-nothing-for-thp.patch
* rmap-fix-theoretical-race-between-do_wp_page-and-shrink_active_list.patch
* rmap-fix-theoretical-race-between-do_wp_page-and-shrink_active_list-fix.patch
* rmap-fix-theoretical-race-between-do_wp_page-and-shrink_active_list-fix-fix.patch
* mm-hugetlb-introduce-minimum-hugepage-order.patch
* mm-memory-hotplug-init-the-zones-size-when-calculate-node-totalpages.patch
* userfaultfd-linux-documentation-vm-userfaultfdtxt.patch
* userfaultfd-linux-documentation-vm-userfaultfdtxt-fix.patch
* userfaultfd-waitqueue-add-nr-wake-parameter-to-__wake_up_locked_key.patch
* userfaultfd-uapi.patch
* userfaultfd-linux-userfaultfd_kh.patch
* userfaultfd-add-vm_userfaultfd_ctx-to-the-vm_area_struct.patch
* userfaultfd-add-vm_uffd_missing-and-vm_uffd_wp.patch
* userfaultfd-call-handle_userfault-for-userfaultfd_missing-faults.patch
* userfaultfd-teach-vma_merge-to-merge-across-vma-vm_userfaultfd_ctx.patch
* userfaultfd-prevent-khugepaged-to-merge-if-userfaultfd-is-armed.patch
* userfaultfd-add-new-syscall-to-provide-memory-externalization.patch
* userfaultfd-add-new-syscall-to-provide-memory-externalization-fix.patch
* userfaultfd-add-new-syscall-to-provide-memory-externalization-fix-fix.patch
* userfaultfd-rename-uffd_apibits-into-features.patch
* userfaultfd-rename-uffd_apibits-into-features-fixup.patch
* userfaultfd-change-the-read-api-to-return-a-uffd_msg.patch
* userfaultfd-change-the-read-api-to-return-a-uffd_msg-fix.patch
* userfaultfd-wake-pending-userfaults.patch
* userfaultfd-optimize-read-and-poll-to-be-o1.patch
* userfaultfd-optimize-read-and-poll-to-be-o1-fix.patch
* userfaultfd-allocate-the-userfaultfd_ctx-cacheline-aligned.patch
* userfaultfd-solve-the-race-between-uffdio_copyzeropage-and-read.patch
* userfaultfd-buildsystem-activation.patch
* userfaultfd-activate-syscall.patch
* userfaultfd-uffdio_copyuffdio_zeropage-uapi.patch
* userfaultfd-mcopy_atomicmfill_zeropage-uffdio_copyuffdio_zeropage-preparation.patch
* userfaultfd-avoid-mmap_sem-read-recursion-in-mcopy_atomic.patch
* userfaultfd-avoid-mmap_sem-read-recursion-in-mcopy_atomic-fix.patch
* userfaultfd-uffdio_copy-and-uffdio_zeropage.patch
* fs-userfaultfdc-work-around-i386-build-error.patch
* mm-oom_kill-remove-unnecessary-locking-in-oom_enable.patch
* mm-oom_kill-clean-up-victim-marking-and-exiting-interfaces.patch
* mm-oom_kill-switch-test-and-clear-of-known-tif_memdie-to-clear.patch
* mm-oom_kill-generalize-oom-progress-waitqueue.patch
* mm-oom_kill-remove-unnecessary-locking-in-exit_oom_victim.patch
* mm-oom_kill-simplify-oom-killer-locking.patch
* mm-page_alloc-inline-should_alloc_retry.patch
* hugetlb-do-not-account-hugetlb-pages-as-nr_file_pages.patch
* hugetlb-do-not-account-hugetlb-pages-as-nr_file_pages-fix.patch
* mm-memcg-try-charging-a-page-before-setting-page-up-to-date.patch
* mm-hugetlb-compute-return-the-number-of-regions-added-by-region_add.patch
* mm-hugetlb-handle-races-in-alloc_huge_page-and-hugetlb_reserve_pages.patch
* mm-hugetlb-handle-races-in-alloc_huge_page-and-hugetlb_reserve_pages-fix.patch
* memory-failure-export-page_type-and-action-result.patch
* memory-failure-change-type-of-action_results-param-3-to-enum.patch
* tracing-add-trace-event-for-memory-failure.patch
* tracing-add-trace-event-for-memory-failure-fix.patch
* mm-thp-split-out-pmd-collpase-flush-into-a-separate-functions.patch
* powerpc-mm-use-generic-version-of-pmdp_clear_flush.patch
* mm-clarify-that-the-function-operates-on-hugepage-pte.patch
* mm-nommu-refactor-debug-and-warning-prints.patch
* page-flags-trivial-cleanup-for-pagetrans-helpers.patch
* page-flags-introduce-page-flags-policies-wrt-compound-pages.patch
* page-flags-define-pg_locked-behavior-on-compound-pages.patch
* page-flags-define-behavior-of-fs-io-related-flags-on-compound-pages.patch
* page-flags-define-behavior-of-lru-related-flags-on-compound-pages.patch
* page-flags-define-behavior-of-lru-related-flags-on-compound-pages-fix.patch
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
* zram-remove-obsolete-zram_debug-option.patch
* zsmalloc-remove-obsolete-zsmalloc_debug.patch
* zram-add-compact-sysfs-entry-to-documentation.patch
* zram-cosmetic-zram_attr_ro-code-formatting-tweak.patch
* zram-use-idr-instead-of-zram_devices-array.patch
* zram-reorganize-code-layout.patch
* zram-remove-max_num_devices-limitation.patch
* zram-report-every-added-and-removed-device.patch
* zram-trivial-correct-flag-operations-comment.patch
* zram-return-zram-device_id-from-zram_add.patch
* zram-close-race-by-open-overriding.patch
* zram-add-dynamic-device-add-remove-functionality.patch
* zram-cosmetic-zram_bvec_write-cleanup.patch
* zram-cut-trailing-newline-in-algorithm-name.patch
* frv-remove-unused-inline-function-is_in_rom.patch
* frv-use-for_each_sg.patch
* avr32-use-for_each_sg.patch
* proc-fix-page_size-limit-of-proc-pid-cmdline.patch
* proc-fix-page_size-limit-of-proc-pid-cmdline-fix.patch
* compiler-gcch-neatening.patch
* compiler-gcc-integrate-the-various-compiler-gcch-files.patch
* compiler-intel-fix-wrong-compiler-barrier-macro.patch
* pratyush-anand-has-moved.patch
* mohit-kumar-has-moved.patch
* clone-support-passing-tls-argument-via-c-rather-than-pt_regs-magic.patch
* clone-support-passing-tls-argument-via-c-rather-than-pt_regs-magic-fix.patch
* clone-support-passing-tls-argument-via-c-rather-than-pt_regs-magic-fix-2.patch
* x86-opt-into-have_copy_thread_tls-for-both-32-bit-and-64-bit.patch
* printk-guard-the-amount-written-per-line-by-devkmsg_read.patch
* printk-factor-out-message-formatting-from-devkmsg_read.patch
* printk-implement-support-for-extended-console-drivers.patch
* netconsole-remove-unnecessary-netconsole_target_get-out-from-write_msg.patch
* netconsole-make-netconsole_target-enabled-a-bool.patch
* netconsole-make-all-dynamic-netconsoles-share-a-mutex.patch
* netconsole-implement-extended-console-support.patch
* lib-vsprintf-add-%pt-format-specifier.patch
* get_maintainerpl-add-get_maintainerignore-file-capability.patch
* maintainers-remove-website-for-paride.patch
* maintainers-update-sound-soc-intel-patterns.patch
* maintainers-remove-section-broadcom-bcm33xx-mips-architecture.patch
* maintainers-update-brcm-dts-pattern.patch
* maintainers-update-brcm-gpio-filename-pattern.patch
* maintainers-remove-unused-nbdh-pattern.patch
* maintainers-move-jens-osterkamp-to-credits.patch
* maintainers-bcache-kent-overstreet-has-changed-email-address.patch
* __bitmap_parselist-fix-bug-in-empty-string-handling.patch
* hexdump-make-test-data-really-const.patch
* lib-sort-add-64-bit-swap-function.patch
* lib-sort-add-64-bit-swap-function-v2.patch
* lib-sort-add-64-bit-swap-function-v2-fix.patch
* bitmap-remove-explicit-newline-handling-using-scnprintf-format-string.patch
* bitmap-remove-explicit-newline-handling-using-scnprintf-format-string-fix.patch
* radix-tree-replace-preallocated-node-array-with-linked-list.patch
* radix-tree-replace-preallocated-node-array-with-linked-list-fix.patch
* mm-utilc-add-kstrimdup.patch
* lib-add-crc64-ecma-module.patch
* checkpatch-check-for-uncommented-waitqueue_active.patch
* checkpatch-add-strict-warning-for-c99-fixed-size-typedefs-intsize_t.patch
* checkpatch-make-types-found-in-a-source-file-patch-local.patch
* efs-remove-unneeded-cast.patch
* kasan-remove-duplicate-definition-of-the-macro-kasan_free_page.patch
* drivers-rtc-rtc-ds1307c-enable-the-mcp794xx-alarm-after-programming-time.patch
* rtc-omap-add-external-32k-clock-feature.patch
* rtc-omap-add-external-32k-clock-feature-fix.patch
* drivers-rtc-interfacec-check-the-error-after-__rtc_read_time.patch
* rtc-restore-alarm-after-resume.patch
* minix-no-need-to-cast-alloction-return-value-in-minix.patch
* fs-befs-btreec-remove-unneeded-initializations.patch
* reiserfs-avoid-pointless-casts-in-alloc-codes.patch
* fat-add-fat_fallocate-operation.patch
* fat-skip-cluster-allocation-on-fallocated-region.patch
* fat-permit-to-return-phy-block-number-by-fibmap-in-fallocated-region.patch
* documentation-filesystems-vfattxt-update-the-limitation-for-fat-fallocate.patch
* coredump-use-from_kuid-kgid-when-formatting-corename.patch
* coredump-add-__printf-attribute-to-cn_printf-functions.patch
* exitstats-obey-this-comment.patch
* prepend-elfcorehdr-instead-of-appending-it-to-the-crash-kernel-command-line.patch
* kernel-panic-call-the-2nd-crash_kexec-only-if-crash_kexec_post_notifiers-is-enabled.patch
* kernel-panic-kexec-fix-crash_kexec_post_notifiers-option-issue-in-oops-path.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* adfs-remove-unneeded-cast.patch
* fs-affs-inodec-remove-unneeded-initialization.patch
* fs-affs-amigaffsc-remove-unneeded-initialization.patch
* fs-affs-symlinkc-remove-unneeded-err-variable.patch
* memstick-remove-deprecated-use-of-pci-api.patch
* scripts-gdb-add-command-to-check-list-consistency.patch
* scripts-gdb-also-allow-list_head-pointer-as-lx-list-check-paramter.patch
* scripts-gdb-enable-completion-for-lx-list-check-parameter.patch
* scripts-gdb-fix-typo-in-exception-name.patch
* scripts-gdb-fix-pep8-compliance.patch
* scripts-gdb-add-ps-command.patch
* scripts-gdb-remove-useless-global-instruction.patch
* devpts-if-initialization-failed-dont-crash-when-opening-dev-ptmx.patch
* devpts-if-initialization-failed-dont-crash-when-opening-dev-ptmx-fix.patch
* arc-use-for_each_sg.patch
* ipc-msgc-msgsnd-use-freezable-blocking-call.patch
* ipc-utilc-use-kvfree-in-ipc_rcu_free.patch
* msgrcv-use-freezable-blocking-call.patch
* lib-scatterlist-fix-kerneldoc-for-sg_pcopy_tofrom_buffer.patch
* lib-scatterlist-mark-input-buffer-parameters-as-const.patch
* scsi-resolve-sg-buffer-const-ness-issue.patch
* scsi-resolve-sg-buffer-const-ness-issue-fix.patch
  linux-next.patch
  linux-next-rejects.patch
  linux-next-git-rejects.patch
* arch-x86-kvm-mmuc-work-around-gcc-444-bug.patch
* drivers-gpu-drm-i915-intel_spritec-fix-build.patch
* drivers-gpu-drm-i915-intel_tvc-fix-build.patch
* unicore32-remove-unnecessary-kern_err-in-fpu-ucf64c.patch
* printk-improve-the-description-of-dev-kmsg-line-format.patch
* kernel-relayc-use-kvfree-in-relay_free_page_array.patch
* cxgb3-use-kvfree-in-cxgb_free_mem.patch
* cxgb4-use-kvfree-in-t4_free_mem.patch
* drm-use-kvfree-in-drm_free_large.patch
* drm-nouveau-gem-use-kvfree-in-u_free.patch
* ib-ehca-use-kvfree-in-ipz_queue_cdtor.patch
* target-use-kvfree-in-session-alloc-and-free.patch
* libcxgbi-use-kvfree-in-cxgbi_free_big_mem.patch
* bcache-use-kvfree-in-various-places.patch
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
  drivers-gpu-drm-i915-i915_gem_gttc-hack-around-build-error-on-i386.patch
  drivers-gpu-drm-i915-i915_gem_gttc-hack-around-build-error-on-i386.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
