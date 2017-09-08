Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1F1836B04D0
	for <linux-mm@kvack.org>; Fri,  8 Sep 2017 19:49:39 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b68so2839124wme.4
        for <linux-mm@kvack.org>; Fri, 08 Sep 2017 16:49:39 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k203si2337390wmg.85.2017.09.08.16.49.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Sep 2017 16:49:37 -0700 (PDT)
Date: Fri, 08 Sep 2017 16:49:34 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2017-09-08-16-48 uploaded
Message-ID: <59b32c8e.2kl6QUdusEmEtnCx%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2017-09-08-16-48 has been uploaded to

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


This mmotm tree contains the following patches against 4.13:
(patches marked "*" will be included in linux-next)

  origin.patch
  mm-mempolicy-add-queue_pages_required.patch
  mm-x86-move-_page_swp_soft_dirty-from-bit-7-to-bit-1.patch
  mm-thp-introduce-separate-ttu-flag-for-thp-freezing.patch
  mm-thp-introduce-config_arch_enable_thp_migration.patch
  mm-thp-enable-thp-migration-in-generic-path.patch
  mm-thp-check-pmd-migration-entry-in-common-path.patch
  mm-soft-dirty-keep-soft-dirty-bits-over-thp-migration.patch
  mm-mempolicy-mbind-and-migrate_pages-support-thp-migration.patch
  mm-migrate-move_pages-supports-thp-migration.patch
  mm-memory_hotplug-memory-hotremove-supports-thp-migration.patch
  hmm-heterogeneous-memory-management-documentation-v3.patch
  mm-hmm-heterogeneous-memory-management-hmm-for-short-v5.patch
  mm-hmm-mirror-mirror-process-address-space-on-device-with-hmm-helpers-v3.patch
  mm-hmm-mirror-helper-to-snapshot-cpu-page-table-v4.patch
  mm-hmm-mirror-device-page-fault-handler.patch
  mm-memory_hotplug-introduce-add_pages.patch
  mm-zone_device-new-type-of-zone_device-for-unaddressable-memory-v5.patch
  mm-zone_device-special-case-put_page-for-device-private-pages-v4.patch
  mm-memcontrol-allow-to-uncharge-page-without-using-page-lru-field.patch
  mm-memcontrol-support-memory_device_private-v4.patch
  mm-hmm-devmem-device-memory-hotplug-using-zone_device-v7.patch
  mm-hmm-devmem-dummy-hmm-device-for-zone_device-memory-v3.patch
  mm-migrate-new-migrate-mode-migrate_sync_no_copy.patch
  mm-migrate-new-memory-migration-helper-for-use-with-device-memory-v5.patch
  mm-migrate-migrate_vma-unmap-page-from-vma-while-collecting-pages.patch
  mm-migrate-support-un-addressable-zone_device-page-in-migration-v3.patch
  mm-migrate-allow-migrate_vma-to-alloc-new-page-on-empty-entry-v4.patch
  mm-device-public-memory-device-memory-cache-coherent-with-cpu-v5.patch
  mm-hmm-add-new-helper-to-hotplug-cdm-memory-region-v3.patch
  mm-hmm-avoid-bloating-arch-that-do-not-make-use-of-hmm.patch
  mm-hmm-fix-build-when-hmm-is-disabled.patch
  mm-remove-useless-vma-parameter-to-offset_il_node.patch
  userfaultfd-non-cooperative-closing-the-uffd-without-triggering-sigbus.patch
  mm-page_fault-remove-reduntant-check-for-write-access.patch
  mm-change-the-call-sites-of-numa-statistics-items.patch
  mm-update-numa-counter-threshold-size.patch
  mm-consider-the-number-in-local-cpus-when-reads-numa-stats.patch
  mm-mlock-use-page_zone-instead-of-page_zone_id.patch
  mm-zsmalloc-change-stat-type-parameter-to-int.patch
  mm-fadvise-avoid-fadvise-for-fs-without-backing-device.patch
  mm-memcontrol-use-per-cpu-stocks-for-socket-memory-uncharging.patch
  mm-fix-mem_cgroup_oom_disable-call-missing.patch
  mm-sparse-fix-typo-in-online_mem_sections.patch
  toolsselftest-kcmp-add-kcmp_epoll_tfd-testing.patch
  mmpage_alloc-apply-gfp_allowed_mask-before-the-first-allocation-attempt.patch
  mm-kvfree-the-swap-cluster-info-if-the-swap-file-is-unsatisfactory.patch
  mm-swapfile-fix-swapon-frontswap_map-memory-leak-on-error.patch
  mm-mempolicy-remove-bug_on-checks-for-vma-inside-mpol_misplaced.patch
  fs-proc-remove-priv-argument-from-is_stack.patch
  proc-uninline-proc_create.patch
  fs-proc-unconditional-cond_resched-when-reading-smaps.patch
  linux-kernelh-move-div_round_down_ull-macro.patch
  add-multibyte-memset-functions.patch
  add-testcases-for-memset16-32-64.patch
  x86-implement-memset16-memset32-memset64.patch
  arm-implement-memset32-memset64.patch
  alpha-add-support-for-memset16.patch
  zram-convert-to-using-memset_l.patch
  sym53c8xx_2-convert-to-use-memset32.patch
  vga-optimise-console-scrolling.patch
  make-nr_cpu_ids-unsigned.patch
  arch-define-cpu_big_endian-for-all-fixed-big-endian-archs.patch
  arch-microblaze-add-choice-for-endianness-and-update-makefile.patch
  include-warn-for-inconsistent-endian-config-definition.patch
  bitops-avoid-integer-overflow-in-genmask_ull.patch
  rbtree-cache-leftmost-node-internally.patch
  rbtree-optimize-root-check-during-rebalancing-loop.patch
  rbtree-add-some-additional-comments-for-rebalancing-cases.patch
  lib-rbtree_testc-make-input-module-parameters.patch
  lib-rbtree_testc-add-inorder-traversal-test.patch
  lib-rbtree_testc-support-rb_root_cached.patch
  sched-fair-replace-cfs_rq-rb_leftmost.patch
  sched-deadline-replace-earliest-dl-and-rq-leftmost-caching.patch
  locking-rtmutex-replace-top-waiter-and-pi_waiters-leftmost-caching.patch
  block-cfq-replace-cfq_rb_root-leftmost-caching.patch
  lib-interval_tree-fast-overlap-detection.patch
  lib-interval-tree-correct-comment-wrt-generic-flavor.patch
  procfs-use-faster-rb_first_cached.patch
  fs-epoll-use-faster-rb_first_cached.patch
  mem-memcg-cache-rightmost-node.patch
  block-cfq-cache-rightmost-rb_node.patch
  lib-hexdump-return-einval-in-case-of-error-in-hex2bin.patch
  lib-add-test-module-for-config_debug_virtual.patch
  lib-make-bitmap_parselist-thread-safe-and-much-faster.patch
  lib-add-test-for-bitmap_parselist.patch
  bitmap-introduce-bitmap_from_u64.patch
  lib-rhashtable-fix-comment-on-locks_mul-default-value.patch
  lib-stringc-check-for-kmalloc-failure.patch
  lib-cmldinec-clean-up-the-meaningless-comment.patch
  radix-tree-must-check-__radix_tree_preload-return-value.patch
  x509-fix-the-buffer-overflow-in-the-utility-function-for-oid-string.patch
  checkpatch-add-strict-check-for-ifs-with-unnecessary-parentheses.patch
  checkpatch-fix-typo-in-comment.patch
  checkpatch-rename-variables-to-avoid-confusion.patch
  checkpatch-add-6-missing-types-to-list-types.patch
  binfmt_flat-delete-two-error-messages-for-a-failed-memory-allocation-in-decompress_exec.patch
  init-move-stack-canary-initialization-after-setup_arch.patch
  extract-early-boot-entropy-from-the-passed-cmdline.patch
  autofs-fix-at_no_automount-not-being-honored.patch
  autofs-make-disc-device-user-accessible.patch
  autofs-make-dev-ioctl-version-and-ismountpoint-user-accessible.patch
  autofs-remove-unused-autofs_ioc_expire_direct-indirect.patch
  autofs-non-functional-header-inclusion-cleanup.patch
  autofs-use-autofs_dev_ioctl_size.patch
  autofs-drop-wrong-comment.patch
  autofs-use-unsigned-int-long-instead-of-uint-ulong-for-ioctl-args.patch
  vfat-deduplicate-hex2bin.patch
  test_kmod-remove-paranoid-uint_max-check-on-uint-range-processing.patch
  test_kmod-flip-int-checks-to-be-consistent.patch
  kmod-split-out-umh-code-into-its-own-file.patch
  maintainers-clarify-kmod-is-just-a-kernel-module-loader.patch
  kmod-split-off-umh-headers-into-its-own-file.patch
  kmod-move-ifdef-config_modules-wrapper-to-makefile.patch
  cpumask-make-cpumask_next-out-of-line.patch
  pps-aesthetic-tweaks-to-pps-related-content.patch
  pps-use-surrounding-if-pps-to-remove-numerous-dependency-checks.patch
  m32r-defconfig-cleanup-from-old-kconfig-options.patch
  mn10300-defconfig-cleanup-from-old-kconfig-options.patch
  sh-defconfig-cleanup-from-old-kconfig-options.patch
  kcov-support-compat-processes.patch
  ipc-convert-ipc_namespacecount-from-atomic_t-to-refcount_t.patch
  ipc-convert-sem_undo_listrefcnt-from-atomic_t-to-refcount_t.patch
  ipc-convert-kern_ipc_permrefcount-from-atomic_t-to-refcount_t.patch
  ipc-sem-drop-sem_checkid-helper.patch
  ipc-sem-play-nicer-with-large-nsops-allocations.patch
  ipc-optimize-semget-shmget-msgget-for-lots-of-keys.patch
  i-need-old-gcc.patch
