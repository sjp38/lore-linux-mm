Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 436686B0038
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 19:18:48 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id u62so2202320pfk.1
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 16:18:48 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e1si8665239pln.238.2017.02.24.16.18.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Feb 2017 16:18:46 -0800 (PST)
Date: Fri, 24 Feb 2017 16:18:45 -0800
From: akpm@linux-foundation.org
Subject: mmotm 2017-02-24-16-18 uploaded
Message-ID: <58b0cd65.pGXRTxXbRsA3tfXs%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2017-02-24-16-18 has been uploaded to

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


This mmotm tree contains the following patches against 4.10:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
* cris-use-generic-currenth.patch
* mm-ksm-improve-deduplication-of-zero-pages-with-colouring.patch
* mm-oom-header-nodemask-is-null-when-cpusets-are-disabled.patch
* mm-devm_memremap_pages-hold-device_hotplug-lock-over-mem_hotplug_begin-done.patch
* mm-validate-device_hotplug-is-held-for-memory-hotplug.patch
* mm-memory_hotplugc-unexport-__remove_pages.patch
* memblock-let-memblock_type_name-know-about-physmem-type.patch
* memblock-also-dump-physmem-list-within-__memblock_dump_all.patch
* memblock-embed-memblock-type-name-within-struct-memblock_type.patch
* userfaultfd-non-cooperative-rename-event_madvdontneed-to-event_remove.patch
* userfaultfd-non-cooperative-add-madvise-event-for-madv_remove-request.patch
* userfaultfd-non-cooperative-selftest-enable-remove-event-test-for-shmem.patch
* mm-vmscan-scan-dirty-pages-even-in-laptop-mode.patch
* mm-vmscan-kick-flushers-when-we-encounter-dirty-pages-on-the-lru.patch
* mm-vmscan-remove-old-flusher-wakeup-from-direct-reclaim-path.patch
* mm-vmscan-only-write-dirty-pages-that-the-scanner-has-seen-twice.patch
* mm-vmscan-move-dirty-pages-out-of-the-way-until-theyre-flushed.patch
* mm-page_alloc-split-buffered_rmqueue.patch
* mm-page_alloc-split-alloc_pages_nodemask.patch
* mm-page_alloc-drain-per-cpu-pages-from-workqueue-context.patch
* mm-page_alloc-do-not-depend-on-cpu-hotplug-locks-inside-the-allocator.patch
* mm-page_alloc-only-use-per-cpu-allocator-for-irq-safe-requests.patch
* mm-fs-reduce-fault-page_mkwrite-and-pfn_mkwrite-to-take-only-vmf.patch
* mm-fix-comments-for-mmap_init.patch
* zram-remove-waitqueue-for-io-done.patch
* mm-page_alloc-remove-redundant-checks-from-alloc-fastpath.patch
* mm-page_alloc-dont-check-cpuset-allowed-twice-in-fast-path.patch
* mm-page_alloc-use-static-global-work_struct-for-draining-per-cpu-pages.patch
* mmfsdax-change-pmd_fault-to-huge_fault.patch
* mm-x86-add-support-for-pud-sized-transparent-hugepages.patch
* dax-support-for-transparent-pud-pages-for-device-dax.patch
* mm-replace-fault_flag_size-with-parameter-to-huge_fault.patch
* mm-fix-get_user_pages-vs-device-dax-pud-mappings.patch
* z3fold-make-pages_nr-atomic.patch
* z3fold-fix-header-size-related-issues.patch
* z3fold-extend-compaction-function.patch
* z3fold-use-per-page-spinlock.patch
* z3fold-add-kref-refcounting.patch
* mm-migration-make-isolate_movable_page-return-int-type.patch
* mm-migration-make-isolate_movable_page-always-defined.patch
* hwpoison-soft-offlining-for-non-lru-movable-page.patch
* mm-hotplug-enable-memory-hotplug-for-non-lru-movable-pages.patch
* uprobes-split-thps-before-trying-replace-them.patch
* mm-introduce-page_vma_mapped_walk.patch
* mm-fix-handling-pte-mapped-thps-in-page_referenced.patch
* mm-fix-handling-pte-mapped-thps-in-page_idle_clear_pte_refs.patch
* mm-rmap-check-all-vmas-that-pte-mapped-thp-can-be-part-of.patch
* mm-convert-page_mkclean_one-to-use-page_vma_mapped_walk.patch
* mm-convert-try_to_unmap_one-to-use-page_vma_mapped_walk.patch
* mm-ksm-convert-write_protect_page-to-use-page_vma_mapped_walk.patch
* mm-uprobes-convert-__replace_page-to-use-page_vma_mapped_walk.patch
* mm-convert-page_mapped_in_vma-to-use-page_vma_mapped_walk.patch
* mm-drop-page_check_address_transhuge.patch
* mm-convert-remove_migration_pte-to-use-page_vma_mapped_walk.patch
* mm-call-vm_munmap-in-munmap-syscall-instead-of-using-open-coded-version.patch
* userfaultfd-non-cooperative-add-event-for-memory-unmaps.patch
* userfaultfd-non-cooperative-add-event-for-exit-notification.patch
* userfaultfd-mcopy_atomic-return-enoent-when-no-compatible-vma-found.patch
* userfaultfd_copy-return-enospc-in-case-mm-has-gone.patch
* userfaultfd-documentation-update.patch
* mm-alloc_contig_range-allow-to-specify-gfp-mask.patch
* mm-cma_alloc-allow-to-specify-gfp-mask.patch
* mm-wire-up-gfp-flag-passing-in-dma_alloc_from_contiguous.patch
* mm-madvise-fail-with-enomem-when-splitting-vma-will-hit-max_map_count.patch
* mm-cma-print-allocation-failure-reason-and-bitmap-status.patch
* vmalloc-back-of-when-the-current-is-killed.patch
* mm-page_alloc-remove-duplicate-page_exth.patch
* mm-fix-sparse-use-plain-integer-as-null-pointer.patch
* mm-fix-checkpatch-warnings-whitespace.patch
* drm-remove-unnecessary-fault-wrappers.patch
* mm-vmscan-clear-pgdat_writeback-when-zone-is-balanced.patch
* shm-fix-unlikely-test-of-info-seals-to-test-only-for-write-and-grow.patch
* mm-autonuma-dont-use-set_pte_at-when-updating-protnone-ptes.patch
* mm-autonuma-let-architecture-override-how-the-write-bit-should-be-stashed-in-a-protnone-pte.patch
* mm-ksm-handle-protnone-saved-writes-when-making-page-write-protect.patch
* powerpc-mm-autonuma-switch-ppc64-to-its-own-implementeation-of-saved-write.patch
* mm-place-not-inside-of-unlikely-statement-in-wb_domain_writeout_inc.patch
* zram-extend-zero-pages-to-same-element-pages.patch
* mm-fix-a-overflow-in-test_pages_in_a_zone.patch
* mm-page_alloc-fix-nodes-for-reclaim-in-fast-path.patch
* mm-remove-shmem_mapping-shmem_zero_setup-duplicates.patch
* mm-vmpressure-fix-sending-wrong-events-on-underflow.patch
* mm-zsmalloc-remove-redundant-setpageprivate2-in-create_page_chain.patch
* mm-page_alloc-remove-redundant-init-code-for-zone_movable.patch
* mm-zsmalloc-fix-comment-in-zsmalloc.patch
* mm-cleanups-for-printing-phys_addr_t-and-dma_addr_t.patch
* mm-gup-check-for-protnone-only-if-it-is-a-pte-entry.patch
* mm-thp-autonuma-use-tnf-flag-instead-of-vm-fault.patch
* mm-do-not-access-page-mapping-directly-on-page_endio.patch
* memory-hotplug-use-dev_online-for-memhp_auto_online.patch
* kasan-drain-quarantine-of-memcg-slab-objects.patch
* kasan-add-memcg-kmem_cache-test.patch
* frv-pci-frv-fix-build-warning.patch
* alpha-use-generic-currenth.patch
* proc-use-rb_entry.patch
* proc-less-code-duplication-in-proc-cmdline.patch
* procfs-use-an-enum-for-possible-hidepid-values.patch
* uapi-mqueueh-add-missing-linux-typesh-include.patch
* iopoll-include-linux-ktimeh-instead-of-linux-hrtimerh.patch
* compiler-gcch-added-a-new-macro-to-wrap-gcc-attribute.patch
* m68k-replaced-gcc-specific-macros-with-ones-from-compilerh.patch
* bug-switch-data-corruption-check-to-__must_check.patch
* mm-balloon-umount-balloon_mnt-when-remove-vb-device.patch
* notifier-simplify-expression.patch
* kernel-ksysfs-add-__ro_after_init-to-bin_attribute-structure.patch
* lib-add-module-support-to-crc32-tests.patch
* lib-add-module-support-to-glob-tests.patch
* lib-add-module-support-to-atomic64-tests.patch
* find_bit-micro-optimise-find_next__bit.patch
* linux-kernelh-fix-div_round_closest-to-support-negative-divisors.patch
* rbtree-use-designated-initializers.patch
* lib-add-config_test_sort-to-enable-self-test-of-sort.patch
* lib-test_sort-make-it-explicitly-non-modular.patch
* lib-update-lz4-compressor-module.patch
* lib-decompress_unlz4-change-module-to-work-with-new-lz4-module-version.patch
* crypto-change-lz4-modules-to-work-with-new-lz4-module-version.patch
* fs-pstore-fs-squashfs-change-usage-of-lz4-to-work-with-new-lz4-version.patch
* lib-lz4-remove-back-compat-wrappers.patch
* checkpatch-warn-on-embedded-function-names.patch
* checkpatch-warn-on-logging-continuations.patch
* checkpatch-update-logfunctions.patch
* checkpatch-add-another-old-address-for-the-fsf.patch
* checkpatch-notice-unbalanced-else-braces-in-a-patch.patch
* checkpatch-remove-false-unbalanced-braces-warning.patch
* scatterlist-dont-overflow-length-field.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called.patch
* ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called-fix.patch
* ocfs2-dlm-optimization-of-code-while-free-dead-node-locks.patch
* ocfs2-dlm-optimization-of-code-while-free-dead-node-locks-checkpatch-fixes.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
  mm.patch
