Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E32C1C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 17:43:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC2AE2070D
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 17:43:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC2AE2070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 901EF8E011D; Fri, 22 Feb 2019 12:43:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D4468E011E; Fri, 22 Feb 2019 12:43:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 488978E011F; Fri, 22 Feb 2019 12:43:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id AB9988E011E
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 12:43:27 -0500 (EST)
Received: by mail-lf1-f69.google.com with SMTP id y13so568120lfg.14
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 09:43:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=l3573FcQI2TMlFRaIikWxGtlWdg1rVzxjrfhnZoKb7g=;
        b=IBnjw7rb4myGr9sRmdf1tGcTjK6igQ7Z6C21LeKKOrM0+MashEf9fClOTBIa5aW3Jq
         vzhK+nNTy4tj3SJ2b1K3/JnHBQTLCdz32chWmXNEKlklg315Tl8g7xVoQTR8Ap+PC7aW
         2OfDobfygZ5rTu0xkY55i3vnqLJFXLUKQ1ysVPJeCyIXm6cwzV/oTEvy4Sf4joagrGwC
         66Wn2thQa1Q1OMskR4LQJ4UL36+RHtqsb/sQaqsExrasbK4DQVyPD9VRrErwq0qwdqGk
         knJmPxKbwYRKuWyIex2VV7/B2kqq/H3DWPklfedP97ClT7UD1k+hn8Jocc/IcvqxCT4q
         vXtA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAub4zENceu7dzGuhXdeIQkZ8imsEItOZ9C/RQAJSNvSAvOyXljUv
	zv/PVLRydMMJGH1SKT3iJS8fLVXUcO/rJYU2RfLftUDhT4yUVFIE2C5tfu0/Jrmg1lQ/pItiRDy
	40xe3i/qqkaNzVkYx6vs5kZs9idZlY+W8VuE2f0U9sUrl3xERZAjUJS1fs620JTASbA==
X-Received: by 2002:a2e:8446:: with SMTP id u6-v6mr3043012ljh.74.1550857406958;
        Fri, 22 Feb 2019 09:43:26 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbjDxC20x9E8o+QZDVnP78BS4Q1bYCJ0HZ4cgTJwnGcC3pcwysCK5uIn8Q0HVWYscJTpDuk
X-Received: by 2002:a2e:8446:: with SMTP id u6-v6mr3042959ljh.74.1550857405548;
        Fri, 22 Feb 2019 09:43:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550857405; cv=none;
        d=google.com; s=arc-20160816;
        b=qTDUesPjdwGOzbaXe/Onsf7xmcf+HiOt4IXi+RLEr54d8V0slk3ONI33wMpCzapYq3
         REu0CYOLwsx1C3KAtcMB6Q50vv+VWy28MFmB16LB+ygn6rip1MO5JFYjrjBWkIvppDd+
         Bz4NsUHoIY97tcciB1a9s7eGqFwBEIAsQmH2HQv09aD17HC6C+pTEVDX2diDAEw5VV9D
         y2+/G9Pp3Qu2r5Qww129vlgJfxsunDBybqpqJzyo7h2bGYx1ZhEvlNvrm2+btOadppUS
         EAHOrEUD6p04eKqjPpIFq3H5yd9MpsW2xY4RIvSouGaJFwULXDShj4Ihw3rIORrrtQBT
         UrDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=l3573FcQI2TMlFRaIikWxGtlWdg1rVzxjrfhnZoKb7g=;
        b=iAOCzdNgs6cYlv+5GHrQQPzxWlvG921AW2kdDvEwL1tq9fMC8j8Zl243sfdlAODs80
         F2Eq9OSflAeT1/tZENPhLLD8SwKwTFgnuNRl8sqq8e8HHvfIhzSOLxytK6NP08Rk0Ka6
         ipTEygxwJDrF6x6LspkyZjmsZz4XcV+r3XB2pTHDxWZLnuTgIQY4e/7Jp39uQ4aReFv4
         iL9LDcnUX0e1eD/ZzelUVn1CzgR8aZVxTBiJZrmAZIIKnnWTFWKV61tPSNIS1tQvCWqF
         OgJ7mm3mogmXD6pagIigxRjKR+36FXUAtwPQtOd/4JvqTym/xjwGcVrk2HJ2USSjVbG4
         SkyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id m4si1537939lfh.59.2019.02.22.09.43.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 09:43:25 -0800 (PST)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12] (helo=i7.sw.ru)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1gxEr3-00010r-FQ; Fri, 22 Feb 2019 20:43:21 +0300
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Rik van Riel <riel@surriel.com>,
	Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 4/5] mm/vmscan: remove unused lru_pages argument
