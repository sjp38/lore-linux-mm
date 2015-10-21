Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id AA2F46B0257
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 05:52:21 -0400 (EDT)
Received: by pasz6 with SMTP id z6so50543010pas.2
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 02:52:21 -0700 (PDT)
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com. [202.81.31.140])
        by mx.google.com with ESMTPS id wj8si12196551pab.47.2015.10.21.02.52.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Oct 2015 02:52:20 -0700 (PDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Wed, 21 Oct 2015 19:52:16 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 0D92F3578056
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 20:52:13 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t9L9pxPS29163678
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 20:52:07 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t9L9pd8G017873
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 20:51:40 +1100
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH 1/3] mm/slub: correct the comment in calculate_order()
Date: Wed, 21 Oct 2015 17:51:04 +0800
Message-Id: <1445421066-10641-2-git-send-email-weiyang@linux.vnet.ibm.com>
In-Reply-To: <1445421066-10641-1-git-send-email-weiyang@linux.vnet.ibm.com>
References: <1445421066-10641-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org
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
index f68c0e5..e171b10 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2839,7 +2839,7 @@ static inline int calculate_order(int size, int reserved)
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
