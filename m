Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 9C33782F67
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 00:56:02 -0400 (EDT)
Received: by padhk11 with SMTP id hk11so17717562pad.1
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 21:56:02 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id fn10si4737057pab.4.2015.10.18.21.56.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Oct 2015 21:56:02 -0700 (PDT)
Received: by pasz6 with SMTP id z6so18194696pas.2
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 21:56:01 -0700 (PDT)
Date: Sun, 18 Oct 2015 21:55:56 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 5/12] mm: correct a couple of page migration comments
In-Reply-To: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1510182154320.2481@eggly.anvils>
References: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org

It's migrate.c not migration,c, and nowadays putback_movable_pages()
not putback_lru_pages().

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/migrate.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- migrat.orig/mm/migrate.c	2015-10-18 17:53:14.326325730 -0700
+++ migrat/mm/migrate.c	2015-10-18 17:53:17.579329434 -0700
@@ -1,5 +1,5 @@
 /*
- * Memory Migration functionality - linux/mm/migration.c
+ * Memory Migration functionality - linux/mm/migrate.c
  *
  * Copyright (C) 2006 Silicon Graphics, Inc., Christoph Lameter
  *
@@ -1113,7 +1113,7 @@ out:
  *
  * The function returns after 10 attempts or if no pages are movable any more
  * because the list has become empty or no retryable pages exist any more.
- * The caller should call putback_lru_pages() to return pages to the LRU
+ * The caller should call putback_movable_pages() to return pages to the LRU
  * or free list only if ret != 0.
  *
  * Returns the number of pages that were not migrated, or an error code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
