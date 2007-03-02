Date: Fri, 2 Mar 2007 06:06:25 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: The performance and behaviour of the anti-fragmentation related patches
Message-ID: <20070302050625.GD15867@wotan.suse.de>
References: <20070301101249.GA29351@skynet.ie> <20070301160915.6da876c5.akpm@linux-foundation.org> <Pine.LNX.4.64.0703011854540.5530@schroedinger.engr.sgi.com> <20070302035751.GA15867@wotan.suse.de> <Pine.LNX.4.64.0703012001260.5548@schroedinger.engr.sgi.com> <20070302042149.GB15867@wotan.suse.de> <Pine.LNX.4.64.0703012022320.14299@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703012022320.14299@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@skynet.ie>, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, torvalds@linux-foundation.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 01, 2007 at 08:31:24PM -0800, Christoph Lameter wrote:
> On Fri, 2 Mar 2007, Nick Piggin wrote:
> 
> > > Yes, we (SGI) need exactly that: Use of higher order pages in the kernel 
> > > in order to reduce overhead of managing page structs for large I/O and 
> > > large memory applications. We need appropriate measures to deal with the 
> > > fragmentation problem.
> > 
> > I don't understand why, out of any architecture, ia64 would have to hack
> > around this in software :(
> 
> Ummm... We have x86_64 platforms with the 4k page problem. 4k pages are 
> very useful for the large number of small files that are around. But for 
> the large streams of data you would want other methods of handling these.
> 
> If I want to write 1 terabyte (2^50) to disk then the I/O subsystem has 
> to handle 2^(50-12) = 2^38 = 256 million page structs! This limits I/O 
> bandwiths and leads to huge scatter gather lists (and we are limited in 
> terms of the numbe of items on those lists in many drivers). Our future 
> platforms have up to serveral petabytes of memory. There needs to be some 
> way to handle these capacities in an efficient way. We cannot wait 
> an hour for the terabyte to reach the disk.

I guess you mean 256 billion page structs.

So what do you mean by efficient? I guess you aren't talking about CPU
efficiency, because even if you make the IO subsystem submit larger
physical IOs, you still have to deal with 256 billion TLB entries, the
pagecache has to deal with 256 billion struct pages, so does the
filesystem code to build the bios.

So you are having problems with your IO controller's handling of sg
lists?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
