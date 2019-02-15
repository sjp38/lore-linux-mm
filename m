Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DAEACC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 18:14:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D5712192C
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 18:14:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="T68qNAfX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D5712192C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99B5F8E0001; Fri, 15 Feb 2019 13:14:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 794C18E0006; Fri, 15 Feb 2019 13:14:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 688318E0001; Fri, 15 Feb 2019 13:14:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4063E8E0004
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 13:14:34 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id 67so6267678ybm.23
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 10:14:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0Mi2kL/2WsC77PZT2+GFY8rm4/RmpjTroxvb9aqMFLo=;
        b=F5BBDArJytM3MEGmWhMLgibcjKUuOxUKd6Za04nYppoKH7KnzGcyhkmjfdP5+NZR4S
         SdlOaVHy6cmpge6N1YpdwXL8n3WsoxC7kZtCZ7qE6FYtb6tcobDLkan4cT6c1/luKd/E
         B9PsSy64PwDtMTGHbdukEjPZH/bS3XcNPGfB/Rk/EdfLtYY7TSpVGpeKS48QbVqAy2yv
         MeQ4fMWstFd6lhJlYHhikPIyTTskbGPI+UYxuEjeZgPdKVfF93bcbw2x+UTzEbH4fsD8
         9jiCpUYIq2wropXQVsplk5EdoLCw6yv3RhDfd4zyj3NEdgCcLpq7Jj9Seas7Mc5Z6zkt
         EXRA==
X-Gm-Message-State: AHQUAuYZ7Wc9wqio1nWVeDIpACWsX5sBSlCOclgC/DQ754uF49/avnyW
	sU6TTkaT2Ye3cF053JJH/jstbqhb7FxcmD6GypdN06MyBehDSOHIH5/SHe6G5k6LhITYGqDr617
	4BAvLztyEbCQIF6yXj+hH8xb4kH3GcJIcaOzIWcV/ZGsnxfjR1B38hgAuIl9L/q5mAd5wa1wRKy
	Ejc3WrepQZmBOE07VW8DHhuu+zbA1FTK+GXh/BPoORsTJVqOa457LtBiIgegozdWP1WJiR1p5Ac
	0jRpXJvsapNtWSe69uPZfVhIx+QzYOsG270nJAQ5GhdzGpjEi9jU9GYFmd2lT6njVzmY9QMKAu3
	3xs/gOhJrp2OfbXdKwaddnan8biZuJVmsxFVNQMwzPGE6Y9JaZ87L6QQlTiX2oiR5049beqZyYv
	V
X-Received: by 2002:a25:bec2:: with SMTP id k2mr9212625ybm.328.1550254473991;
        Fri, 15 Feb 2019 10:14:33 -0800 (PST)
X-Received: by 2002:a25:bec2:: with SMTP id k2mr9212571ybm.328.1550254473275;
        Fri, 15 Feb 2019 10:14:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550254473; cv=none;
        d=google.com; s=arc-20160816;
        b=NTAda0OKXM53NvSNour8cjk+wfe3dP/QnPg6jxE1nXXUi3jxpZ8UHdSviGcXWKI1Yx
         IEZNuoW9x4Rar7ZWyEjKhVyE/wEhM6GuvX+q/Hqxlln1a8EliGQigu+8j3cTCmWaP5/D
         sUcJDaCBnznSywZXDLWPUCCa4V9y1lz86tyFDTTghxgb2HjT06j4QwRKjOVqCgiCTUU8
         u6Vmyps+zWXJptGai0KCoXVs8+HNF6PgN/cCpLd+qFtMZu2w9nWZe4pHYOsAGGglackz
         e+eSuDolr/vrUMI9tpOKTb4H6OhgLq9tKSqgb7ZT3N6Q8kR0Ko+60/HUrkKPMgI0vXCp
         CRAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=0Mi2kL/2WsC77PZT2+GFY8rm4/RmpjTroxvb9aqMFLo=;
        b=VPz58t/8uhaixamWws0wipuX2g3JsD1HGcCp9xxEgXfjgM7b0NLNopNWwcZu4G9PyG
         9BSYMJQHCge/7aFIVSEG8UmJ/Wqe97FfBpHgK2DvJmO4bQtnrVmbNpEW6ov8FYOfyy/6
         XnoEIHn9N55brxzHPoz0VW+SE2gn0TgsxSEy9cOekgMZAAfnmyGGX+VKAG9iSspMhKfl
         nXwSIEhcBDsUzyU/wCNI2//cJql4m6ZCQqRC5yi5RHP3MT4M9M0JSJcql0A41clnguwg
         35vnrB3ZtvOmPVaDQY6pyKQ+bbpmcwPKDcWKwQ59wJI+1IJz8o8JKrql9y45ExyhE3VU
         QVbA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=T68qNAfX;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d193sor1213764ywa.135.2019.02.15.10.14.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Feb 2019 10:14:33 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=T68qNAfX;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=0Mi2kL/2WsC77PZT2+GFY8rm4/RmpjTroxvb9aqMFLo=;
        b=T68qNAfXm8z8Lj+3Sujbvrk6lrgzOm9xtKSZ/IbmFiUVElTgSyqQ2V+u8V/D9scygU
         xxfD6Glf1ZjEFDVjQQL1tMksAEl64SR6rxg+DSZh4qQylcB+qKG7yvncHsUD6laSivYP
         yrEesjRu1nLQkP3oKWLthCKmAAhpLG/cLBDhHmDEZHhlsOsBcznvipgKZKTxTcWUSIlS
         3CGsUy80UjqzcUyhdj0RAav/iNiNe2XnpUFfM0WEFDf/Nju/TBXsm4AIq5xgFLVGyhme
         /L0ACh/CL4wCcQTp/ogKd2o1NGC+q+Wz6XVJ5SxvPfpO1E1z2MSsbYxU1mnLMYATxkqx
         ds+A==
