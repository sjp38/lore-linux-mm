Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00EAFC282CE
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 22:12:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90FC92186A
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 22:12:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JQVCFkvU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90FC92186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 27E616B0269; Fri,  5 Apr 2019 18:12:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2051B6B026A; Fri,  5 Apr 2019 18:12:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 07FDE6B026B; Fri,  5 Apr 2019 18:12:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id BB95D6B0269
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 18:12:28 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e20so5336801pfn.8
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 15:12:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=dVuSGqGMdSL+lYB9NVdPOXJ/yezgrt5Vhv+/46VVp14=;
        b=KnIY3SQHaNJV2QEFsJ6fbdHsawTVdzMjHGdXXnrSGOYo1v/Yih8u5/np6qRgME1Qjr
         SbBN8LSCG6M8t/UF3DsN6o0PbZdUqZClrI7weoK6LtGij4EdnB7dDwIwTCk9ZJjS642a
         B1kEvSvvfbKsqG+iEbdtl84lQJFMGH+kohAPaV39VzJRKE8e7DoWo4v4VYd6goN144F/
         3H/PajITuezszrEYIYBBSkEDECfZs0aSJyTenDhKmkDwiAZ2qoy6EtlT9FWStEWTORD5
         QbtwvGbZip9Moh7SgCXfXC2rOZyQrGk0CSpyX8TgxDgd2jLQDpbIF8RiQ7min1uJGN6v
         24ag==
X-Gm-Message-State: APjAAAU1mDPgd+9tZOuCBl5CRXjyoZ+irwLHSMOWjFmHi8d208wUb+eu
	CLpIT0zz9hsuzsFDudjCIq//WqWJ+KreD7FWwnAMNXHdnxUQ9oF2nqwysQrUn3b5rtn/OLuie/N
	5pmHPteAhPk0V63JXmBjn+aXoPIV7E9wBSzuEE5Ws+Szi2zLkpPLZvFKMVJ7vMtaycg==
X-Received: by 2002:a62:12d0:: with SMTP id 77mr15016673pfs.15.1554502348368;
        Fri, 05 Apr 2019 15:12:28 -0700 (PDT)
X-Received: by 2002:a62:12d0:: with SMTP id 77mr15016600pfs.15.1554502347325;
        Fri, 05 Apr 2019 15:12:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554502347; cv=none;
        d=google.com; s=arc-20160816;
        b=HNpDYwyPLyN9EnqzXMhgmdqJiQ3FKWjLbNtFZyxI/st4VR3eUayyKC0ySsjvHtxPHV
         fAGd1e+wqgZ5Gpflv/jE4r8nVdjoFodA+2bNCWwOERj8rNj4Hv29EaSsvvDCHL0LC36I
         V/YuXAz2JNARzenj4epvh3IvSfJ/h0YM6gqwVswOSXlRxYJ0NSXawXTJ4lM2rFCrOw7g
         ucwV5CmGZS4s6lINGdfEZPGNcZHhqiIpvc6qs+c3s0jdcrv4sK6JjRWCaTO3y0PBHNUF
         CUwpgWAyu0SH70B2maYBGSexWKXuDVce7/HYjGqtYunPVvCZT8sNVYT14oSl+UcrpKfa
         6CBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=dVuSGqGMdSL+lYB9NVdPOXJ/yezgrt5Vhv+/46VVp14=;
        b=lAxXI0FsIicHIu7uwxxy6ypfETbbYK19lwwVpNqq5h+N5+vr1FTk5przHbWqaRgMif
         CjCQYqFi/fRjY7hXKQRJuLuRpsDebeLOfQq8255WryQaZmxrJpzE+hn/BtxXzZ3vSATh
         2B9/rU3jv1u61DWVaASOtCn3AnP06bYMmOdNGIDA0pHLmTm21BgbZMpwQLrilYbEcrt1
         51gkhgZd7EN9Gj0JjfnK4c/zfr03VFgujCA2d/yghZfBGKpJiiDUpRObJdr6yrPvm3rt
         kUv+Lv1cDik0i/CEr14xznkWpinEeq/zdND1kGCE3vBvX3oV944D2dPFlbsguVhoQP5w
         HwCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JQVCFkvU;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z64sor3847683pfz.2.2019.04.05.15.12.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Apr 2019 15:12:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JQVCFkvU;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=dVuSGqGMdSL+lYB9NVdPOXJ/yezgrt5Vhv+/46VVp14=;
        b=JQVCFkvUkfWotyAFTK0D20cgOePlePMZbaEA60cegN8gvROzBwq6nj7PYVeXVjhR8g
         NZzIIiVk2R4QQvX6GA8mIKChjKmhPLCY+hYRKgEiuHzfsshVMvf0mOQlLzE+e0mG5L2U
         prbcDAvY/fTOQJSxxCXfORrqJuu4QoAEf0wXdalbKvLm/vf/DkOoQZdivMOpzrNZP/lN
         vkS06bjvHACsJldSdBM0ThykU5zprTeBnS46dQ8JZ9hcpXn47Zjhtzeah/QrVfh5i7Vh
         PVnpqnU7tXzqfiMoHOm76lWBBUH+Mx2uwHhcCELcSLVlkTi6xJuNGIX7/LefnnkIlzvL
         fIoQ==
