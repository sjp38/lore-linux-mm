Message-ID: <3D3F0DE4.84A4FB62@zip.com.au>
Date: Wed, 24 Jul 2002 13:28:20 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: page_add/remove_rmap costs
References: <3D3F0ACE.D4195BF@zip.com.au> <Pine.LNX.4.44L.0207241719130.3086-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Wed, 24 Jul 2002, Andrew Morton wrote:
> 
> > > > Then again, if the per-vma pfn->pte lookup is feasible, we may not need
> > > > the pte_chain at all...
> > >
> > > It is feasible, both davem and bcrl made code to this effect. The
> > > only problem with that code is that it gets ugly quick after mremap.
> >
> > So.. who's going to do it?
> >
> > It's early days yet - although this looks bad on benchmarks we really
> > need a better understanding of _why_ it's so bad, and of whether it
> > really matters for real workloads.
> 
> I guess I'll take a stab at bcrl's and davem's code and will
> try to also hide it between an rmap.c interface ;)

hmm, OK.  Big job...

> > For example: given that copy_page_range performs atomic ops against
> > page->count, how come page_add_rmap()'s atomic op against page->flags
> > is more of a problem?
> 
> Could it have something to do with cpu_relax() delaying
> things ?

Don't think so.  That's only executed on the contended case, which
is 0.3% of the time.  But hey, it's easy enough to remove it and retest.
I shall do that.

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
