Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D22D1C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 04:39:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 569B6208C3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 04:39:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="MJQHnn/x"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 569B6208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9DD58E0003; Wed, 31 Jul 2019 00:39:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C26508E0001; Wed, 31 Jul 2019 00:39:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AEEC78E0003; Wed, 31 Jul 2019 00:39:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 728AA8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 00:39:14 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id x19so42040501pgx.1
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 21:39:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:subject:message-id
         :user-agent;
        bh=71KlH417QdZclhIQ5hzvQWaiTLv6QUmvPekUEaPd8q4=;
        b=sAJOYuqplY5KFZdu7Wy8NXyMnnQNbSyjZ75/OafrB/73Jp02jkzbVoH4rL8fKYbOf8
         73zS1nGTq0WkQEaAaFQ5po3BMEJFwIGXXvXNtsEAYkjeW6eU2TWOwsSGcnSSkEIgQFvQ
         P5XlXEdHYyRDRSCxhG7ImovZTrnL9YjJQnMs88l18erKvETxMb/PS8ZNYlC+2+Yw77JQ
         djWs7CgfLDvNNjRhY750It6hmPUkDK10OSadTzqo+ndAmZtHrpUhSFfsGUatE3tbjuEB
         ZozRJoWFQYXMy1whYV62az3zQIzHj324m76AeufOimaoNdhoOncAekeULTA4lPzI/Biy
         Dcuw==
X-Gm-Message-State: APjAAAUuELvtyUNIZVgdIOcfd/OOVDRNfyGS+CyWbyYer93tDGNKh+xI
	7+PYGKN7N0WJNGGjFtOjW296F+0hFI1ixUTjNrHkbcYgFj0JXIzQbcazmuYhzr3d3k1EIU6M+7X
	CMTuCX6saGD8CZqSljkqbcU3PSGkRLxaG/phzTkvGiNZkuSh/V/lQEPB3z7oxYabPvg==
X-Received: by 2002:aa7:9ad2:: with SMTP id x18mr47240741pfp.192.1564547953895;
        Tue, 30 Jul 2019 21:39:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxWeAmf3YpJz9KbFfwIUh16/8O2aogrBSOqzzsutYXrD5c7NualClo7ahZHadX7OB6hkyf6
