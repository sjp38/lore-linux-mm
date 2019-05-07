Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	T_DKIMWL_WL_HIGH,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07F2AC04AAB
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 05:34:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AFC5F21530
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 05:34:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="AZclECns"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AFC5F21530
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D6D96B0007; Tue,  7 May 2019 01:34:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 45F9A6B0008; Tue,  7 May 2019 01:34:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 375A66B000A; Tue,  7 May 2019 01:34:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id F32846B0007
	for <linux-mm@kvack.org>; Tue,  7 May 2019 01:34:24 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id w9so8610788plz.11
        for <linux-mm@kvack.org>; Mon, 06 May 2019 22:34:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6XV16zZuyWqtHNxdiJIXvbUs5Q0EJfu3zmK+tvcKxos=;
        b=GJtuC+V/basK8jdTfIerrITZK4hrRNyO5tM8IVnVoWRHIkJiH6pNxzo3STniQgGJsR
         qCvvkzkmOOsqM4CnmT1xnFDw5retlA2EwoIDoUHppKvk6A7fthVAIVddN882Bjt99YHP
         WLMRZ1fFeUi5n0yuGWEK4zrZsLsKQXedruoy7yy4NTfrn5xZRmdCKx1RVSY6tpus2Oyu
         EMgJPp/chbHItjmJYv+JGlyvrxG8/JSj9l1kRgjBdtyq5hTbbWfEhL1fVTU/xBftD3lH
         UOhMySW9hjXH8XnBpnl8L1tMLM2AJyS4pJryn4zgfIPVsChFancW1FoRRO2u5hwpEkWj
         K4Kg==
X-Gm-Message-State: APjAAAVdXN4XYkr06eRU6Nfg/A79STc4nghBuYrEslKLzgkNf8nsdtbz
	vD5odqol+icQlv5uc9hfa0ec8JsEjWWhYYiKLTVLn972NTQT/1X23zIQ9wqrIcuXz7hjKuBY1E/
	T4khzbj0OCqAMz/8CeGSa2R0021jSEUfyYXFffjhWGbrHo6RqjVDx6pbZ1LgnHJ2ncg==
X-Received: by 2002:a17:902:e213:: with SMTP id ce19mr12205082plb.30.1557207264576;
        Mon, 06 May 2019 22:34:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyg9OU/Q719oJxQq3tE494IW5MqZNeA4Omk59tvPSacH24nwCaBMzkdsj64neNxoFzXoRZJ
X-Received: by 2002:a17:902:e213:: with SMTP id ce19mr12205020plb.30.1557207263747;
        Mon, 06 May 2019 22:34:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557207263; cv=none;
        d=google.com; s=arc-20160816;
        b=oVhXow758L7EnZD3KCjPliyKfRFbfgaL2lNUULVkyNhVv5RrbpcnEFSbdN43eABNox
         HD9cKDWH9HCY9yW967gK8TJvkBV+ddkvDtxaABOs7JXgSvrDuA4+AhIO34Rd8EiAN7if
         3aRbVwBofapF3P9wAmYlLsNtPxam+U5Pm1syBBOpGCZXLWllCAT2U/WbQiqmVobSFKUe
         JvRBj4ONDxo/NFceoRSR3DWO/F81OHCjIpbH8xalxsRJS9FPTYUqAyp5i/9ci6M4NgjL
         UgsNnJLhootXExlsald1MwINTdW73+fd+QT/NIpzE3tm4VAOXhSiOByChked6DfzFBXC
         v/Nw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=6XV16zZuyWqtHNxdiJIXvbUs5Q0EJfu3zmK+tvcKxos=;
        b=vMw22mZPImhae9HIgqOdCU4B14++HoG/KMdBrfgu97alXqsCjliBbmRmZukapSxIEB
         vmtSHE+3Cgk9f+I5X96RjP93iVAqrqinVceGsGceGMBck8XMNQLiBFTTBGIHyRwIFYxp
         e/ySIsERz99fQsC9acqFhcy1gx6rtmg4JtXhCcINDAhpW6D8kWPAeQvVHZJoA2IfcRi+
         0WFHasauI2dfzDZSIBA/bDDSmLbIu87ISBAttkQ1GwomYKXPxxf62ysFIoytnixs52LG
         uG/TsdBUXi9uXm4+Z9Sqvye7+4GK1l0zCleBi7EeHVHzzEnXs+kbQz86neuyRVO/BSu8
         YcNw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=AZclECns;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 1si19094939pls.222.2019.05.06.22.34.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 22:34:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=AZclECns;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5BFED20B7C;
	Tue,  7 May 2019 05:34:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557207263;
	bh=oXIr1mm3+pichJjL+9iVnU0mTDTTZQqC5fQkWc/FwsU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=AZclECnsY76yV+4pSX8M9VuXUDZJlS6Pz+40P6Mf3s1hLCDJCcP/x4JsUDpy9gOYJ
	 ZPGWegaNJtqV7DVTNiAXlyS5LUNdU1FcHbFv1NC/sHVYwau2rnLsvAuG1nLqbDNSHi
	 Ii2/oEWAYydoU2bBnQpPhRMJriNdtg+5tgQJghi8=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Qian Cai <cai@lca.pw>,
	Michal Hocko <mhocko@suse.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Oscar Salvador <osalvador@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.0 57/99] mm/hotplug: treat CMA pages as unmovable
