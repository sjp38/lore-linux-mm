Date: Fri, 2 Mar 2007 08:19:55 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: The performance and behaviour of the anti-fragmentation related patches
Message-ID: <20070302071955.GA5557@wotan.suse.de>
References: <20070302042149.GB15867@wotan.suse.de> <Pine.LNX.4.64.0703012022320.14299@schroedinger.engr.sgi.com> <20070302050625.GD15867@wotan.suse.de> <Pine.LNX.4.64.0703012137580.1768@schroedinger.engr.sgi.com> <20070302054944.GE15867@wotan.suse.de> <Pine.LNX.4.64.0703012150290.1768@schroedinger.engr.sgi.com> <20070302060831.GF15867@wotan.suse.de> <Pine.LNX.4.64.0703012213130.1917@schroedinger.engr.sgi.com> <20070302062950.GG15867@wotan.suse.de> <Pine.LNX.4.64.0703012236160.1979@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703012236160.1979@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@skynet.ie>, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, torvalds@linux-foundation.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 01, 2007 at 10:51:00PM -0800, Christoph Lameter wrote:
> On Fri, 2 Mar 2007, Nick Piggin wrote:
> 
> > > There was no talk about slightly. 1G page size would actually be quite 
> > > convenient for some applications.
> > 
> > But it is far from convenient for the kernel. So we have hugepages, so
> > we can stay out of the hair of those applications and they can stay out
> > of hours.
> 
> Huge pages cannot do I/O so we would get back to the gazillions of pages 
> to be handled for I/O. I'd love to have I/O support for huge pages. This 
> would address some of the issues.

Can't direct IO from a hugepage?

> > > Writing a terabyte of memory to disk with handling 256 billion page 
> > > structs? In case of a system with 1 petabyte of memory this may be rather 
> > > typical and necessary for the application to be able to save its state
> > > on disk.
> > 
> > But you will have newer IO controllers, faster CPUs...
> 
> Sure we will. And you believe that the the newer controllers will be able 
> to magically shrink the the SG lists somehow? We will offload the 
> coalescing of the page structs into bios in hardware or some such thing? 
> And the vmscans etc too?

As far as pagecache page management goes, is that an issue for you?
I don't want to know about how many billions of pages for some operation,
just some profiles.

> > Is it a problem or isn't it? Waving around the 256 billion number isn't
> > impressive because it doesn't really say anything.
> 
> It is the number of items that needs to be handled by the I/O layer and 
> likely by the SG engine.

The number is irrelevant, it is the rate that is important.

> > I understand you have controllers (or maybe it is a block layer limit)
> > that doesn't work well with 4K pages, but works OK with 16K pages.
> 
> Really? This is the first that I have heard about it.
>

Maybe that's the issue you're running into.

> > This is not something that we would introduce variable sized pagecache
> > for, surely.
> 
> I am not sure where you get the idea that this is the sole reason why we 
> need to be able to handle larger contiguous chunks of memory.

I'm not saying that. You brought up this subject of variable sized pagecache.

> How about coming up with a response to the issue at hand? How do I write 
> back 1 Terabyte effectively? Ok this may be an exotic configuration today 
> but in one year this may be much more common. Memory sizes keep on 
> increasing and so is the number of page structs to be handled for I/O. At 
> some point we need a solution here.

Considering you're just handwaving about the actual problems, I
don't know. I assume you're sitting in front of some workload that has
gone wrong, so can't you elaborate?

Eventually, increasing x86 page size a bit might be an idea. We could even
do it in software if CPU manufacturers don't for us.

That doesn't buy us a great deal if you think there is this huge looming
problem with struct page management though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
