Date: Thu, 31 Jan 2008 06:09:40 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH] mm: MADV_WILLNEED implementation for anonymous memory
Message-ID: <20080131060940.37a58559@riellaptop.surriel.com>
In-Reply-To: <20080131113224.GB31090@one.firstfloor.org>
References: <20080130144049.73596898.akpm@linux-foundation.org>
	<1201769040.28547.245.camel@lappy>
	<20080131011227.257b9437.akpm@linux-foundation.org>
	<1201772118.28547.254.camel@lappy>
	<20080131014702.705f1040.akpm@linux-foundation.org>
	<1201773206.28547.259.camel@lappy>
	<p73ve5a47yr.fsf@bingen.suse.de>
	<20080131021949.92715ba4.akpm@linux-foundation.org>
	<20080131110610.GA31090@one.firstfloor.org>
	<20080131055209.6adede04@riellaptop.surriel.com>
	<20080131113224.GB31090@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, hugh@veritas.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de, mztabzr@0pointer.de, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

On Thu, 31 Jan 2008 12:32:24 +0100
Andi Kleen <andi@firstfloor.org> wrote:
> On Thu, Jan 31, 2008 at 05:52:09AM -0500, Rik van Riel wrote:

> > Don't malloc() and free() hopelessly fragment memory
> > over time, ensuring that little related data can be
> > found inside each 1MB chunk if the process is large
> > enough?  (say, firefox)
> 
> Even if they do (I don't know if it's true or not) it does not really 
> matter because on modern hard disks/systems it does not cost less to 
> transfer 1MB versus 4K. The actual threshold seems to be rising in
> fact.

That is definately true.

> The only drawback is that the swap might be full sooner, but 
> I would actually consider this a feature because it would likely
> end many prolonged oom death dances much sooner.

A second drawback would be that we evict more potentially
useful data every time we swap in a whole lot of extra
data around the little bit of data we need.

On the other hand, swapping should be the exception on
many of today's workloads.

Maybe we can measure how many of the swapped in pages end
up being used and how many are evicted again without being
used and automatically change our chunk size based on those
statistics?

I would expect most desktop systems to end up with large
chunks, because they rarely swap.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