Date: Tue,  7 May 2019 01:31:51 -0400
Message-Id: <20190507053235.29900-57-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190507053235.29900-1-sashal@kernel.org>
References: <20190507053235.29900-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Qian Cai <cai@lca.pw>

[ Upstream commit 1a9f219157b22d0ffb340a9c5f431afd02cd2cf3 ]

has_unmovable_pages() is used by allocating CMA and gigantic pages as
well as the memory hotplug.  The later doesn't know how to offline CMA
pool properly now, but if an unused (free) CMA page is encountered, then
has_unmovable_pages() happily considers it as a free memory and
propagates this up the call chain.  Memory offlining code then frees the
page without a proper CMA tear down which leads to an accounting issues.
Moreover if the same memory range is onlined again then the memory never
gets back to the CMA pool.

State after memory offline:

 # grep cma /proc/vmstat
 nr_free_cma 205824

 # cat /sys/kernel/debug/cma/cma-kvm_cma/count
 209920

Also, kmemleak still think those memory address are reserved below but
have already been used by the buddy allocator after onlining.  This
patch fixes the situation by treating CMA pageblocks as unmovable except
when has_unmovable_pages() is called as part of CMA allocation.

  Offlined Pages 4096
  kmemleak: Cannot insert 0xc000201f7d040008 into the object search tree (overlaps existing)
  Call Trace:
    dump_stack+0xb0/0xf4 (unreliable)
    create_object+0x344/0x380
    __kmalloc_node+0x3ec/0x860
    kvmalloc_node+0x58/0x110
    seq_read+0x41c/0x620
    __vfs_read+0x3c/0x70
    vfs_read+0xbc/0x1a0
    ksys_read+0x7c/0x140
    system_call+0x5c/0x70
  kmemleak: Kernel memory leak detector disabled
  kmemleak: Object 0xc000201cc8000000 (size 13757317120):
  kmemleak:   comm "swapper/0", pid 0, jiffies 4294937297
  kmemleak:   min_count = -1
  kmemleak:   count = 0
  kmemleak:   flags = 0x5
  kmemleak:   checksum = 0
  kmemleak:   backtrace:
       cma_declare_contiguous+0x2a4/0x3b0
       kvm_cma_reserve+0x11c/0x134
       setup_arch+0x300/0x3f8
       start_kernel+0x9c/0x6e8
       start_here_common+0x1c/0x4b0
  kmemleak: Automatic memory scanning thread ended

[cai@lca.pw: use is_migrate_cma_page() and update commit log]
  Link: http://lkml.kernel.org/r/20190416170510.20048-1-cai@lca.pw
Link: http://lkml.kernel.org/r/20190413002623.8967-1-cai@lca.pw
Signed-off-by: Qian Cai <cai@lca.pw>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/page_alloc.c | 30 ++++++++++++++++++------------
 1 file changed, 18 insertions(+), 12 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 318ef6ccdb3b..eedb57f9b40b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7945,7 +7945,10 @@ void *__init alloc_large_system_hash(const char *tablename,
 bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 			 int migratetype, int flags)
 {
-	unsigned long pfn, iter, found;
+	unsigned long found;
+	unsigned long iter = 0;
+	unsigned long pfn = page_to_pfn(page);
+	const char *reason = "unmovable page";
 
 	/*
 	 * TODO we could make this much more efficient by not checking every
@@ -7955,17 +7958,20 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 	 * can still lead to having bootmem allocations in zone_movable.
 	 */
 
-	/*
-	 * CMA allocations (alloc_contig_range) really need to mark isolate
-	 * CMA pageblocks even when they are not movable in fact so consider
-	 * them movable here.
-	 */
-	if (is_migrate_cma(migratetype) &&
-			is_migrate_cma(get_pageblock_migratetype(page)))
-		return false;
+	if (is_migrate_cma_page(page)) {
+		/*
+		 * CMA allocations (alloc_contig_range) really need to mark
+		 * isolate CMA pageblocks even when they are not movable in fact
+		 * so consider them movable here.
+		 */
+		if (is_migrate_cma(migratetype))
+			return false;
+
+		reason = "CMA page";
+		goto unmovable;
+	}
 
-	pfn = page_to_pfn(page);
-	for (found = 0, iter = 0; iter < pageblock_nr_pages; iter++) {
+	for (found = 0; iter < pageblock_nr_pages; iter++) {
 		unsigned long check = pfn + iter;
 
 		if (!pfn_valid_within(check))
@@ -8045,7 +8051,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 unmovable:
 	WARN_ON_ONCE(zone_idx(zone) == ZONE_MOVABLE);
 	if (flags & REPORT_FAILURE)
-		dump_page(pfn_to_page(pfn+iter), "unmovable page");
+		dump_page(pfn_to_page(pfn + iter), reason);
 	return true;
 }
 
-- 
2.20.1

