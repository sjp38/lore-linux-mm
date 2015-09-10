Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id B4E4A6B0038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 19:30:57 -0400 (EDT)
Received: by qgt47 with SMTP id 47so49646246qgt.2
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 16:30:57 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g33si15390000qge.118.2015.09.10.16.30.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Sep 2015 16:30:56 -0700 (PDT)
Date: Thu, 10 Sep 2015 16:30:54 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2015-09-10-16-30 uploaded
Message-ID: <55f212ae.jOhLy+/WerFdt/xh%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz

The mm-of-the-moment snapshot 2015-09-10-16-30 has been uploaded to

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


This mmotm tree contains the following patches against 4.2:
(patches marked "*" will be included in linux-next)

  origin.patch
  zpool-add-zpool_has_pool.patch
  zswap-dynamic-pool-creation.patch
  zswap-change-zpool-compressor-at-runtime.patch
  zswap-update-docs-for-runtime-changeable-attributes.patch
  memcg-add-page_cgroup_ino-helper.patch
  hwpoison-use-page_cgroup_ino-for-filtering-by-memcg.patch
  memcg-zap-try_get_mem_cgroup_from_page.patch
  proc-add-kpagecgroup-file.patch
  mmu-notifier-add-clear_young-callback.patch
  proc-add-kpageidle-file.patch
  proc-export-idle-flag-via-kpageflags.patch
  proc-add-cond_resched-to-proc-kpage-read-write-loop.patch
  procfs-always-expose-proc-pid-map_files-and-make-it-readable.patch
  proc-change-proc_subdir_lock-to-a-rwlock.patch
  fix-list_poison12-offset.patch
  remove-not-used-poison-pointer-macros.patch
  extable-remove-duplicated-include-from-extablec.patch
  cred-remove-unnecessary-kdebug-atomic-reads.patch
  printk-include-pr_fmt-in-pr_debug_ratelimited.patch
  maintainers-credits-mark-maxraid-as-orphan-move-anil-ravindranath-to-credits.patch
  kstrto-accept-0-for-signed-conversion.patch
  lib-bitmapc-correct-a-code-style-and-do-some-optimization.patch
  lib-bitmapc-fix-a-special-string-handling-bug-in-__bitmap_parselist.patch
  lib-bitmapc-bitmap_parselist-can-accept-string-with-whitespaces-on-head-or-tail.patch
  hexdump-do-not-print-debug-dumps-for-config_debug.patch
  lib-string_helpers-clarify-esc-arg-in-string_escape_mem.patch
  lib-string_helpers-rename-esc-arg-to-only.patch
  test_kasan-just-fix-a-typo.patch
  test_kasan-make-kmalloc_oob_krealloc_less-more-correctly.patch
  checkpatch-warn-on-bare-sha-1-commit-ids-in-commit-logs.patch
  checkpatch-add-warning-on-bug-bug_on-use.patch
  checkpatch-improve-suspect_code_indent-test.patch
  checkpatch-allow-longer-declaration-macros.patch
  checkpatch-add-some-foo_destroy-functions-to-needless_if-tests.patch
  checkpatch-report-the-right-line-when-using-emacs-and-file.patch
  checkpatch-always-check-block-comment-styles.patch
  checkpatch-make-strict-the-default-for-drivers-staging-files-and-patches.patch
  checkpatch-emit-an-error-on-formats-with-0x%decimal.patch
  checkpatch-avoid-some-commit-message-long-line-warnings.patch
  checkpatch-fix-left-brace-warning.patch
  checkpatch-add-__pmem-to-sparse-annotations.patch
  checkpatch-add-constant-comparison-on-left-side-test.patch
  fs-coda-fix-readlink-buffer-overflow.patch
  hfshfsplus-cache-pages-correctly-between-bnode_create-and-bnode_free.patch
  hfs-fix-b-tree-corruption-after-insertion-at-position-0.patch
  kmod-correct-documentation-of-return-status-of-request_module.patch
  kmod-bunch-of-internal-functions-renames.patch
  kmod-remove-unecessary-explicit-wide-cpu-affinity-setting.patch
  kmod-add-up-to-date-explanations-on-the-purpose-of-each-asynchronous-levels.patch
  kmod-use-system_unbound_wq-instead-of-khelper.patch
  kmod-handle-umh_wait_proc-from-system-unbound-workqueue.patch
  fs-if-a-coredump-already-exists-unlink-and-recreate-with-o_excl.patch
  fs-dont-dump-core-if-the-corefile-would-become-world-readable.patch
  seq_file-provide-an-analogue-of-print_hex_dump.patch
  crypto-qat-use-seq_hex_dump-to-dump-buffers.patch
  parisc-use-seq_hex_dump-to-dump-buffers.patch
  zcrypt-use-seq_hex_dump-to-dump-buffers.patch
  kmemleak-use-seq_hex_dump-to-dump-buffers.patch
  wil6210-use-seq_hex_dump-to-dump-buffers.patch
  kexec-split-kexec_file-syscall-code-to-kexec_filec.patch
  kexec-split-kexec_load-syscall-from-kexec-core-code.patch
  kexec-remove-the-unnecessary-conditional-judgement-to-simplify-the-code-logic.patch
  align-crash_notes-allocation-to-make-it-be-inside-one-physical-page.patch
  kexec-export-kernel_image_size-to-vmcoreinfo.patch
  sysctl-fix-int-unsigned-long-assignments-in-int_min-case.patch
  make-affs-root-lookup-from-blkdev-logical-size.patch
  lib-decompressors-use-real-out-buf-size-for-gunzip-with-kernel.patch
  lib-decompress_unlzma-do-a-null-check-for-pointer.patch
  zlib_deflate-deftree-remove-bi_reverse.patch
  ipc-convert-invalid-scenarios-to-use-warn_on.patch
  namei-fix-warning-while-make-xmldocs-caused-by-nameic.patch
  mm-mark-most-vm_operations_struct-const.patch
  mm-mpx-add-vm_flags_t-vm_flags-arg-to-do_mmap_pgoff.patch
  mm-make-sure-all-file-vmas-have-vm_ops-set.patch
  mm-use-vma_is_anonymous-in-create_huge_pmd-and-wp_huge_pmd.patch
  dma-mapping-consolidate-dma_allocfree_attrscoherent.patch
  dma-mapping-consolidate-dma_allocfree_noncoherent.patch
  dma-mapping-cosolidate-dma_mapping_error.patch
  dma-mapping-consolidate-dma_supported.patch
  dma-mapping-consolidate-dma_set_mask.patch
  sys_membarrier-system-wide-memory-barrier-generic-x86.patch
  selftests-add-membarrier-syscall-test.patch
  selftests-enhance-membarrier-syscall-test.patch
  fs-seq_file-convert-int-seq_vprint-seq_printf-etc-returns-to-void.patch
  fs-seq_file-convert-int-seq_vprint-seq_printf-etc-returns-to-void-fix.patch
  fs-seq_file-convert-int-seq_vprint-seq_printf-etc-returns-to-void-fix-fix.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  drivers-gpu-drm-i915-intel_spritec-fix-build.patch
  drivers-gpu-drm-i915-intel_tvc-fix-build.patch
  arm-mm-do-not-use-virt_to_idmap-for-nommu-systems.patch
