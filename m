Date: Thu, 1 Mar 2007 22:51:00 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
In-Reply-To: <20070302062950.GG15867@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0703012236160.1979@schroedinger.engr.sgi.com>
References: <20070302035751.GA15867@wotan.suse.de>
 <Pine.LNX.4.64.0703012001260.5548@schroedinger.engr.sgi.com>
 <20070302042149.GB15867@wotan.suse.de> <Pine.LNX.4.64.0703012022320.14299@schroedinger.engr.sgi.com>
 <20070302050625.GD15867@wotan.suse.de> <Pine.LNX.4.64.0703012137580.1768@schroedinger.engr.sgi.com>
 <20070302054944.GE15867@wotan.suse.de> <Pine.LNX.4.64.0703012150290.1768@schroedinger.engr.sgi.com>
 <20070302060831.GF15867@wotan.suse.de> <Pine.LNX.4.64.0703012213130.1917@schroedinger.engr.sgi.com>
 <20070302062950.GG15867@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@skynet.ie>, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, torvalds@linux-foundation.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2 Mar 2007, Nick Piggin wrote:

> > There was no talk about slightly. 1G page size would actually be quite 
> > convenient for some applications.
> 
> But it is far from convenient for the kernel. So we have hugepages, so
> we can stay out of the hair of those applications and they can stay out
> of hours.

Huge pages cannot do I/O so we would get back to the gazillions of pages 
to be handled for I/O. I'd love to have I/O support for huge pages. This 
would address some of the issues.

> > Writing a terabyte of memory to disk with handling 256 billion page 
> > structs? In case of a system with 1 petabyte of memory this may be rather 
> > typical and necessary for the application to be able to save its state
> > on disk.
> 
> But you will have newer IO controllers, faster CPUs...

Sure we will. And you believe that the the newer controllers will be able 
to magically shrink the the SG lists somehow? We will offload the 
coalescing of the page structs into bios in hardware or some such thing? 
And the vmscans etc too?

> Is it a problem or isn't it? Waving around the 256 billion number isn't
> impressive because it doesn't really say anything.

It is the number of items that needs to be handled by the I/O layer and 
likely by the SG engine.
 
> I understand you have controllers (or maybe it is a block layer limit)
> that doesn't work well with 4K pages, but works OK with 16K pages.

Really? This is the first that I have heard about it.

> This is not something that we would introduce variable sized pagecache
> for, surely.

I am not sure where you get the idea that this is the sole reason why we 
need to be able to handle larger contiguous chunks of memory.

How about coming up with a response to the issue at hand? How do I write 
back 1 Terabyte effectively? Ok this may be an exotic configuration today 
but in one year this may be much more common. Memory sizes keep on 
increasing and so is the number of page structs to be handled for I/O. At 
some point we need a solution here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
