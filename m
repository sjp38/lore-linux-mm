Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 295F2C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 23:37:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8444222C7
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 23:37:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8444222C7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 654278E0002; Tue, 12 Feb 2019 18:37:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 604368E0001; Tue, 12 Feb 2019 18:37:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 51A9A8E0002; Tue, 12 Feb 2019 18:37:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 01C268E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 18:37:47 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id t6so344948pgp.10
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 15:37:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :subject:message-id:user-agent;
        bh=CNpcK4tvSNodjY9bOeeuDoG5SgNLlBGVbOHia9lmrj0=;
        b=biJZTaA5ZEOb1SVkiS9AlyHNfWBblONkhZkuPdNBTwWZJYu/ypkRatcXiNE2+0MVIm
         rfN4qLSnLLSFn5DAs0IiYfYmRrTLneAb5bnO4fdQC9SIpxJiYf8xpny3z8cpym+FDm89
         uzfbsxKs66GjwwLUXjKQOkKjPWwjU6oqfKOPvjkEXv8j3h4APMQumrm3Bc0sDXxh9ymK
         THY9PlpAo37diSOVy/OCyFPX1X+CN4mk1+Pz4wnoD9XiQlybImunyKFY2wYgH6ieNu3H
         9nwMLXRqZfG7yaiVcDSqomzWmpgGjgl142hkTgtW9vSqk5qPSMhwqY5dzQm32C3aGBWQ
         xldA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AHQUAuZxJCyDQ//asPGKIcZI9+pjJ7GfIDog8ToOtyhqjLxPIihKMOM7
	mcl4C2r+I3GDly7ETWaSP6g29KSNEtXygWBcu5EOF01GUP8f7VcjihGJCEYXPQRKx4YGyR0F4bU
	NZoPAwOYKRF0+04gmBM0jv5I0WLD57zHx4CY3dkJUWK3oZU6w1114APnqifjRUNUIyg==
X-Received: by 2002:a17:902:b494:: with SMTP id y20mr6772050plr.178.1550014666567;
        Tue, 12 Feb 2019 15:37:46 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZZXtjZP8/fiKlsfjAJwj8+ibeWKCPLfGMvLom5QlyRaJNHaZ4ErfwGjnhbCp4NbTmyOqbg
X-Received: by 2002:a17:902:b494:: with SMTP id y20mr6771965plr.178.1550014665039;
        Tue, 12 Feb 2019 15:37:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550014665; cv=none;
        d=google.com; s=arc-20160816;
        b=qZjRgrVnB6aFKHveIqoKzR6Brsr4ytXOb2iJ9VH2+FiX8WV1jGJJU+sLfkor2157Et
         YOoz0DPRSX4NQnMKvsRYwi0vUr2AV7QcJi1GnTCu2MnebVLyqT02o4gzBjI5F5IvnzFr
         NK+RaQZbt9KU7n63K1bDrvoQFcXIYuRCemQArAXvESdwOBOwI7mpFPbF+33McUZYzsHZ
         gPbt/Mw1uM6SHXqDNJyFFw13G6UPQ/wi8jbrMEcr5Rc4rHcFORJF+jjwutB8/Y5Co8Wi
         80I7ehYdcEiIotov279Aqj56Ci5MzE8DdbSfJGTMNFpcvzQTB2M1BQBtyBgQHqudrNL2
         aj9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:message-id:subject:to:from:date;
        bh=CNpcK4tvSNodjY9bOeeuDoG5SgNLlBGVbOHia9lmrj0=;
        b=k0iIi7tmLFSb0C6FXBC0T5MIJdPVl5/rzTrsQCVGXv+x6v2p5P9ZBjNvtTF2jnsE4N
         u23cX4L02Xe5vh8ZMZEe7ytGmgI1o8dloHBPjpbP/YuXTQqU8gH44A2+fmJsTkxyT3RP
         C9arisd6jgTojtXVVhKflv9dejdSwaDWmQMhlxdh5RPtpPw5L/y7JR1EtY2qjshWpK4R
         sylpkoxlt9R+MsOgf0Yf5LXm/7Twmmn0Pi6uAFYIKC4HyO7uqY98M7XXDN0axxEqnWy/
         vC5z0drXJi2HtFehbcrBUrjfgKOpE5hVT+N83jtPm0xfSjohufDczMq/84Jyt1Ar7tJ2
         lbww==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l10si3583893pgp.25.2019.02.12.15.37.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 15:37:45 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 77756E138;
	Tue, 12 Feb 2019 23:37:44 +0000 (UTC)
