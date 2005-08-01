Received: from imp5-q.free.fr (imp5-q.free.fr [212.27.42.5])
	by postfix4-1.free.fr (Postfix) with ESMTP id 6CF62319D27
	for <linux-mm@kvack.org>; Mon,  1 Aug 2005 18:05:00 +0200 (CEST)
Message-ID: <1122912299.42ee482bdfadf@imp5-q.free.fr>
Date: Mon, 01 Aug 2005 18:04:59 +0200
From: renaud.lienhart@free.fr
Subject: page_alloc.c: free_pages_bulk() comment is incorrect
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"'count' is the number of pages to free, or 0 for all on the list."

However, when looking carefully at the loop of this function, we can
see that it exits immediately if count == 0, thus defeating the purpose
of freeing the entire list.
If I am wrong, please correct me.

Anyway, this behaviour seems mostly harmless as no user calls it
with an explicit "0". Or perhaps the callers assumed the current behaviour
and ignored the comment.

So we have two solutions:
- Fix free_pages_bulk() to adopt the "0 frees all" behaviour.
- Remove the confusing comment and pray that nobody used this feature
  (and by "nobody" I mean the only 3 callers).

I am not familiar enough with the mm subsystem, but I will be glad to
provide a patch to fix it once I know the correct fix.

Thanks and excuse my poor english,

        Renaud
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
