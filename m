Message-Id: <200108161250.f7GCo8w13004@mailc.telia.com>
Content-Type: text/plain;
  charset="iso-8859-1"
From: Roger Larsson <roger.larsson@norran.net>
Subject: Re: [RFC][PATCH] alternative way of calculating inactive_target
Date: Thu, 16 Aug 2001 14:45:51 +0200
References: <200108160337.FAA11729@mailb.telia.com> <20010816084939Z16265-1231+1158@humbolt.nl.linux.org>
In-Reply-To: <20010816084939Z16265-1231+1158@humbolt.nl.linux.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, Daniel Phillips <phillips@bonn-fries.net>
Cc: "Scott F. Kaplan" <sfkaplan@cs.amherst.edu>
List-ID: <linux-mm.kvack.org>

On Thursday den 16 August 2001 10:55, Daniel Phillips wrote:
> On August 16, 2001 05:33 am, Roger Larsson wrote:
> > Hi,
> >
> > 1. Two things in this file, first an unrelated issue (but included in the
> > patch) global_target in free_shortage shouldn't it be freepages.low?
> > Traditionally freepages.high has been when to stop freeing pages.
> >
> > 2. I have wondered about how inactive_target is calculated.
> > This is an alternative approach...
> >
> > In this alternative approach I use two wrapping counters.
> > (memory_clock & memory_clock_rubberband)
> >
> > memory_clock is incremented only when allocating pages (and it
> > is never decremented)
>
> Yes, exactly, did you read my mind?  Page units are the natural quantum
> of the time base for the whole mm.  When we clock all mm events according
> to the (__alloc_page << order) timebase then lots of memory spikes are
> magically transformed into smooth curves and it becomes immediately
> obvious how much scanning we need to do at each instant.  Now, warning,
> this is a major shift in viewpoint and I'll wager, unwelcome on this side
> of the 2.5 split.  I'd be happy to work with you doing a skunkworks-type
> proof-of-concept though.
>

The idea of using memory allocations as basis for a clock I got from Scott F 
Kaplan and his thesis. "Compressed Caching and Modern Virtual Memory 
Simulation" see chapter 2.1.4 'Timescale Relativity I: Virtual Memory Time 
and "Soonness"'


> > memory_clock_rubberband is calculated to be close to what
> > memory_clock should have been for MEMORY_CLOCK_WINDOW seconds
> > earlier, using current values and information about how long it was since
> > it was updated the last time. This makes it possible to recalculate the
> > target more often when pressure is high - and it simplifies kswapd too...
>
> I'll supply a cute, efficient filter that does what you're doing with the
> rubberband with a little stronger theoretical basis, as soon as I wake up
> again.  Or you can look for my earlier "Early flush with bandwidth
> estimation" post.  (Try to ignore the incorrect volatile handling please.)
>
> BTW, you left out an interesting detail: any performance measurements
> you've already done.

I had not done many at that point in time - it was LATE, it did run... etc...
Now I have some data. (but I had changed a limit too)
In the tests I have run the difference is nothing consistently better NOR 
worse.

/RogerL


-- 
Roger Larsson
Skelleftea
Sweden
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
