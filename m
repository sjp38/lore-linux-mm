Date: Mon, 14 May 2007 09:29:15 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/5] make slab gfp fair
In-Reply-To: <20070514161224.GC11115@waste.org>
Message-ID: <Pine.LNX.4.64.0705140927470.10801@schroedinger.engr.sgi.com>
References: <20070514131904.440041502@chello.nl>
 <Pine.LNX.4.64.0705140852150.10442@schroedinger.engr.sgi.com>
 <20070514161224.GC11115@waste.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Mon, 14 May 2007, Matt Mackall wrote:

> privileged thread                      unprivileged greedy process
> kmem_cache_alloc(...)
>    adds new slab page from lowmem pool

Yes but it returns an object for the privileged thread. Is that not 
enough?


> do_io()
>                                        kmem_cache_alloc(...)
>                                        kmem_cache_alloc(...)
>                                        kmem_cache_alloc(...)
>                                        kmem_cache_alloc(...)
>                                        kmem_cache_alloc(...)
>                                        ...
>                                           eats it all
> kmem_cache_alloc(...) -> ENOMEM
>    who ate my donuts?!
> 
> But I think this solution is somehow overkill. If we only care about
> this issue in the OOM avoidance case, then our rank reduces to a
> boolean.
> 
> -- 
> Mathematics is the supreme nostalgia of our time.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
