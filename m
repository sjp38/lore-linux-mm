Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 826116B009F
	for <linux-mm@kvack.org>; Sun,  1 Jan 2012 02:42:51 -0500 (EST)
Received: by iacb35 with SMTP id b35so33330274iac.14
        for <linux-mm@kvack.org>; Sat, 31 Dec 2011 23:42:50 -0800 (PST)
Date: Sat, 31 Dec 2011 23:42:48 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 2/6] mm: no blank line after EXPORT_SYMBOL in swap.c
In-Reply-To: <alpine.LSU.2.00.1112312333380.18500@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1112312341340.18500@eggly.anvils>
References: <alpine.LSU.2.00.1112312333380.18500@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

checkpatch rightly protests
WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
so fix the five offenders in mm/swap.c.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/swap.c |    5 -----
 1 file changed, 5 deletions(-)

--- mmotm.orig/mm/swap.c	2011-12-30 21:29:45.675350259 -0800
+++ mmotm/mm/swap.c	2011-12-30 21:29:54.415350465 -0800
@@ -369,7 +369,6 @@ void mark_page_accessed(struct page *pag
 		SetPageReferenced(page);
 	}
 }
-
 EXPORT_SYMBOL(mark_page_accessed);
 
 void __lru_cache_add(struct page *page, enum lru_list lru)
@@ -646,7 +645,6 @@ void __pagevec_release(struct pagevec *p
 	release_pages(pvec->pages, pagevec_count(pvec), pvec->cold);
 	pagevec_reinit(pvec);
 }
-
 EXPORT_SYMBOL(__pagevec_release);
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
@@ -726,7 +724,6 @@ void __pagevec_lru_add(struct pagevec *p
 
 	pagevec_lru_move_fn(pvec, __pagevec_lru_add_fn, (void *)lru);
 }
-
 EXPORT_SYMBOL(__pagevec_lru_add);
 
 /**
@@ -751,7 +748,6 @@ unsigned pagevec_lookup(struct pagevec *
 	pvec->nr = find_get_pages(mapping, start, nr_pages, pvec->pages);
 	return pagevec_count(pvec);
 }
-
 EXPORT_SYMBOL(pagevec_lookup);
 
 unsigned pagevec_lookup_tag(struct pagevec *pvec, struct address_space *mapping,
@@ -761,7 +757,6 @@ unsigned pagevec_lookup_tag(struct pagev
 					nr_pages, pvec->pages);
 	return pagevec_count(pvec);
 }
-
 EXPORT_SYMBOL(pagevec_lookup_tag);
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
