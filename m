Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 59C416B0005
	for <linux-mm@kvack.org>; Mon, 23 May 2016 19:51:53 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 129so1751956pfx.0
        for <linux-mm@kvack.org>; Mon, 23 May 2016 16:51:53 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id as6si122930pac.173.2016.05.23.16.51.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 16:51:52 -0700 (PDT)
Date: Mon, 23 May 2016 16:51:51 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2016-05-23-16-51 uploaded
Message-ID: <57439797.36ht8abUxrU5hKGX%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2016-05-23-16-51 has been uploaded to

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


This mmotm tree contains the following patches against 4.6:
(patches marked "*" will be included in linux-next)

  origin.patch
* m32r-fix-build-failure.patch
* elf-mips-build-fix.patch
* mm-memcontrol-fix-possible-css-ref-leak-on-oom.patch
* fs-befs-datastreamc-befs_read_datastream-remove-unneeded-initialization-to-null.patch
* fs-befs-datastreamc-befs_read_lsymlink-remove-unneeded-initialization-to-null.patch
* fs-befs-datastreamc-befs_find_brun_dblindirect-remove-unneeded-initializations-to-null.patch
* fs-befs-linuxvfsc-befs_get_block-remove-unneeded-initialization-to-null.patch
* fs-befs-linuxvfsc-befs_iget-remove-unneeded-initialization-to-null.patch
* fs-befs-linuxvfsc-befs_iget-remove-unneeded-raw_inode-initialization-to-null.patch
* fs-befs-linuxvfsc-befs_iget-remove-unneeded-befs_nio-initialization-to-null.patch
* fs-befs-ioc-befs_bread_iaddr-remove-unneeded-initialization-to-null.patch
* fs-befs-ioc-befs_bread-remove-unneeded-initialization-to-null.patch
* nilfs2-constify-nilfs_sc_operations-structures.patch
* nilfs2-fix-white-space-issue-in-nilfs_mount.patch
* nilfs2-remove-space-before-comma.patch
* nilfs2-remove-fsf-mailing-address-from-gpl-notices.patch
* nilfs2-clean-up-old-e-mail-addresses.patch
* maintainers-add-web-link-for-nilfs-project.patch
* nilfs2-clarify-permission-to-replicate-the-design.patch
* nilfs2-get-rid-of-nilfs_mdt_mark_block_dirty.patch
* nilfs2-move-cleanup-code-of-metadata-file-from-inode-routines.patch
* nilfs2-replace-__attribute__packed-with-__packed.patch
* nilfs2-add-missing-line-spacing.patch
* nilfs2-clean-trailing-semicolons-in-macros.patch
* nilfs2-do-not-emit-extra-newline-on-nilfs_warning-and-nilfs_error.patch
* nilfs2-remove-space-before-semicolon.patch
* nilfs2-fix-code-indent-coding-style-issue.patch
* nilfs2-avoid-bare-use-of-unsigned.patch
* nilfs2-remove-unnecessary-else-after-return-or-break.patch
* nilfs2-remove-loops-of-single-statement-macros.patch
* nilfs2-fix-block-comments.patch
* wait-ptrace-assume-__wall-if-the-child-is-traced.patch
* wait-allow-sys_waitid-to-accept-__wnothread-__wclone-__wall.patch
* signal-make-oom_flags-a-bool.patch
* kernel-signalc-convert-printkkern_level-to-pr_level.patch
* signal-move-the-sig-sigrtmin-check-into-siginmasksig.patch
* allocate-idle-task-for-a-cpu-always-on-its-local-node.patch
* exec-remove-the-no-longer-needed-remove_arg_zero-free_arg_page.patch
* kexec-introduce-a-protection-mechanism-for-the-crashkernel-reserved-memory.patch
* kexec-provide-arch_kexec_protectunprotect_crashkres.patch
* kexec-make-a-pair-of-map-unmap-reserved-pages-in-error-path.patch
* kexec-do-a-cleanup-for-function-kexec_load.patch
* s390-kexec-consolidate-crash_map-unmap_reserved_pages-and-arch_kexec_protectunprotect_crashkres.patch
* kdump-fix-gdb-macros-work-work-with-newer-and-64-bit-kernels.patch
* rtsx_usb_ms-use-schedule_timeout_idle-in-polling-loop-v2.patch
* drivers-memstick-core-mspro_block-use-kmemdup.patch
* arch-defconfig-remove-config_resource_counters.patch
* scripts-gdb-adjust-module-reference-counter-reported-by-lx-lsmod.patch
* scripts-gdb-provide-linux-constants.patch
* scripts-gdb-provide-kernel-list-item-generators.patch
* scripts-gdb-convert-modules-usage-to-lists-functions.patch
* scripts-gdb-provide-exception-catching-parser.patch
* scripts-gdb-support-config_modules-gracefully.patch
* scripts-gdb-provide-a-dentry_name-vfs-path-helper.patch
* scripts-gdb-add-io-resource-readers.patch
* scripts-gdb-add-mount-point-list-command.patch
* scripts-gdb-add-cpu-iterators.patch
* scripts-gdb-cast-cpu-numbers-to-integer.patch
* scripts-gdb-add-a-radix-tree-parser.patch
* scripts-gdb-add-documentation-example-for-radix-tree.patch
* scripts-gdb-add-lx_thread_info_by_pid-helper.patch
* scripts-gdb-improve-types-abstraction-for-gdb-python-scripts.patch
* scripts-gdb-fix-issue-with-dmesgpy-and-python-3x.patch
* scripts-gdb-decode-bytestream-on-dmesg-for-python3.patch
* maintainers-add-co-maintainer-for-scripts-gdb.patch
* mm-make-mmap_sem-for-write-waits-killable-for-mm-syscalls.patch
* mm-make-vm_mmap-killable.patch
* mm-make-vm_munmap-killable.patch
* mm-aout-handle-vm_brk-failures.patch
* mm-elf-handle-vm_brk-error.patch
* mm-make-vm_brk-killable.patch
* mm-proc-make-clear_refs-killable.patch
* mm-fork-make-dup_mmap-wait-for-mmap_sem-for-write-killable.patch
* ipc-shm-make-shmem-attach-detach-wait-for-mmap_sem-killable.patch
* vdso-make-arch_setup_additional_pages-wait-for-mmap_sem-for-write-killable.patch
* coredump-make-coredump_wait-wait-for-mmap_sem-for-write-killable.patch
* aio-make-aio_setup_ring-killable.patch
* exec-make-exec-path-waiting-for-mmap_sem-killable.patch
* prctl-make-pr_set_thp_disable-wait-for-mmap_sem-killable.patch
* uprobes-wait-for-mmap_sem-for-write-killable.patch
* drm-i915-make-i915_gem_mmap_ioctl-wait-for-mmap_sem-killable.patch
* drm-radeon-make-radeon_mn_get-wait-for-mmap_sem-killable.patch
* drm-amdgpu-make-amdgpu_mn_get-wait-for-mmap_sem-killable.patch
* kgdb-depends-on-vt.patch
  i-need-old-gcc.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
