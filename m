Date: Tue, 25 Mar 2008 10:45:06 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [13/14] vcompound: Use vcompound for swap_map
In-Reply-To: <20080325075236.GG2170@one.firstfloor.org>
Message-ID: <Pine.LNX.4.64.0803251043140.15870@schroedinger.engr.sgi.com>
References: <20080321061703.921169367@sgi.com> <20080321061727.269764652@sgi.com>
 <8763vfixb8.fsf@basil.nowhere.org> <Pine.LNX.4.64.0803241253250.4218@schroedinger.engr.sgi.com>
 <20080325075236.GG2170@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Mar 2008, Andi Kleen wrote:

> I liked your idea of fixing compound pages to not rely on order
> better. Ok it is likely more work to implement @)

Right. It just requires a page allocator rewrite. Which is overdue 
anyways given the fastpath issues. Volunteers?

> Also if anything preserving memory should be default, but maybe
> skippable a with __GFP_GO_FAST flag.

Well. Guess we need a definition of preserving memory. All allocations 
typically have some kind of overhead.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