* mm-early_ioremap-add-explicit-include-of-asm-early_ioremaph.patch
* revert-ocfs2-dlm-use-list_for_each_entry-instead-of-list_for_each.patch
* scripts-extract-certc-fix-err-call-in-write_cert.patch
* lib-string_helpersc-fix-infinite-loop-in-string_get_size.patch
* fs-ext4-fsyncc-generic_file_fsync-call-based-on-barrier-flag.patch
* ocfs2-extend-transaction-for-ocfs2_remove_rightmost_path-and-ocfs2_update_edge_lengths-before-to-avoid-inconsistency-between-inode-and-et.patch
* extend-enough-credits-for-freeing-one-truncate-record-while-replaying-truncate-records.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* 9p-do-not-overwrite-return-code-when-locking-fails.patch
  mm.patch
* slab-fix-the-unexpected-index-mapping-result-of-kmalloc_sizeindex_node-1.patch
* userfaultfd-selftest-fix.patch
* mm-mlock-refactor-mlock-munlock-and-munlockall-code.patch
* mm-mlock-refactor-mlock-munlock-and-munlockall-code-v7.patch
* mm-mlock-add-new-mlock-system-call.patch
* mm-mlock-add-new-mlock-system-call-v7.patch
* mm-introduce-vm_lockonfault.patch
* mm-introduce-vm_lockonfault-v7.patch
* mm-mlock-add-mlock-flags-to-enable-vm_lockonfault-usage.patch
* mm-mlock-add-mlock-flags-to-enable-vm_lockonfault-usage-v7.patch
* selftests-vm-add-tests-for-lock-on-fault.patch
* selftests-vm-add-tests-for-lock-on-fault-fix.patch
* selftests-vm-add-tests-for-lock-on-fault-fix-2.patch
* selftests-vm-add-tests-for-lock-on-fault-fix-3.patch
* mips-add-entry-for-new-mlock2-syscall.patch
* mm-srcu-ify-shrinkers.patch
* mm-srcu-ify-shrinkers-fix.patch
* mm-srcu-ify-shrinkers-fix-fix.patch
* mm-hugetlb-proc-add-hugetlbpages-field-to-proc-pid-smaps.patch
* mm-hugetlb-proc-add-hugetlbpages-field-to-proc-pid-smaps-fix.patch
* mm-hugetlb-proc-add-hugetlbpages-field-to-proc-pid-status.patch
* mm-hugetlb-proc-add-hugetlbpages-field-to-proc-pid-status-v5.patch
* page-flags-trivial-cleanup-for-pagetrans-helpers.patch
* page-flags-introduce-page-flags-policies-wrt-compound-pages.patch
* page-flags-introduce-page-flags-policies-wrt-compound-pages-fix.patch
* page-flags-define-pg_locked-behavior-on-compound-pages.patch
* page-flags-define-behavior-of-fs-io-related-flags-on-compound-pages.patch
* page-flags-define-behavior-of-lru-related-flags-on-compound-pages.patch
* page-flags-define-behavior-slb-related-flags-on-compound-pages.patch
* page-flags-define-behavior-of-xen-related-flags-on-compound-pages.patch
* page-flags-define-pg_reserved-behavior-on-compound-pages.patch
* page-flags-define-pg_swapbacked-behavior-on-compound-pages.patch
* page-flags-define-pg_swapcache-behavior-on-compound-pages.patch
* page-flags-define-pg_mlocked-behavior-on-compound-pages.patch
* page-flags-define-pg_uncached-behavior-on-compound-pages.patch
* page-flags-define-pg_uptodate-behavior-on-compound-pages.patch
* page-flags-look-on-head-page-if-the-flag-is-encoded-in-page-mapping.patch
* mm-sanitize-page-mapping-for-tail-pages.patch
* include-linux-page-flagsh-rename-macros-to-avoid-collisions.patch
* mm-increase-swap_cluster_max-to-batch-tlb-flushes.patch
* mm-vmscan-fix-the-page-state-calculation-in-too_many_isolated.patch
* mm-page_isolation-check-pfn-validity-before-access.patch
* mm-fix-invalid-use-of-pfn_valid_within-in-test_pages_in_a_zone.patch
* fs-mpagec-forgotten-write_sync-in-case-of-data-integrity-write.patch
* x86-add-pmd_-for-thp.patch
* x86-add-pmd_-for-thp-fix.patch
* sparc-add-pmd_-for-thp.patch
* sparc-add-pmd_-for-thp-fix.patch
* powerpc-add-pmd_-for-thp.patch
* arm-add-pmd_mkclean-for-thp.patch
* arm64-add-pmd_-for-thp.patch
* mm-support-madvisemadv_free.patch
* mm-support-madvisemadv_free-fix.patch
* mm-support-madvisemadv_free-fix-2.patch
* mm-support-madvisemadv_free-fix-3.patch
* mm-dont-split-thp-page-when-syscall-is-called.patch
* mm-dont-split-thp-page-when-syscall-is-called-fix.patch
* mm-dont-split-thp-page-when-syscall-is-called-fix-2.patch
* mm-dont-split-thp-page-when-syscall-is-called-fix-3.patch
* mm-free-swp_entry-in-madvise_free.patch
* mm-move-lazy-free-pages-to-inactive-list.patch
* mm-move-lazy-free-pages-to-inactive-list-fix.patch
* mm-move-lazy-free-pages-to-inactive-list-fix-fix.patch
* mm-move-lazy-free-pages-to-inactive-list-fix-fix-fix.patch
* use-poison_pointer_delta-for-poison-pointers.patch
* lib-vsprintf-add-%pt-format-specifier.patch
* mm-utilc-add-kstrimdup.patch
* lib-add-crc64-ecma-module.patch
* fat-add-fat_fallocate-operation.patch
* fat-skip-cluster-allocation-on-fallocated-region.patch
* fat-permit-to-return-phy-block-number-by-fibmap-in-fallocated-region.patch
* documentation-filesystems-vfattxt-update-the-limitation-for-fat-fallocate.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* w1-masters-omap_hdq-add-support-for-1-wire-mode.patch
* ipc-msgc-msgsnd-use-freezable-blocking-call.patch
* msgrcv-use-freezable-blocking-call.patch
  linux-next.patch
  linux-next-rejects.patch
