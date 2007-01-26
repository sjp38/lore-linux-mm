Date: Fri, 26 Jan 2007 11:46:15 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 0/8] Create ZONE_MOVABLE to partition memory between
 movable and non-movable pages
Message-Id: <20070126114615.5aa9e213.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0701260751230.6141@schroedinger.engr.sgi.com>
References: <20070125234458.28809.5412.sendpatchset@skynet.skynet.ie>
	<20070126030753.03529e7a.akpm@osdl.org>
	<Pine.LNX.4.64.0701260751230.6141@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <clameter@engr.sgi.com>
List-ID: <linux-mm.kvack.org>

On Fri, 26 Jan 2007 07:56:09 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Fri, 26 Jan 2007, Andrew Morton wrote:
> 
> > - They add zillions of ifdefs
> 
> They just add a few for ZONE_DMA where we alreaday have similar ifdefs for 
> ZONE_DMA32 and ZONE_HIGHMEM.

I refreshed my memory.  It remains awful.

> > - They make the VM's behaviour diverge between different platforms and
> >   between differen configs on the same platforms, and hence degrade
> >   maintainability and increase complexity.
> 
> They avoid unecessary complexity on platforms. They could be made to work 
> on more platforms with measures to deal with what ZONE_DMA 
> provides in different ways. There are 6 or so platforms that do not need 
> ZONE_DMA at all.

As Mel points out, distros will ship with CONFIG_ZONE_DMA=y, so the number
of machines which will actually benefit from this change is really small. 
And the benefit to those few machines will also, I suspect, be small.

> > - We kicked around some quite different ways of implementing the same
> >   things, but nothing came of it.  iirc, one was to remove the hard-coded
> >   zones altogether and rework all the MM to operate in terms of
> > 
> > 	for (idx = 0; idx < NUMBER_OF_ZONES; idx++)
> > 		...
> 
> Hmmm.. How would that be simpler?

Replace a sprinkle of open-coded ifdefs with a regular code sequence which
everyone uses.  Pretty obvious, I'd thought.

Plus it becoems straightforward to extend this from the present four zones
to a complete 12 zones, which gives use the full set of
ZONE_DMA20,ZONE_DMA21,...,ZONE_DMA32 for those funny devices.

> > - I haven't seen any hard numbers to justify the change.
> 
> I have send you numbers showing significant reductions in code size.

If it isn't in the changelog it doesn't exist.  I guess I didn't copy it
into the changelog.

If the only demonstrable benefit is a saving of a few k of text on a small
number of machines then things are looking very grim, IMO.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
