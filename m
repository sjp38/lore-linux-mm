Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A98D9C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 01:48:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6097520C01
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 01:48:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="EEAe5V4C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6097520C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A37D6B0005; Mon,  5 Aug 2019 21:48:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 27B986B000C; Mon,  5 Aug 2019 21:48:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 114D16B0006; Mon,  5 Aug 2019 21:48:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id D8FAF6B000A
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 21:48:11 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id a4so37030571vki.23
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 18:48:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=JhlDiE5CFQVneED4uISVxNEm3HniZ2YmW8rRwhJuusw=;
        b=GgnE15oQ9dDJKLT+VlIJURYszNoMcur0oGwCiN9k+Qp32f2/TvsVNg4g5ZsvR6VSMg
         3iXCmV9LNVi4ae0tSlj33aFeyIHOZPMyqNOTjKxbqpa4NFx6dWqYhyRsmJc/Jm7/uunt
         P6GN0cxU+ua+beeQh4VNu7z4mtrEYoEO/ma6z3EQVTTn9k9USVr+TEdL8QGe9Aq/iAG5
         T1HDeAm6y7m+l5xmljckSNULao2rZJxB4vtilUy9lvzcm8682FXM0ESxtJaRwGBtST3C
         yVu8aUF0NLMQPdE72I1nq2Nj6xD3lpqcomUoSOlQzpiAn6gFZvFfTs9sfIjCaRCr1LYJ
         XzbA==
X-Gm-Message-State: APjAAAXfrLW5pje8GS4Avl6endbNF+Oh4CZwHkGZLjOn6O5nBJzppA+E
	8sfTmoUugA5My2c143d5Va77cFAGX9Ll3mWbybHOEAIhgYHA7Zf5jlpPNkl2utBpA/yl9rhsxkW
	QMXp5yavIzNEZq4WQHp7BhqRuXGEmi3ekrdaB6QP8BpKF2VH+TgMDpwFplMTnP7tUHw==
X-Received: by 2002:a67:ee16:: with SMTP id f22mr782236vsp.191.1565056091607;
        Mon, 05 Aug 2019 18:48:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx8IbGlLE1ZfRzCzEL88vHYiYaHI6e/p0Nfg5vkFkRYna9fKpRg8MCd//uxG2N/HfbvPMqZ
X-Received: by 2002:a67:ee16:: with SMTP id f22mr782223vsp.191.1565056091008;
        Mon, 05 Aug 2019 18:48:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565056091; cv=none;
        d=google.com; s=arc-20160816;
        b=bYVFFXnElL7KI9YESqkH59UbEVLFC12ft1bKyR8DyFewkp33lhJyWjaPROnmYe8TYZ
         W8PTGTiClC4Xm9C/JW1IKgfhw1U3rmjW5sMDsyEYuviAW9EQXMqIEHileA0qFtY/LPsp
         BqTMR9WIKELbjdMIBLsD4lK6PnHBF71s72plkY2oaq/RcJnbl5YL5lIS+PZ3lfo8tthe
         EwlRNKJlmbu+mvCtvgIGprE2RAnC1pYMVG7HWpyZphyeQXS6M8BTxWqRB2dBcsrY5M46
         zeGNV6yg3ZzFO9m83spX/Tyx1Cy4k/rPkRqIowFdcpHKxSFr1igYeAfjSXfqNJQthv1R
         +g6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=JhlDiE5CFQVneED4uISVxNEm3HniZ2YmW8rRwhJuusw=;
        b=lbabI53BmoAgPrnZdKnfc6sXoPOZGdOhlw2p8I8xUTOjwvC3wvG/PIU+KPIqqDJLzs
         wUV9q2PwVegZlB/ca5dFYGiLAN+60JsUahZBVlvhn4dW5dZkE8kIPtYq+0BE6lH/I4Bz
         ufqvNiV/b43KOJkTyqkKmAvQ2Fq/ZPdx456LaVOl+XD2Rg0w6+EhFe9/DhRFTCRS04ut
         cgs6HCAy0kEm844tHE+I+eTnoj5VoBgthFaD00WxyjuhrqA/T2OrkZJ+nV756sBLIEc2
         kDoTi+lhR2djNl/USGDm/d6D+juSJjRgIMKqw1hzZGQ914AhDJBsvriF83J3NPh+pyzO
         c9Yg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=EEAe5V4C;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id k73si18284645vkk.24.2019.08.05.18.48.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 18:48:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=EEAe5V4C;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x761imIe082725;
	Tue, 6 Aug 2019 01:48:05 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=JhlDiE5CFQVneED4uISVxNEm3HniZ2YmW8rRwhJuusw=;
 b=EEAe5V4CpBzlaE/3etCFXwvH2cJ7B5qnyHYluAnrQ7kJmb8gAvpL3ppTRcqjKlF+qsaq
 PwRex9VoWFTmY6c56qrgt6kX2gp2AqkTGm933NlPudzeiPP3KpCMPxMGhZPQ2q+eEnJ8
 CVKopKHFzCoWUyOJHsWdJswsnWoCH2F48pYjhV+Bj5fVKODTlu6gC4xHzZe4C0wpf+Iw
 +ixGzU0Z+Y+JH6WqEOz757o5ZO6ruiEclW39KzXOqaZ3Zy+/SSx3ONaYjMjGMQzu6198
 64H+016popLpUM6eVUf1vNaDQFvrdvDSG8ExpNo/wzHmkhf8HWBP7klSg5PYOQl3WVs3 pA== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2120.oracle.com with ESMTP id 2u52wr2kpf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 06 Aug 2019 01:48:04 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x761m4td012646;
	Tue, 6 Aug 2019 01:48:04 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3020.oracle.com with ESMTP id 2u5233qgee-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 06 Aug 2019 01:48:03 +0000
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x761ls8K017861;
	Tue, 6 Aug 2019 01:47:54 GMT
