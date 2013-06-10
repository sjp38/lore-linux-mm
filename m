Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id C49056B0031
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 17:27:24 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id kp12so3164577pab.7
        for <linux-mm@kvack.org>; Mon, 10 Jun 2013 14:27:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0000013f2eaa90dc-0a3a9858-994c-46dd-83b5-891c05b473f4-000000@email.amazonses.com>
References: <CAAxaTiNXV_RitbBKxCwV_rV44d1cLhfEbLs3ngtEGQUnZ2zk_g@mail.gmail.com>
	<0000013f2eaa90dc-0a3a9858-994c-46dd-83b5-891c05b473f4-000000@email.amazonses.com>
Date: Mon, 10 Jun 2013 23:27:23 +0200
Message-ID: <CAAxaTiOwqEzYO1QTae3HTAu2C-uQY1gvCXeC5rwzypRGV6d+BQ@mail.gmail.com>
Subject: Re: Handling of GFP_WAIT in the slub and slab allocators
From: Nicolas Palix <nicolas.palix@imag.fr>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

On Mon, Jun 10, 2013 at 5:18 PM, Christoph Lameter <cl@gentwo.org> wrote:
> On Mon, 10 Jun 2013, Nicolas Palix wrote:
>
>> I notice that in the SLAB allocator, local_irq_save and
>> local_irq_restore are called in slab_alloc_node and slab_alloc without
>> checking the GFP_WAIT bit of the flags parameter.
>
> SLAB does the same as SLUB. Have a look at mm/slab.c:cache_grow()

I agree and it is the same for mm/slab.c:fallback_alloc() but
why is it not also required for mm/slab.c:slab_alloc_node()
and mm/slab.c:slab_alloc() which both manipulate the local irqs?



--
Nicolas Palix

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
