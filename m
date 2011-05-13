Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E37496B0023
	for <linux-mm@kvack.org>; Fri, 13 May 2011 07:36:39 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 20CB63EE081
	for <linux-mm@kvack.org>; Fri, 13 May 2011 20:36:37 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B21545DE55
	for <linux-mm@kvack.org>; Fri, 13 May 2011 20:36:37 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E77E445DD6E
	for <linux-mm@kvack.org>; Fri, 13 May 2011 20:36:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D7DF61DB803A
	for <linux-mm@kvack.org>; Fri, 13 May 2011 20:36:36 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A5F6D1DB802C
	for <linux-mm@kvack.org>; Fri, 13 May 2011 20:36:36 +0900 (JST)
Message-ID: <4DCD1824.1060801@jp.fujitsu.com>
Date: Fri, 13 May 2011 20:38:12 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 0/3] swap token revisit
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, riel@redhat.com
Cc: kosaki.motohiro@jp.fujitsu.com

Hi

They are a patchset of swap token improvement. each patch is independent.
Probably memcg folks are interest to [1/3]. :)


KOSAKI Motohiro (3):
  vmscan,memcg: memcg aware swap token
  vmscan: implement swap token trace
  vmscan: implement swap token priority decay

 include/linux/memcontrol.h    |    6 +++
 include/linux/swap.h          |    8 +---
 include/trace/events/vmscan.h |   81 ++++++++++++++++++++++++++++++++++++++
 mm/memcontrol.c               |   16 +++----
 mm/thrash.c                   |   87 +++++++++++++++++++++++++++++++---------
 mm/vmscan.c                   |    4 +-
 6 files changed, 165 insertions(+), 37 deletions(-)

-- 
1.7.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
