Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 128B06B0003
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 20:29:37 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id o33-v6so6754581plb.16
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 17:29:37 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w18-v6si6265677pll.424.2018.04.13.17.29.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Apr 2018 17:29:35 -0700 (PDT)
Date: Fri, 13 Apr 2018 17:29:33 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2018-04-13-17-28 uploaded
Message-ID: <20180414002933.6h3S5%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org

The mm-of-the-moment snapshot 2018-04-13-17-28 has been uploaded to

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


This mmotm tree contains the following patches against 4.16:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
* resource-fix-integer-overflow-at-reallocation-v1.patch
* mm-gup_benchmark-handle-gup-failures.patch
* gup-return-efault-on-access_ok-failure.patch
* mm-gup-document-return-value.patch
* mm-filemap-provide-dummy-filemap_page_mkwrite-for-nommu.patch
* ipc-shm-fix-use-after-free-of-shm-file-via-remap_file_pages.patch
* kexec-export-pg_swapbacked-to-vmcoreinfo.patch
* mm-slab-reschedule-cache_reap-on-the-same-cpu.patch
* proc-revalidate-misc-dentries.patch
* kexec_file-make-an-use-of-purgatory-optional.patch
* kexec_filex86powerpc-factor-out-kexec_file_ops-functions.patch
* x86-kexec_file-purge-system-ram-walking-from-prepare_elf64_headers.patch
* x86-kexec_file-remove-x86_64-dependency-from-prepare_elf64_headers.patch
* x86-kexec_file-lift-crash_max_ranges-limit-on-crash_mem-buffer.patch
* x86-kexec_file-clean-up-prepare_elf64_headers.patch
* kexec_file-x86-move-re-factored-code-to-generic-side.patch
* kexec_file-silence-compile-warnings.patch
* kexec_file-remove-checks-in-kexec_purgatory_load.patch
* kexec_file-make-purgatory_info-ehdr-const.patch
* kexec_file-search-symbols-in-read-only-kexec_purgatory.patch
* kexec_file-use-read-only-sections-in-arch_kexec_apply_relocations.patch
* kexec_file-split-up-__kexec_load_puragory.patch
* kexec_file-remove-unneeded-for-loop-in-kexec_purgatory_setup_sechdrs.patch
* kexec_file-remove-unneeded-variables-in-kexec_purgatory_setup_sechdrs.patch
* kexec_file-remove-mis-use-of-sh_offset-field-during-purgatory-load.patch
* kexec_file-allow-archs-to-set-purgatory-load-address.patch
* kexec_file-move-purgatories-sha256-to-common-code.patch
* mm-pagemap-fix-swap-offset-value-for-pmd-migration-entry.patch
* mm-pagemap-fix-swap-offset-value-for-pmd-migration-entry-fix.patch
* writeback-safer-lock-nesting.patch
* writeback-safer-lock-nesting-fix.patch
* writeback-safer-lock-nesting-v4.patch
* mm-enable-thp-migration-for-shmem-thp.patch
* memcg-remove-memcg_cgroup-id-from-idr-on-mem_cgroup_css_alloc-failure.patch
* rapidio-fix-rio_dma_transfer-error-handling.patch
* kasan-add-no_sanitize-attribute-for-clang-builds.patch
* maintainers-add-personal-addresses-for-sascha-and-me.patch
* fs-dcachec-re-add-cond_resched-in-shrink_dcache_parent.patch
* autofs-mount-point-create-should-honour-passed-in-mode.patch
* ocfs2-submit-another-bio-if-current-bio-is-full.patch
* proc-revalidate-kernel-thread-inodes-to-root-root.patch
* proc-fix-proc-loadavg-regression.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* prctl-add-pr_et_pdeathsig_proc.patch
* ocfs2-get-rid-of-ocfs2_is_o2cb_active-function.patch
* ocfs2-without-quota-support-try-to-avoid-calling-quota-recovery.patch
* ocfs2-without-quota-support-try-to-avoid-calling-quota-recovery-checkpatch-fixes.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
* dentry-fix-kmemcheck-splat-at-take_dentry_name_snapshot.patch
  mm.patch
* mm-sparse-add-a-static-variable-nr_present_sections.patch
* mm-sparsemem-defer-the-ms-section_mem_map-clearing.patch
* mm-sparse-add-a-new-parameter-data_unit_size-for-alloc_usemap_and_memmap.patch
* mm-swap-fix-race-between-swapoff-and-some-swap-operations.patch
* mm-swap-fix-race-between-swapoff-and-some-swap-operations-v6.patch
* mm-fix-race-between-swapoff-and-mincore.patch
* mmvmscan-mark-register_shrinker-as-__must_check.patch
* list_lru-prefetch-neighboring-list-entries-before-acquiring-lock.patch
* list_lru-prefetch-neighboring-list-entries-before-acquiring-lock-fix.patch
* mm-oom-refactor-the-oom_kill_process-function.patch
* mm-implement-mem_cgroup_scan_tasks-for-the-root-memory-cgroup.patch
* mm-oom-cgroup-aware-oom-killer.patch
* mm-oom-cgroup-aware-oom-killer-fix.patch
* mm-oom-introduce-memoryoom_group.patch
* mm-oom-introduce-memoryoom_group-fix.patch
* mm-oom-add-cgroup-v2-mount-option-for-cgroup-aware-oom-killer.patch
* mm-oom-docs-describe-the-cgroup-aware-oom-killer.patch
* mm-oom-docs-describe-the-cgroup-aware-oom-killer-fix.patch
* mm-oom-docs-describe-the-cgroup-aware-oom-killer-fix-2.patch
* mm-oom-docs-describe-the-cgroup-aware-oom-killer-fix-2-fix.patch
* cgroup-list-groupoom-in-cgroup-features.patch
* mm-add-strictlimit-knob-v2.patch
* mm-dont-expose-page-to-fast-gup-before-its-ready.patch
* mm-page_owner-align-with-pageblock_nr_pages.patch
* mm-page_owner-align-with-pageblock_nr-pages.patch
* mm-kasan-dont-vfree-nonexistent-vm_area.patch
* rslib-remove-vlas-by-setting-upper-bound-on-nroots.patch
* checkpatch-add-a-strict-test-for-structs-with-bool-member-definitions.patch
* coredump-fix-spam-with-zero-vma-process.patch
* seq_file-delete-small-value-optimization.patch
* fork-unconditionally-clear-stack-on-fork.patch
* exofs-avoid-vla-in-structures.patch
  linux-next.patch
  linux-next-rejects.patch
* resource-add-walk_system_ram_res_rev.patch
* kexec_file-load-kernel-at-top-of-system-ram-if-required.patch
* mm-memcg-remote-memcg-charging-for-kmem-allocations.patch
* mm-memcg-remote-memcg-charging-for-kmem-allocations-fix.patch
* fs-fsnotify-account-fsnotify-metadata-to-kmemcg.patch
* fs-fsnotify-account-fsnotify-metadata-to-kmemcg-fix.patch
* fix-read-buffer-overflow-in-delta-ipc.patch
* sparc64-ng4-memset-32-bits-overflow.patch
  make-sure-nobodys-leaking-resources.patch
  releasing-resources-with-children.patch
  mutex-subsystem-synchro-test-module.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  slab-leaks3-default-y.patch
  workaround-for-a-pci-restoring-bug.patch
