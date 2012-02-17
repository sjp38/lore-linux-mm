Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id E8F1B6B00FA
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 10:27:08 -0500 (EST)
Received: by dadv6 with SMTP id v6so4087824dad.14
        for <linux-mm@kvack.org>; Fri, 17 Feb 2012 07:27:08 -0800 (PST)
From: Kautuk Consul <consul.kautuk@gmail.com>
Subject: [PATCH 1/2 v2] rmap: Make page_referenced_file and page_referenced_anon inline
Date: Fri, 17 Feb 2012 10:26:38 -0500
Message-Id: <1329492398-7631-1-git-send-email-consul.kautuk@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kautuk Consul <consul.kautuk@gmail.com>

Inline the page_referenced_anon and page_referenced_file
functions.
These functions are called only from page_referenced.

Signed-off-by: Kautuk Consul <consul.kautuk@gmail.com>
---
 mm/rmap.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index c8454e0..74aff97 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -772,7 +772,7 @@ out:
 	return referenced;
 }
 
-static int page_referenced_anon(struct page *page,
+static inline int page_referenced_anon(struct page *page,
 				struct mem_cgroup *memcg,
 				unsigned long *vm_flags)
 {
@@ -821,7 +821,7 @@ static int page_referenced_anon(struct page *page,
  *
  * This function is only called from page_referenced for object-based pages.
  */
-static int page_referenced_file(struct page *page,
+static inline int page_referenced_file(struct page *page,
 				struct mem_cgroup *memcg,
 				unsigned long *vm_flags)
 {
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