Date: Tue, 12 Feb 2019 15:37:43 -0800
From: akpm@linux-foundation.org
To: broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au,
 linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 mm-commits@vger.kernel.org
Subject:  mmotm 2019-02-12-15-37 uploaded
Message-ID: <20190212233743.mGzbg%akpm@linux-foundation.org>
User-Agent: s-nail v14.9.6
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The mm-of-the-moment snapshot 2019-02-12-15-37 has been uploaded to

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


This mmotm tree contains the following patches against 5.0-rc6:
(patches marked "*" will be included in linux-next)

  origin.patch
* revert-mm-dont-reclaim-inodes-with-many-attached-pages.patch
* revert-mm-slowly-shrink-slabs-with-a-relatively-small-number-of-objects.patch
* mm-gup-fix-gup_pmd_range-for-dax.patch
* revert-mm-use-early_pfn_to_nid-in-page_ext_init.patch
* rename-include-uapi-=-asm-generic-shmparamh-really.patch
* mm-proc-smaps_rollup-fix-pss_locked-calculation.patch
* checkpatch-dont-interpret-stack-dumps-as-commit-ids.patch
* revert-initramfs-cleanup-incomplete-rootfs.patch
* numa-change-get_mempolicy-to-use-nr_node_ids-instead-of-max_numnodes.patch
* kasan-fix-assigning-tags-twice.patch
* kasan-kmemleak-pass-tagged-pointers-to-kmemleak.patch
* kmemleak-account-for-tagged-pointers-when-calculating-pointer-range.patch
* kasan-slub-move-kasan_poison_slab-hook-before-page_address.patch
* kasan-slub-move-kasan_poison_slab-hook-before-page_address-fix.patch
* kasan-slub-fix-conflicts-with-config_slab_freelist_hardened.patch
* slub-fix-slab_consistency_checks-kasan_sw_tags.patch
* proc-oom-do-not-report-alien-mms-when-setting-oom_score_adj.patch
* huegtlbfs-fix-races-and-page-leaks-during-migration.patch
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
* ocfs2-dlm-clean-dlm_lksb_get_lvb-and-dlm_lksb_put_lvb-when-the-cancel_pending-is-set.patch
* ocfs2-dlm-return-dlm_cancelgrant-if-the-lock-is-on-granted-list-and-the-operation-is-canceled.patch
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
* mm-shuffle-default-enable-all-shuffling.patch
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
* kernel-hung_taskc-fix-sparse-warnings.patch
* kernel-sys-annotate-implicit-fall-through.patch
* spellingtxt-add-more-spellings-to-spellingtxt.patch
* build_bugh-add-wrapper-for-_static_assert.patch
* lib-vsprintfc-move-sizeofstruct-printf_spec-next-to-its-definition.patch
* linux-fsh-move-member-alignment-check-next-to-definition-of-struct-filename.patch
* linux-kernelh-use-short-to-define-ushrt_max-shrt_max-shrt_min.patch
* linux-kernelh-split-_max-and-_min-macros-into-linux-limitsh.patch
* bitopsh-set_mask_bits-to-return-old-value.patch
* lib-genallocc-export-symbol-addr_in_gen_pool.patch
* lib-genallocc-rename-addr_in_gen_pool-to-gen_pool_has_addr.patch
* lib-genallocc-rename-addr_in_gen_pool-to-gen_pool_has_addr-fix.patch
* lib-div64-off-by-one-in-shift.patch
* lib-test_ubsan-vla-no-longer-used-in-kernel.patch
* assoc_array-mark-expected-switch-fall-through.patch
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
* ptrace-take-into-account-saved_sigmask-in-ptrace_getsetsigmask.patch
* signal-allow-the-null-signal-in-rt_sigqueueinfo.patch
* coredump-replace-opencoded-set_mask_bits.patch
* exec-increase-binprm_buf_size-to-256.patch
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
* fs-fs_parser-fix-printk-format-warning.patch
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
* memblock-memblock_alloc_try_nid-dont-panic.patch
* memblock-drop-memblock_alloc__nopanic-variants.patch
* memblock-remove-memblock_setclear_region_flags.patch
* memblock-split-checks-whether-a-region-should-be-skipped-to-a-helper-function.patch
* memblock-update-comments-and-kernel-doc.patch
* memblock-update-comments-and-kernel-doc-fix.patch
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

