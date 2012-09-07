Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 44D0B6B006E
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 20:03:23 -0400 (EDT)
Received: by iec9 with SMTP id 9so4953333iec.14
        for <linux-mm@kvack.org>; Thu, 06 Sep 2012 17:03:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAAmzW4P7=8P3h8-nCUB+iK+RSnVrcJBKUbV5hN+TpR53Xt7eGw@mail.gmail.com>
References: <1346885323-15689-1-git-send-email-elezegarcia@gmail.com>
	<1346885323-15689-5-git-send-email-elezegarcia@gmail.com>
	<CAAmzW4P7=8P3h8-nCUB+iK+RSnVrcJBKUbV5hN+TpR53Xt7eGw@mail.gmail.com>
Date: Thu, 6 Sep 2012 21:03:22 -0300
Message-ID: <CALF0-+XJh4hDM0e=zhJkWqmL+0ykp2aWfKt4f4g5jSWRwNW3Yw@mail.gmail.com>
Subject: Re: [PATCH 5/5] mm, slob: Trace allocation failures consistently
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

Hi Joonso,

On Thu, Sep 6, 2012 at 4:09 PM, JoonSoo Kim <js1304@gmail.com> wrote:
> 2012/9/6 Ezequiel Garcia <elezegarcia@gmail.com>:
>> This patch cleans how we trace kmalloc and kmem_cache_alloc.
>> In particular, it fixes out-of-memory tracing: now every failed
>> allocation will trace reporting non-zero requested bytes, zero obtained bytes.
>
> Other SLAB allocators(slab, slub) doesn't consider zero obtained bytes
> in tracing.
> These just return "addr = 0, obtained size = cache size"
> Why does the slob print a different output?
>

I plan to fix slab, slub in a future patchset. I think it would be nice to have
a trace event reporting this event. But, perhaps it's not worth it.

I'd love to hear what others think about this.

Thanks,
Ezequiel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
