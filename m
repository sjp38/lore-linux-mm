Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 429C56B007E
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 05:44:20 -0400 (EDT)
Received: by mail-io0-f178.google.com with SMTP id g185so15211864ioa.2
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 02:44:20 -0700 (PDT)
Received: from BLU004-OMC1S26.hotmail.com (blu004-omc1s26.hotmail.com. [65.55.116.37])
        by mx.google.com with ESMTPS id i123si27520424ioe.133.2016.03.29.02.44.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 29 Mar 2016 02:44:19 -0700 (PDT)
Message-ID: <BLU437-SMTP663CF466BDC7F9124425CDBA870@phx.gbl>
From: Neil Zhang <neilzhang1123@hotmail.com>
Subject: [PATCH] mm/page_isolation.c: fix the function comments
Date: Tue, 29 Mar 2016 17:43:53 +0800
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, js1304@gmail.com, Neil Zhang <neilzhang1123@hotmail.com>

commit fea85cff11de ("mm/page_isolation.c: return last tested pfn rather
than failure indicator") changed the meaning of the return value.
Let's change the function comments as well.

Signed-off-by: Neil Zhang <neilzhang1123@hotmail.com>
---
 mm/page_isolation.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 92c4c36..9f9b394 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -215,7 +215,7 @@ int undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
  * all pages in [start_pfn...end_pfn) must be in the same zone.
  * zone->lock must be held before call this.
  *
- * Returns 1 if all pages in the range are isolated.
+ * Returns the last tested pfn.
  */
 static unsigned long
 __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
