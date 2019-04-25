Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C932CC4321A
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 23:31:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF0B42077C
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 23:31:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="UtVMI8Ut"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF0B42077C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 046C56B0005; Thu, 25 Apr 2019 19:31:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F39916B0006; Thu, 25 Apr 2019 19:31:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E02496B0007; Thu, 25 Apr 2019 19:31:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 987BB6B0005
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 19:31:05 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 33so713657pgv.17
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 16:31:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:subject:message-id
         :user-agent;
        bh=Z9/wXPjHmR/TAj+f1aBPjFI8y5kUMmIIgNEoIyLzbfk=;
        b=s4xvm1mUSsVhETW3/AXaZ48JNJSURn7dAxHmTXlfDEi6H3/SvtvAO3WhrKNbe9pXPe
         g0n8+RWP7uHfZiXjxnstxwvh8vTl8neadmmxMzdZ58gdaFFvQk1axKMQhFTUQo5UyyUN
         gMQ2j1qzPl19+PU2yNo54xXGGtPOVZWu3ES1KfjPA8A74TpO7ffBBrK00wyFJcdNunKu
         134414qEzzaIme7VTi88t6xIYqtvIfgIndFTdQjWFA9Wvxrcm4NQsYlJaqzRe/o9A7il
         LiaKJXPjrOPeALUJcnoIxJMqV1PuMGmiE03VVxls5uHgPHkTw9SzP5rahqfWTSLrxqPQ
         54oA==
X-Gm-Message-State: APjAAAVdLBUgotfWqxq6aDVLl3vUlO6W8dRGNBBnF5fwyLY4mvzo1n31
	117T7Bx3lMzZMuyX8U6n/FURhd+rZYYyTTP3GZaPCt9l6v0QiGC693eecIjHPmUyjqWEYE+2zbl
	TGFoPi/R6l/i5xb9Z7oTnl7OXPRxFLtM3Sx6Gn/CxiCMOg1CFPFTcVwB7Uai1bCuYEQ==
X-Received: by 2002:a65:4302:: with SMTP id j2mr39694110pgq.291.1556235065136;
        Thu, 25 Apr 2019 16:31:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyhEKvLYEd9TQnCsgan3BScDc8MOxZozPnerJyFaPeec0hxYWkh64Ef65oeJvzEmWwjEu5r
X-Received: by 2002:a65:4302:: with SMTP id j2mr39693930pgq.291.1556235063228;
        Thu, 25 Apr 2019 16:31:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556235063; cv=none;
        d=google.com; s=arc-20160816;
        b=LsV+MWKItTFZxxQ8PVKhj+KmBy1B3wtccqtznN+EJ+Q7TtFJFbsoIrNS2SOsoAxi1N
         k7OSNhDm5jXd6+puGA4dzGVOk2YVgm15m/vP2+GwOjE9/+781NnuC7Z8sHAITXOrCT9Y
         vic6F3YOxFGwJqXxXeEk//yyGvkzUtEeHESSWRF1aOPipeT4lZT/ZxpCd7OJ4UirzjAa
         +XaPFIAXRyus4SM0Lm2pos/UKg/RjckW3Fa7DfdiXVovP0CYlmAP1Xa0NE6c0hFDV7Uk
         P4P2bit4UoDlak7v/siJn66yFMuM7mI0WuqZ3SgKT+GWx2C2hZwe9XFjhxbKCUmVjMDY
         aUzg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:message-id:subject:to:from:date:dkim-signature;
        bh=Z9/wXPjHmR/TAj+f1aBPjFI8y5kUMmIIgNEoIyLzbfk=;
        b=eospKar+2085O8W1hXtwPLmLUne8Ja7ZndtVBaBUN5aK9Pa76S6BilSoOEmxYGM62h
         zhV0Oh3LQ6WNpZCZq+A1jNd5p3KH6aYVba5WoDlwfNtr0gNLuY7vfAyjMNPyid6NTI5Z
         t9fklJx8tVYDZS5kv9sVWe44By+5YxtW+cUukPQnR1z7+d0+Y7jx1Uuz1KY1AbnjCC+F
         t5O83sCXX+fW2HeNpXV3MGkcmtc/h3ce6FwwvVZ6f+3dlDhMcspoR85+8Sn6ZpUXD+p9
         y9omMYaHx9GHQKOjwPfSuRj6SesbeoMteDcB1IYxLi8zM/4gfwOqGP6U73PZ5hZSR97Y
         jWKw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=UtVMI8Ut;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w34si16553202pla.250.2019.04.25.16.31.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 16:31:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=UtVMI8Ut;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CDEC62067C;
	Thu, 25 Apr 2019 23:31:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556235062;
	bh=DQtmMb8bTPWL2zfJw0ixnUTOcJSx0o0yI3MzYtQQZkw=;
	h=Date:From:To:Subject:From;
	b=UtVMI8UtlAZlA5xPvHC4LXZ3uk7fmISZs5qLw9eawYLqepp5CVrWVIdZQC6WUBlrv
	 M8VtKtJxcKQgxHNPHueHZCI7d0VEUC/lU4z1NE7n6ztC2lVwkNDRUynZq5lAivcUo9
	 mrMDthO5XBL8q4E11l2Is6M4qtnmri6l7XRiGqjQ=
