Date: Mon, 12 Nov 2007 11:17:39 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Page allocator: Clean up pcp draining functions
In-Reply-To: <20071112160451.GC6653@skynet.ie>
Message-ID: <Pine.LNX.4.64.0711121115180.26682@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0711091840410.18588@schroedinger.engr.sgi.com>
 <20071112160451.GC6653@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Yasunori Goto <y-goto@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>
List-ID: <linux-mm.kvack.org>

On Mon, 12 Nov 2007, Mel Gorman wrote:

> Reflecting the comment, perhaps the following would not hurt?
> 
> VM_BUG_ON(cpu != smp_processor_id() && cpu_online(cpu))

Well we need to check first with the hotplug developers if the cpu is 
already marked off line when this function is called.

> >  	if (action == CPU_DEAD || action == CPU_DEAD_FROZEN) {
> > -		local_irq_disable();
> > -		__drain_pages(cpu);
> > +		drain_pages(cpu);
> > +
> > +		/*
> > +		 * Spill the event counters of the dead processor
> > +		 * into the current processors event counters.
> > +		 * This artificially elevates the count of the current
> > +		 * processor.
> > +		 */
> 
> This comment addition does not appear to be related to the rest of the
> patch.

Its related to the action of vm_events_fold_cpu which is not that 
unproblematic since the numbers indicate now that more events occurred on 
this processor than what actually occurred.

> Acked-by: Mel Gorman <mel@csn.ul.ie>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
