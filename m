Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1512C46470
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:25:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 802BE273A6
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:25:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="kGNl4N0A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 802BE273A6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 234D96B02B4; Sat,  1 Jun 2019 09:25:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1BD186B02B6; Sat,  1 Jun 2019 09:25:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 037BB6B02B7; Sat,  1 Jun 2019 09:25:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id B9E0B6B02B4
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:25:22 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id e6so6587776pgl.1
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:25:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=LO5exeNyKi6qwaozwJRrquyCTh69r3gSf0SF7EPd1cs=;
        b=OeF3qmnw/w7ilvIM6XXbr4DhkYceaZ1/47OERXtdESpNwnJlx4nRnw/Hk02K0qzcn4
         S32LgmrN1RWXU/ehe98nRoO0lDzsPg4ySM+aMlZyUP3qGLOJq5vSy0Z2Hn66RBLj6K2G
         V1mkQVRE+YRNsZVRU96/zEngx5/fZY8LFc2s+shC86rSbcLzl0kPTj/kK8f05AJ/BTbR
         eBNl4hNBs8VtzUfvCfJc3Tp0aojK62kzoo8dtKJhjCQxKrzwwKMiC7KFkplhluSzB4kH
         qvqDEYmnHsa7o5YsdzD+gIbCJl1IxvjuOPCksg9rDd/h+HrqstDSYQoL/V4oGyypqYiR
         4sDQ==
X-Gm-Message-State: APjAAAXZhnhTFjwqDiAPnWUTi9yynuK3NdHTX0Juh8uqBU+eOy/CG9Gd
	5MJYq8Hf9W5rftsmPPCmOKGlyIn1IZU/y0x0aCszLJ790OhRoWOGZplaT9Yn3dWU1eExHjU0RFk
	A1dwZYJqBAV6IoV44yEmuWmXQYeuovaIdZIAh5e+gmKZK+AU/aVVIeaUEyWWQ5i7WtQ==
X-Received: by 2002:a17:90a:aa0d:: with SMTP id k13mr15454008pjq.53.1559395522413;
        Sat, 01 Jun 2019 06:25:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxSQPsJWPO35SGVAzyV4oGw+PUVTV1UMQb0WYQt5nbLalNKK3TG8LZUcO69NK71Me8avaJR
X-Received: by 2002:a17:90a:aa0d:: with SMTP id k13mr15453941pjq.53.1559395521744;
        Sat, 01 Jun 2019 06:25:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395521; cv=none;
        d=google.com; s=arc-20160816;
        b=lemgWmLdb5am2dWwD+KSVtI3DMA53GHOXu3W7oiRMo1Gk+09g139CHGklIytGgEf9T
         hnPIg3uid4qsknwoQb3pXvDdVZqHMtOPqh5A1IBkpWJn5K3ipAMnmVt+kSdUgLJ+dUMt
         JId0dECXpab+VxyK5rpucnatcNUHYVLmtQhui/0javC37VBFtedOP8BvmRw50aPgWrzB
         V5++suUNIF5ZDEtGmL+rGZWoOAicWqNdjjHddG00qRm8ZkrOSbcAnxezfWJy/v0tta1s
         Q+kpVR8pc2/Z3nvaVbmuHf+jSVV+DdhijHOj3vO6iZJHCM4U3cfIelo8eYQNlLCYPVXo
         Dojg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=LO5exeNyKi6qwaozwJRrquyCTh69r3gSf0SF7EPd1cs=;
        b=eiL3TSok2Oz2GXiVz61ADkwmUvWh7fsnEWDn47UONWJlw/9TYm87MkyfMLJ78lWMXt
         mkXbY4OqjuEQ8mUh4d5gYrVCqKhVxnQwginch629fe0m/kbcQplt1uJJQwG0ozAgxlc4
         g+a3gt8yS9t7WhNZl1PBG5yUxJy6O7t8/tD+nDlCs88N0xS694nLFc827TDgP44m5TnE
         2wZ8PbG3yQ1mNdZMUuWmvT6pgeLsH+tC6mEJw7fhhN4OfcvKWcKpNNDixRmIcSruVXtt
         cY/cUGQnrY7psnzvjUtfjs2EyekHXcyq5n6UsfHcQbez5Z+ej1BD9apDuXGtDSJAtcOE
         XtSA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=kGNl4N0A;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m11si10815261pjq.80.2019.06.01.06.25.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:25:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=kGNl4N0A;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 245BB273A8;
	Sat,  1 Jun 2019 13:25:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395521;
	bh=Ull3eFuDSJu1jVH2uCcdlqCKUnA3s1RlhSagthEqRys=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=kGNl4N0A20VPFdBf99aSEEeu8PvHjQkYIfmG3s0mORrjkWsH06c/foYiJMTAGObLH
	 hUTIxSB8F2Z57eVE1sRlLv3JTexOZkU4RzAxH9lLeC2GuGtK0htZBA5w+GMXK0DUY6
	 fMXMyImbn9REuKLnVuQG0kOz6cN0nG2Mk59c/tl0=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Linxu Fang <fanglinxu@huawei.com>,
	Taku Izumi <izumi.taku@jp.fujitsu.com>,
	Xishi Qiu <qiuxishi@huawei.com>,
	Michal Hocko <mhocko@suse.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Pavel Tatashin <pavel.tatashin@microsoft.com>,
	Oscar Salvador <osalvador@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.9 07/74] mem-hotplug: fix node spanned pages when we have a node with only ZONE_MOVABLE
