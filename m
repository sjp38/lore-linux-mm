Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id A70F46B03A5
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 08:52:13 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id a189so140030248qkc.4
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 05:52:13 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 202sor939172qkj.6.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 03 Mar 2017 05:52:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <db0b6605-32bc-4c7a-0c99-2e60e4bdb11f@virtuozzo.com>
References: <20170302134851.101218-1-andreyknvl@google.com>
 <20170302134851.101218-7-andreyknvl@google.com> <db0b6605-32bc-4c7a-0c99-2e60e4bdb11f@virtuozzo.com>
From: Alexander Potapenko <glider@google.com>
Date: Fri, 3 Mar 2017 14:52:11 +0100
Message-ID: <CAG_fn=Vn1tWsRbt4ohkE0E2ijAZsBvVuPS-Ond2KHVh9WK1zkg@mail.gmail.com>
Subject: Re: [PATCH v2 6/9] kasan: improve slab object description
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrey Konovalov <andreyknvl@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Mar 3, 2017 at 2:31 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> w=
rote:
> On 03/02/2017 04:48 PM, Andrey Konovalov wrote:
>> Changes slab object description from:
>>
>> Object at ffff880068388540, in cache kmalloc-128 size: 128
>>
>> to:
>>
>> The buggy address belongs to the object at ffff880068388540
>>  which belongs to the cache kmalloc-128 of size 128
>> The buggy address is located 123 bytes inside of
>>  128-byte region [ffff880068388540, ffff8800683885c0)
>>
>> Makes it more explanatory and adds information about relative offset
>> of the accessed address to the start of the object.
>>
>
> I don't think that this is an improvement. You replaced one simple line w=
ith a huge
> and hard to parse text without giving any new/useful information.
> Except maybe offset, it useful sometimes, so wouldn't mind adding it to d=
escription.
Agreed.
How about:
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Access 123 bytes inside of 128-byte region [ffff880068388540, ffff880068388=
5c0)
Object at ffff880068388540 belongs to the cache kmalloc-128
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
?

> --
> You received this message because you are subscribed to the Google Groups=
 "kasan-dev" group.
> To unsubscribe from this group and stop receiving emails from it, send an=
 email to kasan-dev+unsubscribe@googlegroups.com.
> To post to this group, send email to kasan-dev@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgi=
d/kasan-dev/db0b6605-32bc-4c7a-0c99-2e60e4bdb11f%40virtuozzo.com.
> For more options, visit https://groups.google.com/d/optout.



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
