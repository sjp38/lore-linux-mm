Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 681EDC282DB
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 23:16:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1117E2148D
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 23:16:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1117E2148D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A160C8E000B; Fri,  1 Feb 2019 18:16:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 99CE48E0001; Fri,  1 Feb 2019 18:16:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 83CF88E000B; Fri,  1 Feb 2019 18:16:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 25C9B8E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 18:16:22 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id q64so6849652pfa.18
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 15:16:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :subject:message-id:user-agent;
        bh=ke1o9DX5rCmixP++FxVTlB/AgasRgIpavWe/jO1KG0E=;
        b=BJLHAygAOq6jyg8/Ax76P6YwnOpwfgtc1Lk+tlf964S2BnrBLgQUlBSra0TsE+awr9
         n8ZrEcb5qT1EaaQe5PXMrTdILFgisL9nTp/DKOxM8zBKfYs/k2aQGSt1njJVsM6kCsrG
         kRNfn9M94nigiSGAGW9v4PKP2MI4A6tosngd71HDuW55DVItcHsC056fJw0+EznpS/p7
         ow36P8nFwjpWTwJ4vXoeN+5uxtJwQv6LE9zPZEsAoizKv7ejIjf36l85A5UidwjRGBVf
         hDDkUkZ2iF7ydFKtGO0RqD2XE1YE3lqjHw6tiNClXWBK+Gb8LiXZ+4bIYqA3+BeinLIy
         3ROA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAuYWwbKGdKl9pHb1QUGdLGVXWK2ViWMTNRt1wy+9AZU4CI8qDqXR
	nI+hOId1y7FL2NYlyX+uHjEDQGplo13gKBZOTwUwfNDOykd9rRqcFARXBmcizUc5s43uUAcfv/E
	K3YZIY8ojLViSdJw+04Ny2bmQpGoDMd9APSlZ9EkgtLEmBxqIiS8tnWqGVDxbsz7+PA==
X-Received: by 2002:a63:e711:: with SMTP id b17mr4116689pgi.363.1549062981681;
        Fri, 01 Feb 2019 15:16:21 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib2+p9dy5BGcO2AZqC9+lX0cYdzLJQhB7VxmESwkjEzqNg4TOhp8i6Wma+owYahjvN9NV4Y
X-Received: by 2002:a63:e711:: with SMTP id b17mr4116603pgi.363.1549062979990;
        Fri, 01 Feb 2019 15:16:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549062979; cv=none;
        d=google.com; s=arc-20160816;
        b=nv8qBT8ny/xRDL0gywU9oW0QZlzQt5tvUiw1emJv5VmLr2YZWTVj8x60z+PbxgF8po
         yW0K8Jm6HWfLYlvhW0qb7S27tDXXYQcfU+Ca6ePsK2Ly3sk90j60reG2NmMi1hW4byTk
         SRtoTLjOFqIhpd4CiRDxFjIxzHl9HecfGyE2oPAYT/2hSGd3G9Sc3KPARIiYQVuJa7IO
         jEL15nuWZS9p7V9PzghCBSUfmvWf+8L2Nva+odDDFnplyJ2NYsO0aRpMJBIXRcrUxFwF
         Nnz/7/ijbdtuKUpYddOwlQEy/CuzkTbLBcEPAz4vz+6RhGxy1VwqftswsZv32wsxK/93
         6Gjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:message-id:subject:to:from:date;
        bh=ke1o9DX5rCmixP++FxVTlB/AgasRgIpavWe/jO1KG0E=;
        b=Lj68NWd3Cns+Cz1zj2vPaidoYEPUvS5YzfmTra+GGK5+9IVAUNp6T1WjVGBh67YN0t
         tbRe6iISBL+W9CLB6cONbEwhXZG66cXTP+nSWp98/Tp/D3wAqXeI0ojvSIAk2Lc4ILHG
         lZUWTgmXq+72zvSXJSFESZOhkFym1i0RFsCGY2hWOOaWIJdlxrFwc/j+Jk1WAJLb/AIB
         khKB5W+5GfkHUj/WXpPOvYY+jiL63v2cz1RFJ+eQIRK/fmU7i71ilW6zHvX7RQERa3H0
         jKgPPQumd5j4CQCQ1FD3wy9eImz4DxEK2PPpgeGVhOeEr7O3LkHX0TnP8MNQFhobdoPL
         JtSA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t11si8441346plo.293.2019.02.01.15.16.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 15:16:19 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 5887B7F0F;
	Fri,  1 Feb 2019 23:16:19 +0000 (UTC)
