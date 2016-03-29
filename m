Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 296236B0005
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 18:55:06 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id zm5so24924127pac.0
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 15:55:06 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 22si1451332pfq.57.2016.03.29.15.55.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Mar 2016 15:55:05 -0700 (PDT)
Date: Tue, 29 Mar 2016 15:55:04 -0700
From: akpm@linux-foundation.org
Subject: mmotm 2016-03-29-15-54 uploaded
Message-ID: <56fb07c8./Yxe34kTw9VGKyZR%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, broonie@kernel.org

The mm-of-the-moment snapshot 2016-03-29-15-54 has been uploaded to

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


This mmotm tree contains the following patches against 4.6-rc1:
(patches marked "*" will be included in linux-next)

  origin.patch
  i-need-old-gcc.patch
  arch-alpha-kernel-systblss-remove-debug-check.patch
  drivers-gpu-drm-i915-intel_spritec-fix-build.patch
  drivers-gpu-drm-i915-intel_tvc-fix-build.patch
* maintainers-orangefs-mailing-list-is-subscribers-only.patch
* include-linux-huge_mmh-return-null-instead-of-false-for-pmd_trans_huge_lock.patch
* mm-fix-invalid-node-in-alloc_migrate_target.patch
* x86-mm-tlb_remote_send_ipi-should-count-pages.patch
* mm-rmap-batched-invalidations-should-use-existing-api.patch
* mm-page_ref-use-page_ref-helper-instead-of-direct-modification-of-_count.patch
* mm-rename-_count-field-of-the-struct-page-to-_refcount.patch
* mm-rename-_count-field-of-the-struct-page-to-_refcount-fix.patch
* ksm-introduce-ksm_max_page_sharing-per-page-deduplication-limit.patch
* ksm-introduce-ksm_max_page_sharing-per-page-deduplication-limit-fix-2.patch
* ksm-introduce-ksm_max_page_sharing-per-page-deduplication-limit-fix-3.patch
* mm-page_isolation-fix-tracepoint-to-mirror-check-function-behavior.patch
* oom-oom_reaper-do-not-enqueue-task-if-it-is-on-the-oom_reaper_list-head.patch
* mm-page_isolationc-fix-the-function-comments.patch
* compilerh-provide-__always_inline-to-userspace-headers-too.patch
* arm-arch-arm-include-asm-pageh-needs-personalityh.patch
* fs-ext4-fsyncc-generic_file_fsync-call-based-on-barrier-flag.patch
* ocfs2-error-code-comments-and-amendments-the-comment-of-ocfs2_extended_slot-should-be-0x08.patch
* ocfs2-clean-up-an-unused-variable-wants_rotate-in-ocfs2_truncate_rec.patch
* ocfs2-o2hb-add-negotiate-timer.patch
* ocfs2-o2hb-add-negotiate-timer-v2.patch
* ocfs2-o2hb-add-nego_timeout-message.patch
* ocfs2-o2hb-add-nego_timeout-message-v2.patch
* ocfs2-o2hb-add-negotiate_approve-message.patch
* ocfs2-o2hb-add-negotiate_approve-message-v2.patch
* ocfs2-o2hb-add-some-user-debug-log.patch
* ocfs2-o2hb-add-some-user-debug-log-v2.patch
* ocfs2-o2hb-dont-negotiate-if-last-hb-fail.patch
* ocfs2-o2hb-fix-hb-hung-time.patch
* block-restore-proc-partitions-to-not-display-non-partitionable-removable-devices.patch
  mm.patch
