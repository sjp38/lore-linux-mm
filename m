Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 5AE396B0033
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 19:52:29 -0400 (EDT)
Received: by mail-vb0-f73.google.com with SMTP id e12so579534vbg.2
        for <linux-mm@kvack.org>; Tue, 27 Aug 2013 16:52:28 -0700 (PDT)
Subject: mmotm 2013-08-27-16-51 uploaded
From: akpm@linux-foundation.org
Date: Tue, 27 Aug 2013 16:52:27 -0700
Message-Id: <20130827235227.99DB95A41D6@corp2gmr1-2.hot.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

The mm-of-the-moment snapshot 2013-08-27-16-51 has been uploaded to

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


This mmotm tree contains the following patches against 3.11-rc7:
(patches marked "*" will be included in linux-next)

  origin.patch
* revert-include-linux-smph-on_each_cpu-switch-back-to-a-macro.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  i-need-old-gcc.patch
* timer_list-correct-the-iterator-for-timer_list.patch
* pidns-fix-vfork-after-unshareclone_newpid.patch
* pidns-kill-the-unnecessary-clone_newpid-in-copy_process.patch
* fork-unify-and-tighten-up-clone_newuser-clone_newpid-checks.patch
* omnikey-cardman-4000-pull-in-ioctlh-in-user-header.patch
* ipc-bugfix-for-msgrcv-with-msgtyp-0.patch
* drivers-base-memoryc-fix-show_mem_removable-to-handle-missing-sections.patch
* memcg-check-that-kmem_cache-has-memcg_params-before-accessing-it.patch
* sh64-kernel-use-usp-instead-of-fn.patch
* sh64-kernel-remove-useless-variable-regs.patch
* arch-x86-include-asm-pgtable-2levelh-clean-up-pte_to_pgoff-and-pgoff_to_pte-helpers.patch
* x86-make-mem=-option-to-work-for-efi-platform.patch
* drivers-pcmcia-pd6729c-convert-to-module_pci_driver.patch
* drivers-pcmcia-yenta_socketc-convert-to-module_pci_driver.patch
* drm-fb-helper-dont-sleep-for-screen-unblank-when-an-oopps-is-in-progress.patch
* drm-cirrus-correct-register-values-for-16bpp.patch
* drm-nouveau-make-vga_switcheroo-code-depend-on-vga_switcheroo.patch
* drivers-video-acornfbc-remove-dead-code.patch
* cyber2000fb-avoid-palette-corruption-at-higher-clocks.patch
* drivers-iommu-remove-unnecessary-platform_set_drvdata.patch
* include-linux-interrupth-add-dummy-irq_set_irq_wake-for-generic_hardirqs.patch
* genirq-correct-fuzzy-and-fragile-irq_retval-definition.patch
* hrtimer-one-more-expiry-time-overflow-check-in-hrtimer_interrupt.patch
* kernel-time-sched_clockc-correct-the-comparison-parameter-of-mhz.patch
* drivers-infiniband-core-cmc-convert-to-using-idr_alloc_cyclic.patch
* scripts-sortextable-support-objects-with-more-than-64k-sections.patch
* makefile-enable-werror=implicit-int-and-werror=strict-prototypes-by-default.patch
* makefile-enable-werror=implicit-int-and-werror=strict-prototypes-by-default-fix.patch
* drivers-net-ethernet-ibm-ehea-ehea_mainc-add-alias-entry-for-portn-properties.patch
* misdn-add-support-for-group-membership-check.patch
* drivers-atm-he-convert-to-module_pci_driver.patch
* isdn-clean-up-debug-format-string-usage.patch
* ocfs2-should-call-ocfs2_journal_access_di-before-ocfs2_delete_entry-in-ocfs2_orphan_del.patch
* ocfs2-llseek-requires-ocfs2-inode-lock-for-the-file-in-seek_end.patch
* ocfs2-fix-issue-that-ocfs2_setattr-does-not-deal-with-new_i_size==i_size.patch
* ocfs2-update-inode-size-after-zeronig-the-hole.patch
* ocfs2-lighten-up-allocate-transaction.patch
* ocfs2-using-i_size_read-to-access-i_size.patch
* ocfs2-dlm_request_all_locks-should-deal-with-the-status-sent-from-target-node.patch
* ocfs2-ac_bits_wanted-should-be-local_alloc_bits-when-returns-enospc.patch
* fs-ocfs2-cluster-tcpc-fix-possible-null-pointer-dereferences.patch
* ocfs2-use-list_for_each_entry-instead-of-list_for_each.patch
* ocfs2-clean-up-dead-code-in-ocfs2_acl_from_xattr.patch
* ocfs2-add-missing-return-value-check-of-ocfs2_get_clusters.patch
* ocfs2-fix-a-memory-leak-in-__ocfs2_move_extents.patch
* ocfs2-add-the-missing-return-value-check-of-ocfs2_xattr_get_clusters.patch
* ocfs2-free-meta_ac-and-data_ac-when-ocfs2_start_trans-fails-in-ocfs2_xattr_set.patch
* ocfs2-dlm-force-clean-refmap-when-doing-local-cleanup.patch
* ocfs2-fix-possible-double-free-in-ocfs2_reflink_xattr_rec.patch
* ocfs2-free-path-in-ocfs2_remove_inode_range.patch
* ocfs2-adjust-code-style-for-o2net_handler_tree_lookup.patch
* ocfs2-avoid-possible-null-pointer-dereference-in-o2net_accept_one.patch
* ocfs2-fix-a-tiny-race-case-when-firing-callbacks.patch
* ocfs2-cleanup-unused-variable-ip-in-dlmfs_get_root_inode.patch
* include-linux-schedh-dont-use-task-pid-tgid-in-same_thread_group-has_group_leader_pid.patch
* drivers-scsi-a100u2w-convert-to-module_pci_driver.patch
* drivers-scsi-dc395x-convert-to-module_pci_driver.patch
* drivers-scsi-dmx3191d-convert-to-module_pci_driver.patch
* drivers-scsi-initio-convert-to-module_pci_driver.patch
* drivers-scsi-mvumi-convert-to-module_pci_driver.patch
* drivers-net-irda-donauboe-convert-to-module_pci_driver.patch
* block-replace-strict_strtoul-with-kstrtoul.patch
* block-blk-sysfs-replace-strict_strtoul-with-kstrtoul.patch
* block-support-embedded-device-command-line-partition.patch
* block-support-embedded-device-command-line-partition-fix.patch
* drivers-block-mg_diskc-make-mg_times_out-static.patch
* cciss-set-max-scatter-gather-entries-to-32-on-p600.patch
* drivers-block-swimc-remove-unnecessary-platform_set_drvdata.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* vfs-allow-umount-to-handle-mountpoints-without-revalidating-them.patch
* anon_inodefs-forbid-open-via-proc.patch
* watchdog-update-watchdog-attributes-atomically.patch
* watchdog-update-watchdog_tresh-properly.patch
* watchdog-update-watchdog_tresh-properly-fix.patch
* watchdog-trigger-all-cpu-backtrace-when-locked-up-and-going-to-panic.patch
  mm.patch
