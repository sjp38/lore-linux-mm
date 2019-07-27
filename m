Return-Path: <SRS0=PO26=VY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44A8EC76191
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 02:00:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE6A12184B
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 02:00:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="a0BC4ZdH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE6A12184B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 58A608E0003; Fri, 26 Jul 2019 22:00:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 53AE08E0002; Fri, 26 Jul 2019 22:00:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42A0B8E0003; Fri, 26 Jul 2019 22:00:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0C9438E0002
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 22:00:42 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id h5so34143107pgq.23
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 19:00:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:subject:message-id
         :user-agent;
        bh=VesMiJQrrOMhohpg1MKGgkLBbkVMnkBqIs4Jq+hgvDk=;
        b=clp3bV8eHjej7KemDckn4o/K7daooL7tU0BdY5ZTfKQSHUSlt/gB3jj1YI9XL2qsD5
         Ei80eMFUxWbPrkyB/vZl+9lGnF/m48KNcX0DTBfTjv3i9UR0zrRem2Gux9rP2gGT8ktO
         Br4SEpIlughZ3KoRv+bHMr4z27jgqb62NslBTPj7AJEoS4Q4asfB81YpCRhFu6co+iR3
         ZpzjVNGnmFK57KE7MGLx50wDvM6V0bMY1Zx5gyHa4OwdGmZEnw6x5AjpwpzOw4rkWlXD
         W+hpK/xDC4IW0b51G6syzqp82Z8eVsnR1Ah6GMbma1+GVNUTT4Q8+5c1A1ChBzrM2cPn
         OTkQ==
X-Gm-Message-State: APjAAAUER2sOgWsoGyRz4Bo0FzTu8sBp9AnMPt4Ty0/fZZFY7KehmnQq
	zJxi1xOGKmI8dge479T3mM1Hip4OXLIgqtPr0OlxDie6Ai1a0CD7IDwTznoLvlQOP2OFHFtsdSB
	rr9PkEtx92J2K5uWG8oPsslzyHq5S10g9EXIKn2353lvHy0EQ8Fc0+8EdvK4dplHUwg==
X-Received: by 2002:a17:90a:ab01:: with SMTP id m1mr14422959pjq.69.1564192841613;
        Fri, 26 Jul 2019 19:00:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4QG8Rta+uuwn72huHF+PuLrcK0/lz5g2JV8Ebo1H7z1Qz+mO36GenaVVnt5HUwESUiNyX
X-Received: by 2002:a17:90a:ab01:: with SMTP id m1mr14422877pjq.69.1564192840477;
        Fri, 26 Jul 2019 19:00:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564192840; cv=none;
        d=google.com; s=arc-20160816;
        b=RKFYLuiH2sh6/soTjWuuT24qfG1I4L936hWSjoCROgik3chcFgQpBiv9SXsdW/JPj+
         nZ6umbbDCvVyIRYk4lj6JMti+8QQqH1qPWkKa5zi/WCLaz/mc6QiOlz0cxQaBabfZCHF
         ws7vJqPlOsXZ4Ku0Vvdc5WlpVOTqOGRumFUfrdUvIenes7HMWJan3qkhjpL7rz0XGlWD
         RdqwVlygB7HyrQYeYVth7BcZqvrkuvAtHqHkDuGfGUCD6EIYgtiYr2deQJvOvYTeZTi9
         BEvZvT8g9cEL+yJGcAr9YJ8JBysrEpZQlvfIlXHDl38TvneOhrciJFl8HdK84OvJcL9f
         xFDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:message-id:subject:to:from:date:dkim-signature;
        bh=VesMiJQrrOMhohpg1MKGgkLBbkVMnkBqIs4Jq+hgvDk=;
        b=w5ejD1ne16udSedQGDVmAKrE1wWL6ELr1/7D+Gpux7/RaTl4t+1UC4PUpYwW+5TFz1
         /xnsnfrbVyJHgZ6mAqGxOUlaOeVeTHvRqVcXRteb9S6q+Qb3NaM3r6nrnnNh0JBsroWi
         ZRtb9f12x2+7zbqNXEYne6E7+Ha2NbSdBHmK/iUinVUeT69TQyLgpujOq83qqJAhaqHq
         70cQoRgavI2dgzJY4PS9iYQwd4yWcgI9/AIHQvrUKHvvpqexoVdlbwjWVSlfo0oeKj06
         2e9FNjuI2+KC1b8Z87QZsWtZiw8XT9E5Lko5AO4peD2GcYiPTKjveXkLPN8PYWrMJ7jy
         j/rg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=a0BC4ZdH;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t2si25015603pgq.488.2019.07.26.19.00.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 19:00:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=a0BC4ZdH;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C83D021721;
	Sat, 27 Jul 2019 02:00:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564192840;
	bh=eocXck03GHQIk/hNB7RnYiyfUeapaR8oyLrNQREir7I=;
	h=Date:From:To:Subject:From;
	b=a0BC4ZdH7ac6YTk70U5wJUTtdsr98BAUDHtOnkv4jMT09SYHfagiIvBDBA8/51Po4
	 X4he54pwqIAiOa+PRN8DBMUE7zJOVImbeDpEV8WKYu0VlcA8Fvkb03DYucV2llmfhR
	 3MLnl5cjzDZdqrRyGlrn9Ov8VuGd3aD3J4qSkbkY=
