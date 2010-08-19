Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 57C476B02C2
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 15:01:09 -0400 (EDT)
Date: Thu, 19 Aug 2010 14:00:44 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of
 NR_FREE_PAGES when memory is low and kswapd is awake
In-Reply-To: <20100819090740.3f46aecf.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1008191359400.1839@router.home>
References: <1281951733-29466-1-git-send-email-mel@csn.ul.ie> <1281951733-29466-3-git-send-email-mel@csn.ul.ie> <20100818115949.c840c937.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1008181050230.4025@router.home>
 <20100819090740.3f46aecf.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

n Thu, 19 Aug 2010, KAMEZAWA Hiroyuki wrote:

> > > This function is now called only at CPU_DEAD. IOW, not called at CPU_UP_PREPARE
> >
> > calculate_threshold() does its calculation based on the number of online
> > cpus. Therefore the threshold may change if a cpu is brought down.
> >
> yes. but why not calculate at bringing up ?

True. Seems to have gone missing somehow.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
