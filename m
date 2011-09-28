Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D09509000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 20:04:39 -0400 (EDT)
Date: Wed, 28 Sep 2011 10:04:29 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Why isn't shrink_slab more zone oriented ?
Message-ID: <20110928000429.GD3159@dastard>
References: <CAFPAmTRHFOT+tc=J-=jTBpvi8ksnp6H32UsEwptrrv=hagjUsA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFPAmTRHFOT+tc=J-=jTBpvi8ksnp6H32UsEwptrrv=hagjUsA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "kautuk.c @samsung.com" <consul.kautuk@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Sep 26, 2011 at 05:21:12PM +0530, kautuk.c @samsung.com wrote:
> Hi,
> 
> I was going through the do_try_to_free_pages(), balance_pgdat(),
> __zone_reclaim()
> functions and I see that shrink_zone and shrink_slab are called for each zone.
> 
> But, shrink_slab() doesn't seem to bother about the zone from where it
> is freeing
> memory.

Work is in progress to do this.

http://lwn.net/Articles/456071/

Dirty slab objects are currently not tracked in a manner that makes
per-zone reclaim efficient to do, os that needs to be corrected
first.  Once we have generic per-zone LRU infrastructure, then we
can easily push zone reclaim hints down into the shrinkers for them
to scan the appropriate LRU....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
