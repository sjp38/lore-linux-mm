Date: Tue, 26 Jun 2007 12:10:56 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] slob: poor man's NUMA support.
In-Reply-To: <29495f1d0706261204x5b49511co18546443c78033fd@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0706261209170.19878@schroedinger.engr.sgi.com>
References: <20070619090616.GA23697@linux-sh.org>
 <20070626002131.ff3518d4.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0706261112380.18010@schroedinger.engr.sgi.com>
 <29495f1d0706261204x5b49511co18546443c78033fd@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nish Aravamudan <nish.aravamudan@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Paul Mundt <lethal@linux-sh.org>, Matt Mackall <mpm@selenic.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 26 Jun 2007, Nish Aravamudan wrote:

> > No. alloc_pages follows memory policy. alloc_pages_node does not. One of
> > the reasons that I want a new memory policy layer are these kinds of
> > strange uses.
> 
> What would break by changing, in alloc_pages_node()
> 
>        if (nid < 0)
>                nid = numa_node_id();
> 
> to
> 
>        if (nid < 0)
>                return alloc_pages_current(gfp_mask, order);
> 
> beyond needing to make alloc_pages_current() defined if !NUMA too.

It would make alloc_pages_node obey memory policies instead of only
following cpuset constraints. An a memory policy may redirect the 
allocation from the local node ;-).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
