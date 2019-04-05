Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6F2FC282DC
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 22:12:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 58A902186A
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 22:12:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="b3nTx7+C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 58A902186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC69E6B0007; Fri,  5 Apr 2019 18:12:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D50BC6B0008; Fri,  5 Apr 2019 18:12:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC9F26B000C; Fri,  5 Apr 2019 18:12:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 82B306B0007
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 18:12:10 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id j18so5333208pfi.20
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 15:12:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:user-agent:mime-version:content-transfer-encoding;
        bh=RFlyHVCvfroOhB2uXylkan752Y+bFRMjZlocuMb6szU=;
        b=BX5RN13Rs4QWoqAapV3gcMIQ1Lr6irUBxhR4AKvoS2fIedYkcOdpEa+7vmp9h/nCac
         Nyzobd9JJRAH3PsZJRT0G1Wergxn0kcPm7Vn2wds2ElZzfyFSPyyEnswh0ffh7ufugk+
         m7fi/p3TMUAuM7Bb6aKUfUR1kqBPKhQ0yU/3wA4nDOltdTNM+eYJvFu3RhM/hKa9kXk0
         uoPPFa9n2I298aJ/LFxIn85unBItKEQ6MoT+wBIkoqGOV5hp2SQpwmhi0MXb14kTXBtv
         QCfPHhYiOy0AFZPQbIvbp1/RnRj9e6VMevbIC8WB9VvF40I7f93YC9bL6cKkSNrJ0Y2C
         chmg==
X-Gm-Message-State: APjAAAWDY1tfLnwiyNQatuTyyBxjgb2Z/F8GdhtILQfcHfJpugXR5nTi
	njcF4PWfuyyeBazL8e+hHxrPQ5tYr8FgcC5xK3KxGtavqBaIUI38vYIMhUUofgkgfxaXSB1gHyV
	xt8Wu6okxQ3PRMmcWU+TIwCruovvdJ4yiWhieZkUVJsrK3L9owHPqpJDQ3ghtm7xWZw==
X-Received: by 2002:a17:902:6a89:: with SMTP id n9mr15840515plk.76.1554502329874;
        Fri, 05 Apr 2019 15:12:09 -0700 (PDT)
X-Received: by 2002:a17:902:6a89:: with SMTP id n9mr15840424plk.76.1554502328779;
        Fri, 05 Apr 2019 15:12:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554502328; cv=none;
        d=google.com; s=arc-20160816;
        b=To3njzS0M2unFlhOZmxv/eYd2FJm4yrSs+C4ZCoXjPWyW3Wf741E4dXIe8jg6vgSJo
         ZRH8JRBmvD1LAj1H3T0ehlNrBoNy7vLt0pa1w9TiBkMffXR+98ex3bPmPpHodGQKPn7b
         EZGGODZoGbqovSoptHg+SD2OLIOSKmwYa8vMNvtTBcuqU83TTsQScUdtxW/BXUkUtTo8
         kYrdFXptp6BdT3Tc4yovuSGWzIo6Ml3IcZcfmzko7+GkI+zESIt8FD0g2Vi3chG8j7K4
         3ZPHxDf8YpYyY1XdQGi9bw9tGFvMETz5tphKxovYaLE5uggjpZAtJbKLLNxq4Sbhjl5K
         DGhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject:dkim-signature;
        bh=RFlyHVCvfroOhB2uXylkan752Y+bFRMjZlocuMb6szU=;
        b=TFRnOC8q/fzUfomgis71nlqHhyDyZ5hCw22qdROquSJvYmq1TibB8/eQZPvojy+D3N
         hKMxZ1QojuOmz9mbV9cG6CuBHdubZi8qWEZu4Uh09h5nFj5PYKNkzsh90Qa8OBdX1nTt
         PgiEWkBxPzI9clIAlISbKgLCaJmYYtw4IYlFKMrvpQfOthixVA6l7Q97IptRlfZamxVB
         kP97C1kGO99iLIz5O+vZEieHnT/NN5SDTbHjH+bTKGHuOoNjx41yZc1ZIn44VJKAg5Yh
         YZLBYJg4BQ5ZFQmzS1j0tC5BJUcysQ80L9xfZF9WOmiij9psd06+1UE9TYS9ZAa2l34t
         3Gfw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=b3nTx7+C;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h68sor23860543pfj.73.2019.04.05.15.12.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Apr 2019 15:12:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=b3nTx7+C;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=RFlyHVCvfroOhB2uXylkan752Y+bFRMjZlocuMb6szU=;
        b=b3nTx7+CUxVUlQscReM8Uk0JVZUKeHtdrGfJ+wUfk33PvUsvBzQAIzRc0Ik1qHli+/
         zTx/G00PbwkkS0GfK1dhoOcSSY3F5ZNAqhIl5zI6blFbjIrCcDlPlYKyHamM5/T0GfJX
         RHUbjorVVLWuSmbEbsexEY6xUYeP0iGnIeMgZ8QDwGvBBm8SDRV2POijtZccOQP/ae7d
         pfq9ekZoa6baUfaKVE9wTeoBy1a/zegQwxayKkYT1XwadVo/t3hEXPUAaFlz/j3lM36W
         DD85qcu4vx4fHBvmm6bDEDvE7zIn1c3CpVX3eS2RVq5DdVpJj/zOzz8O3cKBug+QAMC4
         JXQA==
