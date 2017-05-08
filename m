Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7D4AA6B03DD
	for <linux-mm@kvack.org>; Mon,  8 May 2017 19:31:02 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b17so74668547pfd.1
        for <linux-mm@kvack.org>; Mon, 08 May 2017 16:31:02 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w65si3646976pgb.340.2017.05.08.16.31.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 May 2017 16:31:01 -0700 (PDT)
Date: Mon, 08 May 2017 16:30:58 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2017-05-08-16-30 uploaded
Message-ID: <5910ffb2.xcjYICxfDi+4/blD%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2017-05-08-16-30 has been uploaded to

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


This mmotm tree contains the following patches against 4.11:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
* mm-compaction-reorder-fields-in-struct-compact_control.patch
* mm-compaction-remove-redundant-watermark-check-in-compact_finished.patch
* mm-page_alloc-split-smallest-stolen-page-in-fallback.patch
* mm-page_alloc-count-movable-pages-when-stealing-from-pageblock.patch
* mm-compaction-change-migrate_async_suitable-to-suitable_migration_source.patch
* mm-compaction-add-migratetype-to-compact_control.patch
* mm-compaction-restrict-async-compaction-to-pageblocks-of-same-migratetype.patch
* mm-compaction-finish-whole-pageblock-to-reduce-fragmentation.patch
* proc-remove-cast-from-memory-allocation.patch
* proc-sysctl-fix-the-int-overflow-for-jiffies-conversion.patch
* drivers-virt-use-get_user_pages_unlocked.patch
* jiffiesh-declare-jiffies-and-jiffies_64-with-____cacheline_aligned_in_smp.patch
* make-help-add-tools-help-target.patch
* locking-hung_task-defer-showing-held-locks.patch
* vmci-fix-a-couple-integer-overflow-tests.patch
* c2port-checking-for-null-instead-of-is_err.patch
* revert-lib-test_sortc-make-it-explicitly-non-modular.patch
* lib-add-module-support-to-array-based-sort-tests.patch
* lib-add-module-support-to-linked-list-sorting-tests.patch
* firmware-makefile-force-recompilation-if-makefile-changes.patch
* checkpatch-remove-obsolete-config_experimental-checks.patch
* checkpatch-add-ability-to-find-bad-uses-of-vsprintf-%pfoo-extensions.patch
* checkpatch-improve-embedded_function_name-test.patch
* checkpatch-allow-space-leading-blank-lines-in-email-headers.patch
* checkpatch-avoid-suggesting-struct-definitions-should-be-const.patch
* checkpatch-improve-multistatement_macro_use_do_while-test.patch
* checkpatch-clarify-the-embedded_function_name-message.patch
* checkpatch-special-audit-for-revert-commit-line.patch
* checkpatch-improve-kalloc-with-multiplication-and-sizeof-test.patch
* checkpatch-add-typedefsfile.patch
* checkpatch-improve-the-embedded-function-name-test-for-patch-contexts.patch
* checkpatch-improve-the-suspect_code_indent-test.patch
* reiserfs-use-designated-initializers.patch
* fork-free-vmapped-stacks-in-cache-when-cpus-are-offline.patch
* cpumask-make-nr_cpumask_bits-unsigned.patch
* crash-move-crashkernel-parsing-and-vmcore-related-code-under-config_crash_core.patch
* ia64-reuse-append_elf_note-and-final_note-functions.patch
* powerpc-fadump-remove-dependency-with-config_kexec.patch
* powerpc-fadump-reuse-crashkernel-parameter-for-fadump-memory-reservation.patch
* powerpc-fadump-update-documentation-about-crashkernel-parameter-reuse.patch
* pidns-disable-pid-allocation-if-pid_ns_prepare_proc-is-failed-in-alloc_pid.patch
* ns-allow-ns_entries-to-have-custom-symlink-content.patch
* pidns-expose-task-pid_ns_for_children-to-userspace.patch
* taskstats-add-e-u-stime-for-tgid-command.patch
* kcov-simplify-interrupt-check.patch
* fault-inject-use-correct-check-for-interrupts.patch
* zlib-inflate-fix-potential-buffer-overflow.patch
* initramfs-provide-a-way-to-ignore-image-provided-by-bootloader.patch
* initramfs-use-vfs_stat-lstat-directly.patch
* ipc-shm-some-shmat-cleanups.patch
* sysvipc-cacheline-align-kern_ipc_perm.patch
* mm-introduce-kvalloc-helpers.patch
* mm-vmalloc-properly-track-vmalloc-users.patch
* mm-support-__gfp_repeat-in-kvmalloc_node-for-32kb.patch
* rhashtable-simplify-a-strange-allocation-pattern.patch
* ila-simplify-a-strange-allocation-pattern.patch
* xattr-zero-out-memory-copied-to-userspace-in-getxattr.patch
* treewide-use-kvalloc-rather-than-opencoded-variants.patch
* net-use-kvmalloc-with-__gfp_repeat-rather-than-open-coded-variant.patch
* md-use-kvmalloc-rather-than-opencoded-variant.patch
* bcache-use-kvmalloc.patch
* mm-swap-use-kvzalloc-to-allocate-some-swap-data-structure.patch
* mm-vmalloc-use-__gfp_highmem-implicitly.patch
* scripts-spellingtxt-add-memory-pattern-and-fix-typos.patch
* scripts-spellingtxt-add-regsiter-register-spelling-mistake.patch
* scripts-spellingtxt-add-intialised-pattern-and-fix-typo-instances.patch
* treewide-correct-diffrent-and-banlance-typos.patch
* treewide-move-set_memory_-functions-away-from-cacheflushh.patch
* arm-use-set_memoryh-header.patch
* arm64-use-set_memoryh-header.patch
* s390-use-set_memoryh-header.patch
* x86-use-set_memoryh-header.patch
* agp-use-set_memoryh-header.patch
* drm-use-set_memoryh-header.patch
* intel_th-use-set_memoryh-header.patch
* watchdog-hpwdt-use-set_memoryh-header.patch
* bpf-use-set_memoryh-header.patch
* module-use-set_memoryh-header.patch
* pm-hibernate-use-set_memoryh-header.patch
* alsa-use-set_memoryh-header.patch
* misc-sram-use-set_memoryh-header.patch
* video-vermilion-use-set_memoryh-header.patch
* drivers-staging-media-atomisp-pci-atomisp2-use-set_memoryh.patch
* treewide-decouple-cacheflushh-and-set_memoryh.patch
* kref-remove-warn_on-for-null-release-functions.patch
* megasas-remove-expensive-inline-from-megasas_return_cmd.patch
* remove-expensive-warn_on-in-pagefault_disabled_dec.patch
* fs-remove-set-but-not-checked-aop_flag_uninterruptible-flag.patch
* docs-vm-transhuge-fix-few-trivial-typos.patch
* format-security-move-static-strings-to-const.patch
* fs-f2fs-use-ktime_get_real_seconds-for-sit_info-times.patch
* trace-make-trace_hwlat-timestamp-y2038-safe.patch
* fs-cifs-replace-current_time-by-other-appropriate-apis.patch
* fs-ceph-current_time-with-ktime_get_real_ts.patch
* fs-ufs-use-ktime_get_real_ts64-for-birthtime.patch
* fs-ubifs-replace-current_time_sec-with-current_time.patch
* lustre-replace-current_time-macro.patch
* apparmorfs-replace-current_time-with-current_time.patch
* gfs2-replace-current_time-with-current_time.patch
* time-delete-current_time_sec-and-current_time.patch
* mm-huge_memory-use-zap_deposited_table-more.patch
* mm-huge_memory-deposit-a-pgtable-for-dax-pmd-faults-when-required.patch
* mm-prevent-potential-recursive-reclaim-due-to-clearing-pf_memalloc.patch
* mm-introduce-memalloc_noreclaim_saverestore.patch
* treewide-convert-pf_memalloc-manipulations-to-new-helpers.patch
* mtd-nand-nandsim-convert-to-memalloc_noreclaim_.patch
* dax-add-tracepoints-to-dax_iomap_pte_fault.patch
* dax-add-tracepoints-to-dax_pfn_mkwrite.patch
* dax-add-tracepoints-to-dax_load_hole.patch
* dax-add-tracepoints-to-dax_writeback_mapping_range.patch
* dax-add-tracepoint-to-dax_writeback_one.patch
* dax-add-tracepoint-to-dax_insert_mapping.patch
* selftests-vm-add-a-test-for-virtual-address-range-mapping.patch
* drivers-staging-ccree-ssi_hashc-fix-build-with-gcc-444.patch
* mm-uncharge-poisoned-pages.patch
* mm-skip-hwpoisoned-pages-when-onlining-pages.patch
* mm-vmstat-remove-spurious-warn-during-zoneinfo-print.patch
* gcov-support-gcc-71.patch
* gcov-support-gcc-71-v2.patch
* gcov-support-gcc-71-v2-checkpatch-fixes.patch
* mm-khugepaged-add-missed-tracepoint-for-collapse_huge_page_swapin.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called.patch
* ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called-fix.patch
* ocfs2-dlm-optimization-of-code-while-free-dead-node-locks.patch
* ocfs2-dlm-optimization-of-code-while-free-dead-node-locks-checkpatch-fixes.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
  mm.patch
* mm-page_alloc-return-0-in-case-this-node-has-no-page-within-the-zone.patch
* mm-vmscan-do-not-pass-reclaimed-slab-to-vmpressure.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* mm-walk-the-zone-in-pageblock_nr_pages-steps.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* uapi-fix-linux-sysctlh-userspace-compilation-errors.patch
* scripts-gdb-add-lx-fdtdump-command.patch
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
  linux-next.patch
* imx7-fix-kconfig-warning-and-build-errors.patch
* sparc64-ng4-memset-32-bits-overflow.patch
* mm-zeroing-hash-tables-in-allocator.patch
* mm-updated-callers-to-use-hash_zero-flag.patch
* mm-adaptive-hash-table-scaling.patch
* time-delete-current_fs_time-function.patch
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
