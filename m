Date: Wed, 24 Jul 2002 17:21:27 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: page_add/remove_rmap costs
In-Reply-To: <3D3F0ACE.D4195BF@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0207241719130.3086-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 24 Jul 2002, Andrew Morton wrote:

> > > Then again, if the per-vma pfn->pte lookup is feasible, we may not need
> > > the pte_chain at all...
> >
> > It is feasible, both davem and bcrl made code to this effect. The
> > only problem with that code is that it gets ugly quick after mremap.
>
> So.. who's going to do it?
>
> It's early days yet - although this looks bad on benchmarks we really
> need a better understanding of _why_ it's so bad, and of whether it
> really matters for real workloads.

I guess I'll take a stab at bcrl's and davem's code and will
try to also hide it between an rmap.c interface ;)

> For example: given that copy_page_range performs atomic ops against
> page->count, how come page_add_rmap()'s atomic op against page->flags
> is more of a problem?

Could it have something to do with cpu_relax() delaying
things ?

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