Date: Thu, 25 Apr 2019 16:31:01 -0700
From: akpm@linux-foundation.org
To: broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au,
 linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 mm-commits@vger.kernel.org
Subject:  mmotm 2019-04-25-16-30 uploaded
Message-ID: <20190425233101.nCgrB%akpm@linux-foundation.org>
User-Agent: s-nail v14.9.10
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The mm-of-the-moment snapshot 2019-04-25-16-30 has been uploaded to

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


This mmotm tree contains the following patches against 5.1-rc6:
(patches marked "*" will be included in linux-next)

  origin.patch
* mm-add-sys-kernel-slab-cache-cache_dma32.patch
* userfaultfd-use-rcu-to-free-the-task-struct-when-fork-fails.patch
* mm-memory_hotplug-drop-memory-device-reference-after-find_memory_block.patch
* zram-pass-down-the-bvec-we-need-to-read-into-in-the-work-struct.patch
* lib-kconfigdebug-fix-build-error-without-config_block.patch
* lib-test_vmalloc-do-not-create-cpumask_t-variable-on-stack.patch
* mm-do-not-boost-watermarks-to-avoid-fragmentation-for-the-discontig-memory-model.patch
* mm-page_alloc-always-use-a-captured-page-regardless-of-compaction-result.patch
* mm-page_alloc-avoid-potential-null-pointer-dereference.patch
* mm-page_alloc-fix-never-set-alloc_nofragment-flag.patch
* fs-proc-proc_sysctlc-fix-a-null-pointer-dereference.patch
* prctl-fix-false-positive-in-validate_prctl_map.patch
* scripts-spellingtxt-add-more-typos-to-spellingtxt-and-sort.patch
* arch-sh-boards-mach-dreamcast-irqc-remove-duplicate-header.patch
* debugobjects-move-printk-out-of-db-lock-critical-sections.patch
* ocfs2-use-common-file-type-conversion.patch
* ocfs2-fix-ocfs2-read-inode-data-panic-in-ocfs2_iget.patch
* ocfs2-add-last-unlock-times-in-locking_state.patch
* ocfs2-clear-zero-in-unaligned-direct-io.patch
* ocfs2-clear-zero-in-unaligned-direct-io-checkpatch-fixes.patch
* ocfs2-wait-for-recovering-done-after-direct-unlock-request.patch
* ocfs2-checkpoint-appending-truncate-log-transaction-before-flushing.patch
* ramfs-support-o_tmpfile.patch
  mm.patch
