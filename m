Date: Tue, 26 Jun 2007 11:14:18 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] slob: poor man's NUMA support.
In-Reply-To: <20070626002131.ff3518d4.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0706261112380.18010@schroedinger.engr.sgi.com>
References: <20070619090616.GA23697@linux-sh.org>
 <20070626002131.ff3518d4.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Mundt <lethal@linux-sh.org>, Matt Mackall <mpm@selenic.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 26 Jun 2007, Andrew Morton wrote:

> > +#ifdef CONFIG_NUMA
> > +	if (node != -1)
> > +		page = alloc_pages_node(node, gfp, order);
> > +	else
> > +#endif
> > +		page = alloc_pages(gfp, order);
> 
> Isn't the above equivalent to a bare
> 
> 	page = alloc_pages_node(node, gfp, order);
> 
> ?

No. alloc_pages follows memory policy. alloc_pages_node does not. One of 
the reasons that I want a new memory policy layer are these kinds of 
strange uses.

> 
> 	if (node < 0
> 
> rather than comparing with -1 exactly.
> 
> On many CPUs it'll save a few bytes of code.

-1 means no node specified and much of the NUMA code compares with -1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
