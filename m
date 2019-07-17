Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC35CC76196
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 23:06:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F06421849
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 23:06:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="L4Ortp1y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F06421849
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E68F96B0006; Wed, 17 Jul 2019 19:06:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E1B096B0007; Wed, 17 Jul 2019 19:06:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D086F8E0001; Wed, 17 Jul 2019 19:06:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9801F6B0006
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 19:06:13 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id u10so12810270plq.21
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 16:06:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:subject:message-id
         :user-agent;
        bh=JHJK6rxLif0+5CpB1pmkYI+Sy9t3HqRoLamrdjy/MNg=;
        b=G073c9GZCLMjEA7jV3IAtBKvL4/DZu6XdmB2My6n/IbZkt7kL/XSKNoh8frspapHkT
         hwUjr8Y2K1yh9mDH2d9efJ4UftJnxdjIDy1OxQ5rYmHKvTEy9U3sQQZzcwocGOae6PIR
         QShh/ViW/+njCixY/LuaB6peoKWmrxjk3g+34e0T/ipa/hcdwpA9u3PnWuV2hyYEkj1o
         Svw8ePW8XRkr9mCZpemXulg/PtFx545F8OkvWc+B8Gl4S8xqfZ8/Ysd8UGZSvfhuLvYX
         QeBQqIQdNe/4fIVXvpLl1Nxg+cHkTJt68Hh4vX3wr35Cuewoo0ZB1edSAY0qgJ84YmU4
         IxRA==
X-Gm-Message-State: APjAAAWKr4NSXMi3Sy75vhyv2Mu2uYbxTkGC9TQuLQbXQKM1OltPfD9Z
	aRBdQuuDreaHPgrI7dlP46i6RvF8/A9quJbF+8YzlQ6ZaJ7sKgxXM6k8GW3HWw0hkfHJCH9ffGG
	qiXQVp34STX3b4Tx31w8nhojjh2a+aZCdBfGYpu+Vnv+1bPY7tzkQJWWxECNDw4eEJw==
X-Received: by 2002:a17:902:b949:: with SMTP id h9mr42763024pls.120.1563404773074;
        Wed, 17 Jul 2019 16:06:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwpvhI+DsYNYmPXIKPxno+zqd9C7XaIOEDr+WfP6G59swfDjb7qghCCv5VMh5o6gCzueUYZ
