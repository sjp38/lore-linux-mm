Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B2D0D6B00F1
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 01:23:31 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9D5NSrj020429
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 13 Oct 2010 14:23:29 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B18FF45DE54
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 14:23:28 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 963BF45DE52
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 14:23:28 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D6861DB8012
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 14:23:28 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2DA1C1DB8014
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 14:23:25 +0900 (JST)
Date: Wed, 13 Oct 2010 14:18:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH v2] fix return value of scan_lru_pages in memory
 unplug
Message-Id: <20101013141805.f54ab59f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101013140841.ADBA.A69D9226@jp.fujitsu.com>
References: <20101013135903.c505ff8b.kamezawa.hiroyu@jp.fujitsu.com>
	<20101013140841.ADBA.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Oct 2010 14:08:57 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Also, this can be static. anyway
> 	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
yes.
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

scan_lru_pages returns pfn. So, it's type should be "unsigned long"
not "int".

Note: I guess this has been work until now because memory hotplug tester's
      machine has not very big memory....
      physical address < 32bit << PAGE_SHIFT.

Changelog v1->v2:
 - make the function static.

Reported-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
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
+static unsigned long scan_lru_pages(unsigned long start, unsigned long end)
 {
 	unsigned long pfn;
 	struct page *page;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
