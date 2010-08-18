Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 907896B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 11:55:58 -0400 (EDT)
Date: Wed, 18 Aug 2010 10:55:53 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of
 NR_FREE_PAGES when memory is low and kswapd is awake
In-Reply-To: <20100818115949.c840c937.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1008181050230.4025@router.home>
References: <1281951733-29466-1-git-send-email-mel@csn.ul.ie> <1281951733-29466-3-git-send-email-mel@csn.ul.ie> <20100818115949.c840c937.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 18 Aug 2010, KAMEZAWA Hiroyuki wrote:

> BTW, a nitpick.
>
> > @@ -143,6 +143,9 @@ static void refresh_zone_stat_thresholds(void)
> >  		for_each_online_cpu(cpu)
> >  			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
> >  							= threshold;
> > +
> > +		zone->percpu_drift_mark = high_wmark_pages(zone) +
> > +					num_online_cpus() * threshold;
> >  	}
> >  }
>
> This function is now called only at CPU_DEAD. IOW, not called at CPU_UP_PREPARE

calculate_threshold() does its calculation based on the number of online
cpus. Therefore the threshold may change if a cpu is brought down.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
