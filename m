Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 82D3F828E2
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 07:58:22 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id g62so24044430wme.0
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 04:58:22 -0800 (PST)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id 20si4995476wmo.74.2016.02.18.04.58.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 04:58:21 -0800 (PST)
Received: by mail-wm0-x233.google.com with SMTP id g62so26054008wme.1
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 04:58:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160201021501.GB32125@js1304-P5Q-DELUXE>
References: <cover.1453918525.git.glider@google.com>
	<7f497e194053c25e8a3debe3e1e738a187e38c16.1453918525.git.glider@google.com>
	<20160128074442.GB15426@js1304-P5Q-DELUXE>
	<CAG_fn=W_17XMtCmLRHHccJmzPaJTk1Jc4uCa4T_n4E5NwRR9Mg@mail.gmail.com>
	<CAG_fn=VTnFDOVuQzk3NgFGd6D+BoNDSqL4-MYyo0soq+eM76-g@mail.gmail.com>
	<20160201021501.GB32125@js1304-P5Q-DELUXE>
Date: Thu, 18 Feb 2016 13:58:20 +0100
Message-ID: <CAG_fn=W7tH3MG9kEtPwZdA+ni3d1aSnFT8vkxXEVVQLsdiqZ+A@mail.gmail.com>
Subject: Re: [PATCH v1 2/8] mm, kasan: SLAB support
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: kasan-dev@googlegroups.com, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, Dmitriy Vyukov <dvyukov@google.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, linux-mm@kvack.org, Andrey Konovalov <adech.fo@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>

However this info is meaningless without saved stack traces, which are
only introduced in the stackdepot patch (see "[PATCH v1 5/8] mm,
kasan: Stackdepot implementation. Enable stackdepot for SLAB")

On Mon, Feb 1, 2016 at 3:15 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> On Thu, Jan 28, 2016 at 02:29:42PM +0100, Alexander Potapenko wrote:
>> On Thu, Jan 28, 2016 at 1:37 PM, Alexander Potapenko <glider@google.com>=
 wrote:
>> >
>> > On Jan 28, 2016 8:44 AM, "Joonsoo Kim" <iamjoonsoo.kim@lge.com> wrote:
>> >>
>> >> On Wed, Jan 27, 2016 at 07:25:07PM +0100, Alexander Potapenko wrote:
>> >> > This patch adds KASAN hooks to SLAB allocator.
>> >> >
>> >> > This patch is based on the "mm: kasan: unified support for SLUB and
>> >> > SLAB allocators" patch originally prepared by Dmitry Chernenkov.
>> >> >
>> >> > Signed-off-by: Alexander Potapenko <glider@google.com>
>> >> > ---
>> >> >  Documentation/kasan.txt  |  5 ++-
>> >>
>> >> ...
>> >>
>> >> > +#ifdef CONFIG_SLAB
>> >> > +struct kasan_alloc_meta *get_alloc_info(struct kmem_cache *cache,
>> >> > +                                     const void *object)
>> >> > +{
>> >> > +     return (void *)object + cache->kasan_info.alloc_meta_offset;
>> >> > +}
>> >> > +
>> >> > +struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
>> >> > +                                   const void *object)
>> >> > +{
>> >> > +     return (void *)object + cache->kasan_info.free_meta_offset;
>> >> > +}
>> >> > +#endif
>> >>
>> >> I cannot find the place to store stack info for free. get_free_info()
>> >> isn't used except print_object(). Plese let me know where.
>> >
>> > This is covered by other patches in this patchset.
>
> This should be covered by this patch. Stroing and printing free_info
> is already done on SLUB and it is meaningful without quarantain.
>
> Thanks.



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
Diese E-Mail ist vertraulich. Wenn Sie nicht der richtige Adressat sind,
leiten Sie diese bitte nicht weiter, informieren Sie den
Absender und l=C3=B6schen Sie die E-Mail und alle Anh=C3=A4nge. Vielen Dank=
.
This e-mail is confidential. If you are not the right addressee please
do not forward it, please inform the sender, and please erase this
e-mail including any attachments. Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
