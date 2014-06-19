Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id D62EF6B0035
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 19:34:50 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so2300205pdj.22
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 16:34:50 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id rn1si7403968pbc.172.2014.06.19.16.34.27
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 16:34:28 -0700 (PDT)
Date: Thu, 19 Jun 2014 16:34:26 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2014-06-19-16-33 uploaded
Message-ID: <53a37382.lV+82Dvr0NcrbYia%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, sfr@canb.auug.org.au, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org

The mm-of-the-moment snapshot 2014-06-19-16-33 has been uploaded to

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


This mmotm tree contains the following patches against 3.16-rc1:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  maintainers-akpm-maintenance.patch
  checkpatch-check-git-commit-descriptions.patch
* mm-nommu-per-thread-vma-cache-fix.patch
* cpu-hotplug-smp-flush-any-pending-ipi-callbacks-before-cpu-offline.patch
* cpu-hotplug-smp-flush-any-pending-ipi-callbacks-before-cpu-offline-v2.patch
* cpu-hotplug-smp-flush-any-pending-ipi-callbacks-before-cpu-offline-v3.patch
* kexec-save-pg_head_mask-in-vmcoreinfo.patch
* mm-hotplug-probe-interface-is-available-on-several-platforms.patch
* tmpfs-zero_range-and-collapse_range-not-currently-supported.patch
* hugetlb-fix-copy_hugetlb_page_range-to-handle-migration-hwpoisoned-entry.patch
* hugetlb-fix-copy_hugetlb_page_range-to-handle-migration-hwpoisoned-entry-checkpatch-fixes.patch
* slab-maintainer-update.patch
* watchdog-remove-preemption-restrictions-when-restarting-lockup-detector.patch
* lib-kconfigdebug-let-frame_pointer-exclude-score-just-like-exclude-most-of-other-architectures.patch
* mm-pcp-allow-restoring-percpu_pagelist_fraction-default.patch
* memorystick-rtsx-add-cancel_work-when-remove-driver.patch
* documentation-accounting-getdelaysc-cleaning-up-missing-null-terminate-after-strncpy-call.patch
* ocfs2-should-add-inode-into-orphan-dir-after-updating-entry-in-ocfs2_rename.patch
* deadlock-when-two-nodes-are-converting-same-lock-from-pr-to-ex-and-idletimeout-closes-conn.patch
* ocfs2-revert-the-patch-fix-null-pointer-dereference-when-dismount-and-ocfs2rec-simultaneously.patch
* nmi-provide-the-option-to-issue-an-nmi-back-trace-to-every-cpu-but-current.patch
* nmi-provide-the-option-to-issue-an-nmi-back-trace-to-every-cpu-but-current-fix.patch
* kernel-watchdogc-print-traces-for-all-cpus-on-lockup-detection.patch
* kernel-watchdogc-print-traces-for-all-cpus-on-lockup-detection-fix.patch
* kernel-watchdogc-print-traces-for-all-cpus-on-lockup-detection-fix-2.patch
* kernel-watchdogc-convert-printk-pr_warning-to-pr_foo.patch
* mm-thp-fix-debug_pagealloc-oops-in-copy_page_rep.patch
* mm-thp-fix-debug_pagealloc-oops-in-copy_page_rep-checkpatch-fixes.patch
* mm-let-mm_find_pmd-fix-buggy-race-with-thp-fault.patch
* shmem-fix-faulting-into-a-hole-while-its-punched.patch
* shmem-fix-faulting-into-a-hole-while-its-punched-checkpatch-fixes.patch
* slab-fix-oops-when-reading-proc-slab_allocators.patch
* slab-fix-oops-when-reading-proc-slab_allocators-v2.patch
* refcount-take-rw_lock-in-ocfs2_reflink.patch
* ocfs2-dlm-fix-misuse-of-list_move_tail-in-dlm_run_purge_list.patch
* ocfs2-fix-a-tiny-race-when-running-dirop_fileop_racer.patch
* ocfs2-fix-a-tiny-race-when-running-dirop_fileop_racer-v2.patch
* ocfs2-manually-do-the-iput-once-ocfs2_add_entry-failed-in-ocfs2_symlink-and-ocfs2_mknod.patch
* ocfs2-manually-do-the-iput-once-ocfs2_add_entry-failed-in-ocfs2_symlink-and-ocfs2_mknod-v2.patch
* ocfs2-do-not-return-dlm_migrate_response_mastery_ref-to-avoid-endlessloop-during-umount.patch
* dma-cma-fix-possible-memory-leak.patch
* ia64-arch-ia64-include-uapi-asm-fcntlh-needs-personalityh.patch
* checkpatch-reduce-false-positives-when-checking-void-function-return-statements.patch
* x86mem-hotplug-pass-sync_global_pgds-a-correct-argument-in-remove_pagetable.patch
* x86mem-hotplug-modify-pgd-entry-when-removing-memory.patch
* kernel-auditfilterc-replace-countsize-kmalloc-by-kcalloc.patch
* fs-cifs-remove-obsolete-__constant.patch
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
* ocfs2-dlm-do-not-purge-lockres-that-is-queued-for-assert-master.patch
* maintainers-update-ibm-serveraid-raid-info.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
  mm.patch
