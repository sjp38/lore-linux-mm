Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A19DEC10F02
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 18:14:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 54C96222BE
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 18:14:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="a5f7aXi3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 54C96222BE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E4F728E0007; Fri, 15 Feb 2019 13:14:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DFF258E0004; Fri, 15 Feb 2019 13:14:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC8CF8E0007; Fri, 15 Feb 2019 13:14:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id A95928E0004
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 13:14:37 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id 8so6351060ybu.14
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 10:14:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=GjS/0oY9wwLINvtO7eIortkRmYdX1ic59VaG6ceBez0=;
        b=MBDf5X2lhifbE6sxX1+u3d0EFAURH2dVfqRXzsXsGV2TjPPmfJ6YW+kf580VVSkMy9
         lGPLZv0MWdQXrSvh2tUjBmpNr4gjdxShB0NqerFRM0oIX/GEDmXwXQ6RQjO1/0ByeS89
         oDx22lB+jjcfSJJyzPl/z6otOnFa6ZKeaTpG7BAOZwAmvsXq/DmnnHJyf8VeZ2D5exXI
         ahxlNMF0HCLKCQLy6FajwDBwQPeDOYi2d3qCgE5y4zzS1sroYKwwvqPV9Q8gIoR/KVdr
         rmPEgEx1Aqwwd/1W3DBLS/xZlZI4jBDPqVcj5PLg9CK4oMPArE7SNwh4ai3tiGvs2O8t
         t9/Q==
X-Gm-Message-State: AHQUAuY1kxuzhxNghREgWRHafUU4ZKVaLlJtRAkT/3HO4B1NuBtRkXQg
	vVVZZSrIJz5eypoU475T9Lf+NvXWcbrfnccW2xKuJipH+dYuL6ZCKqiFk4M2xgoc15bFR3rkNN5
	tknpf4KgPwZRy1NHarlV4ishaho2LZU2jgytZpac/liLBh+giFi4KItBsPhMO/hM31npBCbr/Eq
	Wclq6FbHbaQSfdevXOS5gND/4R9nhO/+JPs+0GdFoPLN237lMl+icjG7rkRFIGB3cd7HM4pnIcw
	5DKlMjsswpgnBlSyaV4lSFTiMBqAK9HoUS9tOavepRahVFIj/Y7JSiK9V+UnPqM5oScXRZcynwQ
	Np4cPkKuVEZDRzN4rjjZLBzHO/hjKsMbJowSGAVFFNW1SOm0QHNn+UjAjhOK9Jwl+FGO7zlnx08
	+
X-Received: by 2002:a81:594:: with SMTP id 142mr9310716ywf.294.1550254477424;
        Fri, 15 Feb 2019 10:14:37 -0800 (PST)
X-Received: by 2002:a81:594:: with SMTP id 142mr9310658ywf.294.1550254476686;
        Fri, 15 Feb 2019 10:14:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550254476; cv=none;
        d=google.com; s=arc-20160816;
        b=SW7wNzdaSqi72BFAgiyI8SV1tzp9PDE8irNLcb2J0ByHi2u14xbLxEhpiJjDp9I+Ef
         HQss4pkVV7Zg4WLIJNvKsAK9yqAwODg0ZkgO2e3SI7gDI8+OgjRwjsL5yOhIoqjzRxLu
         aN8ew9mNx2hff6wDmXTAXxOq2dpglMKnV+VkPXVyrFTI7Pw1xa+8+N8TkzlT6nkY4y1c
         UcDbpbkxk/qFaYSh11M1nobXoNde9JqR3Q5nKAhoe6H53sHqzMZE4YoqKwnoJhdEETrz
         eq4r3KuS3bL5qnHMEJrXfsxEaQ4K/r1CFFPj7O1SZ6+1c+mO+FkNgX+YEWMfOUzSQhll
         TiNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=GjS/0oY9wwLINvtO7eIortkRmYdX1ic59VaG6ceBez0=;
        b=eUSJMXjtDPpEy4tkhrxS+aiY1EW7Ep/OTYSkvrFxvkfBqDTRJ3zJQqcqRksmkjaPGQ
         ycp370ANTJVlStN3se4pBBlVnFoyrhMfG5s7LN2kpPhODpiTqYLzBnnvtx7VGxfH4Ka2
         HFwZF+NhNskqZMreoV+fg+yhz7zhU+tALnpRnS0XfVQFCR9LChyGmNtNJ3NzpZ2QnF4N
         bH9Trnq+1eyRN4g27ofXrVdcaaHG0vfpwd1hhF6g3SAidE3e0cMaArDiHRbPhhF9IMRy
         aXveIghGzN5K/38vZozmaHTcZOhbAGhwMMcWDDeuqFlTs491ABowBMEPfl7qt5ZUSghN
         wPaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=a5f7aXi3;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k126sor901778ywd.120.2019.02.15.10.14.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Feb 2019 10:14:36 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=a5f7aXi3;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=GjS/0oY9wwLINvtO7eIortkRmYdX1ic59VaG6ceBez0=;
        b=a5f7aXi3TT8/yuiVA43lpvDIByTjBfBUd1PDUinv5LHcx+bFHBP4zO587KDnz0R/kN
         TEoZi1rdgOC3047+bHpcrBiAyVPsAPpTsKs6ewUl4TSe+/djHoSAr49wBwzffHjBEozt
         TnJYNfBu0e4kntec1YDy2OAqtaeZcg/lE8fbplc082JcDj8VE+pkZDse/RdBl6Ytp4XH
         iCHkx6yRCbA2d5bNwB9lltewmxn/sWkbXfbHjeca79jqED5sY10/KFYwhdbD6DQsbD5y
         09455famEavd9FgM96WVtwZi1U2BMJDMXcLQE+Is5EDN46bvB8wa3n+qaJOXAV/3m0MM
         2YCg==