Date: Fri, 01 Feb 2019 15:16:18 -0800
From: akpm@linux-foundation.org
To: broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au,
 linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 mm-commits@vger.kernel.org
Subject:  mmotm 2019-02-01-15-15 uploaded
Message-ID: <20190201231618.mbSbK%akpm@linux-foundation.org>
User-Agent: s-nail v14.9.6
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The mm-of-the-moment snapshot 2019-02-01-15-15 has been uploaded to

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


This mmotm tree contains the following patches against 5.0-rc4:
(patches marked "*" will be included in linux-next)

  origin.patch
* mm-memory_hotplug-dont-bail-out-in-do_migrate_range-prematurely.patch
* proc-fix-proc-net-after-setns2.patch
* arch-unexport-asm-shmparamh-for-all-architectures.patch
* mm-hugetlbc-teach-follow_hugetlb_page-to-handle-foll_nowait.patch
* x86_64-increase-stack-size-for-kasan_extra.patch
* kernel-release-ptraced-tasks-before-zap_pid_ns_processes.patch
* mm-migrate-make-buffer_migrate_page_norefs-actually-succeed.patch
* oom-oom_reaper-do-not-enqueue-same-task-twice.patch
* mm-memory_hotplug-is_mem_section_removable-do-not-pass-the-end-of-a-zone.patch
* mm-memory_hotplug-test_pages_in_a_zone-do-not-pass-the-end-of-zone.patch
* psi-fix-aggregation-idle-shut-off.patch
* mmmemory_hotplug-fix-scan_movable_pages-for-gigantic-hugepages.patch
* mm-hotplug-invalid-pfns-from-pfn_to_online_page.patch
* mm-oom-fix-use-after-free-in-oom_kill_process.patch
* lib-test_kmod-potential-double-free-in-error-handling.patch
* init-kconfig-fix-grammar-by-moving-a-closing-parenthesis.patch
* kasan-mark-file-common-so-ftrace-doesnt-trace-it.patch
* mm-hwpoison-use-do_send_sig_info-instead-of-force_sig-re-pmem-error-handling-forces-sigkill-causes-kernel-panic.patch
* mm-memory_hotplug-__offline_pages-fix-wrong-locking.patch
* psi-clarify-the-kconfig-text-for-the-default-disable-option.patch
* mm-migrate-dont-rely-on-__pagemovable-of-newpage-after-unlocking-it.patch
* vfs-avoid-softlockups-in-drop_pagecache_sb.patch
* autofs-drop-dentry-reference-only-when-it-is-never-used.patch
* autofs-fix-error-return-in-autofs_fill_super.patch
* checkpatch-dont-interpret-stack-dumps-as-commit-ids.patch
* mm-proc-smaps_rollup-fix-pss_locked-calculation.patch
* mmslabvmscan-accumulate-gradual-pressure-on-small-slabs.patch
* mmslabvmscan-accumulate-gradual-pressure-on-small-slabs-fix.patch
* mmslabvmscan-accumulate-gradual-pressure-on-small-slabs-fix-2.patch
* mm-gup-fix-gup_pmd_range-for-dax.patch
* huegtlbfs-fix-page-leak-during-migration-of-file-pages.patch
* revert-mm-use-early_pfn_to_nid-in-page_ext_init.patch
* kasan-remove-use-after-scope-bugs-detection.patch
* page_poison-play-nicely-with-kasan.patch
* kasan-fix-kasan_check_read-write-definitions.patch
* scripts-decode_stacktracesh-handle-rip-address-with-segment.patch
* sh-remove-nargs-from-__syscall.patch
* sh-generate-uapi-header-and-syscall-table-header-files.patch
* debugobjects-move-printk-out-of-db-lock-critical-sections.patch
* ocfs2-fix-a-panic-problem-caused-by-o2cb_ctl.patch
* ocfs2-fix-the-application-io-timeout-when-fstrim-is-running.patch
* ocfs2-use-zero-sized-array-and-struct_size-in-kzalloc.patch
* ocfs2-clear-zero-in-unaligned-direct-io.patch
* ocfs2-clear-zero-in-unaligned-direct-io-checkpatch-fixes.patch
* ocfs2-dlm-clean-dlm_lksb_get_lvb-and-dlm_lksb_put_lvb-when-the-cancel_pending-is-set.patch
* ocfs2-dlm-return-dlm_cancelgrant-if-the-lock-is-on-granted-list-and-the-operation-is-canceled.patch
* fs-filec-initialize-init_filesresize_wait.patch
  mm.patch