X-Google-Smtp-Source: AHgI3IajdWAbqPOMknx8ni8lnxgBEq1c4triDMsgoY5L29gO6lYAJj0wzEH0Eefp7qQvohqB2OEqow==
X-Received: by 2002:a0d:d857:: with SMTP id a84mr9171114ywe.121.1550254473071;
        Fri, 15 Feb 2019 10:14:33 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::4:33c1])
        by smtp.gmail.com with ESMTPSA id j22sm1915679ywj.37.2019.02.15.10.14.32
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Feb 2019 10:14:32 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 2/6] mm: memcontrol: replace zone summing with lruvec_page_state()
Date: Fri, 15 Feb 2019 13:14:21 -0500
Message-Id: <20190215181425.32624-3-hannes@cmpxchg.org>
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

Instead of adding up the zone counters, use lruvec_page_state() to get
the node state directly. This is a bit cheaper and more stream-lined.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h | 18 ------------------
 mm/memcontrol.c            |  2 +-
 mm/vmscan.c                |  2 +-
 3 files changed, 2 insertions(+), 20 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 83ae11cbd12c..206090de5d7c 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -499,19 +499,6 @@ void mem_cgroup_update_lru_size(struct lruvec *lruvec, enum lru_list lru,
 unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
 					   int nid, unsigned int lru_mask);
 
-static inline
-unsigned long mem_cgroup_get_lru_size(struct lruvec *lruvec, enum lru_list lru)
-{
-	struct mem_cgroup_per_node *mz;
-	unsigned long nr_pages = 0;
-	int zid;
-
-	mz = container_of(lruvec, struct mem_cgroup_per_node, lruvec);
-	for (zid = 0; zid < MAX_NR_ZONES; zid++)
-		nr_pages += mz->lru_zone_size[zid][lru];
-	return nr_pages;
-}
-
 static inline
 unsigned long mem_cgroup_get_zone_lru_size(struct lruvec *lruvec,
 		enum lru_list lru, int zone_idx)
@@ -947,11 +934,6 @@ static inline bool mem_cgroup_online(struct mem_cgroup *memcg)
 	return true;
 }
 
-static inline unsigned long
-mem_cgroup_get_lru_size(struct lruvec *lruvec, enum lru_list lru)
-{
-	return 0;
-}
 static inline
 unsigned long mem_cgroup_get_zone_lru_size(struct lruvec *lruvec,
 		enum lru_list lru, int zone_idx)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index af7f18b32389..a04177f25758 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -730,7 +730,7 @@ unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
 	for_each_lru(lru) {
 		if (!(BIT(lru) & lru_mask))
 			continue;
-		nr += mem_cgroup_get_lru_size(lruvec, lru);
+		nr += lruvec_page_state(lruvec, NR_LRU_BASE + lru);
 	}
 	return nr;
 }
diff --git a/mm/vmscan.c b/mm/vmscan.c
index e979705bbf32..f88fef03fc04 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -346,7 +346,7 @@ unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru, int zone
 	int zid;
 
 	if (!mem_cgroup_disabled())
-		lru_size = mem_cgroup_get_lru_size(lruvec, lru);
+		lru_size = lruvec_page_state(lruvec, NR_LRU_BASE + lru);
 	else
 		lru_size = node_page_state(lruvec_pgdat(lruvec), NR_LRU_BASE + lru);
 
-- 
2.20.1

