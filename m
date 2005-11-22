Date: Tue, 22 Nov 2005 10:19:48 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/5] Light Fragmentation Avoidance V20: 002_usemap
In-Reply-To: <4382EF48.1050107@shadowen.org>
Message-ID: <Pine.LNX.4.58.0511221017060.31192@skynet>
References: <20051115164946.21980.2026.sendpatchset@skynet.csn.ul.ie>
 <200511160036.54461.ak@suse.de> <Pine.LNX.4.58.0511160137540.8470@skynet>
 <200511160252.05494.ak@suse.de> <Pine.LNX.4.58.0511160200530.8470@skynet>
 <4382EF48.1050107@shadowen.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andi Kleen <ak@suse.de>, linux-mm@kvack.org, mingo@elte.hu, lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Tue, 22 Nov 2005, Andy Whitcroft wrote:

> Mel Gorman wrote:
>
> > That's iterating through, potentially, 1024 pages which I considered too
> > expensive. In terms of code complexity, the page-flags patch adds 237
> > which is not much of a saving in comparison to 275 that the usemap
> > approach uses.
>
> Surley you would just use a single bit in the first page of a MAX_ORDER
> block.

No, because you need the flag at free time to determine what list is
should be going to. There is no guarantee that the first page remains
allocated or that it has not been used for fallback.

> We guarentee that the mem_map is contigious out to MAX_ORDER
> pages so you can simply calculate the offset.  The page free path does
> the same thing to find the buddy pages when coallescing.
>

That's finding buddies, not finding the first page in the MAX_ORDER block.

I revisited the page-flag approach anyway and got it working properly. It
currently stands at 160 code insertions. It's been run through benchmarks
at the moment.

> > Again, I can revisit the page-flag approach if I thought that something
> > like this would get merged and people would not choke on another page flag
> > being consumed.
>
> All of that said, I am not even sure we have a bit left in the page
> flags on smaller architectures :/.
>



> -apw
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

-- 
Mel Gorman
Part-time Phd Student                          Java Applications Developer
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
