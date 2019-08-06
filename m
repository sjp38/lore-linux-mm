Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,URIBL_SBL,URIBL_SBL_A,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31446C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 07:19:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC9EB216F4
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 07:19:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="KPZFZE6q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC9EB216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 71FE66B0003; Tue,  6 Aug 2019 03:19:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6CFC76B0005; Tue,  6 Aug 2019 03:19:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 59A0A6B0006; Tue,  6 Aug 2019 03:19:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 214A96B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 03:19:20 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id j96so1914656plb.5
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 00:19:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=MAIbBO7RnF45YFDLIObLMdHkYfMkSRCxrdUY/DRrsJc=;
        b=loONgmiqoBVIvqP85VKFC7OlKQwSb8QS+m7UwbvsYYutqLK5MM24xtfabk1ak2CS+D
         rfyUFep7AUknDIF2NOld27DPzDJdgd9EUoThAa1YvGApGdGV8kunovTm4nLZbHyft8XN
         td6tW84o9rGCA7nBVOnxzB8mH1yjAyTWzM2vADLuHJv51JdGSNRmU8Xr6JS3oHYNIUGD
         ulqBRWVhMWGCF3l+91QrCfnyG2CyBrdyUuIbKaMX8neOL2yNgGcJHTdtc3HTEZ5hSF86
         UAtmefXZNboFD6xJEdvbrMeL4Iq7+MGpVWt/HoBTsggAOmmnXmitoFxSXq7NKzupWWHj
         kihg==
X-Gm-Message-State: APjAAAVfbNDLC0m5JhGYXuCrXl0V3C2BS3CGjA3my7xtrF6OJolBYIu5
	6Z7Ei9PGfgqROOid9NC6HKj0pelu5hQM1j2sfnxiO7JgWcK4BWw4xOeUhocOHYbeOa+O6qCDFxb
	Q11xLSPg4/lCDRwXGlkebA+mm2P5Iv90zGQACkv5PlxGgc83jz3ScmMaaXcqn6vpevg==
X-Received: by 2002:a17:90a:1b48:: with SMTP id q66mr1646107pjq.83.1565075959739;
        Tue, 06 Aug 2019 00:19:19 -0700 (PDT)
X-Received: by 2002:a17:90a:1b48:: with SMTP id q66mr1646072pjq.83.1565075958938;
        Tue, 06 Aug 2019 00:19:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565075958; cv=none;
        d=google.com; s=arc-20160816;
        b=e7xXzr27SV+jDpFggvon5TaW8yeMF1o5MOSlo6aJDqkcqI8g40mBy+9cFwKT/W52FT
         15Wlbvt0zh5YRkHMXlbwMO6rsF8FKPQxWf7+2EEPGkz2LkkapsugcV6+Jb+VuRO+ZREU
         /ixdzruzsTz1xnHv/520Q/K0GXv9m45pPz1KXZuG6x0Rm9aKg6ykbL+MJd+9d6Rcj7US
         p0DoAazDHJ/KpkHQUubWc6PD4jnIdFJaxBDqJgTMbxWFdFIyZi48Kda7G0J8NZ6dAddC
         72Ia7/R4NXMVRpkGtmJBYnav+Asj/PPPL5LqBKxtIpVmE2oQl/AN2AVy7g/bGGgE748Z
         ljmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=MAIbBO7RnF45YFDLIObLMdHkYfMkSRCxrdUY/DRrsJc=;
        b=W8PWeFHW1a0ZyrzyxBMGCgRZMPiJXZbBJONgGcixAi/XU6x4pEDPE1/TQwAyNqOqct
         ZyBUH+0JncP3kRQlg2CTBJlJq8n2ZiVBIa5enq3wXmUE6LLmIzRi08v63+Z+ZDt5BLWE
         ZANOmzDQ/zC0hUKs/k+FXQwdE2vNMnSaLMYJmN/UCG3c+w60jIpghWNKBe9+H0Ydem7b
         SxEgG42GwspLXuyhejYfC4FLSM710hrZqrEqIjuo3b1naCcfBLwfXakhjy4wKgC/OzqQ
         E2TZdZ7sG7UG7Y7J2Hx2hTRpOWTkrh4WzJRZ7Vlke3qPwJ2rjpRd4uaNQg3IGNdvkhPI
         z4zA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=KPZFZE6q;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e10sor10683221pgt.62.2019.08.06.00.19.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 00:19:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=KPZFZE6q;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=MAIbBO7RnF45YFDLIObLMdHkYfMkSRCxrdUY/DRrsJc=;
        b=KPZFZE6qGJg8WynNV3ZB2N9Jj+mk42WcaL6PP9UAkm/q2EOr7ZWVir+fWB7WJc3daU
         DlScyin8Tsn+mY9SKJYoQxoi9lNc4/T+opez4JUJdCevqXugEttGaLqv1M9lCQZYQNWt
         U9HoNr4/7n/SzwXZoMfOETupaQ3ZdEShXvlQgc7XSXUhODT3iWwaHybSgCxisWP1cVNr
         P++2+14D9UOiht8OP0ml8x9jWZ98e8eqqbiehysJfk4El/KRlKxUwCrmiHARZoMxsgKO
         Lxodb95K0f9nsLAeFwU2fWJ6gyCYkZQZQUe2zXZBv06kPduRc+UvAdW5zx21teNeobUL
         dm8A==
