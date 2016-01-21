Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id ADE6B6B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 19:11:23 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id ho8so12727038pac.2
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 16:11:23 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id os10si5758104pac.121.2016.01.20.16.11.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jan 2016 16:11:22 -0800 (PST)
Date: Wed, 20 Jan 2016 16:11:21 -0800
From: akpm@linux-foundation.org
Subject: mmotm 2016-01-20-16-10 uploaded
Message-ID: <56a02229.jflRJCVbhh3syv6r%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2016-01-20-16-10 has been uploaded to

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


This mmotm tree contains the following patches against 4.4:
(patches marked "*" will be included in linux-next)

  origin.patch
* libcrc32c-fix-build-warning.patch
* mm-softirq-safe-softirq-unsafe-lock-order-detected-in-split_huge_page_to_list.patch
* mm-proc-add-workaround-for-old-compilers.patch
* mm-remove-duplicate-definitions-of-madv_free.patch
* zsmalloc-fix-migrate_zspage-zs_free-race-condition.patch
* misc-ibmasm-fix-build-errors.patch
* scripts-get_maintainerpl-handle-file-names-beginning-with.patch
* credits-add-credit-information-for-martin-kepplinger.patch
* string_helpers-fix-precision-loss-for-some-inputs.patch
* frv-io-accept-const-void-pointers-for-readbwl.patch
* lib-iomap_copy-add-__ioread32_copy.patch
* soc-qcom-smd-use-__ioread32_copy-instead-of-open-coding-it.patch
* firmware-bcm47xx_nvram-use-__ioread32_copy-instead-of-open-coding.patch
* test_hexdump-rename-to-test_hexdump.patch
* test_hexdump-introduce-test_hexdump_prepare_test-helper.patch
* test_hexdump-define-fill_char-constant.patch
* test_hexdump-go-through-all-possible-lengths-of-buffer.patch
* test_hexdump-replace-magic-numbers-by-their-meaning.patch
* test_hexdump-switch-to-memcmp.patch
* test_hexdump-check-all-bytes-in-real-buffer.patch
* test_hexdump-test-all-possible-group-sizes-for-overflow.patch
* test_hexdump-print-statistics-at-the-end.patch
* lib-radix_tree-fix-error-in-docs-about-locks.patch
* lib-clz_tabc-put-in-lib-y-rather-than-obj-y.patch
* checkpatch-warn-when-casting-constants-to-c90-int-or-longer-types.patch
* checkpatch-improve-macros-with-flow-control-test.patch
* checkpatch-fix-a-number-of-complex_macro-false-positives.patch
* epoll-add-epollexclusive-flag.patch
* init-mainc-obsolete_checksetup-can-be-boolean.patch
* init-do_mounts-initrd_load-can-be-boolean.patch
* hfs-use-list_for_each_entry-in-hfs_cat_delete.patch
* fat-allow-time_offset-to-be-upto-24-hours.patch
* fat-add-simple-validation-for-directory-inode.patch
* fat-add-fat_fallocate-operation.patch
* fat-skip-cluster-allocation-on-fallocated-region.patch
* fat-permit-to-return-phy-block-number-by-fibmap-in-fallocated-region.patch
* documentation-filesystems-vfattxt-update-the-limitation-for-fat-fallocate.patch
* fat-constify-fatent_operations-structures.patch
* ptrace-make-wait_on_bitjobctl_trapping_bit-in-ptrace_attach-killable.patch
* ptrace-task_stopped_codeptrace-=-true-cant-see-task_stopped-task.patch
* security-let-security-modules-use-ptrace_mode_-with-bitmasks.patch
* ptrace-use-fsuid-fsgid-effective-creds-for-fs-access-checks.patch
* fs-coredump-prevent-core-path-components.patch
* exit-remove-unneeded-declaration-of-exit_mm.patch
* powerpc-fadump-rename-cpu_online_mask-member-of-struct-fadump_crash_info_header.patch
* kernel-cpuc-change-type-of-cpu_possible_bits-and-friends.patch
* kernel-cpuc-export-__cpu__mask.patch
* drivers-base-cpuc-use-__cpu__mask-directly.patch
* kernel-cpuc-eliminate-cpu__mask.patch
* kernel-cpuc-make-set_cpu_-static-inlines.patch
* kexec-set-kexec_type_crash-before-sanity_check_segment_list.patch
* kexec-use-list_for_each_entry_safe-in-kimage_free_page_list.patch
* kexec-move-some-memembers-and-definitions-within-the-scope-of-config_kexec_file.patch
* rapidio-use-kobj_to_dev.patch
* rbtree-use-read_once-in-rb_empty_root.patch
* sysctl-enable-strict-writes.patch
* kernel-printk-specify-alignment-for-struct-printk_log.patch
* mac80211-prevent-build-failure-with-config_ubsan=y.patch
* ubsan-run-time-undefined-behavior-sanity-checker.patch
* powerpc-enable-ubsan-support.patch
* prctl-take-mmap-sem-for-writing-to-protect-against-others.patch
* proc-read-mms-argenv_startend-with-mmap-semaphore-taken.patch
* lz4-fix-wrong-compress-buffer-size-for-64-bits.patch
* ipc-shm-is_file_shm_hugepages-can-be-boolean.patch
* fs-overlayfs-superc-needs-pagemaph.patch
* fs-adfs-adfsh-tidy-up-comments.patch
* iio-core-introduce-iio-software-triggers-fix.patch
* dma-mapping-make-the-generic-coherent-dma-mmap-implementation-optional.patch
* arc-convert-to-dma_map_ops.patch
* avr32-convert-to-dma_map_ops.patch
* blackfin-convert-to-dma_map_ops.patch
* c6x-convert-to-dma_map_ops.patch
* cris-convert-to-dma_map_ops.patch
* nios2-convert-to-dma_map_ops.patch
* frv-convert-to-dma_map_ops.patch
* parisc-convert-to-dma_map_ops.patch
* mn10300-convert-to-dma_map_ops.patch
* m68k-convert-to-dma_map_ops.patch
* metag-convert-to-dma_map_ops.patch
* sparc-use-generic-dma_set_mask.patch
* tile-uninline-dma_set_mask.patch
* dma-mapping-always-provide-the-dma_map_ops-based-implementation.patch
* dma-mapping-remove-asm-generic-dma-coherenth.patch
* dma-mapping-use-offset_in_page-macro.patch
* memstick-use-sector_div-instead-of-do_div.patch
* mm-memcontrol-drop-unused-css-argument-in-memcg_init_kmem.patch
* mm-memcontrol-remove-double-kmem-page_counter-init.patch
* mm-memcontrol-give-the-kmem-states-more-descriptive-names.patch
* mm-memcontrol-group-kmem-init-and-exit-functions-together.patch
* mm-memcontrol-separate-kmem-code-from-legacy-tcp-accounting-code.patch
* mm-memcontrol-move-kmem-accounting-code-to-config_memcg.patch
* mm-memcontrol-account-kmem-consumers-in-cgroup2-memory-controller.patch
* mm-memcontrol-allow-to-disable-kmem-accounting-for-cgroup2.patch
* mm-memcontrol-introduce-config_memcg_legacy_kmem.patch
* net-drop-tcp_memcontrolc.patch
* mm-memcontrol-reign-in-the-config-space-madness.patch
* mm-memcontrol-flatten-struct-cg_proto.patch
* mm-memcontrol-clean-up-alloc-online-offline-free-functions.patch
* mm-memcontrol-charge-swap-to-cgroup2.patch
* mm-vmscan-pass-memcg-to-get_scan_count.patch
* mm-memcontrol-replace-mem_cgroup_lruvec_online-with-mem_cgroup_online.patch
* swaph-move-memcg-related-stuff-to-the-end-of-the-file.patch
* mm-vmscan-do-not-scan-anon-pages-if-memcg-swap-limit-is-hit.patch
* mm-free-swap-cache-aggressively-if-memcg-swap-is-full.patch
* documentation-cgroup-add-memoryswapcurrentmax-description.patch
* mm-memcontrol-do-not-uncharge-old-page-in-page-cache-replacement.patch
* mm-memcontrol-basic-memory-statistics-in-cgroup2-memory-controller.patch
* mm-memcontrol-add-sock-to-cgroup2-memorystat.patch
* maintainers-add-git-url-for-apm-driver.patch
  i-need-old-gcc.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  drivers-gpu-drm-i915-intel_spritec-fix-build.patch
  drivers-gpu-drm-i915-intel_tvc-fix-build.patch
  arm-mm-do-not-use-virt_to_idmap-for-nommu-systems.patch
