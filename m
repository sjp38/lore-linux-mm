Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0FA126B0317
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 16:59:58 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y19so8829425wrc.8
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 13:59:58 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a5si3348344wrc.78.2017.06.16.13.59.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 13:59:56 -0700 (PDT)
Date: Fri, 16 Jun 2017 13:59:53 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2017-06-16-13-59 uploaded
Message-ID: <594446c9.eAH/wqFVRkHpWQ7B%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2017-06-16-13-59 has been uploaded to

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


This mmotm tree contains the following patches against 4.12-rc5:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
* mm-hwpoison-use-compound_head-flags-for-huge-pages.patch
* swap-cond_resched-in-swap_cgroup_prepare.patch
* mm-numa-avoid-waiting-on-freed-migrated-pages.patch
* userfaultfd-shmem-handle-coredumping-in-handle_userfault.patch
* mm-correct-the-comment-when-reclaimed-pages-exceed-the-scanned-pages.patch
* mm-correct-the-comment-when-reclaimed-pages-exceed-the-scanned-pages-fix.patch
* mm-list_lruc-use-cond_resched_lock-for-nlru-lock.patch
* mm-skip-hwpoisoned-pages-when-onlining-pages.patch
* mm-huge-vmap-fail-gracefully-on-unexpected-huge-vmap-mappings.patch
* autofs-sanity-check-status-reported-with-autofs_dev_ioctl_fail.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* mn10300-remove-wrapper-header-for-asm-deviceh.patch
* mn10300-use-generic-fbh.patch
* tile-provide-default-ioremap-declaration.patch
* teach-initramfs_root_uid-and-initramfs_root_gid-that-1-means-current-user.patch
* clarify-help-text-that-compression-applies-to-ramfs-as-well-as-legacy-ramdisk.patch
* sh-intc-delete-an-error-message-for-a-failed-memory-allocation-in-add_virq_to_pirq.patch
* ocfs2-fix-a-static-checker-warning.patch
* ocfs2-use-magich.patch
* ocfs2-get-rid-of-ocfs2_is_o2cb_active-function.patch
* ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called.patch
* ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called-fix.patch
* ocfs2-dlm-optimization-of-code-while-free-dead-node-locks.patch
* ocfs2-dlm-optimization-of-code-while-free-dead-node-locks-checkpatch-fixes.patch
* ocfs2-give-an-obvious-tip-for-dismatch-cluster-names.patch
* ocfs2-give-an-obvious-tip-for-dismatch-cluster-names-v2.patch
* ocfs2-move-some-definitions-to-header-file.patch
* ocfs2-fix-some-small-problems.patch
* ocfs2-add-kobject-for-online-file-check.patch
* ocfs2-add-duplicative-ino-number-check.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* sendfile-do-not-update-file-offset-of-non-lseekable-objects.patch
* fs-file-replace-alloc_fdmem-with-kvmalloc-alternative.patch
* watchdog-remove-unused-declaration.patch
* watchdog-introduce-arch_touch_nmi_watchdog.patch
* watchdog-split-up-config-options.patch
* watchdog-provide-watchdog_reconfigure-for-arch-watchdogs.patch
* powerpc-64s-implement-arch-specific-hardlockup-watchdog.patch
* powerpc-64s-implement-arch-specific-hardlockup-watchdog-checkpatch-fixes.patch
  mm.patch
