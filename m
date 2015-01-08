Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 433FA6B0032
	for <linux-mm@kvack.org>; Wed,  7 Jan 2015 20:09:10 -0500 (EST)
Received: by mail-ig0-f172.google.com with SMTP id hl2so482368igb.5
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 17:09:09 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x8si3184353ick.8.2015.01.07.17.09.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Jan 2015 17:09:08 -0800 (PST)
Date: Wed, 07 Jan 2015 17:09:06 -0800
From: akpm@linux-foundation.org
Subject: mmotm 2015-01-07-17-07 uploaded
Message-ID: <54add8b2.REqH7FrN0x7D6egk%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz

The mm-of-the-moment snapshot 2015-01-07-17-07 has been uploaded to

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


This mmotm tree contains the following patches against 3.19-rc3:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
* ocfs2-remove-bogus-check-in-dlm_process_recovery_data.patch
* exit-fix-race-between-wait_consider_task-and-wait_task_zombie.patch
* mm-prevent-endless-growth-of-anon_vma-hierarchy.patch
* mm-prevent-endless-growth-of-anon_vma-hierarchy-fix.patch
* mm-protect-set_page_dirty-from-ongoing-truncation.patch
* maintainers-update-rydbergs-addresses.patch
* ocfs2-fix-the-wrong-directory-passed-to-ocfs2_lookup_ino_from_name-when-link-file.patch
* blackfin-bf533-stamp-add-linux-delayh.patch
* vfs-renumber-fmode_nonotify-and-add-to-uniqueness-check.patch
* mm-debug-pagealloc-prepare-boottime-configurable-on-off.patch
* mm-memcontrol-switch-soft-limit-default-back-to-infinity.patch
* memcg-fix-destination-cgroup-leak-on-task-charges-migration.patch
* mm-vmscan-prevent-kswapd-livelock-due-to-pfmemalloc-throttled-process-being-killed.patch
* mm-page_alloc-embed-oom-killing-naturally-into-allocation-slowpath.patch
* mm-page_alloc-embed-oom-killing-naturally-into-allocation-slowpath-update.patch
* mm-page_alloc-embed-oom-killing-naturally-into-allocation-slowpath-fix.patch
* jffs2-bugfix-of-summary-length.patch
* fanotify-only-destroy-mark-when-both-mask-and-ignored_mask-are-cleared.patch
* fanotify-dont-recalculate-a-marks-mask-if-only-the-ignored-mask-changed.patch
* fanotify-dont-recalculate-a-marks-mask-if-only-the-ignored-mask-changed-checkpatch-fixes.patch
* fanotify-dont-set-fan_ondir-implicitly-on-a-marks-ignored-mask.patch
* fanotify-dont-set-fan_ondir-implicitly-on-a-marks-ignored-mask-checkpatch-fixes.patch
* input-route-kbd-leds-through-the-generic-leds-layer.patch
* kconfig-use-bool-instead-of-boolean-for-type-definition-attributes.patch
* fs-ext4-fsyncc-generic_file_fsync-call-based-on-barrier-flag.patch
* ocfs2-dlm-add-missing-dlm_lock_put-when-recovery-master-down.patch
* ocfs2-remove-unnecessary-else-in-ocfs2_set_acl.patch
* ocfs2-fix-uninitialized-variable-access.patch
* ocfs2-fix-wrong-comment.patch
* ocfs2-add-a-mount-option-journal_async_commit-on-ocfs2-filesystem.patch
* o2dlm-fix-null-pointer-dereference-in-o2dlm_blocking_ast_wrapper.patch
* ocfs2-call-ocfs2_journal_access_di-before-ocfs2_journal_dirty-in-ocfs2_write_end_nolock.patch
* ocfs2-avoid-access-invalid-address-when-read-o2dlm-debug-messages.patch
* ocfs2-eliminate-the-static-flag-of-some-functions.patch
* ocfs2-add-functions-to-add-and-remove-inode-in-orphan-dir.patch
* ocfs2-add-orphan-recovery-types-in-ocfs2_recover_orphans.patch
* ocfs2-implement-ocfs2_direct_io_write.patch
* ocfs2-allocate-blocks-in-ocfs2_direct_io_get_blocks.patch
* ocfs2-do-not-fallback-to-buffer-i-o-write-if-appending.patch
* ocfs2-do-not-fallback-to-buffer-i-o-write-if-fill-holes.patch
* ocfs2-fix-leftover-orphan-entry-caused-by-append-o_direct-write-crash.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* fs-make-generic_block_fiemap-sig-tolerant.patch
* fs-make-generic_block_fiemap-sig-tolerant-fix.patch
  mm.patch