Received: from monkey.oracle.com (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 05 Aug 2019 18:47:54 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Hillf Danton <hdanton@sina.com>, Vlastimil Babka <vbabka@suse.cz>,
        Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@suse.de>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Andrea Arcangeli <aarcange@redhat.com>,
        David Rientjes <rientjes@google.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v2 1/4] mm, reclaim: make should_continue_reclaim perform dryrun detection
Date: Mon,  5 Aug 2019 18:47:41 -0700
Message-Id: <20190806014744.15446-2-mike.kravetz@oracle.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190806014744.15446-1-mike.kravetz@oracle.com>
References: <20190806014744.15446-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9340 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908060020
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9340 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908060019
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Hillf Danton <hdanton@sina.com>

Address the issue of should_continue_reclaim returning true too often
for __GFP_RETRY_MAYFAIL attempts when !nr_reclaimed and nr_scanned.
This was observed during hugetlb page allocation causing stalls for
minutes or hours.

We can stop reclaiming pages if compaction reports it can make a progress.
There might be side-effects for other high-order allocations that would
potentially benefit from reclaiming more before compaction so that they
would be faster and less likely to stall.  However, the consequences of
premature/over-reclaim are considered worse.

We can also bail out of reclaiming pages if we know that there are not
enough inactive lru pages left to satisfy the costly allocation.

We can give up reclaiming pages too if we see dryrun occur, with the
certainty of plenty of inactive pages. IOW with dryrun detected, we are
sure we have reclaimed as many pages as we could.

Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Hillf Danton <hdanton@sina.com>
Tested-by: Mike Kravetz <mike.kravetz@oracle.com>
Acked-by: Mel Gorman <mgorman@suse.de>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
v2 - Updated commit message and added SOB.

 mm/vmscan.c | 28 +++++++++++++++-------------
 1 file changed, 15 insertions(+), 13 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 47aa2158cfac..a386c5351592 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2738,18 +2738,6 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
 			return false;
 	}
 
-	/*
-	 * If we have not reclaimed enough pages for compaction and the
-	 * inactive lists are large enough, continue reclaiming
-	 */
-	pages_for_compaction = compact_gap(sc->order);
-	inactive_lru_pages = node_page_state(pgdat, NR_INACTIVE_FILE);
-	if (get_nr_swap_pages() > 0)
-		inactive_lru_pages += node_page_state(pgdat, NR_INACTIVE_ANON);
-	if (sc->nr_reclaimed < pages_for_compaction &&
-			inactive_lru_pages > pages_for_compaction)
-		return true;
-
 	/* If compaction would go ahead or the allocation would succeed, stop */
 	for (z = 0; z <= sc->reclaim_idx; z++) {
 		struct zone *zone = &pgdat->node_zones[z];
@@ -2765,7 +2753,21 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
 			;
 		}
 	}
-	return true;
+
+	/*
+	 * If we have not reclaimed enough pages for compaction and the
+	 * inactive lists are large enough, continue reclaiming
+	 */
+	pages_for_compaction = compact_gap(sc->order);
+	inactive_lru_pages = node_page_state(pgdat, NR_INACTIVE_FILE);
+	if (get_nr_swap_pages() > 0)
+		inactive_lru_pages += node_page_state(pgdat, NR_INACTIVE_ANON);
+
+	return inactive_lru_pages > pages_for_compaction &&
+		/*
+		 * avoid dryrun with plenty of inactive pages
+		 */
+		nr_scanned && nr_reclaimed;
 }
 
 static bool pgdat_memcg_congested(pg_data_t *pgdat, struct mem_cgroup *memcg)
-- 
2.20.1

