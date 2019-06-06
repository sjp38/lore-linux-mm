Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77543C28D1D
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 10:15:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D5D120868
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 10:15:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JPQyxXmz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D5D120868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ACFC06B026C; Thu,  6 Jun 2019 06:15:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A81616B026D; Thu,  6 Jun 2019 06:15:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 96FA16B026E; Thu,  6 Jun 2019 06:15:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5FF2E6B026C
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 06:15:27 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id f25so289545pfk.14
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 03:15:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=k0l9U+sWxSO3Dg0lLraseLlI8mAPkbXeLIQciOlURR0=;
        b=LPb6om+vsYgUQr/UcaQtscyBbkqxZ4qNkYb13Hh6u/yW4WvNoCpxIhO34CgKFkxmmn
         pH+xokmKsNz9HE6r99NuKnjgRrR56QQhNDC5U6rLBc/GTfjnmY5meV8h8VzHZ8GlFdpC
         FJMDDYxcG0eT9A63X6Jf7sCrWKJAvUj/bVKJHDdDqxrd2EXPM3D0IRCrOImpxF0ZwZwN
         z867SEAW2bq+A21vHi+5gMwIAdxt/Omsz8LL7INU8zJeWi0E5ghNyCGu+xeOOtKVg82D
         +lWgQNzW9tvNObVPGy5lAjk/w30FfC5MIsFBfJojPBloP+YTUR+mRjNtBDqG6oHgmeJ+
         szCw==
X-Gm-Message-State: APjAAAVgA5QE46VW6/kN20zf77eOcwkDU497wOxQmldXuAnnd1UswfTM
	4O02yA2lh9AAGPnzmMQh6k/yc7dz7dkM5JCnj53AuvdBAjyfkE4S36TfQrICGMXFcSVPpU8OBCd
	qzOccD5SGxw0cHWzTDbrf5SLcCJl2VaEFBh3AHZWeZe939Sr/pjtWx8FDPrqnp3xnpw==
X-Received: by 2002:a62:1c91:: with SMTP id c139mr44497973pfc.25.1559816126857;
        Thu, 06 Jun 2019 03:15:26 -0700 (PDT)
X-Received: by 2002:a62:1c91:: with SMTP id c139mr44497858pfc.25.1559816125479;
        Thu, 06 Jun 2019 03:15:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559816125; cv=none;
        d=google.com; s=arc-20160816;
        b=wAi0MalDIkKcnOvgzYXeJu1gX15H6iaRBTPYV88qDW8Ag54h82xMIs9uoiB5D4OZqh
         6ctyuxW9n9yVU9+BZGONNdSxmJwNz70MAUGF3bhqFRJ+m1qFj2z9yHl0ZtK/5NIvNd70
         9sJCxDsLVaEHHG5umDX60rZGe5NQ6QbpRZtt0HPmhqJtSozEaB9I6vM/wSZYLtK18CFP
         056yLFnKlk+ZSCNZfLB/zNU22NFuHwQKvMLDRFPwBHoTK2cJhQD3C/oWKVHN2sRifrFA
         6O92xR2DdMNYeKyQ2bkrOjtQalWAASMvfgImJSt8lQ/FuN5ug6RZPOZokpTpY3b4ugC9
         T7Og==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=k0l9U+sWxSO3Dg0lLraseLlI8mAPkbXeLIQciOlURR0=;
        b=x2fdUpRb745+Q0eGYOdEaY+FklJbPeBrA5Q+VFS/v1okHjygWrfDbFyZ1d2rVJe7PA
         bwgNWZpVYkTjg1mPH0V9AI+LC2DNQcgty+XFRtI2OUSYU5GChrZyerDj9Kjv6wSn1/vf
         ms6WJb1uluEMOnfJ09IANpmK7J1yjFQ/LMPdZjSqEAJpcFmg1KyUI5o6nYMgMqRRcxIU
         GH8H4jfv89zkrji2QvBMbE/z68ZGsBp/v+kY8IRyCbyoxQ6d1W/8vk+a4TkCq6GjDpyQ
         esMX7O2mMoqlZNFoKOJEta3J8bMOr8CcSyS8TZLUNwZtmP0rK5yMS78xFTGEsIpVmaTm
         o8lg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JPQyxXmz;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h42sor1567018pjb.11.2019.06.06.03.15.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 03:15:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JPQyxXmz;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=k0l9U+sWxSO3Dg0lLraseLlI8mAPkbXeLIQciOlURR0=;
        b=JPQyxXmz5AbC2GN+uXwBGzE7FZj+CmKUQbLDzpB6sb+dr9rW1QUgr4TI6PMGB5DIkD
         BlVh9N81Eq/4WfLr6/KFiZnjNAvcPeJ0LnNjGTYPPfRlaa694QQr7r/KLn85QhtjEiy1
         8m06CFjqkucMajYAAzNw5sFslhBQ1fDvgL2pLzu/zMKx4JqwEKWVl5Wd+PnRwHq8Rf96
         vfZ8SEx5w3aMrUDmwSBgz1FgjFAUV3QT6SY9HiqRUy/hLDzXncf1oVK5Cv93AAO8bQ4r
         Pg8hmzfakIWvTM1Xexey2BjD7Cjpy1WCbqJuEyp/a541Sr0u0Uqy8TEZWrugv8drh8DS
         VjRw==
