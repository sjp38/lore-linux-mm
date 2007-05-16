Date: Wed, 16 May 2007 16:33:38 +0100
Subject: Re: [PATCH 1/2] Have kswapd keep a minimum order free other than order-0
Message-ID: <20070516153337.GC10225@skynet.ie>
References: <1179218576.25205.1.camel@rousalka.dyndns.org> <Pine.LNX.4.64.0705150958150.6896@skynet.skynet.ie> <464AC00E.10704@yahoo.com.au> <Pine.LNX.4.64.0705160958230.7139@skynet.skynet.ie> <464ACA68.2040707@yahoo.com.au> <Pine.LNX.4.64.0705161011400.7139@skynet.skynet.ie> <464AF8DB.9030000@yahoo.com.au> <20070516135039.GA7467@skynet.ie> <464B131F.6090904@yahoo.com.au> <1179328013.23605.1.camel@rousalka.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1179328013.23605.1.camel@rousalka.dyndns.org>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nicolas Mailhot <nicolas.mailhot@laposte.net>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>, Andy Whitcroft <apw@shadowen.org>, akpm@linux-foundation.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On (16/05/07 17:06), Nicolas Mailhot didst pronounce:
> Le jeudi 17 mai 2007 a 00:20 +1000, Nick Piggin a ecrit :
> > Mel Gorman wrote:
> > 
> > > ======
> > > 
> > > On third thought: The trouble with this solution is that we will now set
> > > the order to that used by the largest kmalloc cache. Bad... this could be
> > > 6 on i386 to 13 if CONFIG_LARGE_ALLOCs is set. The large kmalloc caches are
> > > rarely used and we are used to OOMing if those are utilized to frequently.
> > > 
> > > I guess we should only set this for non kmalloc caches then. 
> > > So move the call into kmem_cache_create? Would make the min order 3 on
> > > most of my mm machines.
> > > ===
> > 
> > Also, I might add that the e1000 page allocations failures usually come
> > from kmalloc, so doing this means they might just be protected by chance
> > if someone happens to create a kmem cache of order 3.
> 
> The system on which the patches were tested does not include an e1000
> card
> 

We know. It's simply a case that in the past, e1000 failing to allocate pages
was the reason to receive reports like yours. They are some similarities in
the problems.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
