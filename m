Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A031C76195
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 23:08:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C04D821850
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 23:08:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="RXudblfJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C04D821850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2DD556B0003; Thu, 18 Jul 2019 19:08:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 267F66B0006; Thu, 18 Jul 2019 19:08:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E07C8E0001; Thu, 18 Jul 2019 19:08:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id C559F6B0003
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 19:08:53 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 6so17502842pfz.10
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 16:08:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:subject:message-id
         :user-agent;
        bh=+UFNJC23v4PT+jvqY6xenCF1K6tlS0MhZq+8f4HjExw=;
        b=uhhzQX0sgPiq8g2Wip0VX0miOMh09MghxT6jvcTsUsK0OYwNp6YLS6yHCSeFc/+KvV
         gJx81YDWQq8bgLIfbL2HKRxBx6Zf72EOCelv1599EIP4vcD3yDsPsCIuLqNpGsR+KZey
         1MU5LK68Iy2k29EROkAb2AA14TiJKZ5yLLnDY3Z/nF4epCMI4nzXQzd2lDN7mBH1GmHk
         GqUkqjVpL2qxHiYDW5Dg6sS+Z/alm5HoT2AdGyjmE+Ba24LyUeW2t0NMwQvl2u6Uu+tW
         olK/+4uISy8WH6PQ6Bd6zkjEajQzRxaUGp3+v2DggWmglE+MJN/Sl7aZ3v/Z1Hjghg3d
         U84g==
X-Gm-Message-State: APjAAAXeXAPkc1MFEKnjhC083pTWfv/0oNsYo3pKwDujRk+wBYPcpVmu
	HtnKAPua7a3uCl3XowVK4eTzXKsF3J67cJw6sgRG7IW3AGP2Wgs+/BjquHs5Zj/r3ucWW3Lrbqx
	87L3Uq20aEpvjDwTpKOQlBQPVCfrL5w0eVgy/476NV1m81ZpGFgn2sxwj3j4cvXmVwQ==
X-Received: by 2002:a63:e907:: with SMTP id i7mr49710568pgh.84.1563491333319;
        Thu, 18 Jul 2019 16:08:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqykKnV4qBrsZxbZbGUcGIJOVHkauV0TYk7FFxP4vUw9okrmRnF7Ro6BgpJHxjSygDWOpa+J
X-Received: by 2002:a63:e907:: with SMTP id i7mr49710466pgh.84.1563491331959;
        Thu, 18 Jul 2019 16:08:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563491331; cv=none;
        d=google.com; s=arc-20160816;
        b=GXR5yedcVMfMBT97dx9cOYqavfsgmoeLl6O9C8MB3OS/r3pjYvYiSEJ8hg0o6+/j9J
         qED57ScpAAxpfPdwKt7lNWfbhAZZF2DxlJYCDrhYYI68J4YXSCHoakQx6lMvAS6UY22H
         if2vUTLOc4G8SbAUK1WZgNKTgLWTsrI0B2yR1dn6xSwEui/BH74y3TkqomCxB4p2KUK3
         FP27h/96EJ312H2hxhUviWpn6mdXAx3ER/mGNlUdLLbVkmR0+sBlPj2KQ9si0h8P4Yc+
         pRpsDP7+GPg9Yj3+IdlZZjBMjJwNhqPrri2h3glT0+NIyfnjiJdo1zhKnSNeOiQMqN2X
         i4Rg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:message-id:subject:to:from:date:dkim-signature;
        bh=+UFNJC23v4PT+jvqY6xenCF1K6tlS0MhZq+8f4HjExw=;
        b=AXL5Y06Ga8WnQ+IESaBYVdIeKFx2Pgc7nN8xGutDAzJX5Fy9SlFQsOwRnR2PW/OFlu
         p1rVt6DNxUEBNjifoPgu7tnauZCqTWsPlFQHTqSrW1WZ1Jplfi4E9QXTfJmbGTxO34v0
         OjR1WyZBNwHVyNG3mUxuEI5coGg1PGr10zY5tjpXrV46DMzk6q8r2SeMHHWsYU1i68Jg
         EA/9kPE+wJyLdLKX2b72ZHhl6x7Qf+bowydQ0JDTJDy1n46TO39uqGvYbfynoWJnWV3F
         0COzv/eXAOn0OywCM/rBCSIdBzvNBgdRIvg65kPAO3V/p/AKSQ7rjzt3KjQHXkzXAfGt
         xJpg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=RXudblfJ;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w18si585893pll.132.2019.07.18.16.08.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 16:08:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=RXudblfJ;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.64])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4804121019;
	Thu, 18 Jul 2019 23:08:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563491331;
	bh=l41XHqfhQXRWpJRimWubsDCtliFI/buN2e5R5tXe1pQ=;
	h=Date:From:To:Subject:From;
	b=RXudblfJ6N6q3NSsicM6rKkZmK/AxczRHVASO9nc9JOTZICedbGeaArhLNuJ6hE97
	 tcS/A26xycdAt+OsHMsVmh2kGRPPKeucVuQiZAYKfW3OUOVfwEoOilkUIRfDRVsSOg
	 U2pBXyRhr03JP7GfQ+yM6saIlevejBvtIyHKVw/s=
Date: Thu, 18 Jul 2019 16:08:50 -0700
From: akpm@linux-foundation.org
To: broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au,
 linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 mm-commits@vger.kernel.org
