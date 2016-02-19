Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 85200830B6
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 20:41:33 -0500 (EST)
Received: by mail-ob0-f179.google.com with SMTP id jq7so94327182obb.0
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 17:41:33 -0800 (PST)
Received: from mail-ob0-x22b.google.com (mail-ob0-x22b.google.com. [2607:f8b0:4003:c01::22b])
        by mx.google.com with ESMTPS id a190si13149365oib.53.2016.02.18.17.41.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 17:41:32 -0800 (PST)
Received: by mail-ob0-x22b.google.com with SMTP id xk3so95823787obc.2
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 17:41:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAG_fn=W7tH3MG9kEtPwZdA+ni3d1aSnFT8vkxXEVVQLsdiqZ+A@mail.gmail.com>
References: <cover.1453918525.git.glider@google.com>
	<7f497e194053c25e8a3debe3e1e738a187e38c16.1453918525.git.glider@google.com>
	<20160128074442.GB15426@js1304-P5Q-DELUXE>
	<CAG_fn=W_17XMtCmLRHHccJmzPaJTk1Jc4uCa4T_n4E5NwRR9Mg@mail.gmail.com>
	<CAG_fn=VTnFDOVuQzk3NgFGd6D+BoNDSqL4-MYyo0soq+eM76-g@mail.gmail.com>
	<20160201021501.GB32125@js1304-P5Q-DELUXE>
	<CAG_fn=W7tH3MG9kEtPwZdA+ni3d1aSnFT8vkxXEVVQLsdiqZ+A@mail.gmail.com>
Date: Fri, 19 Feb 2016 10:41:32 +0900
Message-ID: <CAAmzW4M98a4pGF7kCx_273nPGNjsORY-MGSgx1y0+JzYNyAa1w@mail.gmail.com>
Subject: Re: [PATCH v1 2/8] mm, kasan: SLAB support
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, kasan-dev@googlegroups.com, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, Dmitriy Vyukov <dvyukov@google.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrey Konovalov <adech.fo@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>

> On Mon, Feb 1, 2016 at 3:15 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
>> On Thu, Jan 28, 2016 at 02:29:42PM +0100, Alexander Potapenko wrote:
>>> On Thu, Jan 28, 2016 at 1:37 PM, Alexander Potapenko <glider@google.com> wrote:
>>> >
>>> > On Jan 28, 2016 8:44 AM, "Joonsoo Kim" <iamjoonsoo.kim@lge.com> wrote:
>>> >>
>>> >> On Wed, Jan 27, 2016 at 07:25:07PM +0100, Alexander Potapenko wrote:
>>> >> > This patch adds KASAN hooks to SLAB allocator.
>>> >> >
>>> >> > This patch is based on the "mm: kasan: unified support for SLUB and
>>> >> > SLAB allocators" patch originally prepared by Dmitry Chernenkov.
>>> >> >
>>> >> > Signed-off-by: Alexander Potapenko <glider@google.com>
>>> >> > ---
>>> >> >  Documentation/kasan.txt  |  5 ++-
>>> >>
>>> >> ...
>>> >>
>>> >> > +#ifdef CONFIG_SLAB
>>> >> > +struct kasan_alloc_meta *get_alloc_info(struct kmem_cache *cache,
>>> >> > +                                     const void *object)
>>> >> > +{
>>> >> > +     return (void *)object + cache->kasan_info.alloc_meta_offset;
>>> >> > +}
>>> >> > +
>>> >> > +struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
>>> >> > +                                   const void *object)
>>> >> > +{
>>> >> > +     return (void *)object + cache->kasan_info.free_meta_offset;
>>> >> > +}
>>> >> > +#endif
>>> >>
>>> >> I cannot find the place to store stack info for free. get_free_info()
>>> >> isn't used except print_object(). Plese let me know where.
>>> >
>>> > This is covered by other patches in this patchset.
>>
>> This should be covered by this patch. Stroing and printing free_info
>> is already done on SLUB and it is meaningful without quarantain.

2016-02-18 21:58 GMT+09:00 Alexander Potapenko <glider@google.com>:
> However this info is meaningless without saved stack traces, which are
> only introduced in the stackdepot patch (see "[PATCH v1 5/8] mm,
> kasan: Stackdepot implementation. Enable stackdepot for SLAB")

Not meaningless. You already did it for allocation caller without saved
stack traces. What makes difference between alloc/free?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
