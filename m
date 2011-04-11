Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5A91C8D003B
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 03:59:37 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 6FF473EE081
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 16:59:32 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 542DD45DE96
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 16:59:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B87745DE92
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 16:59:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2CF38E08005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 16:59:32 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id EC63DE08003
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 16:59:31 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [patch 0/3 resend] mm, mem-hotplug: proper maintainance zone attribute when memory hotplug occur
Message-Id: <20110411165957.0352.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 11 Apr 2011 16:59:31 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Yasunori Goto <y-goto@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>
Cc: kosaki.motohiro@jp.fujitsu.com

Hi,

This is resending very old patch. The code has no change.


KOSAKI Motohiro (3):
  mm, mem-hotplug: fix section mismatch.
    setup_per_zone_inactive_ratio() should be __meminit.
  mm, mem-hotplug: recalculate lowmem_reserve when memory hotplug occur
  mm, mem-hotplug: update pcp->stat_threshold when memory hotplug occur

 include/linux/mm.h     |    2 +-
 include/linux/vmstat.h |    1 +
 mm/memory_hotplug.c    |   13 +++++++------
 mm/page_alloc.c        |    8 +++++---
 mm/vmstat.c            |    3 +--
 5 files changed, 15 insertions(+), 12 deletions(-)

-- 
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