* drivers-net-ieee802154-at86rf230c-seq_printf-now-returns-null.patch
* w1-call-put_device-if-device_register-fails.patch
  x86-numa-acpi-online-node-earlier-when-doing-cpu-hot-addition.patch
  kernel-profilec-replace-cpu_to_mem-with-cpu_to_node.patch
  sgi-xp-replace-cpu_to_node-with-cpu_to_mem-to-support-memoryless-node.patch
  openvswitch-replace-cpu_to_node-with-cpu_to_mem-to-support-memoryless-node.patch
  i40e-use-numa_mem_id-to-better-support-memoryless-node.patch
  i40evf-use-numa_mem_id-to-better-support-memoryless-node.patch
  x86-numa-kill-useless-code-to-improve-code-readability.patch
  mm-update-_mem_id_-for-every-possible-cpu-when-memory-configuration-changes.patch
  mm-x86-enable-memoryless-node-support-to-better-support-cpu-memory-hotplug.patch
  uaccess-reimplement-probe_kernel_address-using-probe_kernel_read.patch
  uaccess-reimplement-probe_kernel_address-using-probe_kernel_read-fix.patch
  lib-dynamic_debugc-use-kstrdup_const.patch
  inotify-actually-check-for-invalid-bits-in-sys_inotify_add_watch.patch
  inotify-actually-check-for-invalid-bits-in-sys_inotify_add_watch-v2.patch
  scripts-kernel-doc-processing-nofunc-for-functions-only.patch
  mm-mmapc-remove-useless-statement-vma-=-null-in-find_vma.patch
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
