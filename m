Date: Thu, 24 Jul 2008 08:20:10 -0400
From: Rik van Riel <riel@surriel.com>
Subject: Re: [RFC][PATCH -mm] vmscan: fix swapout on sequential IO
Message-ID: <20080724082010.49546f60@bree.surriel.com>
In-Reply-To: <20080724152555.869D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080723144115.72803eb8@bree.surriel.com>
	<20080724152555.869D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@saeurebad.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 24 Jul 2008 15:26:44 +0900
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > -			zone->lru[l].nr_scan += scan + 1;
> > +			zone->lru[l].nr_scan += scan + force_scan;
> >  			nr[l] = zone->lru[l].nr_scan;
> >  			if (nr[l] >= sc->swap_cluster_max)
> >  				zone->lru[l].nr_scan = 0;
> 
> looks good to me.
> 
> 	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

I'm still benchmarking it, against 2.6.26, 2.6.26-rc8-mm1 and
2.6.26-rc8-mm1 with the "evict cache first" patch.

So far the results look promising.  I hope to publish the
benchmark results later today, when I have a full set of
all tests against all these kernels.

I have been running tests for about a week now.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
