Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 313686B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 08:29:44 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id l66so25401465wml.0
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 05:29:44 -0800 (PST)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id o11si15328881wjw.191.2016.01.28.05.29.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 05:29:43 -0800 (PST)
Received: by mail-wm0-x234.google.com with SMTP id p63so24782194wmp.1
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 05:29:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAG_fn=W_17XMtCmLRHHccJmzPaJTk1Jc4uCa4T_n4E5NwRR9Mg@mail.gmail.com>
References: <cover.1453918525.git.glider@google.com>
	<7f497e194053c25e8a3debe3e1e738a187e38c16.1453918525.git.glider@google.com>
	<20160128074442.GB15426@js1304-P5Q-DELUXE>
	<CAG_fn=W_17XMtCmLRHHccJmzPaJTk1Jc4uCa4T_n4E5NwRR9Mg@mail.gmail.com>
Date: Thu, 28 Jan 2016 14:29:42 +0100
Message-ID: <CAG_fn=VTnFDOVuQzk3NgFGd6D+BoNDSqL4-MYyo0soq+eM76-g@mail.gmail.com>
Subject: Re: [PATCH v1 2/8] mm, kasan: SLAB support
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: kasan-dev@googlegroups.com, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, Dmitriy Vyukov <dvyukov@google.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, linux-mm@kvack.org, Andrey Konovalov <adech.fo@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, rostedt@goodmis.org

On Thu, Jan 28, 2016 at 1:37 PM, Alexander Potapenko <glider@google.com> wr=
ote:
>
> On Jan 28, 2016 8:44 AM, "Joonsoo Kim" <iamjoonsoo.kim@lge.com> wrote:
>>
>> On Wed, Jan 27, 2016 at 07:25:07PM +0100, Alexander Potapenko wrote:
>> > This patch adds KASAN hooks to SLAB allocator.
>> >
>> > This patch is based on the "mm: kasan: unified support for SLUB and
>> > SLAB allocators" patch originally prepared by Dmitry Chernenkov.
>> >
>> > Signed-off-by: Alexander Potapenko <glider@google.com>
>> > ---
>> >  Documentation/kasan.txt  |  5 ++-
>>
>> ...
>>
>> > +#ifdef CONFIG_SLAB
>> > +struct kasan_alloc_meta *get_alloc_info(struct kmem_cache *cache,
>> > +                                     const void *object)
>> > +{
>> > +     return (void *)object + cache->kasan_info.alloc_meta_offset;
>> > +}
>> > +
>> > +struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
>> > +                                   const void *object)
>> > +{
>> > +     return (void *)object + cache->kasan_info.free_meta_offset;
>> > +}
>> > +#endif
>>
>> I cannot find the place to store stack info for free. get_free_info()
>> isn't used except print_object(). Plese let me know where.
>
> This is covered by other patches in this patchset.
>
>> Thanks.
(resending to linux-kernel@ because the previous mail bounced)


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
