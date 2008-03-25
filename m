Date: Tue, 25 Mar 2008 18:55:08 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [13/14] vcompound: Use vcompound for swap_map
Message-ID: <20080325175508.GV2170@one.firstfloor.org>
References: <20080321061703.921169367@sgi.com> <20080321061727.269764652@sgi.com> <8763vfixb8.fsf@basil.nowhere.org> <Pine.LNX.4.64.0803241253250.4218@schroedinger.engr.sgi.com> <20080325075236.GG2170@one.firstfloor.org> <Pine.LNX.4.64.0803251043140.15870@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803251043140.15870@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 25, 2008 at 10:45:06AM -0700, Christoph Lameter wrote:
> On Tue, 25 Mar 2008, Andi Kleen wrote:
> 
> > I liked your idea of fixing compound pages to not rely on order
> > better. Ok it is likely more work to implement @)
> 
> Right. It just requires a page allocator rewrite. 

Not when the trick of getting high order, returning left over pages
is used. I meant just updating the GFP_COMPOUND code to always
use number of pages instead of order so that it could deal with a compound
where the excess pages are already returned. That is not actually that 
much work (I reimplemented this recently for dma alloc and it's < 20 LOC) 

Of course the full rewrite would be also great, agreed :)

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