* mm-skip-hwpoisoned-pages-when-onlining-pages.patch
* mm-memory_hotplug-do-not-back-off-draining-pcp-free-pages-from-kworker-context.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* ocfs2-get-rid-of-ocfs2_is_o2cb_active-function.patch
* ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called.patch
* ocfs2-old-mle-put-and-release-after-the-function-dlm_add_migration_mle-called-fix.patch
* ocfs2-give-an-obvious-tip-for-dismatch-cluster-names.patch
* ocfs2-give-an-obvious-tip-for-dismatch-cluster-names-v2.patch
* ocfs2-move-some-definitions-to-header-file.patch
* ocfs2-fix-some-small-problems.patch
* ocfs2-add-kobject-for-online-file-check.patch
* ocfs2-add-duplicative-ino-number-check.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
  mm.patch
* mm-compaction-kcompactd-should-not-ignore-pageblock-skip.patch
* mm-compaction-persistently-skip-hugetlbfs-pageblocks.patch
* mm-compaction-persistently-skip-hugetlbfs-pageblocks-fix.patch
* mm-cma-manage-the-memory-of-the-cma-area-by-using-the-zone_movable.patch
* mm-cma-remove-alloc_cma.patch
* arm-cma-avoid-double-mapping-to-the-cma-area-if-config_highmem-=-y.patch
* mm-page_alloc-return-0-in-case-this-node-has-no-page-within-the-zone.patch
* mm-vmscan-do-not-pass-reclaimed-slab-to-vmpressure.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* mm-walk-the-zone-in-pageblock_nr_pages-steps.patch
* parse-maintainers-add-ability-to-specify-filenames.patch
* seq_file-delete-small-value-optimization.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* rapidio-remove-global-irq-spinlocks-from-the-subsystem.patch
* uapi-fix-linux-sysctlh-userspace-compilation-errors.patch
* kernel-reboot-add-devm_register_reboot_notifier.patch
* kernel-reboot-add-devm_register_reboot_notifier-fix.patch
  linux-next.patch
  linux-next-git-rejects.patch
* drivers-media-cec-cec-adapc-fix-build-with-gcc-444.patch
* fscache-fix-fscache_objlist_show-format-processing.patch
* ib-mlx4-fix-sprintf-format-warning.patch
* iopoll-avoid-wint-in-bool-context-warning.patch
* sparc64-ng4-memset-32-bits-overflow.patch
* treewide-remove-gfp_temporary-allocation-flag.patch
* treewide-remove-gfp_temporary-allocation-flag-fix.patch
* treewide-remove-gfp_temporary-allocation-flag-checkpatch-fixes.patch
* treewide-remove-gfp_temporary-allocation-flag-fix-2.patch
* arm64-stacktrace-avoid-listing-stacktrace-functions-in-stacktrace.patch
* mm-page_owner-skip-unnecessary-stack_trace-entries.patch
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