* mm-mempolicy-turn-vma_set_policy-into-vma_dup_policy.patch
* mm-madvisec-fix-coding-style-errors.patch
* swap-warn-when-a-swap-area-overflows-the-maximum-size.patch
* swap-warn-when-a-swap-area-overflows-the-maximum-size-fix.patch
* mm-swapfilec-convert-to-pr_foo.patch
* mm-shift-vm_grows-check-from-mmap_region-to-do_mmap_pgoff-v2.patch
* mm-do_mmap_pgoff-cleanup-the-usage-of-file_inode.patch
* mm-mmap_region-kill-correct_wcount-inode-use-allow_write_access.patch
* mm-zswapc-get-swapper-address_space-by-using-macro.patch
* mm-vmstats-tlb-flush-counters.patch
* mm-vmstats-track-tlb-flush-stats-on-up-too.patch
* mm-vmstats-track-tlb-flush-stats-on-up-too-fix.patch
* mm-replace-strict_strtoul-with-kstrtoul.patch
* mm-fix-negative-left-shift-count-when-page_shift-20.patch
* mm-page_allocc-use-__paginginit-instead-of-__init.patch
* swap-change-block-allocation-algorithm-for-ssd.patch
* swap-make-swap-discard-async.patch
* swap-make-swap-discard-async-checkpatch-fixes.patch
* swap-fix-races-exposed-by-swap-discard.patch
* swap-make-cluster-allocation-per-cpu.patch
* swap-make-cluster-allocation-per-cpu-checkpatch-fixes.patch
* mm-page_allocc-fix-coding-style-and-spelling.patch
* mm-page_alloc-restructure-free-page-stealing-code-and-fix-a-bug.patch
* mm-page_alloc-restructure-free-page-stealing-code-and-fix-a-bug-fix.patch
* mm-fix-the-value-of-fallback_migratetype-in-alloc_extfrag-tracepoint.patch
* mm-kill-one-if-loop-in-__free_pages_bootmem.patch
* mm-fix-potential-null-pointer-dereference.patch
* mm-vmscan-fix-numa-reclaim-balance-problem-in-kswapd.patch
* mm-page_alloc-rearrange-watermark-checking-in-get_page_from_freelist.patch
* mm-page_alloc-fair-zone-allocator-policy.patch
* mm-page_alloc-fair-zone-allocator-policy-v2.patch
* mm-page_alloc-fair-zone-allocator-policy-v2-fix.patch
* mm-page_alloc-fair-zone-allocator-policy-v2-fix-2.patch
* mm-revert-page-writebackc-subtract-min_free_kbytes-from-dirtyable-memory.patch
* mm-hugetlb-move-up-the-code-which-check-availability-of-free-huge-page.patch
* mm-hugetlb-trivial-commenting-fix.patch
* mm-hugetlb-clean-up-alloc_huge_page.patch
* mm-hugetlb-fix-and-clean-up-node-iteration-code-to-alloc-or-free.patch
* mm-hugetlb-remove-redundant-list_empty-check-in-gather_surplus_pages.patch
* mm-hugetlb-do-not-use-a-page-in-page-cache-for-cow-optimization.patch
* mm-hugetlb-add-vm_noreserve-check-in-vma_has_reserves.patch
* mm-hugetlb-remove-decrement_hugepage_resv_vma.patch
* mm-hugetlb-decrement-reserve-count-if-vm_noreserve-alloc-page-cache.patch
* mm-hugetlb-decrement-reserve-count-if-vm_noreserve-alloc-page-cache-fix.patch
* mm-mempolicy-return-null-if-node-is-numa_no_node-in-get_task_policy.patch
* mm-page_alloc-add-unlikely-macro-to-help-compiler-optimization.patch
* mm-move-pgtable-related-functions-to-right-place.patch
* swap-clean-up-ifdef-in-page_mapping.patch
* vmstat-create-separate-function-to-fold-per-cpu-diffs-into-local-counters.patch
* vmstat-create-separate-function-to-fold-per-cpu-diffs-into-local-counters-fix.patch
* vmstat-create-fold_diff.patch
* vmstat-use-this_cpu-to-avoid-irqon-off-sequence-in-refresh_cpu_vm_stats.patch
* mm-vmalloc-remove-useless-variable-in-vmap_block.patch
* mm-vmalloc-use-well-defined-find_last_bit-func.patch
* mm-hotplug-remove-unnecessary-bug_on-in-__offline_pages.patch
* mm-zbud-fix-some-trivial-typos-in-comments.patch
* genalloc-fix-overflow-of-ending-address-of-memory-chunk.patch
* genalloc-fix-overflow-of-ending-address-of-memory-chunk-fix.patch
* mm-use-zone_end_pfn-instead-of-zone_start_pfnspanned_pages.patch
* mm-use-zone_end_pfn-instead-of-zone_start_pfnspanned_pages-fix.patch
* mm-use-zone_is_empty-instead-of-ifzone-spanned_pages.patch
* mm-use-zone_is_initialized-instead-of-ifzone-wait_table.patch
* readahead-make-context-readahead-more-conservative.patch
* hugepage-mention-libhugetlbfs-in-doc.patch
* mm-hotplug-verify-hotplug-memory-range.patch
* mm-hotplug-verify-hotplug-memory-range-fix.patch
* mm-hotplug-remove-stop_machine-from-try_offline_node.patch
* mm-hugetlb-protect-reserved-pages-when-soft-offlining-a-hugepage.patch
* mm-hugetlb-change-variable-name-reservations-to-resv.patch
* mm-hugetlb-fix-subpool-accounting-handling.patch
* mm-hugetlb-remove-useless-check-about-mapping-type.patch
* mm-hugetlb-grab-a-page_table_lock-after-page_cache_release.patch
* mm-hugetlb-return-a-reserved-page-to-a-reserved-pool-if-failed.patch
* mm-migrate-make-core-migration-code-aware-of-hugepage.patch
* mm-soft-offline-use-migrate_pages-instead-of-migrate_huge_page.patch
* migrate-add-hugepage-migration-code-to-migrate_pages.patch
* mm-migrate-add-hugepage-migration-code-to-move_pages.patch
* mm-mbind-add-hugepage-migration-code-to-mbind.patch
* mm-migrate-remove-vm_hugetlb-from-vma-flag-check-in-vma_migratable.patch
* mm-memory-hotplug-enable-memory-hotplug-to-handle-hugepage.patch
* mm-memory-hotplug-enable-memory-hotplug-to-handle-hugepage-fix.patch
* mm-memory-hotplug-enable-memory-hotplug-to-handle-hugepage-fix-2.patch
* mm-migrate-check-movability-of-hugepage-in-unmap_and_move_huge_page.patch
* mm-prepare-to-remove-proc-sys-vm-hugepages_treat_as_movable.patch
* mm-prepare-to-remove-proc-sys-vm-hugepages_treat_as_movable-v2.patch
* mm-prepare-to-remove-proc-sys-vm-hugepages_treat_as_movable-v2-fix.patch
* mm-mempolicy-rename-check_range-to-queue_pages_range.patch
* mbind-add-bug_onvma-in-new_vma_page.patch
* memblock-numa-binary-search-node-id.patch
* kmemcg-dont-allocate-extra-memory-for-root-memcg_cache_params-v2.patch
* mm-compaction-do-not-compact-pgdat-for-order-0.patch
* mm-fix-aio-performance-regression-for-database-caused-by-thp.patch
* mm-fix-aio-performance-regression-for-database-caused-by-thp-fix.patch
* writeback-fix-occasional-slow-sync1.patch
* mm-page_alloc-fix-comment-get_page_from_freelist.patch
* mm-track-vma-changes-with-vm_softdirty-bit.patch
* mm-track-vma-changes-with-vm_softdirty-bit-fix.patch
* mm-putback_lru_page-remove-unnecessary-call-to-page_lru_base_type.patch
* mm-munlock-remove-unnecessary-call-to-lru_add_drain.patch
* mm-munlock-batch-non-thp-page-isolation-and-munlockputback-using-pagevec.patch
* mm-munlock-batch-non-thp-page-isolation-and-munlockputback-using-pagevec-fix.patch
* mm-munlock-batch-nr_mlock-zone-state-updates.patch
* mm-munlock-bypass-per-cpu-pvec-for-putback_lru_page.patch
* mm-munlock-bypass-per-cpu-pvec-for-putback_lru_page-fix.patch
* mm-munlock-remove-redundant-get_page-put_page-pair-on-the-fast-path.patch
* mm-munlock-manual-pte-walk-in-fast-path-instead-of-follow_page_mask.patch
* mm-vmscan-fix-do_try_to_free_pages-livelock.patch
* mm-vmscan-fix-do_try_to_free_pages-livelock-fix.patch
* mm-vmscan-fix-do_try_to_free_pages-livelock-fix-2.patch
* mm-sparse-introduce-alloc_usemap_and_memmap.patch
* mm-writeback-make-writeback_inodes_wb-static.patch
* mm-vmalloc-use-wrapper-function-get_vm_area_size-to-caculate-size-of-vm-area.patch
* mm-mremapc-call-pud_free-after-fail-calling-pmd_alloc.patch
* mm-backing-devc-check-user-buffer-length-before-copying-data-to-the-related-user-buffer.patch
* mm-page-writebackc-add-strictlimit-feature.patch
* mm-make-sure-_page_swp_soft_dirty-bit-is-not-set-on-present-pte.patch
* mm-correct-the-comment-about-the-value-for-buddy-_mapcount.patch
* documentation-memory-hotplugtxt-fix-typo.patch
* hwpoison-always-unset-migrate_isolate-before-returning-from-soft_offline_page.patch
* mm-hwpoison-fix-loss-of-pg_dirty-for-errors-on-mlocked-pages.patch
* mm-hwpoison-dont-need-to-hold-compound-lock-for-hugetlbfs-page.patch
* mm-hwpoison-fix-race-against-poison-thp.patch
* mm-hwpoison-replace-atomic_long_sub-with-atomic_long_dec.patch
* mm-hwpoison-dont-set-migration-type-twice-to-avoid-holding-heavily-contend-zone-lock.patch
* mm-hwpoison-drop-forward-reference-declarations-__soft_offline_page.patch
* mm-hwpoison-add-to-madvise_hwpoison.patch
* mm-hwpoisonc-fix-held-reference-count-after-unpoisoning-empty-zero-page.patch
* mm-hwpoison-injectc-change-permission-of-corrupt-pfn-unpoison-pfn-to-0200.patch
* mm-memory-failurec-fix-bug-triggered-by-unpoisoning-empty-zero-page.patch
* mm-hwpoison-fix-return-value-of-madvise_hwpoison.patch
* mm-madvisec-madvise_hwpoison-remove-local-ret.patch
* thp-mm-locking-tail-page-is-a-bug.patch
* thp-mm-locking-tail-page-is-a-bug-fix.patch
* swap-add-a-simple-detector-for-inappropriate-swapin-readahead.patch
* swap-add-a-simple-detector-for-inappropriate-swapin-readahead-fix.patch
* drivers-firmware-google-gsmic-replace-strict_strtoul-with-kstrtoul.patch
* kernel-wide-fix-missing-validations-on-__get-__put-__copy_to-__copy_from_user.patch
* kernel-modsign_pubkeyc-fix-init-const-for-module-signing-code.patch
* lto-watchdog-hpwdtc-make-assembler-label-global.patch
* fs-bio-integrity-fix-a-potential-mem-leak.patch
* kernel-smpc-free-related-resources-when-failure-occurs-in-hotplug_cfd.patch
* kernel-spinlockc-add-default-arch__relax-definitions-for-generic_lockbreak.patch
* smp-quit-unconditionally-enabling-irq-in-on_each_cpu_mask-and-on_each_cpu_cond.patch
* upc-use-local_irq_saverestore-in-smp_call_function_single.patch
* smph-move-smp-version-of-on_each_cpu-out-of-line.patch
* syscallsh-use-gcc-alias-instead-of-assembler-aliases-for-syscalls.patch
* scripts-mod-modpostc-handle-non-abs-crc-symbols.patch
* extable-skip-sorting-if-the-table-is-empty.patch
* cleanup-add-forward-declarations-for-inplace-syscall-wrappers.patch
* kernel-smpc-quit-unconditionally-enabling-irqs-in-on_each_cpu_mask.patch
* kernel-padatac-register-hotcpu-notifier-after-initialization.patch
* task_work-minor-cleanups.patch
* task_work-documentation.patch
* x86-add-1-2-4-8-byte-optimization-to-64bit-__copy_fromto_user_inatomic.patch
* x86-include-linux-schedh-in-asm-uaccessh.patch
* tree-sweep-include-linux-schedh-for-might_sleep-users.patch
* sched-mark-should_resched-__always_inline.patch
* drivers-misc-ti-st-st_corec-fix-null-dereference-on-protocol-type-check.patch
* maintainers-exynos-remove-board-files.patch
* maintainers-arm-omap2-3-remove-unused-clockdomain-files.patch
* maintainers-omap-powerdomain-update-patterns.patch
* maintainers-arm-s3c2410-update-patterns.patch
* maintainers-arm-spear-consolidate-sections.patch
* maintainers-arm-plat-nomadik-update-patterns.patch
* maintainers-arm-s3c24xx-remove-plat-s3c24xx.patch
* maintainers-ghes_edac-update-pattern.patch
* maintainers-update-siano-drivers.patch
* maintainers-si4713-fix-file-pattern.patch
* maintainers-update-it913x-patterns.patch
* maintainers-update-ssbi-patterns.patch
* maintainers-update-file-pattern-for-arc-uart.patch
* maintainers-update-usb-ehci-platform-pattern.patch
* maintainers-usb-phy-update-patterns.patch
* maintainers-update-gre-demux-patterns.patch
* maintainers-add-mach-bcm-and-drivers.patch
* maintainers-append-to-directory-patterns.patch
* lib-genallocc-correct-dev_get_gen_pool-documentation.patch
* lib-crc32-update-the-comments-of-crc32_bele_generic.patch
* lib-crc32-update-the-comments-of-crc32_bele_generic-checkpatch-fixes.patch
* decompressors-fix-no-limit-output-buffer-length.patch
* lib-add-crc64-ecma-module.patch
* checkpatch-add-a-few-more-fix-corrections.patch
* checkpatch-check-camelcase-by-word-not-by-lval.patch
* checkpatch-enforce-sane-perl-version.patch
* checkpatch-check-for-duplicate-signatures.patch
* checkpatch-warn-when-using-extern-with-function-prototypes-in-h-files.patch
* checkpatch-fix-networking-kernel-doc-block-comment-defect.patch
* checkpatch-add-types-option-to-report-only-specific-message-types.patch
* checkpatch-ignore-define-trace_foo-macros.patch
* checkpatch-better-fix-of-spacing-errors.patch
* checkpatch-reduce-runtime-cpu-time-used.patch
* checkpatch-fix-perl-version-512-and-earlier-incompatibility.patch
* epoll-add-a-reschedule-point-in-ep_free.patch
* binfmt_elfc-use-get_random_int-to-fix-entropy-depleting.patch
* firmware-dmi_scan-drop-obsolete-comment.patch
* firmware-dmi_scan-fix-most-checkpatch-errors-and-warnings.patch
* firmware-dmi_scan-constify-strings.patch
* firmware-dmi_scan-drop-oom-messages.patch
* kprobes-unify-insn-caches.patch
* kprobes-allow-to-specify-custum-allocator-for-insn-caches.patch
* s390-kprobes-add-support-for-pc-relative-long-displacement-instructions.patch
* autofs4-allow-autofs-to-work-outside-the-initial-pid-namespace.patch
* autofs4-translate-pids-to-the-right-namespace-for-the-daemon.patch
* drivers-rtc-rtc-hid-sensor-timec-add-module-alias-to-let-the-module-load-automatically.patch
* drivers-rtc-rtc-pcf2127c-remove-empty-function.patch
* rtc-add-moxa-art-rtc-driver.patch
* drivers-rtc-rtc-omapc-add-rtc-wakeup-support-to-alarm-events.patch
* drivers-rtc-rtc-palmasc-support-for-backup-battery-charging.patch
* drivers-rtc-rtc-palmasc-support-for-backup-battery-charging-fix.patch
* drivers-rtc-rtc-hid-sensor-timec-improve-error-handling-when-rtc-register-fails.patch
* drivers-rtc-rtc-max77686c-fix-wrong-register.patch
* drivers-rtc-rtc-hid-sensor-timec-enable-hid-input-processing-early.patch
* rtc-rtc-nuc900-use-null-instead-of-0.patch
* hfsplus-add-necessary-declarations-for-posix-acls-support.patch
* hfsplus-implement-posix-acls-support.patch
* hfsplus-integrate-posix-acls-support-into-driver.patch
* fat-additions-to-support-fat_fallocate.patch
* fat-additions-to-support-fat_fallocate-fix.patch
* documentation-hwspinlocktxt-fix-typo.patch
* __ptrace_may_access-should-not-deny-sub-threads.patch
* signals-eventpoll-set-saved_sigmask-at-the-start.patch
* coredump-add-new-%p-variable-in-core_pattern.patch
* move-exit_task_namespaces-outside-of-exit_notify-fix.patch
* fix-mistake-in-the-description-of-committed_as.patch
* fs-proc-task_mmuc-check-the-return-value-of-mpol_to_str.patch
* exec-introduce-exec_binprm-for-depth-==-0-code.patch
* exec-kill-int-depth-in-search_binary_handler.patch
* exec-proc_exec_connector-should-be-called-only-once.patch
* exec-move-allow_write_access-fput-to-exec_binprm.patch
* exec-kill-load_binary-=-null-check-in-search_binary_handler.patch
* exec-cleanup-the-config_modules-logic.patch
* exec-dont-retry-if-request_module-fails.patch
* exec-cleanup-the-error-handling-in-search_binary_handler.patch
* kexec-remove-unnecessary-return.patch
* vmcore-introduce-elf-header-in-new-memory-feature.patch
* s390-vmcore-use-elf-header-in-new-memory-feature.patch
* vmcore-introduce-remap_oldmem_pfn_range.patch
* vmcore-introduce-remap_oldmem_pfn_range-fix.patch
* s390-vmcore-implement-remap_oldmem_pfn_range-for-s390.patch
* vmcore-enable-proc-vmcore-mmap-for-s390.patch
* s390-vmcore-use-vmcore-for-zfcpdump.patch
* rbtree-add-postorder-iteration-functions.patch
* rbtree-add-rbtree_postorder_for_each_entry_safe-helper.patch
* rbtree_test-add-test-for-postorder-iteration.patch
* rbtree-allow-tests-to-run-as-builtin.patch
* mm-zswap-use-postorder-iteration-when-destroying-rbtree.patch
* aoe-create-and-destroy-debugfs-directory-for-aoe.patch
* aoe-add-aoe-target-files-to-debugfs.patch
* aoe-provide-file-operations-for-debugfs-files.patch
* aoe-fill-in-per-aoe-target-information-for-debugfs-file.patch
* aoe-update-copyright-date.patch
* aoe-update-internal-version-number-to-85.patch
* aoe-remove-custom-implementation-of-kbasename.patch
* aoe-suppress-compiler-warnings.patch
* affs-use-loff_t-in-affs_truncate.patch
* panic-call-panic-handlers-before-kmsg_dump.patch
* pktcdvd-convert-zone-macro-to-static-function-get_zone.patch
* pktcdvd-convert-printk-to-pr_level.patch
* pktcdvd-consolidate-dprintk-and-vprintk-macros.patch
* pktcdvd-add-struct-pktcdvd_device-to-pkt_dbg.patch
* pktcdvd-add-struct-pktcdvd_devicename-to-pr_err-logging-where-possible.patch
* pktcdvd-convert-pr_notice-to-pkt_notice.patch
* pktcdvd-convert-pr_info-to-pkt_info.patch
* pktcdvd-add-struct-pktcdvd_device-to-pkt_dump_sense.patch
* pktcdvd-fix-defective-misuses-of-pkt_level.patch
* drivers-pps-clients-pps-gpioc-remove-unnecessary-platform_set_drvdata.patch
* drivers-memstick-host-rtsx_pci_msc-remove-unnecessary-platform_set_drvdata.patch
* memstick-add-support-for-legacy-memorysticks.patch
* w1-replace-strict_strtol-with-kstrtol.patch
* drivers-w1-masters-mxc_w1c-remove-unnecessary-platform_set_drvdata.patch
* lib-radix-treec-make-radix_tree_node_alloc-work-correctly-within-interrupt.patch
* initmpfs-replace-ms_nouser-in-initramfs.patch
* initmpfs-move-bdi-setup-from-init_rootfs-to-init_ramfs.patch
* initmpfs-move-bdi-setup-from-init_rootfs-to-init_ramfs-fix.patch
* initmpfs-move-rootfs-code-from-fs-ramfs-to-init.patch
* initmpfs-make-rootfs-use-tmpfs-when-config_tmpfs-enabled.patch
* initmpfs-use-initramfs-if-rootfstype=-or-root=-specified.patch
* initmpfs-use-initramfs-if-rootfstype=-or-root=-specified-fix.patch
* initmpfs-use-initramfs-if-rootfstype=-or-root=-specified-checkpatch-fixes.patch
* ipcshm-introduce-lockless-functions-to-obtain-the-ipc-object.patch
* ipcshm-shorten-critical-region-in-shmctl_down.patch
* ipc-drop-ipcctl_pre_down.patch
* ipc-drop-ipcctl_pre_down-fix.patch
* ipcshm-introduce-shmctl_nolock.patch
* ipcshm-make-shmctl_nolock-lockless.patch
* ipcshm-make-shmctl_nolock-lockless-checkpatch-fixes.patch
* ipcshm-shorten-critical-region-for-shmctl.patch
* ipcshm-cleanup-do_shmat-pasta.patch
* ipcshm-shorten-critical-region-for-shmat.patch
* ipcshm-shorten-critical-region-for-shmat-fix.patch
* ipc-rename-ids-rw_mutex.patch
* ipcmsg-drop-msg_unlock.patch
* ipc-document-general-ipc-locking-scheme.patch
* ipc-shm-guard-against-non-existant-vma-in-shmdt2.patch
* ipc-drop-ipc_lock_by_ptr.patch
* ipc-shm-drop-shm_lock_check.patch
* ipc-drop-ipc_lock_check.patch
* lz4-fix-compression-decompression-signedness-mismatch.patch
  linux-next.patch
