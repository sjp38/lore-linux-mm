Date: Tue, 25 Mar 2008 08:52:36 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [13/14] vcompound: Use vcompound for swap_map
Message-ID: <20080325075236.GG2170@one.firstfloor.org>
References: <20080321061703.921169367@sgi.com> <20080321061727.269764652@sgi.com> <8763vfixb8.fsf@basil.nowhere.org> <Pine.LNX.4.64.0803241253250.4218@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803241253250.4218@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 24, 2008 at 12:54:54PM -0700, Christoph Lameter wrote:
> On Fri, 21 Mar 2008, Andi Kleen wrote:
> 
> > But I used a simple trick to avoid the waste problem: it allocated a
> > continuous range rounded up to the next page-size order and then freed
> > the excess pages back into the page allocator. That was called
> > alloc_exact(). If you replace vmalloc with alloc_pages you should
> > use something like that too I think.
> 
> One way of dealing with it would be to define an additional allocation 
> variant that allows the limiting of the loss? I noted that both the swap
> and the wait tables vary significantly between allocations. So we could 
> specify an upper boundary of a loss that is acceptable. If too much memory
> would be lost then use vmalloc unconditionally.

I liked your idea of fixing compound pages to not rely on order
better. Ok it is likely more work to implement @)

Also if anything preserving memory should be default, but maybe
skippable a with __GFP_GO_FAST flag.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
