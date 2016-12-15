Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5622E6B0253
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 19:01:18 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f188so66828385pgc.1
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 16:01:18 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h63si54936268pge.110.2016.12.14.16.01.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Dec 2016 16:01:17 -0800 (PST)
Date: Wed, 14 Dec 2016 16:02:05 -0800
From: akpm@linux-foundation.org
Subject: mmotm 2016-12-14-16-01 uploaded
Message-ID: <5851dd7d.0C/EP/j+qRRD2rph%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2016-12-14-16-01 has been uploaded to

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


This mmotm tree contains the following patches against 4.9:
(patches marked "*" will be included in linux-next)

  origin.patch
* btrfs-better-handle-btrfs_printk-defaults.patch
* kernel-watchdog-use-nmi-registers-snapshot-in-hardlockup-handler.patch
* mm-compaction-allow-compaction-for-gfp_nofs-requests.patch
* signals-avoid-unnecessary-taking-of-sighand-siglock.patch
* coredump-clarify-unsafe-core_pattern-warning.patch
* revert-kdump-vmcoreinfo-report-memory-sections-virtual-addresses.patch
* kexec-change-to-export-the-value-of-phys_base-instead-of-symbol-address.patch
* kexec-add-cond_resched-into-kimage_alloc_crash_control_pages.patch
* sysctl-add-kern_cont-to-deprecated_sysctl_warning.patch
* arch-arc-add-option-to-skip-sync-on-dma-mapping.patch
* arch-arm-add-option-to-skip-sync-on-dma-map-and-unmap.patch
* arch-avr32-add-option-to-skip-sync-on-dma-map.patch
* arch-blackfin-add-option-to-skip-sync-on-dma-map.patch
* arch-c6x-add-option-to-skip-sync-on-dma-map-and-unmap.patch
* arch-frv-add-option-to-skip-sync-on-dma-map.patch
* arch-hexagon-add-option-to-skip-dma-sync-as-a-part-of-mapping.patch
* arch-m68k-add-option-to-skip-dma-sync-as-a-part-of-mapping.patch
* arch-metag-add-option-to-skip-dma-sync-as-a-part-of-map-and-unmap.patch
* arch-microblaze-add-option-to-skip-dma-sync-as-a-part-of-map-and-unmap.patch
* arch-mips-add-option-to-skip-dma-sync-as-a-part-of-map-and-unmap.patch
* arch-nios2-add-option-to-skip-dma-sync-as-a-part-of-map-and-unmap.patch
* arch-openrisc-add-option-to-skip-dma-sync-as-a-part-of-mapping.patch
* arch-parisc-add-option-to-skip-dma-sync-as-a-part-of-map-and-unmap.patch
* arch-powerpc-add-option-to-skip-dma-sync-as-a-part-of-mapping.patch
* arch-sh-add-option-to-skip-dma-sync-as-a-part-of-mapping.patch
* arch-sparc-add-option-to-skip-dma-sync-as-a-part-of-map-and-unmap.patch
* arch-tile-add-option-to-skip-dma-sync-as-a-part-of-map-and-unmap.patch
* arch-xtensa-add-option-to-skip-dma-sync-as-a-part-of-mapping.patch
* dma-add-calls-for-dma_map_page_attrs-and-dma_unmap_page_attrs.patch
* mm-add-support-for-releasing-multiple-instances-of-a-page.patch
* igb-update-driver-to-make-use-of-dma_attr_skip_cpu_sync.patch
* igb-update-code-to-better-handle-incrementing-page-count.patch
* relay-check-array-offset-before-using-it.patch
* kconfig-lib-kconfigdebug-fix-references-to-documenation.patch
* kconfig-lib-kconfigubsan-fix-reference-to-ubsan-documentation.patch
* kcov-add-more-missing-include.patch
* debug-more-properly-delay-for-secondary-cpus.patch
* kdb-remove-unused-kdb_event-handling.patch
* kdb-properly-synchronize-vkdb_printf-calls-with-other-cpus.patch
* kdb-call-vkdb_printf-from-vprintk_default-only-when-wanted.patch
* initramfs-select-builtin-initram-compression-algorithm-on-kconfig-instead-of-makefile.patch
* initramfs-allow-again-choice-of-the-embedded-initram-compression-algorithm.patch
* ipc-msg-make-msgrcv-work-with-long_min.patch
* ipc-fixed-warnings.patch
* posix-timers-give-lazy-compilers-some-help-optimizing-code-away.patch
* drivers-net-wireless-intel-iwlwifi-dvm-calibc-fix-min-warning.patch
* ktestpl-fix-english.patch
* watchdog-move-shared-definitions-to-nmih.patch
* watchdog-move-hardlockup-detector-to-separate-file.patch
* sparc-implement-watchdog_nmi_enable-and-watchdog_nmi_disable.patch
* ipc-sem-do-not-call-wake_sem_queue_do-prematurely.patch
* ipc-sem-rework-task-wakeups.patch
* ipc-sem-optimize-perform_atomic_semop.patch
* ipc-sem-explicitly-inline-check_restart.patch
* ipc-sem-use-proper-list-api-for-pending_list-wakeups.patch
* ipc-sem-simplify-wait-wake-loop.patch
* ipc-sem-avoid-idr-tree-lookup-for-interrupted-semop.patch
* mm-add-locked-parameter-to-get_user_pages_remote.patch
* mm-unexport-__get_user_pages_unlocked.patch
* mm-join-struct-fault_env-and-vm_fault.patch
* mm-use-vmf-address-instead-of-of-vmf-virtual_address.patch
* mm-use-pgoff-in-struct-vm_fault-instead-of-passing-it-separately.patch
* mm-use-passed-vm_fault-structure-in-__do_fault.patch
* mm-trim-__do_fault-arguments.patch
* mm-use-passed-vm_fault-structure-for-in-wp_pfn_shared.patch
* mm-add-orig_pte-field-into-vm_fault.patch
* mm-allow-full-handling-of-cow-faults-in-fault-handlers.patch
* mm-factor-out-functionality-to-finish-page-faults.patch
* mm-move-handling-of-cow-faults-into-dax-code.patch
* mm-factor-out-common-parts-of-write-fault-handling.patch
* mm-pass-vm_fault-structure-into-do_page_mkwrite.patch
* mm-use-vmf-page-during-wp-faults.patch
* mm-move-part-of-wp_page_reuse-into-the-single-call-site.patch
* mm-provide-helper-for-finishing-mkwrite-faults.patch
* mm-change-return-values-of-finish_mkwrite_fault.patch
* mm-export-follow_pte.patch
* dax-make-cache-flushing-protected-by-entry-lock.patch
* dax-protect-pte-modification-on-wp-fault-by-radix-tree-entry-lock.patch
* dax-clear-dirty-entry-tags-on-cache-flush.patch
* tools-add-warn_on_once.patch
* radix-tree-test-suite-allow-gfp_atomic-allocations-to-fail.patch
* radix-tree-test-suite-track-preempt_count.patch
* radix-tree-test-suite-free-preallocated-nodes.patch
* radix-tree-test-suite-make-runs-more-reproducible.patch
* radix-tree-test-suite-iteration-test-misuses-rcu.patch
* radix-tree-test-suite-benchmark-for-iterator.patch
* radix-tree-test-suite-use-rcu_barrier.patch
* radix-tree-test-suite-handle-exceptional-entries.patch
* radix-tree-test-suite-record-order-in-each-item.patch
* tools-add-more-bitmap-functions.patch
* radix-tree-test-suite-use-common-find-bit-code.patch
* radix-tree-fix-typo.patch
* radix-tree-move-rcu_head-into-a-union-with-private_list.patch
* radix-tree-create-node_tag_set.patch
* radix-tree-make-radix_tree_find_next_bit-more-useful.patch
* radix-tree-improve-dump-output.patch
* btrfs-fix-race-in-btrfs_free_dummy_fs_info.patch
* radix-tree-improve-multiorder-iterators.patch
* radix-tree-delete-radix_tree_locate_item.patch
* radix-tree-delete-radix_tree_range_tag_if_tagged.patch
* radix-tree-add-radix_tree_join.patch
* radix-tree-add-radix_tree_split.patch
* radix-tree-add-radix_tree_split_preload.patch
* radix-tree-fix-replacement-for-multiorder-entries.patch
* radix-tree-test-suite-check-multiorder-iteration.patch
* idr-add-ida_is_empty.patch
* tpm-use-idr_find-not-idr_find_slowpath.patch
* rxrpc-abstract-away-knowledge-of-idr-internals.patch
* idr-reduce-the-number-of-bits-per-level-from-8-to-6.patch
* radix-tree-test-suite-add-some-more-functionality.patch
* radix-tree-test-suite-cache-recently-freed-objects.patch
* radix-tree-ensure-counts-are-initialised.patch
* radix-tree-test-suite-add-new-tag-check.patch
* radix-tree-test-suite-delete-unused-rcupdatec.patch
  i-need-old-gcc.patch