* revert-selinux-do-not-handle-seclabel-as-a-special-flag.patch
* memcg-remove-redundant-code-in-mem_cgroup_force_empty_write.patch
* memcg-vmscan-integrate-soft-reclaim-tighter-with-zone-shrinking-code.patch
* memcg-get-rid-of-soft-limit-tree-infrastructure.patch
* vmscan-memcg-do-softlimit-reclaim-also-for-targeted-reclaim.patch
* memcg-enhance-memcg-iterator-to-support-predicates.patch
* memcg-enhance-memcg-iterator-to-support-predicates-fix.patch
* memcg-track-children-in-soft-limit-excess-to-improve-soft-limit.patch
* memcg-vmscan-do-not-attempt-soft-limit-reclaim-if-it-would-not-scan-anything.patch
* memcg-track-all-children-over-limit-in-the-root.patch
* memcg-vmscan-do-not-fall-into-reclaim-all-pass-too-quickly.patch
* memcg-trivial-cleanups.patch
* arch-mm-remove-obsolete-init-oom-protection.patch
* arch-mm-do-not-invoke-oom-killer-on-kernel-fault-oom.patch
* arch-mm-pass-userspace-fault-flag-to-generic-fault-handler.patch
* x86-finish-user-fault-error-path-with-fatal-signal.patch
* mm-memcg-enable-memcg-oom-killer-only-for-user-faults.patch
* mm-memcg-rework-and-document-oom-waiting-and-wakeup.patch
* mm-memcg-do-not-trap-chargers-with-full-callstack-on-oom.patch
* memcg-correct-resource_max-to-ullong_max.patch
* memcg-rename-resource_max-to-res_counter_max.patch
* memcg-avoid-overflow-caused-by-page_align.patch
* memcg-reduce-function-dereference.patch
* memcg-remove-memcg_nr_file_mapped.patch
* memcg-check-for-proper-lock-held-in-mem_cgroup_update_page_stat.patch
* memcg-add-per-cgroup-writeback-pages-accounting.patch
* memcg-document-cgroup-dirty-writeback-memory-statistics.patch
* mm-make-lru_add_drain_all-selective.patch
* truncate-drop-oldsize-truncate_pagecache-parameter.patch
* mm-drop-actor-argument-of-do_generic_file_read.patch
* mm-drop-actor-argument-of-do_generic_file_read-fix.patch
* thp-account-anon-transparent-huge-pages-into-nr_anon_pages.patch
* mm-cleanup-add_to_page_cache_locked.patch
* thp-move-maybe_pmd_mkwrite-out-of-mk_huge_pmd.patch
* thp-do_huge_pmd_anonymous_page-cleanup.patch
* thp-consolidate-code-between-handle_mm_fault-and-do_huge_pmd_anonymous_page.patch
* mm-thp-count-thp_fault_fallback-anytime-thp-fault-fails.patch
* kernel-replace-strict_strto-with-kstrto.patch
* fs-bump-inode-and-dentry-counters-to-long.patch
* super-fix-calculation-of-shrinkable-objects-for-small-numbers.patch
* dcache-convert-dentry_statnr_unused-to-per-cpu-counters.patch
* dentry-move-to-per-sb-lru-locks.patch
* dcache-remove-dentries-from-lru-before-putting-on-dispose-list.patch
* mm-new-shrinker-api.patch
* shrinker-convert-superblock-shrinkers-to-new-api.patch
* shrinker-convert-superblock-shrinkers-to-new-api-fix.patch
* list-add-a-new-lru-list-type.patch
* inode-convert-inode-lru-list-to-generic-lru-list-code.patch
* inode-convert-inode-lru-list-to-generic-lru-list-code-inode-move-inode-to-a-different-list-inside-lock.patch
* dcache-convert-to-use-new-lru-list-infrastructure.patch
* list_lru-per-node-list-infrastructure.patch
* list_lru-per-node-list-infrastructure-fix.patch
* list_lru-per-node-list-infrastructure-fix-broken-lru_retry-behaviour.patch
* list_lru-per-node-api.patch
* list_lru-remove-special-case-function-list_lru_dispose_all.patch
* shrinker-add-node-awareness.patch
* vmscan-per-node-deferred-work.patch
* fs-convert-inode-and-dentry-shrinking-to-be-node-aware.patch
* xfs-convert-buftarg-lru-to-generic-code.patch
* xfs-convert-buftarg-lru-to-generic-code-fix.patch
* xfs-rework-buffer-dispose-list-tracking.patch
* xfs-convert-dquot-cache-lru-to-list_lru.patch
* xfs-convert-dquot-cache-lru-to-list_lru-fix.patch
* xfs-convert-dquot-cache-lru-to-list_lru-fix-dquot-isolation-hang.patch
* fs-convert-fs-shrinkers-to-new-scan-count-api.patch
* fs-convert-fs-shrinkers-to-new-scan-count-api-fix.patch
* fs-convert-fs-shrinkers-to-new-scan-count-api-fix-fix.patch
* fs-convert-fs-shrinkers-to-new-scan-count-api-fix-fix-2.patch
* drivers-convert-shrinkers-to-new-count-scan-api.patch
* drivers-convert-shrinkers-to-new-count-scan-api-fix.patch
* drivers-convert-shrinkers-to-new-count-scan-api-fix-2.patch
* i915-bail-out-earlier-when-shrinker-cannot-acquire-mutex.patch
* shrinker-convert-remaining-shrinkers-to-count-scan-api.patch
* shrinker-convert-remaining-shrinkers-to-count-scan-api-fix.patch
* hugepage-convert-huge-zero-page-shrinker-to-new-shrinker-api.patch
* hugepage-convert-huge-zero-page-shrinker-to-new-shrinker-api-fix.patch
* shrinker-kill-old-shrink-api.patch
* shrinker-kill-old-shrink-api-fix.patch
* list_lru-dynamically-adjust-node-arrays.patch
* list_lru-dynamically-adjust-node-arrays-super-fix-for-destroy-lrus.patch
* staging-lustre-ldlm-convert-to-shrinkers-to-count-scan-api.patch
* staging-lustre-obdclass-convert-lu_object-shrinker-to-count-scan-api.patch
* staging-lustre-ptlrpc-convert-to-new-shrinker-api.patch
* staging-lustre-libcfs-cleanup-linux-memh.patch
* mm-kconfig-add-mmu-dependency-for-migration.patch
  debugging-keep-track-of-page-owners.patch
  debugging-keep-track-of-page-owners-fix.patch
  debugging-keep-track-of-page-owners-fix-2.patch
  debugging-keep-track-of-page-owners-fix-2-fix.patch
  debugging-keep-track-of-page-owners-fix-2-fix-fix.patch
  debugging-keep-track-of-page-owners-fix-2-fix-fix-fix.patch
  debugging-keep-track-of-page-owner-now-depends-on-stacktrace_support.patch
  make-sure-nobodys-leaking-resources.patch
  journal_add_journal_head-debug.patch
  releasing-resources-with-children.patch
  make-frame_pointer-default=y.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  mutex-subsystem-synchro-test-module.patch
  slab-leaks3-default-y.patch
  put_bh-debug.patch
  add-debugging-aid-for-memory-initialisation-problems.patch
  workaround-for-a-pci-restoring-bug.patch
  single_open-seq_release-leak-diagnostics.patch
  add-a-refcount-check-in-dput.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