X-Received: by 2002:aa7:9ad2:: with SMTP id x18mr47240515pfp.192.1564547950449;
        Tue, 30 Jul 2019 21:39:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564547950; cv=none;
        d=google.com; s=arc-20160816;
        b=WfZp42kbRZp3g87cKmep8kUnd900lcOjufNvHqIXgn1CA4+9LV6ugjbtzg7fHSgtwa
         u7VZKM+4N4De2+pLOv7jcpVy68G1CCHPibV0RgYdzQYqsgwD4u98AU1bAEkHYO4U6Ib3
         mfOisBAz+Kwtkr59KPDD4JYtor5dJpGyet8xx28QZvHaBXj2saXbvqt/rnhFOhVKf5Hi
         keX1P7dOYg25B7Uu5WHlmQpzVswhDQvgypJiWO3r0x5wj2cD/j1dlrnr72wLaSNWAVVx
         UkifBbL/T+4EQnpKdKNxzZ5q263sVbD36sHUucxfMiemDS0q73Bmko4JX4cQnYZrEP7E
         I1Mg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:message-id:subject:to:from:date:dkim-signature;
        bh=71KlH417QdZclhIQ5hzvQWaiTLv6QUmvPekUEaPd8q4=;
        b=OBfhhnWEM3DslvZjPSYbxSGSQ0DnHFOsRXoRMr7bJBVj62yq+/M8nUtu6CoNZFgFnW
         nNwUU9hkOWC4JJW3+tPPBwIiBPUHVDW/ahCTQl2XMuTLpyKic7wlVCskS5Ro2juAxgQd
         ToxvW2AeVC6rVjHU8FT0UuGPkfbIFJ7rCWqcR6G6E23JtER8icoumzWwy4Lf2LS/LJCV
         4YNRLN8Z4OQJ6p8gwgjhpwupJD/Q1RfE0i0ad7WELx6c5Knt5XMTv3DRLGktCy987DCA
         85txD5cvNg0B9tkLgHnCWbeyUgJEYYwqOO258ilBDFscNLpmTrWhOJVa2fksPMR6MMRT
         T5MQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="MJQHnn/x";
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id o13si468821pjr.101.2019.07.30.21.39.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 21:39:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="MJQHnn/x";
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-71-198-47-131.hsd1.ca.comcast.net [71.198.47.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 83161206A2;
	Wed, 31 Jul 2019 04:39:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564547949;
	bh=rRfZVYKlkFRLweTLxOiwrdipjktMGguBScI326zEDBw=;
	h=Date:From:To:Subject:From;
	b=MJQHnn/xohl1DBVihVvcMPUDxyMUMeo54pIKnvfQVJA4x1vPAIN3bRN4xa45ctlo7
	 zj1LLpxqg3La58QRKINm1LSSsBZDFSZxEovjPq8pnyuhlhK8fLHMc0KNwMW26UdUDy
	 +fiqOx/tXIrpPSVv632m54PE+wqoRgiq06N03ijY=
Date: Tue, 30 Jul 2019 21:39:09 -0700
From: akpm@linux-foundation.org
To: broonie@kernel.org, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-next@vger.kernel.org, mhocko@suse.cz, mm-commits@vger.kernel.org,
 sfr@canb.auug.org.au
Subject:  mmotm 2019-07-30-21-37 uploaded
Message-ID: <20190731043909.UFALgW9LX%akpm@linux-foundation.org>
User-Agent: s-nail v14.8.16
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The mm-of-the-moment snapshot 2019-07-30-21-37 has been uploaded to

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


This mmotm tree contains the following patches against 5.3-rc2:
(patches marked "*" will be included in linux-next)

  origin.patch
* docs-signal-fix-a-kernel-doc-markup.patch
* revert-kmemleak-allow-to-coexist-with-fault-injection.patch
* ocfs2-remove-set-but-not-used-variable-last_hash.patch
* mm-vmscan-check-if-mem-cgroup-is-disabled-or-not-before-calling-memcg-slab-shrinker.patch
* mm-migrate-fix-reference-check-race-between-__find_get_block-and-migration.patch
* mm-compaction-avoid-100%-cpu-usage-during-compaction-when-a-task-is-killed.patch
* kasan-remove-clang-version-check-for-kasan_stack.patch
* ubsan-build-ubsanc-more-conservatively.patch
* page-flags-prioritize-kasan-bits-over-last-cpuid.patch
* page-flags-prioritize-kasan-bits-over-last-cpuid-fix.patch
* coredump-split-pipe-command-whitespace-before-expanding-template.patch
* mm-migrate-initialize-pud_entry-in-migrate_vma.patch
* mm-hotplug-remove-unneeded-return-for-void-function.patch
* cgroup-kselftest-relax-fs_spec-checks.patch
* asm-generic-fix-wtype-limits-compiler-warnings.patch
* asm-generic-fix-wtype-limits-compiler-warnings-fix.patch
* asm-generic-fix-wtype-limits-compiler-warnings-v2.patch
* test_meminit-use-gfp_atomic-in-rcu-critical-section.patch
* proc-kpageflags-prevent-an-integer-overflow-in-stable_page_flags.patch
* proc-kpageflags-do-not-use-uninitialized-struct-pages.patch
* mm-document-zone-device-struct-page-field-usage.patch
* mm-hmm-fix-zone_device-anon-page-mapping-reuse.patch
* mm-hmm-fix-bad-subpage-pointer-in-try_to_unmap_one.patch
* mm-hmm-fix-bad-subpage-pointer-in-try_to_unmap_one-v3.patch
* acpi-scan-acquire-device_hotplug_lock-in-acpi_scan_init.patch
* mm-mempolicy-make-the-behavior-consistent-when-mpol_mf_move-and-mpol_mf_strict-were-specified.patch
* mm-mempolicy-make-the-behavior-consistent-when-mpol_mf_move-and-mpol_mf_strict-were-specified-v4.patch
* mm-mempolicy-handle-vma-with-unmovable-pages-mapped-correctly-in-mbind.patch
* mm-mempolicy-handle-vma-with-unmovable-pages-mapped-correctly-in-mbind-v4.patch
* mm-z3foldc-fix-z3fold_destroy_pool-ordering.patch
* mm-z3foldc-fix-z3fold_destroy_pool-race-condition.patch
* mm-memcontrol-fix-use-after-free-in-mem_cgroup_iter.patch
* mm-vmallocc-fix-percpu-free-vm-area-search-criteria.patch
* kbuild-clean-compressed-initramfs-image.patch
* ocfs2-use-jbd2_inode-dirty-range-scoping.patch
* jbd2-remove-jbd2_journal_inode_add_.patch
* fs-ocfs2-fix-possible-null-pointer-dereferences-in-ocfs2_xa_prepare_entry.patch
* fs-ocfs2-fix-a-possible-null-pointer-dereference-in-ocfs2_write_end_nolock.patch
* fs-ocfs2-fix-a-possible-null-pointer-dereference-in-ocfs2_info_scan_inode_alloc.patch
* ocfs2-clear-zero-in-unaligned-direct-io.patch
* ocfs2-clear-zero-in-unaligned-direct-io-checkpatch-fixes.patch
* ocfs2-wait-for-recovering-done-after-direct-unlock-request.patch
* ocfs2-checkpoint-appending-truncate-log-transaction-before-flushing.patch
* ramfs-support-o_tmpfile.patch
  mm.patch
* mm-slab-extend-slab-shrink-to-shrink-all-memcg-caches.patch
* mm-slab-move-memcg_cache_params-structure-to-mm-slabh.patch
* kmemleak-increase-debug_kmemleak_early_log_size-default-to-16k.patch
* mm-kmemleak-use-mempool-allocations-for-kmemleak-objects.patch
* memremap-move-from-kernel-to-mm.patch
* mm-page_poison-fix-a-typo-in-a-comment.patch
* mm-rmapc-remove-set-but-not-used-variable-cstart.patch
* mm-introduce-page_size.patch
* mm-introduce-page_shift.patch
* mm-introduce-page_shift-fix.patch
* mm-introduce-compound_nr.patch
* mm-replace-list_move_tail-with-add_page_to_lru_list_tail.patch
* mm-filemap-dont-initiate-writeback-if-mapping-has-no-dirty-pages.patch
* mm-filemap-rewrite-mapping_needs_writeback-in-less-fancy-manner.patch
* mm-throttle-allocators-when-failing-reclaim-over-memoryhigh.patch
* mm-throttle-allocators-when-failing-reclaim-over-memoryhigh-fix.patch
* mm-throttle-allocators-when-failing-reclaim-over-memoryhigh-fix-fix.patch
* mm-throttle-allocators-when-failing-reclaim-over-memoryhigh-fix-fix-fix.patch
* mm-throttle-allocators-when-failing-reclaim-over-memoryhigh-fix-fix-fix-fix.patch
* mm-vmscan-expose-cgroup_ino-for-memcg-reclaim-tracepoints.patch
* mm-gup-add-make_dirty-arg-to-put_user_pages_dirty_lock.patch
* mm-gup-add-make_dirty-arg-to-put_user_pages_dirty_lock-fix.patch
* drivers-gpu-drm-via-convert-put_page-to-put_user_page.patch
* net-xdp-convert-put_page-to-put_user_page.patch
* mm-remove-redundant-assignment-of-entry.patch
* mm-mmap-fix-the-adjusted-length-error.patch
* mm-memory_hotplug-remove-move_pfn_range.patch
* mm-memory_hotplug-remove-move_pfn_range-fix.patch
* drivers-base-nodec-simplify-unregister_memory_block_under_nodes.patch
* mm-sparse-fix-memory-leak-of-sparsemap_buf-in-aliged-memory.patch
* mm-sparse-fix-memory-leak-of-sparsemap_buf-in-aliged-memory-fix.patch
* mm-sparse-fix-align-without-power-of-2-in-sparse_buffer_alloc.patch
* mm-vmalloc-do-not-keep-unpurged-areas-in-the-busy-tree.patch
* mm-vmalloc-modify-struct-vmap_area-to-reduce-its-size.patch
* mm-compaction-clear-total_migratefree_scanned-before-scanning-a-new-zone.patch
* mm-compaction-clear-total_migratefree_scanned-before-scanning-a-new-zone-fix.patch
* mm-compaction-clear-total_migratefree_scanned-before-scanning-a-new-zone-fix-fix.patch
* mm-compaction-clear-total_migratefree_scanned-before-scanning-a-new-zone-fix-2.patch
* mm-compaction-clear-total_migratefree_scanned-before-scanning-a-new-zone-fix-2-fix.patch
* mm-oom-avoid-printk-iteration-under-rcu.patch
* mm-oom-avoid-printk-iteration-under-rcu-fix.patch
* mm-oom_killer-add-task-uid-to-info-message-on-an-oom-kill.patch
* mm-oom_killer-add-task-uid-to-info-message-on-an-oom-kill-fix.patch
* mm-move-memcmp_pages-and-pages_identical.patch
* uprobe-use-original-page-when-all-uprobes-are-removed.patch
* uprobe-use-original-page-when-all-uprobes-are-removed-v2.patch
* mm-thp-introduce-foll_split_pmd.patch
* mm-thp-introduce-foll_split_pmd-v11.patch
* uprobe-use-foll_split_pmd-instead-of-foll_split.patch
* psi-annotate-refault-stalls-from-io-submission.patch
* psi-annotate-refault-stalls-from-io-submission-fix.patch
* psi-annotate-refault-stalls-from-io-submission-fix-2.patch
* mm-fs-move-randomize_stack_top-from-fs-to-mm.patch
* arm64-make-use-of-is_compat_task-instead-of-hardcoding-this-test.patch
* arm64-consider-stack-randomization-for-mmap-base-only-when-necessary.patch
* arm64-mm-move-generic-mmap-layout-functions-to-mm.patch
* arm64-mm-make-randomization-selected-by-generic-topdown-mmap-layout.patch
* arm-properly-account-for-stack-randomization-and-stack-guard-gap.patch
* arm-use-stack_top-when-computing-mmap-base-address.patch
* arm-use-generic-mmap-top-down-layout-and-brk-randomization.patch
* mips-properly-account-for-stack-randomization-and-stack-guard-gap.patch
* mips-use-stack_top-when-computing-mmap-base-address.patch
* mips-adjust-brk-randomization-offset-to-fit-generic-version.patch
* mips-replace-arch-specific-way-to-determine-32bit-task-with-generic-version.patch
* mips-use-generic-mmap-top-down-layout-and-brk-randomization.patch
* riscv-make-mmap-allocation-top-down-by-default.patch
* mm-introduce-madv_cold.patch
* mm-change-pageref_reclaim_clean-with-page_refreclaim.patch
* mm-account-nr_isolated_xxx-in-_lru_page.patch
* mm-introduce-madv_pageout.patch
* mm-factor-out-common-parts-between-madv_cold-and-madv_pageout.patch
* zpool-add-malloc_support_movable-to-zpool_driver.patch
* zswap-use-movable-memory-if-zpool-support-allocate-movable-memory.patch
* mm-proportional-memorylowmin-reclaim.patch
* mm-make-memoryemin-the-baseline-for-utilisation-determination.patch
* mm-make-memoryemin-the-baseline-for-utilisation-determination-fix.patch
* mm-vmscan-remove-unused-lru_pages-argument.patch
* mm-dont-expose-page-to-fast-gup-before-its-ready.patch
* info-task-hung-in-generic_file_write_iter.patch
* info-task-hung-in-generic_file_write-fix.patch
* kernel-hung_taskc-monitor-killed-tasks.patch
* hung_task-allow-printing-warnings-every-check-interval.patch
* rbtree-sync-up-the-tools-copy-of-the-code-with-the-main-one.patch
* augmented-rbtree-add-comments-for-rb_declare_callbacks-macro.patch
* augmented-rbtree-add-new-rb_declare_callbacks_max-macro.patch
* augmented-rbtree-add-new-rb_declare_callbacks_max-macro-fix.patch
* augmented-rbtree-add-new-rb_declare_callbacks_max-macro-fix-3.patch
* augmented-rbtree-rework-the-rb_declare_callbacks-macro-definition.patch
* lib-genallocc-export-symbol-addr_in_gen_pool.patch
* lib-genallocc-rename-addr_in_gen_pool-to-gen_pool_has_addr.patch
* lib-genallocc-rename-addr_in_gen_pool-to-gen_pool_has_addr-fix.patch
* string-add-stracpy-and-stracpy_pad-mechanisms.patch
* documentation-checkpatch-prefer-stracpy-strscpy-over-strcpy-strlcpy-strncpy.patch
* kernel-doc-core-api-include-stringh-into-core-api.patch
* kernel-doc-core-api-include-stringh-into-core-api-v2.patch
* writeback-fix-wstringop-truncation-warnings.patch
* strscpy-reject-buffer-sizes-larger-than-int_max.patch
* lib-fix-possible-incorrect-result-from-rational-fractions-helper.patch
* checkpatch-dont-interpret-stack-dumps-as-commit-ids.patch
* checkpatch-improve-spdx-license-checking.patch
* checkpatchpl-warn-on-invalid-commit-id.patch
* checkpatch-add-_notifier_head-as-var-definition.patch
* fs-reiserfs-remove-unnecessary-check-of-bh-in-remove_from_transaction.patch
* fat-add-nobarrier-to-workaround-the-strange-behavior-of-device.patch
* cpumask-nicer-for_each_cpumask_and-signature.patch
* kexec-bail-out-upon-sigkill-when-allocating-memory.patch
* kexec-restore-arch_kexec_kernel_image_probe-declaration.patch
* aio-simplify-read_events.patch
* kgdb-dont-use-a-notifier-to-enter-kgdb-at-panic-call-directly.patch
* ipc-consolidate-all-xxxctl_down-functions.patch
  linux-next.patch
  linux-next-rejects.patch
  linux-next-git-rejects.patch
  diff-sucks.patch
* pinctrl-fix-pxa2xxc-build-warnings.patch
* mm-treewide-clarify-pgtable_page_ctordtor-naming.patch
* drivers-tty-serial-sh-scic-suppress-warning.patch
* fix-read-buffer-overflow-in-delta-ipc.patch
  make-sure-nobodys-leaking-resources.patch
  releasing-resources-with-children.patch
  mutex-subsystem-synchro-test-module.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  workaround-for-a-pci-restoring-bug.patch

