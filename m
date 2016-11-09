Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id CF2F46B0038
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 19:50:12 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 17so84943689pfy.2
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 16:50:12 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g80si39303135pfb.21.2016.11.08.16.50.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Nov 2016 16:50:11 -0800 (PST)
Date: Tue, 08 Nov 2016 16:50:10 -0800
From: akpm@linux-foundation.org
Subject: mmotm 2016-11-08-16-49 uploaded
Message-ID: <582272c2.JkCxg4EZ9iVL3W5R%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2016-11-08-16-49 has been uploaded to

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


This mmotm tree contains the following patches against 4.9-rc4:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
* mm-remove-extra-newline-from-allocation-stall-warning.patch
* mm-remove-extra-newline-from-allocation-stall-warning-fix.patch
* mm-frontswap-make-sure-allocated-frontswap-map-is-assigned.patch
* shmem-fix-pageflags-after-swapping-dma32-object.patch
* scripts-bloat-o-meter-fix-sigpipe.patch
* mm-cma-check-the-max-limit-for-cma-allocation.patch
* swapfile-fix-memory-corruption-via-malformed-swapfile.patch
* mm-hwpoison-fix-thp-split-handling-in-memory_failure.patch
* revert-console-dont-prefer-first-registered-if-dt-specifies-stdout-path.patch
* ocfs2-fix-not-enough-credit-panic.patch
* mm-hugetlb-fix-huge-page-reservation-leak-in-private-mapping-error-paths.patch
* mm-filemap-dont-allow-partially-uptodate-page-for-pipes.patch
* coredump-fix-unfreezable-coredumping-task.patch
* memcg-prevent-memcg-caches-to-be-both-off_slab-objfreelist_slab.patch
* mm-kmemleak-scan-dataro_after_init.patch
* lib-stackdepot-export-save-fetch-stack-for-drivers.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* prctl-remove-one-shot-limitation-for-changing-exe-link.patch
* prctl-remove-one-shot-limitation-for-changing-exe-link-fix.patch
* kbuild-simpler-generation-of-assembly-constants.patch
* m32r-add-simple-dma.patch
* ocfs2-dlm-clean-up-useless-bug_on-default-case-in-dlm_finalize_reco_handler.patch
* ocfs2-delete-redundant-code-and-set-the-node-bit-into-maybe_map-directly.patch
* ocfs2-dlm-clean-up-deadcode-in-dlm_master_request_handler.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* kernel-watchdog-use-nmi-registers-snapshot-in-hardlockup-handler.patch
  mm.patch