* mm-replace-remap_file_pages-syscall-with-emulation.patch
* mm-drop-support-of-non-linear-mapping-from-unmap-zap-codepath.patch
* mm-drop-support-of-non-linear-mapping-from-fault-codepath.patch
* mm-drop-vm_ops-remap_pages-and-generic_file_remap_pages-stub.patch
* proc-drop-handling-non-linear-mappings.patch
* rmap-drop-support-of-non-linear-mappings.patch
* mm-replace-vma-shareadlinear-with-vma-shared.patch
* mm-remove-rest-usage-of-vm_nonlinear-and-pte_file.patch
* asm-generic-drop-unused-pte_file-helpers.patch
* alpha-drop-_page_file-and-pte_file-related-helpers.patch
* arc-drop-_page_file-and-pte_file-related-helpers.patch
* arc-drop-_page_file-and-pte_file-related-helpers-fix.patch
* arm64-drop-pte_file-and-pte_file-related-helpers.patch
* arm-drop-l_pte_file-and-pte_file-related-helpers.patch
* avr32-drop-_page_file-and-pte_file-related-helpers.patch
* blackfin-drop-pte_file.patch
* c6x-drop-pte_file.patch
* cris-drop-_page_file-and-pte_file-related-helpers.patch
* frv-drop-_page_file-and-pte_file-related-helpers.patch
* hexagon-drop-_page_file-and-pte_file-related-helpers.patch
* ia64-drop-_page_file-and-pte_file-related-helpers.patch
* m32r-drop-_page_file-and-pte_file-related-helpers.patch
* m68k-drop-_page_file-and-pte_file-related-helpers.patch
* metag-drop-_page_file-and-pte_file-related-helpers.patch
* microblaze-drop-_page_file-and-pte_file-related-helpers.patch
* mips-drop-_page_file-and-pte_file-related-helpers.patch
* mn10300-drop-_page_file-and-pte_file-related-helpers.patch
* nios2-drop-_page_file-and-pte_file-related-helpers.patch
* openrisc-drop-_page_file-and-pte_file-related-helpers.patch
* parisc-drop-_page_file-and-pte_file-related-helpers.patch
* powerpc-drop-_page_file-and-pte_file-related-helpers.patch
* s390-drop-pte_file-related-helpers.patch
* score-drop-_page_file-and-pte_file-related-helpers.patch
* sh-drop-_page_file-and-pte_file-related-helpers.patch
* sparc-drop-pte_file-related-helpers.patch
* tile-drop-pte_file-related-helpers.patch
* um-drop-_page_file-and-pte_file-related-helpers.patch
* unicore32-drop-pte_file-related-helpers.patch
* x86-drop-_page_file-and-pte_file-related-helpers.patch
* xtensa-drop-_page_file-and-pte_file-related-helpers.patch
* mm-memory-remove-vm_file-check-on-shared-writable-vmas.patch
* mm-memory-merge-shared-writable-dirtying-branches-in-do_wp_page.patch
* hugetlb-sysctl-pass-extra1-=-null-rather-then-extra1-=-zero.patch
* mm-hugetlb-fix-type-of-hugetlb_treat_as_movable-variable.patch
* mm-page_alloc-place-zone_id-check-before-vm_bug_on_page-check.patch
* memcg-zap-__memcg_chargeuncharge_slab.patch
* memcg-zap-memcg_name-argument-of-memcg_create_kmem_cache.patch
* memcg-zap-memcg_slab_caches-and-memcg_slab_mutex.patch
* mm-add-fields-for-compound-destructor-and-order-into-struct-page.patch
* mm-add-vm_bug_on_page-for-page_mapcount.patch
* mm-add-kpf_zero_page-flag-for-proc-kpageflags.patch
* oom-dont-count-on-mm-less-current-process.patch
* oom-make-sure-that-tif_memdie-is-set-under-task_lock.patch
* swap-remove-unused-mem_cgroup_uncharge_swapcache-declaration.patch
* mm-memcontrol-track-move_lock-state-internally.patch
* mm-memcontrol-track-move_lock-state-internally-fix.patch
* mm-change-meminfo-cached-calculation.patch
* mm-change-meminfo-cached-calculation-fix.patch
* mm-page_allocc-__alloc_pages_nodemask-dont-alter-arg-gfp_mask.patch
* kmemcheck-move-hook-into-__alloc_pages_nodemask-for-the-page-allocator.patch
* mm-fix-a-typo-of-migrate_reserve-in-comment.patch
* mm-page_allocc-drop-dead-destroy_compound_page.patch
* mm-vmscan-wake-up-all-pfmemalloc-throttled-processes-at-once.patch
* mm-page_isolation-check-pfn-validity-before-access.patch
* mm-fix-invalid-use-of-pfn_valid_within-in-test_pages_in_a_zone.patch
* fs-mpagec-forgotten-write_sync-in-case-of-data-integrity-write.patch
* mm-support-madvisemadv_free.patch
* mm-support-madvisemadv_free-fix.patch
* x86-add-pmd_-for-thp.patch
* x86-add-pmd_-for-thp-fix.patch
* sparc-add-pmd_-for-thp.patch
* sparc-add-pmd_-for-thp-fix.patch
* powerpc-add-pmd_-for-thp.patch
* arm-add-pmd_mkclean-for-thp.patch
* arm64-add-pmd_-for-thp.patch
* mm-dont-split-thp-page-when-syscall-is-called.patch
* mm-dont-split-thp-page-when-syscall-is-called-fix.patch
* mm-dont-split-thp-page-when-syscall-is-called-fix-2.patch
* zram-clean-up-zram_meta_alloc.patch
* mm-zpool-add-name-argument-to-create-zpool.patch
* mm-zsmalloc-add-statistics-support.patch
* do_shared_fault-check-that-mmap_sem-is-held.patch
* arch-frv-mm-extablec-remove-unused-function.patch
* task_mmu-add-user-space-support-for-resetting-mm-hiwater_rss-peak-rss.patch
* fs-proc-use-the-pde-to-to-get-proc_dir_entry.patch
* fs-proc-task_mmu-show-page-size-in-proc-pid-numa_maps.patch
* all-arches-signal-move-restart_block-to-struct-task_struct.patch
* all-arches-signal-move-restart_block-to-struct-task_struct-fix.patch
* param-initialize-store-function-to-null-if-not-available.patch
* drivers-char-mem-make-dev-mem-an-optional-device.patch
* drivers-char-mem-simplify-devkmem-configuration.patch
* drivers-char-mem-simplify-devport-configuration.patch
* drivers-misc-ti-st-st_corec-fix-null-dereference-on-protocol-type-check.patch
* printk-correct-timeout-comment-neaten-module_parm_desc.patch
* lib-vsprintf-add-%pt-format-specifier.patch
* lib-string_get_size-remove-redundant-prefixes.patch
* lib-string_get_size-use-32-bit-arithmetic-when-possible.patch
* lib-string_get_size-return-void.patch
* lib-bitmap-more-signed-unsigned-conversions.patch
* linux-nodemaskh-update-bitmap-wrappers-to-take-unsigned-int.patch
* linux-cpumaskh-update-bitmap-wrappers-to-take-unsigned-int.patch
* lib-bitmap-update-bitmap_onto-to-unsigned.patch
* lib-bitmap-update-bitmap_onto-to-unsigned-checkpatch-fixes.patch
* lib-bitmap-change-parameters-of-bitmap_fold-to-unsigned.patch
* lib-bitmap-change-parameters-of-bitmap_fold-to-unsigned-fix.patch
* lib-bitmap-simplify-bitmap_pos_to_ord.patch
* lib-bitmap-simplify-bitmap_ord_to_pos.patch
* lib-bitmap-make-the-bits-parameter-of-bitmap_remap-unsigned.patch
* lib-remove-strnicmp.patch
* lib-genallocc-fix-the-end-addr-check-in-addr_in_gen_pool.patch
* hexdump-introduce-test-suite.patch
* hexdump-fix-ascii-column-for-the-tail-of-a-dump.patch
* hexdump-do-few-calculations-ahead.patch
* hexdump-makes-it-return-amount-of-bytes-placed-in-buffer.patch
* hexdump-makes-it-return-amount-of-bytes-placed-in-buffer-fix.patch
* lib-interval_treec-simplify-includes.patch
* lib-sortc-use-simpler-includes.patch
* lib-dynamic_queue_limitsc-simplify-includes.patch
* lib-halfmd4c-simplify-includes.patch
* lib-idrc-remove-redundant-include.patch
* lib-genallocc-remove-redundant-include.patch
* lib-list_sortc-rearrange-includes.patch
* lib-md5c-simplify-include.patch
* lib-llistc-remove-redundant-include.patch
* lib-kobject_ueventc-remove-redundant-include.patch
* lib-nlattrc-remove-redundant-include.patch
* lib-plistc-remove-redundant-include.patch
* lib-radix-treec-change-to-simpler-include.patch
* lib-show_memc-remove-redundant-include.patch
* lib-sortc-move-include-inside-if-0.patch
* lib-stmp_devicec-replace-moduleh-include.patch
* lib-strncpy_from_userc-replace-moduleh-include.patch
* lib-percpu_idac-remove-redundant-includes.patch
* lib-lcmc-replace-include.patch
* lib-bitmapc-change-prototype-of-bitmap_copy_le.patch
* lib-bitmapc-elide-bitmap_copy_le-on-little-endian.patch
* lib-bitmap-change-bitmap_shift_right-to-take-unsigned-parameters.patch
* lib-bitmap-eliminate-branch-in-__bitmap_shift_right.patch
* lib-bitmap-remove-redundant-code-from-__bitmap_shift_right.patch
* lib-bitmap-yet-another-simplification-in-__bitmap_shift_right.patch
* lib-bitmap-change-bitmap_shift_left-to-take-unsigned-parameters.patch
* lib-bitmap-eliminate-branch-in-__bitmap_shift_left.patch
* lib-bitmap-remove-redundant-code-from-__bitmap_shift_left.patch
* lib-crc32-constify-crc32-lookup-table.patch
* mm-utilc-add-kstrimdup.patch
* lib-add-crc64-ecma-module.patch
* checkpatch-emit-an-error-when-using-predefined-timestamp-macros.patch
* checkpatch-improve-octal-permissions-tests.patch
* checkpatch-ignore-__pure-attribute.patch
* checkpatch-fix-unnecessary_kern_level-false-positive.patch
* checkpatch-add-check-for-keyword-boolean-in-kconfig-definitions.patch
* init-remove-config_init_fallback.patch
* rtc-rtc-pfc2123-add-support-for-devicetree.patch
* drivers-rtc-interfacec-check-the-error-after-__rtc_read_time.patch
* rtc-rtc-isl12057-add-alarm-support-to-intersil-isl12057-rtc-driver.patch
* rtc-rtc-isl12057-add-alarm-support-to-intersil-isl12057-rtc-driver-update.patch
* rtc-rtc-isl12057-add-isilirq2-can-wakeup-machine-property-for-in-tree-users.patch
* arm-mvebu-isl12057-rtc-chip-can-now-wake-up-rn102-rn102-and-rn2120.patch
* rtc-imx-dryice-trivial-clean-up-code.patch
* rtc-imx-dryice-add-more-known-register-bits.patch
* rtc-at91sam9-constify-struct-regmap_config.patch
* rtc-isl12057-constify-struct-regmap_config.patch
* rtc-restore-alarm-after-resume.patch
* fs-befs-linuxvfsc-remove-unnecessary-casting.patch
* fs-befs-linuxvfsc-remove-unnecessary-casting-fix.patch
* fs-coda-dirc-forward-declaration-clean-up.patch
* fs-ufs-superc-remove-unnecessary-casting.patch
* fs-reiserfs-inodec-replace-0-by-null-for-pointers.patch
* fs-fat-use-msdos_sb-macro-to-get-msdos_sb_info.patch
* fat-add-fat_fallocate-operation.patch
* fat-skip-cluster-allocation-on-fallocated-region.patch
* fat-permit-to-return-phy-block-number-by-fibmap-in-fallocated-region.patch
* documentation-filesystems-vfattxt-update-the-limitation-for-fat-fallocate.patch
* ptrace-remove-linux-compath-inclusion-under-config_compat.patch
* kexec-remove-never-used-member-destination-in-kimage.patch
* kexec-fix-a-typo-in-comment.patch
* vmcore-fix-pt_note-n_namesz-n_descsz-overflow-issue.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* rbtree-fix-typo-in-comment.patch
* fs-affs-fix-casting-in-printed-messages.patch
* fs-affs-filec-replace-if-bug-by-bug_on.patch
  linux-next.patch
* drivers-gpio-gpio-zevioc-fix-build.patch
* livepatching-handle-ancient-compilers-with-more-grace.patch
* livepatching-handle-ancient-compilers-with-more-grace-checkpatch-fixes.patch
* dt-bindings-use-isil-prefix-for-intersil.patch
* rtc-isl12022-deprecate-use-of-isl-in-compatible-string-for-isil.patch
* rtc-isl12057-deprecate-use-of-isl-in-compatible-string-for-isil.patch
* staging-iio-isl29028-deprecate-use-of-isl-in-compatible-string-for-isil.patch
* arm-dts-zynq-update-isl9305-compatible-string-to-use-isil-vendor-prefix.patch
* arm-dts-tegra-update-isl29028-compatible-string-to-use-isil-vendor-prefix.patch
* w1-call-put_device-if-device_register-fails.patch
* mm-add-strictlimit-knob-v2.patch
  make-sure-nobodys-leaking-resources.patch
  journal_add_journal_head-debug.patch
  journal_add_journal_head-debug-fix.patch
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
