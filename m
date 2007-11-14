Date: Wed, 14 Nov 2007 18:13:45 +0000
Subject: Re: Page allocator: Clean up pcp draining functions
Message-ID: <20071114181345.GD773@skynet.ie>
References: <Pine.LNX.4.64.0711091840410.18588@schroedinger.engr.sgi.com> <20071112160451.GC6653@skynet.ie> <Pine.LNX.4.64.0711121115180.26682@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0711121115180.26682@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Yasunori Goto <y-goto@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>
List-ID: <linux-mm.kvack.org>

On (12/11/07 11:17), Christoph Lameter didst pronounce:
> On Mon, 12 Nov 2007, Mel Gorman wrote:
> 
> > Reflecting the comment, perhaps the following would not hurt?
> > 
> > VM_BUG_ON(cpu != smp_processor_id() && cpu_online(cpu))
> 
> Well we need to check first with the hotplug developers if the cpu is 
> already marked off line when this function is called.
> 

Fair point, best left as is for the moment.

> > >  	if (action == CPU_DEAD || action == CPU_DEAD_FROZEN) {
> > > -		local_irq_disable();
> > > -		__drain_pages(cpu);
> > > +		drain_pages(cpu);
> > > +
> > > +		/*
> > > +		 * Spill the event counters of the dead processor
> > > +		 * into the current processors event counters.
> > > +		 * This artificially elevates the count of the current
> > > +		 * processor.
> > > +		 */
> > 
> > This comment addition does not appear to be related to the rest of the
> > patch.
> 
> Its related to the action of vm_events_fold_cpu which is not that 
> unproblematic since the numbers indicate now that more events occurred on 
> this processor than what actually occurred.
> 

Yeah, I've no problem with the comment itself - I just wanted to be sure
it was not part of some other patchset by accident. I'm happy with it
now as-is.

> > Acked-by: Mel Gorman <mel@csn.ul.ie>
> 
> Thanks.
> 

-- 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
