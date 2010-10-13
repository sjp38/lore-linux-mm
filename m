Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1FC826B00EB
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 01:04:54 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9D54o0v003202
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 13 Oct 2010 14:04:51 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A4E4B45DE51
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 14:04:50 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7215345DE4F
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 14:04:50 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F8211DB8040
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 14:04:50 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BDC7A1DB803B
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 14:04:49 +0900 (JST)
Date: Wed, 13 Oct 2010 13:59:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH] fix return value of scan_lru_pages in memory unplug
Message-Id: <20101013135903.c505ff8b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

CC'ed to stable tree...maybe all kernel has this bug.
But this may not very critical because we've got no report until now.

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

scan_lru_pages returns pfn. So, it's type should be "unsigned long"
not "int".

Note: I guess this has been work until now because memory hotplug tester's
      machine has not very big memory....
      physical address < 32bit << PAGE_SHIFT.

Reported-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memory_hotplug.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: mmotm-1008/mm/memory_hotplug.c
===================================================================
--- mmotm-1008.orig/mm/memory_hotplug.c
+++ mmotm-1008/mm/memory_hotplug.c
@@ -646,7 +646,7 @@ static int test_pages_in_a_zone(unsigned
  * Scanning pfn is much easier than scanning lru list.
  * Scan pfn from start to end and Find LRU page.
  */
-int scan_lru_pages(unsigned long start, unsigned long end)
+unsigned long scan_lru_pages(unsigned long start, unsigned long end)
 {
 	unsigned long pfn;
 	struct page *page;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
