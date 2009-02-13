Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id AFFBF6B009A
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 19:16:16 -0500 (EST)
Received: by ti-out-0910.google.com with SMTP id u3so597094tia.8
        for <linux-mm@kvack.org>; Thu, 12 Feb 2009 16:16:13 -0800 (PST)
Date: Fri, 13 Feb 2009 09:15:39 +0900
From: MinChan Kim <minchan.kim@gmail.com>
Subject: [patch 0/2 v2] vmscan: one cleanup, one bugfix
Message-Id: <20090213091539.e26e5e8e.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, MinChan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>


Hi Andrew,

the first patch is that it moves the suspend-to-disk memory
shrinking functions to use sc.nr_reclaimed all over instead of maintaining
an extra local variable. It was suggested by Kosaki-san and modified 
by me and Hannes. 

The second patch which is written by Hannes is a bugfix 
for shrink_all_memory() which currently does reclaim more than requested 
because of setting swap_cluster_max once to our overall reclaim goal 
but failing to decrease it while we go and reclaim is making progress.  
Hannes added Nigel Cunningham to Cc because ISTR he complained
about exactly this behaviour.  Well, this patch seems to fix it, Hannes even
added some shiny numbers coming from real tests!

I just remaked second patch based on my first patch.
Notice that it is just Hannes's contribution. :)

-- 
Kinds Regards
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
