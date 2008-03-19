Subject: Re: [patch 7/9] slub: Adjust order boundaries and minimum objects
	per slab.
From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
In-Reply-To: <Pine.LNX.4.64.0803181159450.23790@schroedinger.engr.sgi.com>
References: <20080317230516.078358225@sgi.com>
	 <20080317230529.474353536@sgi.com> <47E00FEF.10604@cs.helsinki.fi>
	 <Pine.LNX.4.64.0803181159450.23790@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=utf-8
Date: Wed, 19 Mar 2008 09:04:29 +0800
Message-Id: <1205888669.3215.587.camel@ymzhang>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mel@csn.ul.ie>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2008-03-18 at 12:00 -0700, Christoph Lameter wrote:
> On Tue, 18 Mar 2008, Pekka Enberg wrote:
> 
> > Christoph Lameter wrote:
> > > Since there is now no worry anymore about higher order allocs (hopefully).
> > > Set the max order to default to PAGE_ALLOC_ORDER_COSTLY (32k) and require
> > > slub to use a higher order if a certain object density cannot be reached.
> > > 
> > > The mininum objects per slab is calculated based on the number of processors
> > > that may come online.
> > 
> > Interesting. Why do we want to make min objects depend on CPU count and not
> > amount of memory available on the system?
> 
> Yanmin found a performance correlation with processors. He may be able to 
> expand on that.
>From performance point of view, slab alloc/free competition among processes and processors
is one of the key bootlenecks. If a server has more processors, usually it means more
processes run on it, and the competition is more severe.

I did lots of testing with hackbench on my 8-core stoakley and 16-core tigerton. Pls. find
the data in discussion thread http://marc.info/?l=linux-kernel&m=120581108329033&w=2.

As you know, amount of memory is a direct factor to have impact on the min objects
obviously, but I think mostly it is from memory fragmentation or something else. I have testing
data to verify the correlation with processors, but have no data about amount of memory.

In the other hand, memory is very cheap now. Usually users could install lots of memory
in server. So the competition among processors/processes are more severe.

If both processor number and amount of memory are the input factor for min objects, I have
no objections but asking highlighting processer number. If not, I will like to choose processor
number.

-yanmin


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
