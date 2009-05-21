Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 735E16B0055
	for <linux-mm@kvack.org>; Wed, 20 May 2009 20:22:49 -0400 (EDT)
Received: by fxm12 with SMTP id 12so1130015fxm.38
        for <linux-mm@kvack.org>; Wed, 20 May 2009 17:23:08 -0700 (PDT)
Date: Thu, 21 May 2009 09:22:44 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH 0/3]  fix zone watermark and inactive ration when memory
 hotplug occur  V2
Message-Id: <20090521092244.244a17c6.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Yasunori Goto <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Changelog since V1 
 o Add reviewd-by and acked-by
 o Change functions name properly. 

Thanks for careful review. Mel, KOSAKI, Yasunori. 

This patch series clean up setup_per_zone_pages_min 
and fix memory hotplug bug. (watermark, inactive ratio of zone)

Patch 1/3 is independent of others.

But I just add it for convinient since it is tivial.
If anyone want to devide it, i will do it. 

patch 1/3 - change function name related to pages_min
patch 2/3 - devide setup_per_zone_inactive_ratio with per 
zone function. this patch helps 3/3
patch 3/3 - reset wmark_min and inactive ratio of zone when 
hotplug happens

 include/linux/mm.h  |    3 ++-
 mm/memory_hotplug.c |    6 +++++-
 mm/page_alloc.c     |   43 ++++++++++++++++++++++++-------------------
 3 files changed, 31 insertions(+), 21 deletions(-)


-- 
Kinds Regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
