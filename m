Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 493A2C10F0B
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 17:43:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14E242070D
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 17:43:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14E242070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D67D8E0120; Fri, 22 Feb 2019 12:43:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F1B68E011D; Fri, 22 Feb 2019 12:43:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 353698E0120; Fri, 22 Feb 2019 12:43:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id B15398E011F
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 12:43:27 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id v27-v6so486064ljv.1
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 09:43:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0J6EKeVNPV4DTtVCERPQrtxws2K83/Ht9c8m80Bex9g=;
        b=ZHiIu497LY0GWjTageawQWF0tFYzPVZw+V5IgA4Y3hqUPdnOZwgHFXGk99tLrKHs5J
         NIUR+jWjb0cSjivTxjAHvjQ9hUidT8uVawu90rMzUfD/wLXg4Elc7DnAYj7gzM3Bucwh
         bp3Sv+ED+LWIaxqZ4vHhPECKm+xD47TZSIPHkneD5L9uR4A7YbjWgFYg8o80hsk/0/a7
         nhXTSbwzyjDBbBY1pcCEyBrJIX5P/MtvvpKm54eB2aI/EDr+LKfo1ScalGo3AK+/92xZ
         LMrzOCstJVgrB9CVzt2MwgZqps2zmQZaj8s4L3sP352zMKOZl7tQHqnqiH92BNuoudZ5
         Lyiw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAuYbzB6Wg0JVIl8Q46Op5WLDsKvEYvFZ51bhBK3wVFialc+U6jSh
	8x4/km68egLs2hfiNFslo49XCxxWTk/2AaxRUgm2NdtORHo+6ZcZi/vkHMNhcjgljmicSwOuRT3
	j2ib7/FSWAr7KfpC8hNIpioOlU0hvd6PmfMyI89eYQPTIJhoQTaFQokgIvNMcaVOFXw==
X-Received: by 2002:ac2:415a:: with SMTP id c26mr3381224lfi.62.1550857406944;
        Fri, 22 Feb 2019 09:43:26 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZFfbb5wBqJLaAvfQsdXWbVbYIfYP5XPDtfDOWNeQyoyM09W/df90wUdNSOw8mcLEiD8ZDS
X-Received: by 2002:ac2:415a:: with SMTP id c26mr3381153lfi.62.1550857405546;
        Fri, 22 Feb 2019 09:43:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550857405; cv=none;
        d=google.com; s=arc-20160816;
        b=nAwIo4mqvi3/mqWRBoPqmY7plTpvYgyVKsoaH6eCQZdLq/O3+P1DGIPT3xO2q4efGF
         l/nr1os9grrB2c7nEW6JUSRwPHMNTennalEI5eFnkF0iRlPTONQ5s2tv82VojgVsV6++
         XzQwOyOMsvsNte9Y5BqvcbRABKma+zh1kIJGYE78C9i3NbZ9X2JfeW5MrVvJGuid2SEj
         hfgXNQIngt2ec9KZ5UVu3Y+IS8HFfdixi5VPtwZ1V7mvQSAZnu/lnfYvBrDNvh+a7DPT
         aN00Cf7Yum6rPLPDJTkqJLJwWYiAMzF8IftSUNNe/slbZLxqPVfNkK4k+a/j6At+eoA3
         OkuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=0J6EKeVNPV4DTtVCERPQrtxws2K83/Ht9c8m80Bex9g=;
        b=W0qKdmCu4Uoerm/TLmq/UAl6O/wjSbBIw81Gi5XTfmYDE3LpyOlHDinpeB0Yv5CP1f
         /kLcBzeBde58JTtr1A/qkB5brJYcNcOnh4vfBSXbvlLTUdm8l3DZVpPvsrdXWu3+vndz
         lztPiwdYO7Zpps8eC9WMKOsaMuTMANPs7OigPIdeoKTKW8ETtVBv4SDZi2uq2MreMIr/
         aWjz//jg9bmZGm87CnG8P+y/JPltRcz56QUKNhaAkOIs1TE8+/ZeSde5TTsFefPvewEW
         JqkDTeS4atq8Y77V7PtYtBd15dS9IMBaGgFoFneXeMxq51YgBJQypLS7XFEuA5nA7QnH
         6kyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id 1-v6si1488654lji.133.2019.02.22.09.43.25
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
	id 1gxEr3-00010r-J9; Fri, 22 Feb 2019 20:43:21 +0300
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
Subject: [PATCH 5/5] mm/vmscan: don't forcely shrink active anon lru list
Date: Fri, 22 Feb 2019 20:43:37 +0300
Message-Id: <20190222174337.26390-5-aryabinin@virtuozzo.com>
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

shrink_node_memcg() always forcely shrink active anon list.
This doesn't seem like correct behavior. If system/memcg has no swap, it's
absolutely pointless to rebalance anon lru lists.
And in case we did scan the active anon list above, it's unclear why would
we need this additional force scan. If there are cases when we want more
aggressive scan of the anon lru we should just change the scan target
in get_scan_count() (and better explain such cases in the comments).

Remove this force shrink and let get_scan_count() to decide how
much of active anon we want to shrink.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Rik van Riel <riel@surriel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
---
 mm/vmscan.c | 12 ++----------
 1 file changed, 2 insertions(+), 10 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 07f74e9507b6..efd10d6b9510 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2563,8 +2563,8 @@ static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memc
 			 sc->priority == DEF_PRIORITY);
 
 	blk_start_plug(&plug);
-	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
-					nr[LRU_INACTIVE_FILE]) {
+	while (nr[LRU_ACTIVE_ANON] || nr[LRU_INACTIVE_ANON] ||
+		nr[LRU_ACTIVE_FILE] || nr[LRU_INACTIVE_FILE]) {
 		unsigned long nr_anon, nr_file, percentage;
 		unsigned long nr_scanned;
 
@@ -2636,14 +2636,6 @@ static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memc
 	}
 	blk_finish_plug(&plug);
 	sc->nr_reclaimed += nr_reclaimed;
-
-	/*
-	 * Even if we did not try to evict anon pages at all, we want to
-	 * rebalance the anon lru active/inactive ratio.
-	 */
-	if (inactive_list_is_low(lruvec, false, memcg, sc, true))
-		shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
-				   sc, LRU_ACTIVE_ANON);
 }
 
 /* Use reclaim/compaction for costly allocs or under memory pressure */
-- 
2.19.2