* mm-slubc-freelist-is-ensured-to-be-null-when-new_slab-fails.patch
* mm-slub-introduce-slab_warn_on_error.patch
* mm-slub-introduce-slab_warn_on_error-fix.patch
* slab-kmemleak-no-scan-alien-caches.patch
* memory_hotplug-free-pages-as-higher-order.patch
* mm-page_allocc-memory_hotplug-free-pages-as-higher-order-v11.patch
* mm-page_allocc-memory_hotplug-free-pages-as-higher-order-v11-fix.patch
* mm-balloon-update-comment-about-isolation-migration-compaction.patch
* mm-convert-pg_balloon-to-pg_offline.patch
* mm-convert-pg_balloon-to-pg_offline-fix.patch
* kexec-export-pg_offline-to-vmcoreinfo.patch
* xen-balloon-mark-inflated-pages-pg_offline.patch
* hv_balloon-mark-inflated-pages-pg_offline.patch
* vmw_balloon-mark-inflated-pages-pg_offline.patch
* vmw_balloon-mark-inflated-pages-pg_offline-v2.patch
* pm-hibernate-use-pfn_to_online_page.patch
* pm-hibernate-exclude-all-pageoffline-pages.patch
* pm-hibernate-exclude-all-pageoffline-pages-v2.patch
* mm-refactor-readahead-defines-in-mmh.patch
* mm-vmallocc-dont-dereference-possible-null-pointer-in-__vunmap.patch
* mm-replace-all-open-encodings-for-numa_no_node.patch
* tools-replace-open-encodings-for-numa_no_node.patch
* tools-replace-open-encodings-for-numa_no_node-fix.patch
* mm-reuse-only-pte-mapped-ksm-page-in-do_wp_page.patch
* mm-reuse-only-pte-mapped-ksm-page-in-do_wp_page-fix.patch
* powerpc-prefer-memblock-apis-returning-virtual-address.patch
* microblaze-prefer-memblock-api-returning-virtual-address.patch
* sh-prefer-memblock-apis-returning-virtual-address.patch
* openrisc-simplify-pte_alloc_one_kernel.patch
* arch-simplify-several-early-memory-allocations.patch
* arm-s390-unicore32-remove-oneliner-wrappers-for-memblock_alloc.patch
* mm-slub-make-the-comment-of-put_cpu_partial-complete.patch
* memcg-localize-memcg_kmem_enabled-check.patch
* mm-vmalloc-make-vmalloc_32_user-align-base-kernel-virtual-address-to-shmlba.patch
* mm-vmalloc-fix-size-check-for-remap_vmalloc_range_partial.patch
* mm-vmalloc-do-not-call-kmemleak_free-on-not-yet-accounted-memory.patch
* mm-vmalloc-pass-vm_usermap-flags-directly-to-__vmalloc_node_range.patch
* vmalloc-export-__vmalloc_node_range-for-config_test_vmalloc_module.patch
* vmalloc-add-test-driver-to-analyse-vmalloc-allocator.patch
* vmalloc-add-test-driver-to-analyse-vmalloc-allocator-fix.patch
* selftests-vm-add-script-helper-for-config_test_vmalloc_module.patch
* mm-remove-sysctl_extfrag_handler.patch
* openvswitch-convert-to-kvmalloc.patch
* md-convert-to-kvmalloc.patch
* selinux-convert-to-kvmalloc.patch
* generic-radix-trees.patch
* proc-commit-to-genradix.patch
* sctp-convert-to-genradix.patch
* drop-flex_arrays.patch
* mm-hugetlb-distinguish-between-migratability-and-movability.patch
* mm-hugetlb-enable-pud-level-huge-page-migration.patch
* mm-hugetlb-enable-arch-specific-huge-page-size-support-for-migration.patch
* arm64-mm-enable-hugetlb-migration.patch
* arm64-mm-enable-hugetlb-migration-for-contiguous-bit-hugetlb-pages.patch
* mm-remove-extra-drain-pages-on-pcp-list.patch
* mm-create-the-new-vm_fault_t-type.patch
* mm-create-the-new-vm_fault_t-type-fix.patch
* mm-hmm-convert-to-use-vm_fault_t.patch
* include-linux-nodemaskh-use-nr_node_ids-not-max_numnodes-in-__nodemask_pr_numnodes.patch
* mm-memcontrol-use-struct_size-in-kmalloc.patch
* mm-remove-redundant-test-from-find_get_pages_contig.patch
* memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work.patch
* memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work-v3.patch
* mm-swap-check-if-swap-backing-device-is-congested-or-not.patch
* mm-swap-check-if-swap-backing-device-is-congested-or-not-fix.patch
* mm-swap-check-if-swap-backing-device-is-congested-or-not-fix-2.patch
* mm-swap-add-comment-for-swap_vma_readahead.patch
* mm-shuffle-gfp_-flags.patch
* mm-filemap-pass-inclusive-end_byte-parameter-to-filemap_range_has_page.patch
* mm-compaction-shrink-compact_control.patch
* mm-compaction-rearrange-compact_control.patch
* mm-compaction-remove-last_migrated_pfn-from-compact_control.patch
* mm-compaction-remove-unnecessary-zone-parameter-in-some-instances.patch
* mm-compaction-rename-map_pages-to-split_map_pages.patch
* mm-migrate-immediately-fail-migration-of-a-page-with-no-migration-handler.patch
* mm-compaction-always-finish-scanning-of-a-full-pageblock.patch
* mm-compaction-ignore-the-fragmentation-avoidance-boost-for-isolation-and-compaction.patch
* mm-compaction-use-free-lists-to-quickly-locate-a-migration-source.patch
* mm-compaction-keep-migration-source-private-to-a-single-compaction-instance.patch
* mm-compaction-use-free-lists-to-quickly-locate-a-migration-target.patch
* mm-compaction-avoid-rescanning-the-same-pageblock-multiple-times.patch
* mm-compaction-finish-pageblock-scanning-on-contention.patch
* mm-compaction-check-early-for-huge-pages-encountered-by-the-migration-scanner.patch
* mm-compaction-keep-cached-migration-pfns-synced-for-unusable-pageblocks.patch
* mm-compaction-rework-compact_should_abort-as-compact_check_resched.patch
* mm-compaction-do-not-consider-a-need-to-reschedule-as-contention.patch
* mm-compaction-reduce-premature-advancement-of-the-migration-target-scanner.patch
* mm-compaction-round-robin-the-order-while-searching-the-free-lists-for-a-target.patch
* mm-compaction-sample-pageblocks-for-free-pages.patch
* mm-compaction-be-selective-about-what-pageblocks-to-clear-skip-hints.patch
* mm-compaction-capture-a-page-under-direct-compaction.patch
* mm-compaction-capture-a-page-under-direct-compaction-fix.patch
* fs-kernfs-add-poll-file-operation.patch
* kernel-cgroup-add-poll-file-operation.patch
* psi-introduce-state_mask-to-represent-stalled-psi-states.patch
* psi-rename-psi-fields-in-preparation-for-psi-trigger-addition.patch
* mm-create-mem_cgroup_from_seq.patch
* mm-extract-memcg-maxable-seq_file-logic-to-seq_show_memcg_tunable.patch
* mm-vmalloc-fix-kernel-bug-at-mm-vmallocc-512.patch
* mm-add-priority-threshold-to-__purge_vmap_area_lazy.patch
* mm-prevent-mapping-slab-pages-to-userspace.patch
* mm-prevent-mapping-typed-pages-to-userspace.patch
* mm-proportional-memorylowmin-reclaim.patch
* mm-proportional-memorylowmin-reclaim-checkpatch-fixes.patch
* mm-proportional-memorylowmin-reclaim-fix.patch
* mm-no-need-to-check-return-value-of-debugfs_create-functions.patch
* mm-oom-remove-prefer-children-over-parent-heuristic.patch
* mm-oom-remove-prefer-children-over-parent-heuristic-checkpatch-fixes.patch
* mm-mmapc-remove-some-redundancy-in-arch_get_unmapped_area_topdown.patch
* mm-page_owner-move-config-option-to-mm-kconfigdebug.patch
* mm-fix-some-typo-scatter-in-mm-directory.patch
* mm-hmm-use-reference-counting-for-hmm-struct.patch
* mm-hmm-do-not-erase-snapshot-when-a-range-is-invalidated.patch
* mm-hmm-improve-and-rename-hmm_vma_get_pfns-to-hmm_range_snapshot.patch
* mm-hmm-improve-and-rename-hmm_vma_fault-to-hmm_range_fault.patch
* mm-hmm-improve-driver-api-to-work-and-wait-over-a-range.patch
* mm-hmm-add-default-fault-flags-to-avoid-the-need-to-pre-fill-pfns-arrays.patch
* mm-hmm-add-an-helper-function-that-fault-pages-and-map-them-to-a-device.patch
* mm-hmm-support-hugetlbfs-snap-shoting-faulting-and-dma-mapping.patch
* mm-hmm-allow-to-mirror-vma-of-a-file-on-a-dax-backed-filesystem.patch
* mm-hmm-add-helpers-for-driver-to-safely-take-the-mmap_sem.patch
* mm-update-ptep_modify_prot_start-commit-to-take-vm_area_struct-as-arg.patch
* mm-update-ptep_modify_prot_commit-to-take-old-pte-value-as-arg.patch
* arch-powerpc-mm-nest-mmu-workaround-for-mprotect-rw-upgrade.patch
* mm-hugetlb-add-prot_modify_start-commit-sequence-for-hugetlb-update.patch
* arch-powerpc-mm-hugetlb-nestmmu-workaround-for-hugetlb-mprotect-rw-upgrade.patch
* mm-page_alloc-check-return-value-of-memblock_alloc_node_nopanic.patch
* mm-add-probe_user_read.patch
* powerpc-use-probe_user_read.patch
* memcg-killed-threads-should-not-invoke-memcg-oom-killer.patch
* mm-mempolicy-fix-uninit-memory-access.patch
* mm-remove-7th-argument-of-isolate_lru_pages.patch
* mm-refactor-swap-in-logic-out-of-shmem_getpage_gfp.patch
* mm-rid-swapoff-of-quadratic-complexity.patch
* agp-efficeon-no-need-to-set-pg_reserved-on-gatt-tables.patch
* s390-vdso-dont-clear-pg_reserved.patch
* powerpc-vdso-dont-clear-pg_reserved.patch
* riscv-vdso-dont-clear-pg_reserved.patch
* m68k-mm-use-__clearpagereserved.patch
* arm64-kexec-no-need-to-clearpagereserved.patch
* arm64-kdump-no-need-to-mark-crashkernel-pages-manually-pg_reserved.patch
* ia64-perfmon-dont-mark-buffer-pages-as-pg_reserved.patch
* mm-better-document-pg_reserved.patch
* mm-cma-add-pf-flag-to-force-non-cma-alloc.patch
* mm-update-get_user_pages_longterm-to-migrate-pages-allocated-from-cma-region.patch
* powerpc-mm-iommu-allow-migration-of-cma-allocated-pages-during-mm_iommu_do_alloc.patch
* powerpc-mm-iommu-allow-large-iommu-page-size-only-for-hugetlb-backing.patch
* mm-memfd-add-an-f_seal_future_write-seal-to-memfd.patch
* selftests-memfd-add-tests-for-f_seal_future_write-seal.patch
* mm-swap-use-mem_cgroup_is_root-instead-of-deferencing-css-parent.patch
* mm-vmscan-do-not-iterate-all-mem-cgroups-for-global-direct-reclaim.patch
* mm-memcontrol-expose-thp-events-on-a-per-memcg-basis.patch
* mm-memcontrol-expose-thp-events-on-a-per-memcg-basis-fix.patch
* mm-memcontrol-expose-thp-events-on-a-per-memcg-basis-fix-2.patch
* mm-ksm-do-not-block-on-page-lock-when-searching-stable-tree.patch
* mm-vmalloc-convert-vmap_lazy_nr-to-atomic_long_t.patch
* mm-do-not-allocate-duplicate-stack-variables-in-shrink_page_list.patch
* mm-swap-bounds-check-swap_info-array-accesses-to-avoid-null-derefs.patch
* mmoom-dont-kill-global-init-via-memoryoomgroup.patch
* mm-use-mm_zero_struct_page-from-sparc-on-all-64b-architectures.patch
* mm-drop-meminit_pfn_in_nid-as-it-is-redundant.patch
* mm-implement-new-zone-specific-memblock-iterator.patch
* mm-initialize-max_order_nr_pages-at-a-time-instead-of-doing-larger-sections.patch
* mm-move-hot-plug-specific-memory-init-into-separate-functions-and-optimize.patch
* mm-add-reserved-flag-setting-to-set_page_links.patch
* mm-use-common-iterator-for-deferred_init_pages-and-deferred_free_pages.patch
* mm-page_alloc-calculate-first_deferred_pfn-directly.patch
* filemap-kill-page_cache_read-usage-in-filemap_fault.patch
* filemap-kill-page_cache_read-usage-in-filemap_fault-fix.patch
* filemap-pass-vm_fault-to-the-mmap-ra-helpers.patch
* filemap-drop-the-mmap_sem-for-all-blocking-operations.patch
* filemap-drop-the-mmap_sem-for-all-blocking-operations-v6.patch
* filemap-drop-the-mmap_sem-for-all-blocking-operations-fix.patch
* filemap-drop-the-mmap_sem-for-all-blocking-operations-checkpatch-fixes.patch
* mm-dont-expose-page-to-fast-gup-before-its-ready.patch
* info-task-hung-in-generic_file_write_iter.patch
* info-task-hung-in-generic_file_write-fix.patch
* proc-return-exit-code-4-for-skipped-tests.patch
* proc-code-cleanup-for-proc_setup_self.patch
* proc-code-cleanup-for-proc_setup_thread_self.patch
* proc-remove-unused-argument-in-proc_pid_lookup.patch
* proc-read-kernel-cpu-stat-pointer-once.patch
* proc-use-seq_puts-everywhere.patch
* kernelh-unconditionally-include-asm-div64h-for-do_div.patch
* taint-fix-debugfs_simple_attrcocci-warnings.patch
* kernel-hung_taskc-fix-sparse-warnings.patch
* kernel-sys-annotate-implicit-fall-through.patch
* spellingtxt-add-more-spellings-to-spellingtxt.patch
* lib-genallocc-export-symbol-addr_in_gen_pool.patch
* lib-genallocc-rename-addr_in_gen_pool-to-gen_pool_has_addr.patch
* lib-genallocc-rename-addr_in_gen_pool-to-gen_pool_has_addr-fix.patch
* lib-div64-off-by-one-in-shift.patch
* lib-test_ubsan-vla-no-longer-used-in-kernel.patch
* checkpatch-verify-spdx-comment-style.patch
* checkpatch-add-some-new-alloc-functions-to-various-tests.patch
* checkpatch-allow-reporting-c99-style-comments.patch
* epoll-make-sure-all-elements-in-ready-list-are-in-fifo-order.patch
* epoll-unify-awaking-of-wakeup-source-on-ep_poll_callback-path.patch
* epoll-use-rwlock-in-order-to-reduce-ep_poll_callback-contention.patch
* init-calibratec-provide-proper-prototype.patch
* autofs-add-ignore-mount-option.patch
* autofs-use-seq_puts-for-simple-strings-in-autofs_show_options.patch
* ptrace-take-into-account-saved_sigmask-in-ptrace_getsetsigmask.patch
* signal-allow-the-null-signal-in-rt_sigqueueinfo.patch
* exec-increase-binprm_buf_size-to-256.patch
* rapidio-potential-oops-in-riocm_ch_listen.patch
* sysctl-handle-overflow-in-proc_get_long.patch
* sysctl-handle-overflow-for-file-max.patch
* gcov-use-struct_size-in-kzalloc.patch
* configs-get-rid-of-obsolete-config_enable_warn_deprecated.patch
* kcov-no-need-to-check-return-value-of-debugfs_create-functions.patch
* kcov-convert-kcovrefcount-to-refcount_t.patch
* lib-ubsan-default-ubsan_alignment-to-not-set.patch
* ipc-allow-boot-time-extension-of-ipcmni-from-32k-to-8m.patch
* ipc-allow-boot-time-extension-of-ipcmni-from-32k-to-8m-checkpatch-fixes.patch
* ipc-conserve-sequence-numbers-in-extended-ipcmni-mode.patch
* ipc-annotate-implicit-fall-through.patch
* ipc-semc-replace-kvmalloc-memset-with-kvzalloc-and-use-struct_size.patch
  linux-next.patch
  linux-next-rejects.patch
