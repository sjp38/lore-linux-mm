Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 911AF6B026E
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 18:53:24 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z72so1299220wrc.11
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 15:53:24 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 92si1502518edn.391.2017.10.13.15.53.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Oct 2017 15:53:22 -0700 (PDT)
Date: Fri, 13 Oct 2017 15:53:19 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2017-10-13-15-52 uploaded
Message-ID: <59e143df.vNA5wmejtzbnuyje%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2017-10-13-15-52 has been uploaded to

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


This mmotm tree contains the following patches against 4.14-rc4:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
* mm-migrate-fix-indexing-bug-off-by-one-and-avoid-out-of-bound-access.patch
* kernel-hacking-menu-runtime-testing-keep-tests-together.patch
* mm-madvise-add-description-for-madv_wipeonfork-and-madv_keeponfork.patch
* of-provide-of_n_addrsize_cells-wrappers-for-config_of.patch
* mm-mempolicy-fix-numa_interleave_hit-counter.patch
* mm-remove-unnecessary-warn_once-in-page_vma_mapped_walk.patch
* mm-only-dispaly-online-cpus-of-the-numa-node.patch
* userfaultfd-selftest-exercise-eexist-only-in-background-transfer.patch
* scripts-kallsyms-ignore-symbol-type-n.patch
* cma-take-__gfp_nowarn-into-account-in-cma_alloc.patch
* revert-vmalloc-back-off-when-the-current-task-is-killed.patch
* tty-fall-back-to-n_null-if-switching-to-n_tty-fails-during-hangup.patch
* linux-kernelh-add-correct-kernel-doc-notation.patch
* fix-mpage_writepage-for-pages-with-buffers.patch
* binfmt_misc-node-could-be-null-when-evicting-inode.patch
* kmemleak-clear-stale-pointers-from-task-stacks.patch
* mm-page_vma_mapped-ensure-pmd-is-loaded-with-read_once-outside-of-lock.patch
* mm-swap-use-page-cluster-as-max-window-of-vma-based-swap-readahead.patch
* scripts-decodecode-fix-decoding-for-aarch64-arm64-instructions.patch
* mm-skip-hwpoisoned-pages-when-onlining-pages.patch
* dma-debug-fix-incorrect-pfn-calculation.patch
* mm-memory_hotplug-do-not-back-off-draining-pcp-free-pages-from-kworker-context.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* prctl-add-pr_et_pdeathsig_proc.patch
* bloat-o-meter-provide-3-different-arguments-for-data-function-and-all.patch
* bloat-o-meter-provide-3-different-arguments-for-data-function-and-all-v2.patch
* spellingtxt-add-unnecessary-typo-variants.patch
* ocfs2-remove-unused-function-ocfs2_publish_get_mount_state.patch
* ocfs2-no-need-flush-workqueue-before-destroying-it.patch
* ocfs2-cleanup-unused-func-declaration-and-assignment.patch
* ocfs2-get-rid-of-ocfs2_is_o2cb_active-function.patch
* ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called.patch
* ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called-fix.patch
* ocfs2-give-an-obvious-tip-for-dismatch-cluster-names.patch
* ocfs2-give-an-obvious-tip-for-dismatch-cluster-names-v2.patch
* ocfs2-move-some-definitions-to-header-file.patch
* ocfs2-fix-some-small-problems.patch
* ocfs2-add-kobject-for-online-file-check.patch
* ocfs2-add-duplicative-ino-number-check.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* dentry-fix-kmemcheck-splat-at-take_dentry_name_snapshot.patch
  mm.patch
