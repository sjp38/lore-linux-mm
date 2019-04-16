Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5F75C282DA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 17:05:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6DA182087C
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 17:05:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="XlrbG0dS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DA182087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF2C76B0266; Tue, 16 Apr 2019 13:05:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA46B6B0269; Tue, 16 Apr 2019 13:05:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D93BD6B026A; Tue, 16 Apr 2019 13:05:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id B39336B0266
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 13:05:52 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id x23so18420333qka.19
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 10:05:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=XtR+JxYWE/z/6y97hZH4+xI4vSK6w0v5+dVQRinH+Z0=;
        b=JO0/XVS/MdaP2K0yWA8TYj/gFM6QcvuXzjrIokg/scA1tuNULTicSQboJhjLHjovX8
         59GTghJJ5Nr9v8N/vdsUXA9oRq3bStJtbbaZUaR25X4MS9dITBeq2Wi9c79JJa2SwsXn
         CEHfxHkfbhByyd0ou+jPqtv8U2K/belW7FAEZKZ/iCHIOJbJKAuGM/+wRqcxxAJhz8oX
         1xUG3ElDJ6npzg3XmS6xRRanrS4vSlGmeLREf8Aj4L1h4acH39+MjfCN6S2U58CgxjzL
         H96aE75n9d98gkJHYj7M5AJ3b00YM9sTxhyfydp8vT43HvhoVsC+kWNd8IaHdNz1jeAN
         UAYg==
X-Gm-Message-State: APjAAAUQarWsP5DmbBOzwdIp0uJ1a3hMhiaWUhZ7dTTIvBnpJifK0VqM
	ksRxQeOVgRng932754GbWFTkRVlsXnGTk3Hg4Myngr2+1H9S9lc3f+p7nCinbmHdcKur40kWQeS
	4nR4lmLGHF6C21E7+DCmI2Lti4Oq3nkBpo6+BQtPaw+LBPI4kyIJuoFWjrQAOxqS3YA==
X-Received: by 2002:a37:a246:: with SMTP id l67mr61586886qke.237.1555434352342;
        Tue, 16 Apr 2019 10:05:52 -0700 (PDT)
X-Received: by 2002:a37:a246:: with SMTP id l67mr61586746qke.237.1555434350629;
        Tue, 16 Apr 2019 10:05:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555434350; cv=none;
        d=google.com; s=arc-20160816;
        b=YoUxMCYaaZsIbkGxu8NiLQ+68eXEPAhVJn8osh8YxTzU033jrlguvnYka2Vvw1y4m4
         Ahe756ScH/qReJpfoN1IJfsrL5mOQgEp+WuYVbGjPUFkZaeb4fphgtfmznHPG9mAn6Im
         kNefU02d2HGWInXKREIzJDgCcungi6GlCztqF67TLHfxkODLqmRHtdvskAkpPGWfDA5H
         A8pOr1dvNqPC5zdyjphCcaB1vq8TsRxZ2bCf94hiHeIkjnulVnRxQ5Nkw1wU9BStyrJ8
         ng1dDBSmw1CYW1sVoyArKz3LiprP2thH7Bur5UNNr1vCo1OQdpxnqc/F0g6p81FqCg4g
         2T2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=XtR+JxYWE/z/6y97hZH4+xI4vSK6w0v5+dVQRinH+Z0=;
        b=dc8IsW+Cs5whuhNqgaF158Lj5dHk1s/rlVtz+YY97aoDGYp0TzCjpQNYPH5k9EIdi0
         S8i3TUO8J9Gud4AUJnWSmN/UOppTQd/ldPKswJiMlgXH3F6KE2CyqKukZcp4lp0ksVLR
         gkXFvM4RjdeCqcSQ9cxwDp4HBSD94nd83hcP0s494afzOhRmV/IlxnCW7XNLFrB6B9Ni
         IM944rSM82WF8VIGHIFpAThFPdJSvZfNyja0PqBcXacBCMY4en0l6Rl8oyLXHEzcFcxe
         J9OZONHhs/dcksZEz+FAUKWpQIhQygFjoe+wBvCXD8KMo5wbBR6ESgu8dm/RThs+KP+f
         8/UA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=XlrbG0dS;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z192sor32257129qka.66.2019.04.16.10.05.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Apr 2019 10:05:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=XlrbG0dS;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=XtR+JxYWE/z/6y97hZH4+xI4vSK6w0v5+dVQRinH+Z0=;
        b=XlrbG0dSXQaKCqJ6oDXPnysHRJQlRGQzQ/8QsS2sCiPWRvfggPR5oqp1pbLA/61dO4
         28Jj6vdq97OzDEme/JlulXC2o+Oam0CH6Pn4H2FdvPTfqNf7aDlFuuga6NzdBtU4xaos
         q2ZUvP/czfBCE3d2X7EginnTov2XVyHW0SbV9EJ6n5i7wi9H1eBJBn0f6oh3Jntk/WjZ
         +pdbvyF5c4HG0mqYb+ztmuDjKuk6U1OKA13ynsSv6/7dUHTnlOjeY+bRDQLUG4xioaWi
         KCNkrKA6RwayZlzbXhNhPJnHwRsQwEy3y1y2nD0uW6xIVsAqoKwv2+1WVt1ZA54kFKxJ
         3hXg==
