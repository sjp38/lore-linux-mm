Date: Thu, 1 Mar 2007 22:19:48 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
In-Reply-To: <20070302060831.GF15867@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0703012213130.1917@schroedinger.engr.sgi.com>
References: <20070301160915.6da876c5.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0703011854540.5530@schroedinger.engr.sgi.com>
 <20070302035751.GA15867@wotan.suse.de> <Pine.LNX.4.64.0703012001260.5548@schroedinger.engr.sgi.com>
 <20070302042149.GB15867@wotan.suse.de> <Pine.LNX.4.64.0703012022320.14299@schroedinger.engr.sgi.com>
 <20070302050625.GD15867@wotan.suse.de> <Pine.LNX.4.64.0703012137580.1768@schroedinger.engr.sgi.com>
 <20070302054944.GE15867@wotan.suse.de> <Pine.LNX.4.64.0703012150290.1768@schroedinger.engr.sgi.com>
 <20070302060831.GF15867@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@skynet.ie>, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, torvalds@linux-foundation.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2 Mar 2007, Nick Piggin wrote:

> > >From the I/O controller and from the application. 
> 
> Why doesn't the application need to deal with TLB entries?

Because it may only operate on a small section of the file and hopefully 
splice the rest through? But yes support for mmapped I/O would be 
necessary.

> > This would only be a temporary fix pushing the limits to the double or so?
> 
> And using slightly larger page sizes isn't?

There was no talk about slightly. 1G page size would actually be quite 
convenient for some applications.

> > Amortized? The controller still would have to hunt down the 4kb page 
> > pieces that we have to feed him right now. Result: Huge scatter gather 
> > lists that may themselves create issues with higher page order.
> 
> What sort of numbers do you have for these controllers that aren't
> very good at doing sg?

Writing a terabyte of memory to disk with handling 256 billion page 
structs? In case of a system with 1 petabyte of memory this may be rather 
typical and necessary for the application to be able to save its state
on disk.

> Isn't the issue was something like your IO controllers have only a
> limited number of sg entries, which is fine with 16K pages, but with
> 4K pages that doesn't give enough data to cover your RAID stripe?
> 
> We're never going to do a variable sized pagecache just because of that.

No, we need support for larger page sizes than 16k. 16k has not been fine 
for a couple of years. We only agreed to 16k because that was the common 
consensus. Best performance was always at 64k 4 years ago (but then we 
have no numbers for higher page sizes yet). Now we would prefer much 
larger sizes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