X-Google-Smtp-Source: APXvYqxKbwb1VzShMBMk6QhT/5s3udfUks/YgS3lLw5sgTjR3Ne4rhJN++RLqGAP8qX1lUodDpAx3g==
X-Received: by 2002:aa7:8289:: with SMTP id s9mr15095613pfm.208.1554502346930;
        Fri, 05 Apr 2019 15:12:26 -0700 (PDT)
Received: from localhost.localdomain (50-126-100-225.drr01.csby.or.frontiernet.net. [50.126.100.225])
        by smtp.gmail.com with ESMTPSA id f63sm30382350pfc.180.2019.04.05.15.12.25
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Apr 2019 15:12:26 -0700 (PDT)
Subject: [mm PATCH v7 3/4] mm: Implement new zone specific memblock iterator
From: Alexander Duyck <alexander.duyck@gmail.com>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: pavel.tatashin@microsoft.com, mhocko@suse.com, dave.jiang@intel.com,
 linux-nvdimm@lists.01.org, alexander.h.duyck@linux.intel.com,
 linux-kernel@vger.kernel.org, willy@infradead.org, mingo@kernel.org,
 yi.z.zhang@linux.intel.com, khalid.aziz@oracle.com, rppt@linux.vnet.ibm.com,
 vbabka@suse.cz, sparclinux@vger.kernel.org, dan.j.williams@intel.com,
 ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, davem@davemloft.net,
 kirill.shutemov@linux.intel.com
Date: Fri, 05 Apr 2019 15:12:25 -0700
Message-ID: <20190405221225.12227.22573.stgit@localhost.localdomain>
In-Reply-To: <20190405221043.12227.19679.stgit@localhost.localdomain>
References: <20190405221043.12227.19679.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alexander Duyck <alexander.h.duyck@linux.intel.com>

Introduce a new iterator for_each_free_mem_pfn_range_in_zone.

