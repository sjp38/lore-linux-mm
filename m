Date: Fri, 2 Mar 2007 00:21:49 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
In-Reply-To: <20070302081210.GD5557@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0703020015080.14651@schroedinger.engr.sgi.com>
References: <20070302050625.GD15867@wotan.suse.de>
 <Pine.LNX.4.64.0703012137580.1768@schroedinger.engr.sgi.com>
 <20070302054944.GE15867@wotan.suse.de> <Pine.LNX.4.64.0703012150290.1768@schroedinger.engr.sgi.com>
 <20070302060831.GF15867@wotan.suse.de> <Pine.LNX.4.64.0703012213130.1917@schroedinger.engr.sgi.com>
 <20070302062950.GG15867@wotan.suse.de> <Pine.LNX.4.64.0703012236160.1979@schroedinger.engr.sgi.com>
 <20070302071955.GA5557@wotan.suse.de> <Pine.LNX.4.64.0703012335250.13224@schroedinger.engr.sgi.com>
 <20070302081210.GD5557@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@skynet.ie>, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, torvalds@linux-foundation.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2 Mar 2007, Nick Piggin wrote:

> > If there are billions of pages in the system and we are allocating and 
> > deallocating then pages need to be aged. If there are just few pages 
> > freeable then we run into issues.
> 
> page writeout and vmscan don't work too badly. What are the issues?

Slow downs up to livelocks with large memory configurations.

> So what problems that you commonly see now? Some of us here don't
> have 4TB of memory, so you actually have to tell us ;)

Oh just run a 32GB SMP system with sparsely freeable pages and lots of 
allocs and frees and you will see it too. F.e try Linus tree and mlock 
a large portion of the memory and then see the fun starting. See also 
Rik's list of pathological cases on this.

> How did you come up with that 2MB number?

Huge page size. The only basic choice on x86_64

> Anyway, we have hugetlbfs for things like that.

Good to know that direct io works.

> > I am not the first one.... See Rik's posts regarding the reasons for his 
> > new page replacement algorithms.
> 
> Different issue, isn't it? Rik wants to be smarter in figuring out which
> pages to throw away. More work per page == worse for you.

Rik is trying to solve the same issue in a different way. He is trying to 
manage gazillion entries better instead of reducing the entries to be 
managed. That can only work in a limited way. Drastic reductions in the 
entries to be manages have good effects in multiple ways. Reduce 
management overhead, improve I/O throughput, etc etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
