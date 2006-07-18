Date: Tue, 18 Jul 2006 06:59:22 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] mm: inactive-clean list
In-Reply-To: <44BCE86A.4030602@mbligh.org>
Message-ID: <Pine.LNX.4.64.0607180657160.30887@schroedinger.engr.sgi.com>
References: <1153167857.31891.78.camel@lappy>
 <Pine.LNX.4.64.0607172035140.28956@schroedinger.engr.sgi.com>
 <1153224998.2041.15.camel@lappy> <Pine.LNX.4.64.0607180557440.30245@schroedinger.engr.sgi.com>
 <44BCE86A.4030602@mbligh.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 18 Jul 2006, Martin J. Bligh wrote:

> Someone remind me why we can't remove the memlocked pages from the LRU
> again? Apart from needing a refcount of how many times they're memlocked
> (or we just shove them back whenever they're unlocked, and let it fall
> out again when we walk the list, but that doesn't fix the accounting
> problem).

We simply do not unmap memlocked pages (see try_to_unmap). And therefore
they are not reclaimable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