Date: Fri, 26 Jul 2019 19:00:39 -0700
From: akpm@linux-foundation.org
To: broonie@kernel.org, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-next@vger.kernel.org, mhocko@suse.cz, mm-commits@vger.kernel.org,
 sfr@canb.auug.org.au
Subject:  mmotm 2019-07-26-19-00 uploaded
Message-ID: <20190727020039.N6neVVHva%akpm@linux-foundation.org>
User-Agent: s-nail v14.8.16
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The mm-of-the-moment snapshot 2019-07-26-19-00 has been uploaded to

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


This mmotm tree contains the following patches against 5.3-rc1:
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
* kbuild-clean-compressed-initramfs-image.patch
* ocfs2-use-jbd2_inode-dirty-range-scoping.patch
* jbd2-remove-jbd2_journal_inode_add_.patch
* ocfs2-clear-zero-in-unaligned-direct-io.patch
* ocfs2-clear-zero-in-unaligned-direct-io-checkpatch-fixes.patch
* ocfs2-wait-for-recovering-done-after-direct-unlock-request.patch
* ocfs2-checkpoint-appending-truncate-log-transaction-before-flushing.patch
* ramfs-support-o_tmpfile.patch
  mm.patch
* mm-slab-extend-slab-shrink-to-shrink-all-memcg-caches.patch
* mm-slab-move-memcg_cache_params-structure-to-mm-slabh.patch
* memremap-move-from-kernel-to-mm.patch
* mm-page_poison-fix-a-typo-in-a-comment.patch
* mm-rmapc-remove-set-but-not-used-variable-cstart.patch
* mm-introduce-page_size.patch
* mm-introduce-page_shift.patch
* mm-introduce-page_shift-fix.patch
* mm-introduce-compound_nr.patch
* mm-replace-list_move_tail-with-add_page_to_lru_list_tail.patch
* mm-filemap-rewrite-mapping_needs_writeback-in-less-fancy-manner.patch
* mm-throttle-allocators-when-failing-reclaim-over-memoryhigh.patch
* mm-throttle-allocators-when-failing-reclaim-over-memoryhigh-fix.patch
* mm-throttle-allocators-when-failing-reclaim-over-memoryhigh-fix-fix.patch
* mm-vmscan-expose-cgroup_ino-for-memcg-reclaim-tracepoints.patch
* mm-gup-add-make_dirty-arg-to-put_user_pages_dirty_lock.patch
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
* mm-thp-introduce-foll_split_pmd.patch
* uprobe-use-foll_split_pmd-instead-of-foll_split.patch
* psi-annotate-refault-stalls-from-io-submission.patch
* psi-annotate-refault-stalls-from-io-submission-fix.patch
* psi-annotate-refault-stalls-from-io-submission-fix-2.patch
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
* augmented-rbtree-add-new-rb_declare_callbacks_max-macro-fix-2.patch
* augmented-rbtree-rework-the-rb_declare_callbacks-macro-definition.patch
* lib-genallocc-export-symbol-addr_in_gen_pool.patch
* lib-genallocc-rename-addr_in_gen_pool-to-gen_pool_has_addr.patch
* lib-genallocc-rename-addr_in_gen_pool-to-gen_pool_has_addr-fix.patch
* string-add-stracpy-and-stracpy_pad-mechanisms.patch
* kernel-doc-core-api-include-stringh-into-core-api.patch
* kernel-doc-core-api-include-stringh-into-core-api-v2.patch
* writeback-fix-wstringop-truncation-warnings.patch
* strscpy-reject-buffer-sizes-larger-than-int_max.patch
* lib-fix-possible-incorrect-result-from-rational-fractions-helper.patch
* checkpatch-dont-interpret-stack-dumps-as-commit-ids.patch
* checkpatch-improve-spdx-license-checking.patch
* checkpatchpl-warn-on-invalid-commit-id.patch
* checkpatch-add-_notifier_head-as-var-definition.patch
* fat-add-nobarrier-to-workaround-the-strange-behavior-of-device.patch
* cpumask-nicer-for_each_cpumask_and-signature.patch
* kexec-bail-out-upon-sigkill-when-allocating-memory.patch
* aio-simplify-read_events.patch
* kgdb-dont-use-a-notifier-to-enter-kgdb-at-panic-call-directly.patch
* ipc-consolidate-all-xxxctl_down-functions.patch
  linux-next.patch
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

