Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id B2B7A6B0012
	for <linux-mm@kvack.org>; Wed, 25 May 2011 03:07:57 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 745D13EE0AE
	for <linux-mm@kvack.org>; Wed, 25 May 2011 16:07:53 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5444645DEF3
	for <linux-mm@kvack.org>; Wed, 25 May 2011 16:07:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A16945DF57
	for <linux-mm@kvack.org>; Wed, 25 May 2011 16:07:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1CDAC1DB8043
	for <linux-mm@kvack.org>; Wed, 25 May 2011 16:07:53 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D9DB71DB803E
	for <linux-mm@kvack.org>; Wed, 25 May 2011 16:07:52 +0900 (JST)
Message-ID: <4DDCAAC0.20102@jp.fujitsu.com>
Date: Wed, 25 May 2011 16:07:44 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 0/4] fix pagewalk minor issues
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, kamezawa.hiroyu@jp.fujitsu.com
Cc: kosaki.motohiro@jp.fujitsu.com

While reviewing Stephen's numa_maps improvement, I've found recent pagewalk changes
made some minor issues.

This series fix them. I think only [1/4] need to backport to -stable.


KOSAKI Motohiro (4):
  pagewalk: Fix walk_page_range() don't check find_vma() result
    properly
  pagewalk: don't look up vma if walk->hugetlb_entry is unused
  pagewalk: add locking-rule commnets
  pagewalk: fix code comment for THP

 include/linux/mm.h |    1 +
 mm/pagewalk.c      |   49 ++++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 43 insertions(+), 7 deletions(-)

-- 
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