* scripts-atomic-check-atomicssh-dont-assume-that-scripts-are-executable.patch
* proc-calculate-end-pointer-for-proc-lookup-at-compile-time.patch
* proc-calculate-end-pointer-for-proc-lookup-at-compile-time-fix.patch
* unicore32-stop-printing-the-virtual-memory-layout.patch
* mm-remove-duplicate-header.patch
* include-replace-tsk-to-task-in-linux-sched-signalh.patch
* openrisc-prefer-memblock-apis-returning-virtual-address.patch
* powerpc-use-memblock-functions-returning-virtual-address.patch
* memblock-replace-memblock_alloc_baseanywhere-with-memblock_phys_alloc.patch
* memblock-drop-memblock_alloc_base_nid.patch
* memblock-emphasize-that-memblock_alloc_range-returns-a-physical-address.patch
* memblock-memblock_phys_alloc_try_nid-dont-panic.patch
* memblock-memblock_phys_alloc-dont-panic.patch
* memblock-drop-__memblock_alloc_base.patch
* memblock-drop-memblock_alloc_base.patch
* memblock-refactor-internal-allocation-functions.patch
* memblock-make-memblock_find_in_range_node-and-choose_memblock_flags-static.patch
* arch-use-memblock_alloc-instead-of-memblock_alloc_fromsize-align-0.patch
* arch-dont-memset0-memory-returned-by-memblock_alloc.patch
* ia64-add-checks-for-the-return-value-of-memblock_alloc.patch
* sparc-add-checks-for-the-return-value-of-memblock_alloc.patch
* mm-percpu-add-checks-for-the-return-value-of-memblock_alloc.patch
* init-main-add-checks-for-the-return-value-of-memblock_alloc.patch
* swiotlb-add-checks-for-the-return-value-of-memblock_alloc.patch
* treewide-add-checks-for-the-return-value-of-memblock_alloc.patch
* treewide-add-checks-for-the-return-value-of-memblock_alloc-fix.patch
* treewide-add-checks-for-the-return-value-of-memblock_alloc-fix-2.patch
* treewide-add-checks-for-the-return-value-of-memblock_alloc-fix-3.patch
* memblock-memblock_alloc_try_nid-dont-panic.patch
* memblock-drop-memblock_alloc__nopanic-variants.patch
* relay-fix-percpu-annotation-in-struct-rchan.patch
* fork-remove-duplicated-include-from-forkc.patch
* samples-mic-mpssd-remove-duplicate-header.patch
* fix-read-buffer-overflow-in-delta-ipc.patch
  make-sure-nobodys-leaking-resources.patch
  releasing-resources-with-children.patch
  mutex-subsystem-synchro-test-module.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  slab-leaks3-default-y.patch
  workaround-for-a-pci-restoring-bug.patch

