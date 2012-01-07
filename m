Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 22E766B005A
	for <linux-mm@kvack.org>; Fri,  6 Jan 2012 22:46:19 -0500 (EST)
Received: by wibhq12 with SMTP id hq12so2202685wib.14
        for <linux-mm@kvack.org>; Fri, 06 Jan 2012 19:46:17 -0800 (PST)
MIME-Version: 1.0
Date: Sat, 7 Jan 2012 11:46:17 +0800
Message-ID: <CAJd=RBDAoNt=TZWhNeLs0MaCJ_ormEp=ya55-PA+B0BAxfGbbQ@mail.gmail.com>
Subject: [PATCH] mm: vmscan: no change of reclaim mode if unevictable page encountered
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Hillf Danton <dhillf@gmail.com>, LKML <linux-kernel@vger.kernel.org>

Since unevictable page is not isolated from lru list for shrink_page_list(),
it is accident if encountered in shrinking, and no need to change reclaim mode.

Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/vmscan.c	Thu Dec 29 20:20:16 2011
+++ b/mm/vmscan.c	Sat Jan  7 11:27:44 2012
@@ -995,7 +995,6 @@ cull_mlocked:
 			try_to_free_swap(page);
 		unlock_page(page);
 		putback_lru_page(page);
-		reset_reclaim_mode(sc);
 		continue;

 activate_locked:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
