Subject: Re: [PATCH] mm: call into direct reclaim without PF_MEMALLOC set
From: Arjan van de Ven <arjan@fenrus.demon.nl>
In-Reply-To: <20061115140049.c835fbfd.akpm@osdl.org>
References: <1163618703.5968.50.camel@twins>
	 <20061115124228.db0b42a6.akpm@osdl.org> <1163625058.5968.64.camel@twins>
	 <20061115132340.3cbf4008.akpm@osdl.org> <1163626378.5968.74.camel@twins>
	 <20061115140049.c835fbfd.akpm@osdl.org>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Wed, 15 Nov 2006 23:12:19 +0100
Message-Id: <1163628739.31358.164.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2006-11-15 at 14:00 -0800, Andrew Morton wrote:
> On Wed, 15 Nov 2006 22:32:58 +0100
> Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> 
> > +			current->flags |= PF_MEMALLOC;
> >  			try_to_free_pages(zones, GFP_NOFS);
> > +			current->flags &= ~PF_MEMALLOC;
> 
> Sometime, later, in a different patch, we might as well suck that into
> try_to_free_pages() itself.   Along with nice comment explaining
> what it means and WARN_ON(current->flags & PF_MEMALLOC).

also I've seen a few cases where this will break.
If you already *have* PF_MEMALLOC you'd lose it here; it's generally a
mistake to do so. It's a lot safer to save the old value and restore
it...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
