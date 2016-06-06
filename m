Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A63D46B0253
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 19:16:35 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u67so57312267pfu.1
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 16:16:35 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ww8si29280318pac.4.2016.06.06.16.16.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 16:16:32 -0700 (PDT)
Date: Mon, 06 Jun 2016 16:16:31 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2016-06-06-16-15 uploaded
Message-ID: <5756044f.cqbGNgG68vsPkNYg%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2016-06-06-16-15 has been uploaded to

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


This mmotm tree contains the following patches against 4.7-rc2:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
* tree-wide-get-rid-of-__gfp_repeat-for-order-0-allocations-part-i.patch
* x86-get-rid-of-superfluous-__gfp_repeat.patch
* x86-efi-get-rid-of-superfluous-__gfp_repeat.patch
* arm-get-rid-of-superfluous-__gfp_repeat.patch
* arm64-get-rid-of-superfluous-__gfp_repeat.patch
* arc-get-rid-of-superfluous-__gfp_repeat.patch
* mips-get-rid-of-superfluous-__gfp_repeat.patch
* nios2-get-rid-of-superfluous-__gfp_repeat.patch
* parisc-get-rid-of-superfluous-__gfp_repeat.patch
* score-get-rid-of-superfluous-__gfp_repeat.patch
* powerpc-get-rid-of-superfluous-__gfp_repeat.patch
* sparc-get-rid-of-superfluous-__gfp_repeat.patch
* s390-get-rid-of-superfluous-__gfp_repeat.patch
* sh-get-rid-of-superfluous-__gfp_repeat.patch
* tile-get-rid-of-superfluous-__gfp_repeat.patch
* unicore32-get-rid-of-superfluous-__gfp_repeat.patch
* jbd2-get-rid-of-superfluous-__gfp_repeat.patch
* mm-hugetlb-fix-huge-page-reserve-accounting-for-private-mappings.patch
* kasan-change-memory-hot-add-error-messages-to-info-messages.patch
* mmoom_reaper-dont-call-mmput_async-without-atomic_inc_not_zero.patch
* revert-mm-memcontrol-fix-possible-css-ref-leak-on-oom.patch
* thp-broken-page-count-after-commit-aa88b68c.patch
* relay-fix-potential-memory-leak.patch
* mm-introduce-dedicated-wq_mem_reclaim-workqueue-to-do-lru_add_drain_all.patch
* mm-do-not-discard-partial-pages-with-posix_fadv_dontneed.patch
* oom_reaper-avoid-pointless-atomic_inc_not_zero-usage.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* tile-early_printko-is-always-required.patch
* fs-ext4-fsyncc-generic_file_fsync-call-based-on-barrier-flag.patch
* ocfs2-fix-a-redundant-re-initialization.patch
* ocfs2-insure-dlm-lockspace-is-created-by-kernel-module.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
  mm.patch
