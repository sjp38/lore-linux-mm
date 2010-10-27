Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 003C86B0085
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 04:47:36 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 0/2] Reduce the amount of time spent in watermark-related functions
Date: Wed, 27 Oct 2010 09:47:34 +0100
Message-Id: <1288169256-7174-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shaohua Li <shaohua.li@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

The following two patches are in response to a bug report by Shaohua Li
where the amount of time spent in zone_nr_free_pages() is unacceptable
for large machines. All the background is in the first patches leader. The
second patch replaces two setter functions with one function that takes a
callback function as a parameter.

Mel Gorman (2):
  mm: page allocator: Adjust the per-cpu counter threshold when memory
    is low
  mm: vmstat: Use a single setter function and callback for adjusting
    percpu thresholds

 include/linux/mmzone.h |   10 +++-------
 include/linux/vmstat.h |    7 +++++++
 mm/mmzone.c            |   21 ---------------------
 mm/page_alloc.c        |   35 +++++++++++++++++++++++++++--------
 mm/vmscan.c            |   25 +++++++++++++++----------
 mm/vmstat.c            |   32 +++++++++++++++++++++++++++++---
 6 files changed, 81 insertions(+), 49 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
