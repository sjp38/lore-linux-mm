Date: Wed, 9 May 2001 13:36:18 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [PATCH] allocation looping + kswapd CPU cycles 
In-Reply-To: <Pine.LNX.4.21.0105090957420.31900-100000@alloc>
Message-ID: <Pine.LNX.4.21.0105091334540.13878-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Hemment <markhe@veritas.com>
Cc: "David S. Miller" <davem@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 9 May 2001, Mark Hemment wrote:

> 
> On Tue, 8 May 2001, David S. Miller wrote: 
> > Actually, the change was made because it is illogical to try only
> > once on multi-order pages.  Especially because we depend upon order
> > 1 pages so much (every task struct allocated).  We depend upon them
> > even more so on sparc64 (certain kinds of page tables need to be
> > allocated as 1 order pages).
> > 
> > The old code failed _far_ too easily, it was unacceptable.
> > 
> > Why put some strange limit in there?  Whatever number you pick
> > is arbitrary, and I can probably piece together an allocation
> > state where the choosen limit is too small.
> 
>   Agreed, but some allocations of non-zero orders can fall back to other
> schemes (such as an emergency buffer, or using vmalloc for a temp
> buffer) and don't want to be trapped in __alloc_pages() for too long.
> 
>   Could introduce another allocation flag (__GFP_FAIL?) which is or'ed
> with a __GFP_WAIT to limit the looping?

__GFP_FAIL is in the -ac tree already and it is being used by the bounce
buffer allocation code. 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
