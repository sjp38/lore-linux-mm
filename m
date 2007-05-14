Date: Mon, 14 May 2007 12:44:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/5] make slab gfp fair
Message-Id: <20070514124451.c868c4c0.akpm@linux-foundation.org>
In-Reply-To: <20070514161224.GC11115@waste.org>
References: <20070514131904.440041502@chello.nl>
	<Pine.LNX.4.64.0705140852150.10442@schroedinger.engr.sgi.com>
	<20070514161224.GC11115@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Christoph Lameter <clameter@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Mon, 14 May 2007 11:12:24 -0500
Matt Mackall <mpm@selenic.com> wrote:

> If I understand this correctly:
> 
> privileged thread                      unprivileged greedy process
> kmem_cache_alloc(...)
>    adds new slab page from lowmem pool
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

Yes, that's my understanding also.

I can see why it's a problem in theory, but I don't think Peter has yet
revealed to us why it's a problem in practice.  I got all excited when
Christoph asked "I am not sure what the point of all of this is.", but
Peter cunningly avoided answering that ;)

What observed problem is being fixed here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
