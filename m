Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D19F06B0087
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 11:43:41 -0500 (EST)
Date: Wed, 8 Dec 2010 17:43:27 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] compaction: Remove mem_cgroup_del_lru
Message-ID: <20101208164327.GL2356@cmpxchg.org>
References: <1291734086-1405-1-git-send-email-minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1291734086-1405-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 08, 2010 at 12:01:26AM +0900, Minchan Kim wrote:
> del_page_from_lru_list alreay called mem_cgroup_del_lru.
> So we need to call it again. It makes wrong stat of memcg and
> even happen VM_BUG_ON hit.
> 
> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

But regarding the severity of this: shouldn't the second deletion
attempt be caught by the TestClearPageCgroupAcctLRU() early in
mem_cgroup_del_lru_list()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
