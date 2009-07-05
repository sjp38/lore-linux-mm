Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id DDAE36B004F
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 14:01:58 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n659QJrO022258
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 5 Jul 2009 18:26:22 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A0EC845DE50
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 18:26:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B9B645DD7B
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 18:26:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FF2AE08001
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 18:26:19 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1EECEE08003
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 18:26:19 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 5/5] add NR_ANON_PAGES to OOM log
In-Reply-To: <20090705181400.08F1.A69D9226@jp.fujitsu.com>
References: <20090705181400.08F1.A69D9226@jp.fujitsu.com>
Message-Id: <20090705182533.0902.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun,  5 Jul 2009 18:26:18 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Subject: [PATCH] add NR_ANON_PAGES to OOM log

show_free_areas can display NR_FILE_PAGES, but it can't display
NR_ANON_PAGES.

this patch fix its inconsistency.


Reported-by: Wu Fengguang <fengguang.wu@gmail.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/page_alloc.c |    1 +
 1 file changed, 1 insertion(+)

Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2216,6 +2216,7 @@ void show_free_areas(void)
 		printk("= %lukB\n", K(total));
 	}
 
+	printk("%ld total anon pages\n", global_page_state(NR_ANON_PAGES));
 	printk("%ld total pagecache pages\n", global_page_state(NR_FILE_PAGES));
 
 	show_swap_cache_info();


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
