Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAP4U0kT027692
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 25 Nov 2008 13:30:01 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8008C45DD79
	for <linux-mm@kvack.org>; Tue, 25 Nov 2008 13:30:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6087545DD77
	for <linux-mm@kvack.org>; Tue, 25 Nov 2008 13:30:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3317C1DB8040
	for <linux-mm@kvack.org>; Tue, 25 Nov 2008 13:30:00 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DBAA01DB8044
	for <linux-mm@kvack.org>; Tue, 25 Nov 2008 13:29:59 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] mm: make setup_per_zone_inactive_ratio() static
In-Reply-To: <20081125131942.26CD.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081125131942.26CD.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20081125132919.26DF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 25 Nov 2008 13:29:59 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Sparse output following warning.

mm/page_alloc.c:4301:6: warning: symbol 'setup_per_zone_inactive_ratio' was not declared. Should it be static?

cleanup here.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 mm/page_alloc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c	2008-11-22 22:38:20.000000000 +0900
+++ b/mm/page_alloc.c	2008-11-22 22:38:40.000000000 +0900
@@ -4298,7 +4298,7 @@ void setup_per_zone_pages_min(void)
  *    1TB     101        10GB
  *   10TB     320        32GB
  */
-void setup_per_zone_inactive_ratio(void)
+static void setup_per_zone_inactive_ratio(void)
 {
 	struct zone *zone;
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