X-Google-Smtp-Source: APXvYqxKvfL027icRD2xvrxUtq46Y+QT8HXaBU8Ay/gNybybqWmCWqULPJC+LJsPMh5RL/X5xkxInQ==
X-Received: by 2002:a17:90a:2743:: with SMTP id o61mr36311591pje.59.1559816125195;
        Thu, 06 Jun 2019 03:15:25 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id z68sm1895829pfb.37.2019.06.06.03.15.22
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 03:15:24 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: akpm@linux-foundation.org,
	mhocko@suse.com,
	linux.bhar@gmail.com
Cc: linux-mm@kvack.org,
	shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH v4 3/3] mm/vmscan: shrink slab in node reclaim
Date: Thu,  6 Jun 2019 18:14:40 +0800
Message-Id: <1559816080-26405-4-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1559816080-26405-1-git-send-email-laoar.shao@gmail.com>
References: <1559816080-26405-1-git-send-email-laoar.shao@gmail.com>
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

reclaim_state.reclaimed_slab will tell us how many pages are
reclaimed in shrink slab.

This issue is very easy to produce, first you continuously cat a random
non-exist file to produce more and more dentry, then you read big file
to produce page cache. And finally you will find that the denty will
never be shrunk in node reclaim.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 mm/vmscan.c | 27 +++++++++++++++++----------
 1 file changed, 17 insertions(+), 10 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 281bfa9..da53ed6 100644
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
@@ -2744,7 +2747,9 @@ static void shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 
 			reclaimed = sc->nr_reclaimed;
 			scanned = sc->nr_scanned;
-			shrink_node_memcg(pgdat, memcg, sc);
+
+			if (!sc->no_pagecache)
+				shrink_node_memcg(pgdat, memcg, sc);
 
 			if (sc->may_shrinkslab) {
 				shrink_slab(sc->gfp_mask, pgdat->node_id,
@@ -4176,6 +4181,10 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 		.may_writepage = !!(node_reclaim_mode & RECLAIM_WRITE),
 		.may_unmap = !!(node_reclaim_mode & RECLAIM_UNMAP),
 		.may_swap = 1,
+		.may_shrinkslab = (node_page_state(pgdat, NR_SLAB_RECLAIMABLE) >
+				  pgdat->min_slab_pages),
+		.no_pagecache = !(node_pagecache_reclaimable(pgdat) >
+				pgdat->min_unmapped_pages),
 		.reclaim_idx = gfp_zone(gfp_mask),
 	};
 
@@ -4194,15 +4203,13 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
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
 
 	p->reclaim_state = NULL;
 	current->flags &= ~PF_SWAPWRITE;
-- 
1.8.3.1