* arm64-setup-introduce-kaslr_offset.patch
* kcov-make-kcov-work-properly-with-kaslr-enabled.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called.patch
* ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called-fix.patch
* ocfs2-fix-crash-caused-by-stale-lvb-with-fsdlm-plugin.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
  mm.patch
* z3fold-limit-first_num-to-the-actual-range-of-possible-buddy-indexes.patch
* z3fold-make-pages_nr-atomic.patch
* z3fold-extend-compaction-function.patch
* z3fold-use-per-page-spinlock.patch
* z3fold-discourage-use-of-pages-that-werent-compacted.patch
* z3fold-fix-header-size-related-issues.patch
* z3fold-fix-locking-issues.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* mm-walk-the-zone-in-pageblock_nr_pages-steps.patch
* lib-add-crc64-ecma-module.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* ipc-semc-avoid-using-spin_unlock_wait.patch
* ipc-sem-add-hysteresis.patch
  linux-next.patch
  linux-next-git-rejects.patch
* radix-tree-test-suite-fix-compilation.patch
* powerpc-ima-get-the-kexec-buffer-passed-by-the-previous-kernel.patch
* ima-on-soft-reboot-restore-the-measurement-list.patch
* ima-permit-duplicate-measurement-list-entries.patch
* ima-maintain-memory-size-needed-for-serializing-the-measurement-list.patch
* powerpc-ima-send-the-kexec-buffer-to-the-next-kernel.patch
* ima-on-soft-reboot-save-the-measurement-list.patch
* ima-store-the-builtin-custom-template-definitions-in-a-list.patch
* ima-support-restoring-multiple-template-formats.patch
* ima-define-a-canonical-binary_runtime_measurements-list-format.patch
* ima-platform-independent-hash-value.patch
* reimplement-idr-and-ida-using-the-radix-tree.patch
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
