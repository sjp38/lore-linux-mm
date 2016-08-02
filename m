Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 182676B025E
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 06:27:28 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id e7so91449789lfe.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 03:27:28 -0700 (PDT)
Received: from mail-lf0-x22e.google.com (mail-lf0-x22e.google.com. [2a00:1450:4010:c07::22e])
        by mx.google.com with ESMTPS id d199si775947lfg.254.2016.08.02.03.27.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 03:27:26 -0700 (PDT)
Received: by mail-lf0-x22e.google.com with SMTP id l69so134838931lfg.1
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 03:27:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <57A074AF.3040505@virtuozzo.com>
References: <1470063563-96266-1-git-send-email-glider@google.com>
 <57A06F23.9080804@virtuozzo.com> <CACT4Y+ad6ZY=1=kM0FGZD8LtOaupV4c0AW0mXjMoxMNRsH2omA@mail.gmail.com>
 <CAG_fn=X2zahG9enAdSPxwqC-VV6nwK2PhuAXPyhOvASnXok9JQ@mail.gmail.com> <57A074AF.3040505@virtuozzo.com>
From: Alexander Potapenko <glider@google.com>
Date: Tue, 2 Aug 2016 12:27:25 +0200
Message-ID: <CAG_fn=VNGWwLzctnOXv0hS7aAod9jfJXrX-hk6X7RK3Egt0vtQ@mail.gmail.com>
Subject: Re: [PATCH] kasan: avoid overflowing quarantine size on low memory systems
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Aug 2, 2016 at 12:23 PM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
>
>
> On 08/02/2016 01:07 PM, Alexander Potapenko wrote:
>> On Tue, Aug 2, 2016 at 12:05 PM, Dmitry Vyukov <dvyukov@google.com> wrot=
e:
>>> On Tue, Aug 2, 2016 at 12:00 PM, Andrey Ryabinin
>>>>
>>>> Why WARN? I'd suggest pr_warn_once();
>>>
>>>
>>> I would suggest to just do something useful. Setting quarantine
>>> new_quarantine_size to 0 looks fine.
>>> What would user do with this warning? Number of CPUs and amount of
>>> memory are generally fixed. Why is it an issue for end user at all? We
>>> still have some quarantine per-cpu. A WARNING means a [non-critical]
>>> kernel bug. E.g. syzkaller will catch each and every boot of such
>>> system as a bug.
>> How about printk_once then?
>> Silently setting the quarantine size to zero may puzzle the user.
>>
>
> Nope, user will not notice anything. So keeping it silent would be better=
.
> Plus it's very unlikely that this will ever happen in real life.
>
Ok, I've sent out v2, please take a look.


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