* zswap-allow-initialization-at-boot-without-pool.patch
* zswap-clear-compressor-or-zpool-param-if-invalid-at-init.patch
* zswap-dont-param_set_charp-while-holding-spinlock.patch
* mm-page_alloc-return-0-in-case-this-node-has-no-page-within-the-zone.patch
* mm-vmscan-do-not-pass-reclaimed-slab-to-vmpressure.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* mm-walk-the-zone-in-pageblock_nr_pages-steps.patch
* kprobes-move-kprobe-declarations-to-asm-generic-kprobesh.patch
* kprobes-move-kprobe-declarations-to-asm-generic-kprobesh-fix.patch
* kprobes-move-kprobe-declarations-to-asm-generic-kprobesh-fix-2.patch
* autofs-remove-wrong-comment.patch
* autofs-fix-typo-in-documentation.patch
* autofs-fix-wrong-ioctl-documentation-regarding-devid.patch
* autofs-update-ioctl-documentation-regarding-struct-autofs_dev_ioctl.patch
* autofs-add-command-enum-macros-for-root-dir-ioctls.patch
* autofs-remove-duplicated-autofs_dev_ioctl_size-definition.patch
* autofs-take-more-care-to-not-update-last_used-on-path-walk.patch
* hfs-fix-fix-hfs_readdir.patch
* hfs-atomically-read-inode-size.patch
* hfsplus-atomically-read-inode-size.patch
* fs-reiserfs-atomically-read-inode-size.patch
* sigaltstack-support-ss_autodisarm-for-config_compat.patch
* tests-improve-output-of-sigaltstack-testcase.patch
* proc-kcore-update-physical-address-for-kcore-ram-and-text.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* rapidio-use-get_user_pages_unlocked.patch
* uapi-fix-linux-sysctlh-userspace-compilation-errors.patch
* pid-use-for_each_thread-in-do_each_pid_thread.patch
* fseventpoll-dont-test-for-bitfield-with-stack-value.patch
* fs-affs-remove-reference-to-affs_parent_ino.patch
* fs-affs-add-validation-block-function.patch
* fs-affs-make-affs-exportable.patch
* fs-affs-use-octal-for-permissions.patch
* fs-affs-add-prefix-to-some-functions.patch
* fs-affs-nameic-forward-declarations-clean-up.patch
* fs-affs-make-export-work-with-cold-dcache.patch
* fs-affs-make-export-work-with-cold-dcache-fix.patch
* config-android-recommended-disable-aio-support.patch
* config-android-base-enable-hardened-usercopy-and-kernel-aslr.patch
* fonts-keep-non-sparc-fonts-listed-together.patch
* scripts-gdb-add-lx-fdtdump-command.patch
* initramfs-finish-fput-before-accessing-any-binary-from-initramfs.patch
* ipc-semc-avoid-using-spin_unlock_wait.patch
* ipc-sem-add-hysteresis.patch
* ipc-mqueue-add-missing-sparse-annotation.patch
* ipc-shm-fix-shmat-mmap-nil-page-protection.patch
* scatterlist-reorder-compound-boolean-expression.patch
* scatterlist-do-not-disable-irqs-in-sg_copy_buffer.patch
  linux-next.patch
  linux-next-rejects.patch
  linux-next-git-rejects.patch
