Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 587E86B004A
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 20:27:01 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o820QxUw002610
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 2 Sep 2010 09:26:59 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DCE0045DE51
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 09:26:58 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A3DA845DE4F
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 09:26:58 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8BB931DB8054
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 09:26:58 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3604B1DB8048
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 09:26:58 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of NR_FREE_PAGES when memory is low and kswapd is awake
In-Reply-To: <alpine.DEB.2.00.1009011919110.20518@router.home>
References: <20100901203422.GA19519@csn.ul.ie> <alpine.DEB.2.00.1009011919110.20518@router.home>
Message-Id: <20100902092628.D065.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  2 Sep 2010 09:26:57 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> On Wed, 1 Sep 2010, Mel Gorman wrote:
> 
> > > > >         if (delta < 0 && abs(delta) > nr_free_pages)
> > > > >                 delta = -nr_free_pages;
> > >
> > > Not sure what the point here is. If the delta is going below zero then
> > > there was a concurrent operation updating the counters negatively while
> > > we summed up the counters.
> >
> > The point is if the negative delta is greater than the current value of
> > nr_free_pages then nr_free_pages would underflow when delta is applied to it.
> 
> Ok. then
> 
> 	nr_free_pages += delta;
> 	if (nr_free_pages < 0)
> 		nr_free_pages = 0;

nr_free_pages is unsined. this wouldn't works ;)




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
