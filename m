Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B75F86B0169
	for <linux-mm@kvack.org>; Wed, 27 Jul 2011 16:16:57 -0400 (EDT)
Date: Wed, 27 Jul 2011 13:16:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 00/10] Prevent LRU churning
Message-Id: <20110727131650.ad30a331.akpm@linux-foundation.org>
In-Reply-To: <cover.1309787991.git.minchan.kim@gmail.com>
References: <cover.1309787991.git.minchan.kim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>

On Mon,  4 Jul 2011 23:04:33 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> Test result is following as.
> 
> 1) Elapased time 10GB file decompressed.
> Old			inorder			inorder + pagevec flush[10/10]
> 01:47:50.88		01:43:16.16		01:40:27.18
> 
> 2) failure of inorder lru
> For test, it isolated 375756 pages. Only 45875 pages(12%) are put backed to
> out-of-order(ie, head of LRU) Others, 329963 pages(88%) are put backed to in-order
> (ie, position of old page in LRU).

I'm getting more and more worried about how complex MM is becoming and
this patchset doesn't take us in a helpful direction :(

But it's hard to argue with numbers like that.  Please respin patches 6-10?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