* mm-slabc-add-__init-to-init_lock_keys.patch
* slab-common-add-functions-for-kmem_cache_node-access.patch
* slub-use-new-node-functions.patch
* slub-use-new-node-functions-checkpatch-fixes.patch
* slub-use-new-node-functions-fix.patch
* slab-use-get_node-and-kmem_cache_node-functions.patch
* slab-use-get_node-and-kmem_cache_node-functions-fix.patch
* slab-use-get_node-and-kmem_cache_node-functions-fix-2.patch
* mm-slabh-wrap-the-whole-file-with-guarding-macro.patch
* mm-slub-mark-resiliency_test-as-init-text.patch
* mm-slub-slub_debug=n-use-the-same-alloc-free-hooks-as-for-slub_debug=y.patch
* mm-readaheadc-remove-unused-file_ra_state-from-count_history_pages.patch
* mm-memory_hotplugc-add-__meminit-to-grow_zone_span-grow_pgdat_span.patch
* mm-page_alloc-add-__meminit-to-alloc_pages_exact_nid.patch
* mm-page_allocc-unexport-alloc_pages_exact_nid.patch
* hwpoison-fix-the-handling-path-of-the-victimized-page-frame-that-belong-to-non-lur.patch
* include-linux-memblockh-add-__init-to-memblock_set_bottom_up.patch
* vmalloc-use-rcu-list-iterator-to-reduce-vmap_area_lock-contention.patch
* mm-memoryc-use-entry-=-access_oncepte-in-handle_pte_fault.patch
* mem-hotplug-avoid-illegal-state-prefixed-with-legal-state-when-changing-state-of-memory_block.patch
* mem-hotplug-introduce-mmop_offline-to-replace-the-hard-coding-1.patch
* mm-page_alloc-simplify-drain_zone_pages-by-using-min.patch
* memcg-cleanup-memcg_cache_params-refcnt-usage.patch
* memcg-destroy-kmem-caches-when-last-slab-is-freed.patch
* memcg-mark-caches-that-belong-to-offline-memcgs-as-dead.patch
* slub-dont-fail-kmem_cache_shrink-if-slab-placement-optimization-fails.patch
* slub-make-slab_free-non-preemptable.patch
* memcg-wait-for-kfrees-to-finish-before-destroying-cache.patch
* slub-make-dead-memcg-caches-discard-free-slabs-immediately.patch
* slab-do-not-keep-free-objects-slabs-on-dead-memcg-caches.patch
* mm-internalh-use-nth_page.patch
* dma-cma-separate-core-cma-management-codes-from-dma-apis.patch
* dma-cma-support-alignment-constraint-on-cma-region.patch
* dma-cma-support-arbitrary-bitmap-granularity.patch
* dma-cma-support-arbitrary-bitmap-granularity-fix.patch
* cma-generalize-cma-reserved-area-management-functionality.patch
* ppc-kvm-cma-use-general-cma-reserved-area-management-framework.patch
* mm-cma-clean-up-cma-allocation-error-path.patch
* mm-cma-change-cma_declare_contiguous-to-obey-coding-convention.patch
* mm-cma-clean-up-log-message.patch
* mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff.patch
* mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff-v2.patch
* mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff-v3.patch
* mm-hugetlbfs-fix-rmapping-for-anonymous-hugepages-with-page_pgoff-v3-fix.patch
* mm-thp-move-invariant-bug-check-out-of-loop-in-__split_huge_page_map.patch
* mm-thp-replace-smp_mb-after-atomic_add-by-smp_mb__after_atomic.patch
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
* mm-memcontrol-rewrite-charge-api-fix.patch
* mm-memcontrol-rewrite-uncharge-api.patch
* mm-memcontrol-rewrite-uncharge-api-fix.patch
* mm-mem-hotplug-replace-simple_strtoull-with-kstrtoull.patch
* mm-introduce-do_shared_fault-and-drop-do_fault-fix-fix.patch
* mm-compactionc-isolate_freepages_block-small-tuneup.patch
* fs-mpagec-forgotten-write_sync-in-case-of-data-integrity-write.patch
* m68k-call-find_vma-with-the-mmap_sem-held-in-sys_cacheflush.patch
* mm-zswapc-add-__init-to-zswap_entry_cache_destroy.patch
* do_shared_fault-check-that-mmap_sem-is-held.patch
* include-kernelh-rewrite-min3-max3-and-clamp-using-min-and-max.patch
* makefile-tell-gcc-optimizer-to-never-introduce-new-data-races.patch
* drivers-misc-ti-st-st_corec-fix-null-dereference-on-protocol-type-check.patch
* lib-vsprintf-add-%pt-format-specifier.patch
* drivers-video-backlight-backlightc-remove-backlight-sysfs-uevent.patch
* list-use-argument-hlist_add_after-names-from-rcu-variant.patch
* list-fix-order-of-arguments-for-hlist_add_after_rcu.patch
* list-fix-order-of-arguments-for-hlist_add_after_rcu-checkpatch-fixes.patch
* klist-use-same-naming-scheme-as-hlist-for-klist_add_after.patch
* mm-utilc-add-kstrimdup.patch
* add-lib-globc.patch
* lib-globc-add-config_glob_selftest.patch
* libata-use-glob_match-from-lib-globc.patch
* lib-add-size-unit-t-p-e-to-memparse.patch
* lib-string_helpersc-constify-static-arrays.patch
* lib-add-crc64-ecma-module.patch
* fs-compatc-remove-unnecessary-test-on-unsigned-value.patch
* checkpatch-attempt-to-find-unnecessary-out-of-memory-messages.patch
* checkpatch-warn-on-unnecessary-else-after-return-or-break.patch
* checkpatch-fix-complex-macro-false-positive-for-escaped-constant-char.patch
* checkpatch-fix-function-pointers-in-blank-line-needed-after-declarations-test.patch
* binfmt_elfc-use-get_random_int-to-fix-entropy-depleting.patch
* init-make-rootdelay=n-consistent-with-rootwait-behaviour.patch
* kernel-test_kprobesc-use-current-logging-functions.patch
* rtc-add-support-of-nvram-for-maxim-dallas-rtc-ds1343.patch
* fs-isofs-logging-clean-up.patch
* fs-isofs-logging-clean-up-fix.patch
* fs-nilfs2-superc-remove-unnecessary-test-on-unsigned-value.patch
* hfsplus-fix-longname-handling.patch
* fs-proc-kcorec-use-page_align-instead-of-alignpage_size.patch
* proc-stat-convert-to-single_open_size.patch
* fs-seq_file-fallback-to-vmalloc-allocation.patch
* fork-exec-cleanup-mm-initialization.patch
* fork-reset-mm-pinned_vm.patch
* fork-copy-mms-vm-usage-counters-under-mmap_sem.patch
* sysctl-remove-now-unused-typedef-ctl_table.patch
* sysctl-remove-now-unused-typedef-ctl_table-fix.patch
* fs-adfs-dir_fplusc-use-array_size-instead-of-sizeof-sizeof.patch
* drivers-parport-parport_ip32c-use-ptr_err_or_zero.patch
* fs-cachefiles-daemonc-remove-unnecessary-tests-on-unsigned-values.patch
* fs-cachefiles-bindc-remove-unnecessary-assertions.patch
* fs-romfs-superc-convert-printk-to-pr_foo.patch
* fs-romfs-superc-use-pr_fmt-in-logging.patch
* fs-romfs-superc-add-blank-line-after-declarations.patch
* fs-qnx6-convert-printk-to-pr_foo.patch
* fs-qnx6-use-pr_fmt-and-__func__-in-logging.patch
* fs-qnx6-update-debugging-to-current-functions.patch
* initramfs-support-initramfs-that-is-more-than-2g.patch
* initramfs-support-initramfs-that-is-more-than-2g-checkpatch-fixes.patch
* shm-make-exit_shm-work-proportional-to-task-activity.patch
* shm-allow-exit_shm-in-parallel-if-only-marking-orphans.patch
* shm-remove-unneeded-extern-for-function.patch
* lib-scatterlist-make-arch_has_sg_chain-an-actual-kconfig.patch
* lib-scatterlist-make-arch_has_sg_chain-an-actual-kconfig-fix.patch
* lib-scatterlist-make-arch_has_sg_chain-an-actual-kconfig-fix-2.patch
* lib-scatterlist-make-arch_has_sg_chain-an-actual-kconfig-fix-3.patch
* lib-scatterlist-clean-up-useless-architecture-versions-of-scatterlisth.patch
  linux-next.patch
* drivers-gpio-gpio-zevioc-fix-build.patch
* init-mainc-code-clean-up.patch
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
* bio-modify-__bio_add_page-to-accept-pages-that-dont-start-a-new-segment.patch
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
