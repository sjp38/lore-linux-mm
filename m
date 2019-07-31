Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,URIBL_SBL,URIBL_SBL_A,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5940EC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 02:00:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 067FD20651
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 02:00:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="k+q+hA5Q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 067FD20651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A55F58E0003; Tue, 30 Jul 2019 22:00:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A06A68E0001; Tue, 30 Jul 2019 22:00:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F5E18E0003; Tue, 30 Jul 2019 22:00:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5BDC78E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 22:00:19 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id x19so41815561pgx.1
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 19:00:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=oCLOdBMgfCfLJi2/RWEeEeVaZTdV5EmVCrQBzvZ/uFM=;
        b=RA+y4UBrorhz55mimhv9UxE1F600Aqm1a8ot7K0PICn/w8yQmFHSFd4nInXzcS+lgF
         HtNCi9xz974Qalz64U3RAfBXmSQCb4QLTQGqIaTmHmxDFBsMQZ+Qk1QQyp0tWYJNwgbp
         cw6fn7aKl3R3TOPlAc6iemrfe1XHTZkWNHx02Q4zAuic4V+gb6MODabB9sgDIj0U3GsS
         sZrxjFKrDcl0VIAr82HlrS/0M/MkEXJiwpB1ym/X0Vd747GlnyqN1uVaQOu1aYUR7nkM
         7ugwBv0N/VSxIXnvz/Xw7mnDLC/FyUXeb0SX0IvZIyEf4sv6htCRInN8g+A5Y3WFNSMi
         7zpg==
X-Gm-Message-State: APjAAAXPu5psjYatXX1ZO9Z76ZKzb0VVwwKVxZ3KrEAKcbYdABEzrlqd
	gV9FFeVHy05ENLebu9ufCFA8cchSAKS/80S8gRwTa+FdWRA9iKGwSpPuY99AZoLGSxvzFAolcrq
	bKHI3PjYCe4y0McGvQ4B1FiAMi7AFRtQ2U6HgA7exySXxUl5TjvyH2Wy5XbTQksBmTQ==
X-Received: by 2002:a63:553:: with SMTP id 80mr114619664pgf.280.1564538418751;
        Tue, 30 Jul 2019 19:00:18 -0700 (PDT)
X-Received: by 2002:a63:553:: with SMTP id 80mr114619528pgf.280.1564538417012;
        Tue, 30 Jul 2019 19:00:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564538417; cv=none;
        d=google.com; s=arc-20160816;
        b=jUy5Qb+jd7ZRNaQxUcoVpK67+XDRztn95t0a4EfGdJXzG/nK+V+SXVNs9ffG32KDbz
         jAbRh+i6o328zHi8d120N3TX5FiWoMqjA4LzTy3MM38uG8+M+zB5U0f18ML7h6p+lOwl
         3Uw9vwg/C/7pvJag6YQc5Qga4KbmP+CWj5tiwwX9wBPN6azf/Cnp+0LlnnZMoQOC92y4
         CIRgfutsAG9Bi6DrHJ4eEA3LUXmVevSQ1u+oQveOal5UryfdfGOPM+RZN8CIDdbpRZ1A
         RkTOXIVmeUCw8nkrty0Jv0IrAYhIcePuzNDTs5COrIkMHoGTj7nrSef0/hFWkshvQbsc
         ALlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=oCLOdBMgfCfLJi2/RWEeEeVaZTdV5EmVCrQBzvZ/uFM=;
        b=iQFtC6HI/cvjFmN7EV04bFLFECeUSkel8wAVKGt69kInw82c2rbhcxgPkbLFz8C7U5
         BNVz0ecZtg3WBBQcNUP664ECE+Y81nGHxEP1pVbPuDNlvqHbOMDFoPhsjR80B6u7i62g
         Ct/AkNyTXD6bGqB2ntIn+8YlTROHWRtJOyjOCXQoF3/UMkVI3lmUsQsHu5OK3XiYTIfj
         Y/8sKF5tYNRQzMD+3B5AoLOJlQ+3Z7/FyONfQeoKCUFLV9/ixOuOIL4XMtQ0wdpBuzzP
         613ERKfud7Y1j1L1KFs0UluhoPolOQzoG8F4XA3EMV0M1P9JWJi+vwV1TaJ2Vc9pLtiD
         0Elg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=k+q+hA5Q;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v21sor34565809pgb.48.2019.07.30.19.00.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jul 2019 19:00:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=k+q+hA5Q;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=oCLOdBMgfCfLJi2/RWEeEeVaZTdV5EmVCrQBzvZ/uFM=;
        b=k+q+hA5QM2q24CH7290heHs2kmQGt/ykzG47vTmlDxy0jLaUWJpEELxpSqCPfTFsVI
         HZzNjy7Bix+8gIjF99zvebszJvIJau9MSSv+YNQXh7i+UqZmSKv06y4mjkudoX3Lo1FX
         uLVWfyxOnww6OOYSI9vx+qfDU5xi3PQW4rdqEyo6ZJIRgsPhHxe7MOaSCEhGGJ601iYT
         E7RJEJVO1tlucP/3ciwquXKugFaCXNgGb8K4jC2eRJNVgNj/I7C4HIjpQJeytATwQEVr
         mQjrz0qY6YsEGP9yiPWZ+rW547IEtDD780P2vKakMWpFJxdOcTQl/GfdbLXx/j3RjJdh
         vJ3w==
X-Google-Smtp-Source: APXvYqxNcCQKJ8aCEl77yBJkBG2jtsQ4ZpgP5FUCmJoJEm1exonIQap8RKBcC3hCDX6oaUx8s5ym7Q==
X-Received: by 2002:a63:67c6:: with SMTP id b189mr20351099pgc.163.1564538416577;
        Tue, 30 Jul 2019 19:00:16 -0700 (PDT)
Received: from bogon.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id i9sm136885pjj.2.2019.07.30.19.00.13
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 19:00:15 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	Yafang Shao <laoar.shao@gmail.com>,
	Michal Hocko <mhocko@kernel.org>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: [PATCH RESEND] mm/vmscan: shrink slab in node reclaim
Date: Tue, 30 Jul 2019 22:00:01 -0400
Message-Id: <1564538401-21353-1-git-send-email-laoar.shao@gmail.com>
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

If reclaimable pagecache is less than min_unmapped_pages while
reclaimable slab is greater than min_slab_pages, we only shrink slab.
Otherwise the min_unmapped_pages will be useless under this condition.
A new bitmask no_pagecache is introduced in scan_control for this
purpose, which is 0 by default.
Once __node_reclaim() is called, either the reclaimable pagecache is
greater than min_unmapped_pages or reclaimable slab is greater than
min_slab_pages, that is ensured in function node_reclaim(). So wen can
remove the if statement in __node_reclaim().

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

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Yafang Shao <shaoyafang@didiglobal.com>
---
 mm/vmscan.c | 27 +++++++++++++++++----------
 1 file changed, 17 insertions(+), 10 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 47aa215..1e410ef 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -91,6 +91,9 @@ struct scan_control {
 	/* e.g. boosted watermark reclaim leaves slabs alone */
 	unsigned int may_shrinkslab:1;
 
+	/* in node relcaim mode, we may shrink slab only */
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
+		.no_pagecache = !(node_pagecache_reclaimable(pgdat) >
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

