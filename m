Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id B27286B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 20:08:48 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z1so10489954wre.6
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 17:08:48 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d17si10772486wmh.252.2017.10.03.17.08.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Oct 2017 17:08:47 -0700 (PDT)
Date: Tue, 03 Oct 2017 17:08:44 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2017-10-03-17-08 uploaded
Message-ID: <59d4268c.FlFtK0Mqe7TSSBd5%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2017-10-03-17-08 has been uploaded to

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


This mmotm tree contains the following patches against 4.14-rc3:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
* alpha-fix-build-failures.patch
* params-align-add_sysfs_param-documentation-with-code.patch
* scripts-spellingtxt-add-more-spelling-mistakes-to-spellingtxt.patch
* mm-fix-typo-in-vm_mpx-definition.patch
* ksm-fix-unlocked-iteration-over-vmas-in-cmp_and_merge_page.patch
* mm-hugetlb-soft_offline-save-compound-page-order-before-page-migration.patch
* sh-sh7722-remove-nonexistent-gpio_ptq7-to-fix-pinctrl-registration.patch
* sh-sh7757-remove-nonexistent-gpio_pt7_resv-to-fix-pinctrl-registration.patch
* sh-sh7264-remove-nonexistent-gpio_ph-to-fix-pinctrl-registration.patch
* sh-sh7269-remove-nonexistent-gpio_ph-to-fix-pinctrl-registration.patch
* z3fold-fix-potential-race-in-z3fold_reclaim_page.patch
* mm-oom_reaper-skip-mm-structs-with-mmu-notifiers.patch
* mm-memcg-remove-hotplug-locking-from-try_charge.patch
* mm-memcg-avoid-page-count-check-for-zone-device.patch
* android-binder-drop-lru-lock-in-isolate-callback.patch
* mmcompaction-serialize-waitqueue_active-checks-for-real.patch
* z3fold-fix-stale-list-handling.patch
* mm-meminit-mark-init_reserved_page-as-__meminit.patch
* rapidio-remove-global-irq-spinlocks-from-the-subsystem.patch
* mm-fix-rodata_test-failure-rodata_test-test-data-was-not-read-only.patch
* zram-fix-null-dereference-of-handle.patch
* m32r-define-cpu_big_endian.patch
* mm-have-filemap_check_and_advance_wb_err-clear-as_eio-as_enospc.patch
* mm-avoid-marking-swap-cached-page-as-lazyfree.patch
* mm-fix-data-corruption-caused-by-lazyfree-page.patch
* mm-device-public-memory-fix-edge-case-in-_vm_normal_page.patch
* userfaultfd-non-cooperative-fix-fork-use-after-free.patch
* exec-load_script-kill-the-onstack-interp-array.patch
* exec-binfmt_misc-dont-nullify-node-dentry-in-kill_node.patch
* exec-binfmt_misc-shift-filp_closeinterp_file-from-kill_node-to-bm_evict_inode.patch
* exec-binfmt_misc-remove-the-confusing-e-interp_file-=-null-checks.patch
* exec-binfmt_misc-fix-race-between-load_misc_binary-and-kill_node.patch
* exec-binfmt_misc-kill-the-onstack-iname-array.patch
* lib-lz4-make-arrays-static-const-reduces-object-code-size.patch
* bitfieldh-remove-32bit-from-field_get-comment-block.patch
* sysctl-remove-duplicate-uint_max-check-on-do_proc_douintvec_conv.patch
* mm-memcontrol-use-vmalloc-fallback-for-large-kmem-memcg-arrays.patch
* idr-fix-comment-for-idr_replace.patch
* mm-memory_hotplug-add-scheduling-point-to-__add_pages.patch
* mm-page_alloc-add-scheduling-point-to-memmap_init_zone.patch
* memremap-add-scheduling-point-to-devm_memremap_pages.patch
* kcmp-drop-branch-leftover-typo.patch
* mm-memory_hotplug-change-pfn_to_section_nr-section_nr_to_pfn-macro-to-inline-function.patch
* mm-memory_hotplug-define-find_smallestbiggest_section_pfn-as-unsigned-long.patch
* params-fix-the-maximum-length-in-param_get_string.patch
* params-fix-an-overflow-in-param_attr_show.patch
* params-improve-standard_param_def-readability.patch
* ratelimit-use-deferred-printk-version.patch
* m32r-fix-build-failure.patch
* checkpatch-fix-ignoring-cover-letter-logic.patch
* include-linux-fsh-fix-comment-about-struct-address_space.patch
* scripts-decodecode-fix-decoding-for-aarch64-arm64-instructions.patch
* mm-skip-hwpoisoned-pages-when-onlining-pages.patch
* mm-migrate-fix-indexing-bug-off-by-one-and-avoid-out-of-bound-access.patch
* kernel-hacking-menu-runtime-testing-keep-tests-together.patch
* mm-madvise-add-description-for-madv_wipeonfork-and-madv_keeponfork.patch
* of-provide-of_n_addrsize_cells-wrappers-for-config_of.patch
* of-provide-of_n_addrsize_cells-wrappers-for-config_of-fix.patch
* mm-mempolicy-fix-numa_interleave_hit-counter.patch
* mm-remove-unnecessary-warn_once-in-page_vma_mapped_walk.patch
* mm-only-dispaly-online-cpus-of-the-numa-node.patch
* dma-debug-fix-incorrect-pfn-calculation.patch
* mm-memory_hotplug-do-not-back-off-draining-pcp-free-pages-from-kworker-context.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* dax-quiet-bdev_dax_supported.patch
* dax-disable-filesystem-dax-on-devices-that-do-not-map-pages.patch
* dax-stop-using-vm_mixedmap-for-dax.patch
* dax-stop-using-vm_mixedmap-for-dax-fix.patch
* dax-stop-using-vm_hugepage-for-dax.patch
* prctl-add-pr_et_pdeathsig_proc.patch
* bloat-o-meter-provide-3-different-arguments-for-data-function-and-all.patch
* bloat-o-meter-provide-3-different-arguments-for-data-function-and-all-v2.patch
* spellingtxt-add-unnecessary-typo-variants.patch
* ocfs2-remove-unused-function-ocfs2_publish_get_mount_state.patch
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
* zsmalloc-calling-zs_map_object-from-irq-is-a-bug.patch
* mm-mmu_notifier-avoid-double-notification-when-it-is-useless.patch
* mm-mmu_notifier-avoid-double-notification-when-it-is-useless-checkpatch-fixes.patch
* mm-remove-unused-pgdat-inactive_ratio.patch
* mm-hugetlb-drop-hugepages_treat_as_movable-sysctl.patch
* mm-swap-fix-race-conditions-in-swap_slots-cache-init.patch
* mm-swap-fix-race-conditions-in-swap_slots-cache-init-fix.patch
* mm-swap-fix-race-conditions-in-swap_slots-cache-init-fix-fix.patch
* mm-swap-remove-lock_initialized-flag-from-swap_slots_cache.patch
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
* parse-maintainers-add-ability-to-specify-filenames.patch
* bitfieldh-include-linux-build_bugh-instead-of-linux-bugh.patch
* radix-tree-remove-unneeded-include-linux-bugh.patch
* lib-add-module-support-to-string-tests.patch
* checkpatch-support-function-pointers-for-unnamed-function-definition-arguments.patch
* scripts-checkpatchpl-avoid-false-warning-missing-break.patch
* checkpatch-printks-always-need-a-kern_level.patch
* epoll-account-epitem-and-eppoll_entry-to-kmemcg.patch
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
* pid-delete-reserved_pids.patch
* pid-delete-struct-pidmap-nr_free.patch
* kernel-panic-add-taint_aux.patch
* kcov-remove-pointless-current-=-null-check.patch
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
