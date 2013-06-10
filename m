Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 055D06B0031
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 11:18:18 -0400 (EDT)
Date: Mon, 10 Jun 2013 15:18:17 +0000
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: Handling of GFP_WAIT in the slub and slab allocators
In-Reply-To: <CAAxaTiNXV_RitbBKxCwV_rV44d1cLhfEbLs3ngtEGQUnZ2zk_g@mail.gmail.com>
Message-ID: <0000013f2eaa90dc-0a3a9858-994c-46dd-83b5-891c05b473f4-000000@email.amazonses.com>
References: <CAAxaTiNXV_RitbBKxCwV_rV44d1cLhfEbLs3ngtEGQUnZ2zk_g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Palix <nicolas.palix@imag.fr>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

On Mon, 10 Jun 2013, Nicolas Palix wrote:

> I notice that in the SLAB allocator, local_irq_save and
> local_irq_restore are called in slab_alloc_node and slab_alloc without
> checking the GFP_WAIT bit of the flags parameter.

SLAB does the same as SLUB. Have a look at mm/slab.c:cache_grow()

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
