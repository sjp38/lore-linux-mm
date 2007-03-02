Date: Thu, 1 Mar 2007 23:44:05 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
In-Reply-To: <20070302071955.GA5557@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0703012335250.13224@schroedinger.engr.sgi.com>
References: <20070302042149.GB15867@wotan.suse.de>
 <Pine.LNX.4.64.0703012022320.14299@schroedinger.engr.sgi.com>
 <20070302050625.GD15867@wotan.suse.de> <Pine.LNX.4.64.0703012137580.1768@schroedinger.engr.sgi.com>
 <20070302054944.GE15867@wotan.suse.de> <Pine.LNX.4.64.0703012150290.1768@schroedinger.engr.sgi.com>
 <20070302060831.GF15867@wotan.suse.de> <Pine.LNX.4.64.0703012213130.1917@schroedinger.engr.sgi.com>
 <20070302062950.GG15867@wotan.suse.de> <Pine.LNX.4.64.0703012236160.1979@schroedinger.engr.sgi.com>
 <20070302071955.GA5557@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@skynet.ie>, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, torvalds@linux-foundation.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2 Mar 2007, Nick Piggin wrote:

> > Sure we will. And you believe that the the newer controllers will be able 
> > to magically shrink the the SG lists somehow? We will offload the 
> > coalescing of the page structs into bios in hardware or some such thing? 
> > And the vmscans etc too?
> 
> As far as pagecache page management goes, is that an issue for you?
> I don't want to know about how many billions of pages for some operation,
> just some profiles.

If there are billions of pages in the system and we are allocating and 
deallocating then pages need to be aged. If there are just few pages 
freeable then we run into issues.

> > > I understand you have controllers (or maybe it is a block layer limit)
> > > that doesn't work well with 4K pages, but works OK with 16K pages.
> > Really? This is the first that I have heard about it.
> Maybe that's the issue you're running into.

Oh, I am running into an issue on a system that does not yet exist? I am 
extrapolating from the problems that we commonly see now. Those will get 
worse the more memory increases.

> > > This is not something that we would introduce variable sized pagecache
> > > for, surely.
> > I am not sure where you get the idea that this is the sole reason why we 
> > need to be able to handle larger contiguous chunks of memory.
> I'm not saying that. You brought up this subject of variable sized pagecache.

You keep bringing up the 4k/16k issue into this for some reason. I want 
just the ability to handle large amounts of memory. Larger page sizes are 
a way to accomplish that.

> Eventually, increasing x86 page size a bit might be an idea. We could even
> do it in software if CPU manufacturers don't for us.

A bit? Are we back to the 4k/16k issue? We need to reach 2M at mininum. 
Some way to handle continuous memory segments of 1GB and larger 
effectively would be great.
  
> That doesn't buy us a great deal if you think there is this huge looming
> problem with struct page management though.

I am not the first one.... See Rik's posts regarding the reasons for his 
new page replacement algorithms.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
