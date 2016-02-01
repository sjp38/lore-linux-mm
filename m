Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 501166B0005
	for <linux-mm@kvack.org>; Sun, 31 Jan 2016 21:14:44 -0500 (EST)
Received: by mail-io0-f170.google.com with SMTP id g73so143359355ioe.3
        for <linux-mm@kvack.org>; Sun, 31 Jan 2016 18:14:44 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id on1si12087968igb.65.2016.01.31.18.14.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 31 Jan 2016 18:14:43 -0800 (PST)
Date: Mon, 1 Feb 2016 11:15:01 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v1 2/8] mm, kasan: SLAB support
Message-ID: <20160201021501.GB32125@js1304-P5Q-DELUXE>
References: <cover.1453918525.git.glider@google.com>
 <7f497e194053c25e8a3debe3e1e738a187e38c16.1453918525.git.glider@google.com>
 <20160128074442.GB15426@js1304-P5Q-DELUXE>
 <CAG_fn=W_17XMtCmLRHHccJmzPaJTk1Jc4uCa4T_n4E5NwRR9Mg@mail.gmail.com>
 <CAG_fn=VTnFDOVuQzk3NgFGd6D+BoNDSqL4-MYyo0soq+eM76-g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG_fn=VTnFDOVuQzk3NgFGd6D+BoNDSqL4-MYyo0soq+eM76-g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: kasan-dev@googlegroups.com, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, Dmitriy Vyukov <dvyukov@google.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, linux-mm@kvack.org, Andrey Konovalov <adech.fo@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, rostedt@goodmis.org

On Thu, Jan 28, 2016 at 02:29:42PM +0100, Alexander Potapenko wrote:
> On Thu, Jan 28, 2016 at 1:37 PM, Alexander Potapenko <glider@google.com> wrote:
> >
> > On Jan 28, 2016 8:44 AM, "Joonsoo Kim" <iamjoonsoo.kim@lge.com> wrote:
> >>
> >> On Wed, Jan 27, 2016 at 07:25:07PM +0100, Alexander Potapenko wrote:
> >> > This patch adds KASAN hooks to SLAB allocator.
> >> >
> >> > This patch is based on the "mm: kasan: unified support for SLUB and
> >> > SLAB allocators" patch originally prepared by Dmitry Chernenkov.
> >> >
> >> > Signed-off-by: Alexander Potapenko <glider@google.com>
> >> > ---
> >> >  Documentation/kasan.txt  |  5 ++-
> >>
> >> ...
> >>
> >> > +#ifdef CONFIG_SLAB
> >> > +struct kasan_alloc_meta *get_alloc_info(struct kmem_cache *cache,
> >> > +                                     const void *object)
> >> > +{
> >> > +     return (void *)object + cache->kasan_info.alloc_meta_offset;
> >> > +}
> >> > +
> >> > +struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
> >> > +                                   const void *object)
> >> > +{
> >> > +     return (void *)object + cache->kasan_info.free_meta_offset;
> >> > +}
> >> > +#endif
> >>
> >> I cannot find the place to store stack info for free. get_free_info()
> >> isn't used except print_object(). Plese let me know where.
> >
> > This is covered by other patches in this patchset.

This should be covered by this patch. Stroing and printing free_info
is already done on SLUB and it is meaningful without quarantain.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
