Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9737E6B0253
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 08:53:52 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 1so103108296wmz.2
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 05:53:52 -0700 (PDT)
Received: from mail-lf0-x22d.google.com (mail-lf0-x22d.google.com. [2a00:1450:4010:c07::22d])
        by mx.google.com with ESMTPS id 11si1081099ljf.100.2016.08.02.05.53.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 05:53:51 -0700 (PDT)
Received: by mail-lf0-x22d.google.com with SMTP id b199so137800702lfe.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 05:53:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <57A0933F.8000706@virtuozzo.com>
References: <1470062715-14077-1-git-send-email-aryabinin@virtuozzo.com>
 <1470062715-14077-6-git-send-email-aryabinin@virtuozzo.com>
 <CAG_fn=WP2VmNNuzp1YMi+vPLaG9B3JH9TD4FfzxVyeZL2AyM_Q@mail.gmail.com> <57A0933F.8000706@virtuozzo.com>
From: Alexander Potapenko <glider@google.com>
Date: Tue, 2 Aug 2016 14:53:50 +0200
Message-ID: <CAG_fn=ViiZ+WnL_c6vMg5-4HFeBjMJfm9RU15XO6uVKet+YD_w@mail.gmail.com>
Subject: Re: [PATCH 6/6] kasan: improve double-free reports.
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@codemonkey.org.uk>, Vegard Nossum <vegard.nossum@oracle.com>, Sasha Levin <alexander.levin@verizon.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Tue, Aug 2, 2016 at 2:34 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> w=
rote:
>
>
> On 08/02/2016 02:39 PM, Alexander Potapenko wrote:
>
>>> +static void kasan_end_report(unsigned long *flags)
>>> +{
>>> +       pr_err("=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D\n");
>>> +       add_taint(TAINT_BAD_PAGE, LOCKDEP_NOW_UNRELIABLE);
>> Don't we want to add the taint as early as possible once we've
>> detected the error?
>
> What for?
> It certainly shouldn't be before dump_stack(), otherwise on the first rep=
ort the kernel will claimed as tainted.
Ah, got it. Fair enough.
>
>>>
>>> +void kasan_report_double_free(struct kmem_cache *cache, void *object,
>>> +                       s8 shadow)
>>> +{
>>> +       unsigned long flags;
>>> +
>>> +       kasan_start_report(&flags);
>>> +       pr_err("BUG: Double free or corrupt pointer\n");
>> How about "Double free or freeing an invalid pointer\n"?
>> I think "corrupt pointer" doesn't exactly reflect where the bug is.
>
> Ok
>



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
