Message-ID: <396653EC.5D146D55@norran.net>
Date: Sat, 08 Jul 2000 00:04:28 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: [linux-audio-dev] Re: [PATCH really] latency improvements, one
 reschedule moved
References: <395D520C.F16DD7D6@norran.net> <39628664.7756172A@norran.net>
		<39638C9B.64AB2544@norran.net> <873dlnkpk1.fsf@atlas.iskon.hr>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: zlatko@iskon.hr
Cc: Linus Torvalds <torvalds@transmeta.com>, "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Zlatko Calusic wrote:
> 
> Roger Larsson <roger.larsson@norran.net> writes:
> 
> > Again... :-(
> >
> > Patch included this time...
> >
> 
> Hi, Roger, Linus, others!
> 
> 2.4.0-test3-pre4 (which includes this patch) is really a pleasant
> surprise. The I/O bandwidth has greatly improved and I'm still trying
> to understand how can patch this simple be so effective. :)
> 
> Great work Roger!
> 
> I see this as the first (and most critical) step of returning my faith
> in good performing 2.4.0-final.
> 
> Keep up the good work!
> --
> Zlatko

It was not intended to give better performance...
(something masks the expected latency improvements - floppy is
disturbing
 me, recal_interrupt. And kmem stuff - but that is more understandable
 we will issue additional 'kmem_cache_reap']


I examined the patches again and the fact that it runs
do_try_to_free_pages
periodically may improve performance due to its page cleaning effect -
all pages won't be dirty at the same time...

But it has a downside too - it will destroy the LRU order of pages...
PG_referenced loses some of its meaning...

Streaming writes are likely to gain the most.
Non uniform random accesses may loose :-(


I have an idea...

/RogerL

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
