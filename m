Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	T_DKIMWL_WL_HIGH,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9EF6C04AAB
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 05:34:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6DA9021479
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 05:34:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="U8Y2cIYh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DA9021479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E27916B000A; Tue,  7 May 2019 01:34:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D88A46B000C; Tue,  7 May 2019 01:34:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C782C6B000D; Tue,  7 May 2019 01:34:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 88E616B000A
	for <linux-mm@kvack.org>; Tue,  7 May 2019 01:34:27 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id l16so4525422pfb.23
        for <linux-mm@kvack.org>; Mon, 06 May 2019 22:34:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=7kdNaMdAyg43kZJrGibJ3orTG116ljc1+tmlXiXDI74=;
        b=iZZFLYzXjeZVH3JBdAa+xTE5QVH3Ue/XRzf6UEHQL1p74c5BZ5MeGGKAH6lXyH687O
         VKdr8I5GdAyOXdtGXSI1CiuXAddWDmxNjgqPdr8GNvMbA/AXcZdJJSLkz6u9Gb7uQeay
         6+g/hrh6JOtOaDMH1mrZZ5SEFgNGyJe1BQmm6C67stD4LLSHQvVnowL7GegjvPhqQy0y
         9UU54qlcyg7po8d0rzFKzrxcTj5LbjrB4y+qWVV2x430cbxdhYNfkG2kWlNiCXGzzYem
         GcrSXtp9FzfVAhFb9kRcBvvVI/R+nVT+fhNvsAYrLyqgcZtsBQLJKBRrFsdCZ9hbHFxB
         4SBw==
X-Gm-Message-State: APjAAAWaptpToSxWRFpyxjsilT4Q8YAvQpuYjQAmaNshcrSuVxKM1fQn
	46BK6aslZOQAwX/79yyABbOO9XlbBligsQA3oPgt+QFLQQNXF4mUF/lMgNevWCCAWBuDffi6vY8
	8MJvCphgbzuzlPa/bJyEfqwCL0GUisBuQjJ1DEZCryQRsqJyE3vUKlS1HUD2hwSTgeA==
X-Received: by 2002:a63:d908:: with SMTP id r8mr37879676pgg.268.1557207267005;
        Mon, 06 May 2019 22:34:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzvx24tXSXVLoCXVGxzdRXf2pB+MIM7BoC89U8oi8zpsAIPFQqJp4NsJoVB5Q3yeG+w+SAa
X-Received: by 2002:a63:d908:: with SMTP id r8mr37879625pgg.268.1557207266231;
        Mon, 06 May 2019 22:34:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557207266; cv=none;
        d=google.com; s=arc-20160816;
        b=m5qa9EHbFfm35upPLI504+DvLWSV0Dat4ZMLwj46IS+XguaBelvy5hRXHVFH2LojgQ
         dnovXH5lWsJnbDRyfhDgU68GRaqwwkdPz96WOuvmMhBWN1cBRUl752kI8Uo7VIc3rQ/s
         R+1Qn2Q5oTqNdloDizyOseaXXpZrZrG/GcceWjR7dhx2BO+VwnVyNvkw5GAwKOamBflT
         rh4p4W7oampUGzALDJK+XTE7ltqqnd/HXmRqomGNawBQnP7lY1Jd6w3V7+yQxSoKbXqr
         KOtJsa82Kd19JBN8umOoJZvXapOsJlqpLeXYRNjvNgUvAJ+QMdFJodoBFT2ndeMdBdKV
         FXDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=7kdNaMdAyg43kZJrGibJ3orTG116ljc1+tmlXiXDI74=;
        b=d8uhatla8YaVc13gQuPLw8cnvValKLVW+v0ASfUIZBENHoBsrYBywBR61rDhPKzC9z
         g6HSC1SLNKtw283KZO9RwTkltzsQdR3nHM0Jct7JTNhRRINPH9nSX2KilKUy//eTUrHK
         IFiTDPdCtZ9bCsjXfV+DLeel9UzdEjH+MchjbRNElxHRIMV6hmA519XTcT/+nvz0JW5c
         jlbuK+nKIeutrOutfeK15SHU2kwfehZb0djD5KjR5KpNEkbAgjOl9/pezbgdnmy0XmRi
         4nmruKepRDXUG9AQLsTo1qBP76vo3qUysRGFaA2UNNkqYddxguOtXh6HKqNVOjSnMkYT
         KtVw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=U8Y2cIYh;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w21si15323019pgk.170.2019.05.06.22.34.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 22:34:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=U8Y2cIYh;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D02F22087F;
	Tue,  7 May 2019 05:34:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557207265;
	bh=Z70QKsPD3e3mToKCe29V3EsQvz2CP06bSc4T9mz6NSg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=U8Y2cIYhPozZhD5z/fvTjnBgJi7DaPFsIatp1ut9gnoLwSL+dyOiXIL53tX900YVf
	 6Z7RgU3v2FT67S2Io3pnyWaoCUt8jLUTsSLZdE6wNqd4jZMtbZzTBZdR+AzKSJt+lq
	 SytGeXsj4A5N6NECLXHbYsrm54FPfiWoWJXNhFbw=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Shakeel Butt <shakeelb@google.com>,
	Roman Gushchin <guro@fb.com>,
	Michal Hocko <mhocko@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.0 58/99] mm: fix inactive list balancing between NUMA nodes and cgroups
Date: Tue,  7 May 2019 01:31:52 -0400
Message-Id: <20190507053235.29900-58-sashal@kernel.org>
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

From: Johannes Weiner <hannes@cmpxchg.org>

[ Upstream commit 3b991208b897f52507168374033771a984b947b1 ]

