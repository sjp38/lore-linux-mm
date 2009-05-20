Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0E8636B005A
	for <linux-mm@kvack.org>; Wed, 20 May 2009 03:18:15 -0400 (EDT)
Received: by wf-out-1314.google.com with SMTP id 25so87274wfa.11
        for <linux-mm@kvack.org>; Wed, 20 May 2009 00:18:32 -0700 (PDT)
Date: Wed, 20 May 2009 16:18:22 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH 0/3] fix zone watermark and inactive ration when memory hot
 plug occur
Message-Id: <20090520161822.e2f2d94a.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>


This patch series clean up setup_per_zone_pages_min 
and fix memory hotplug bug. (watermark, inactive ratio of zone)

Patch 1/3 is independent of others.

But I just add it for convinient since it is tivial.
If anyone want to devide it, i will do it. 

patch 1/3 - change setup_per_zone_pages_min function name 
patch 2/3 - devide setup_per_zone_inactive_ratio with per 
zone function. this patch helps 3/3
patch 3/3 - reset wmark_min and inactive ratio of zone when 
hotplug happens


 include/linux/mm.h  |    3 ++- 
 mm/memory_hotplug.c |    6 +++++-
 mm/page_alloc.c     |   28 ++++++++++++++++------------
 3 files changed, 23 insertions(+), 14 deletions(-)

-- 
Kinds Regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
