Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 705166B0037
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 19:00:00 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id eu11so443886pac.3
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 16:00:00 -0700 (PDT)
Received: from mail-pa0-f73.google.com (mail-pa0-f73.google.com [209.85.220.73])
        by mx.google.com with ESMTPS id uz1si450205pac.88.2014.07.22.15.59.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Jul 2014 15:59:59 -0700 (PDT)
Received: by mail-pa0-f73.google.com with SMTP id kx10so120987pab.4
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 15:59:59 -0700 (PDT)
Date: Tue, 22 Jul 2014 15:59:58 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2014-07-22-15-58 uploaded
Message-ID: <53ceecee.WqC+QfGnCB8K1WrF%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz

The mm-of-the-moment snapshot 2014-07-22-15-58 has been uploaded to

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


This mmotm tree contains the following patches against 3.16-rc6:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  maintainers-akpm-maintenance.patch
* coredump-fix-the-setting-of-pf_dumpcore.patch
* revert-fs-seq_file-fallback-to-vmalloc-allocation.patch
* rmap-fix-pgoff-calculation-to-handle-hugepage-correctly.patch
* zram-avoid-lockdep-splat-by-revalidate_disk.patch
* sh-also-try-passing-m4-nofpu-for-sh2a-builds.patch
* mm-do-not-call-do_fault_around-for-non-linear-fault.patch
* shmem-fix-faulting-into-a-hole-not-taking-i_mutex.patch
* shmem-fix-splicing-from-a-hole-while-its-punched.patch
* mm-fs-fix-pessimization-in-hole-punching-pagecache.patch
* simple_xattr-permit-0-size-extended-attributes.patch
* mm-hugetlb-fix-copy_hugetlb_page_range-re-new-copy_hugetlb_page_range-causing-crashes.patch
* mm-page-writebackc-fix-divide-by-zero-in-bdi_dirty_limits.patch
* x86mem-hotplug-pass-sync_global_pgds-a-correct-argument-in-remove_pagetable.patch
* x86mem-hotplug-modify-pgd-entry-when-removing-memory.patch
* x86-numa-setup_node_data-drop-dead-code-and-rename-function.patch
* x86-numa-setup_node_data-drop-dead-code-and-rename-function-v2.patch
* kernel-auditfilterc-replace-countsize-kmalloc-by-kcalloc.patch
* fs-cifs-remove-obsolete-__constant.patch
* fs-cifs-filec-replace-countsize-kzalloc-by-kcalloc.patch
* fs-cifs-smb2filec-replace-countsize-kzalloc-by-kcalloc.patch
* fs-fscache-make-ctl_table-static.patch
* input-route-kbd-leds-through-the-generic-leds-layer.patch
* input-route-kbd-leds-through-the-generic-leds-layer-fix.patch
* kbuild-explain-stack-protector-strong-config-logic.patch
* fs-logfs-readwritec-kernel-doc-warning-fixes.patch
* ntfs-kernel-doc-warning-fixes.patch
* score-ptrace-remove-the-macros-which-not-be-used-currently.patch
* remove-cpu_subtype_sh7764.patch
* arch-sh-mm-asids-debugfsc-use-ptr_err_or_zero.patch
* arch-sh-kernel-timec-use-ptr_err_or_zero.patch
* sh7724-clock-fixes.patch
* fs-squashfs-file_directc-replace-countsize-kmalloc-by-kmalloc_array.patch
* fs-squashfs-superc-logging-clean-up.patch
* drivers-net-irda-donauboe-convert-to-module_pci_driver.patch
* fs-ext4-fsyncc-generic_file_fsync-call-based-on-barrier-flag.patch
* ocfs2-correctly-check-the-return-value-of-ocfs2_search_extent_list.patch
* ocfs2-remove-convertion-of-total_backoff-in-dlm_join_domain.patch
* ocfs2-race-between-umount-and-unfinished-remastering-during-recovery.patch
* ocfs2-do-not-write-error-flag-to-user-structure-we-cannot-copy-from-to.patch
* ocfs2-free-inode-when-i_count-becomes-zero.patch
* ocfs2-free-inode-when-i_count-becomes-zero-checkpatch-fixes.patch
* ocfs2-o2net-dont-shutdown-connection-when-idle-timeout.patch
* ocfs2-o2net-set-tcp-user-timeout-to-max-value.patch
* ocfs2-quorum-add-a-log-for-node-not-fenced.patch
* ocfs2-call-ocfs2_journal_access_di-before-ocfs2_journal_dirty-in-ocfs2_write_end_nolock.patch
* fs-ocfs2-slot_mapc-replace-countsize-kzalloc-by-kcalloc.patch
* ocfs2-dlm-fix-race-between-dispatched_work-and-dlm_lockres_grab_inflight_worker.patch
* bio-integrity-remove-the-needless-fail-handle-of-bip_slab-creating.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* kernel-watchdogc-convert-printk-pr_warning-to-pr_foo.patch
  mm.patch