X-Google-Smtp-Source: APXvYqzcZRP6M2t/f+TFS8bfJasWfrNHx5XYhr8s6AbPgY9grB0g7CJ3SNDhP2NHNMThRf34AJUEoQ==
X-Received: by 2002:aa7:82d6:: with SMTP id f22mr15222497pfn.190.1554502328079;
        Fri, 05 Apr 2019 15:12:08 -0700 (PDT)
Received: from localhost.localdomain (50-126-100-225.drr01.csby.or.frontiernet.net. [50.126.100.225])
        by smtp.gmail.com with ESMTPSA id q81sm42013500pfi.102.2019.04.05.15.12.06
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Apr 2019 15:12:07 -0700 (PDT)
Subject: [mm PATCH v7 0/4] Deferred page init improvements
From: Alexander Duyck <alexander.duyck@gmail.com>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: pavel.tatashin@microsoft.com, mhocko@suse.com, dave.jiang@intel.com,
 linux-nvdimm@lists.01.org, alexander.h.duyck@linux.intel.com,
 linux-kernel@vger.kernel.org, willy@infradead.org, mingo@kernel.org,
 yi.z.zhang@linux.intel.com, khalid.aziz@oracle.com, rppt@linux.vnet.ibm.com,
 vbabka@suse.cz, sparclinux@vger.kernel.org, dan.j.williams@intel.com,
 ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, davem@davemloft.net,
 kirill.shutemov@linux.intel.com
Date: Fri, 05 Apr 2019 15:12:06 -0700
Message-ID: <20190405221043.12227.19679.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patchset is essentially a refactor of the page initialization logic
that is meant to provide for better code reuse while providing a
significant improvement in deferred page initialization performance.

In my testing on an x86_64 system with 384GB of RAM I have seen the
following. In the case of regular memory initialization the deferred init
time was decreased from 3.75s to 1.38s on average. This amounts to a 172%
improvement for the deferred memory initialization performance.

I have called out the improvement observed with each patch.

v1->v2:
    Fixed build issue on PowerPC due to page struct size being 56
    Added new patch that removed __SetPageReserved call for hotplug
v2->v3:
    Rebased on latest linux-next
    Removed patch that had removed __SetPageReserved call from init
    Added patch that folded __SetPageReserved into set_page_links
    Tweaked __init_pageblock to use start_pfn to get section_nr instead of pfn
v3->v4:
    Updated patch description and comments for mm_zero_struct_page patch
        Replaced "default" with "case 64"
        Removed #ifndef mm_zero_struct_page
    Fixed typo in comment that ommited "_from" in kerneldoc for iterator
    Added Reviewed-by for patches reviewed by Pavel
    Added Acked-by from Michal Hocko
    Added deferred init times for patches that affect init performance
    Swapped patches 5 & 6, pulled some code/comments from 4 into 5
v4->v5:
    Updated Acks/Reviewed-by
    Rebased on latest linux-next
    Split core bits of zone iterator patch from MAX_ORDER_NR_PAGES init
v5->v6:
    Rebased on linux-next with previous v5 reverted
    Drop the "This patch" or "This change" from patch descriptions.
    Cleaned up patch descriptions for patches 3 & 4
    Fixed kerneldoc for __next_mem_pfn_range_in_zone
    Updated several Reviewed-by, and incorporated suggestions from Pavel
    Added __init_single_page_nolru to patch 5 to consolidate code
    Refactored iterator in patch 7 and fixed several issues
v6->v7:
    Updated MAX_ORDER_NR_PAGES patch to stop on section aligned boundaries
    Dropped patches 5-7
        Will follow-up later with reserved bit rework before resubmitting

---

Alexander Duyck (4):
      mm: Use mm_zero_struct_page from SPARC on all 64b architectures
      mm: Drop meminit_pfn_in_nid as it is redundant
      mm: Implement new zone specific memblock iterator
      mm: Initialize MAX_ORDER_NR_PAGES at a time instead of doing larger sections


 arch/sparc/include/asm/pgtable_64.h |   30 -----
 include/linux/memblock.h            |   41 +++++++
 include/linux/mm.h                  |   41 ++++++-
 mm/memblock.c                       |   64 ++++++++++
 mm/page_alloc.c                     |  218 ++++++++++++++++++++++-------------
 5 files changed, 277 insertions(+), 117 deletions(-)

--