X-Google-Smtp-Source: AHgI3IaTs3l6l3o0r57AsapVmdI1i/rDDUCcCVFJ3a4eYlNp4dSi6HTTnSBprSZTOVICUY1w6xMeGw==
X-Received: by 2002:a81:1cc1:: with SMTP id c184mr9371591ywc.360.1550254476411;
        Fri, 15 Feb 2019 10:14:36 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::4:33c1])
        by smtp.gmail.com with ESMTPSA id n67sm2023613ywn.1.2019.02.15.10.14.35
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Feb 2019 10:14:35 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 4/6] mm: memcontrol: push down mem_cgroup_node_nr_lru_pages()
Date: Fri, 15 Feb 2019 13:14:23 -0500
Message-Id: <20190215181425.32624-5-hannes@cmpxchg.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190215181425.32624-1-hannes@cmpxchg.org>
References: <20190215181425.32624-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

mem_cgroup_node_nr_lru_pages() is just a convenience wrapper around
lruvec_page_state() that takes bitmasks of lru indexes and aggregates
the counts for those.

Replace callsites where the bitmask is simple enough with direct
lruvec_page_state() calls.

This removes the last extern user of mem_cgroup_node_nr_lru_pages(),
so make that function private again, too.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h | 10 ----------
 mm/memcontrol.c            | 10 +++++++---
 mm/workingset.c            |  5 +++--
 3 files changed, 10 insertions(+), 15 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 206090de5d7c..6bf06b9d0260 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -496,9 +496,6 @@ int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
 void mem_cgroup_update_lru_size(struct lruvec *lruvec, enum lru_list lru,
 		int zid, int nr_pages);
 
-unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
-					   int nid, unsigned int lru_mask);
-
 static inline
 unsigned long mem_cgroup_get_zone_lru_size(struct lruvec *lruvec,
 		enum lru_list lru, int zone_idx)
@@ -941,13 +938,6 @@ unsigned long mem_cgroup_get_zone_lru_size(struct lruvec *lruvec,
 	return 0;
 }
 
-static inline unsigned long
-mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
-			     int nid, unsigned int lru_mask)
-{
-	return 0;
-}
-
 static inline unsigned long mem_cgroup_get_max(struct mem_cgroup *memcg)
 {
 	return 0;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4d573f4e1759..73eb8333bc73 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -718,7 +718,7 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
 	__this_cpu_add(memcg->stat_cpu->nr_page_events, nr_pages);
 }
 
-unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
+static unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
 					   int nid, unsigned int lru_mask)
 {
 	struct lruvec *lruvec = mem_cgroup_lruvec(NODE_DATA(nid), memcg);
@@ -1413,11 +1413,15 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 static bool test_mem_cgroup_node_reclaimable(struct mem_cgroup *memcg,
 		int nid, bool noswap)
 {
-	if (mem_cgroup_node_nr_lru_pages(memcg, nid, LRU_ALL_FILE))
+	struct lruvec *lruvec = mem_cgroup_lruvec(NODE_DATA(nid), memcg);
+
+	if (lruvec_page_state(lruvec, NR_INACTIVE_FILE) ||
+	    lruvec_page_state(lruvec, NR_ACTIVE_FILE))
 		return true;
 	if (noswap || !total_swap_pages)
 		return false;
-	if (mem_cgroup_node_nr_lru_pages(memcg, nid, LRU_ALL_ANON))
+	if (lruvec_page_state(lruvec, NR_INACTIVE_ANON) ||
+	    lruvec_page_state(lruvec, NR_ACTIVE_ANON))
 		return true;
 	return false;
 
diff --git a/mm/workingset.c b/mm/workingset.c
index dcb994f2acc2..dbc333a21254 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -427,10 +427,11 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
 #ifdef CONFIG_MEMCG
 	if (sc->memcg) {
 		struct lruvec *lruvec;
+		int i;
 
-		pages = mem_cgroup_node_nr_lru_pages(sc->memcg, sc->nid,
-						     LRU_ALL);
 		lruvec = mem_cgroup_lruvec(NODE_DATA(sc->nid), sc->memcg);
+		for (pages = 0, i = 0; i < NR_LRU_LISTS; i++)
+			pages += lruvec_page_state(lruvec, NR_LRU_BASE + i);
 		pages += lruvec_page_state(lruvec, NR_SLAB_RECLAIMABLE);
 		pages += lruvec_page_state(lruvec, NR_SLAB_UNRECLAIMABLE);
 	} else
-- 
2.20.1