* seqlock-fix-raw_read_seqcount_latch.patch
* mm-make-config_deferred_struct_page_init-depends-on-flatmem-explicitly.patch
* mm-kasan-remove-unused-reserved-field-from-struct-kasan_alloc_meta.patch
* mm-slub-remove-unused-virt_to_obj.patch
* ocfs2-fix-improper-handling-of-return-errno.patch
* memcg-fix-mem_cgroup_out_of_memory-return-value.patch
* mm-oom_reaper-do-not-mmput-synchronously-from-the-oom-reaper-context-fix.patch
* mm-oom_reaper-do-not-mmput-synchronously-from-the-oom-reaper-context-fix-fix.patch
* dma-debug-avoid-spinlock-recursion-when-disabling-dma-debug.patch
* update-mm-zsmalloc-dont-fail-if-cant-create-debugfs-info.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* fs-ext4-fsyncc-generic_file_fsync-call-based-on-barrier-flag.patch
* ocfs2-fix-a-redundant-re-initialization.patch
* ocfs2-o2hb-add-negotiate-timer.patch
* ocfs2-o2hb-add-nego_timeout-message.patch
* ocfs2-o2hb-add-negotiate_approve-message.patch
* ocfs2-o2hb-add-some-user-debug-log.patch
* ocfs2-o2hb-dont-negotiate-if-last-hb-fail.patch
* ocfs2-o2hb-fix-hb-hung-time.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
  mm.patch
* mm-check-the-return-value-of-lookup_page_ext-for-all-call-sites.patch
* mm-check-the-return-value-of-lookup_page_ext-for-all-call-sites-checkpatch-fixes.patch
* memory-hotplug-add-move_pfn_range.patch
* memory-hotplug-more-general-validation-of-zone-during-online.patch
* memory-hotplug-use-zone_can_shift-for-sysfs-valid_zones-attribute.patch
* mm-memblock-if-nr_new-is-0-just-return.patch
* mm-make-optimistic-check-for-swapin-readahead.patch
* mm-make-optimistic-check-for-swapin-readahead-fix-2.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-2.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-3.patch
* mm-vmstat-calculate-particular-vm-event.patch
* mm-thp-avoid-unnecessary-swapin-in-khugepaged.patch
* mm-thp-avoid-unnecessary-swapin-in-khugepaged-fix.patch
* lib-switch-config_printk_time-to-int.patch
* printk-allow-different-timestamps-for-printktime.patch
* lib-add-crc64-ecma-module.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* futex-fix-shared-futex-operations-on-nommu.patch
* kcov-allow-more-fine-grained-coverage-instrumentation.patch
* ipc-semc-fix-complex_count-vs-simple-op-race.patch
* ipc-msgc-msgsnd-use-freezable-blocking-call.patch
* msgrcv-use-freezable-blocking-call.patch
  linux-next.patch
* mm-make-optimistic-check-for-swapin-readahead-fix.patch
* drivers-net-wireless-intel-iwlwifi-dvm-calibc-fix-min-warning.patch
* fs-nfs-nfs4statec-work-around-gcc-44-union-initialization-bug.patch
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
