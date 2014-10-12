Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2B66A6B0038
	for <linux-mm@kvack.org>; Sun, 12 Oct 2014 07:48:53 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id eu11so4333934pac.14
        for <linux-mm@kvack.org>; Sun, 12 Oct 2014 04:48:52 -0700 (PDT)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id yd5si8023312pbc.53.2014.10.12.04.48.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Sun, 12 Oct 2014 04:48:52 -0700 (PDT)
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0NDB00323Y5D5UA0@mailout2.samsung.com> for linux-mm@kvack.org;
 Sun, 12 Oct 2014 20:48:49 +0900 (KST)
From: Pintu Kumar <pintu.k@samsung.com>
Subject: [PATCH] [mm]: vmscan: replace printk with pr_err
Date: Sun, 12 Oct 2014 17:10:51 +0530
Message-id: <1413114051-10555-1-git-send-email-pintu.k@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, mgorman@suse.de, vdavydov@parallels.com, mhocko@suse.cz, suleiman@google.com
Cc: cpgs@samsung.com, pintu.k@samsung.com, pintu_agarwal@yahoo.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, iqbal.ams@samsung.com

This patch replaces printk(KERN_ERR..) with pr_err found
under shrink_slab.
Thus it also reduces one line extra because of formatting.

Signed-off-by: Pintu Kumar <pintu.k@samsung.com>
---
 mm/vmscan.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index dcb4707..59605b7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -260,8 +260,7 @@ shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
 	do_div(delta, lru_pages + 1);
 	total_scan += delta;
 	if (total_scan < 0) {
-		printk(KERN_ERR
-		"shrink_slab: %pF negative objects to delete nr=%ld\n",
+		pr_err("shrink_slab: %pF negative objects to delete nr=%ld\n",
 		       shrinker->scan_objects, total_scan);
 		total_scan = freeable;
 	}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
