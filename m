Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7FC326B0292
	for <linux-mm@kvack.org>; Thu, 25 May 2017 20:28:50 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c10so249094332pfg.10
        for <linux-mm@kvack.org>; Thu, 25 May 2017 17:28:50 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t64si29205580pfg.350.2017.05.25.17.28.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 May 2017 17:28:49 -0700 (PDT)
Date: Thu, 25 May 2017 17:28:46 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2017-05-25-17-28 uploaded
Message-ID: <592776be.DReAO8hNs7HUKfxe%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2017-05-25-17-28 has been uploaded to

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


This mmotm tree contains the following patches against 4.12-rc2:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
* mm-skip-hwpoisoned-pages-when-onlining-pages.patch
* ksm-prevent-crash-after-write_protect_page-fails.patch
* include-linux-gfph-fix-___gfp_nolockdep-value.patch
* frv-declare-jiffies-to-be-located-in-the-data-section.patch
* mm-clarify-why-we-want-kmalloc-before-falling-backto-vmallock.patch
* mm-clarify-why-we-want-kmalloc-before-falling-backto-vmallock-checkpatch-fixes.patch
* initramfs-fix-disabling-of-initramfs-and-its-compression.patch
* slub-memcg-cure-the-brainless-abuse-of-sysfs-attributes.patch
* pcmcia-remove-left-over-%z-format.patch
* mmpage_alloc-make-sure-oom-victim-can-try-allocations-with-no-watermarks-once.patch
* mm-avoid-spurious-bad-pmd-warning-messages.patch
* dax-fix-race-between-colliding-pmd-pte-entries.patch
* mm-migrate-fix-ref-count-handling-when-hugepage_migration_supported-v2.patch
* mlock-fix-mlock-count-can-not-decrease-in-race-condition.patch
* mm-hugetlb-report-ehwpoison-not-efault-when-foll_hwpoison-is-specified.patch
* mm-hugetlb-report-ehwpoison-not-efault-when-foll_hwpoison-is-specified-checkpatch-fixes.patch
* mm-hugetlb-report-ehwpoison-not-efault-when-foll_hwpoison-is-specified-v2.patch
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
  mm.patch
* mm-slub-remove-a-redundant-assignment-in-___slab_alloc.patch
* mm-slub-reset-cpu_slabs-pointer-in-deactivate_slab.patch
* mm-slub-pack-red_left_pad-with-another-int-to-save-a-word.patch
* mm-slub-wrap-cpu_slab-partial-in-config_slub_cpu_partial.patch
* mm-slub-wrap-cpu_slab-partial-in-config_slub_cpu_partial-fix.patch
* mm-slub-wrap-kmem_cache-cpu_partial-in-config-config_slub_cpu_partial.patch
* mm-sparsemem-break-out-of-loops-early.patch
* mark-protection_map-as-__ro_after_init.patch
* mm-vmscan-fix-unsequenced-modification-and-access-warning.patch
* mm-nobootmem-return-0-when-start_pfn-equals-end_pfn.patch
* ksm-introduce-ksm_max_page_sharing-per-page-deduplication-limit.patch
* ksm-fix-use-after-free-with-merge_across_nodes-=-0.patch
* ksm-cleanup-stable_node-chain-collapse-case.patch
* ksm-swap-the-two-output-parameters-of-chain-chain_prune.patch
* ksm-optimize-refile-of-stable_node_dup-at-the-head-of-the-chain.patch
* zram-introduce-zram_entry-to-prepare-dedup-functionality.patch
* zram-implement-deduplication-in-zram.patch
* zram-make-deduplication-feature-optional.patch
* zram-compare-all-the-entries-with-same-checksum-for-deduplication.patch
* zram-count-same-page-write-as-page_stored.patch
* zram-do-not-count-duplicated-pages-as-compressed.patch
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
* mm-make-kswapd-try-harder-to-keep-active-pages-in-cache.patch
* mm-make-kswapd-try-harder-to-keep-active-pages-in-cache-fix.patch
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
* mm-fix-mapping_set_error-call-in-me_pagecache_dirty.patch
* mm-per-cgroup-memory-reclaim-stats.patch
* mm-oom_kill-count-global-and-memory-cgroup-oom-kills.patch
* mm-oom_kill-count-global-and-memory-cgroup-oom-kills-fix.patch
* mm-swap-sort-swap-entries-before-free.patch
* mm-swap-sort-swap-entries-before-free-fix.patch
* zswap-delete-an-error-message-for-a-failed-memory-allocation-in-zswap_pool_create.patch
* zswap-improve-a-size-determination-in-zswap_frontswap_init.patch
* zswap-delete-an-error-message-for-a-failed-memory-allocation-in-zswap_dstmem_prepare.patch
* mm-page_alloc-return-0-in-case-this-node-has-no-page-within-the-zone.patch
* mm-vmscan-do-not-pass-reclaimed-slab-to-vmpressure.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* mm-walk-the-zone-in-pageblock_nr_pages-steps.patch
* mm-kasan-use-kasan_zero_pud-for-p4d-table.patch
* mm-kasan-rename-xxx_is_zero-to-xxx_is_nonzero.patch
* frv-remove-wrapper-header-for-asm-deviceh.patch
* frv-use-generic-fbh.patch
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
* maintainers-give-proc-sysctl-some-maintainer-love.patch
* kstrtox-delete-end-of-string-test.patch
* kstrtox-use-unsigned-int-more.patch
* lib-interval_tree_test-allow-the-module-to-be-compiled-in.patch
* lib-interval_tree_test-make-test-options-module-parameters.patch
* lib-interval_tree_test-allow-users-to-limit-scope-of-endpoint.patch
* lib-interval_tree_test-allow-full-tree-search.patch
* fs-epoll-short-circuit-fetching-events-if-thread-has-been-killed.patch
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
* uapi-fix-linux-sysctlh-userspace-compilation-errors.patch
* bfs-fix-sanity-checks-for-empty-files.patch
* fs-kill-config_percpu_rwsem-some-more.patch
* scripts-gdb-add-lx-fdtdump-command.patch
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
* sparc64-ng4-memset-32-bits-overflow.patch
* powerpc-sequoia-fix-nand-partitions-not-to-overlap.patch
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