* mm-reorganize-slab-freelist-randomization.patch
* mm-slub-freelist-randomization.patch
* mm-memcontrol-remove-the-useless-parameter-for-mc_handle_swap_pte.patch
* mm-init-fix-zone-boundary-creation.patch
* memory-hotplug-add-move_pfn_range.patch
* memory-hotplug-more-general-validation-of-zone-during-online.patch
* memory-hotplug-use-zone_can_shift-for-sysfs-valid_zones-attribute.patch
* mm-zap-zone_oom_locked.patch
* mm-oom-add-memcg-to-oom_control.patch
* mm-debug-add-vm_warn-which-maps-to-warn.patch
* powerpc-mm-check-for-irq-disabled-only-if-debug_vm-is-enabled.patch
* zram-rename-zstrm-find-release-functions.patch
* zram-switch-to-crypto-compress-api.patch
* zram-use-crypto-api-to-check-alg-availability.patch
* zram-cosmetic-cleanup-documentation.patch
* zram-delete-custom-lzo-lz4.patch
* zram-add-more-compression-algorithms.patch
* zram-drop-gfp_t-from-zcomp_strm_alloc.patch
* mm-use-put_page-to-free-page-instead-of-putback_lru_page.patch
* mm-migrate-support-non-lru-movable-page-migration.patch
* mm-balloon-use-general-non-lru-movable-page-feature.patch
* zsmalloc-keep-max_object-in-size_class.patch
* zsmalloc-use-bit_spin_lock.patch
* zsmalloc-use-accessor.patch
* zsmalloc-factor-page-chain-functionality-out.patch
* zsmalloc-introduce-zspage-structure.patch
* zsmalloc-separate-free_zspage-from-putback_zspage.patch
* zsmalloc-use-freeobj-for-index.patch
* zsmalloc-page-migration-support.patch
* zsmalloc-page-migration-support-fix.patch
* zram-use-__gfp_movable-for-memory-allocation.patch
* mm-compaction-split-freepages-without-holding-the-zone-lock.patch
* mm-page_owner-initialize-page-owner-without-holding-the-zone-lock.patch
* mm-page_owner-copy-last_migrate_reason-in-copy_page_owner.patch
* mm-page_owner-introduce-split_page_owner-and-replace-manual-handling.patch
* tools-vm-page_owner-increase-temporary-buffer-size.patch
* mm-page_owner-use-stackdepot-to-store-stacktrace.patch
* mm-page_owner-use-stackdepot-to-store-stacktrace-fix.patch
* mm-page_alloc-introduce-post-allocation-processing-on-page-allocator.patch
* mm-thp-check-pmd_trans_unstable-after-split_huge_pmd.patch
* mm-hugetlb-simplify-hugetlb-unmap.patch
* mm-change-the-interface-for-__tlb_remove_page.patch
* mm-mmu_gather-track-page-size-with-mmu-gather-and-force-flush-if-page-size-change.patch
* mm-remove-pointless-struct-in-struct-page-definition.patch
* mm-clean-up-non-standard-page-_mapcount-users.patch
* mm-memcontrol-cleanup-kmem-charge-functions.patch
* mm-charge-uncharge-kmemcg-from-generic-page-allocator-paths.patch
* mm-memcontrol-teach-uncharge_list-to-deal-with-kmem-pages.patch
* arch-x86-charge-page-tables-to-kmemcg.patch
* pipe-account-to-kmemcg.patch
* af_unix-charge-buffers-to-kmemcg.patch
* mmoom-remove-unused-argument-from-oom_scan_process_thread.patch
* mm-frontswap-convert-frontswap_enabled-to-static-key.patch
* mm-frontswap-convert-frontswap_enabled-to-static-key-checkpatch-fixes.patch
* mm-add-nr_zsmalloc-to-vmstat.patch
* mm-add-nr_zsmalloc-to-vmstat-fix.patch
* include-linux-memblockh-clean-up-code-for-several-trivial-details.patch
* mm-memblock-if-nr_new-is-0-just-return.patch
* mm-make-optimistic-check-for-swapin-readahead.patch
* mm-make-optimistic-check-for-swapin-readahead-fix-2.patch
* mm-make-optimistic-check-for-swapin-readahead-fix-3.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-2.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-3.patch
* mm-vmstat-calculate-particular-vm-event.patch
* mm-thp-avoid-unnecessary-swapin-in-khugepaged.patch
* mm-thp-avoid-unnecessary-swapin-in-khugepaged-fix.patch
* mm-thp-avoid-unnecessary-swapin-in-khugepaged-fix-2.patch
* mm-thp-make-swapin-readahead-under-down_read-of-mmap_sem.patch
* mm-thp-make-swapin-readahead-under-down_read-of-mmap_sem-fix.patch
* mm-thp-make-swapin-readahead-under-down_read-of-mmap_sem-fix-2.patch
* mm-thp-make-swapin-readahead-under-down_read-of-mmap_sem-fix-2-fix.patch
* khugepaged-simplify-khugepaged-vs-__mmput.patch
* memstick-dont-allocate-unused-major-for-ms_block.patch
* nvme-dont-allocate-unused-nvme_major.patch
* nvme-dont-allocate-unused-nvme_major-fix.patch
* jump_label-remove-bugh-atomich-dependencies-for-have_jump_label.patch
* powerpc-add-explicit-include-asm-asm-compath-for-jump-label.patch
* s390-add-explicit-linux-stringifyh-for-jump-label.patch
* dynamic_debug-add-jump-label-support.patch
* lib-switch-config_printk_time-to-int.patch
* printk-allow-different-timestamps-for-printktime.patch
* lib-add-crc64-ecma-module.patch
* samples-kprobe-convert-the-printk-to-pr_info-pr_err.patch
* samples-jprobe-convert-the-printk-to-pr_info-pr_err.patch
* samples-kretprobe-convert-the-printk-to-pr_info-pr_err.patch
* samples-kretprobe-fix-the-wrong-type.patch
* fs-befs-move-useless-assignment.patch
* fs-befs-check-silent-flag-before-logging-errors.patch
* fs-befs-remove-useless-pr_err.patch
* fs-befs-remove-useless-befs_error.patch
* fs-befs-remove-useless-pr_err-in-befs_init_inodecache.patch
* nilfs2-hide-function-name-argument-from-nilfs_error.patch
* nilfs2-add-nilfs_msg-message-interface.patch
* nilfs2-embed-a-back-pointer-to-super-block-instance-in-nilfs-object.patch
* nilfs2-reduce-bare-use-of-printk-with-nilfs_msg.patch
* nilfs2-replace-nilfs_warning-with-nilfs_msg.patch
* nilfs2-emit-error-message-when-i-o-error-is-detected.patch
* nilfs2-do-not-use-yield.patch
* nilfs2-refactor-parser-of-snapshot-mount-option.patch
* reiserfs-fix-new_insert_key-may-be-used-uninitialized.patch
* kexec-return-error-number-directly.patch
* arm-kdump-advertise-boot-aliased-crash-kernel-resource.patch
* arm-kexec-advertise-location-of-bootable-ram.patch
* kexec-dont-invoke-oom-killer-for-control-page-allocation.patch
* kexec-ensure-user-memory-sizes-do-not-wrap.patch
* kexec-ensure-user-memory-sizes-do-not-wrap-fix.patch
* kdump-arrange-for-paddr_vmcoreinfo_note-to-return-phys_addr_t.patch
* kexec-allow-architectures-to-override-boot-mapping.patch
* kexec-allow-architectures-to-override-boot-mapping-fix.patch
* arm-keystone-dts-add-psci-command-definition.patch
* arm-kexec-fix-kexec-for-keystone-2.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* futex-fix-shared-futex-operations-on-nommu.patch
* dma-mapping-constify-attrs-passed-to-dma_get_attr.patch
* arm-dma-mapping-constify-attrs-passed-to-internal-functions.patch
* arm64-dma-mapping-constify-attrs-passed-to-internal-functions.patch
* w1-remove-need-for-ida-and-use-platform_devid_auto.patch
* w1-add-helper-macro-module_w1_family.patch
* kcov-allow-more-fine-grained-coverage-instrumentation.patch
* ipc-semc-fix-complex_count-vs-simple-op-race.patch
* ipc-msgc-msgsnd-use-freezable-blocking-call.patch
* msgrcv-use-freezable-blocking-call.patch
  linux-next.patch
* mm-make-optimistic-check-for-swapin-readahead-fix.patch
* drivers-net-wireless-intel-iwlwifi-dvm-calibc-fix-min-warning.patch
* fpga-zynq-fpga-fix-build-failure.patch
  mm-add-strictlimit-knob-v2.patch
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