* list-add-function-list_rotate_to_front.patch
* slob-respect-list_head-abstraction-layer.patch
* slob-use-slab_list-instead-of-lru.patch
* slub-add-comments-to-endif-pre-processor-macros.patch
* slub-use-slab_list-instead-of-lru.patch
* slab-use-slab_list-instead-of-lru.patch
* mm-remove-stale-comment-from-page-struct.patch
* slub-remove-useless-kmem_cache_debug-before-remove_full.patch
* mm-slab-remove-unneed-check-in-cpuup_canceled.patch
* slub-update-the-comment-about-slab-frozen.patch
* slab-fix-an-infinite-loop-in-leaks_show.patch
* slab-fix-an-infinite-loop-in-leaks_show-fix.patch
* mm-vmscan-drop-zone-id-from-kswapd-tracepoints.patch
* mm-cma_debugc-fix-the-break-condition-in-cma_maxchunk_get.patch
* userfaultfd-sysctl-add-vmunprivileged_userfaultfd.patch
* userfaultfd-sysctl-add-vmunprivileged_userfaultfd-fix.patch
* page-cache-store-only-head-pages-in-i_pages.patch
* page-cache-store-only-head-pages-in-i_pages-fix.patch
* page-cache-store-only-head-pages-in-i_pages-fix-fix.patch
* mm-page_alloc-disallow-__gfp_comp-in-alloc_pages_exact.patch
* mm-move-recent_rotated-pages-calculation-to-shrink_inactive_list.patch
* mm-move-nr_deactivate-accounting-to-shrink_active_list.patch
* mm-move-nr_deactivate-accounting-to-shrink_active_list-fix.patch
* mm-remove-pages_to_free-argument-of-move_active_pages_to_lru.patch
* mm-generalize-putback-scan-functions.patch
* mm-gup-replace-get_user_pages_longterm-with-foll_longterm.patch
* mm-gup-replace-get_user_pages_longterm-with-foll_longterm-v3.patch
* mm-gup-change-write-parameter-to-flags-in-fast-walk.patch
* mm-gup-change-gup-fast-to-use-flags-rather-than-a-write-bool.patch
* mm-gup-add-foll_longterm-capability-to-gup-fast.patch
* mm-gup-add-foll_longterm-capability-to-gup-fast-v3.patch
* ib-hfi1-use-the-new-foll_longterm-flag-to-get_user_pages_fast.patch
* ib-hfi1-use-the-new-foll_longterm-flag-to-get_user_pages_fast-v3.patch
* ib-qib-use-the-new-foll_longterm-flag-to-get_user_pages_fast.patch
* ib-mthca-use-the-new-foll_longterm-flag-to-get_user_pages_fast.patch
* mmmemory_hotplug-unlock-1gb-hugetlb-on-x86_64.patch
* mmmemory_hotplug-drop-redundant-hugepage_migration_supported-check.patch
* mm-memory_hotplug-fix-the-wrong-usage-of-n_high_memory.patch
* mm-compaction-fix-an-undefined-behaviour.patch
* mm-compaction-fix-an-undefined-behaviour-fix.patch
* mm-cma-fix-the-bitmap-status-to-show-failed-allocation-reason.patch
* mm-compaction-show-gfp-flag-names-in-try_to_compact_pages-tracepoint.patch
* mm-compaction-some-tracepoints-should-be-defined-only-when-config_compaction-is-set.patch
* mm-change-mm_update_next_owner-to-update-mm-owner-with-write_once.patch
* mm-isolation-remove-redundant-pfn_valid_within-in-__first_valid_page.patch
* mm-vmscan-add-tracepoints-for-node-reclaim.patch
* mm-memcontrol-track-lru-counts-in-the-vmstats-array.patch
* mm-memcontrol-replace-zone-summing-with-lruvec_page_state.patch
* mm-memcontrol-replace-node-summing-with-memcg_page_state.patch
* mm-memcontrol-push-down-mem_cgroup_node_nr_lru_pages.patch
* mm-memcontrol-push-down-mem_cgroup_nr_lru_pages.patch
* mm-memcontrol-quarantine-the-mem_cgroup_nr_lru_pages-api.patch
* mm-cma-fix-crash-on-cma-allocation-if-bitmap-allocation-fails.patch
* initramfs-free-initrd-memory-if-opening-initrdimage-fails.patch
* initramfs-cleanup-initrd-freeing.patch
* initramfs-factor-out-a-helper-to-populate-the-initrd-image.patch
* initramfs-cleanup-populate_rootfs.patch
* initramfs-cleanup-populate_rootfs-fix.patch
* initramfs-move-the-legacy-keepinitrd-parameter-to-core-code.patch
* initramfs-proide-a-generic-free_initrd_mem-implementation.patch
* initramfs-poison-freed-initrd-memory.patch
* init-provide-a-generic-free_initmem-implementation.patch
* hexagon-switch-over-to-generic-free_initmem.patch
* init-free_initmem-poison-freed-init-memory.patch
* riscv-switch-over-to-generic-free_initmem.patch
* sh-advertise-gigantic-page-support.patch
* sparc-advertise-gigantic-page-support.patch
* mm-simplify-memory_isolation-compaction-cma-into-contig_alloc.patch
* hugetlb-allow-to-free-gigantic-pages-regardless-of-the-configuration.patch
* mm-introduce-put_user_page-placeholder-versions.patch
* mm-page_mkclean-vs-madv_dontneed-race.patch
* mm-vmscan-drop-may_writepage-and-classzone_idx-from-direct-reclaim-begin-template.patch
* mem-hotplug-fix-node-spanned-pages-when-we-have-a-node-with-only-zone_movable.patch
* hugetlbfs-fix-potential-over-underflow-setting-node-specific-nr_hugepages.patch
* mm-hugetlb-get-rid-of-nodemask_alloc.patch
* mm-__pagevec_lru_add_fn-typo-fix.patch
* mm-balloon-drop-unused-function-stubs.patch
* mm-sparse-clean-up-the-obsolete-code-comment.patch
* drivers-base-memoryc-clean-up-relicts-in-function-parameters.patch
* huegtlbfs-on-restore-reserve-error-path-retain-subpool-reservation.patch
* hugetlb-use-same-fault-hash-key-for-shared-and-private-mappings.patch
* mm-change-locked_vms-type-from-unsigned-long-to-atomic64_t.patch
* vfio-type1-drop-mmap_sem-now-that-locked_vm-is-atomic.patch
* vfio-spapr_tce-drop-mmap_sem-now-that-locked_vm-is-atomic.patch
* fpga-dlf-afu-drop-mmap_sem-now-that-locked_vm-is-atomic.patch
* powerpc-mmu-drop-mmap_sem-now-that-locked_vm-is-atomic.patch
* kvm-book3s-drop-mmap_sem-now-that-locked_vm-is-atomic.patch
* mm-hmm-select-mmu-notifier-when-selecting-hmm-v2.patch
* mm-hmm-use-reference-counting-for-hmm-struct-v3.patch
* mm-hmm-do-not-erase-snapshot-when-a-range-is-invalidated.patch
* mm-hmm-improve-and-rename-hmm_vma_get_pfns-to-hmm_range_snapshot-v2.patch
* mm-hmm-improve-and-rename-hmm_vma_fault-to-hmm_range_fault-v3.patch
* mm-hmm-improve-driver-api-to-work-and-wait-over-a-range-v3.patch
* mm-hmm-add-default-fault-flags-to-avoid-the-need-to-pre-fill-pfns-arrays-v2.patch
* mm-hmm-mirror-hugetlbfs-snapshoting-faulting-and-dma-mapping-v3.patch
* mm-hmm-mirror-hugetlbfs-snapshoting-faulting-and-dma-mapping-v3-fix.patch
* mm-hmm-allow-to-mirror-vma-of-a-file-on-a-dax-backed-filesystem-v3.patch
* mm-hmm-allow-to-mirror-vma-of-a-file-on-a-dax-backed-filesystem-v3-fix.patch
* mm-hmm-add-helpers-to-test-if-mm-is-still-alive-or-not.patch
* mm-hmm-add-an-helper-function-that-fault-pages-and-map-them-to-a-device-v3.patch
* mm-hmm-add-an-helper-function-that-fault-pages-and-map-them-to-a-device-v3-fix.patch
* mm-hmm-convert-various-hmm_pfn_-to-device_entry-which-is-a-better-name.patch
* mm-mmu_notifier-helper-to-test-if-a-range-invalidation-is-blockable.patch
* mm-mmu_notifier-convert-user-range-blockable-to-helper-function.patch
* mm-mmu_notifier-convert-mmu_notifier_range-blockable-to-a-flags.patch
* mm-mmu_notifier-contextual-information-for-event-enums.patch
* mm-mmu_notifier-contextual-information-for-event-triggering-invalidation-v2.patch
* mm-mmu_notifier-use-correct-mmu_notifier-events-for-each-invalidation.patch
* mm-mmu_notifier-pass-down-vma-and-reasons-why-mmu-notifier-is-happening-v2.patch
* mm-mmu_notifier-mmu_notifier_range_update_to_read_only-helper.patch
* mm-enable-error-injection-at-add_to_page_cache.patch
* mm-enable-error-injection-at-add_to_page_cache-fix.patch
* mm-rmap-use-the-pramapcount-to-do-the-check.patch
* mm-use-mm_zero_struct_page-from-sparc-on-all-64b-architectures.patch
* mm-drop-meminit_pfn_in_nid-as-it-is-redundant.patch
* mm-implement-new-zone-specific-memblock-iterator.patch
* mm-initialize-max_order_nr_pages-at-a-time-instead-of-doing-larger-sections.patch
* mm-memory_hotplug-cleanup-memory-offline-path.patch
* mm-memory_hotplug-provide-a-more-generic-restrictions-for-memory-hotplug.patch
* mm-memory_hotplug-provide-a-more-generic-restrictions-for-memory-hotplug-fix.patch
* mm-filemap-fix-minor-typo.patch
* mm-memory_hotplug-release-memory-resource-after-arch_remove_memory.patch
* mm-memory_hotplug-release-memory-resource-after-arch_remove_memory-fix.patch
* mm-memory_hotplug-make-unregister_memory_section-never-fail.patch
* mm-memory_hotplug-make-__remove_section-never-fail.patch
* mm-memory_hotplug-make-__remove_pages-and-arch_remove_memory-never-fail.patch
* mm-fix-false-positive-overcommit_guess-failures.patch
* mm-remove-redundant-default-n-from-kconfig-s.patch
* mm-introduce-new-vm_map_pages-and-vm_map_pages_zero-api.patch
* arm-mm-dma-mapping-convert-to-use-vm_map_pages.patch
* drivers-firewire-core-isoc-convert-to-use-vm_map_pages_zero.patch
* drm-rockchip-rockchip_drm_gemc-convert-to-use-vm_map_pages.patch
* drm-xen-xen_drm_front_gemc-convert-to-use-vm_map_pages.patch
* iommu-dma-iommuc-convert-to-use-vm_map_pages.patch
* videobuf2-videobuf2-dma-sgc-convert-to-use-vm_map_pages.patch
* xen-gntdevc-convert-to-use-vm_map_pages.patch
* xen-privcmd-bufc-convert-to-use-vm_map_pages_zero.patch
* x86-numa-always-initialize-all-possible-nodes.patch
* mm-be-more-verbose-about-zonelist-initialization.patch
* fs-syncc-sync_file_range2-may-use-wb_sync_all-writeback.patch
* mm-simplify-shrink_inactive_list.patch
* mm-hmm-add-arch_has_hmm_mirror-arch_has_hmm_device-kconfig.patch
* mm-refactor-__vunmap-to-avoid-duplicated-call-to-find_vm_area.patch
* mm-show-number-of-vmalloc-pages-in-proc-meminfo.patch
* mm-remove-might_sleep-in-__remove_vm_area.patch
* mm-page_alloc-remove-unnecessary-parameter-in-rmqueue_pcplist.patch
* z3fold-introduce-helper-functions.patch
* z3fold-improve-compression-by-extending-search.patch
* z3fold-add-structure-for-buddy-handles.patch
* z3fold-support-page-migration.patch
* z3fold-support-page-migration-fix.patch
* hugetlbfs-always-use-address-space-in-inode-for-resv_map-pointer.patch
* memblock-make-keeping-memblock-memory-opt-in-rather-than-opt-out.patch
* mm-vmscan-dont-disable-irq-again-when-count-pgrefill-for-memcg.patch
* mm-kconfig-update-memory-model-help-text.patch
* mm-vmscan-simplify-trace_reclaim_flags-and-trace_shrink_flags.patch
* memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work.patch
* memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work-v3.patch
* psi-introduce-state_mask-to-represent-stalled-psi-states.patch
* psi-make-psi_enable-static.patch
* psi-rename-psi-fields-in-preparation-for-psi-trigger-addition.patch
* psi-rename-psi-fields-in-preparation-for-psi-trigger-addition-v6.patch
* psi-split-update_stats-into-parts.patch
* psi-track-changed-states.patch
* refactor-header-includes-to-allow-kthreadh-inclusion-in-psi_typesh.patch
* psi-introduce-psi-monitor.patch
* mm-add-priority-threshold-to-__purge_vmap_area_lazy.patch
* mm-vmap-keep-track-of-free-blocks-for-vmap-allocation.patch
* mm-vmap-keep-track-of-free-blocks-for-vmap-allocation-v3.patch
* mm-vmap-keep-track-of-free-blocks-for-vmap-allocation-v4.patch
* mm-vmap-add-debug_augment_propagate_check-macro.patch
* mm-vmap-add-debug_augment_propagate_check-macro-v4.patch
* mm-vmap-add-debug_augment_lowest_match_check-macro.patch
* mm-vmap-add-debug_augment_lowest_match_check-macro-v4.patch
* mm-proportional-memorylowmin-reclaim.patch
* mm-make-memoryemin-the-baseline-for-utilisation-determination.patch
* mm-make-memoryemin-the-baseline-for-utilisation-determination-fix.patch
* mm-add-probe_user_read.patch
* mm-add-probe_user_read-fix.patch
* powerpc-use-probe_user_read.patch
* mm-vmalloc-convert-vmap_lazy_nr-to-atomic_long_t.patch
* mm-shuffle-initial-free-memory-to-improve-memory-side-cache-utilization.patch
* mm-shuffle-initial-free-memory-to-improve-memory-side-cache-utilization-fix.patch
* mm-shuffle-initial-free-memory-to-improve-memory-side-cache-utilization-fix-2.patch
* mm-move-buddy-list-manipulations-into-helpers.patch
* mm-move-buddy-list-manipulations-into-helpers-fix.patch
* mm-move-buddy-list-manipulations-into-helpers-fix2.patch
* mm-maintain-randomization-of-page-free-lists.patch
* mm-maintain-randomization-of-page-free-lists-checkpatch-fixes.patch
* mm-vmscan-remove-unused-lru_pages-argument.patch
* mm-mincore-make-mincore-more-conservative.patch
* mm-mincore-make-mincore-more-conservative-v2.patch
* mm-dont-expose-page-to-fast-gup-before-its-ready.patch
* info-task-hung-in-generic_file_write_iter.patch
* info-task-hung-in-generic_file_write-fix.patch
* fs-select-avoid-clang-stack-usage-warning.patch
* kdb-get-rid-of-broken-attempt-to-print-ccversion-in-kdb-summary.patch
* remove-spdx-with-linux-syscall-note-from-kernel-space-headers.patch
* arm-prevent-tracing-ipi_cpu_backtrace.patch
* arm64-mark-__cpus_have_const_cap-as-__always_inline.patch
* mips-mark-mult_sh_align_mod-as-__always_inline.patch
* s390-cpacf-mark-scpacf_query-as-__always_inline.patch
* mtd-rawnand-vf610_nfc-add-initializer-to-avoid-wmaybe-uninitialized.patch
* mips-mark-__fls-and-__ffs-as-__always_inline.patch
* arm-mark-setup_machine_tags-stub-as-__init-__noreturn.patch
* powerpc-prom_init-mark-prom_getprop-and-prom_getproplen-as-__init.patch
* powerpc-mm-radix-mark-__radix__flush_tlb_range_psize-as-__always_inline.patch
* powerpc-mm-radix-mark-as-__tlbie_pid-and-friends-as__always_inline.patch
* compiler-allow-all-arches-to-enable-config_optimize_inlining.patch
* notifiers-double-register-detection.patch
* kernel-latencytopc-remove-unnecessary-checks-for-latencytop_enabled.patch
* kernel-latencytopc-rename-clear_all_latency_tracing-to-clear_tsk_latency_tracing.patch
* byteorder-sanity-check-toolchain-vs-kernel-endianess.patch
* kernel-userc-clean-up-some-leftover-code.patch
* byteorder-sanity-check-toolchain-vs-kernel-endianess-checkpatch-fixes.patch
* linux-deviceh-use-unique-identifier-for-each-struct-_ddebug.patch
* linux-neth-use-unique-identifier-for-each-struct-_ddebug.patch
* linux-printkh-use-unique-identifier-for-each-struct-_ddebug.patch
* dynamic_debug-introduce-accessors-for-string-members-of-struct-_ddebug.patch
* dynamic_debug-drop-use-of-bitfields-in-struct-_ddebug.patch
* dynamic_debug-introduce-config_dynamic_debug_relative_pointers.patch
* dynamic_debug-add-asm-generic-implementation-for-dynamic_debug_relative_pointers.patch
* x86-64-select-dynamic_debug_relative_pointers.patch
* arm64-select-dynamic_debug_relative_pointers.patch
* powerpc-select-dynamic_debug_relative_pointers-for-ppc64.patch
* lib-bitmapc-remove-unused-export_symbols.patch
* lib-bitmapc-guard-exotic-bitmap-functions-by-config_numa.patch
* lib-genallocc-export-symbol-addr_in_gen_pool.patch
* lib-genallocc-rename-addr_in_gen_pool-to-gen_pool_has_addr.patch
* lib-genallocc-rename-addr_in_gen_pool-to-gen_pool_has_addr-fix.patch
* lib-plist-rename-debug_pi_list-to-debug_plist.patch
* lib-sort-make-swap-functions-more-generic.patch
* lib-sort-use-more-efficient-bottom-up-heapsort-variant.patch
* lib-sort-avoid-indirect-calls-to-built-in-swap.patch
* lib-list_sort-simplify-and-remove-max_list_length_bits.patch
* lib-list_sort-simplify-and-remove-max_list_length_bits-fix.patch
* lib-list_sort-optimize-number-of-calls-to-comparison-function.patch
* lib-move-mathematic-helpers-to-separate-folder.patch
* lib-move-mathematic-helpers-to-separate-folder-fix.patch
* lib-math-move-int_pow-from-pwm_blc-for-wider-use.patch
* lib-make-bitmap_parselist_user-a-wrapper-on-bitmap_parselist.patch
* lib-rework-bitmap_parselist.patch
* lib-rework-bitmap_parselist-v5.patch
* lib-test_bitmap-switch-test_bitmap_parselist-to-ktime_get.patch
* lib-test_bitmap-add-testcases-for-bitmap_parselist.patch
* lib-test_bitmap-add-testcases-for-bitmap_parselist-v5.patch
* lib-test_bitmap-add-tests-for-bitmap_parselist_user.patch
* lib-fix-possible-incorrect-result-from-rational-fractions-helper.patch
* bitopsh-sanitize-rotate-primitives.patch
* lib-test_vmallocc-test_func-eliminate-local-ret.patch
* checkpatch-dont-interpret-stack-dumps-as-commit-ids.patch
* checkpatch-fix-something.patch
* fs-binfmt_elfc-remove-unneeded-initialization-of-mm-start_stack.patch
* elf-make-scope-of-pos-variable-smaller.patch
* elf-free-pt_interp-filename-asap.patch
* elf-free-pt_interp-filename-asap-fix.patch
* elf-delete-trailing-return-in-functions-returning-void.patch
* elf-save-1-indent-level.patch
* elf-move-variables-initialization-closer-to-their-usage.patch
* elf-extract-prot_-calculations.patch
* elf-init-pt_regs-pointer-later.patch
* binfmt_elf-move-brk-out-of-mmap-when-doing-direct-loader-exec.patch
* init-introduce-debug_misc-option.patch
* powerpc-replace-config_debug_kernel-with-config_debug_misc.patch
* mips-replace-config_debug_kernel-with-config_debug_misc.patch
* xtensa-replace-config_debug_kernel-with-config_debug_misc.patch
* net-replace-config_debug_kernel-with-config_debug_misc.patch
* autofs-fix-some-word-usage-odities-in-autofstxt.patch
* autofs-update-autofstxt-for-strictexpire-mount-option.patch
* autofs-update-autofs_exp_leaves-description.patch
* autofs-update-mount-control-expire-desription-with-autofs_exp_forced.patch
* autofs-add-description-of-ignore-pseudo-mount-option.patch
* reiserfs-add-comment-to-explain-endianness-issue-in-xattr_hash.patch
* reiserfs-add-comment-to-explain-endianness-issue-in-xattr_hash-checkpatch-fixes.patch
* fat-issue-flush-after-the-writeback-of-fat.patch
* signal-annotate-implicit-fall-through.patch
* exec-move-recursion_depth-out-of-critical-sections.patch
* exec-move-struct-linux_binprm-buf.patch
* exec-test-recursion_depth.patch
* cpumask-fix-double-string-traverse-in-cpumask_parse.patch
* cpumask-fix-double-string-traverse-in-cpumask_parse-fix.patch
* rapidio-fix-a-null-pointer-derefenrece-when-create_workqueue-fails.patch
* kernel-sysctlc-switch-to-bitmap_zalloc.patch
* sysctl-return-einval-if-val-violates-minmax.patch
* test_sysctl-remove-superfluous-test_reqs.patch
* test_sysctl-load-module-before-testing-for-it.patch
* test_sysctl-ignore-diff-output-on-verify_diff_w.patch
* test_sysctl-allow-graceful-use-on-older-kernels.patch
* test_sysctl-add-proc_do_large_bitmap-test-case.patch
* test_sysctl-add-proc_do_large_bitmap-test-case-fix.patch
* sysctl-fix-proc_do_large_bitmap-for-large-input-buffers.patch
* convert-struct-pid-count-to-refcount_t.patch
* convert-struct-pid-count-to-refcount_t-fix.patch
* eventfd-prepare-id-to-userspace-via-fdinfo.patch
* gcov-clang-move-common-gcc-code-into-gcc_basec.patch
* gcov-docs-add-a-note-on-gcc-vs-clang-differences.patch
* gcov-clang-support.patch
* gcov-clang-support-checkpatch-fixes.patch
* panic-avoid-the-extra-noise-dmesg.patch
* panic-reboot-allow-specifying-reboot_mode-for-panic-only.patch
* panic-add-an-option-to-replay-all-the-printk-message-in-buffer.patch
* panic-add-an-option-to-replay-all-the-printk-message-in-buffer-v4.patch
* pps-descriptor-based-gpio.patch
* dt-bindings-pps-pps-gpio-pps-echo-implementation.patch
* pps-pps-gpio-pps-echo-implementation.patch
* scripts-gdb-find-vmlinux-where-it-was-before.patch
* scripts-gdb-add-kernel-config-dumping-command.patch
* scripts-gdb-add-kernel-config-dumping-command-v2.patch
* scripts-gdb-add-rb-tree-iterating-utilities.patch
* scripts-gdb-add-rb-tree-iterating-utilities-v2.patch
* scripts-gdb-add-a-timer-list-command.patch
* scripts-gdb-add-a-timer-list-command-v2.patch
* scripts-gdb-silence-pep8-checks.patch
* scripts-gdb-add-hlist-utilities.patch
* scripts-gdb-initial-clk-support-lx-clk-summary.patch
* scripts-gdb-add-lx_clk_core_lookup-function.patch
* ipc-prevent-lockup-on-alloc_msg-and-free_msg.patch
* ipc-mqueue-remove-redundant-wq-task-assignment.patch
* ipc-mqueue-optimize-msg_get.patch
* ipc-allow-boot-time-extension-of-ipcmni-from-32k-to-16m.patch
* ipc-conserve-sequence-numbers-in-ipcmni_extend-mode.patch
* ipc-do-cyclic-id-allocation-for-the-ipc-object.patch
* ipc-do-cyclic-id-allocation-for-the-ipc-object-fix.patch
  linux-next.patch
  linux-next-rejects.patch
  linux-next-git-rejects.patch
