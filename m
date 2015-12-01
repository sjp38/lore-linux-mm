Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 17A0F6B0253
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 03:37:17 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so214995648pac.3
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 00:37:16 -0800 (PST)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id l73si8543897pfb.148.2015.12.01.00.37.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Dec 2015 00:37:16 -0800 (PST)
Received: by padhx2 with SMTP id hx2so215027014pad.1
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 00:37:16 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1] mm: fix warning in comparing enumerator
Date: Tue,  1 Dec 2015 17:37:12 +0900
Message-Id: <1448959032-754-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Yaowei Bai <baiyaowei@cmss.chinamobile.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

I saw the following warning when building mmotm-2015-11-25-17-08.

mm/page_alloc.c:4185:16: warning: comparison between 'enum zone_type' and 'enum <anonymous>' [-Wenum-compare]
  for (i = 0; i < MAX_ZONELISTS; i++) {
                ^

enum zone_type is named like ZONE_* which is different from ZONELIST_*, so
we are somehow doing incorrect comparison. Just fixes it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/page_alloc.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git mmotm-2015-11-25-17-08/mm/page_alloc.c mmotm-2015-11-25-17-08_patched/mm/page_alloc.c
index e267faa..b801e6f 100644
--- mmotm-2015-11-25-17-08/mm/page_alloc.c
+++ mmotm-2015-11-25-17-08_patched/mm/page_alloc.c
@@ -4174,8 +4174,7 @@ static void set_zonelist_order(void)
 
 static void build_zonelists(pg_data_t *pgdat)
 {
-	int j, node, load;
-	enum zone_type i;
+	int i, j, node, load;
 	nodemask_t used_mask;
 	int local_node, prev_node;
 	struct zonelist *zonelist;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
