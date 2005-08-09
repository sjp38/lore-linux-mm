Date: Tue, 9 Aug 2005 15:50:47 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC][patch 0/2] mm: remove PageReserved
In-Reply-To: <1123597903.30257.204.camel@gaston>
Message-ID: <Pine.LNX.4.61.0508091548150.13674@goblin.wat.veritas.com>
References: <42F57FCA.9040805@yahoo.com.au>  <200508090710.00637.phillips@arcor.de>
 <42F7F5AE.6070403@yahoo.com.au>  <1123577509.30257.173.camel@gaston>
 <Pine.LNX.4.61.0508091215490.11660@goblin.wat.veritas.com>
 <1123597903.30257.204.camel@gaston>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Daniel Phillips <phillips@arcor.de>, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 9 Aug 2005, Benjamin Herrenschmidt wrote:
> 
> > But you don't mind if they are refcounted, do you?
> > Just so long as they start out from 1 so never get freed.
> 
> Well, a refcounting bug would let them be freed and kaboom ... That's
> why a "PG_not_your_ram_dammit" bit would be useful. It could at least
> BUG_ON when refcount reaches 0 :)

Okay, great, let's give every struct page two refcounts,
so if one of them goes wrong, the other one will save us.

Hugh
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
