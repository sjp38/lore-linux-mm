Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id ACFC06B0012
	for <linux-mm@kvack.org>; Wed, 25 May 2011 03:11:38 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id CF4BC3EE081
	for <linux-mm@kvack.org>; Wed, 25 May 2011 16:11:35 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B672945DF55
	for <linux-mm@kvack.org>; Wed, 25 May 2011 16:11:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9433945DF58
	for <linux-mm@kvack.org>; Wed, 25 May 2011 16:11:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 85D92E08001
	for <linux-mm@kvack.org>; Wed, 25 May 2011 16:11:35 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4FAD31DB803A
	for <linux-mm@kvack.org>; Wed, 25 May 2011 16:11:35 +0900 (JST)
Message-ID: <4DDCABA0.4000207@jp.fujitsu.com>
Date: Wed, 25 May 2011 16:11:28 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 4/4] pagewalk: fix code comment for THP
References: <4DDCAAC0.20102@jp.fujitsu.com>
In-Reply-To: <4DDCAAC0.20102@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@jp.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, kamezawa.hiroyu@jp.fujitsu.com

commit bae9c19bf1 (thp: split_huge_page_mm/vma) changed locking behavior
of walk_page_range(). Thus this patch changes comment too.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/pagewalk.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index f792940..2f5cf10 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -176,7 +176,8 @@ static int walk_hugetlb_range(struct vm_area_struct *vma,
  * associated range, and a copy of the original mm_walk for access to
  * the ->private or ->mm fields.
  *
- * No locks are taken, but the bottom level iterator will map PTE
+ * Usually no locks are taken, but splitting transparent huge page may
+ * take page table lock. And the bottom level iterator will map PTE
  * directories from highmem if necessary.
  *
  * If any callback returns a non-zero value, the walk is aborted and
-- 
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
