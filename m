Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C5EFC46460
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 02:10:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06583270A4
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 02:10:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="bh06dIN+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06583270A4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89B696B0005; Fri, 31 May 2019 22:10:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 84CD06B000E; Fri, 31 May 2019 22:10:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 761E56B0010; Fri, 31 May 2019 22:10:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3AB156B0005
	for <linux-mm@kvack.org>; Fri, 31 May 2019 22:10:17 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id n1so567755plk.11
        for <linux-mm@kvack.org>; Fri, 31 May 2019 19:10:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:subject:message-id
         :user-agent;
        bh=zyMWIagGb2K5otfcX20QVx7ArkB4OkTT+nrZCZS22UU=;
        b=RjFshANkngX8jxIPImwyVnS1T/8pvTdLJQT2n5TR8YwabW9UYAxxohXwQFEjp4xosa
         nKP9V+8+SuebfDQVe6bMBe44qTsnUCMx1TswHxB06V4bPnXf7uiIu73pQXGmdKzMm9GH
         HA4Ef/0CCMesT7/KJ0jcwhCyjXOfPexJ4c25TT+7ikWaJiPWrjDdyep0RhArENrYN/K3
         IjSQIWSg2o9RKzYI1cEcj+14l3OdzgTOW0QOiGo8iyjdpHcF3AAZWwdpB+jtJNNzcK1m
         qZxaqQPGvmh8e9bu3CjIZg9oyMaM1XDZYVibFAYZm8XXbg7Ba0bYhDk6QAItdoiVbXuJ
         0DYQ==
X-Gm-Message-State: APjAAAXfW6ZeOk87rozKsx+3kh9uq+N5UXwwKqsbByFKlseK3EFQQGGa
	OQV4palNvFaIAfyxslq/RlVtqJRwbtyZj/AGzNzG6A5Q/03VZDIKHe3Z9Q84SBzijFTNQBG++ok
	thkEBEcKl71LaNQjLbVUv5EYTIeZVELvBqcfVqdNdzEk4uJ/QAOqR21r2rNpiNlG36w==
X-Received: by 2002:a17:90a:cb0e:: with SMTP id z14mr12681967pjt.99.1559355016569;
        Fri, 31 May 2019 19:10:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx1e9iPSGPZS+EjX0GXYZhDYaliUpzheSy8pMabMyTTpmHTsRUPFgULJNjG7bYxKCg825gz
X-Received: by 2002:a17:90a:cb0e:: with SMTP id z14mr12681884pjt.99.1559355015018;
        Fri, 31 May 2019 19:10:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559355015; cv=none;
        d=google.com; s=arc-20160816;
        b=D4L9AsHNsqHBNKfp0W0AjOVguwHgvXnWpstEtboQhelb9SKFkoRkdDzf5JFBZEPtii
         9ELIgEdUp0kDSSwpuBEl3lCQSma4SVFkgSFVI03Hcxo86lVZor1gr4Fq7Oixn1mb/Yv6
         jxqEyHtOKGWUlhW7au6o0H9cwgyz7NowFkpnEjd3FFsuY06htjDrejSJhGdpj7mpUQn9
         nZIaqpDESMQqmRmEVFPXpB0wQhpji+RB2o5I0RrRblft0zpyqyXlPxQDjvUBEmCUkg7Q
         e+vFIXQJmn/9eaEt2UuJSynKhfktM9vRFlJvmdwheYEw1iCo4t91bIVO9I6wdT485bFd
         PzmA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:message-id:subject:to:from:date:dkim-signature;
        bh=zyMWIagGb2K5otfcX20QVx7ArkB4OkTT+nrZCZS22UU=;
        b=UCR8I1gqekU0qSztZH/NomQb0s8IFANkRv27tP0g9vSyFBwyjaqcAzytJXC14rvCgd
         YiTXhXh5A0eO5JviXvKfJZVe6sfY723N4rysQjzPlqqDaWVFttK1tGAXb4vApMlfwSlh
         lr1TKCRqArfk5Z0TbYwGd9L6PTCpdw1HWQd4RlJRVK30i0pkj887UwaSf6ikdZL+2IUP
         WN45uLTnslFSXX8hzyYAzsAsrztAt2hAKy8+Uym18lE25a0fbhOXn+6lTLeTigvNEZCn
         54JYMGZO6XtRcQt756QzSaOfam68iTWIJezA08CmGAvfRxwHyQ3lNRHyDuwy+0JFId1b
         gxUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=bh06dIN+;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id z3si9447038pfq.19.2019.05.31.19.10.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 May 2019 19:10:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=bh06dIN+;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 522A827094;
	Sat,  1 Jun 2019 02:10:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559355014;
	bh=puboCcPhKFQG7lLCfeiQMie7XRlna4krdQfgkOCxdM4=;
	h=Date:From:To:Subject:From;
	b=bh06dIN+Xl0BgY+A/p6EIZ8Wvim+fjAALtwjHotzKA65ENk6XPVOMYyLIKs0/Rc42
	 i5rV4MyJRZ5WVGonGEH0dM9cdgUhiicV/aO3h6hs8qfNfg19xqMFj2tPipser0yiy4
	 1pKTZyzzMQHhJdhLSK3yaBT4JzPua35fYyVCXiiM=
