Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id F29CB6B0038
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 21:06:50 -0400 (EDT)
Received: by obcxm10 with SMTP id xm10so39153418obc.3
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 18:06:50 -0700 (PDT)
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com. [122.248.162.4])
        by mx.google.com with ESMTPS id s196si9679307oie.91.2015.09.28.18.06.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Sep 2015 18:06:50 -0700 (PDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Tue, 29 Sep 2015 06:36:46 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id DD18FE0054
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 06:36:26 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t8T16gWw6160678
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 06:36:42 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t8T16fdn000802
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 06:36:42 +0530
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH 1/2] mm/slub: correct the comment in calculate_order()
Date: Tue, 29 Sep 2015 09:06:26 +0800
Message-Id: <1443488787-2232-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com
Cc: linux-mm@kvack.org, Wei Yang <weiyang@linux.vnet.ibm.com>

In calculate_order(), it tries to calculate the best order by adjusting the
fraction and min_objects. On each iteration on min_objects, fraction
iterates on 16, 8, 4. Which means the acceptable waste increases with 1/16,
1/8, 1/4.

This patch corrects the comment according to the code.

Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
---
 mm/slub.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index f614b5d..a94b9f4 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2943,7 +2943,7 @@ static inline int calculate_order(int size, int reserved)
 	 * works by first attempting to generate a layout with
 	 * the best configuration and backing off gradually.
 	 *
-	 * First we reduce the acceptable waste in a slab. Then
+	 * First we increase the acceptable waste in a slab. Then
 	 * we reduce the minimum objects required in a slab.
 	 */
 	min_objects = slub_min_objects;
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
