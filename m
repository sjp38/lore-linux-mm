Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E36DC10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 03:58:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5728C2133D
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 03:58:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5728C2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE0426B0266; Wed, 10 Apr 2019 23:58:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E65776B0269; Wed, 10 Apr 2019 23:58:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D073E6B026A; Wed, 10 Apr 2019 23:58:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 944FA6B0266
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 23:58:21 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id b34so3218613pld.17
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 20:58:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=aomN1GPRo9IazHu+20Dhl0DXd62/KJuH2okPvztfYlE=;
        b=uVuNw7Hnd3VnH9/ywsTv0MKjHmfMs0+xVolGk0LVtuJPPcc/p5BSqNs8yMqXlfft1n
         cQH5S8ejmmXgnL4uFQJhtOjZ71KE1r2O6JT5jMy+CbUvWVaBBxWuGBCr9JRqSzuscs9s
         hkbAW/kmxkSnYBacaQYkJwf+mdS41gmTM3n35g2V3s8wqcMCKv+e28DtleuOaf6H2Fpm
         ApULKeH/8YCc6J7KDpKMynnNNbbwDdwZHyds3yV5VcGWbZahmWDamoFvs4eQFVV+KAAF
         tCopxcbswvhVTGmHFJB1QhmnZd9eC0woqq0pNRttOP664SXhob88Kuc0o++vJX2vizeE
         Xqfg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWoJp/tEmCx2X4IzB9RXWx6+65sQm9NdWKl012uNA2C9GxICwja
	TtiFvStCTHhjiysiqayUuCOyFkqgJV0qK0hlPVfckl/b9e3hx399Ib61XlzNVB89JlocerqGwkF
	J3WUP1tiY72aosOvy1Eb58feTcgE2IqRq+7kccTBsrOZ/9typmnTUeVfQeH451p1ihQ==
X-Received: by 2002:a63:5057:: with SMTP id q23mr45359278pgl.30.1554955101163;
        Wed, 10 Apr 2019 20:58:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzU6dXvYij1Ksi0pSNQVKtaEXqJ3NsZQINAbytbamRQFwGfuZK+NnenCF90we5adGhL4xj4
X-Received: by 2002:a63:5057:: with SMTP id q23mr45359214pgl.30.1554955099964;
        Wed, 10 Apr 2019 20:58:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554955099; cv=none;
        d=google.com; s=arc-20160816;
        b=eTAKoopg8rDPE3mghEn8NRowtMKSaP4zqJeNprtB5hJ75/afE/ZQuWTjowVh56agDu
         UbpuHxu6gxMxY9KsEkvsEAkfs7D9klo6GppLflOWyqlG3PTSrVwgAWHTCMsamWyQTKIc
         GlghcdUvO2eDlu/wie4ff41R01b2JU3YEuoCk/jYUtM7l7QDwFIyNtJThno/oNXkVG0q
         vLEseJYBVKG3McpPsEFXuoudkoQx9WIKCt9oOuvso+Xph1leFkfBDaQ4Jz1matiWsHNh
         DPUiJU/XauI/BnlYB0hoKrqqn6014nvkLA59T5/WWs/DI7VUpA3/zaIgSHSgSPgFhL+H
         Hidg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=aomN1GPRo9IazHu+20Dhl0DXd62/KJuH2okPvztfYlE=;
        b=h1+0PKGuPp7HnElH4Wp+N47VtRYewpNhT2IkXLt/bprvd9nTDQOxMvT3AJPOHZv8OV
         TW9xSjJYRzIMxNFlxuDVAUbNtSKoxDKLpEAll60Lz8hRcXqLUUZFhyflHYA7km8PAPfX
         WhL5j3tSax3oRrrpmqZKrHIqN8GJqQphejbS2AG1rh+rExR4NygZuS37UdJTTlK/+jFf
         U9mubHYRp7Tr6rS6uwPFMtOqd2xAbQdne5WxxWEtp/IatH0Vrh1XDizd2Fa7lnQRgI5H
         +kT47uxV66+fjRhVD/pyc6sr4xhdvTNsvgb4Qs8myxJkKwkQPAdIVVRHzd46CkFlKCC4
         LJgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-54.freemail.mail.aliyun.com (out30-54.freemail.mail.aliyun.com. [115.124.30.54])
        by mx.google.com with ESMTPS id l66si15104606pfi.62.2019.04.10.20.58.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 20:58:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) client-ip=115.124.30.54;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R861e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07486;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=15;SR=0;TI=SMTPD_---0TP0I5rB_1554955031;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TP0I5rB_1554955031)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 11 Apr 2019 11:57:23 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: mhocko@suse.com,
	mgorman@techsingularity.net,
	riel@surriel.com,
	hannes@cmpxchg.org,
	akpm@linux-foundation.org,
	dave.hansen@intel.com,
	keith.busch@intel.com,
	dan.j.williams@intel.com,
	fengguang.wu@intel.com,
	fan.du@intel.com,
	ying.huang@intel.com,
	ziy@nvidia.com
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v2 PATCH 7/9] mm: vmscan: check if the demote target node is contended or not
Date: Thu, 11 Apr 2019 11:56:57 +0800
Message-Id: <1554955019-29472-8-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When demoting to PMEM node, the target node may have memory pressure,
then the memory pressure may cause migrate_pages() fail.