* mm-slub-remove-a-redundant-assignment-in-___slab_alloc.patch
* mm-slub-reset-cpu_slabs-pointer-in-deactivate_slab.patch
* mm-slub-pack-red_left_pad-with-another-int-to-save-a-word.patch
* mm-slub-wrap-cpu_slab-partial-in-config_slub_cpu_partial.patch
* mm-slub-wrap-cpu_slab-partial-in-config_slub_cpu_partial-fix.patch
* mm-slub-wrap-kmem_cache-cpu_partial-in-config-config_slub_cpu_partial.patch
* subject-mm-slab-trivial-change-to-replace-round-up-code-with-align.patch
* mm-sparsemem-break-out-of-loops-early.patch
* mark-protection_map-as-__ro_after_init.patch
* mm-vmscan-fix-unsequenced-modification-and-access-warning.patch
* mm-nobootmem-return-0-when-start_pfn-equals-end_pfn.patch
* ksm-introduce-ksm_max_page_sharing-per-page-deduplication-limit.patch
* ksm-fix-use-after-free-with-merge_across_nodes-=-0.patch
* ksm-cleanup-stable_node-chain-collapse-case.patch
* ksm-swap-the-two-output-parameters-of-chain-chain_prune.patch
* ksm-optimize-refile-of-stable_node_dup-at-the-head-of-the-chain.patch
* zram-count-same-page-write-as-page_stored.patch
* mm-vmstat-standardize-file-operations-variable-names.patch
* mm-thp-swap-delay-splitting-thp-during-swap-out.patch
* mm-thp-swap-delay-splitting-thp-during-swap-out-fix.patch
* mm-thp-swap-unify-swap-slot-free-functions-to-put_swap_page.patch
* mm-thp-swap-move-anonymous-thp-split-logic-to-vmscan.patch
* mm-thp-swap-check-whether-thp-can-be-split-firstly.patch
* mm-thp-swap-enable-thp-swap-optimization-only-if-has-compound-map.patch
* mm-remove-return-value-from-init_currently_empty_zone.patch
* mm-memory_hotplug-use-node-instead-of-zone-in-can_online_high_movable.patch
* mm-drop-page_initialized-check-from-get_nid_for_pfn.patch
* mm-memory_hotplug-get-rid-of-is_zone_device_section.patch
* mm-memory_hotplug-split-up-register_one_node.patch
* mm-memory_hotplug-consider-offline-memblocks-removable.patch
* mm-consider-zone-which-is-not-fully-populated-to-have-holes.patch
* mm-consider-zone-which-is-not-fully-populated-to-have-holes-fix.patch
* mm-compaction-skip-over-holes-in-__reset_isolation_suitable.patch
* mm-__first_valid_page-skip-over-offline-pages.patch
* mm-vmstat-skip-reporting-offline-pages-in-pagetypeinfo.patch
* mm-vmstat-skip-reporting-offline-pages-in-pagetypeinfo-fix.patch
* mm-memory_hotplug-do-not-associate-hotadded-memory-to-zones-until-online.patch
* mm-memory_hotplug-do-not-associate-hotadded-memory-to-zones-until-online-fix.patch
* mm-memory_hotplug-fix-mmop_online_keep-behavior.patch
* mm-memory_hotplug-do-not-assume-zone_normal-is-default-kernel-zone.patch
* mm-memory_hotplug-replace-for_device-by-want_memblock-in-arch_add_memory.patch
* mm-memory_hotplug-fix-the-section-mismatch-warning.patch
* mm-memory_hotplug-remove-unused-cruft-after-memory-hotplug-rework.patch
* exit-dont-include-unused-userfaultfd_kh.patch
* userfaultfd-drop-dead-code.patch
* mm-madvise-enable-softhard-offline-of-hugetlb-pages-at-pgd-level.patch
* mm-madvise-enable-softhard-offline-of-hugetlb-pages-at-pgd-level-fix.patch
* mm-hugetlb-migration-use-set_huge_pte_at-instead-of-set_pte_at.patch
* mm-follow_page_mask-split-follow_page_mask-to-smaller-functions.patch
* mm-hugetlb-export-hugetlb_entry_migration-helper.patch
* mm-follow_page_mask-add-support-for-hugetlb-pgd-entries.patch
* mm-hugetlb-move-default-definition-of-hugepd_t-earlier-in-the-header.patch
* mm-follow_page_mask-add-support-for-hugepage-directory-entry.patch
* powerpc-hugetlb-add-follow_huge_pd-implementation-for-ppc64.patch
* powerpc-mm-hugetlb-remove-follow_huge_addr-for-powerpc.patch
* powerpc-hugetlb-enable-hugetlb-migration-for-ppc64.patch
* mm-zeroing-hash-tables-in-allocator.patch
* mm-updated-callers-to-use-hash_zero-flag.patch
* mm-adaptive-hash-table-scaling.patch
* mm-adaptive-hash-table-scaling-fix.patch
* mm-adaptive-hash-table-scaling-v2.patch
* mm-adaptive-hash-table-scaling-v5.patch
* mm-hugetlb-cleanup-arch_has_gigantic_page.patch
* powerpc-mm-hugetlb-add-support-for-1g-huge-pages.patch
* mm-page_alloc-mark-bad_range-and-meminit_pfn_in_nid-as-__maybe_unused.patch
* mm-drop-null-return-check-of-pte_offset_map_lock.patch
* arm64-hugetlb-refactor-find_num_contig.patch
* arm64-hugetlb-remove-spurious-calls-to-huge_ptep_offset.patch
* mm-gup-remove-broken-vm_bug_on_page-compound-check-for-hugepages.patch
* mm-gup-ensure-real-head-page-is-ref-counted-when-using-hugepages.patch
* mm-hugetlb-add-size-parameter-to-huge_pte_offset.patch
* mm-hugetlb-allow-architectures-to-override-huge_pte_clear.patch
* mm-hugetlb-introduce-set_huge_swap_pte_at-helper.patch
* mm-hugetlb-introduce-set_huge_swap_pte_at-helper-v4.patch
* mm-hugetlb-introduce-set_huge_swap_pte_at-helper-v41.patch
* mm-rmap-use-correct-helper-when-poisoning-hugepages.patch
* mm-page_alloc-fix-more-premature-oom-due-to-race-with-cpuset-update.patch
* mm-mempolicy-stop-adjusting-current-il_next-in-mpol_rebind_nodemask.patch
* mm-page_alloc-pass-preferred-nid-instead-of-zonelist-to-allocator.patch
* mm-mempolicy-simplify-rebinding-mempolicies-when-updating-cpusets.patch
* mm-cpuset-always-use-seqlock-when-changing-tasks-nodemask.patch
* mm-mempolicy-dont-check-cpuset-seqlock-where-it-doesnt-matter.patch
* swap-add-block-io-poll-in-swapin-path.patch
* swap-add-block-io-poll-in-swapin-path-checkpatch-fixes.patch
* mm-kmemleak-slightly-reduce-the-size-of-some-structures-on-64-bit-architectures.patch
* mm-kmemleak-factor-object-reference-updating-out-of-scan_block.patch
* mm-kmemleak-treat-vm_struct-as-alternative-reference-to-vmalloced-objects.patch
* mm-drop-wait-parameter-from-write_one_page.patch
* mm-drop-wait-parameter-from-write_one_page-fix.patch
* mm-fix-mapping_set_error-call-in-me_pagecache_dirty.patch
* mm-per-cgroup-memory-reclaim-stats.patch
* mm-oom_kill-count-global-and-memory-cgroup-oom-kills.patch
* mm-oom_kill-count-global-and-memory-cgroup-oom-kills-fix.patch
* mm-oom_kill-count-global-and-memory-cgroup-oom-kills-fix-fix.patch
* mm-swap-sort-swap-entries-before-free.patch
* mm-swap-sort-swap-entries-before-free-fix.patch
* zswap-delete-an-error-message-for-a-failed-memory-allocation-in-zswap_pool_create.patch
* zswap-improve-a-size-determination-in-zswap_frontswap_init.patch
* zswap-delete-an-error-message-for-a-failed-memory-allocation-in-zswap_dstmem_prepare.patch
* mm-vmstat-move-slab-statistics-from-zone-to-node-counters.patch
* mm-vmstat-move-slab-statistics-from-zone-to-node-counters-fix.patch
* mm-memcontrol-use-the-node-native-slab-memory-counters.patch
* mm-memcontrol-use-generic-mod_memcg_page_state-for-kmem-pages.patch
* mm-memcontrol-per-lruvec-stats-infrastructure.patch
* mm-memcontrol-per-lruvec-stats-infrastructure-fix.patch
* mm-memcontrol-per-lruvec-stats-infrastructure-fix-2.patch
* mm-memcontrol-per-lruvec-stats-infrastructure-fix-3.patch
* mm-memcontrol-account-slab-stats-per-lruvec.patch
* mm-memory_hotplug-drop-artificial-restriction-on-online-offline.patch
* mm-memory_hotplug-drop-config_movable_node.patch
* mm-memory_hotplug-move-movable_node-to-the-hotplug-proper.patch
* mm-page_alloc-fallback-to-smallest-page-when-not-stealing-whole-pageblock.patch
* mm-convert-to-define_debugfs_attribute.patch
* mm-vmscan-avoid-thrashing-anon-lru-when-free-file-is-low.patch
* mm-vmscan-avoid-thrashing-anon-lru-when-free-file-is-low-fix.patch
* mm-add-null-check-to-avoid-potential-null-pointer-dereference.patch
* mm-zsmalloc-fix-wunneeded-internal-declaration-warning.patch
* fs-bufferc-make-bh_lru_install-more-efficient.patch
* mm-hugetlb-prevent-reuse-of-hwpoisoned-free-hugepages.patch
* mm-hugetlb-return-immediately-for-hugetlb-page-in-__delete_from_page_cache.patch
* mm-hwpoison-change-pagehwpoison-behavior-on-hugetlb-pages.patch
* mm-hugetlb-soft-offline-dissolve-source-hugepage-after-successful-migration.patch
* mm-hugetlb-soft-offline-dissolve-source-hugepage-after-successful-migration-fix.patch
* mm-soft-offline-dissolve-free-hugepage-if-soft-offlined.patch
* mm-hwpoison-introduce-memory_failure_hugetlb.patch
* mm-hwpoison-dissolve-in-use-hugepage-in-unrecoverable-memory-error.patch
* mm-hwpoison-dissolve-in-use-hugepage-in-unrecoverable-memory-error-fix.patch
* mm-hugetlb-delete-dequeue_hwpoisoned_huge_page.patch
* mm-hwpoison-introduce-idenfity_page_state.patch
* mm-vmpressure-pass-through-notification-support.patch
* mm-vmpressure-pass-through-notification-support-fix.patch
* mm-make-pr_set_thp_disable-immediately-active.patch
* mm-memcontrol-exclude-root-from-checks-in-mem_cgroup_low.patch
* vmalloc-show-more-detail-info-in-vmallocinfo-for-clarify.patch
* mm-cma-warn-if-the-cma-area-could-not-be-activated.patch
* mm-hugetlb-warn-the-user-when-issues-arise-on-boot-due-to-hugepages.patch
* mm-hugetlb-warn-the-user-when-issues-arise-on-boot-due-to-hugepages-fix.patch
* oom-trace-remove-enum-evaluation-of-compaction_feedback.patch
* mm-improve-readability-of-transparent_hugepage_enabled.patch
* mm-improve-readability-of-transparent_hugepage_enabled-fix.patch
* mm-improve-readability-of-transparent_hugepage_enabled-fix-fix.patch
* mm-always-enable-thp-for-dax-mappings.patch
* mm-page_ref-ensure-page_ref_unfreeze-is-ordered-against-prior-accesses.patch
* mm-migrate-stabilise-page-count-when-migrating-transparent-hugepages.patch
* zram-use-__sysfs_match_string-helper.patch
* mm-memory_hotplug-support-movable_node-for-hotplugable-nodes.patch
* mm-memory_hotplug-simplify-empty-node-mask-handling-in-new_node_page.patch
* hugetlb-memory_hotplug-prefer-to-use-reserved-pages-for-migration.patch
* hugetlb-memory_hotplug-prefer-to-use-reserved-pages-for-migration-fix.patch
* mm-unify-new_node_page-and-alloc_migrate_target.patch
* mm-hugetlb-schedule-when-potentially-allocating-many-hugepages.patch
* mm-memcg-fix-potential-undefined-behavior-in-mem_cgroup_event_ratelimit.patch
* replace-memfmt-with-string_get_size.patch
* mm-page_alloc-return-0-in-case-this-node-has-no-page-within-the-zone.patch
* mm-vmscan-do-not-pass-reclaimed-slab-to-vmpressure.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* mm-walk-the-zone-in-pageblock_nr_pages-steps.patch
* mm-kasan-use-kasan_zero_pud-for-p4d-table.patch
* mm-kasan-get-rid-of-speculative-shadow-checks.patch
* x86-kasan-dont-allocate-extra-shadow-memory.patch
* arm64-kasan-dont-allocate-extra-shadow-memory.patch
* mm-kasan-add-support-for-memory-hotplug.patch
* mm-kasan-rename-xxx_is_zero-to-xxx_is_nonzero.patch
* frv-remove-wrapper-header-for-asm-deviceh.patch
* frv-use-generic-fbh.patch
* fs-proc-switch-to-ida_simple_get-remove.patch
* randomstackprotect-introduce-get_random_canary-function.patch
* forkrandom-use-get_random_canary-to-set-tsk-stack_canary.patch
* x86-ascii-armor-the-x86_64-boot-init-stack-canary.patch
* arm64-ascii-armor-the-arm64-boot-init-stack-canary.patch
* sh64-ascii-armor-the-sh64-boot-init-stack-canary.patch
* asm-generic-bugh-declare-struct-pt_regs-before-function-prototype.patch
* linux-bugh-correct-formatting-of-block-comment.patch
* linux-bugh-correct-foo-should-be-foo.patch
* linux-bugh-correct-space-required-before-that.patch
* bug-split-build_bug-stuff-out-into-linux-build_bugh.patch
* kernelh-handle-pointers-to-arrays-better-in-container_of.patch
* kernel-groupsc-use-sort-library-function.patch
* kernel-kallsyms-replace-all_var-with-is_enabledconfig_kallsyms_all.patch
* maintainers-give-proc-sysctl-some-maintainer-love.patch
* kstrtox-delete-end-of-string-test.patch
* kstrtox-use-unsigned-int-more.patch
* lib-interval_tree_test-allow-the-module-to-be-compiled-in.patch
* lib-interval_tree_test-make-test-options-module-parameters.patch
* lib-interval_tree_test-allow-users-to-limit-scope-of-endpoint.patch
* lib-interval_tree_test-allow-full-tree-search.patch
* lib-rhashtablec-use-kvzalloc-in-bucket_table_alloc-when-possible.patch
* lib-extablec-use-bsearch-library-function-in-search_extable.patch
* lib-extablec-use-bsearch-library-function-in-search_extable-checkpatch-fixes.patch
* bsearch-micro-optimize-pivot-position-calculation.patch
* checkpatch-improve-the-unnecessary-oom-message-test.patch
* checkpatch-warn-when-a-maintainers-entry-isnt-t.patch
* checkpatch-list_head-is-also-declaration.patch
* checkpatch-fix-stepping-through-statements-with-stat-and-ctx_statement_block.patch
* checkpatch-remove-false-warning-for-commit-reference.patch
* checkpatch-improve-tests-for-multiple-line-function-definitions.patch
* checkpatch-silence-perl-5260-unescaped-left-brace-warnings.patch
* checkpatch-change-format-of-color-argument-to-color.patch
* fs-epoll-short-circuit-fetching-events-if-thread-has-been-killed.patch
* signal-avoid-undefined-behaviour-in-kill_something_info.patch
* signal-avoid-undefined-behaviour-in-kill_something_info-fix.patch
* exit-avoid-undefined-behaviour-when-call-wait4.patch
* seq_file-delete-small-value-optimization.patch
* virtually-mapped-stacks-do-not-disable-interrupts.patch
* kexec-move-vmcoreinfo-out-of-the-kernels-bss-section.patch
* powerpc-fadump-use-the-correct-vmcoreinfo_note_size-for-phdr.patch
* powerpc-fadump-use-the-correct-vmcoreinfo_note_size-for-phdr-fix.patch
* kdump-protect-vmcoreinfo-data-under-the-crash-memory.patch
* kexec-kdump-minor-documentation-updates-for-arm64-and-image.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* sysctl-fix-lax-sysctl_check_table-sanity-check.patch
* sysctl-kdocify-sysctl_writes_strict.patch
* sysctl-fold-sysctl_writes_strict-checks-into-helper.patch
* sysctl-simplify-unsigned-int-support.patch
* sysctl-add-unsigned-int-range-support.patch
* sysctl-check-name-array-length-in-deprecated_sysctl_warning.patch
* test_sysctl-add-dedicated-proc-sysctl-test-driver.patch
* test_sysctl-add-generic-script-to-expand-on-tests.patch
* test_sysctl-test-against-page_size-for-int.patch
* test_sysctl-add-simple-proc_dointvec-case.patch
* test_sysctl-add-simple-proc_douintvec-case.patch
* test_sysctl-test-against-int-proc_dointvec-array-support.patch
* uapi-fix-linux-sysctlh-userspace-compilation-errors.patch
* bfs-fix-sanity-checks-for-empty-files.patch
* fs-kill-config_percpu_rwsem-some-more.patch
* scripts-gdb-add-lx-fdtdump-command.patch
* kfifo-cleanup-example-to-not-use-page_link.patch
* procfs-fdinfo-extend-information-about-epoll-target-files.patch
* kcmp-add-kcmp_epoll_tfd-mode-to-compare-epoll-target-files.patch
* kcmp-fs-epoll-wrap-kcmp-code-with-config_checkpoint_restore.patch
* kernel-reboot-add-devm_register_reboot_notifier.patch
* kernel-reboot-add-devm_register_reboot_notifier-fix.patch
* fault-inject-support-systematic-fault-injection.patch
* fault-inject-support-systematic-fault-injection-fix.patch
* fault-inject-automatically-detect-the-number-base-for-fail-nth-write-interface.patch
* fault-inject-parse-as-natural-1-based-value-for-fail-nth-write-interface.patch
* fault-inject-make-fail-nth-read-write-interface-symmetric.patch
* fault-inject-simplify-access-check-for-fail-nth.patch
* fault-inject-simplify-access-check-for-fail-nth-fix.patch
* fault-inject-add-proc-pid-fail-nth.patch
* ipc-semc-remove-sem_base-embed-struct-sem.patch
* ipc-semc-remove-sem_base-embed-struct-sem-v3.patch
* ipc-merge-ipc_rcu-and-kern_ipc_perm.patch
* ipc-merge-ipc_rcu-and-kern_ipc_perm-fix.patch
* include-linux-semh-correctly-document-sem_ctime.patch
* ipc-drop-non-rcu-allocation.patch
* ipc-sem-do-not-use-ipc_rcu_free.patch
* ipc-shm-do-not-use-ipc_rcu_free.patch
* ipc-msg-do-not-use-ipc_rcu_free.patch
* ipc-util-drop-ipc_rcu_free.patch
* ipc-sem-avoid-ipc_rcu_alloc.patch
* ipc-shm-avoid-ipc_rcu_alloc.patch
* ipc-msg-avoid-ipc_rcu_alloc.patch
* ipc-util-drop-ipc_rcu_alloc.patch
* ipc-semc-avoid-ipc_rcu_putref-for-failed-ipc_addid.patch
* ipc-shmc-avoid-ipc_rcu_putref-for-failed-ipc_addid.patch
* ipc-msgc-avoid-ipc_rcu_putref-for-failed-ipc_addid.patch
* ipc-move-atomic_set-to-where-it-is-needed.patch
* ipc-shm-remove-special-shm_alloc-free.patch
* ipc-msg-remove-special-msg_alloc-free.patch
* ipc-sem-drop-__sem_free.patch
* ipc-utilh-update-documentation-for-ipc_getref-and-ipc_putref.patch
  linux-next.patch
  linux-next-git-rejects.patch
* netfilter-use-kvmalloc-xt_alloc_table_info.patch
* sparc64-ng4-memset-32-bits-overflow.patch
* xtensa-use-generic-fbh.patch
* lib-crc-ccitt-add-ccitt-false-crc16-variant.patch
  mm-add-strictlimit-knob-v2.patch
  make-sure-nobodys-leaking-resources.patch
  releasing-resources-with-children.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  mutex-subsystem-synchro-test-module.patch
  slab-leaks3-default-y.patch
  workaround-for-a-pci-restoring-bug.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
