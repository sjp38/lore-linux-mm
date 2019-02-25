Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ADA9CC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 21:41:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B07420652
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 21:41:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B07420652
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C18558E0005; Mon, 25 Feb 2019 16:41:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC88A8E0004; Mon, 25 Feb 2019 16:41:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB70F8E0005; Mon, 25 Feb 2019 16:41:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5B9698E0004
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 16:41:32 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id x23so5221345pfm.0
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 13:41:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :subject:message-id:user-agent;
        bh=21i61Qyai2bt0zBGJXWZXa8j+DBB8JsZYeG4V5eSjDA=;
        b=czOQbguix2skPFHaFxpvhPstq5Gw4D1OjUA0Z8B4Dm+1+waq6SwxeEjzSoUyEK7Opq
         PyT+17ClyZkQESZNehHReNPDHuorw+Xznyfbv4RweqPQ5d5QfDQpYcnFhIIQtzlsVE6h
         A3i256FzdDMMIoz4qc5jILfEbjAgKX7sb3hJ+lLeR//CERL1CbgYTEm/XXn5E4AFwBZC
         hFQUbKLuLauBRAW/7ErCF6GP3yN8LFI6uQ3cFVSJVcIuZohVUVO58+JAeJo+0m6ivD/h
         El1oP8eAazC6j75AUr5DOZqgQ9iFixKNvf8GV+jyCWPDGCgjFDR7nRy/ssiHk9RLk9HZ
         uolQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAuZ3Rga5mwaWatoYKeXYu5akGbYpfdz1q0GqPj7wLMkYirDPU9hi
	JiJaKuh5YdA/B6rN3xQyWCcoN8K53ljVqGKE6yste+KiDGIdIyU+MF2mafsmaEc6BJ9yG16l21T
	Do/ACwXW9ulCuMl9EcfCvkKrj06JtEV3pSmgL8AxN0YQHJnIUzjOmIYr7j1wFACi/Yg==
X-Received: by 2002:a17:902:8f8a:: with SMTP id z10mr22737232plo.23.1551130891802;
        Mon, 25 Feb 2019 13:41:31 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaQ+o/HTowXzdcB/xypZhqR7Czp/JHDF42EOsWDMHR7+D9XaHuQFI78y71OD1c1jmVGoYld
X-Received: by 2002:a17:902:8f8a:: with SMTP id z10mr22737100plo.23.1551130889403;
        Mon, 25 Feb 2019 13:41:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551130889; cv=none;
        d=google.com; s=arc-20160816;
        b=B+5axgMjY3LfHc7yg/BUTCRYl9lDQAvFNMq0lU35orGxDadbXU8WLQMz4rU90iMEIo
         2SJjeH+7yQ706KDbAGbwI9xpCXPBfdYmtcoqybXnmpNG8yoXEjsjR1GDCF3JS7tYkxKJ
         IMTn3qIg20ftmc4MWu/rKaNvgwStHXTR7DjouMr6XBA3XH3PUJr73xzOmUHT2sd4UgDe
         CccvHiEn8FTFTJgzwn7S0JT+NMdtfgHQAAr7CyVO7WfGQ44J5D2JOhwJSO6iHnM/oQBQ
         7IB636btsq2uhJjFKp769UY0TDn/Ni4WT3O4ZcDgSVjUWOo0gvbR2Xeje9K3VLYqLfLl
         2xhg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:message-id:subject:to:from:date;
        bh=21i61Qyai2bt0zBGJXWZXa8j+DBB8JsZYeG4V5eSjDA=;
        b=FN192rV3yINildo08nQ3ZMWSI1d8WKRHnTdgwhDiIJd94D5pJluhWBzawc3YUjGMei
         YDcmqP405gaBn58u9uzP8qHHuamHChhwZ0uTwDPWEsdrodCN8f+hElpUmcwMfiQwBAD0
         +tkladcmNQYpzyD4I0BSurjNRdvtMCO4vAP2xcRRuZvnVjacryIalpSG6ZyZovmNPFag
         UAsjItA+6ZJa1ATDfR7mE29c4M+NVgvbWolNHWwelkav/lut9LjcrATqkGCIFkz8xsXQ
         AeWmhukSLIMIusjdZFNF786wfLo2AeVpzAjEX8owjwEcPBKlWHgjKdtVthGOen2RPR+R
         tATA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q77si409821pfa.102.2019.02.25.13.41.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 13:41:29 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id BF5D96720;
	Mon, 25 Feb 2019 21:41:28 +0000 (UTC)
Date: Mon, 25 Feb 2019 13:41:26 -0800
From: akpm@linux-foundation.org
To: broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au,
 linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 mm-commits@vger.kernel.org
