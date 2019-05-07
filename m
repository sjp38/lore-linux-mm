Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34407C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 04:06:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DCA4F206BF
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 04:06:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="C/BO2gGc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DCA4F206BF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C1CD6B0010; Tue,  7 May 2019 00:06:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 122C16B026C; Tue,  7 May 2019 00:06:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA1EA6B0010; Tue,  7 May 2019 00:06:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 414126B000E
	for <linux-mm@kvack.org>; Tue,  7 May 2019 00:06:15 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 93so6627902plf.14
        for <linux-mm@kvack.org>; Mon, 06 May 2019 21:06:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=yWov6o46xZpNERY8ayCrMW/keWJ4olLp4dp39iSEbbk=;
        b=TmhFxopom5w405uioiE+nDqfTlVfjCqu+knO/WM4bUfwhX+hAqXT4H74/ksE4CahS0
         uvVZen+GPs3D14GA4mbKvxe/aDmTtEzUOJStH0rYcieYTFNeZ6VC5VUcnb11jMJG2DvX
         IObCgvwOyhAe9q8NHhH26urUs+BE6OXn8jqhpeK5SqIxBTScKL908mxnCW2rzaPYsrpH
         ttvHvNcCzvT2ph0N+NDi9B1CfB40Lt64pDpoYEs1Cjn5xKRMUiiug28nebKLI/2Bpvym
         bP5GKhzWmctw3RktE75HhoBHSQSrm9KmHOnVSaPtoEXzAclH6NbYjDRsWIRc54cvOKY/
         23dQ==
X-Gm-Message-State: APjAAAX30JcpqzOWb0pAM1tOmxoL7PQ2SW14tFffGZSAw+2cTMEDWUZc
	xTDeHRKqVAsB9HjLSY0JkPbbEqYJ1YdmRA+7u+4foOBalykiZoqMxykhVBwyLJCpE1y4wDV7eS5
	0Pdsq/xJHxFaFjqBc9hVZ6kbP2HkPx6WkEw5q7BocMOciNtADIMnbjDePcqk5aNK9lg==
X-Received: by 2002:a17:902:b490:: with SMTP id y16mr10022567plr.161.1557201974907;
        Mon, 06 May 2019 21:06:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz6JTqT1nAyolW17tMEYclm4PDqQC8QvlimLZuIIapHhBOWZw9d1bEJC7E76zV/wGejJXnc
X-Received: by 2002:a17:902:b490:: with SMTP id y16mr10022425plr.161.1557201973311;
        Mon, 06 May 2019 21:06:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557201973; cv=none;
        d=google.com; s=arc-20160816;
        b=GPlTOIGIjJn2Fs7ZXuT7noGvEWAOsK0OQdGVc6XAHncwukCf42tvFPGCu1M5bibWLD
         C2HxMF+FvKBp1wsijUAdu2PDY5JDwlDN4x2JELki+IEf1fpC2ow6z3uiQORBzig1pSxj
         xqf0e8IwAd+2mMh3ULRge0E2yoDeQZy6LF3xdst+bXKCL2rmFuqZ193JxET9ymJ9DtIf
         UacqjbMbhqf3qIWnpul/7ZZ2i0n544UQmITcPoOa8DS2FmrT4X86cOhf5O5R5DoxX6YE
         0tTmFyhGT5R5xkFjYh8EOqkhxepNmTAYd0Nea+uvJ3WLEtjUj5d9oMPE6TxmlnqwVbym
         LWbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=yWov6o46xZpNERY8ayCrMW/keWJ4olLp4dp39iSEbbk=;
        b=AinDRt3iSVnJhxqnytQwoT4UC/gWsn2BGs4dob+m2t2tY1D3/W7zpbYVC9OJ7RRlxN
         r6HkBh5MKzWtRmHNh/5qWx+UHdwuu66lNV0G8Pi5bU2OEEoYEb5aPFPpj4+KfK6C7v7J
         gs/JhaeE6xrZ2RMonQvz2FfNH3MiOd+E+ZDzGP+iLECp1XAzTnsRsfXcdXlQi7hus6or
         jVEkZrC/hbhnrs4k6DC/pWu5kDeCBAZZg5glDRRhsGnbNeR9iep5zFSZjxQSyl1/wVQc
         gD7dVJnIJTSnRjoAI2x2u0EDq56/usLdtJItsIRAgWz3YypTQQbAR0ShlJBh40CFC+tp
         miAg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="C/BO2gGc";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e24si16814232pgh.403.2019.05.06.21.06.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 06 May 2019 21:06:13 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="C/BO2gGc";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=References:In-Reply-To:Message-Id:
	Date:Subject:Cc:To:From:Sender:Reply-To:MIME-Version:Content-Type:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=yWov6o46xZpNERY8ayCrMW/keWJ4olLp4dp39iSEbbk=; b=C/BO2gGcJ+zHKAA3YIO/zEEg4
	JuDpRzAmQrFaMdG12HQLyAepL0FTipYxzftr1ZBoXpge1IjpZ2na4CbPyORxRq7/+ZOidHBPXjsr9
	zN7W9ZkQB3wtcC7/9rrhBtZcl4gePknGJsJHzGxb1VpC3/Ql/g2cBDd8bvURBh4TZNyZ9osa09Wrf
	SMf9ZZKWc2kaWCfq6+7Q/UwTMf/xoFllXKmPQPWZp1LK6Oo2Gjw6VUk8mkFM+nPzBNoGC4GvNJNmK
	HQTvniCkS948K5DRxnsdFhpm9ouseCnrmXS/5KjZJV6ftCRa1e/sqtseaOc6X7CwU8ht3ilL3mYUv
	5ClWocTDQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hNrMq-0005ir-OV; Tue, 07 May 2019 04:06:12 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Subject: [PATCH 11/11] mm: Pass order to node_reclaim() in GFP flags
