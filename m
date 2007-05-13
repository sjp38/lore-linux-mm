Date: Sun, 13 May 2007 05:39:03 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [rfc] optimise unlock_page
In-Reply-To: <20070513033210.GA3667@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0705130535410.3015@blonde.wat.veritas.com>
References: <20070508113709.GA19294@wotan.suse.de> <20070508114003.GB19294@wotan.suse.de>
 <1178659827.14928.85.camel@localhost.localdomain> <20070508224124.GD20174@wotan.suse.de>
 <20070508225012.GF20174@wotan.suse.de> <Pine.LNX.4.64.0705091950080.2909@blonde.wat.veritas.com>
 <20070510033736.GA19196@wotan.suse.de> <Pine.LNX.4.64.0705101935590.18496@blonde.wat.veritas.com>
 <20070511085424.GA15352@wotan.suse.de> <Pine.LNX.4.64.0705111357120.3350@blonde.wat.veritas.com>
 <20070513033210.GA3667@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-arch@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 13 May 2007, Nick Piggin wrote:
> On Fri, May 11, 2007 at 02:15:03PM +0100, Hugh Dickins wrote:
> 
> > Hmm, well, I think that's fairly horrid, and would it even be
> > guaranteed to work on all architectures?  Playing with one char
> > of an unsigned long in one way, while playing with the whole of
> > the unsigned long in another way (bitops) sounds very dodgy to me.
> 
> Of course not, but they can just use a regular atomic word sized
> bitop. The problem with i386 is that its atomic ops also imply
> memory barriers that you obviously don't need on unlock.

But is it even a valid procedure on i386?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