X-Google-Smtp-Source: APXvYqwd8S8EZ0Fi6sy0vXFg+OcvWsHiqyuQOAX/BjqtaukX8QAvrPKDllb6d65D2Nr1yl6yzbHfoQ==
X-Received: by 2002:a63:1743:: with SMTP id 3mr1677617pgx.435.1565075958444;
        Tue, 06 Aug 2019 00:19:18 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id o12sm15576999pjr.22.2019.08.06.00.19.15
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 00:19:17 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	Yafang Shao <laoar.shao@gmail.com>,
	Daniel Jordan <daniel.m.jordan@oracle.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Christoph Lameter <cl@linux.com>,
	Michal Hocko <mhocko@kernel.org>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: [PATCH v2] mm/vmscan: shrink slab in node reclaim
Date: Tue,  6 Aug 2019 03:19:00 -0400
Message-Id: <1565075940-23121-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In the node reclaim, may_shrinkslab is 0 by default,
hence shrink_slab will never be performed in it.
While shrik_slab should be performed if the relcaimable slab is over
min slab limit.

Add scan_control::no_pagecache so shrink_node can decide to reclaim page
cache, slab, or both as dictated by min_unmapped_pages and min_slab_pages.
shrink_node will do at least one of the two because otherwise node_reclaim
returns early.

__node_reclaim can detect when enough slab has been reclaimed because
sc.reclaim_state.reclaimed_slab will tell us how many pages are
reclaimed in shrink slab.

This issue is very easy to produce, first you continuously cat a random
non-exist file to produce more and more dentry, then you read big file
to produce page cache. And finally you will find that the denty will
never be shrunk in node reclaim (they can only be shrunk in kswapd until
the watermark is reached).

Regarding vm.zone_reclaim_mode, we always set it to zero to disable node
reclaim. Someone may prefer to enable it if their different workloads work
on different nodes.

[Daniel improved the changelog]

Fixes: 1c30844d2dfe ("mm: reclaim small amounts of memory when an external fragmentation event occurs")
Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Christoph Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Yafang Shao <shaoyafang@didiglobal.com>
---
 mm/vmscan.c | 27 +++++++++++++++++----------
 1 file changed, 17 insertions(+), 10 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 47aa215..7e2a8ac 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -91,6 +91,9 @@ struct scan_control {
 	/* e.g. boosted watermark reclaim leaves slabs alone */
 	unsigned int may_shrinkslab:1;
 
+	/* In node reclaim mode, we may shrink slab only */
+	unsigned int no_pagecache:1;
+
 	/*
 	 * Cgroups are not reclaimed below their configured memory.low,
 	 * unless we threaten to OOM. If any cgroups are skipped due to
@@ -2831,7 +2834,9 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 
 			reclaimed = sc->nr_reclaimed;
 			scanned = sc->nr_scanned;
-			shrink_node_memcg(pgdat, memcg, sc);
+
+			if (!sc->no_pagecache)
+				shrink_node_memcg(pgdat, memcg, sc);
 
 			if (sc->may_shrinkslab) {
 				shrink_slab(sc->gfp_mask, pgdat->node_id,
@@ -4268,6 +4273,10 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 		.may_writepage = !!(node_reclaim_mode & RECLAIM_WRITE),
 		.may_unmap = !!(node_reclaim_mode & RECLAIM_UNMAP),
 		.may_swap = 1,
+		.may_shrinkslab = (node_page_state(pgdat, NR_SLAB_RECLAIMABLE) >
+				   pgdat->min_slab_pages),
+		.no_pagecache = (node_pagecache_reclaimable(pgdat) <=
+				  pgdat->min_unmapped_pages),
 		.reclaim_idx = gfp_zone(gfp_mask),
 	};
 
@@ -4285,15 +4294,13 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 	p->flags |= PF_SWAPWRITE;
 	set_task_reclaim_state(p, &sc.reclaim_state);
 
-	if (node_pagecache_reclaimable(pgdat) > pgdat->min_unmapped_pages) {
-		/*
-		 * Free memory by calling shrink node with increasing
-		 * priorities until we have enough memory freed.
-		 */
-		do {
-			shrink_node(pgdat, &sc);
-		} while (sc.nr_reclaimed < nr_pages && --sc.priority >= 0);
-	}
+	/*
+	 * Free memory by calling shrink node with increasing
+	 * priorities until we have enough memory freed.
+	 */
+	do {
+		shrink_node(pgdat, &sc);
+	} while (sc.nr_reclaimed < nr_pages && --sc.priority >= 0);
 
 	set_task_reclaim_state(p, NULL);
 	current->flags &= ~PF_SWAPWRITE;
-- 
1.8.3.1