* tools-slabinfo-add-u-option-to-show-unreclaimable-slabs-only.patch
* mm-slabinfo-dump-config_slabinfo.patch
* mm-slabinfo-dump-config_slabinfo-v11.patch
* mm-oom-show-unreclaimable-slab-info-when-unreclaimable-slabs-user-memory.patch
* mm-oom-show-unreclaimable-slab-info-when-unreclaimable-slabs-user-memory-v11.patch
* mm-slob-remove-an-unnecessary-check-for-__gfp_zero.patch
* include-linux-sched-mmh-uninline-mmdrop_async-etc.patch
* mm-add-kmalloc_array_node-and-kcalloc_node.patch
* block-use-kmalloc_array_node.patch
* ib-qib-use-kmalloc_array_node.patch
* ib-rdmavt-use-kmalloc_array_node.patch
* mm-mempool-use-kmalloc_array_node.patch
* rds-ib-use-kmalloc_array_node.patch
* mm-update-comments-for-struct-pagemapping.patch
* zram-set-bdi_cap_stable_writes-once.patch
* bdi-introduce-bdi_cap_synchronous_io.patch
* mm-swap-introduce-swp_synchronous_io.patch
* mm-swap-skip-swapcache-for-swapin-of-synchronous-device.patch
* mm-swap-skip-swapcache-only-if-swapped-page-has-no-other-reference.patch
* mm-swap-skip-swapcache-only-if-swapped-page-has-no-other-reference-checkpatch-fixes.patch
* mm-make-count-list_lru_one-nr_items-lockless.patch
* writeback-remove-unused-parameter-from-balance_dirty_pages.patch
* mm-memory_hotplug-do-not-fail-offlining-too-early.patch
* mm-memory_hotplug-remove-timeout-from-__offline_memory.patch
* mm-memblockc-make-the-index-explicit-argument-of-for_each_memblock_type.patch
* mm-print-a-warning-once-the-vm-dirtiness-settings-is-illogical.patch
* mm-sysctl-make-numa-stats-configurable.patch
* mm-sysctl-make-numa-stats-configurable-fix.patch
* mm-sysctl-make-numa-stats-configurable-fix-fix.patch
* mm-madvise-enable-soft-offline-of-hugetlb-pages-at-pud-level.patch
* zram-add-zstd-to-the-supported-algorithms-list.patch
* zram-remove-zlib-from-the-list-of-recommended-algorithms.patch
* mm-hugetlbfs-remove-the-redundant-enival-return-from-hugetlbfs_setattr.patch
* mm-hmm-constify-hmm_devmem_page_get_drvdata-parameter.patch
* mm-account-pud-page-tables.patch
* mm-account-pud-page-tables-fix.patch
* zsmalloc-calling-zs_map_object-from-irq-is-a-bug.patch
* mm-mmu_notifier-avoid-double-notification-when-it-is-useless.patch
* mm-mmu_notifier-avoid-double-notification-when-it-is-useless-checkpatch-fixes.patch
* mm-remove-unused-pgdat-inactive_ratio.patch
* mm-hugetlb-drop-hugepages_treat_as_movable-sysctl.patch
* mm-swap-fix-race-conditions-in-swap_slots-cache-init.patch
* mm-swap-fix-race-conditions-in-swap_slots-cache-init-fix.patch
* mm-swap-fix-race-conditions-in-swap_slots-cache-init-fix-fix.patch
* mm-arch-remove-empty_bad_page.patch
* mm-readahead-increase-maximum-readahead-window.patch
* cma-change-pr_info-to-pr_err-for-cma_alloc-fail-log.patch
* mm-reducing-page_owner-structure-size.patch
* mm-implement-find_get_pages_range_tag.patch
* btrfs-use-pagevec_lookup_range_tag.patch
* ceph-use-pagevec_lookup_range_tag.patch
* ext4-use-pagevec_lookup_range_tag.patch
* f2fs-use-pagevec_lookup_range_tag.patch
* f2fs-simplify-page-iteration-loops.patch
* f2fs-use-find_get_pages_tag-for-looking-up-single-page.patch
* gfs2-use-pagevec_lookup_range_tag.patch
* nilfs2-use-pagevec_lookup_range_tag.patch
* mm-use-pagevec_lookup_range_tag-in-__filemap_fdatawait_range.patch
* mm-use-pagevec_lookup_range_tag-in-write_cache_pages.patch
* mm-add-variant-of-pagevec_lookup_range_tag-taking-number-of-pages.patch
* ceph-use-pagevec_lookup_range_nr_tag.patch
* mm-remove-nr_pages-argument-from-pagevec_lookup_range_tag.patch
* afs-use-find_get_pages_range_tag.patch
* cifs-use-find_get_pages_range_tag.patch
* kmemleak-change-sys-kernel-debug-kmemleak-permissions-from-0444-to-0644.patch
* proc-do-not-show-vmexe-bigger-than-total-executable-virtual-memory.patch
* mm-introduce-wrappers-to-access-mm-nr_ptes.patch
* mm-consolidate-page-table-accounting.patch
* kvm-mm-account-kvm-related-kmem-slabs-to-kmemcg.patch
* fs-mm-account-filp-cache-to-kmemcg.patch
* mm-rmap-remove-redundant-variable-cend.patch
* kmemcheck-remove-annotations.patch
* kmemcheck-remove-annotations-fix.patch
* kmemcheck-stop-using-gfp_notrack-and-slab_notrack.patch
* kmemcheck-remove-whats-left-of-notrack-flags.patch
* kmemcheck-rip-it-out.patch
* mm-swap_statec-declare-a-few-variables-as-__read_mostly.patch
* mm-deferred_init_memmap-improvements.patch
* x86-mm-setting-fields-in-deferred-pages.patch
* sparc64-mm-setting-fields-in-deferred-pages.patch
* sparc64-simplify-vmemmap_populate.patch
* mm-defining-memblock_virt_alloc_try_nid_raw.patch
* mm-zero-reserved-and-unavailable-struct-pages.patch
* x86-kasan-add-and-use-kasan_map_populate.patch
* arm64-kasan-add-and-use-kasan_map_populate.patch
* mm-stop-zeroing-memory-during-allocation-in-vmemmap.patch
* sparc64-optimized-struct-page-zeroing.patch
* arm64-kasan-avoid-using-vmemmap_populate-to-initialise-shadow.patch
* mm-page_alloc-make-sure-__rmqueue-etc-always-inline.patch
* mm-compaction-kcompactd-should-not-ignore-pageblock-skip.patch
* mm-compaction-persistently-skip-hugetlbfs-pageblocks.patch
* mm-compaction-persistently-skip-hugetlbfs-pageblocks-fix.patch
* mm-page_alloc-return-0-in-case-this-node-has-no-page-within-the-zone.patch
* mm-vmscan-do-not-pass-reclaimed-slab-to-vmpressure.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* mm-walk-the-zone-in-pageblock_nr_pages-steps.patch
* proc-coredump-add-coredumping-flag-to-proc-pid-status.patch
* proc-coredump-add-coredumping-flag-to-proc-pid-status-fix.patch
* proc-uninline-name_to_int.patch
* proc-use-do-while-in-name_to_int.patch
* sh-boot-add-static-stack-protector-to-pre-kernel.patch
* makefile-move-stackprotector-availability-out-of-kconfig.patch
* makefile-introduce-config_cc_stackprotector_auto.patch
* makefile-introduce-config_cc_stackprotector_auto-fix.patch
* makefile-introduce-config_cc_stackprotector_auto-fix-2.patch
* parse-maintainers-add-ability-to-specify-filenames.patch
* bitfieldh-include-linux-build_bugh-instead-of-linux-bugh.patch
* radix-tree-remove-unneeded-include-linux-bugh.patch
* lib-add-module-support-to-string-tests.patch
* lib-test-delete-five-error-messages-for-a-failed-memory-allocation.patch
* checkpatch-support-function-pointers-for-unnamed-function-definition-arguments.patch
* scripts-checkpatchpl-avoid-false-warning-missing-break.patch
* checkpatch-printks-always-need-a-kern_level.patch
* epoll-account-epitem-and-eppoll_entry-to-kmemcg.patch
* epoll-avoid-calling-ep_call_nested-from-ep_poll_safewake.patch
* init-version-include-linux-exporth-instead-of-linux-moduleh.patch
* seq_file-delete-small-value-optimization.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* rapidio-idt_gen2-constify-rio_device_id.patch
* rapidio-idt_gen3-constify-rio_device_id.patch
* rapidio-idtcps-constify-rio_device_id.patch
* rapidio-tsi568-constify-rio_device_id.patch
* rapidio-tsi57x-constify-rio_device_id.patch
* rapidio-fix-resources-leak-in-error-handling-path-in-rio_dma_transfer.patch
* rapidio-fix-an-error-handling-in-rio_dma_transfer.patch
* uapi-fix-linux-sysctlh-userspace-compilation-errors.patch
* pid-replace-pid-bitmap-implementation-with-idr-api.patch
* pid-replace-pid-bitmap-implementation-with-idr-api-v6.patch
* pid-remove-pidhash.patch
* pid-remove-pidhash-v6.patch
* kernel-panic-add-taint_aux.patch
* kcov-remove-pointless-current-=-null-check.patch
* kcov-support-comparison-operands-collection.patch
* makefile-support-flag-fsanitizer-coverage=trace-cmp.patch
* kcov-update-documentation.patch
* kernel-reboot-add-devm_register_reboot_notifier.patch
* kernel-reboot-add-devm_register_reboot_notifier-fix.patch
* initramfs-fix-initramfs-rebuilds-w-compression-after-disabling.patch
* sysvipc-unteach-ids-next_id-for-checkpoint_restore.patch
* sysvipc-unteach-ids-next_id-for-checkpoint_restore-checkpatch-fixes.patch
* sysvipc-duplicate-lock-comments-wrt-ipc_addid.patch
* sysvipc-properly-name-ipc_addid-limit-parameter.patch
* sysvipc-make-get_maxid-o1-again.patch
* sysvipc-make-get_maxid-o1-again-checkpatch-fixes.patch
  linux-next.patch
  linux-next-rejects.patch
  linux-next-git-rejects.patch
* mm-add-infrastructure-for-get_user_pages_fast-benchmarking.patch
* iopoll-avoid-wint-in-bool-context-warning.patch
* maintainers-update-tpm-driver-infrastructure-changes.patch
* pcmcia-badge4-avoid-unused-function-warning.patch
* ia64-topology-remove-the-unused-parent_node-macro.patch
* sh-numa-remove-the-unused-parent_node-macro.patch
* sparc64-topology-remove-the-unused-parent_node-macro.patch
* tile-topology-remove-the-unused-parent_node-macro.patch
* asm-generic-numa-remove-the-unused-parent_node-macro.patch
* sparc64-ng4-memset-32-bits-overflow.patch
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