* thp-change-pmd_trans_huge_lock-interface-to-return-ptl.patch
* mlocked-pages-statistics-shows-bogus-value.patch
* mm-fix-kernel-crash-in-khugepaged-thread.patch
* mm-fix-kernel-crash-in-khugepaged-thread-fix.patch
* numa-fix-proc-pid-numa_maps-on-s390.patch
* numa-fix-proc-pid-numa_maps-on-s390-fix.patch
* ratelimit-fix-bug-in-time-interval-by-resetting-right-begin-time.patch
* reiserfs-fix-dereference-of-err_ptr.patch
* nfs-hangs-in-__ocfs2_cluster_lock-due-to-race-with-ocfs2_unblock_lock.patch
* proc-revert-proc-pid-maps-annotation.patch
* fs-ext4-fsyncc-generic_file_fsync-call-based-on-barrier-flag.patch
* ocfs2-add-ocfs2_write_type_t-type-to-identify-the-caller-of-write.patch
* ocfs2-use-c_new-to-indicate-newly-allocated-extents.patch
* ocfs2-test-target-page-before-change-it.patch
* ocfs2-do-not-change-i_size-in-write_end-for-direct-io.patch
* ocfs2-return-the-physical-address-in-ocfs2_write_cluster.patch
* ocfs2-record-unwritten-extents-when-populate-write-desc.patch
* ocfs2-fix-sparse-file-data-ordering-issue-in-direct-io.patch
* ocfs2-code-clean-up-for-direct-io.patch
* ocfs2-fix-ip_unaligned_aio-deadlock-with-dio-work-queue.patch
* ocfs2-fix-ip_unaligned_aio-deadlock-with-dio-work-queue-fix.patch
* ocfs2-take-ip_alloc_sem-in-ocfs2_dio_get_block-ocfs2_dio_end_io_write.patch
* ocfs2-fix-disk-file-size-and-memory-file-size-mismatch.patch
* ocfs2-fix-a-deadlock-issue-in-ocfs2_dio_end_io_write.patch
* ocfs2-dlm-fix-race-between-convert-and-recovery.patch
* ocfs2-dlm-fix-race-between-convert-and-recovery-v2.patch
* ocfs2-dlm-fix-race-between-convert-and-recovery-v3.patch
* ocfs2-dlm-fix-bug-in-dlm_move_lockres_to_recovery_list.patch
* ocfs2-extend-transaction-for-ocfs2_remove_rightmost_path-and-ocfs2_update_edge_lengths-before-to-avoid-inconsistency-between-inode-and-et.patch
* extend-enough-credits-for-freeing-one-truncate-record-while-replaying-truncate-records.patch
* ocfs2-avoid-occurring-deadlock-by-changing-ocfs2_wq-from-global-to-local.patch
* ocfs2-solve-a-problem-of-crossing-the-boundary-in-updating-backups.patch
* ocfs2-export-ocfs2_kset-for-online-file-check.patch
* ocfs2-sysfile-interfaces-for-online-file-check.patch
* ocfs2-create-remove-sysfile-for-online-file-check.patch
* ocfs2-check-fix-inode-block-for-online-file-check.patch
* ocfs2-add-feature-document-for-online-file-check.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
  mm.patch