* mm-slab-hold-a-slab_mutex-when-calling-__kmem_cache_shrink.patch
* mm-slab-remove-bad_alien_magic-again.patch
* mm-slab-drain-the-free-slab-as-much-as-possible.patch
* mm-slab-factor-out-kmem_cache_node-initialization-code.patch
* mm-slab-clean-up-kmem_cache_node-setup.patch
* mm-slab-dont-keep-free-slabs-if-free_objects-exceeds-free_limit.patch
* mm-slab-racy-access-modify-the-slab-color.patch
* mm-slab-make-cache_grow-handle-the-page-allocated-on-arbitrary-node.patch
* mm-slab-separate-cache_grow-to-two-parts.patch
* mm-slab-refill-cpu-cache-through-a-new-slab-without-holding-a-node-lock.patch
* mm-slab-lockless-decision-to-grow-cache.patch
* compilerh-add-support-for-malloc-attribute.patch
* include-linux-apply-__malloc-attribute.patch
* include-linux-apply-__malloc-attribute-checkpatch-fixes.patch
* include-linux-nodemaskh-create-next_node_in-helper.patch
* mm-hugetlb-optimize-minimum-size-min_size-accounting.patch
* mm-hugetlb-introduce-hugetlb_bad_size.patch
* arm64-mm-use-hugetlb_bad_size.patch
* metag-mm-use-hugetlb_bad_size.patch
* powerpc-mm-use-hugetlb_bad_size.patch
* tile-mm-use-hugetlb_bad_size.patch
* x86-mm-use-hugetlb_bad_size.patch
* mm-hugetlb-is_vm_hugetlb_page-can-be-boolean.patch
* mm-memory_hotplug-is_mem_section_removable-can-be-boolean.patch
* mm-vmalloc-is_vmalloc_addr-can-be-boolean.patch
* mm-mempolicy-vma_migratable-can-be-boolean.patch
* mm-memcontrolc-mem_cgroup_select_victim_node-clarify-comment.patch
* mm-page_alloc-remove-useless-parameter-of-__free_pages_boot_core.patch
* mm-make-optimistic-check-for-swapin-readahead.patch
* mm-make-optimistic-check-for-swapin-readahead-fix-2.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-2.patch
* mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-3.patch
* mm-kasan-initial-memory-quarantine-implementation.patch
* mm-kasan-initial-memory-quarantine-implementation-v8.patch
* zsmalloc-use-first_page-rather-than-page.patch
* zsmalloc-clean-up-many-bug_on.patch
* zsmalloc-reordering-function-parameter.patch
* zsmalloc-remove-unused-pool-param-in-obj_free.patch
* mm-oom-rework-oom-detection.patch
* mm-oom-rework-oom-detection-checkpatch-fixes.patch
* mm-throttle-on-io-only-when-there-are-too-many-dirty-and-writeback-pages.patch
* mm-use-watermak-checks-for-__gfp_repeat-high-order-allocations.patch
* mm-use-watermak-checks-for-__gfp_repeat-high-order-allocations-checkpatch-fixes.patch
* mm-memblock-if-nr_new-is-0-just-return.patch
* maintainers-remove-linux-listsopenriscnet.patch
* lib-add-crc64-ecma-module.patch
* checkpatch-add-prefer_is_enabled-test.patch
* checkpatch-improve-constant_comparison-test-for-structure-members.patch
* init-mainc-simplify-initcall_blacklisted.patch
* wait-ptrace-assume-__wall-if-the-child-is-traced.patch
* wait-allow-sys_waitid-to-accept-__wnothread-__wclone-__wall.patch
* signal-make-oom_flags-a-bool.patch
* kexec-introduce-a-protection-mechanism-for-the-crashkernel-reserved-memory.patch
* kexec-provide-arch_kexec_protectunprotect_crashkres.patch
* kexec-make-a-pair-of-map-unmap-reserved-pages-in-error-path.patch
* kexec-do-a-cleanup-for-function-kexec_load.patch
* kdump-vmcoreinfo-report-actual-value-of-phys_base.patch
* ipc-semc-fix-complex_count-vs-simple-op-race.patch
* ipc-msgc-msgsnd-use-freezable-blocking-call.patch
* msgrcv-use-freezable-blocking-call.patch
  linux-next.patch
* drivers-net-wireless-intel-iwlwifi-dvm-calibc-fix-min-warning.patch
* staging-goldfish-use-6-arg-get_user_pages.patch
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
