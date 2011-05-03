Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0EDD16B0024
	for <linux-mm@kvack.org>; Tue,  3 May 2011 10:48:45 -0400 (EDT)
Received: by pwi10 with SMTP id 10so111546pwi.14
        for <linux-mm@kvack.org>; Tue, 03 May 2011 07:48:43 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v2 0/2] Fix and Enhance deactive_page
Date: Tue,  3 May 2011 23:48:31 +0900
Message-Id: <cover.1304433952.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Ying Han <yinghan@google.com>, Minchan Kim <minchan.kim@gmail.com>

A few days ago, Ying reported a problem.
http://marc.info/?l=linux-mm&m=130403310601663&w=2
After I and Ying dive in problem, We found deactive_page
has a problem. Apparently, It's a BUG so 
[1/2] is fix of the problem and [2/2] is enhancement for 
helping CPU.

* v2
  - add Reviewed-by signs
  - Fix typo

Minchan Kim (2):
  [1/2] Check PageUnevictable in lru_deactivate_fn
  [2/2] Filter unevictable page out in deactivate_page

 mm/swap.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
