From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: Fw: [PATCH] Add alloc_pages_exact() and free_pages_exact()
Date: Mon, 7 Jul 2008 16:42:39 +1000
References: <20080624135750.0c59c6b9.akpm@linux-foundation.org> <200806251139.51142.nickpiggin@yahoo.com.au> <48625571.9060201@freescale.com>
In-Reply-To: <48625571.9060201@freescale.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200807071642.39972.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <timur@freescale.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 26 June 2008 00:25, Timur Tabi wrote:
> Nick Piggin wrote:
> > On Wednesday 25 June 2008 06:57, Andrew Morton wrote:
> >> I'm applying this.
> >
> > Fine. And IIRC there are one or two places around the kernel that
> > could be converted to use it. Why not just have a node id
> > argument and call it alloc_pages_node_exact? so Christoph doesn't
> > have to do it himself ;)
>
> Since I don't know anything nodes, I can't say whether this is a good idea
> or not, or even how to implement it.  Sorry.

Just give an 'int nid' parameter, and then pass it through to
alloc_pages_node. You don't have to do anything with it directly.


> > Maybe you could also say that __GFP_COMPOUND cannot be used, and
> > that the returned pages are "split" (work the same way as N
> > indivudually allocated order-0 pages WRT refcounting).
>
> Is this a suggestion for the function comments?

Yes, just comments.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