Date: Mon,  6 May 2019 21:06:09 -0700
Message-Id: <20190507040609.21746-12-willy@infradead.org>
X-Mailer: git-send-email 2.14.5
In-Reply-To: <20190507040609.21746-1-willy@infradead.org>
References: <20190507040609.21746-1-willy@infradead.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Matthew Wilcox (Oracle)" <willy@infradead.org>

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 include/trace/events/vmscan.h |  8 +++-----
 mm/internal.h                 |  5 ++---
 mm/page_alloc.c               |  2 +-
 mm/vmscan.c                   | 13 ++++++-------
 4 files changed, 12 insertions(+), 16 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index fd8b468570c8..bc5a8a6f6e64 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -464,25 +464,23 @@ TRACE_EVENT(mm_vmscan_inactive_list_is_low,
 
 TRACE_EVENT(mm_vmscan_node_reclaim_begin,
 
-	TP_PROTO(int nid, int order, gfp_t gfp_flags),
+	TP_PROTO(int nid, gfp_t gfp_flags),
 
-	TP_ARGS(nid, order, gfp_flags),
+	TP_ARGS(nid, gfp_flags),
 
 	TP_STRUCT__entry(
 		__field(int, nid)
-		__field(int, order)
 		__field(gfp_t, gfp_flags)
 	),
 
 	TP_fast_assign(
 		__entry->nid = nid;
-		__entry->order = order;
 		__entry->gfp_flags = gfp_flags;
 	),
 
 	TP_printk("nid=%d order=%d gfp_flags=%s",
 		__entry->nid,
-		__entry->order,
+		gfp_order(__entry->gfp_flags),
 		show_gfp_flags(__entry->gfp_flags))
 );
 
diff --git a/mm/internal.h b/mm/internal.h
index 9eeaf2b95166..353cefdc3f34 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -457,10 +457,9 @@ static inline void mminit_validate_memmodel_limits(unsigned long *start_pfn,
 #define NODE_RECLAIM_SUCCESS	1
 
 #ifdef CONFIG_NUMA
-extern int node_reclaim(struct pglist_data *, gfp_t, unsigned int);
+extern int node_reclaim(struct pglist_data *, gfp_t);
 #else
-static inline int node_reclaim(struct pglist_data *pgdat, gfp_t mask,
-				unsigned int order)
+static inline int node_reclaim(struct pglist_data *pgdat, gfp_t mask)
 {
 	return NODE_RECLAIM_NOSCAN;
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5ac2cbb105c3..6ea7bda90100 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3577,7 +3577,7 @@ get_page_from_freelist(gfp_t gfp_mask, int alloc_flags,
 			    !zone_allows_reclaim(ac->preferred_zoneref->zone, zone))
 				continue;
 
-			ret = node_reclaim(zone->zone_pgdat, gfp_mask, order);
+			ret = node_reclaim(zone->zone_pgdat, gfp_mask);
 			switch (ret) {
 			case NODE_RECLAIM_NOSCAN:
 				/* did not scan */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5d465bdaf225..171844a2a8c0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -4148,17 +4148,17 @@ static unsigned long node_pagecache_reclaimable(struct pglist_data *pgdat)
 /*
  * Try to free up some pages from this node through reclaim.
  */
-static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned int order)
+static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask)
 {
 	/* Minimum pages needed in order to stay on node */
-	const unsigned long nr_pages = 1 << order;
+	const unsigned long nr_pages = 1UL << gfp_order(gfp_mask);
 	struct task_struct *p = current;
 	struct reclaim_state reclaim_state;
 	unsigned int noreclaim_flag;
 	struct scan_control sc = {
 		.nr_to_reclaim = max(nr_pages, SWAP_CLUSTER_MAX),
 		.gfp_mask = current_gfp_context(gfp_mask),
-		.order = order,
+		.order = gfp_order(gfp_mask),
 		.priority = NODE_RECLAIM_PRIORITY,
 		.may_writepage = !!(node_reclaim_mode & RECLAIM_WRITE),
 		.may_unmap = !!(node_reclaim_mode & RECLAIM_UNMAP),
@@ -4166,8 +4166,7 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 		.reclaim_idx = gfp_zone(gfp_mask),
 	};
 
-	trace_mm_vmscan_node_reclaim_begin(pgdat->node_id, order,
-					   sc.gfp_mask);
+	trace_mm_vmscan_node_reclaim_begin(pgdat->node_id, sc.gfp_mask);
 
 	cond_resched();
 	fs_reclaim_acquire(sc.gfp_mask);
@@ -4201,7 +4200,7 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 	return sc.nr_reclaimed >= nr_pages;
 }
 
-int node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned int order)
+int node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask)
 {
 	int ret;
 
@@ -4237,7 +4236,7 @@ int node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned int order)
 	if (test_and_set_bit(PGDAT_RECLAIM_LOCKED, &pgdat->flags))
 		return NODE_RECLAIM_NOSCAN;
 
-	ret = __node_reclaim(pgdat, gfp_mask, order);
+	ret = __node_reclaim(pgdat, gfp_mask);
 	clear_bit(PGDAT_RECLAIM_LOCKED, &pgdat->flags);
 
 	if (!ret)
-- 
2.20.1

