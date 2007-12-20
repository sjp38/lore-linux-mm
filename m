Subject: Re: [rfc][patch] mm: madvise(WILLNEED) for anonymous memory
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20071220171143.GV19691@waste.org>
References: <1198155938.6821.3.camel@twins>
	 <Pine.LNX.4.64.0712201339010.18399@blonde.wat.veritas.com>
	 <1198162078.6821.27.camel@twins>
	 <Pine.LNX.4.64.0712201508290.857@blonde.wat.veritas.com>
	 <1198169621.6821.44.camel@twins>  <20071220171143.GV19691@waste.org>
Content-Type: text/plain
Date: Thu, 20 Dec 2007 18:15:59 +0100
Message-Id: <1198170959.30889.0.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Hugh Dickins <hugh@veritas.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, riel <riel@redhat.com>, Lennart Poettering <mztabzr@0pointer.de>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-12-20 at 11:11 -0600, Matt Mackall wrote:
> On Thu, Dec 20, 2007 at 05:53:41PM +0100, Peter Zijlstra wrote:
> > 
> > On Thu, 2007-12-20 at 15:26 +0000, Hugh Dickins wrote:
> > 
> > > The asynch code: perhaps not worth doing for MADV_WILLNEED alone,
> > > but might prove useful for more general use when swapping in.
> > > Not really the same as Con's swap prefetch, but worth looking
> > > at that for reference.  But I guess this becomes a much bigger
> > > issue than you were intending to get into here.
> > 
> > heh, yeah, got somewhat more complex that I'd hoped for.
> > 
> > last patch for today (not even compile tested), will do a proper patch
> > and test it tomorrow.
> > 
> > ---
> > A best effort MADV_WILLNEED implementation for anonymous memory.
> > 
> > It adds a batch method to the page table walk routines so we can
> > copy a few ptes while holding the kmap, which makes it possible to
> > allocate the backing pages using GFP_KERNEL.
> 
> Yuck. We actually need to just fix the atomic kmap issue in the
> existing pagemap code rather than add a new method, I think.
> 
> If performance of map/unmap is too slow at a granularity of 1, we can
> add some internal batching in the CONFIG_HIGHPTE case.

OK, sounds like a much better idea indeed. Will implement that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