* mm-slabc-add-__init-to-init_lock_keys.patch
* slab-common-add-functions-for-kmem_cache_node-access.patch
* slab-common-add-functions-for-kmem_cache_node-access-fix.patch
* slub-use-new-node-functions.patch
* slub-use-new-node-functions-checkpatch-fixes.patch
* slub-use-new-node-functions-fix.patch
* slab-use-get_node-and-kmem_cache_node-functions.patch
* slab-use-get_node-and-kmem_cache_node-functions-fix.patch
* slab-use-get_node-and-kmem_cache_node-functions-fix-2.patch
* slab-use-get_node-and-kmem_cache_node-functions-fix-2-fix.patch
* mm-slabh-wrap-the-whole-file-with-guarding-macro.patch
* mm-slub-mark-resiliency_test-as-init-text.patch
* mm-slub-slub_debug=n-use-the-same-alloc-free-hooks-as-for-slub_debug=y.patch
* slab-add-unlikely-macro-to-help-compiler.patch
* slab-move-up-code-to-get-kmem_cache_node-in-free_block.patch
* slab-defer-slab_destroy-in-free_block.patch
* slab-defer-slab_destroy-in-free_block-v4.patch
* slab-factor-out-initialization-of-arracy-cache.patch
* slab-introduce-alien_cache.patch
* slab-use-the-lock-on-alien_cache-instead-of-the-lock-on-array_cache.patch
* slab-destroy-a-slab-without-holding-any-alien-cache-lock.patch
* slab-remove-a-useless-lockdep-annotation.patch
* slab-remove-bad_alien_magic.patch
* slab-change-int-to-size_t-for-representing-allocation-size.patch
* slub-reduce-duplicate-creation-on-the-first-object.patch
* mm-move-slab-related-stuff-from-utilc-to-slab_commonc.patch
* mm-trivial-comment-cleanup-in-slabc.patch
* mm-readaheadc-remove-unused-file_ra_state-from-count_history_pages.patch
* mm-memory_hotplugc-add-__meminit-to-grow_zone_span-grow_pgdat_span.patch
* mm-page_alloc-add-__meminit-to-alloc_pages_exact_nid.patch
* mm-page_allocc-unexport-alloc_pages_exact_nid.patch
* include-linux-memblockh-add-__init-to-memblock_set_bottom_up.patch
* vmalloc-use-rcu-list-iterator-to-reduce-vmap_area_lock-contention.patch
* mm-memoryc-use-entry-=-access_oncepte-in-handle_pte_fault.patch
* mem-hotplug-avoid-illegal-state-prefixed-with-legal-state-when-changing-state-of-memory_block.patch
* mem-hotplug-introduce-mmop_offline-to-replace-the-hard-coding-1.patch
* mm-page_alloc-simplify-drain_zone_pages-by-using-min.patch
* mm-internalh-use-nth_page.patch
* dma-cma-separate-core-cma-management-codes-from-dma-apis.patch
* dma-cma-support-alignment-constraint-on-cma-region.patch
* dma-cma-support-arbitrary-bitmap-granularity.patch
* dma-cma-support-arbitrary-bitmap-granularity-fix.patch
* cma-generalize-cma-reserved-area-management-functionality.patch
* cma-generalize-cma-reserved-area-management-functionality-fix.patch
* ppc-kvm-cma-use-general-cma-reserved-area-management-framework.patch
* ppc-kvm-cma-use-general-cma-reserved-area-management-framework-fix.patch
* mm-cma-clean-up-cma-allocation-error-path.patch
* mm-cma-change-cma_declare_contiguous-to-obey-coding-convention.patch
* mm-cma-clean-up-log-message.patch
* mm-thp-move-invariant-bug-check-out-of-loop-in-__split_huge_page_map.patch
* mm-thp-replace-smp_mb-after-atomic_add-by-smp_mb__after_atomic.patch
* mm-page-flags-clean-up-the-page-flag-test-set-clear-macros.patch
* mm-memcontrol-fold-mem_cgroup_do_charge.patch
* mm-memcontrol-rearrange-charging-fast-path.patch
* mm-memcontrol-reclaim-at-least-once-for-__gfp_noretry.patch
* mm-huge_memory-use-gfp_transhuge-when-charging-huge-pages.patch
* mm-memcontrol-retry-reclaim-for-oom-disabled-and-__gfp_nofail-charges.patch
* mm-memcontrol-remove-explicit-oom-parameter-in-charge-path.patch
* mm-memcontrol-simplify-move-precharge-function.patch
* mm-memcontrol-catch-root-bypass-in-move-precharge.patch
* mm-memcontrol-use-root_mem_cgroup-res_counter.patch
* mm-memcontrol-remove-ordering-between-pc-mem_cgroup-and-pagecgroupused.patch
* mm-memcontrol-do-not-acquire-page_cgroup-lock-for-kmem-pages.patch
* mm-memcontrol-rewrite-charge-api.patch
* mm-memcontrol-rewrite-charge-api-fix-3.patch
* mm-memcontrol-rewrite-uncharge-api.patch
* mm-memcontrol-rewrite-uncharge-api-fix-2.patch
* mm-memcontrol-rewrite-uncharge-api-fix-4.patch
* mm-memcontrol-rewrite-uncharge-api-fix-5.patch
* mm-memcontrol-rewrite-charge-api-fix-shmem_unuse.patch
* mm-memcontrol-rewrite-charge-api-fix-shmem_unuse-fix.patch
* mm-memcontrol-rewrite-uncharge-api-fix-uncharge-from-irq-context.patch
* mm-memcontrol-rewrite-uncharge-api-fix-double-migration-v2.patch
* mm-memcontrol-rewrite-uncharge-api-fix-migrate-before-re-mapping.patch
* mm-memcontrol-rewrite-charge-api-fix-hugetlb-charging.patch
* mm-memcontrol-rewrite-uncharge-api-fix-page-cache-migration.patch
* mm-memcontrol-use-page-lists-for-uncharge-batching.patch
* mm-memcontrol-use-page-lists-for-uncharge-batching-fix-hugetlb-page-lru.patch
* page-cgroup-trivial-cleanup.patch
* page-cgroup-get-rid-of-nr_pcg_flags.patch
* mm-mem-hotplug-replace-simple_strtoull-with-kstrtoull.patch
* memcg-remove-lookup_cgroup_page-prototype.patch
* mm-update-comments-for-get-set_pfnblock_flags_mask.patch
* mem-hotplug-improve-zone_movable_is_highmem-logic.patch
* mm-vmscan-remove-remains-of-kswapd-managed-zone-all_unreclaimable.patch
* mm-vmscan-rework-compaction-ready-signaling-in-direct-reclaim.patch
* mm-vmscan-rework-compaction-ready-signaling-in-direct-reclaim-fix.patch
* mm-vmscan-remove-all_unreclaimable.patch
* mm-vmscan-remove-all_unreclaimable-fix.patch
* mm-vmscan-move-swappiness-out-of-scan_control.patch
* mm-vmscan-clean-up-struct-scan_control-v2.patch
* tracing-tell-mm_migrate_pages-event-about-numa_misplaced.patch
* mm-update-the-description-for-madvise_remove.patch
* mm-vmallocc-add-a-schedule-point-to-vmalloc.patch
* mm-vmallocc-add-a-schedule-point-to-vmalloc-fix.patch
* mm-vmalloc-constify-allocation-mask.patch
* include-linux-mmdebugh-add-vm_warn_once.patch
* shmem-fix-double-uncharge-in-__shmem_file_setup.patch
* shmem-update-memory-reservation-on-truncate.patch
* mm-catch-memory-commitment-underflow.patch
* mm-catch-memory-commitment-underflow-fix.patch
* mm-export-nr_shmem-via-sysinfo2-si_meminfo-interfaces.patch
* mm-hwpoison-injectc-remove-unnecessary-null-test-before-debugfs_remove_recursive.patch
* mm-replace-init_page_accessed-by-__setpagereferenced.patch
* mmhugetlb-make-unmap_ref_private-return-void.patch
* mmhugetlb-simplify-error-handling-in-hugetlb_cow.patch
* hwpoison-fix-race-with-changing-page-during-offlining-v2.patch
* mm-hugetlb-generalize-writes-to-nr_hugepages.patch
* mm-hugetlb-generalize-writes-to-nr_hugepages-fix.patch
* mm-hugetlb-remove-hugetlb_zero-and-hugetlb_infinity.patch
* mm-make-copy_pte_range-static-again.patch
* mm-vmallocc-clean-up-map_vm_area-third-argument.patch
* mm-vmallocc-clean-up-map_vm_area-third-argument-v2.patch
* firmware-memmap-pass-the-correct-argument-to-firmware_map_find_entry_bootmem.patch
* dont-allocate-firmware_map_entry-of-same-memory-range.patch
* mm-dont-forget-to-set-softdirty-on-file-mapped-fault.patch
* mm-update-the-description-for-vm_total_pages.patch
* mm-vmscan-report-the-number-of-file-anon-pages-respectively.patch
* mm-pagemap-avoid-unnecessary-overhead-when-tracepoints-are-deactivated.patch
* mm-rearrange-zone-fields-into-read-only-page-alloc-statistics-and-page-reclaim-lines.patch
* mm-move-zone-pages_scanned-into-a-vmstat-counter.patch
* mm-vmscan-only-update-per-cpu-thresholds-for-online-cpu.patch
* mm-page_alloc-abort-fair-zone-allocation-policy-when-remotes-nodes-are-encountered.patch
* mm-page_alloc-reduce-cost-of-the-fair-zone-allocation-policy.patch
* describe-mmap_sem-rules-for-__lock_page_or_retry-and-callers.patch
* mm-remove-the-unused-gfp-arg-to-shmem_add_to_page_cache.patch
* vmstat-on-demand-vmstat-workers-v8.patch
* vmstat-on-demand-vmstat-workers-v8-fix.patch
* vmstat-on-demand-vmstat-workers-v8-do-not-open-code-alloc_cpumask_var.patch
* mm-thp-only-collapse-hugepages-to-nodes-with-affinity-for-zone_reclaim_mode.patch
* mm-writeback-prevent-race-when-calculating-dirty-limits.patch
* slub-remove-kmemcg-id-from-create_unique_id.patch
* slab-use-mem_cgroup_id-for-per-memcg-cache-naming.patch
* memcg-make-memcg_cache_id-static.patch
* memcg-add-pointer-to-owner-cache-to-memcg_cache_params.patch
* memcg-keep-all-children-of-each-root-cache-on-a-list.patch
* memcg-release-memcg_cache_id-on-css-offline.patch
* memory-hotplug-add-zone_for_memory-for-selecting-zone-for-new-memory.patch
* memory-hotplug-x86_64-suitable-memory-should-go-to-zone_movable.patch
* memory-hotplug-x86_32-suitable-memory-should-go-to-zone_movable.patch
* memory-hotplug-ia64-suitable-memory-should-go-to-zone_movable.patch
* memory-hotplug-ppc-suitable-memory-should-go-to-zone_movable.patch
* memory-hotplug-sh-suitable-memory-should-go-to-zone_movable.patch
* mm-introduce-do_shared_fault-and-drop-do_fault-fix-fix.patch
* mm-compactionc-isolate_freepages_block-small-tuneup.patch
* fs-mpagec-forgotten-write_sync-in-case-of-data-integrity-write.patch
* m68k-call-find_vma-with-the-mmap_sem-held-in-sys_cacheflush.patch
* zram-rename-struct-table-to-zram_table_entry.patch
* zram-remove-unused-sector_size-define.patch
* zram-use-size_t-instead-of-u16.patch
* zram-remove-global-tb_lock-with-fine-grain-lock.patch
* mm-zswapc-add-__init-to-zswap_entry_cache_destroy.patch
* mm-zbud-change-zbud_alloc-size-type-to-size_t.patch
* mm-zpool-implement-common-zpool-api-to-zbud-zsmalloc.patch
* mm-zpool-zbud-zsmalloc-implement-zpool.patch
* mm-zpool-update-zswap-to-use-zpool.patch
* do_shared_fault-check-that-mmap_sem-is-held.patch
* include-kernelh-rewrite-min3-max3-and-clamp-using-min-and-max.patch
* include-kernelh-rewrite-min3-max3-and-clamp-using-min-and-max-fix.patch
* makefile-tell-gcc-optimizer-to-never-introduce-new-data-races.patch
* fs-asus_atk0110-fix-define_simple_attribute-semicolon-definition-and-use.patch
* include-minor-comment-fix-in-generich.patch
* kernel-acct-fix-coding-style-warnings-and-errors.patch
* drivers-misc-ti-st-st_corec-fix-null-dereference-on-protocol-type-check.patch
* printk-make-dynamic-kernel-ring-buffer-alignment-explicit.patch
* printk-move-power-of-2-practice-of-ring-buffer-size-to-a-helper.patch
* printk-make-dynamic-units-clear-for-the-kernel-ring-buffer.patch
* printk-allow-increasing-the-ring-buffer-depending-on-the-number-of-cpus.patch
* printk-allow-increasing-the-ring-buffer-depending-on-the-number-of-cpus-fix.patch
* printk-tweak-do_syslog-to-match-comments.patch
* printk-rename-default_message_loglevel.patch
* printk-fix-some-comments.patch
* printk-use-a-clever-macro.patch
* printk-miscellaneous-cleanups.patch
* lib-vsprintf-add-%pt-format-specifier.patch
* drivers-video-backlight-backlightc-remove-backlight-sysfs-uevent.patch
* list-use-argument-hlist_add_after-names-from-rcu-variant.patch
* list-fix-order-of-arguments-for-hlist_add_after_rcu.patch
* list-fix-order-of-arguments-for-hlist_add_after_rcu-checkpatch-fixes.patch
* klist-use-same-naming-scheme-as-hlist-for-klist_add_after.patch
* zlib-cleanup-some-dead-code.patch
* add-lib-globc.patch
* add-lib-globc-fix.patch
* lib-globc-add-config_glob_selftest.patch
* libata-use-glob_match-from-lib-globc.patch
* lib-add-size-unit-t-p-e-to-memparse.patch
* lib-string_helpersc-constify-static-arrays.patch
* lib-test-kstrtoxc-use-array_size-instead-of-sizeof-sizeof.patch
* kernelh-remove-deprecated-pack_hex_byte.patch
* lib-list_sort_test-return-enomem-when-allocation-fails.patch
* lib-list_sort_test-add-extra-corruption-check.patch
* lib-list_sort_test-simplify-and-harden-cleanup.patch
* lib-list_sortc-limit-number-of-unused-cmp-callbacks.patch
* lib-list_sortc-convert-to-pr_foo.patch
* lib-list_sortc-convert-to-pr_foo-fix.patch
* lib-bitmap-make-nbits-parameter-of-bitmap_empty-unsigned.patch
* lib-bitmap-make-nbits-parameter-of-bitmap_full-unsigned.patch
* lib-bitmap-make-nbits-parameter-of-bitmap_equal-unsigned.patch
* lib-bitmap-make-nbits-parameter-of-bitmap_complement-unsigned.patch
* lib-bitmap-remove-unnecessary-mask-from-bitmap_complement.patch
* lib-bitmap-make-nbits-parameter-of-bitmap_andorxorandnot-unsigned.patch
* lib-bitmap-make-nbits-parameter-of-bitmap_intersects-unsigned.patch
* lib-bitmap-make-nbits-parameter-of-bitmap_subset-unsigned.patch
* lib-bitmap-make-nbits-parameter-of-bitmap_weight-unsigned.patch
* lib-bitmap-make-the-start-index-of-bitmap_set-unsigned.patch
* lib-bitmap-make-the-start-index-of-bitmap_clear-unsigned.patch
* lib-bitmap-simplify-bitmap_parselist.patch
* lib-bitmap-fix-typo-in-kerneldoc-for-bitmap_pos_to_ord.patch
* lib-bitmap-change-parameter-of-bitmap__region-to-unsigned.patch
* lib-bitmap-micro-optimize-bitmap_allocate_region.patch
* lib-bitmap-add-missing-mask-in-bitmap_shift_right.patch
* lib-bitmap-add-missing-mask-in-bitmap_and.patch
* lib-bitmap-add-missing-mask-in-bitmap_andnot.patch
* mm-utilc-add-kstrimdup.patch
* lib-add-crc64-ecma-module.patch
* fs-compatc-remove-unnecessary-test-on-unsigned-value.patch
* checkpatch-attempt-to-find-unnecessary-out-of-memory-messages.patch
* checkpatch-warn-on-unnecessary-else-after-return-or-break.patch
* checkpatch-fix-complex-macro-false-positive-for-escaped-constant-char.patch
* checkpatch-fix-function-pointers-in-blank-line-needed-after-declarations-test.patch
* checkpatch-ignore-email-headers-better.patch
* checkpatchpl-also-suggest-else-if-when-if-follows-brace.patch
* checkpatch-add-test-for-blank-lines-after-function-struct-union-enum.patch
* checkpatch-add-test-for-blank-lines-after-function-struct-union-enum-declarations.patch
* checkpatch-add-a-multiple-blank-lines-test.patch
* checkpatch-change-blank-line-after-declaration-type-to-line_spacing.patch
* checkpatch-quiet-kconfig-help-message-checking.patch
* checkpatch-warn-on-unnecessary-parentheses-around-references-of-foo-bar.patch
* checkpatch-allow-multiple-const-types.patch
* checkpatch-improve-no-space-after-cast-test.patch
* checkpatch-emit-fewer-kmalloc_array-kcalloc-conversion-warnings.patch
* checkpatch-add-test-for-commit-id-formatting-style-in-commit-log.patch
* checkpatch-emit-a-warning-on-file-add-move-delete.patch
* checkpatch-warn-on-break-after-goto-or-return-with-same-tab-indentation.patch
* checkpatch-add-an-index-variable-for-fixed-lines.patch
* checkpatch-add-ability-to-insert-and-delete-lines-to-patch-file.patch
* checkpatch-add-fix_insert_line-and-fix_delete_line-helpers.patch
* checkpatch-use-the-correct-indentation-for-which.patch
* checkpatch-add-fix-option-for-a-couple-open_brace-misuses.patch
* checkpatch-fix-brace-style-misuses-of-else-and-while.patch
* checkpatch-add-for_each-tests-to-indentation-and-brace-tests.patch
* checkpatch-add-short-int-to-c-variable-types.patch
* checkpatch-add-signed-generic-types.patch
* checkpatch-add-test-for-native-c90-types-in-unusual-order.patch
* checkpatch-fix-false-positive-missing_break-warnings-with-file.patch
* fs-efs-nameic-return-is-not-a-function.patch
* binfmt_elfc-use-get_random_int-to-fix-entropy-depleting.patch
* binfmt_elfc-use-get_random_int-to-fix-entropy-depleting-fix.patch
* printk-fix-%pb-when-theres-no-symbol-at-the-address.patch
* fs-ramfs-file-nommuc-replace-countsize-kzalloc-by-kcalloc.patch
* init-make-rootdelay=n-consistent-with-rootwait-behaviour.patch
* kernel-test_kprobesc-use-current-logging-functions.patch
* autofs4-remove-unused-autofs4_ispending.patch
* autofs4-remove-a-redundant-assignment.patch
* autofs4-dont-take-spinlock-when-not-needed-in-autofs4_lookup_expiring.patch
* autofs4-remove-some-unused-inline-functions.patch
* autofs4-comment-typo-remove-a-a-doubled-word.patch
* rtc-add-support-of-nvram-for-maxim-dallas-rtc-ds1343.patch
* rtc-move-ds2404-entry-where-it-belongs.patch
* rtc-add-hardware-dependency-to-rtc-moxart.patch
* rtc-rtc-ds1742-revert-drivers-rtc-rtc-ds1742c-remove-redundant-of_match_ptr-helper.patch
* rtc-efi-check-for-invalid-data-coming-back-from-uefi.patch
* drivers-rtc-interfacec-check-the-error-after-__rtc_read_time.patch
* rtc-ia64-allow-other-architectures-to-use-efi-rtc.patch
* rtc-rtc-pcf8563-introducing-readwrite_block_data.patch
* rtc-rtc-pcf8563-add-alarm-support.patch
* drivers-rtc-rtc-isl12022c-device-tree-support.patch
* rtc-add-pcf85063-support.patch
* rtc-add-pcf85063-support-fix.patch
* fs-isofs-logging-clean-up.patch
* fs-isofs-logging-clean-up-fix.patch
* fs-coda-use-linux-uaccessh.patch
* fs-nilfs2-superc-remove-unnecessary-test-on-unsigned-value.patch
* nilfs2-add-sys-fs-nilfs2-features-group.patch
* nilfs2-add-sys-fs-nilfs2-device-group.patch
* nilfs2-add-sys-fs-nilfs2-device-superblock-group.patch
* nilfs2-add-sys-fs-nilfs2-device-segctor-group.patch
* nilfs2-add-sys-fs-nilfs2-device-segments-group.patch
* nilfs2-add-sys-fs-nilfs2-device-checkpoints-group.patch
* nilfs2-add-sys-fs-nilfs2-device-mounted_snapshots-group.patch
* nilfs2-add-sys-fs-nilfs2-device-mounted_snapshots-snapshot-group.patch
* nilfs2-integrate-sysfs-support-into-driver.patch
* nilfs2-integrate-sysfs-support-into-driver-fix.patch
* hfsplus-fix-longname-handling.patch
* fs-ufs-convert-printk-to-pr_foo.patch
* fs-ufs-use-pr_fmt.patch
* fs-ufs-superc-use-__func__-in-logging.patch
* fs-ufs-superc-use-va_format-instead-of-buffer-vsnprintf.patch
* fs-ufs-convert-ufsd-printk-to-pr_debug.patch
* fs-ufs-inodec-kernel-doc-warning-fixes.patch
* fs-reiserfs-replace-not-standard-%lu-%ld.patch
* fs-reiserfs-use-linux-uaccessh.patch
* fs-reiserfs-xattrc-fix-blank-line-missing-after-declarations.patch
* fs-hpfs-dnodec-fix-suspect-code-indent.patch
* kernel-exit-fix-coding-style-warnings-and-errors.patch
* fs-proc-kcorec-use-page_align-instead-of-alignpage_size.patch
* proc-constify-seq_operations.patch
* proc-add-and-remove-proc-entry-create-checks.patch
* proc-faster-proc-pid-lookup.patch
* proc-make-proc_subdir_lock-static.patch
* proc-remove-proc_tty_ldisc-variable.patch
* proc-remove-proc_tty_ldisc-variable-fix.patch
* proc-more-const-char-pointers.patch
* proc-convert-proc-pid-auxv-to-seq_file-interface.patch
* proc-convert-proc-pid-limits-to-seq_file-interface.patch
* proc-convert-proc-pid-syscall-to-seq_file-interface.patch
* proc-convert-proc-pid-cmdline-to-seq_file-interface.patch
* proc-convert-proc-pid-wchan-to-seq_file-interface.patch
* proc-convert-proc-pid-schedstat-to-seq_file-interface.patch
* proc-convert-proc-pid-oom_score-to-seq_file-interface.patch
* proc-convert-proc-pid-io-to-seq_file-interface.patch
* proc-convert-proc-pid-hardwall-to-seq_file-interface.patch
* proc-remove-inf-macro.patch
* fork-exec-cleanup-mm-initialization.patch
* fork-reset-mm-pinned_vm.patch
* fork-copy-mms-vm-usage-counters-under-mmap_sem.patch
* fork-make-mm_init_owner-static.patch
* mmap_vmcore-skip-non-ram-pages-reported-by-hypervisors.patch
* mmap_vmcore-skip-non-ram-pages-reported-by-hypervisors-v4.patch
* mmap_vmcore-skip-non-ram-pages-reported-by-hypervisors-v4-fix.patch
* mmap_vmcore-skip-non-ram-pages-reported-by-hypervisors-v4-fix-fix.patch
* mmap_vmcore-skip-non-ram-pages-reported-by-hypervisors-v6.patch
* mmap_vmcore-skip-non-ram-pages-reported-by-hypervisors-v7.patch
* lib-idr-fix-out-of-bounds-pointer-dereference.patch
* rbtree-fix-typo-in-comment-of-__rb_insert.patch
* sysctl-remove-now-unused-typedef-ctl_table.patch
* sysctl-remove-now-unused-typedef-ctl_table-fix.patch
* fs-exofs-ore_raidc-replace-countsize-kzalloc-by-kcalloc.patch
* kernel-gcov-fsc-remove-unnecessary-null-test-before-debugfs_remove.patch
* fs-adfs-dir_fplusc-use-array_size-instead-of-sizeof-sizeof.patch
* fs-adfs-dir_fplusc-replace-countsize-kzalloc-by-kcalloc.patch
* adfs-add-__printf-verification-fix-format-argument-mismatches.patch
* fs-bfs-use-bfs-prefix-for-dump_imap.patch
* panic-add-taint_softlockup.patch
* panic-add-taint_softlockup-fix.patch
* drivers-parport-parport_ip32c-use-ptr_err_or_zero.patch
* fs-pstore-ram_corec-replace-countsize-kmalloc-by-kmalloc_array.patch
* fs-cachefiles-daemonc-remove-unnecessary-tests-on-unsigned-values.patch
* fs-cachefiles-bindc-remove-unnecessary-assertions.patch
* fs-omfs-inodec-replace-countsize-kzalloc-by-kcalloc.patch
* kfifo-use-bug_on.patch
* fs-cramfs-convert-printk-to-pr_foo.patch
* fs-cramfs-use-pr_fmt.patch
* fs-cramfs-code-clean-up.patch
* fs-cramfs-inodec-use-linux-uaccessh.patch
* fs-romfs-superc-convert-printk-to-pr_foo.patch
* fs-romfs-superc-use-pr_fmt-in-logging.patch
* fs-romfs-superc-add-blank-line-after-declarations.patch
* fs-qnx6-convert-printk-to-pr_foo.patch
* fs-qnx6-use-pr_fmt-and-__func__-in-logging.patch
* fs-qnx6-update-debugging-to-current-functions.patch
* initrd-fix-lz4-decompress-with-initrd.patch
* initramfs-support-initrd-that-is-bigger-than-2gib.patch
* initramfs-support-initramfs-that-is-bigger-than-2gib.patch
* add-error-checks-to-initramfs.patch
* shm-make-exit_shm-work-proportional-to-task-activity.patch
* shm-allow-exit_shm-in-parallel-if-only-marking-orphans.patch
* shm-remove-unneeded-extern-for-function.patch
* lib-scatterlist-make-arch_has_sg_chain-an-actual-kconfig.patch
* lib-scatterlist-make-arch_has_sg_chain-an-actual-kconfig-fix.patch
* lib-scatterlist-make-arch_has_sg_chain-an-actual-kconfig-fix-2.patch
* lib-scatterlist-make-arch_has_sg_chain-an-actual-kconfig-fix-3.patch
* lib-scatterlist-clean-up-useless-architecture-versions-of-scatterlisth.patch
* scripts-coccinelle-free-add-null-test-before-freeing-functions.patch
* scripts-coccinelle-free-ifnullfreecocci-add-copyright-information.patch
* scripts-tagssh-include-compat_sys_-symbols-in-the-generated-tags.patch
* scripts-checkstackpl-automatically-handle-32-bit-and-64-bit-mode-for-arch=x86.patch
* fs-dlm-debug_fsc-remove-unnecessary-null-test-before-debugfs_remove.patch
  linux-next.patch
  linux-next-git-rejects.patch