This iterator will take care of making sure a given memory range provided
is in fact contained within a zone. It takes are of all the bounds checking
we were doing in deferred_grow_zone, and deferred_init_memmap. In addition
it should help to speed up the search a bit by iterating until the end of a
range is greater than the start of the zone pfn range, and will exit
completely if the start is beyond the end of the zone.

Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 include/linux/memblock.h |   25 ++++++++++++++++++
 mm/memblock.c            |   64 ++++++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c          |   31 +++++++++-------------
 3 files changed, 101 insertions(+), 19 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 294d5d80e150..f8b78892b977 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -240,6 +240,31 @@ void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
 	     i >= 0; __next_mem_pfn_range(&i, nid, p_start, p_end, p_nid))
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
+#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
+void __next_mem_pfn_range_in_zone(u64 *idx, struct zone *zone,
+				  unsigned long *out_spfn,
+				  unsigned long *out_epfn);
+/**
+ * for_each_free_mem_range_in_zone - iterate through zone specific free
+ * memblock areas
+ * @i: u64 used as loop variable
+ * @zone: zone in which all of the memory blocks reside
+ * @p_start: ptr to phys_addr_t for start address of the range, can be %NULL
+ * @p_end: ptr to phys_addr_t for end address of the range, can be %NULL
+ *
+ * Walks over free (memory && !reserved) areas of memblock in a specific
+ * zone. Available once memblock and an empty zone is initialized. The main
+ * assumption is that the zone start, end, and pgdat have been associated.
+ * This way we can use the zone to determine NUMA node, and if a given part
+ * of the memblock is valid for the zone.
+ */
+#define for_each_free_mem_pfn_range_in_zone(i, zone, p_start, p_end)	\
+	for (i = 0,							\
+	     __next_mem_pfn_range_in_zone(&i, zone, p_start, p_end);	\
+	     i != U64_MAX;					\
+	     __next_mem_pfn_range_in_zone(&i, zone, p_start, p_end))
+#endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
+
 /**
  * for_each_free_mem_range - iterate through free memblock areas
  * @i: u64 used as loop variable
diff --git a/mm/memblock.c b/mm/memblock.c
index e7665cf914b1..28fa8926d9f8 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1255,6 +1255,70 @@ int __init_memblock memblock_set_node(phys_addr_t base, phys_addr_t size,
 	return 0;
 }
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
+#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
+/**
+ * __next_mem_pfn_range_in_zone - iterator for for_each_*_range_in_zone()
+ *
+ * @idx: pointer to u64 loop variable
+ * @zone: zone in which all of the memory blocks reside
+ * @out_spfn: ptr to ulong for start pfn of the range, can be %NULL
+ * @out_epfn: ptr to ulong for end pfn of the range, can be %NULL
+ *
+ * This function is meant to be a zone/pfn specific wrapper for the
+ * for_each_mem_range type iterators. Specifically they are used in the
+ * deferred memory init routines and as such we were duplicating much of
+ * this logic throughout the code. So instead of having it in multiple
+ * locations it seemed like it would make more sense to centralize this to
+ * one new iterator that does everything they need.
+ */
+void __init_memblock
+__next_mem_pfn_range_in_zone(u64 *idx, struct zone *zone,
+			     unsigned long *out_spfn, unsigned long *out_epfn)
+{
+	int zone_nid = zone_to_nid(zone);
+	phys_addr_t spa, epa;
+	int nid;
+
+	__next_mem_range(idx, zone_nid, MEMBLOCK_NONE,
+			 &memblock.memory, &memblock.reserved,
+			 &spa, &epa, &nid);
+
+	while (*idx != U64_MAX) {
+		unsigned long epfn = PFN_DOWN(epa);
+		unsigned long spfn = PFN_UP(spa);
+
+		/*
+		 * Verify the end is at least past the start of the zone and
+		 * that we have at least one PFN to initialize.
+		 */
+		if (zone->zone_start_pfn < epfn && spfn < epfn) {
+			/* if we went too far just stop searching */
+			if (zone_end_pfn(zone) <= spfn) {
+				*idx = U64_MAX;
+				break;
+			}
+
+			if (out_spfn)
+				*out_spfn = max(zone->zone_start_pfn, spfn);
+			if (out_epfn)
+				*out_epfn = min(zone_end_pfn(zone), epfn);
+
+			return;
+		}
+
+		__next_mem_range(idx, zone_nid, MEMBLOCK_NONE,
+				 &memblock.memory, &memblock.reserved,
+				 &spa, &epa, &nid);
+	}
+
+	/* signal end of iteration */
+	if (out_spfn)
+		*out_spfn = ULONG_MAX;
+	if (out_epfn)
+		*out_epfn = 0;
+}
+
+#endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
 
 /**
  * memblock_alloc_range_nid - allocate boot memory block
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2d2bca9803d2..61467e28c966 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1613,11 +1613,9 @@ static unsigned long  __init deferred_init_pages(struct zone *zone,
 static int __init deferred_init_memmap(void *data)
 {
 	pg_data_t *pgdat = data;
-	int nid = pgdat->node_id;
 	unsigned long start = jiffies;
 	unsigned long nr_pages = 0;
 	unsigned long spfn, epfn, first_init_pfn, flags;
-	phys_addr_t spa, epa;
 	int zid;
 	struct zone *zone;
 	const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
@@ -1654,14 +1652,12 @@ static int __init deferred_init_memmap(void *data)
 	 * freeing pages we can access pages that are ahead (computing buddy
 	 * page in __free_one_page()).
 	 */
