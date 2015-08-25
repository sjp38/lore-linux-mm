Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7B4396B0253
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 22:08:00 -0400 (EDT)
Received: by qgj62 with SMTP id 62so98522871qgj.2
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 19:08:00 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id w93si19921599qge.51.2015.08.24.19.07.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 19:07:59 -0700 (PDT)
Message-ID: <55DBCCE2.3070901@huawei.com>
Date: Tue, 25 Aug 2015 10:03:14 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] memory-hotplug: fix comment in zone_spanned_pages_in_node()
 and zone_spanned_pages_in_node()
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, David Rientjes <rientjes@google.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, izumi.taku@jp.fujitsu.com
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

When hotadd a node from add_memory(), we will add memblock first, so the
node is not empty. But when from cpu_up(), the node should be empty.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/page_alloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2ec3ca3..d370445 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5051,7 +5051,7 @@ static unsigned long __meminit zone_spanned_pages_in_node(int nid,
 {
 	unsigned long zone_start_pfn, zone_end_pfn;
 
-	/* When hotadd a new node, the node should be empty */
+	/* When hotadd a new node from cpu_up(), the node should be empty */
 	if (!node_start_pfn && !node_end_pfn)
 		return 0;
 
@@ -5118,7 +5118,7 @@ static unsigned long __meminit zone_absent_pages_in_node(int nid,
 	unsigned long zone_high = arch_zone_highest_possible_pfn[zone_type];
 	unsigned long zone_start_pfn, zone_end_pfn;
 
-	/* When hotadd a new node, the node should be empty */
+	/* When hotadd a new node from cpu_up(), the node should be empty */
 	if (!node_start_pfn && !node_end_pfn)
 		return 0;
 
-- 
2.0.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