X-Google-Smtp-Source: APXvYqznAuQo6d6nHKCse/naTQKiOVz5utoPPkz+iRwwqaHCeR/aqn8tE2Mx1uKby3JEv87St1QuMw==
X-Received: by 2002:a37:4757:: with SMTP id u84mr56641076qka.275.1555434350060;
        Tue, 16 Apr 2019 10:05:50 -0700 (PDT)
Received: from ovpn-120-81.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id d205sm28157637qkg.66.2019.04.16.10.05.48
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 10:05:49 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com,
	osalvador@suse.de,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>,
	Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v4] mm/hotplug: treat CMA pages as unmovable
Date: Tue, 16 Apr 2019 13:05:10 -0400
Message-Id: <20190416170510.20048-1-cai@lca.pw>
X-Mailer: git-send-email 2.20.1 (Apple Git-117)
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

has_unmovable_pages() is used by allocating CMA and gigantic pages as
well as the memory hotplug. The later doesn't know how to offline CMA
pool properly now, but if an unused (free) CMA page is encountered, then
has_unmovable_pages() happily considers it as a free memory and
propagates this up the call chain. Memory offlining code then frees the
page without a proper CMA tear down which leads to an accounting issues.
Moreover if the same memory range is onlined again then the memory never
gets back to the CMA pool.

State after memory offline:
 # grep cma /proc/vmstat
 nr_free_cma 205824

 # cat /sys/kernel/debug/cma/cma-kvm_cma/count
 209920

Also, kmemleak still think those memory address are reserved below but
have already been used by the buddy allocator after onlining. This patch
fixes the situation by treating CMA pageblocks as unmovable except when
has_unmovable_pages() is called as part of CMA allocation.

Offlined Pages 4096
kmemleak: Cannot insert 0xc000201f7d040008 into the object search tree
(overlaps existing)
Call Trace:
[c00000003dc2faf0] [c000000000884b2c] dump_stack+0xb0/0xf4 (unreliable)
[c00000003dc2fb30] [c000000000424fb4] create_object+0x344/0x380
[c00000003dc2fbf0] [c0000000003d178c] __kmalloc_node+0x3ec/0x860
[c00000003dc2fc90] [c000000000319078] kvmalloc_node+0x58/0x110
[c00000003dc2fcd0] [c000000000484d9c] seq_read+0x41c/0x620
[c00000003dc2fd60] [c0000000004472bc] __vfs_read+0x3c/0x70
[c00000003dc2fd80] [c0000000004473ac] vfs_read+0xbc/0x1a0
[c00000003dc2fdd0] [c00000000044783c] ksys_read+0x7c/0x140
[c00000003dc2fe20] [c00000000000b108] system_call+0x5c/0x70
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

Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Qian Cai <cai@lca.pw>
---

v4: Use is_migrate_cma_page() and update the commit log per Vlastimil.
v3: Use a string pointer instead of an array per Michal.
v2: Borrow some commit log texts.
    Call dump_page() in the error path.

 mm/page_alloc.c | 30 ++++++++++++++++++------------
 1 file changed, 18 insertions(+), 12 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d96ca5bc555b..c6ce20aaf80b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -8005,7 +8005,10 @@ void *__init alloc_large_system_hash(const char *tablename,
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
@@ -8015,17 +8018,20 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
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
@@ -8105,7 +8111,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 unmovable:
 	WARN_ON_ONCE(zone_idx(zone) == ZONE_MOVABLE);
 	if (flags & REPORT_FAILURE)
-		dump_page(pfn_to_page(pfn+iter), "unmovable page");
+		dump_page(pfn_to_page(pfn + iter), reason);
 	return true;
 }
 
-- 
2.20.1 (Apple Git-117)