If the failure is caused by memory pressure (i.e. returning -ENOMEM),
tag the node with PGDAT_CONTENDED.  The tag would be cleared once the
target node is balanced again.

Check if the target node is PGDAT_CONTENDED or not, if it is just skip
demotion.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 include/linux/mmzone.h |  3 +++
 mm/vmscan.c            | 28 ++++++++++++++++++++++++++++
 2 files changed, 31 insertions(+)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index fba7741..de534db 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -520,6 +520,9 @@ enum pgdat_flags {
 					 * many pages under writeback
 					 */
 	PGDAT_RECLAIM_LOCKED,		/* prevents concurrent reclaim */
+	PGDAT_CONTENDED,		/* the node has not enough free memory
+					 * available
+					 */
 };
 
 enum zone_flags {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 80cd624..50cde53 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1048,6 +1048,9 @@ static void page_check_dirty_writeback(struct page *page,
 
 static inline bool is_demote_ok(int nid, struct scan_control *sc)
 {
+	int node;
+	nodemask_t used_mask;
+
 	/* It is pointless to do demotion in memcg reclaim */
 	if (!global_reclaim(sc))
 		return false;
@@ -1060,6 +1063,13 @@ static inline bool is_demote_ok(int nid, struct scan_control *sc)
 	if (!has_cpuless_node_online())
 		return false;
 
+	/* Check if the demote target node is contended or not */
+	nodes_clear(used_mask);
+	node = find_next_best_node(nid, &used_mask, true);
+
+	if (test_bit(PGDAT_CONTENDED, &NODE_DATA(node)->flags))
+		return false;
+
 	return true;
 }
 
@@ -1502,6 +1512,10 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		nr_reclaimed += nr_succeeded;
 
 		if (err) {
+			if (err == -ENOMEM)
+				set_bit(PGDAT_CONTENDED,
+					&NODE_DATA(target_nid)->flags);
+
 			putback_movable_pages(&demote_pages);
 
 			list_splice(&ret_pages, &demote_pages);
@@ -2596,6 +2610,19 @@ static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memc
 		 * scan target and the percentage scanning already complete
 		 */
 		lru = (lru == LRU_FILE) ? LRU_BASE : LRU_FILE;
+
+		/*
+		 * The shrink_page_list() may find the demote target node is
+		 * contended, if so it doesn't make sense to scan anonymous
+		 * LRU again.
+		 *
+		 * Need check if swap is available or not too since demotion
+		 * may happen on swapless system.
+		 */
+		if (!is_demote_ok(pgdat->node_id, sc) &&
+		    (!sc->may_swap || mem_cgroup_get_nr_swap_pages(memcg) <= 0))
+			lru = LRU_FILE;
+
 		nr_scanned = targets[lru] - nr[lru];
 		nr[lru] = targets[lru] * (100 - percentage) / 100;
 		nr[lru] -= min(nr[lru], nr_scanned);
@@ -3458,6 +3485,7 @@ static void clear_pgdat_congested(pg_data_t *pgdat)
 	clear_bit(PGDAT_CONGESTED, &pgdat->flags);
 	clear_bit(PGDAT_DIRTY, &pgdat->flags);
 	clear_bit(PGDAT_WRITEBACK, &pgdat->flags);
+	clear_bit(PGDAT_CONTENDED, &pgdat->flags);
 }
 
 /*
-- 
1.8.3.1

