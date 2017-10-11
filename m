Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 92AE46B0253
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 05:57:10 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id d3so572268uai.7
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 02:57:10 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i92sor2663817uad.41.2017.10.11.02.57.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Oct 2017 02:57:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <6184cd73-6d78-b490-3fdd-2d577ef033a6@virtuozzo.com>
References: <20171010152731.26031-1-glider@google.com> <20171010152731.26031-2-glider@google.com>
 <6184cd73-6d78-b490-3fdd-2d577ef033a6@virtuozzo.com>
From: Alexander Potapenko <glider@google.com>
Date: Wed, 11 Oct 2017 11:57:08 +0200
Message-ID: <CAG_fn=UFQe7wrTcDxGAfi3Gr=JMjYDg_cRLxeDsxm508mR3yKg@mail.gmail.com>
Subject: Re: [PATCH v3 2/3] Makefile: support flag -fsanitizer-coverage=trace-cmp
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Alexander Popov <alex.popov@linux.com>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrey Konovalov <andreyknvl@google.com>, Kees Cook <keescook@chromium.org>, Vegard Nossum <vegard.nossum@oracle.com>, syzkaller <syzkaller@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Oct 10, 2017 at 5:51 PM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
>
>
> On 10/10/2017 06:27 PM, Alexander Potapenko wrote:
>>
>> v3: - Andrey Ryabinin's comments: reinstated scripts/Makefile.kcov
>>       and moved CFLAGS_KCOV there, dropped CFLAGS_KCOV_COMPS
>
> Huh? Try again.
Reverted Makefile.lib in v4. Thanks!
>> diff --git a/scripts/Makefile.lib b/scripts/Makefile.lib
>> index 5e975fee0f5b..7ddd5932c832 100644
>> --- a/scripts/Makefile.lib
>> +++ b/scripts/Makefile.lib
>> @@ -142,6 +142,12 @@ _c_flags +=3D $(if $(patsubst n%,, \
>>       $(CFLAGS_KCOV))
>>  endif
>>
>> +ifeq ($(CONFIG_KCOV_ENABLE_COMPARISONS),y)
>> +_c_flags +=3D $(if $(patsubst n%,, \
>> +     $(KCOV_INSTRUMENT_$(basetarget).o)$(KCOV_INSTRUMENT)$(CONFIG_KCOV_=
INSTRUMENT_ALL)), \
>> +     $(CFLAGS_KCOV_COMPS))
>> +endif
>> +
>>  # If building the kernel in a separate objtree expand all occurrences
>>  # of -Idir to -I$(srctree)/dir except for absolute paths (starting with=
 '/').
>>
>>



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
