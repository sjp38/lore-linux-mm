Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A154D6B007B
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 09:52:51 -0500 (EST)
Received: by pwj10 with SMTP id 10so3543153pwj.6
        for <linux-mm@kvack.org>; Wed, 13 Jan 2010 06:52:49 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 13 Jan 2010 22:52:48 +0800
Message-ID: <3a3680031001130652g58c70471sfb2b46743816de84@mail.gmail.com>
Subject: [PATCH 2/3] mm: page_alloc.c Adjust a call site to
	trace_mm_page_free_direct
From: Li Hong <lihong.hi@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>

Move a call of 'trace_mm_page_free_direct' from 'free_hot_page' to
'free_hot_cold_page'. It is clearer and close to 'kmemcheck_free_shadow', as it
is done in function '__free_pages_ok'.

Signed-off-by: Li Hong <lihong.hi@gmail.com>
---
 mm/page_alloc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 24344cd..175dd36 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1082,6 +1082,7 @@ static void free_hot_cold_page(struct page
*page, int cold)
        int migratetype;
        int wasMlocked = __TestClearPageMlocked(page);

+       trace_mm_page_free_direct(page, 0);
        kmemcheck_free_shadow(page, 0);

        if (PageAnon(page))
@@ -1136,7 +1137,6 @@ out:

 void free_hot_page(struct page *page)
 {
-       trace_mm_page_free_direct(page, 0);
        free_hot_cold_page(page, 0);
 }

-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
