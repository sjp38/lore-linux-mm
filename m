Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 920888D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 15:05:28 -0400 (EDT)
Date: Tue, 29 Mar 2011 21:05:20 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Lsf] [LSF][MM] page allocation & direct reclaim latency
Message-ID: <20110329190520.GJ12265@random.random>
References: <1301373398.2590.20.camel@mulgrave.site>
 <4D91FC2D.4090602@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4D91FC2D.4090602@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>

Hi Rik, Hugh and everyone,

On Tue, Mar 29, 2011 at 11:35:09AM -0400, Rik van Riel wrote:
> On 03/29/2011 12:36 AM, James Bottomley wrote:
> > Hi All,
> >
> > Since LSF is less than a week away, the programme committee put together
> > a just in time preliminary agenda for LSF.  As you can see there is
> > still plenty of empty space, which you can make suggestions
> 
> There have been a few patches upstream by people for who
> page allocation latency is a concern.
> 
> It may be worthwhile to have a short discussion on what
> we can do to keep page allocation (and direct reclaim?)
> latencies down to a minimum, reducing the slowdown that
> direct reclaim introduces on some workloads.

I don't see the patches you refer to, but checking schedule we've a
slot with Mel&Minchan about "Reclaim, compaction and LRU
ordering". Compaction only applies to high order allocations and it
changes nothing to PAGE_SIZE allocations, but it surely has lower
latency than the older lumpy reclaim logic so overall it should be a
net improvement compared to what we had before.

Should the latency issues be discussed in that track?

The MM schedule has still a free slot 14-14:30 on Monday, I wonder if
there's interest on a "NUMA automatic migration and scheduling
awareness" topic or if it's still too vapourware for a real topic and
we should keep it for offtrack discussions, and maybe we should
reserve it for something more tangible with patches already floating
around. Comments welcome.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