* mm-memcontrol-use-special-workqueue-for-creating-per-memcg-caches.patch
* slub-move-synchronize_sched-out-of-slab_mutex-on-shrink.patch
* slub-avoid-false-postive-warning.patch
* mm-check-kmem_create_cache-flags-are-commons.patch
* mm-slab-faster-active-and-free-stats.patch
* dont-touch-single-threaded-ptes-which-are-on-the-right-node.patch
* dont-touch-single-threaded-ptes-which-are-on-the-right-node-v3.patch
* vmscan-set-correct-defer-count-for-shrinker.patch
* mm-compaction-allow-compaction-for-gfp_nofs-requests.patch
* mm-compaction-allow-compaction-for-gfp_nofs-requests-fix.patch
* mm-gup-make-unnecessarily-global-vma_permits_fault-static.patch
* mm-hugetlb-use-the-right-pte-val-for-compare-in-hugetlb_cow.patch
* mm-hugetlb-use-huge_pte_lock-instead-of-opencoding-the-lock.patch
* z3fold-limit-first_num-to-the-actual-range-of-possible-buddy-indexes.patch
* kmemleak-fix-reference-to-documentation.patch
* mm-dont-steal-highatomic-pageblock.patch
* mm-prevent-double-decrease-of-nr_reserved_highatomic.patch
* mm-try-to-exhaust-highatomic-reserve-before-the-oom.patch
* mm-make-unreserve-highatomic-functions-reliable.patch
* mm-vmallocc-simplify-proc-vmallocinfo-implementation.patch
* mm-thp-avoid-unlikely-branches-for-split_huge_pmd.patch
* mm-mempolicy-clean-up-__gfp_thisnode-confusion-in-policy_zonelist.patch
* mm-mempolicy-clean-up-__gfp_thisnode-confusion-in-policy_zonelist-checkpatch-fixes.patch
* mm-compaction-fix-nr_isolated_-stats-for-pfn-based-migration.patch
* shmem-avoid-maybe-uninitialized-warning.patch
* mm-use-the-correct-page-size-when-removing-the-page.patch
* mm-update-mmu_gather-range-correctly.patch
* mm-hugetlb-add-tlb_remove_hugetlb_entry-for-handling-hugetlb-pages.patch
* mm-add-tlb_remove_check_page_size_change-to-track-page-size-change.patch
* mm-remove-the-page-size-change-check-in-tlb_remove_page.patch
* mm-fixup-get_user_pages-comments.patch
* mm-mempolicyc-forbid-static-or-relative-flags-for-local-numa-mode.patch
* mm-add-locked-parameter-to-get_user_pages_remote.patch
* mm-unexport-__get_user_pages_unlocked.patch
* mm-unexport-__get_user_pages_unlocked-checkpatch-fixes.patch
* z3fold-make-pages_nr-atomic.patch
* z3fold-extend-compaction-function.patch
* mm-hugetlb-rename-some-allocation-functions.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* mm-walk-the-zone-in-pageblock_nr_pages-steps.patch
* kasan-support-panic_on_warn.patch
* mm-percpuc-fix-panic-triggered-by-bug_on-falsely.patch
* proc-report-no_new_privs-state.patch
* proc-make-struct-pid_entry-len-unsigned.patch
* proc-make-struct-struct-map_files_info-len-unsigned-int.patch
* proc-optimize-render_sigset_t.patch
* proc-just-list_del-struct-pde_opener.patch
* proc-fix-type-of-struct-pde_opener-closing-field.patch
* proc-kmalloc-struct-pde_opener.patch
* proc-tweak-comments-about-2-stage-open-and-everything.patch
* hung_task-decrement-sysctl_hung_task_warnings-only-if-it-is-positive.patch
* compiler-gcch-use-proved-instead-of-proofed.patch
* get_maintainer-look-for-arbitrary-letter-prefixes-in-sections.patch
* maintainers-add-b-for-uri-where-to-file-bugs.patch
* maintainers-add-drm-and-drm-i915-bug-filing-info.patch
* maintainers-add-c-for-uri-for-chat-where-developers-hang-out.patch
* maintainers-add-drm-and-drm-i915-irc-channels.patch
* let-config_strict_devmem-depends-on-config_devmem.patch
* lib-rbtreec-fix-typo-in-comment-of-____rb_erase_color.patch
* lib-ida-document-locking-requirements-a-bit-better-v2.patch
* lib-add-crc64-ecma-module.patch
* checkpatch-dont-try-to-get-maintained-status-when-no-tree-is-given.patch
* scripts-checkpatchpl-fix-spelling.patch
* checkpatch-dont-check-pl-files-improve-absolute-path-commit-log-test.patch
* checkpatch-avoid-multiple-line-dereferences.patch
* vfs-change-d_manage-to-take-a-struct-path.patch
* vfs-add-path_is_mountpoint-helper.patch
* vfs-add-path_has_submounts.patch
* autofs-change-autofs4_expire_wait-to-take-struct-path.patch
* autofs-change-autofs4_wait-to-take-struct-path.patch
* autofs-use-path_is_mountpoint-to-fix-unreliable-d_mountpoint-checks.patch
* autofs-use-path_has_submounts-to-fix-unreliable-have_submount-checks.patch
* vfs-remove-unused-have_submounts-function.patch
* signals-avoid-unnecessary-taking-of-sighand-siglock.patch
* coredump-clarify-unsafe-core_pattern-warning.patch
* revert-kdump-vmcoreinfo-report-memory-sections-virtual-addresses.patch
* kexec-change-to-export-the-value-of-phys_base-instead-of-symbol-address.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* relay-check-array-offset-before-using-it.patch
* kconfig-lib-kconfigdebug-fix-references-to-documenation.patch
* kconfig-lib-kconfigubsan-fix-reference-to-ubsan-documentation.patch
* debug-more-properly-delay-for-secondary-cpus.patch
* debug-more-properly-delay-for-secondary-cpus-fix.patch
* initramfs-select-builtin-initram-compression-algorithm-on-kconfig-instead-of-makefile.patch
* initramfs-allow-again-choice-of-the-embedded-initram-compression-algorithm.patch
* ipc-semc-avoid-using-spin_unlock_wait.patch
* ipc-sem-add-hysteresis.patch
* ipc-msg-make-msgrcv-work-with-long_min.patch
* ipc-sem-do-not-call-wake_sem_queue_do-prematurely.patch
* ipc-sem-rework-task-wakeups.patch
* ipc-sem-rework-task-wakeups-checkpatch-fixes.patch
* ipc-sem-optimize-perform_atomic_semop.patch
* ipc-sem-optimize-perform_atomic_semop-fix.patch
* ipc-sem-optimize-perform_atomic_semop-checkpatch-fixes.patch
* ipc-sem-explicitly-inline-check_restart.patch
* ipc-sem-use-proper-list-api-for-pending_list-wakeups.patch
* ipc-fixed-warnings.patch
  linux-next.patch
* drivers-net-wireless-intel-iwlwifi-dvm-calibc-fix-min-warning.patch
* kexec_file-allow-arch-specific-memory-walking-for-kexec_add_buffer.patch
* kexec_file-change-kexec_add_buffer-to-take-kexec_buf-as-argument.patch
* kexec_file-factor-out-kexec_locate_mem_hole-from-kexec_add_buffer.patch
* powerpc-change-places-using-config_kexec-to-use-config_kexec_core-instead.patch
* powerpc-factor-out-relocation-code-in-module_64c.patch
* powerpc-implement-kexec_file_load.patch
* powerpc-add-functions-to-read-elf-files-of-any-endianness.patch
* powerpc-add-support-for-loading-elf-kernels-with-kexec_file_load.patch
* powerpc-add-purgatory-for-kexec_file_load-implementation.patch
* powerpc-enable-config_kexec_file-in-powerpc-server-defconfigs.patch
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
* ktestpl-fix-english.patch
* watchdog-move-shared-definitions-to-nmih.patch
* watchdog-move-hardlockup-detector-to-separate-file.patch
* sparc-implement-watchdog_nmi_enable-and-watchdog_nmi_disable.patch
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
