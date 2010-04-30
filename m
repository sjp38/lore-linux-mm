Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 293326004BC
	for <linux-mm@kvack.org>; Fri, 30 Apr 2010 19:06:04 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/5] vmscan: cut down on struct scan_control
Date: Sat,  1 May 2010 01:05:28 +0200
Message-Id: <20100430222009.379195565@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

here are 5 patches that remove 4 members from struct scan_control.

sc->may_unmap is no longer used after patch #1, sc->may_swap is folded
into sc->swappiness, sc->all_unreclaimable is made a return value, and
sc->isolate_pages is replaced with a branch on sc->mem_cgroup (reusing
a nearby branch, so no additional one) and direct function calling.

So nothing too spectecular.  It saves a bit of code and 2 to 4 stack
words depending on the wordsize and call path.

	Hannes

 include/linux/memcontrol.h |   13 +++--
 include/linux/swap.h       |    4 -
 mm/memcontrol.c            |   13 +++--
 mm/vmscan.c                |  105 ++++++++++++++++++---------------------------
 4 files changed, 61 insertions(+), 74 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
