Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5183E831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 17:19:26 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id q125so43224228pgq.8
        for <linux-mm@kvack.org>; Thu, 18 May 2017 14:19:26 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e20si6351193pfm.312.2017.05.18.14.19.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 May 2017 14:19:24 -0700 (PDT)
Date: Thu, 18 May 2017 14:19:22 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2017-05-18-14-18 uploaded
Message-ID: <591e0fda.vzk3711i/nFtEx7T%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2017-05-18-14-18 has been uploaded to

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


This mmotm tree contains the following patches against 4.12-rc1:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
* mm-skip-hwpoisoned-pages-when-onlining-pages.patch
* ksm-prevent-crash-after-write_protect_page-fails.patch
* maintainers-greybus-dev-list-is-members-only.patch
* include-linux-gfph-fix-___gfp_nolockdep-value.patch
* frv-declare-jiffies-to-be-located-in-the-data-section.patch
* mm-clarify-why-we-want-kmalloc-before-falling-backto-vmallock.patch
* mm-clarify-why-we-want-kmalloc-before-falling-backto-vmallock-checkpatch-fixes.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* mn10300-remove-wrapper-header-for-asm-deviceh.patch
* teach-initramfs_root_uid-and-initramfs_root_gid-that-1-means-current-user.patch
* clarify-help-text-that-compression-applies-to-ramfs-as-well-as-legacy-ramdisk.patch
* sh-intc-delete-an-error-message-for-a-failed-memory-allocation-in-add_virq_to_pirq.patch
* ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called.patch
* ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called-fix.patch
* ocfs2-dlm-optimization-of-code-while-free-dead-node-locks.patch
* ocfs2-dlm-optimization-of-code-while-free-dead-node-locks-checkpatch-fixes.patch
* ocfs2-give-an-obvious-tip-for-dismatch-cluster-names.patch
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
* zram-try-harder-to-store-user-data-on-compression-error.patch
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
* mm-memory_hotplug-do-not-associate-hotadded-memory-to-zones-until-online.patch
* mm-memory_hotplug-replace-for_device-by-want_memblock-in-arch_add_memory.patch
* mm-memory_hotplug-fix-the-section-mismatch-warning.patch
* mm-memory_hotplug-remove-unused-cruft-after-memory-hotplug-rework.patch
* exit-dont-include-unused-userfaultfd_kh.patch
* userfaultfd-drop-dead-code.patch
* mm-madvise-enable-softhard-offline-of-hugetlb-pages-at-pgd-level.patch
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
* mm-hugetlb-cleanup-arch_has_gigantic_page.patch
* powerpc-mm-hugetlb-add-support-for-1g-huge-pages.patch
* mm-page_alloc-mark-bad_range-and-meminit_pfn_in_nid-as-__maybe_unused.patch
* mm-drop-null-return-check-of-pte_offset_map_lock.patch
* mm-page_alloc-return-0-in-case-this-node-has-no-page-within-the-zone.patch
* mm-vmscan-do-not-pass-reclaimed-slab-to-vmpressure.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* mm-walk-the-zone-in-pageblock_nr_pages-steps.patch
* mm-kasan-use-kasan_zero_pud-for-p4d-table.patch
* mm-kasan-rename-xxx_is_zero-to-xxx_is_nonzero.patch
* frv-remove-wrapper-header-for-asm-deviceh.patch
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
* make-initramfs-honor-config_devtmpfs_mount.patch
* ipc-semc-remove-sem_base-embed-struct-sem.patch
* ipc-merge-ipc_rcu-and-kern_ipc_perm.patch
* include-linux-semh-correctly-document-sem_ctime.patch
  linux-next.patch
* sparc64-ng4-memset-32-bits-overflow.patch
* powerpc-sequoia-fix-nand-partitions-not-to-overlap.patch
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