* ksm-introduce-ksm_max_page_sharing-per-page-deduplication-limit.patch
* ksm-introduce-ksm_max_page_sharing-per-page-deduplication-limit-fix-2.patch
* ksm-introduce-ksm_max_page_sharing-per-page-deduplication-limit-fix-3.patch
* mm-make-optimistic-check-for-swapin-readahead.patch
* mm-make-optimistic-check-for-swapin-readahead-fix-2.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-2.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-3.patch
* mm-oom-rework-oom-detection.patch
* mm-oom-rework-oom-detection-checkpatch-fixes.patch
* mm-throttle-on-io-only-when-there-are-too-many-dirty-and-writeback-pages.patch
* mm-use-watermak-checks-for-__gfp_repeat-high-order-allocations.patch
* mm-use-watermak-checks-for-__gfp_repeat-high-order-allocations-checkpatch-fixes.patch
* sched-add-schedule_timeout_idle.patch
* mm-oom-introduce-oom-reaper.patch
* mm-oom-introduce-oom-reaper-v4.patch
* oom-reaper-handle-anonymous-mlocked-pages.patch
* oom-clear-tif_memdie-after-oom_reaper-managed-to-unmap-the-address-space.patch
* mm-oom_killc-dont-skip-pf_exiting-tasks-when-searching-for-a-victim.patch
* mm-page_allocc-calculate-zone_start_pfn-at-zone_spanned_pages_in_node.patch
* mm-page_allocc-introduce-kernelcore=mirror-option.patch
* mm-page_allocc-introduce-kernelcore=mirror-option-fix.patch
* mm-page_allocc-rework-code-layout-in-memmap_init_zone.patch
* mm-memblock-if-nr_new-is-0-just-return.patch
* kernel-hung_taskc-use-timeout-diff-when-timeout-is-updated.patch
* printk-nmi-generic-solution-for-safe-printk-in-nmi.patch
* printk-nmi-use-irq-work-only-when-ready.patch
* printk-nmi-warn-when-some-message-has-been-lost-in-nmi-context.patch
* printk-nmi-increase-the-size-of-nmi-buffer-and-make-it-configurable.patch
* mm-utilc-add-kstrimdup.patch
* lib-add-crc64-ecma-module.patch
* kexec-introduce-a-protection-mechanism-for-the-crashkernel-reserved-memory.patch
* kexec-provide-arch_kexec_protectunprotect_crashkres.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* ipc-semc-fix-complex_count-vs-simple-op-race.patch
* ipc-msgc-msgsnd-use-freezable-blocking-call.patch
* msgrcv-use-freezable-blocking-call.patch
  linux-next.patch
  linux-next-rejects.patch
  linux-next-git-rejects.patch
