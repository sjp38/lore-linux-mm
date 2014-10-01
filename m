Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 4C06C6B0069
	for <linux-mm@kvack.org>; Wed,  1 Oct 2014 13:25:45 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id ho1so1353350wib.16
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 10:25:44 -0700 (PDT)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id cn7si2037741wjb.126.2014.10.01.10.25.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 01 Oct 2014 10:25:44 -0700 (PDT)
Received: by mail-wi0-f172.google.com with SMTP id n3so1383571wiv.5
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 10:25:44 -0700 (PDT)
From: Paul McQuade <paulmcquad@gmail.com>
Subject: [PATCH] mm: Space required for open parenthesis
Date: Wed,  1 Oct 2014 18:25:39 +0100
Message-Id: <1412184339-3987-1-git-send-email-paulmcquad@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmcquad@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, vegardno@ifi.uio.no

ERROR: space required before the open parenthesis '('

Signed-off-by: Paul McQuade <paulmcquad@gmail.com>
---
 mm/kmemcheck.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/kmemcheck.c b/mm/kmemcheck.c
index fd814fd..89a7440 100644
--- a/mm/kmemcheck.c
+++ b/mm/kmemcheck.c
@@ -24,7 +24,7 @@ void kmemcheck_alloc_shadow(struct page *page, int order, gfp_t flags, int node)
 		return;
 	}
 
-	for(i = 0; i < pages; ++i)
+	for (i = 0; i < pages; ++i)
 		page[i].shadow = page_address(&shadow[i]);
 
 	/*
@@ -50,7 +50,7 @@ void kmemcheck_free_shadow(struct page *page, int order)
 
 	shadow = virt_to_page(page[0].shadow);
 
-	for(i = 0; i < pages; ++i)
+	for (i = 0; i < pages; ++i)
 		page[i].shadow = NULL;
 
 	__free_pages(shadow, order);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
