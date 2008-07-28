Subject: Re: page swap allocation error/failure in 2.6.25
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20080727060701.GA7157@samad.com.au>
References: <20080725072015.GA17688@samad.com.au>
	 <1216971601.7257.345.camel@twins>  <20080727060701.GA7157@samad.com.au>
Content-Type: text/plain
Date: Mon, 28 Jul 2008 12:04:47 +0200
Message-Id: <1217239487.6331.24.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alex Samad <alex@samad.com.au>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

On Sun, 2008-07-27 at 16:07 +1000, Alex Samad wrote:
> On Fri, Jul 25, 2008 at 09:40:01AM +0200, Peter Zijlstra wrote:
> > On Fri, 2008-07-25 at 17:20 +1000, Alex Samad wrote:
> > > Hi
> 
> [snip]
> 
> > 
> > 
> > Its harmless if it happens sporadically. 
> > 
> > Atomic order 2 allocations are just bound to go wrong under pressure.
> can you point me to any doco that explains this ?

An order 2 allocation means allocating 1<<2 or 4 physically contiguous
pages. Atomic allocation means not being able to sleep.

Now if the free page lists don't have any order 2 pages available due to
fragmentation there is currently nothing we can do about it.

I've been meaning to try and play with 'atomic' page migration to try
and assemble a higher order page on demand with something like memory
compaction.

But its never managed to get high enough on the todo list..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