Date: Fri, 31 May 2019 19:10:13 -0700
From: akpm@linux-foundation.org
To: broonie@kernel.org, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-next@vger.kernel.org, mhocko@suse.cz, mm-commits@vger.kernel.org,
 sfr@canb.auug.org.au
Subject:  mmotm 2019-05-31-19-09 uploaded
Message-ID: <20190601021013.JZvIcmr28%akpm@linux-foundation.org>
User-Agent: s-nail v14.8.16
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The mm-of-the-moment snapshot 2019-05-31-19-09 has been uploaded to

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


This mmotm tree contains the following patches against 5.2-rc2:
(patches marked "*" will be included in linux-next)

  origin.patch
  drivers-crypto-ux500-cryp-makefile-fix.patch
* mm-fix-documentation-vm-hmmrst-sphinx-warnings.patch
* lib-sortc-fix-kernel-doc-notation-warnings.patch
* mm-vmallocc-fix-typo-in-comment.patch
* mm-slab-remove-obsoleted-config_debug_slab_leak.patch
* arch-arm-boot-compressed-decompressc-fix-build-error-due-to-lz4-changes.patch
* kernel-fork-make-max_threads-symbol-static.patch
* prctl_set_mm-refactor-checks-from-validate_prctl_map.patch
* prctl_set_mm-refactor-checks-from-validate_prctl_map-checkpatch-fixes.patch
* prctl_set_mm-downgrade-mmap_sem-to-read-lock.patch
* prctl_set_mm-downgrade-mmap_sem-to-read-lock-checkpatch-fixes.patch
* mm-consider-subtrees-in-memoryevents.patch
* memcg-make-it-work-on-sparse-non-0-node-systems.patch
* ocfs2-fix-error-path-kobject-memory-leak.patch
* mm-gup-continue-vm_fault_retry-processing-event-for-pre-faults.patch
* scripts-gdb-fix-invocation-when-config_common_clk-is-not-set.patch
* z3fold-fix-sheduling-while-atomic.patch
* kasan-initialize-tag-to-0xff-in-__kasan_kmalloc.patch
* spdxcheckpy-fix-directory-structures-v3.patch
* iommu-intel-fix-variable-iommu-set-but-not-used.patch
* signal-trace_signal_deliver-when-signal_group_exit.patch
* generic-radix-trees-fix-kerneldoc-comment.patch
* mm-compaction-make-sure-we-isolate-a-valid-pfn.patch
* convert-struct-pid-count-to-refcount_t.patch
* mm-dev_pfn-exclude-memory_device_private-while-computing-virtual-address.patch
* fs-proc-allow-reporting-eip-esp-for-all-coredumping-threads.patch
* mm-mempolicy-fix-an-incorrect-rebind-node-in-mpol_rebind_nodemask.patch
* binfmt_flat-make-load_flat_shared_library-work.patch
* mm-fix-trying-to-reclaim-unevicable-lru-page.patch
* mm-memcontrol-dont-batch-updates-of-local-vm-stats-and-events.patch
* list_lru-fix-memory-leak-in-__memcg_init_list_lru_node.patch
* scripts-decode_stacktracesh-prefix-addr2line-with-cross_compile.patch
* mm-mlockall-error-for-flag-mcl_onfault.patch
* mm-fix-recent_rotated-history.patch
* fs-ocfs2-fix-race-in-ocfs2_dentry_attach_lock.patch
* mm-mmu_gather-remove-__tlb_reset_range-for-force-flush.patch
* mm-mmu_gather-remove-__tlb_reset_range-for-force-flush-checkpatch-fixes.patch
* scripts-decode_stacktrace-match-basepath-using-shell-prefix-operator-not-regex.patch
* scripts-decode_stacktrace-look-for-modules-with-kodebug-extension.patch
* scripts-decode_stacktrace-look-for-modules-with-kodebug-extension-v2.patch
* scripts-spellingtxt-drop-sepc-from-the-misspelling-list.patch
* scripts-spellingtxt-drop-sepc-from-the-misspelling-list-fix.patch
* scripts-spellingtxt-add-spelling-fix-for-prohibited.patch
* scripts-decode_stacktrace-accept-dash-underscore-in-modules.patch
* sh-configs-remove-config_logfs-from-defconfig.patch
* debugobjects-move-printk-out-of-db-lock-critical-sections.patch
* ocfs2-add-last-unlock-times-in-locking_state.patch
* ocfs2-add-locking-filter-debugfs-file.patch
* fs-ocfs-fix-spelling-mistake-hearbeating-heartbeat.patch
* ocfs2-clear-zero-in-unaligned-direct-io.patch
* ocfs2-clear-zero-in-unaligned-direct-io-checkpatch-fixes.patch
* ocfs2-wait-for-recovering-done-after-direct-unlock-request.patch
* ocfs2-checkpoint-appending-truncate-log-transaction-before-flushing.patch
* ramfs-support-o_tmpfile.patch
  mm.patch