-	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
-		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
-		epfn = min_t(unsigned long, zone_end_pfn(zone), PFN_DOWN(epa));
+	for_each_free_mem_pfn_range_in_zone(i, zone, &spfn, &epfn) {
+		spfn = max_t(unsigned long, first_init_pfn, spfn);
 		nr_pages += deferred_init_pages(zone, spfn, epfn);
 	}
-	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
-		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
-		epfn = min_t(unsigned long, zone_end_pfn(zone), PFN_DOWN(epa));
+	for_each_free_mem_pfn_range_in_zone(i, zone, &spfn, &epfn) {
+		spfn = max_t(unsigned long, first_init_pfn, spfn);
 		deferred_free_pages(spfn, epfn);
 	}
 	pgdat_resize_unlock(pgdat, &flags);
@@ -1669,8 +1665,8 @@ static int __init deferred_init_memmap(void *data)
 	/* Sanity check that the next zone really is unpopulated */
 	WARN_ON(++zid < MAX_NR_ZONES && populated_zone(++zone));
 
-	pr_info("node %d initialised, %lu pages in %ums\n", nid, nr_pages,
-					jiffies_to_msecs(jiffies - start));
+	pr_info("node %d initialised, %lu pages in %ums\n",
+		pgdat->node_id,	nr_pages, jiffies_to_msecs(jiffies - start));
 
 	pgdat_init_report_one_done();
 	return 0;
@@ -1694,13 +1690,11 @@ static int __init deferred_init_memmap(void *data)
 static noinline bool __init
 deferred_grow_zone(struct zone *zone, unsigned int order)
 {
-	int nid = zone_to_nid(zone);
-	pg_data_t *pgdat = NODE_DATA(nid);
 	unsigned long nr_pages_needed = ALIGN(1 << order, PAGES_PER_SECTION);
+	pg_data_t *pgdat = zone->zone_pgdat;
 	unsigned long nr_pages = 0;
 	unsigned long first_init_pfn, spfn, epfn, t, flags;
 	unsigned long first_deferred_pfn = pgdat->first_deferred_pfn;
-	phys_addr_t spa, epa;
 	u64 i;
 
 	/* Only the last zone may have deferred pages */
@@ -1736,9 +1730,8 @@ static int __init deferred_init_memmap(void *data)
 		return false;
 	}
 
-	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
-		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
-		epfn = min_t(unsigned long, zone_end_pfn(zone), PFN_DOWN(epa));
+	for_each_free_mem_pfn_range_in_zone(i, zone, &spfn, &epfn) {
+		spfn = max_t(unsigned long, first_init_pfn, spfn);
 
 		while (spfn < epfn && nr_pages < nr_pages_needed) {
 			t = ALIGN(spfn + PAGES_PER_SECTION, PAGES_PER_SECTION);
@@ -1752,9 +1745,9 @@ static int __init deferred_init_memmap(void *data)
 			break;
 	}
 
-	for_each_free_mem_range(i, nid, MEMBLOCK_NONE, &spa, &epa, NULL) {
-		spfn = max_t(unsigned long, first_init_pfn, PFN_UP(spa));
-		epfn = min_t(unsigned long, first_deferred_pfn, PFN_DOWN(epa));
+	for_each_free_mem_pfn_range_in_zone(i, zone, &spfn, &epfn) {
+		spfn = max_t(unsigned long, first_init_pfn, spfn);
+		epfn = min_t(unsigned long, first_deferred_pfn, epfn);
 		deferred_free_pages(spfn, epfn);
 
 		if (first_deferred_pfn == epfn)

