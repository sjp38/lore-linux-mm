Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 06C396B0195
	for <linux-mm@kvack.org>; Fri,  8 Nov 2013 07:47:56 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id g10so2103329pdj.6
        for <linux-mm@kvack.org>; Fri, 08 Nov 2013 04:47:56 -0800 (PST)
Received: from psmtp.com ([74.125.245.202])
        by mx.google.com with SMTP id rr7si6410782pbc.255.2013.11.08.04.47.55
        for <linux-mm@kvack.org>;
        Fri, 08 Nov 2013 04:47:55 -0800 (PST)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zwu.kernel@gmail.com>;
	Fri, 8 Nov 2013 05:47:53 -0700
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id D95993E40026
	for <linux-mm@kvack.org>; Fri,  8 Nov 2013 05:47:51 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rA8ClpMg329760
	for <linux-mm@kvack.org>; Fri, 8 Nov 2013 05:47:51 -0700
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rA8ClpcI016549
	for <linux-mm@kvack.org>; Fri, 8 Nov 2013 05:47:51 -0700
From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [PATCH 3/3] mm, memory-failure: fix the typo in me_pagecache_dirty()
Date: Fri,  8 Nov 2013 20:47:38 +0800
Message-Id: <1383914858-14533-3-git-send-email-zwu.kernel@gmail.com>
In-Reply-To: <1383914858-14533-1-git-send-email-zwu.kernel@gmail.com>
References: <1383914858-14533-1-git-send-email-zwu.kernel@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 mm/memory-failure.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index bf3351b..d8ec181 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -611,7 +611,7 @@ static int me_pagecache_clean(struct page *p, unsigned long pfn)
 }
 
 /*
- * Dirty cache page page
+ * Dirty cache page
  * Issues: when the error hit a hole page the error is not properly
  * propagated.
  */
-- 
1.7.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
