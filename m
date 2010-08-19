Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1CE896B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 20:12:42 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7J0Cc2L028171
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 19 Aug 2010 09:12:38 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 06BBF45DE5D
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 09:12:38 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D92B545DE55
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 09:12:37 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BE6BB1DB803F
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 09:12:37 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D1BC1DB803E
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 09:12:37 +0900 (JST)
Date: Thu, 19 Aug 2010 09:07:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of
 NR_FREE_PAGES when memory is low and kswapd is awake
Message-Id: <20100819090740.3f46aecf.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1008181050230.4025@router.home>
References: <1281951733-29466-1-git-send-email-mel@csn.ul.ie>
	<1281951733-29466-3-git-send-email-mel@csn.ul.ie>
	<20100818115949.c840c937.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1008181050230.4025@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 18 Aug 2010 10:55:53 -0500 (CDT)
Christoph Lameter <cl@linux-foundation.org> wrote:

> On Wed, 18 Aug 2010, KAMEZAWA Hiroyuki wrote:
> 
> > BTW, a nitpick.
> >
> > > @@ -143,6 +143,9 @@ static void refresh_zone_stat_thresholds(void)
> > >  		for_each_online_cpu(cpu)
> > >  			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
> > >  							= threshold;
> > > +
> > > +		zone->percpu_drift_mark = high_wmark_pages(zone) +
> > > +					num_online_cpus() * threshold;
> > >  	}
> > >  }
> >
> > This function is now called only at CPU_DEAD. IOW, not called at CPU_UP_PREPARE
> 
> calculate_threshold() does its calculation based on the number of online
> cpus. Therefore the threshold may change if a cpu is brought down.
> 
yes. but why not calculate at bringing up ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
