Date: Sun, 20 May 2007 11:25:52 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc] increase struct page size?!
Message-ID: <20070520092552.GA7318@wotan.suse.de>
References: <20070518040854.GA15654@wotan.suse.de> <Pine.LNX.4.64.0705181112250.11881@schroedinger.engr.sgi.com> <20070519012530.GB15569@wotan.suse.de> <20070519181501.GC19966@holomorphy.com> <20070520052229.GA9372@wotan.suse.de> <20070520084647.GF19966@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070520084647.GF19966@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Christoph Lameter <clameter@sgi.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, May 20, 2007 at 01:46:47AM -0700, William Lee Irwin III wrote:
> On Sat, May 19, 2007 at 11:15:01AM -0700, William Lee Irwin III wrote:
> >> The cache cost argument is specious. Even misaligned, smaller is
> >> smaller.
> 
> On Sun, May 20, 2007 at 07:22:29AM +0200, Nick Piggin wrote:
> > Of course smaller is smaller ;) Why would that make the cache cost
> > argument specious?
> 
> It's not possible to ignore aggregation. For instance, for a subset
> of mem_map whose size ignoring alignment would otherwise fit in the
> cache to completely avoid sharing any cachelines between page
> structures requires page structures to be separated by at least one
> mem_map index. This is highly unlikely in uniform distributions.

But that wasn't my argument. I _know_ there are cases where the smaller
struct would be better, and I'm sure they would even arise in a running
kernel.
 

> On Sat, May 19, 2007 at 11:15:01AM -0700, William Lee Irwin III wrote:
> >> The cache footprint reduction is merely amortized,
> >> probabilistic, etc.
> 
> On Sun, May 20, 2007 at 07:22:29AM +0200, Nick Piggin wrote:
> > I don't really know what you mean by this, or what part of my cache cost
> > argument you disagree with...
> > I think it is that you could construct mem_map access patterns, without
> > specifically looking at alignment, where a 56 byte struct page would suffer
> > about 75% more cache misses than a 64 byte aligned one (and you could also
> > get about 12% fewer cache misses with other access patterns).
> > I also think the kernel's mem_map access patterns would be more on the
> > random side, so overall would result in significantly fewer cache misses
> > with 64 byte aligned pages.
> > Which part do you disagree with?
> 
> The lack of consideration of the average case. I'll see what I can smoke
> out there.

I _am_ considering the average case, and I consider the aligned structure
is likely to win on average :) I just don't have numbers for it yet.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