X-Received: by 2002:a17:902:b949:: with SMTP id h9mr42762890pls.120.1563404771912;
        Wed, 17 Jul 2019 16:06:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563404771; cv=none;
        d=google.com; s=arc-20160816;
        b=XoYz5OkMyuiAv8fUN2DfBJ1XQZuVrlRw24Lp901wL7rvMt9G1axdMcTcnoiSJJG0AW
         ciy1WEjZHFrYMAlQYvlljJw4WE+UB8l5b8XRL2I8braglNIBcVDm0lAgE7IHc97OpEAC
         qdn7Kyl8usOrDVifj34xvHLpDNN40fKT5A7huq9mz6eYRpe5yT99Kr5fmvAnaofFKl2o
         IREc66HZpI8neyPMtZNMSgypXGAyDHdV5X43P1e3Sq0UxJ/IGFvcIsx8BIAYQpAcyfRW
         B64BP2r92fzvSi0N5nTCrJilTWLCxufHWq2aUmSXoIMHTlPk5aA3L2GU7V1D4gUCguFZ
         ZkpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:message-id:subject:to:from:date:dkim-signature;
        bh=JHJK6rxLif0+5CpB1pmkYI+Sy9t3HqRoLamrdjy/MNg=;
        b=pFXNd/eKKaWsCV8gZ6eUslAXK+Tvfmv1R5ab8wBx/+qHv/MoqADHVTuBW6TD+3z35J
         oEOz6mIl/EgEWIlGQBT524aTB7scXHt1A/2hM3JTNOtLPKwHPkI4vIfzqVssCr3VHTFy
         YC6ujiZ6Y82aVwV1NrN99xqr3E+18Mduui7laUCBs+rBQ+vY0OxyhZ4OO4BCw+krhXid
         5PeuXTEEle8aeQSqNxDfOCUedGry2DungmGI/6ssNKrTQROu0nwp4gbawfULymYH7wIp
         AFSlE77zRNPtuXG/0/f4V/yUmFhQkZm8zEdg+Q1elB8yO/9Y0tgtsDKPrhQxyydH8qbw
         cdLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=L4Ortp1y;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 64si356593ply.399.2019.07.17.16.06.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 16:06:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=L4Ortp1y;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-231-172-41.hsd1.ca.comcast.net [73.231.172.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 16EA021783;
	Wed, 17 Jul 2019 23:06:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563404771;
	bh=NUNe0BXmq1hgXW1PTVVIXnYofgWyfdyqpPJM1v29GvU=;
	h=Date:From:To:Subject:From;
	b=L4Ortp1ycCSi9EuCOel7rHp4XI6x5jalJlvS3yWg7evKvz+OVROtfpfBTWk9Msp8e
	 ApNskNz4LeTR4eFFbYrsKntqvp90ipB/IXf2xEIvlKxUD7VR8nI/BfCb8/TWrs0b/E
	 37TYdT0xw8da+B2f/6GOMsX19K1Eg0mQ+5gvPtK8=
Date: Wed, 17 Jul 2019 16:06:10 -0700
From: akpm@linux-foundation.org
To: broonie@kernel.org, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-next@vger.kernel.org, mhocko@suse.cz, mm-commits@vger.kernel.org,
 sfr@canb.auug.org.au
Subject:  mmotm 2019-07-17-16-05 uploaded
Message-ID: <20190717230610.zvRfipNL4%akpm@linux-foundation.org>
User-Agent: s-nail v14.8.16
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The mm-of-the-moment snapshot 2019-07-17-16-05 has been uploaded to

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


This mmotm tree contains the following patches against 5.2:
(patches marked "*" will be included in linux-next)

  origin.patch
* mm-hmm-fix-bad-subpage-pointer-in-try_to_unmap_one.patch
* docs-signal-fix-a-kernel-doc-markup.patch
* revert-kmemleak-allow-to-coexist-with-fault-injection.patch
* ocfs2-remove-set-but-not-used-variable-last_hash.patch
* ocfs2-clear-zero-in-unaligned-direct-io.patch
* ocfs2-clear-zero-in-unaligned-direct-io-checkpatch-fixes.patch
* ocfs2-wait-for-recovering-done-after-direct-unlock-request.patch
* ocfs2-checkpoint-appending-truncate-log-transaction-before-flushing.patch
* ramfs-support-o_tmpfile.patch
  mm.patch
* mm-vmscan-expose-cgroup_ino-for-memcg-reclaim-tracepoints.patch
* mm-mmap-fix-the-adjusted-length-error.patch
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
* mm-sparse-set-section-nid-for-hot-add-memory.patch
* mm-sparse-fix-memory-leak-of-sparsemap_buf-in-aliged-memory.patch
* mm-sparse-fix-memory-leak-of-sparsemap_buf-in-aliged-memory-fix.patch
* mm-sparse-fix-align-without-power-of-2-in-sparse_buffer_alloc.patch
* mm-mempolicy-make-the-behavior-consistent-when-mpol_mf_move-and-mpol_mf_strict-were-specified.patch
* mm-mempolicy-handle-vma-with-unmovable-pages-mapped-correctly-in-mbind.patch
* mm-oom_killer-add-task-uid-to-info-message-on-an-oom-kill.patch
* mm-oom_killer-add-task-uid-to-info-message-on-an-oom-kill-fix.patch
* mm-thp-make-transhuge_vma_suitable-available-for-anonymous-thp.patch
* mm-thp-make-transhuge_vma_suitable-available-for-anonymous-thp-fix.patch
* mm-thp-make-transhuge_vma_suitable-available-for-anonymous-thp-v4.patch
* mm-thp-fix-false-negative-of-shmem-vmas-thp-eligibility.patch
* mm-proportional-memorylowmin-reclaim.patch
* mm-make-memoryemin-the-baseline-for-utilisation-determination.patch
* mm-make-memoryemin-the-baseline-for-utilisation-determination-fix.patch
* mm-vmscan-remove-unused-lru_pages-argument.patch
* mm-dont-expose-page-to-fast-gup-before-its-ready.patch
* info-task-hung-in-generic_file_write_iter.patch
* info-task-hung-in-generic_file_write-fix.patch
* kernel-hung_taskc-monitor-killed-tasks.patch
* lib-genallocc-export-symbol-addr_in_gen_pool.patch
* lib-genallocc-rename-addr_in_gen_pool-to-gen_pool_has_addr.patch
* lib-genallocc-rename-addr_in_gen_pool-to-gen_pool_has_addr-fix.patch
* lib-fix-possible-incorrect-result-from-rational-fractions-helper.patch
* checkpatch-added-warnings-in-favor-of-strscpy.patch
* checkpatch-dont-interpret-stack-dumps-as-commit-ids.patch
* checkpatch-fix-something.patch
* fat-add-nobarrier-to-workaround-the-strange-behavior-of-device.patch
* coredump-split-pipe-command-whitespace-before-expanding-template.patch
* aio-simplify-read_events.patch
* resource-fix-locking-in-find_next_iomem_res.patch
* resource-fix-locking-in-find_next_iomem_res-fix.patch
* resource-avoid-unnecessary-lookups-in-find_next_iomem_res.patch
* ipc-consolidate-all-xxxctl_down-functions.patch
  linux-next.patch
  linux-next-git-rejects.patch
  diff-sucks.patch
* pinctrl-fix-pxa2xxc-build-warnings.patch
* mm-section-numbers-use-the-type-unsigned-long.patch
* mm-section-numbers-use-the-type-unsigned-long-fix.patch
* mm-section-numbers-use-the-type-unsigned-long-v3.patch
* drivers-base-memory-use-unsigned-long-for-block-ids.patch
* mm-make-register_mem_sect_under_node-static.patch
* mm-memory_hotplug-rename-walk_memory_range-and-pass-startsize-instead-of-pfns.patch
* mm-memory_hotplug-move-and-simplify-walk_memory_blocks.patch
* drivers-base-memoryc-get-rid-of-find_memory_block_hinted.patch
* drivers-base-memoryc-get-rid-of-find_memory_block_hinted-v3.patch
* drivers-base-memoryc-get-rid-of-find_memory_block_hinted-v3-fix.patch
* mm-sparsemem-introduce-struct-mem_section_usage.patch
* mm-sparsemem-introduce-a-section_is_early-flag.patch
* mm-sparsemem-add-helpers-track-active-portions-of-a-section-at-boot.patch
* mm-hotplug-prepare-shrink_zone-pgdat_span-for-sub-section-removal.patch
* mm-hotplug-prepare-shrink_zone-pgdat_span-for-sub-section-removal-fix.patch
* mm-sparsemem-convert-kmalloc_section_memmap-to-populate_section_memmap.patch
* mm-hotplug-kill-is_dev_zone-usage-in-__remove_pages.patch
* mm-kill-is_dev_zone-helper.patch
* mm-sparsemem-prepare-for-sub-section-ranges.patch
* mm-sparsemem-support-sub-section-hotplug.patch
* mm-sparsemem-support-sub-section-hotplug-fix.patch
* mm-sparsemem-support-sub-section-hotplug-fix-fix.patch
* mm-document-zone_device-memory-model-implications.patch
* mm-document-zone_device-memory-model-implications-fix.patch
* mm-devm_memremap_pages-enable-sub-section-remap.patch
* libnvdimm-pfn-fix-fsdax-mode-namespace-info-block-zero-fields.patch
* libnvdimm-pfn-stop-padding-pmem-namespaces-to-section-alignment.patch
* mm-sparsemem-cleanup-section-number-data-types.patch
* mm-sparsemem-cleanup-section-number-data-types-fix.patch
* mm-migrate-remove-unused-mode-argument.patch
* proc-sysctl-add-shared-variables-for-range-check.patch
* proc-sysctl-add-shared-variables-for-range-check-fix-2.patch
* proc-sysctl-add-shared-variables-for-range-check-fix-2-fix.patch
* proc-sysctl-add-shared-variables-for-range-check-fix-3.patch
* proc-sysctl-add-shared-variables-for-range-check-fix-4.patch
* drivers-tty-serial-sh-scic-suppress-warning.patch
* fix-read-buffer-overflow-in-delta-ipc.patch
  make-sure-nobodys-leaking-resources.patch
  releasing-resources-with-children.patch
  mutex-subsystem-synchro-test-module.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  workaround-for-a-pci-restoring-bug.patch