Date: Fri, 22 Feb 2019 20:43:36 +0300
Message-Id: <20190222174337.26390-4-aryabinin@virtuozzo.com>
X-Mailer: git-send-email 2.19.2
In-Reply-To: <20190222174337.26390-1-aryabinin@virtuozzo.com>
References: <20190222174337.26390-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The argument 'unsigned long *lru_pages' passed around with no purpose,
remove it.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Rik van Riel <riel@surriel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
---
 mm/vmscan.c | 17 +++++------------
 1 file changed, 5 insertions(+), 12 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2d081a32c6a8..07f74e9507b6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2257,8 +2257,7 @@ enum scan_balance {
  * nr[2] = file inactive pages to scan; nr[3] = file active pages to scan
  */
 static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
-			   struct scan_control *sc, unsigned long *nr,
-			   unsigned long *lru_pages)
+			   struct scan_control *sc, unsigned long *nr)
 {
 	int swappiness = mem_cgroup_swappiness(memcg);
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
@@ -2409,7 +2408,6 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	fraction[1] = fp;
 	denominator = ap + fp + 1;
 out:
-	*lru_pages = 0;
 	for_each_evictable_lru(lru) {
 		int file = is_file_lru(lru);
 		unsigned long lruvec_size;
@@ -2525,7 +2523,6 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 			BUG();
 		}
 
-		*lru_pages += lruvec_size;
 		nr[lru] = scan;
 	}
 }
@@ -2534,7 +2531,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
  * This is a basic per-node page freer.  Used by both kswapd and direct reclaim.
  */
 static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memcg,
-			      struct scan_control *sc, unsigned long *lru_pages)
+			      struct scan_control *sc)
 {
 	struct lruvec *lruvec = mem_cgroup_lruvec(pgdat, memcg);
 	unsigned long nr[NR_LRU_LISTS];
@@ -2546,7 +2543,7 @@ static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memc
 	struct blk_plug plug;
 	bool scan_adjusted;
 
-	get_scan_count(lruvec, memcg, sc, nr, lru_pages);
+	get_scan_count(lruvec, memcg, sc, nr);
 
 	/* Record the original scan target for proportional adjustments later */
 	memcpy(targets, nr, sizeof(nr));
@@ -2751,7 +2748,6 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			.pgdat = pgdat,
 			.priority = sc->priority,
 		};
-		unsigned long node_lru_pages = 0;
 		struct mem_cgroup *memcg;
 
 		memset(&sc->nr, 0, sizeof(sc->nr));
@@ -2761,7 +2757,6 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 
 		memcg = mem_cgroup_iter(root, NULL, &reclaim);
 		do {
-			unsigned long lru_pages;
 			unsigned long reclaimed;
 			unsigned long scanned;
 
@@ -2798,8 +2793,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 
 			reclaimed = sc->nr_reclaimed;
 			scanned = sc->nr_scanned;
-			shrink_node_memcg(pgdat, memcg, sc, &lru_pages);
-			node_lru_pages += lru_pages;
+			shrink_node_memcg(pgdat, memcg, sc);
 
 			if (sc->may_shrinkslab) {
 				shrink_slab(sc->gfp_mask, pgdat->node_id,
@@ -3332,7 +3326,6 @@ unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
 		.may_swap = !noswap,
 		.may_shrinkslab = 1,
 	};
-	unsigned long lru_pages;
 
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
@@ -3349,7 +3342,7 @@ unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
 	 * will pick up pages from other mem cgroup's as well. We hack
 	 * the priority and make it zero.
 	 */
-	shrink_node_memcg(pgdat, memcg, &sc, &lru_pages);
+	shrink_node_memcg(pgdat, memcg, &sc);
 
 	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
 
-- 
2.19.2

