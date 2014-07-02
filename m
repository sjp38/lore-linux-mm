Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 102BB6B0035
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 18:08:22 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id ft15so12607575pdb.7
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 15:08:21 -0700 (PDT)
Received: from mail-pa0-f73.google.com (mail-pa0-f73.google.com [209.85.220.73])
        by mx.google.com with ESMTPS id dt16si378392pdb.108.2014.07.02.15.08.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 02 Jul 2014 15:08:20 -0700 (PDT)
Received: by mail-pa0-f73.google.com with SMTP id kq14so2024714pab.2
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 15:08:19 -0700 (PDT)
Date: Wed, 02 Jul 2014 15:08:19 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2014-07-02-15-07 uploaded
Message-ID: <53b482d3.gR7nYB/K7hPREviI%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz

The mm-of-the-moment snapshot 2014-07-02-15-07 has been uploaded to

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


This mmotm tree contains the following patches against 3.16-rc3:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  maintainers-akpm-maintenance.patch
* mm-page_alloc-fix-cma-area-initialisation-when-pageblock-max_order.patch
* slub-fix-off-by-one-in-number-of-slab-tests.patch
* autofs4-fix-false-positive-compile-error.patch
* tools-cpu-hotplug-fix-unexpected-operator-error.patch
* tools-memory-hotplug-fix-unexpected-operator-error.patch
* zram-revalidate-disk-after-capacity-change.patch
* msync-fix-incorrect-fstart-calculation.patch
* mm-vmscan-update-the-trace-vmscan-postprocesspl-for-event-vmscan-mm_vmscan_lru_isolate.patch
* hwpoison-fix-the-handling-path-of-the-victimized-page-frame-that-belong-to-non-lur.patch
* proc-stat-convert-to-single_open_size.patch
* fs-seq_file-fallback-to-vmalloc-allocation.patch
* tools-msgque-improve-error-handling-when-not-running-as-root.patch
* kernel-printk-printkc-revert-printk-enable-interrupts-before-calling-console_trylock_for_printk.patch
* shmem-fix-init_page_accessed-use-to-stop-pagelru-bug.patch
* revert-shmem-fix-faulting-into-a-hole-while-its-punched.patch
* shmem-fix-faulting-into-a-hole-while-its-punched-take-2.patch
* mm-fs-fix-pessimization-in-hole-punching-pagecache.patch
* x86mem-hotplug-pass-sync_global_pgds-a-correct-argument-in-remove_pagetable.patch
* x86mem-hotplug-modify-pgd-entry-when-removing-memory.patch
* x86-numa-setup_node_data-drop-dead-code-and-rename-function.patch
* x86-numa-setup_node_data-drop-dead-code-and-rename-function-checkpatch-fixes.patch
* kernel-auditfilterc-replace-countsize-kmalloc-by-kcalloc.patch
* fs-cifs-remove-obsolete-__constant.patch
* fs-cifs-filec-replace-countsize-kzalloc-by-kcalloc.patch
* fs-cifs-smb2filec-replace-countsize-kzalloc-by-kcalloc.patch
* kernel-posix-timersc-code-clean-up.patch
* kernel-posix-timersc-code-clean-up-checkpatch-fixes.patch
* input-route-kbd-leds-through-the-generic-leds-layer.patch
* input-route-kbd-leds-through-the-generic-leds-layer-fix.patch
* remove-cpu_subtype_sh7764.patch
* fs-squashfs-file_directc-replace-countsize-kmalloc-by-kmalloc_array.patch
* fs-squashfs-superc-logging-clean-up.patch
* drivers-net-irda-donauboe-convert-to-module_pci_driver.patch
* fs-ext4-fsyncc-generic_file_fsync-call-based-on-barrier-flag.patch
* ocfs2-correctly-check-the-return-value-of-ocfs2_search_extent_list.patch
* ocfs2-remove-convertion-of-total_backoff-in-dlm_join_domain.patch
* ocfs2-do-not-write-error-flag-to-user-structure-we-cannot-copy-from-to.patch
* ocfs2-free-inode-when-i_count-becomes-zero.patch
* ocfs2-free-inode-when-i_count-becomes-zero-checkpatch-fixes.patch
* ocfs2-o2net-dont-shutdown-connection-when-idle-timeout.patch
* ocfs2-o2net-set-tcp-user-timeout-to-max-value.patch
* ocfs2-quorum-add-a-log-for-node-not-fenced.patch
* ocfs2-call-ocfs2_journal_access_di-before-ocfs2_journal_dirty-in-ocfs2_write_end_nolock.patch
* fs-ocfs2-slot_mapc-replace-countsize-kzalloc-by-kcalloc.patch
* ocfs2-dlm-fix-race-between-dispatched_work-and-dlm_lockres_grab_inflight_worker.patch
* maintainers-update-ibm-serveraid-raid-info.patch
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
* memcg-cleanup-memcg_cache_params-refcnt-usage.patch
* memcg-destroy-kmem-caches-when-last-slab-is-freed.patch
* memcg-mark-caches-that-belong-to-offline-memcgs-as-dead.patch
* slub-dont-fail-kmem_cache_shrink-if-slab-placement-optimization-fails.patch
* slub-make-slab_free-non-preemptable.patch
* memcg-wait-for-kfrees-to-finish-before-destroying-cache.patch
* slub-make-dead-memcg-caches-discard-free-slabs-immediately.patch
* slub-kmem_cache_shrink-check-if-partial-list-is-empty-under-list_lock.patch
* slab-do-not-keep-free-objects-slabs-on-dead-memcg-caches.patch
* slab-set-free_limit-for-dead-caches-to-0.patch
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
* mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff.patch
* mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff-v2.patch
* mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff-v3.patch
* mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff-v3-fix.patch
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
* page-cgroup-trivial-cleanup.patch
* page-cgroup-get-rid-of-nr_pcg_flags.patch
* mm-mem-hotplug-replace-simple_strtoull-with-kstrtoull.patch
* memcg-remove-lookup_cgroup_page-prototype.patch
* mm-update-comments-for-get-set_pfnblock_flags_mask.patch
* mem-hotplug-improve-zone_movable_is_highmem-logic.patch
* mm-vmscan-remove-remains-of-kswapd-managed-zone-all_unreclaimable.patch
* mm-vmscan-rework-compaction-ready-signaling-in-direct-reclaim.patch
* mm-vmscan-remove-all_unreclaimable.patch
* mm-vmscan-move-swappiness-out-of-scan_control.patch
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
* mm-hugetlb-remove-hugetlb_zero-and-hugetlb_infinity.patch
* mm-make-copy_pte_range-static-again.patch
* mm-introduce-do_shared_fault-and-drop-do_fault-fix-fix.patch
* mm-compactionc-isolate_freepages_block-small-tuneup.patch
* fs-mpagec-forgotten-write_sync-in-case-of-data-integrity-write.patch
* m68k-call-find_vma-with-the-mmap_sem-held-in-sys_cacheflush.patch
* zram-rename-struct-table-to-zram_table_entry.patch
* zram-remove-unused-sector_size-define.patch
* zram-use-size_t-instead-of-u16.patch
* zram-remove-global-tb_lock-with-fine-grain-lock.patch
* mm-zswapc-add-__init-to-zswap_entry_cache_destroy.patch
* mm-zbud-zbud_alloc-minor-param-change.patch
* mm-zbud-change-zbud_alloc-size-type-to-size_t.patch
* mm-zpool-implement-common-zpool-api-to-zbud-zsmalloc.patch
* mm-zpool-implement-common-zpool-api-to-zbud-zsmalloc-fix.patch
* mm-zpool-zbud-zsmalloc-implement-zpool.patch
* mm-zpool-update-zswap-to-use-zpool.patch
* mm-zpool-update-zswap-to-use-zpool-fix.patch
* mm-zpool-prevent-zbud-zsmalloc-from-unloading-when-used.patch
* mm-zpool-prevent-zbud-zsmalloc-from-unloading-when-used-checkpatch-fixes.patch
* do_shared_fault-check-that-mmap_sem-is-held.patch
* include-kernelh-rewrite-min3-max3-and-clamp-using-min-and-max.patch
* include-kernelh-rewrite-min3-max3-and-clamp-using-min-and-max-fix.patch
* makefile-tell-gcc-optimizer-to-never-introduce-new-data-races.patch
* fs-asus_atk0110-fix-define_simple_attribute-semicolon-definition-and-use.patch
* drivers-misc-ti-st-st_corec-fix-null-dereference-on-protocol-type-check.patch
* printk-make-dynamic-kernel-ring-buffer-alignment-explicit.patch
* printk-move-power-of-2-practice-of-ring-buffer-size-to-a-helper.patch
* printk-make-dynamic-units-clear-for-the-kernel-ring-buffer.patch
* printk-allow-increasing-the-ring-buffer-depending-on-the-number-of-cpus.patch
* printk-allow-increasing-the-ring-buffer-depending-on-the-number-of-cpus-fix.patch
* printk-tweak-do_syslog-to-match-comments.patch
* lib-vsprintf-add-%pt-format-specifier.patch
* maintainers-remove-two-ancient-eata-sections.patch
* drivers-video-backlight-backlightc-remove-backlight-sysfs-uevent.patch
* list-use-argument-hlist_add_after-names-from-rcu-variant.patch
* list-fix-order-of-arguments-for-hlist_add_after_rcu.patch
* list-fix-order-of-arguments-for-hlist_add_after_rcu-checkpatch-fixes.patch
* klist-use-same-naming-scheme-as-hlist-for-klist_add_after.patch
* mm-utilc-add-kstrimdup.patch
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
* fs-efs-nameic-return-is-not-a-function.patch
* binfmt_elfc-use-get_random_int-to-fix-entropy-depleting.patch
* binfmt_elfc-use-get_random_int-to-fix-entropy-depleting-fix.patch
* fs-ramfs-file-nommuc-replace-countsize-kzalloc-by-kcalloc.patch
* init-make-rootdelay=n-consistent-with-rootwait-behaviour.patch
* kernel-test_kprobesc-use-current-logging-functions.patch
* rtc-add-support-of-nvram-for-maxim-dallas-rtc-ds1343.patch
* rtc-move-ds2404-entry-where-it-belongs.patch
* rtc-add-hardware-dependency-to-rtc-moxart.patch
* rtc-rtc-ds1742-revert-drivers-rtc-rtc-ds1742c-remove-redundant-of_match_ptr-helper.patch
* rtc-efi-check-for-invalid-data-coming-back-from-uefi.patch
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
* fs-reiserfs-replace-not-standard-%lu-%ld.patch
* fs-reiserfs-use-linux-uaccessh.patch
* fs-reiserfs-xattrc-fix-blank-line-missing-after-declarations.patch
* fs-hpfs-dnodec-fix-suspect-code-indent.patch
* fs-proc-kcorec-use-page_align-instead-of-alignpage_size.patch
* proc-constify-seq_operations.patch
* fork-exec-cleanup-mm-initialization.patch
* fork-reset-mm-pinned_vm.patch
* fork-copy-mms-vm-usage-counters-under-mmap_sem.patch
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
* kexec-load-and-relocate-purgatory-at-kernel-load-time.patch
* kexec-bzimage64-support-for-loading-bzimage-using-64bit-entry.patch
* kexec-bzimage64-support-for-loading-bzimage-using-64bit-entry-fix.patch
* kexec-support-for-kexec-on-panic-using-new-system-call.patch
* kexec-support-for-kexec-on-panic-using-new-system-call-fix.patch
* kexec-support-kexec-kdump-on-efi-systems.patch
* kexec-support-kexec-kdump-on-efi-systems-fix.patch
* lib-idr-fix-out-of-bounds-pointer-dereference.patch
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
* fs-romfs-superc-convert-printk-to-pr_foo.patch
* fs-romfs-superc-use-pr_fmt-in-logging.patch
* fs-romfs-superc-add-blank-line-after-declarations.patch
* fs-qnx6-convert-printk-to-pr_foo.patch
* fs-qnx6-use-pr_fmt-and-__func__-in-logging.patch
* fs-qnx6-update-debugging-to-current-functions.patch
* initrd-fix-lz4-decompress-with-initrd.patch
* initramfs-support-initrd-that-is-bigger-than-2gib.patch
* initramfs-support-initramfs-that-is-bigger-than-2gib.patch
* shm-make-exit_shm-work-proportional-to-task-activity.patch
* shm-allow-exit_shm-in-parallel-if-only-marking-orphans.patch
* shm-remove-unneeded-extern-for-function.patch
* lib-scatterlist-make-arch_has_sg_chain-an-actual-kconfig.patch
* lib-scatterlist-make-arch_has_sg_chain-an-actual-kconfig-fix.patch
* lib-scatterlist-make-arch_has_sg_chain-an-actual-kconfig-fix-2.patch
* lib-scatterlist-make-arch_has_sg_chain-an-actual-kconfig-fix-3.patch
* lib-scatterlist-clean-up-useless-architecture-versions-of-scatterlisth.patch
* scripts-coccinelle-free-add-null-test-before-freeing-functions.patch
* scripts-tagssh-include-compat_sys_-symbols-in-the-generated-tags.patch
* fs-dlm-debug_fsc-remove-unnecessary-null-test-before-debugfs_remove.patch
  linux-next.patch