* fs-add-i_blocksize.patch
* fs-add-i_blocksize-fix.patch
* nilfs2-use-nilfs_btree_node_size.patch
* nilfs2-use-i_blocksize.patch
* scripts-spellingtxt-add-swith-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-swithc-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-an-user-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-an-union-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-an-one-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-partiton-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-aligment-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-algined-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-efective-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-varible-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-embeded-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-againt-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-neded-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-unneded-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-intialization-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-initialiazation-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-intialised-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-comsumer-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-disbled-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-overide-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-overrided-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-configuartion-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-applys-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-explictely-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-omited-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-disassocation-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-deintialized-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-overwritting-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-overwriten-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-therfore-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-followings-pattern-and-fix-typo-instances.patch
* scripts-spellingtxt-add-some-typo-words.patch
* lib-vsprintfc-remove-%z-support.patch
* checkpatchpl-warn-against-using-%z.patch
* checkpatchpl-warn-against-using-%z-fix.patch
* mm-add-new-mmgrab-helper.patch
* mm-add-new-mmget-helper.patch
* mm-use-mmget_not_zero-helper.patch
* mm-clarify-mm_structmm_userscount-documentation.patch
* mm-add-arch-independent-testcases-for-rodata.patch
* mm-add-arch-independent-testcases-for-rodata-fix.patch
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
