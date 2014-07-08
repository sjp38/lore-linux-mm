Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id A7AB86B0031
	for <linux-mm@kvack.org>; Tue,  8 Jul 2014 01:45:18 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id eu11so6634046pac.25
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 22:45:18 -0700 (PDT)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id fs16si5656890pdb.338.2014.07.07.22.45.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 07 Jul 2014 22:45:17 -0700 (PDT)
Received: by mail-pd0-f169.google.com with SMTP id g10so6597497pdj.14
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 22:45:16 -0700 (PDT)
Message-ID: <53BB8553.10508@gmail.com>
Date: Tue, 08 Jul 2014 13:44:51 +0800
From: Wang Sheng-Hui <shhuiw@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] mm: update the description for vm_total_pages
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, Glauber Costa <glommer@openvz.org>, Dave Chinner <dchinner@redhat.com>, linux-mm@kvack.org


vm_total_pages is calculated by nr_free_pagecache_pages(), which counts
the number of pages which are beyond the high watermark within all zones.
So vm_total_pages is not equal to total number of pages which the VM controls.

Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
---
 mm/vmscan.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0f16ffe..8c7a559 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -136,7 +136,11 @@ struct scan_control {
  * From 0 .. 100.  Higher means more swappy.
  */
 int vm_swappiness = 60;
-unsigned long vm_total_pages;  /* The total number of pages which the VM controls */
+/*
+ * The total number of pages which are beyond the high watermark
+ * within all zones.
+ */
+unsigned long vm_total_pages;

 static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