* drivers-gpio-gpio-zevioc-fix-build.patch
* init-mainc-code-clean-up.patch
* arch-arm-mach-omap2-replace-strict_strto-with-kstrto.patch
* arch-arm-mach-pxa-replace-strict_strto-call-with-kstrto.patch
* arch-arm-mach-s3c24xx-mach-jivec-replace-strict_strto-with-kstrto.patch
* arch-arm-mach-w90x900-cpuc-replace-obsolete-strict_strto.patch
* arch-powerpc-replace-obsolete-strict_strto-calls.patch
* arch-x86-replace-strict_strto-calls.patch
* drivers-scsi-replace-strict_strto-calls.patch
* net-sunrpc-replace-strict_strto-calls.patch
* drivers-staging-emxx_udc-emxx_udcc-replace-strict_strto-with-kstrto.patch
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
* kernel-kprobesc-convert-printk-to-pr_foo.patch
* mm-replace-remap_file_pages-syscall-with-emulation.patch
* mm-replace-remap_file_pages-syscall-with-emulation-fix.patch
* mm-replace-remap_file_pages-syscall-with-emulation-fix-2.patch
* mm-replace-remap_file_pages-syscall-with-emulation-fix-3.patch
* memcg-deprecate-memoryforce_empty-knob.patch
* memcg-deprecate-memoryforce_empty-knob-fix.patch
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
