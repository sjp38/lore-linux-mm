Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BD58C10F00
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 08:35:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D7D46218AE
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 08:35:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D7D46218AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BAE78E0005; Thu, 28 Feb 2019 03:35:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 14D7B8E0008; Thu, 28 Feb 2019 03:35:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E40D38E0005; Thu, 28 Feb 2019 03:35:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 72D7A8E0006
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 03:35:49 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id y86so751813lje.1
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 00:35:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=OF/MFn2RYZUqEg593eJ/PysigzeOI7gs8bHHT/DLPHw=;
        b=A1EIpJ0MvdN4BHB5ES1AZfJhAmzFTAk6RNsgmHnZUWSTVQP4AeNYEf3z/o/UxZbivy
         RRRJiTEIOv+zJVLouKbeGVPl4WjUsed5ku+LuHXaId3S3Gkbrxhk7iZYbjY8RrkgeF6B
         vnxtvMrpP/dJlLEi1sJbTb/C4eMGPJ2JbiLLzMEFNnytJpP2/cLBK1+dmmrXkrFo8EYr
         Yqj9uLmS3Ue3x7uT2HYJB6eJog5PQ87x1LoWk80RqYvv/+66OqQuFIIaJcgCNTFP2y3k
         WzuPJF4mNpggv0ikXSy4I7Lia42OuReyxI1ymfFdsF8ZER+98ZjmhjrJHZJmRjKfeuef
         VM4g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAVPBF++Qtr3eIPuB+M4tkKY7woTJAK7UJkqauhw7cEFgDsL+iau
	pi53FdhHe1vrFAdk54mdr3LFQ5O168weXMoWWIAgwfls1UxUC/MK30SOe84nPKT+doumUNegOtV
	d0eauDw0wW+kaPmMgebd6Vg7VP36fjO418ukFo+pihPDyTEqNJ7KcjnU1Cfq5p58QLA==
X-Received: by 2002:a2e:5d88:: with SMTP id v8mr4018998lje.150.1551342948752;
        Thu, 28 Feb 2019 00:35:48 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZkw68zdGBkYq3fedbBzH7/qpSgd0S3U6dRwlt3WzYhtIRAu9Zyi4ENtej0KONb6JqY3FQw
X-Received: by 2002:a2e:5d88:: with SMTP id v8mr4018951lje.150.1551342947427;
        Thu, 28 Feb 2019 00:35:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551342947; cv=none;
        d=google.com; s=arc-20160816;
        b=uDLWwjuf9mpAb0hry/HErsXKMLcRybVcZgbXJ2YAweUcTp5pODoRKticiDYoMR+A/R
         p4MCAiK/hI9rN8XCnxJAHYHYIVJM0JHyDh8S5SS/WDYkqIX6QHzYa4Np3ido4C6gRDbm
         I6zcrkFq17sTovRCWI8bAMHwFXxkUKWKKsj+f3cAmcyCHmdV8BtyrnZ1QlG2wxHdbB7M
         sQS+BbUS+t70foicx5FUPWWY51H4zDYKPbu8ATgkTlYTgbSNU4nJcqtcWcxRFnp6Sy8c
         WDfqKXNQbFYezasfbStBa1PmlPmVVfqycA14FDd/GOhr+wdic7/7C6wkvHPyStT5vrQc
         GUMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=OF/MFn2RYZUqEg593eJ/PysigzeOI7gs8bHHT/DLPHw=;
        b=Elka00QDW/p33Lm66tUdakf6MXC/ionPxCExBOmflfH3EqIkX5/zeWUgusTjr70iqv
         yKVHpYW4RJorPaaSxw2VzNZyCpjJ7L95jwidFoIWigaGKwbj1fwvv5DQM9Z5BgCYMfuL
         Wgtt5XK6TJkca/94Hf2J9OXx/p+mshYOCYisOFZ1IPOotWcYXjvOY/wNXaC/B1AG1DWg
         BOrQvSM+xLN9CaA1OUKrR9z0Ysm1S5DAoQvpBDuauhilCRG0PgCR00Hn7EMACj6qIHn/
         HdYVeCHI3s+WZ108fMqnDqi813G7902iU69Q1SrQaz0LhVbyg9F6be5Ng6TBaEK38b0Y
         rqMg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id t17si6988767lfl.65.2019.02.28.00.35.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 00:35:47 -0800 (PST)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12] (helo=i7.sw.ru)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1gzHAK-0008R2-BB; Thu, 28 Feb 2019 11:35:40 +0300
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Rik van Riel <riel@surriel.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Michal Hocko <mhocko@kernel.org>,
	Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH v2 4/4] mm/vmscan: remove unused lru_pages argument
Date: Thu, 28 Feb 2019 11:33:29 +0300
Message-Id: <20190228083329.31892-4-aryabinin@virtuozzo.com>
X-Mailer: git-send-email 2.19.2
In-Reply-To: <20190228083329.31892-1-aryabinin@virtuozzo.com>
References: <20190228083329.31892-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since commit 9092c71bb724 ("mm: use sc->priority for slab shrink targets")
the argument 'unsigned long *lru_pages' passed around with no purpose.
Remove it.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Rik van Riel <riel@surriel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
---

Changes since v1:
 - Changelog update
 - Added acks

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

