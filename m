Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 39FD46B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 05:09:56 -0400 (EDT)
Received: by lbon3 with SMTP id n3so1245123lbo.14
        for <linux-mm@kvack.org>; Thu, 06 Sep 2012 02:09:54 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 6 Sep 2012 17:09:53 +0800
Message-ID: <CAFNq8R56EXJx3X7C1AAe4xr7AaNGkFNJ2SoOELFF483q1uRk8A@mail.gmail.com>
Subject: [PATCH 1/2] mm: Fixup obsolete PG_buddy flag in error_states[]
From: Li Haifeng <omycle@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org

PG_buddy, an abandoned flag, indicates page(s) is/are free
and in buddy allocator. So in the comment, "pages in
buddy system" instead of "PG_buddy pages".

Signed-off-by: Haifeng Li <omycle@gmail.com>
---
 mm/memory-failure.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index ab1e714..2873498 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -762,7 +762,8 @@ static struct page_state {
        { reserved,     reserved,       "reserved kernel",      me_kernel },
        /*
         * free pages are specially detected outside this table:
-        * PG_buddy pages only make a small fraction of all free pages.
+        * pages in buddy system only make a small fraction of all
+        * free pages.
         */

        /*
--
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