* mm-slab-validate-cache-membership-under-freelist-hardening.patch
* mm-slab-sanity-check-page-type-when-looking-up-cache.patch
* lkdtm-heap-add-tests-for-freelist-hardening.patch
* mm-slub-avoid-double-string-traverse-in-kmem_cache_flags.patch
* kmemleak-fix-check-for-softirq-context.patch
* mm-kasan-print-frame-description-for-stack-bugs.patch
* device-dax-fix-memory-and-resource-leak-if-hotplug-fails.patch
* mm-hotplug-make-remove_memory-interface-useable.patch
* device-dax-hotremove-persistent-memory-that-is-used-like-normal-ram.patch
* mm-move-map_sync-to-asm-generic-mman-commonh.patch
* include-linux-pfn_th-remove-pfn_t_to_virt.patch
* arm-remove-arch_select_memory_model.patch
* s390-remove-arch_select_memory_model.patch
* sparc-remove-arch_select_memory_model.patch
* mm-gupc-make-follow_page_mask-static.patch
* mm-migrate-remove-unused-mode-argument.patch
* mm-trivial-clean-up-in-insert_page.patch
* mm-make-config_huge_page-wrappers-into-static-inlines.patch
* swap-ifdef-struct-vm_area_struct-swap_readahead_info.patch
* mm-failslab-by-default-do-not-fail-allocations-with-direct-reclaim-only.patch
* mm-fix-an-overly-long-line-in-read_cache_page.patch
* mm-dont-cast-readpage-to-filler_t-for-do_read_cache_page.patch
* jffs2-pass-the-correct-prototype-to-read_cache_page.patch
* 9p-pass-the-correct-prototype-to-read_cache_page.patch
* mm-filemap-correct-the-comment-about-vm_fault_retry.patch
* mm-swap-fix-race-between-swapoff-and-some-swap-operations.patch
* mm-swap-simplify-total_swapcache_pages-with-get_swap_device.patch
* mm-swap-simplify-total_swapcache_pages-with-get_swap_device-fix.patch
* mm-swap-use-rbtree-for-swap_extent.patch
* mm-swap-use-rbtree-for-swap_extent-fix.patch
* memcg-oom-no-oom-kill-for-__gfp_retry_mayfail.patch
* memcg-fsnotify-no-oom-kill-for-remote-memcg-charging.patch
* mm-vmscan-expose-cgroup_ino-for-memcg-reclaim-tracepoints.patch
* mm-memcg-introduce-memoryeventslocal.patch
* mm-mmap-fix-the-adjusted-length-error.patch
* asm-generic-x86-introduce-generic-pte_allocfree_one.patch
* alpha-switch-to-generic-version-of-pte-allocation.patch
* arm-switch-to-generic-version-of-pte-allocation.patch
* arm64-switch-to-generic-version-of-pte-allocation.patch
* csky-switch-to-generic-version-of-pte-allocation.patch
* m68k-sun3-switch-to-generic-version-of-pte-allocation.patch
* mips-switch-to-generic-version-of-pte-allocation.patch
* nds32-switch-to-generic-version-of-pte-allocation.patch
* nios2-switch-to-generic-version-of-pte-allocation.patch
* parisc-switch-to-generic-version-of-pte-allocation.patch
* riscv-switch-to-generic-version-of-pte-allocation.patch
* um-switch-to-generic-version-of-pte-allocation.patch
* unicore32-switch-to-generic-version-of-pte-allocation.patch
* mm-memremap-rename-and-consolidate-section_size.patch
* mm-clean-up-is_device__page-definitions.patch
* mm-introduce-arch_has_pte_devmap.patch
* arm64-mm-implement-pte_devmap-support.patch
* arm64-mm-implement-pte_devmap-support-fix.patch
* mm-pgtable-drop-pgtable_t-variable-from-pte_fn_t-functions.patch
* mm-swap-fix-release_pages-when-releasing-devmap-pages.patch
* mm-swap-fix-release_pages-when-releasing-devmap-pages-v2.patch
* mm-mmu_notifier-use-hlist_add_head_rcu.patch
* mm-add-account_locked_vm-utility-function.patch
* mm-add-account_locked_vm-utility-function-v3.patch
* mm-memory_hotplug-simplify-and-fix-check_hotplug_memory_range.patch
* s390x-mm-fail-when-an-altmap-is-used-for-arch_add_memory.patch
* s390x-mm-implement-arch_remove_memory.patch
* arm64-mm-add-temporary-arch_remove_memory-implementation.patch
* drivers-base-memory-pass-a-block_id-to-init_memory_block.patch
* drivers-base-memory-pass-a-block_id-to-init_memory_block-fix.patch
* mm-memory_hotplug-allow-arch_remove_pages-without-config_memory_hotremove.patch
* mm-memory_hotplug-create-memory-block-devices-after-arch_add_memory.patch
* mm-memory_hotplug-drop-mhp_memblock_api.patch
* mm-memory_hotplug-remove-memory-block-devices-before-arch_remove_memory.patch
* mm-memory_hotplug-make-unregister_memory_block_under_nodes-never-fail.patch
* mm-memory_hotplug-remove-zone-parameter-from-sparse_remove_one_section.patch
* mm-vmap-remove-node-argument.patch
* mm-vmap-preload-a-cpu-with-one-object-for-split-purpose.patch
* mm-vmap-get-rid-of-one-single-unlink_va-when-merge.patch
* mm-vmap-switch-to-warn_on-and-move-it-under-unlink_va.patch
* mm-vmscan-remove-double-slab-pressure-by-incing-sc-nr_scanned.patch
* mm-vmscan-correct-some-vmscan-counters-for-thp-swapout.patch
* tools-vm-slabinfo-order-command-line-options.patch
* tools-vm-slabinfo-add-partial-slab-listing-to-x.patch
* tools-vm-slabinfo-add-option-to-sort-by-partial-slabs.patch
* tools-vm-slabinfo-add-sorting-info-to-help-menu.patch
* drivers-base-devres-introduce-devm_release_action.patch
* mm-devm_memremap_pages-introduce-devm_memunmap_pages.patch
* pci-p2pdma-fix-the-gen_pool_add_virt-failure-path.patch
* lib-genalloc-introduce-chunk-owners.patch
* pci-p2pdma-track-pgmap-references-per-resource-not-globally.patch
* mm-devm_memremap_pages-fix-final-page-put-race.patch
* mm-hmm-support-automatic-numa-balancing.patch
* mm-hmm-only-set-fault_flag_allow_retry-for-non-blocking.patch
* z3fold-add-inter-page-compaction.patch
* z3fold-add-inter-page-compaction-fix.patch
* z3fold-add-inter-page-compaction-fix-2.patch
* x86-numa-always-initialize-all-possible-nodes.patch
* mm-be-more-verbose-about-zonelist-initialization.patch
* mm-proportional-memorylowmin-reclaim.patch
* mm-make-memoryemin-the-baseline-for-utilisation-determination.patch
* mm-make-memoryemin-the-baseline-for-utilisation-determination-fix.patch
* mm-vmscan-remove-unused-lru_pages-argument.patch
* mm-dont-expose-page-to-fast-gup-before-its-ready.patch
* info-task-hung-in-generic_file_write_iter.patch
* info-task-hung-in-generic_file_write-fix.patch
* kernel-hung_taskc-monitor-killed-tasks.patch
* proc-sysctl-add-shared-variables-for-range-check.patch
* proc-sysctl-add-shared-variables-for-range-check-fix.patch
* proc-sysctl-add-shared-variables-for-range-check-fix-2.patch
* proc-hide-segfault-at-ffffffffff600000-dmesg-spam.patch
* vmcore-add-a-kernel-parameter-novmcoredd.patch
* vmcore-add-a-kernel-parameter-novmcoredd-fix.patch
* vmcore-add-a-kernel-parameter-novmcoredd-fix-fix.patch
* add-typeof_member-macro.patch
* proc-use-typeof_member-macro.patch
* kernel-fix-typos-and-some-coding-style-in-comments.patch
* byteorder-sanity-check-toolchain-vs-kernel-endianess.patch
* byteorder-sanity-check-toolchain-vs-kernel-endianess-checkpatch-fixes.patch
* linux-deviceh-use-unique-identifier-for-each-struct-_ddebug.patch
* linux-neth-use-unique-identifier-for-each-struct-_ddebug.patch
* linux-printkh-use-unique-identifier-for-each-struct-_ddebug.patch
* dynamic_debug-introduce-accessors-for-string-members-of-struct-_ddebug.patch
* dynamic_debug-drop-use-of-bitfields-in-struct-_ddebug.patch
* lib-genallocc-export-symbol-addr_in_gen_pool.patch
* lib-genallocc-rename-addr_in_gen_pool-to-gen_pool_has_addr.patch
* lib-genallocc-rename-addr_in_gen_pool-to-gen_pool_has_addr-fix.patch
* lib-fix-possible-incorrect-result-from-rational-fractions-helper.patch
* tweak-list_poison2-for-better-code-generation-on-x86_64.patch
* lib-string-allow-searching-for-nul-with-strnchr.patch
* lib-test_string-avoid-masking-memset16-32-64-failures.patch
* lib-test_string-add-some-testcases-for-strchr-and-strnchr.patch
* lib-test_overflow-avoid-tainting-the-kernel-and-fix-wrap-size.patch
* lib-introduce-test_meminit-module.patch
* checkpatchpl-warn-on-duplicate-sysctl-local-variable.patch
* checkpatch-dont-interpret-stack-dumps-as-commit-ids.patch
* checkpatch-fix-something.patch
* binfmt_flat-remove-set-but-not-used-variable-inode.patch
* elf-delete-stale-comment.patch
* mm-kconfig-fix-neighboring-typos.patch
* coda-pass-the-host-file-in-vma-vm_file-on-mmap.patch
* uapi-linux-codah-use-__kernel_pid_t-for-userspace.patch
* uapi-linux-coda_psdevh-move-upc_req-definition-from-uapi-to-kernel-side-headers.patch
* coda-add-error-handling-for-fget.patch
* coda-potential-buffer-overflow-in-coda_psdev_write.patch
* coda-fix-build-using-bare-metal-toolchain.patch
* coda-dont-try-to-print-names-that-were-considered-too-long.patch
* uapi-linux-coda_psdevh-move-coda_req_-from-uapi-to-kernel-side-headers.patch
* coda-clean-up-indentation-replace-spaces-with-tab.patch
* coda-stop-using-struct-timespec-in-user-api.patch
* coda-change-codas-user-api-to-use-64-bit-time_t-in-timespec.patch
* coda-get-rid-of-coda_alloc.patch
* coda-get-rid-of-coda_free.patch
* coda-bump-module-version.patch
* coda-move-internal-defs-out-of-include-linux.patch
* coda-remove-uapi-linux-coda_psdevh.patch
* coda-destroy-mutex-in-put_super.patch
* coda-use-size-for-stat.patch
* coda-add-__init-to-init_coda_psdev.patch
* coda-remove-sysctl-object-from-module-when-unused.patch
* coda-remove-sb-test-in-coda_fid_to_inode.patch
* coda-ftoc-validity-check-integration.patch
* hfsplus-replace-strncpy-with-memcpy.patch
* ufs-remove-set-but-not-used-variable-usb3.patch
* nds32-fix-asm-syscallh.patch
* hexagon-define-syscall_get_error-and-syscall_get_return_value.patch
* mips-define-syscall_get_error.patch
* parisc-define-syscall_get_error.patch
* powerpc-define-syscall_get_error.patch
* ptrace-add-ptrace_get_syscall_info-request.patch
* selftests-ptrace-add-a-test-case-for-ptrace_get_syscall_info.patch
* selftests-ptrace-add-a-test-case-for-ptrace_get_syscall_info-checkpatch-fixes.patch
* signal-reorder-struct-sighand_struct.patch
* coredump-split-pipe-command-whitespace-before-expanding-template.patch
* rapidio-mport_cdev-nul-terminate-some-strings.patch
* lz4-fix-spelling-and-copy-paste-errors-in-documentation.patch
  linux-next.patch
  linux-next-rejects.patch
  linux-next-git-rejects.patch
* pinctrl-fix-pxa2xxc-build-warnings.patch
* hmm-suppress-compilation-warnings-when-config_hugetlb_page-is-not-set.patch
* dma-contiguous-fix-config_dma_cma-version-of-dma_allocfree_contiguous.patch
* fix-read-buffer-overflow-in-delta-ipc.patch
  make-sure-nobodys-leaking-resources.patch
  releasing-resources-with-children.patch
  mutex-subsystem-synchro-test-module.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  workaround-for-a-pci-restoring-bug.patch