* drivers-net-wireless-intel-iwlwifi-dvm-calibc-fix-min-warning.patch
* dax-fix-null-pointer-dereference-in-__dax_dbg.patch
* dax-fix-conversion-of-holes-to-pmds.patch
* pmem-add-wb_cache_pmem-to-the-pmem-api.patch
* pmem-add-wb_cache_pmem-to-the-pmem-api-v6.patch
* dax-support-dirty-dax-entries-in-radix-tree.patch
* dax-support-dirty-dax-entries-in-radix-tree-v6.patch
* mm-add-find_get_entries_tag.patch
* dax-add-support-for-fsync-sync.patch
* dax-add-support-for-fsync-sync-v6.patch
* dax-add-support-for-fsync-sync-v6-fix.patch
* dax-add-support-for-fsync-msync-v7.patch
* dax-add-support-for-fsync-msync-v8.patch
* ext2-call-dax_pfn_mkwrite-for-dax-fsync-msync.patch
* ext4-call-dax_pfn_mkwrite-for-dax-fsync-msync.patch
* xfs-call-dax_pfn_mkwrite-for-dax-fsync-msync.patch
* tree-wide-use-kvfree-than-conditional-kfree-vfree.patch
* include-linux-huge_mmh-pmd_trans_huge_lock-returns-a-spinlock_t.patch
  mm-add-strictlimit-knob-v2.patch
  do_shared_fault-check-that-mmap_sem-is-held.patch
  make-sure-nobodys-leaking-resources.patch
  releasing-resources-with-children.patch
  make-frame_pointer-default=y.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  mutex-subsystem-synchro-test-module.patch
  slab-leaks3-default-y.patch
  add-debugging-aid-for-memory-initialisation-problems.patch
  workaround-for-a-pci-restoring-bug.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