Subject:  mmotm 2019-02-25-13-40 uploaded
Message-ID: <20190225214126.vmS3t%akpm@linux-foundation.org>
User-Agent: s-nail v14.9.6
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The mm-of-the-moment snapshot 2019-02-25-13-40 has been uploaded to

   http://www.ozlabs.org/~akpm/mmotm/

mmotm-readme.txt says

README for mm-of-the-moment:

http://www.ozlabs.org/~akpm/mmotm/

This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
more than once a week.

You will need quilt to apply these patches to the latest Linus release (5.x
or 5.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
http://ozlabs.org/~akpm/mmotm/series

The file broken-out.tar.gz contains two datestamp files: .DATE and
.DATE-yyyy-mm-dd-hh-mm-ss.  Both contain the string yyyy-mm-dd-hh-mm-ss,
followed by the base kernel version against which this patch series is to
be applied.

This tree is partially included in linux-next.  To see which patches are
included in linux-next, consult the `series' file.  Only the patches
within the #NEXT_PATCHES_START/#NEXT_PATCHES_END markers are included in
linux-next.


A full copy of the full kernel tree with the linux-next and mmotm patches
already applied is available through git within an hour of the mmotm
release.  Individual mmotm releases are tagged.  The master branch always
points to the latest release, so it's constantly rebasing.

http://git.cmpxchg.org/cgit.cgi/linux-mmotm.git/



The directory http://www.ozlabs.org/~akpm/mmots/ (mm-of-the-second)
contains daily snapshots of the -mm tree.  It is updated more frequently
than mmotm, and is untested.

A git copy of this tree is available at

	http://git.cmpxchg.org/cgit.cgi/linux-mmots.git/

and use of this tree is similar to
http://git.cmpxchg.org/cgit.cgi/linux-mmotm.git/, described above.


This mmotm tree contains the following patches against 5.0-rc8:
(patches marked "*" will be included in linux-next)

* checkpatch-dont-interpret-stack-dumps-as-commit-ids.patch
* huegtlbfs-fix-races-and-page-leaks-during-migration.patch
* huegtlbfs-fix-races-and-page-leaks-during-migration-update.patch
* kasan-remove-use-after-scope-bugs-detection.patch
* page_poison-play-nicely-with-kasan.patch
* kasan-fix-kasan_check_read-write-definitions.patch
* scripts-decode_stacktracesh-handle-rip-address-with-segment.patch
* sh-remove-nargs-from-__syscall.patch
* debugobjects-move-printk-out-of-db-lock-critical-sections.patch
* ocfs2-fix-a-panic-problem-caused-by-o2cb_ctl.patch
* ocfs2-fix-the-application-io-timeout-when-fstrim-is-running.patch
* ocfs2-use-zero-sized-array-and-struct_size-in-kzalloc.patch
* ocfs2-clear-zero-in-unaligned-direct-io.patch
* ocfs2-clear-zero-in-unaligned-direct-io-checkpatch-fixes.patch
* ocfs2-wait-for-recovering-done-after-direct-unlock-request.patch
* ocfs2-checkpoint-appending-truncate-log-transaction-before-flushing.patch
* ramfs-support-o_tmpfile.patch
* fs-inode_set_flags-replace-opencoded-set_mask_bits.patch
* fs-filec-initialize-init_filesresize_wait.patch
  mm.patch
* mm-slubc-freelist-is-ensured-to-be-null-when-new_slab-fails.patch
* mm-slub-introduce-slab_warn_on_error.patch
* mm-slub-introduce-slab_warn_on_error-fix.patch
* slab-kmemleak-no-scan-alien-caches.patch
* slub-capitialize-comment-string.patch
* slub-remove-an-unused-addr-argument.patch
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
* mm-vmallocc-dont-dereference-possible-null-pointer-in-__vunmap.patch
* mm-replace-all-open-encodings-for-numa_no_node.patch
* tools-replace-open-encodings-for-numa_no_node.patch
* tools-replace-open-encodings-for-numa_no_node-fix.patch
* mm-reuse-only-pte-mapped-ksm-page-in-do_wp_page.patch
* mm-reuse-only-pte-mapped-ksm-page-in-do_wp_page-fix.patch
* mm-slub-make-the-comment-of-put_cpu_partial-complete.patch
* memcg-localize-memcg_kmem_enabled-check.patch
* mm-vmalloc-make-vmalloc_32_user-align-base-kernel-virtual-address-to-shmlba.patch
* mm-vmalloc-fix-size-check-for-remap_vmalloc_range_partial.patch
* mm-vmalloc-do-not-call-kmemleak_free-on-not-yet-accounted-memory.patch
* mm-vmalloc-pass-vm_usermap-flags-directly-to-__vmalloc_node_range.patch
* vmalloc-export-__vmalloc_node_range-for-config_test_vmalloc_module.patch
* vmalloc-add-test-driver-to-analyse-vmalloc-allocator.patch
* vmalloc-add-test-driver-to-analyse-vmalloc-allocator-fix.patch
* vmalloc-add-test-driver-to-analyse-vmalloc-allocator-fix-2.patch
* selftests-vm-add-script-helper-for-config_test_vmalloc_module.patch
* mm-remove-sysctl_extfrag_handler.patch
* mm-hugetlb-distinguish-between-migratability-and-movability.patch
* mm-hugetlb-enable-pud-level-huge-page-migration.patch
* mm-hugetlb-enable-arch-specific-huge-page-size-support-for-migration.patch
* arm64-mm-enable-hugetlb-migration.patch
* arm64-mm-enable-hugetlb-migration-for-contiguous-bit-hugetlb-pages.patch
* mm-remove-extra-drain-pages-on-pcp-list.patch
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
* mm-compaction-use-free-lists-to-quickly-locate-a-migration-source-fix.patch
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
* mm-compaction-be-selective-about-what-pageblocks-to-clear-skip-hints-fix.patch
* mm-compaction-capture-a-page-under-direct-compaction.patch
* mm-compaction-capture-a-page-under-direct-compaction-fix.patch
* fs-kernfs-add-poll-file-operation.patch
* kernel-cgroup-add-poll-file-operation.patch
* psi-introduce-state_mask-to-represent-stalled-psi-states.patch
* psi-rename-psi-fields-in-preparation-for-psi-trigger-addition.patch
* psi-introduce-psi-monitor.patch
* psi-introduce-psi-monitor-fix.patch
* psi-introduce-psi-monitor-fix-fix.patch
* psi-introduce-psi-monitor-fix-3.patch
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
* mm-hmm-improve-driver-api-to-work-and-wait-over-a-range-fix.patch
* mm-hmm-improve-driver-api-to-work-and-wait-over-a-range-fix-fix.patch
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
* mm-add-probe_user_read-fix.patch
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
* mm-ksm-do-not-block-on-page-lock-when-searching-stable-tree-fix.patch
* mm-vmalloc-convert-vmap_lazy_nr-to-atomic_long_t.patch
* mm-do-not-allocate-duplicate-stack-variables-in-shrink_page_list.patch
* mm-swap-bounds-check-swap_info-array-accesses-to-avoid-null-derefs.patch
* mmoom-dont-kill-global-init-via-memoryoomgroup.patch
* hugetlb-allow-to-free-gigantic-pages-regardless-of-the-configuration.patch
* numa-make-nr_node_ids-unsigned-int.patch
* numa-make-nr_online_nodes-unsigned-int.patch
* mm-make-memoryemin-the-baseline-for-utilisation-determination.patch
* mm-shuffle-initial-free-memory-to-improve-memory-side-cache-utilization.patch
* mm-shuffle-initial-free-memory-to-improve-memory-side-cache-utilization-fix.patch
* mm-move-buddy-list-manipulations-into-helpers.patch
* mm-move-buddy-list-manipulations-into-helpers-fix.patch
* mm-move-buddy-list-manipulations-into-helpers-fix2.patch
* mm-maintain-randomization-of-page-free-lists.patch
* mm-maintain-randomization-of-page-free-lists-checkpatch-fixes.patch
* mm-page_poison-update-comment-after-code-moved.patch
* docs-mm-vmalloc-re-indent-kernel-doc-comemnts.patch
* docs-core-api-mm-fix-user-memory-accessors-formatting.patch
* docs-core-api-mm-fix-return-value-descriptions-in-mm.patch
* mm-cleanup-expected_page_refs.patch
* mm-page_cache_add_speculative-refactor-out-some-code-duplication.patch
* mmmemory_hotplug-explicitly-pass-the-head-to-isolate_huge_page.patch
* mm-fix-potential-build-error-in-compactionh.patch
* mm-memory-hotplug-add-sysfs-hot-remove-trigger.patch
* tools-vm-slabinfo-update-options-in-usage-message.patch
* tools-vm-slabinfo-put-options-in-alphabetic-order.patch
* tools-vm-slabinfo-align-usage-output-columns.patch
* tools-vm-slabinfo-clean-up-usage-menu-debug-items.patch
* mm-unexport-free_reserved_area.patch
* mm-shmem-make-find_get_pages_range-work-for-huge-page.patch
* maintainers-add-entry-for-memblock.patch
* tmpfs-test-link-accounting-with-o_tmpfile.patch
* mm-cma_debug-avoid-to-use-global-cma_debugfs_root.patch
* mm-swapfilec-use-struct_size-in-kvzalloc.patch
* mm-hotplug-fix-an-imbalance-with-debug_pagealloc.patch
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
* proc-test-proc-maps-smaps-smaps_rollup-statm.patch
* proc-test-proc-maps-smaps-smaps_rollup-statm-fix.patch
* proc-more-robust-bulk-read-test.patch
* kernelh-unconditionally-include-asm-div64h-for-do_div.patch
* taint-fix-debugfs_simple_attrcocci-warnings.patch
* linux-kernelh-drop-the-gcc-33-const-hack-in-roundup.patch
* kernel-hung_taskc-fix-sparse-warnings.patch
* kernel-sys-annotate-implicit-fall-through.patch
* spellingtxt-add-more-spellings-to-spellingtxt.patch
* build_bugh-add-wrapper-for-_static_assert.patch
* lib-vsprintfc-move-sizeofstruct-printf_spec-next-to-its-definition.patch
* linux-fsh-move-member-alignment-check-next-to-definition-of-struct-filename.patch
* linux-kernelh-use-short-to-define-ushrt_max-shrt_max-shrt_min.patch
* linux-kernelh-split-_max-and-_min-macros-into-linux-limitsh.patch
* pid-remove-next_pidmap-declaration.patch
* linux-deviceh-use-dynamic_debug_branch-in-dev_dbg_ratelimited.patch
* linux-neth-use-dynamic_debug_branch-in-net_dbg_ratelimited.patch
* linux-printkh-use-dynamic_debug_branch-in-pr_debug_ratelimited.patch
* dynamic_debug-consolidate-define_dynamic_debug_metadata-definitions.patch
* dynamic_debug-dont-duplicate-modname-in-ddebug_add_module.patch
* dynamic_debug-use-pointer-comparison-in-ddebug_remove_module.patch
* dynamic_debug-remove-unused-export_symbols.patch
* dynamic_debug-move-pr_err-from-modulec-to-ddebug_add_module.patch
* dynamic_debug-add-static-inline-stub-for-ddebug_add_module.patch
* dynamic_debug-refactor-dynamic_pr_debug-and-friends.patch
* btrfs-implement-btrfs_debug-in-terms-of-helper-macro.patch
* acpi-use-proper-dynamic_debug_branch-macro.patch
* acpi-remove-unused-__acpi_handle_debug-macro.patch
* acpi-implement-acpi_handle_debug-in-terms-of-_dynamic_func_call.patch
* bitopsh-set_mask_bits-to-return-old-value.patch
* lib-genallocc-export-symbol-addr_in_gen_pool.patch
* lib-genallocc-rename-addr_in_gen_pool-to-gen_pool_has_addr.patch
* lib-genallocc-rename-addr_in_gen_pool-to-gen_pool_has_addr-fix.patch
* lib-div64-off-by-one-in-shift.patch
* lib-test_ubsan-vla-no-longer-used-in-kernel.patch
* assoc_array-mark-expected-switch-fall-through.patch
* test_firmware-remove-some-dead-code.patch
* checkpatch-verify-spdx-comment-style.patch
* checkpatch-add-some-new-alloc-functions-to-various-tests.patch
* checkpatch-allow-reporting-c99-style-comments.patch
* checkpatch-add-test-for-spdx-license-identifier-on-wrong-line.patch
* checkpatch-fix-something.patch
* epoll-make-sure-all-elements-in-ready-list-are-in-fifo-order.patch
* epoll-unify-awaking-of-wakeup-source-on-ep_poll_callback-path.patch
* epoll-use-rwlock-in-order-to-reduce-ep_poll_callback-contention.patch
* elf-dont-be-afraid-of-overflow.patch
* elf-use-list_for_each_entry.patch
* elf-use-list_for_each_entry-fix.patch
* elf-spread-const-a-little.patch
* init-calibratec-provide-proper-prototype.patch
* autofs-add-ignore-mount-option.patch
* autofs-use-seq_puts-for-simple-strings-in-autofs_show_options.patch
* autofs-clear-o_nonblock-on-the-pipe.patch
* fat-enable-splice_write-to-support-splice-on-o_direct-file.patch
* ptrace-take-into-account-saved_sigmask-in-ptrace_getsetsigmask.patch
* signal-allow-the-null-signal-in-rt_sigqueueinfo.patch
* coredump-replace-opencoded-set_mask_bits.patch
* exec-increase-binprm_buf_size-to-256.patch
* exec-increase-binprm_buf_size-to-256-fix.patch
* kernel-workqueue-clarify-wq_worker_last_func-caller-requirements.patch
* rapidio-potential-oops-in-riocm_ch_listen.patch
* test_sysctl-add-tests-for-32-bit-values-written-to-32-bit-integers.patch
* kernel-sysctlc-add-missing-range-check-in-do_proc_dointvec_minmax_conv.patch
* kernel-sysctlc-define-minmax-conv-functions-in-terms-of-non-minmax-versions.patch
* sysctl-handle-overflow-in-proc_get_long.patch
* sysctl-handle-overflow-for-file-max.patch
* sysctl-handle-overflow-for-file-max-v4.patch
* sysctl-return-einval-if-val-violates-minmax.patch
* gcov-use-struct_size-in-kzalloc.patch
* configs-get-rid-of-obsolete-config_enable_warn_deprecated.patch
* kernel-configs-use-incbin-directive-to-embed-config_datagz.patch
* kernel-configs-use-incbin-directive-to-embed-config_datagz-v2.patch
* kcov-no-need-to-check-return-value-of-debugfs_create-functions.patch
* kcov-convert-kcovrefcount-to-refcount_t.patch
* lib-ubsan-default-ubsan_alignment-to-not-set.patch
* initramfs-provide-more-details-in-error-messages.patch
* ipc-allow-boot-time-extension-of-ipcmni-from-32k-to-8m.patch
* ipc-allow-boot-time-extension-of-ipcmni-from-32k-to-8m-checkpatch-fixes.patch
* ipc-conserve-sequence-numbers-in-extended-ipcmni-mode.patch
* ipc-annotate-implicit-fall-through.patch
* ipc-semc-replace-kvmalloc-memset-with-kvzalloc-and-use-struct_size.patch
* lib-lzo-tidy-up-ifdefs.patch
* lib-lzo-64-bit-ctz-on-arm64.patch
* lib-lzo-fast-8-byte-copy-on-arm64.patch
* lib-lzo-implement-run-length-encoding.patch
* lib-lzo-separate-lzo-rle-from-lzo.patch
* zram-default-to-lzo-rle-instead-of-lzo.patch
  linux-next.patch
  linux-next-rejects.patch
* pinctrl-fix-pxa2xxc-build-warnings.patch
* scripts-atomic-check-atomicssh-dont-assume-that-scripts-are-executable.patch
* powerpc-prefer-memblock-apis-returning-virtual-address.patch
* microblaze-prefer-memblock-api-returning-virtual-address.patch
* sh-prefer-memblock-apis-returning-virtual-address.patch
* openrisc-simplify-pte_alloc_one_kernel.patch
* arch-simplify-several-early-memory-allocations.patch
* arm-s390-unicore32-remove-oneliner-wrappers-for-memblock_alloc.patch
* mm-create-the-new-vm_fault_t-type.patch
* mm-create-the-new-vm_fault_t-type-fix.patch
* mm-hmm-convert-to-use-vm_fault_t.patch
* mm-hmm-convert-to-use-vm_fault_t-fix.patch
* maintainers-fix-gta02-entry-and-mark-as-orphan.patch
* fs-fs_parser-fix-printk-format-warning.patch
* mm-refactor-readahead-defines-in-mmh.patch
* mm-refactor-readahead-defines-in-mmh-fix.patch
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
* memblock-refactor-internal-allocation-functions-fix.patch
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
* treewide-add-checks-for-the-return-value-of-memblock_alloc-fix-3-fix.patch
* memblock-memblock_alloc_try_nid-dont-panic.patch
* memblock-drop-memblock_alloc__nopanic-variants.patch
* memblock-remove-memblock_setclear_region_flags.patch
* memblock-split-checks-whether-a-region-should-be-skipped-to-a-helper-function.patch
* memblock-update-comments-and-kernel-doc.patch
* memblock-update-comments-and-kernel-doc-fix.patch
* of-fix-kmemleak-crash-caused-by-imbalance-in-early-memory-reservation.patch
* of-fix-kmemleak-crash-caused-by-imbalance-in-early-memory-reservation-fix.patch
* mm-rename-ambiguously-named-memorystat-counters-and-functions.patch
* mm-consider-subtrees-in-memoryevents.patch
* openvswitch-convert-to-kvmalloc.patch
* md-convert-to-kvmalloc.patch
* selinux-convert-to-kvmalloc.patch
* generic-radix-trees.patch
* proc-commit-to-genradix.patch
* sctp-convert-to-genradix.patch
* drop-flex_arrays.patch
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

