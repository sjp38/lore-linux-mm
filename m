Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E91546B007E
	for <linux-mm@kvack.org>; Wed, 11 May 2016 11:33:06 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w143so45527277wmw.3
        for <linux-mm@kvack.org>; Wed, 11 May 2016 08:33:06 -0700 (PDT)
Received: from mail-lf0-x230.google.com (mail-lf0-x230.google.com. [2a00:1450:4010:c07::230])
        by mx.google.com with ESMTPS id y7si1532102lbq.192.2016.05.11.08.33.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 May 2016 08:33:05 -0700 (PDT)
Received: by mail-lf0-x230.google.com with SMTP id y84so53845295lfc.0
        for <linux-mm@kvack.org>; Wed, 11 May 2016 08:33:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAG_fn=Xuv_b7k9VCPu=93Ats6eG6LvJn9cFDW75D=_OD=eawQw@mail.gmail.com>
References: <1462887534-30428-1-git-send-email-aryabinin@virtuozzo.com>
	<CAG_fn=UdD=gvFXOSMh3b+PzHerh6HD0ydrDYTEeXf1gPgMuBZw@mail.gmail.com>
	<57331368.9070101@virtuozzo.com>
	<CAG_fn=Xuv_b7k9VCPu=93Ats6eG6LvJn9cFDW75D=_OD=eawQw@mail.gmail.com>
Date: Wed, 11 May 2016 17:33:05 +0200
Message-ID: <CAG_fn=VtVQ6+CP0J58ANRBn-7fH-wycbiLuurEY8kMnorNySog@mail.gmail.com>
Subject: Re: [PATCH] mm-kasan-initial-memory-quarantine-implementation-v8-fix
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>

On Wed, May 11, 2016 at 4:30 PM, Alexander Potapenko <glider@google.com> wr=
ote:
> On Wed, May 11, 2016 at 1:11 PM, Andrey Ryabinin
> <aryabinin@virtuozzo.com> wrote:
>> On 05/11/2016 01:18 PM, Alexander Potapenko wrote:
>>> On Tue, May 10, 2016 at 3:38 PM, Andrey Ryabinin
>>> <aryabinin@virtuozzo.com> wrote:
>>>>  * Fix comment styles,
>>>  yDid you remove the comments from include/linux/kasan.h because they
>>> were put inconsistently, or was there any other reason?
>>
>> We usually comment functions near definition, not declarations.
>> If you like, put comment back. Just place it near definition.
>>
>>>>  * Get rid of some ifdefs
>>> Thanks!
>>>>  * Revert needless functions renames in quarantine patch
>>> I believe right now the names are somewhat obscure. I agree however
>>> the change should be done in a separate patch.
>>
>> Besides that, I didn't like the fact that you made names longer and exce=
eded
>> 80-char limit in some places.
>>
>>>>  * Remove needless local_irq_save()/restore() in per_cpu_remove_cache(=
)
>>> Ack
>>>>  * Add new 'struct qlist_node' instead of 'void **' types. This makes
>>>>    code a bit more redable.
>>> Nice, thank you!
>>>
>>> How do I incorporate your changes? Is it ok if I merge it with the
>>> next version of my patch and add a "Signed-off-by: Andrey Ryabinin
>>> <aryabinin@virtuozzo.com>" line to the description?
>>>
>>
>> Ok, but I don't think that this is matters. Andrew will just craft a dif=
f patch
>> on top of the current code anyways.
>> Or you can make such diff by yourself and send it, it's easier to review=
, after all.
>>
> The kernel crashed for me when I applied your patch.
>
> I also had to make the following change:
>
> +++ b/mm/kasan/quarantine.c
> @@ -245,7 +245,7 @@ static void qlist_move_cache(struct qlist_head *from,
>
>         prev =3D from->head;
>         while (prev) {
> -               struct qlist_node *qlink =3D prev->next;
> +               struct qlist_node *qlink =3D prev;
>                 struct kmem_cache *obj_cache =3D qlink_to_cache(qlink);
>
>                 if (obj_cache =3D=3D cache) {
>
Well, not really.
I had to rewrite qlist_move_cache(), will send a new patch shortly.
>
> --
> Alexander Potapenko
> Software Engineer
>
> Google Germany GmbH
> Erika-Mann-Stra=C3=9Fe, 33
> 80636 M=C3=BCnchen
>
> Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
> Registergericht und -nummer: Hamburg, HRB 86891
> Sitz der Gesellschaft: Hamburg



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