Date: Sat,  1 Jun 2019 09:23:54 -0400
Message-Id: <20190601132501.27021-7-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601132501.27021-1-sashal@kernel.org>
References: <20190601132501.27021-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Linxu Fang <fanglinxu@huawei.com>

[ Upstream commit 299c83dce9ea3a79bb4b5511d2cb996b6b8e5111 ]

342332e6a925 ("mm/page_alloc.c: introduce kernelcore=mirror option") and
later patches rewrote the calculation of node spanned pages.

e506b99696a2 ("mem-hotplug: fix node spanned pages when we have a movable
node"), but the current code still has problems,

When we have a node with only zone_movable and the node id is not zero,
the size of node spanned pages is double added.

That's because we have an empty normal zone, and zone_start_pfn or
zone_end_pfn is not between arch_zone_lowest_possible_pfn and
arch_zone_highest_possible_pfn, so we need to use clamp to constrain the
range just like the commit <96e907d13602> (bootmem: Reimplement
__absent_pages_in_range() using for_each_mem_pfn_range()).

e.g.
Zone ranges:
  DMA      [mem 0x0000000000001000-0x0000000000ffffff]
  DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
  Normal   [mem 0x0000000100000000-0x000000023fffffff]
Movable zone start for each node
  Node 0: 0x0000000100000000
  Node 1: 0x0000000140000000
Early memory node ranges
  node   0: [mem 0x0000000000001000-0x000000000009efff]
  node   0: [mem 0x0000000000100000-0x00000000bffdffff]
  node   0: [mem 0x0000000100000000-0x000000013fffffff]
  node   1: [mem 0x0000000140000000-0x000000023fffffff]

node 0 DMA	spanned:0xfff   present:0xf9e   absent:0x61
node 0 DMA32	spanned:0xff000 present:0xbefe0	absent:0x40020
node 0 Normal	spanned:0	present:0	absent:0
node 0 Movable	spanned:0x40000 present:0x40000 absent:0
On node 0 totalpages(node_present_pages): 1048446
node_spanned_pages:1310719
node 1 DMA	spanned:0	    present:0		absent:0
node 1 DMA32	spanned:0	    present:0		absent:0
node 1 Normal	spanned:0x100000    present:0x100000	absent:0
node 1 Movable	spanned:0x100000    present:0x100000	absent:0
On node 1 totalpages(node_present_pages): 2097152
node_spanned_pages:2097152
Memory: 6967796K/12582392K available (16388K kernel code, 3686K rwdata,
4468K rodata, 2160K init, 10444K bss, 5614596K reserved, 0K
cma-reserved)

It shows that the current memory of node 1 is double added.
After this patch, the problem is fixed.

node 0 DMA	spanned:0xfff   present:0xf9e   absent:0x61
node 0 DMA32	spanned:0xff000 present:0xbefe0	absent:0x40020
node 0 Normal	spanned:0	present:0	absent:0
node 0 Movable	spanned:0x40000 present:0x40000 absent:0
On node 0 totalpages(node_present_pages): 1048446
node_spanned_pages:1310719
node 1 DMA	spanned:0	    present:0		absent:0
node 1 DMA32	spanned:0	    present:0		absent:0
node 1 Normal	spanned:0	    present:0		absent:0
node 1 Movable	spanned:0x100000    present:0x100000	absent:0
On node 1 totalpages(node_present_pages): 1048576
node_spanned_pages:1048576
memory: 6967796K/8388088K available (16388K kernel code, 3686K rwdata,
4468K rodata, 2160K init, 10444K bss, 1420292K reserved, 0K
cma-reserved)

Link: http://lkml.kernel.org/r/1554178276-10372-1-git-send-email-fanglinxu@huawei.com
Signed-off-by: Linxu Fang <fanglinxu@huawei.com>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Pavel Tatashin <pavel.tatashin@microsoft.com>
Cc: Oscar Salvador <osalvador@suse.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/page_alloc.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 05f141e39ac15..13a642192e121 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5491,13 +5491,15 @@ static unsigned long __meminit zone_spanned_pages_in_node(int nid,
 					unsigned long *zone_end_pfn,
 					unsigned long *ignored)
 {
+	unsigned long zone_low = arch_zone_lowest_possible_pfn[zone_type];
+	unsigned long zone_high = arch_zone_highest_possible_pfn[zone_type];
 	/* When hotadd a new node from cpu_up(), the node should be empty */
 	if (!node_start_pfn && !node_end_pfn)
 		return 0;
 
 	/* Get the start and end of the zone */
-	*zone_start_pfn = arch_zone_lowest_possible_pfn[zone_type];
-	*zone_end_pfn = arch_zone_highest_possible_pfn[zone_type];
+	*zone_start_pfn = clamp(node_start_pfn, zone_low, zone_high);
+	*zone_end_pfn = clamp(node_end_pfn, zone_low, zone_high);
 	adjust_zone_range_for_zone_movable(nid, zone_type,
 				node_start_pfn, node_end_pfn,
 				zone_start_pfn, zone_end_pfn);
-- 
2.20.1