Subject:  mmotm 2019-07-18-16-08 uploaded
Message-ID: <20190718230850.aurae%akpm@linux-foundation.org>
User-Agent: s-nail v14.9.10
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The mm-of-the-moment snapshot 2019-07-18-16-08 has been uploaded to

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
* mm-memory_hotplug-simplify-and-fix-check_hotplug_memory_range.patch
* s390x-mm-fail-when-an-altmap-is-used-for-arch_add_memory.patch
* s390x-mm-implement-arch_remove_memory.patch
* arm64-mm-add-temporary-arch_remove_memory-implementation.patch
* drivers-base-memory-pass-a-block_id-to-init_memory_block.patch
* mm-memory_hotplug-allow-arch_remove_pages-without-config_memory_hotremove.patch
* mm-memory_hotplug-create-memory-block-devices-after-arch_add_memory.patch
* mm-memory_hotplug-drop-mhp_memblock_api.patch
* mm-memory_hotplug-remove-memory-block-devices-before-arch_remove_memory.patch
* mm-memory_hotplug-make-unregister_memory_block_under_nodes-never-fail.patch
* mm-memory_hotplug-remove-zone-parameter-from-sparse_remove_one_section.patch
* mm-sparse-set-section-nid-for-hot-add-memory.patch
* mm-thp-make-transhuge_vma_suitable-available-for-anonymous-thp.patch
* mm-thp-fix-false-negative-of-shmem-vmas-thp-eligibility.patch
* resource-fix-locking-in-find_next_iomem_res.patch
* resource-avoid-unnecessary-lookups-in-find_next_iomem_res.patch
* mm-section-numbers-use-the-type-unsigned-long.patch
* drivers-base-memory-use-unsigned-long-for-block-ids.patch
* mm-make-register_mem_sect_under_node-static.patch
* mm-memory_hotplug-rename-walk_memory_range-and-pass-startsize-instead-of-pfns.patch
* mm-memory_hotplug-move-and-simplify-walk_memory_blocks.patch
* drivers-base-memoryc-get-rid-of-find_memory_block_hinted.patch
* mm-sparsemem-introduce-struct-mem_section_usage.patch
* mm-sparsemem-introduce-a-section_is_early-flag.patch
* mm-sparsemem-add-helpers-track-active-portions-of-a-section-at-boot.patch
* mm-hotplug-prepare-shrink_zone-pgdat_span-for-sub-section-removal.patch
* mm-sparsemem-convert-kmalloc_section_memmap-to-populate_section_memmap.patch
* mm-hotplug-kill-is_dev_zone-usage-in-__remove_pages.patch
* mm-kill-is_dev_zone-helper.patch
* mm-sparsemem-prepare-for-sub-section-ranges.patch
* mm-sparsemem-support-sub-section-hotplug.patch
* mm-document-zone_device-memory-model-implications.patch
* mm-devm_memremap_pages-enable-sub-section-remap.patch
* libnvdimm-pfn-fix-fsdax-mode-namespace-info-block-zero-fields.patch
* libnvdimm-pfn-stop-padding-pmem-namespaces-to-section-alignment.patch
* mm-sparsemem-cleanup-section-number-data-types.patch
* mm-migrate-remove-unused-mode-argument.patch
* proc-sysctl-add-shared-variables-for-range-check.patch
* riscv-fix-build-break-after-macro-to-function-conversion-in-generic-cacheflushh.patch
* mm-hmm-fix-bad-subpage-pointer-in-try_to_unmap_one.patch
* docs-signal-fix-a-kernel-doc-markup.patch
* revert-kmemleak-allow-to-coexist-with-fault-injection.patch
* ocfs2-remove-set-but-not-used-variable-last_hash.patch
* mm-vmscan-check-if-mem-cgroup-is-disabled-or-not-before-calling-memcg-slab-shrinker.patch
* mm-migrate-fix-reference-check-race-between-__find_get_block-and-migration.patch
* mm-balloon_compaction-avoid-duplicate-page-removal.patch
* balloon-fix-up-comments.patch
* mm-compaction-avoid-100%-cpu-usage-during-compaction-when-a-task-is-killed.patch
* ocfs2-clear-zero-in-unaligned-direct-io.patch
* ocfs2-clear-zero-in-unaligned-direct-io-checkpatch-fixes.patch
* ocfs2-wait-for-recovering-done-after-direct-unlock-request.patch
* ocfs2-checkpoint-appending-truncate-log-transaction-before-flushing.patch
* ramfs-support-o_tmpfile.patch
  mm.patch
* mm-vmscan-expose-cgroup_ino-for-memcg-reclaim-tracepoints.patch
* mm-mmap-fix-the-adjusted-length-error.patch
* mm-sparse-fix-memory-leak-of-sparsemap_buf-in-aliged-memory.patch
* mm-sparse-fix-memory-leak-of-sparsemap_buf-in-aliged-memory-fix.patch
* mm-sparse-fix-align-without-power-of-2-in-sparse_buffer_alloc.patch
* mm-mempolicy-make-the-behavior-consistent-when-mpol_mf_move-and-mpol_mf_strict-were-specified.patch
* mm-mempolicy-handle-vma-with-unmovable-pages-mapped-correctly-in-mbind.patch
* mm-oom_killer-add-task-uid-to-info-message-on-an-oom-kill.patch
* mm-oom_killer-add-task-uid-to-info-message-on-an-oom-kill-fix.patch
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
* ipc-consolidate-all-xxxctl_down-functions.patch
  linux-next.patch
  linux-next-rejects.patch
  diff-sucks.patch
* pinctrl-fix-pxa2xxc-build-warnings.patch
* drivers-tty-serial-sh-scic-suppress-warning.patch
* fix-read-buffer-overflow-in-delta-ipc.patch
  make-sure-nobodys-leaking-resources.patch
  releasing-resources-with-children.patch
  mutex-subsystem-synchro-test-module.patch
  kernel-forkc-export-kernel_thread-to-modules.patch
  workaround-for-a-pci-restoring-bug.patch