* pinctrl-fix-pxa2xxc-build-warnings.patch
* fs-coda-psdevc-remove-duplicate-header.patch
* include-replace-tsk-to-task-in-linux-sched-signalh.patch
* fs-cachefiles-nameic-remove-duplicate-header.patch
* fs-block_devc-remove-duplicate-header.patch
* treewide-replace-include-asm-sizesh-with-include-linux-sizesh.patch
* arch-remove-asm-sizesh-amd-asm-generic-sizesh.patch
* mm-rename-ambiguously-named-memorystat-counters-and-functions.patch
* mm-rename-ambiguously-named-memorystat-counters-and-functions-fix.patch
* mm-consider-subtrees-in-memoryevents.patch
* fsl_hypervisor-dereferencing-error-pointers-in-ioctl.patch
* fsl_hypervisor-prevent-integer-overflow-in-ioctl.patch
* mm-memcontrol-make-cgroup-stats-and-events-query-api-explicitly-local.patch
* mm-memcontrol-make-cgroup-stats-and-events-query-api-explicitly-local-fix.patch
* mm-memcontrol-move-stat-event-counting-functions-out-of-line.patch
* mm-memcontrol-fix-recursive-statistics-correctness-scalabilty.patch
* mm-memcontrol-fix-numa-round-robin-reclaim-at-intermediate-level.patch
* fix-read-buffer-overflow-in-delta-ipc.patch
  make-sure-nobodys-leaking-resources.patch
  releasing-resources-with-children.patch
  mutex-subsystem-synchro-test-module.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  slab-leaks3-default-y.patch
  workaround-for-a-pci-restoring-bug.patch