During !CONFIG_CGROUP reclaim, we expand the inactive list size if it's
thrashing on the node that is about to be reclaimed.  But when cgroups
are enabled, we suddenly ignore the node scope and use the cgroup scope
only.  The result is that pressure bleeds between NUMA nodes depending
on whether cgroups are merely compiled into Linux.  This behavioral
difference is unexpected and undesirable.

When the refault adaptivity of the inactive list was first introduced,
there were no statistics at the lruvec level - the intersection of node
and memcg - so it was better than nothing.

But now that we have that infrastructure, use lruvec_page_state() to
make the list balancing decision always NUMA aware.

[hannes@cmpxchg.org: fix bisection hole]
  Link: http://lkml.kernel.org/r/20190417155241.GB23013@cmpxchg.org
Link: http://lkml.kernel.org/r/20190412144438.2645-1-hannes@cmpxchg.org
Fixes: 2a2e48854d70 ("mm: vmscan: fix IO/refault regression in cache workingset transition")
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Shakeel Butt <shakeelb@google.com>
Cc: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/vmscan.c | 29 +++++++++--------------------
 1 file changed, 9 insertions(+), 20 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index e979705bbf32..022afabac3f6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2199,7 +2199,6 @@ static void shrink_active_list(unsigned long nr_to_scan,
  *   10TB     320        32GB
  */
 static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
-				 struct mem_cgroup *memcg,
 				 struct scan_control *sc, bool actual_reclaim)
 {
 	enum lru_list active_lru = file * LRU_FILE + LRU_ACTIVE;
@@ -2220,16 +2219,12 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 	inactive = lruvec_lru_size(lruvec, inactive_lru, sc->reclaim_idx);
 	active = lruvec_lru_size(lruvec, active_lru, sc->reclaim_idx);
 
-	if (memcg)
-		refaults = memcg_page_state(memcg, WORKINGSET_ACTIVATE);
-	else
-		refaults = node_page_state(pgdat, WORKINGSET_ACTIVATE);
-
 	/*
 	 * When refaults are being observed, it means a new workingset
 	 * is being established. Disable active list protection to get
 	 * rid of the stale workingset quickly.
 	 */
+	refaults = lruvec_page_state(lruvec, WORKINGSET_ACTIVATE);
 	if (file && actual_reclaim && lruvec->refaults != refaults) {
 		inactive_ratio = 0;
 	} else {
@@ -2250,12 +2245,10 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 }
 
 static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
-				 struct lruvec *lruvec, struct mem_cgroup *memcg,
-				 struct scan_control *sc)
+				 struct lruvec *lruvec, struct scan_control *sc)
 {
 	if (is_active_lru(lru)) {
-		if (inactive_list_is_low(lruvec, is_file_lru(lru),
-					 memcg, sc, true))
+		if (inactive_list_is_low(lruvec, is_file_lru(lru), sc, true))
 			shrink_active_list(nr_to_scan, lruvec, sc, lru);
 		return 0;
 	}
@@ -2355,7 +2348,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 			 * anonymous pages on the LRU in eligible zones.
 			 * Otherwise, the small LRU gets thrashed.
 			 */
-			if (!inactive_list_is_low(lruvec, false, memcg, sc, false) &&
+			if (!inactive_list_is_low(lruvec, false, sc, false) &&
 			    lruvec_lru_size(lruvec, LRU_INACTIVE_ANON, sc->reclaim_idx)
 					>> sc->priority) {
 				scan_balance = SCAN_ANON;
@@ -2373,7 +2366,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	 * lruvec even if it has plenty of old anonymous pages unless the
 	 * system is under heavy pressure.
 	 */
-	if (!inactive_list_is_low(lruvec, true, memcg, sc, false) &&
+	if (!inactive_list_is_low(lruvec, true, sc, false) &&
 	    lruvec_lru_size(lruvec, LRU_INACTIVE_FILE, sc->reclaim_idx) >> sc->priority) {
 		scan_balance = SCAN_FILE;
 		goto out;
@@ -2526,7 +2519,7 @@ static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memc
 				nr[lru] -= nr_to_scan;
 
 				nr_reclaimed += shrink_list(lru, nr_to_scan,
-							    lruvec, memcg, sc);
+							    lruvec, sc);
 			}
 		}
 
@@ -2593,7 +2586,7 @@ static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memc
 	 * Even if we did not try to evict anon pages at all, we want to
 	 * rebalance the anon lru active/inactive ratio.
 	 */
-	if (inactive_list_is_low(lruvec, false, memcg, sc, true))
+	if (inactive_list_is_low(lruvec, false, sc, true))
 		shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
 				   sc, LRU_ACTIVE_ANON);
 }
@@ -2993,12 +2986,8 @@ static void snapshot_refaults(struct mem_cgroup *root_memcg, pg_data_t *pgdat)
 		unsigned long refaults;
 		struct lruvec *lruvec;
 
-		if (memcg)
-			refaults = memcg_page_state(memcg, WORKINGSET_ACTIVATE);
-		else
-			refaults = node_page_state(pgdat, WORKINGSET_ACTIVATE);
-
 		lruvec = mem_cgroup_lruvec(pgdat, memcg);
+		refaults = lruvec_page_state(lruvec, WORKINGSET_ACTIVATE);
 		lruvec->refaults = refaults;
 	} while ((memcg = mem_cgroup_iter(root_memcg, memcg, NULL)));
 }
@@ -3363,7 +3352,7 @@ static void age_active_anon(struct pglist_data *pgdat,
 	do {
 		struct lruvec *lruvec = mem_cgroup_lruvec(pgdat, memcg);
 
-		if (inactive_list_is_low(lruvec, false, memcg, sc, true))
+		if (inactive_list_is_low(lruvec, false, sc, true))
 			shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
 					   sc, LRU_ACTIVE_ANON);
 
-- 
2.20.1

