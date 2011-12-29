Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 8B40D6B0096
	for <linux-mm@kvack.org>; Thu, 29 Dec 2011 07:38:43 -0500 (EST)
Received: by werf1 with SMTP id f1so8534965wer.14
        for <linux-mm@kvack.org>; Thu, 29 Dec 2011 04:38:41 -0800 (PST)
MIME-Version: 1.0
Date: Thu, 29 Dec 2011 20:38:41 +0800
Message-ID: <CAJd=RBAp=ooYGoDqJG0qkUhRuYTsSKG9h+bUvC0dvuVCvfkCgQ@mail.gmail.com>
Subject: [PATCH] mm: vmscan: fix typo in isolating lru pages
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

It is not the tag page but the cursor page that we should process, and it looks
a typo.

Signed-off-by: Hillf Danton <dhillf@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hughd@google.com>
---

--- a/mm/vmscan.c	Thu Dec 29 20:20:16 2011
+++ b/mm/vmscan.c	Thu Dec 29 20:23:30 2011
@@ -1231,13 +1231,13 @@ static unsigned long isolate_lru_pages(u

 				mem_cgroup_lru_del(cursor_page);
 				list_move(&cursor_page->lru, dst);
-				isolated_pages = hpage_nr_pages(page);
+				isolated_pages = hpage_nr_pages(cursor_page);
 				nr_taken += isolated_pages;
 				nr_lumpy_taken += isolated_pages;
 				if (PageDirty(cursor_page))
 					nr_lumpy_dirty += isolated_pages;
 				scan++;
-				pfn += isolated_pages-1;
+				pfn += isolated_pages - 1;
 			} else {
 				/*
 				 * Check if the page is freed already.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
