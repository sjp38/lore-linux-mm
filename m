Date: Fri, 2 Mar 2007 13:20:13 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: The performance and behaviour of the anti-fragmentation related patches
Message-ID: <20070302042013.GA12669@linux-sh.org>
References: <20070301101249.GA29351@skynet.ie> <20070301160915.6da876c5.akpm@linux-foundation.org> <Pine.LNX.4.64.0703011854540.5530@schroedinger.engr.sgi.com> <20070302035751.GA15867@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070302035751.GA15867@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <clameter@engr.sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@skynet.ie>, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, torvalds@linux-foundation.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 02, 2007 at 04:57:51AM +0100, Nick Piggin wrote:
> On Thu, Mar 01, 2007 at 07:05:48PM -0800, Christoph Lameter wrote:
> > On Thu, 1 Mar 2007, Andrew Morton wrote:
> > > For prioritisation purposes I'd judge that memory hot-unplug is of similar
> > > value to the antifrag work (because memory hot-unplug permits DIMM
> > > poweroff).
> > 
> > I would say that anti-frag / defrag enables memory unplug.
> 
> Well that really depends. If you want to have any sort of guaranteed
> amount of unplugging or shrinking (or hugepage allocating), then antifrag
> doesn't work because it is a heuristic.
> 
> One thing that worries me about anti-fragmentation is that people might
> actually start _using_ higher order pages in the kernel. Then fragmentation
> comes back, and it's worse because now it is not just the fringe hugepage or
> unplug users (who can anyway work around the fragmentation by allocating
> from reserve zones).
> 
There's two sides to that, the ability to use higher order pages in the
kernel also means that it's possible to use larger TLB entries while
keeping the base page size small, too. There are already many places in
the kernel that attempt to use the largest possible size when setting up
the entries, and this is something that those of us with tiny
software-managed TLBs are a huge fan of -- some platforms have even opted
to do perverse things such as scanning for contiguous PTEs and bumping to
the next order automatically at set_pte() time.

Unplug is also interesting from a power management point of view.
Powering off is still more attractive than self-refresh, for example, but
could also be used at run-time depending on the workload.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