* drivers-gpio-gpio-zevioc-fix-build.patch
* drivers-infiniband-hw-cxgb4-devicec-fix-32-bit-builds.patch
* init-mainc-code-clean-up.patch
* update-roland-mcgraths-mail.patch
* maintainers-remove-two-ancient-eata-sections.patch
* maintainers-update-ibm-serveraid-raid-info.patch
* arch-arm-mach-omap2-replace-strict_strto-with-kstrto.patch
* arch-arm-mach-pxa-replace-strict_strto-call-with-kstrto.patch
* arch-arm-mach-s3c24xx-mach-jivec-replace-strict_strto-with-kstrto.patch
* arch-arm-mach-w90x900-cpuc-replace-obsolete-strict_strto.patch
* arch-powerpc-replace-obsolete-strict_strto-calls.patch
* arch-x86-replace-strict_strto-calls.patch
* drivers-scsi-replace-strict_strto-calls.patch
* include-linux-remove-strict_strto-definitions.patch
* pci-dma-compat-add-pci_zalloc_consistent-helper.patch
* atm-use-pci_zalloc_consistent.patch
* block-use-pci_zalloc_consistent.patch
* crypto-use-pci_zalloc_consistent.patch
* infiniband-use-pci_zalloc_consistent.patch
* i810-use-pci_zalloc_consistent.patch
* media-use-pci_zalloc_consistent.patch
* amd-use-pci_zalloc_consistent.patch
* atl1e-use-pci_zalloc_consistent.patch
* enic-use-pci_zalloc_consistent.patch
* sky2-use-pci_zalloc_consistent.patch
* micrel-use-pci_zalloc_consistent.patch
* qlogic-use-pci_zalloc_consistent.patch
* irda-use-pci_zalloc_consistent.patch
* ipw2100-use-pci_zalloc_consistent.patch
* mwl8k-use-pci_zalloc_consistent.patch
* rtl818x-use-pci_zalloc_consistent.patch
* rtlwifi-use-pci_zalloc_consistent.patch
* scsi-use-pci_zalloc_consistent.patch
* staging-use-pci_zalloc_consistent.patch
* synclink_gt-use-pci_zalloc_consistent.patch
* vme-bridges-use-pci_zalloc_consistent.patch
* amd-neaten-and-remove-unnecessary-oom-messages.patch
* kernel-posix-timersc-code-clean-up.patch
* kernel-posix-timersc-code-clean-up-checkpatch-fixes.patch
* maintainers-update-microcode-patterns.patch
* maintainers-update-cifs-location.patch
* maintainers-use-the-correct-efi-stub-location.patch
* maintainers-update-clk-sirf-patterns.patch
* maintainers-fix-ssbi-pattern.patch
* maintainers-use-correct-filename-for-sdhci-bcm-kona.patch
* maintainers-fix-pxa3xx-nand-flash-driver-pattern.patch
* maintainers-update-picoxcell-patterns.patch
* maintainers-remove-section-cirrus-logic-ep93xx-ohci-usb-host-driver.patch
* maintainers-remove-metag-imgdafs-pattern.patch
* maintainers-remove-unused-radeon-drm-pattern.patch
* maintainers-remove-unusd-arm-qualcomm-msm-pattern.patch
* maintainers-remove-unused-nfsd-pattern.patch
* bin2c-move-bin2c-in-scripts-basic.patch
* kernel-build-bin2c-based-on-config-option-config_build_bin2c.patch
* kexec-rename-unusebale_pages-to-unusable_pages.patch
* kexec-move-segment-verification-code-in-a-separate-function.patch
* kexec-use-common-function-for-kimage_normal_alloc-and-kimage_crash_alloc.patch
* resource-provide-new-functions-to-walk-through-resources.patch
* kexec-make-kexec_segment-user-buffer-pointer-a-union.patch
* kexec-new-syscall-kexec_file_load-declaration.patch
* kexec-implementation-of-new-syscall-kexec_file_load.patch
* kexec-implementation-of-new-syscall-kexec_file_load-checkpatch-fixes.patch
* kexec-implementation-of-new-syscall-kexec_file_load-fix.patch
* purgatory-sha256-provide-implementation-of-sha256-in-purgaotory-context.patch
* purgatory-core-purgatory-functionality.patch
* purgatory-core-purgatory-functionality-fix.patch
* kexec-load-and-relocate-purgatory-at-kernel-load-time.patch
* kexec-load-and-relocate-purgatory-at-kernel-load-time-fix.patch
* kexec-bzimage64-support-for-loading-bzimage-using-64bit-entry.patch
* kexec-bzimage64-support-for-loading-bzimage-using-64bit-entry-fix.patch
* kexec-support-for-kexec-on-panic-using-new-system-call.patch
* kexec-support-for-kexec-on-panic-using-new-system-call-fix.patch
* kexec-support-kexec-kdump-on-efi-systems.patch
* kexec-support-kexec-kdump-on-efi-systems-fix.patch
* fsh-remove-unnecessary-extern-prototypes.patch
* fsh-whitespace-neatening.patch
* fsh-a-few-more-whitespace-neatenings.patch
* fsh-add-argument-names-to-struct-file_lock_operations-funcs.patch
* fsh-add-member-argument-descriptions-to-lock_manager_operations.patch
* dlm-plock-add-argument-descriptions-to-notify.patch
* dlm-fs-remove-unused-conf-from-lm_grant.patch
* dlm-plock-reduce-indentation-by-rearranging-order.patch
* fs-dlm-lockd-convert-int-result-to-unsigned-char-type.patch
* kernel-kprobesc-convert-printk-to-pr_foo.patch
* mm-replace-remap_file_pages-syscall-with-emulation.patch
* mm-replace-remap_file_pages-syscall-with-emulation-fix.patch
* mm-replace-remap_file_pages-syscall-with-emulation-fix-2.patch
* mm-replace-remap_file_pages-syscall-with-emulation-fix-3.patch
* fat-add-i_disksize-to-represent-uninitialized-size-v4.patch
* fat-add-fat_fallocate-operation-v4.patch
* fat-zero-out-seek-range-on-_fat_get_block-v4.patch
* fat-fallback-to-buffered-write-in-case-of-fallocated-region-on-direct-io-v4.patch
* fat-permit-to-return-phy-block-number-by-fibmap-in-fallocated-region-v4.patch
* documentation-filesystems-vfattxt-update-the-limitation-for-fat-fallocate-v4.patch
* w1-call-put_device-if-device_register-fails.patch
* mm-add-strictlimit-knob-v2.patch
  debugging-keep-track-of-page-owners.patch
  page-owners-correct-page-order-when-to-free-page.patch
  make-sure-nobodys-leaking-resources.patch
  journal_add_journal_head-debug.patch
  journal_add_journal_head-debug-fix.patch
  releasing-resources-with-children.patch
  make-frame_pointer-default=y.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  mutex-subsystem-synchro-test-module.patch
  slab-leaks3-default-y.patch
  put_bh-debug.patch
  add-debugging-aid-for-memory-initialisation-problems.patch
  workaround-for-a-pci-restoring-bug.patch
  single_open-seq_release-leak-diagnostics.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
