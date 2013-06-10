Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 459876B0031
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 19:39:29 -0400 (EDT)
Date: Mon, 10 Jun 2013 23:39:27 +0000
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: Handling of GFP_WAIT in the slub and slab allocators
In-Reply-To: <CAAxaTiOwqEzYO1QTae3HTAu2C-uQY1gvCXeC5rwzypRGV6d+BQ@mail.gmail.com>
Message-ID: <0000013f307566d3-94cbc8ed-e638-4f95-aa1a-9d32dbae2022-000000@email.amazonses.com>
References: <CAAxaTiNXV_RitbBKxCwV_rV44d1cLhfEbLs3ngtEGQUnZ2zk_g@mail.gmail.com> <0000013f2eaa90dc-0a3a9858-994c-46dd-83b5-891c05b473f4-000000@email.amazonses.com> <CAAxaTiOwqEzYO1QTae3HTAu2C-uQY1gvCXeC5rwzypRGV6d+BQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Palix <nicolas.palix@imag.fr>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

On Mon, 10 Jun 2013, Nicolas Palix wrote:

> On Mon, Jun 10, 2013 at 5:18 PM, Christoph Lameter <cl@gentwo.org> wrote:
> > On Mon, 10 Jun 2013, Nicolas Palix wrote:
> >
> >> I notice that in the SLAB allocator, local_irq_save and
> >> local_irq_restore are called in slab_alloc_node and slab_alloc without
> >> checking the GFP_WAIT bit of the flags parameter.
> >
> > SLAB does the same as SLUB. Have a look at mm/slab.c:cache_grow()
>
> I agree and it is the same for mm/slab.c:fallback_alloc() but
> why is it not also required for mm/slab.c:slab_alloc_node()
> and mm/slab.c:slab_alloc() which both manipulate the local irqs?

Because cache_grow calls into the page allocator and we cannot do reclaim
with interrupts off.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
