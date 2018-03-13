Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 957B06B000D
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 12:49:14 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id j11so526768ioe.5
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 09:49:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g42sor301918ioj.231.2018.03.13.09.49.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Mar 2018 09:49:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAG_fn=UfNxWkfza5=W9zGXcuDW7zfTAGuPunfcYn5ZriTjjeVA@mail.gmail.com>
References: <cover.1520017438.git.andreyknvl@google.com> <1943a345f4fb7e8e8f19b4ece2457bccd772f0dc.1520017438.git.andreyknvl@google.com>
 <CAG_fn=UfNxWkfza5=W9zGXcuDW7zfTAGuPunfcYn5ZriTjjeVA@mail.gmail.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 13 Mar 2018 17:49:11 +0100
Message-ID: <CAAeHK+xpNMHej6jtcfgCtbdb=gBfgHwJoF9FeAhOaJ=rtanaYA@mail.gmail.com>
Subject: Re: [RFC PATCH 14/14] khwasan: default the instrumentation mode to inline
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Bob Picco <bob.picco@oracle.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On Tue, Mar 13, 2018 at 3:44 PM, Alexander Potapenko <glider@google.com> wr=
ote:
> On Fri, Mar 2, 2018 at 8:44 PM, Andrey Konovalov <andreyknvl@google.com> =
wrote:
>> There are two reasons to use outline instrumentation:
>> 1. Outline instrumentation reduces the size of the kernel text, and shou=
ld
>>    be used where this size matters.
>> 2. Outline instrumentation is less invasive and can be used for debuggin=
g
>>    for KASAN developers, when it's not clear whether some issue is cause=
d
>>    by KASAN or by something else.
>
> Don't you think this patch can be landed separately from the KHWASAN seri=
es?

Sure, I can mail it separately.

>
>> For the rest cases inline instrumentation is preferrable, since it's
>> faster.
>>
>> This patch changes the default instrumentation mode to inline.
>> ---
>>  lib/Kconfig.kasan | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
>> index ab34e7d7d3a7..8ea6ae26b4a3 100644
>> --- a/lib/Kconfig.kasan
>> +++ b/lib/Kconfig.kasan
>> @@ -70,7 +70,7 @@ config KASAN_EXTRA
>>  choice
>>         prompt "Instrumentation type"
>>         depends on KASAN
>> -       default KASAN_OUTLINE
>> +       default KASAN_INLINE
>>
>>  config KASAN_OUTLINE
>>         bool "Outline instrumentation"
>> --
>> 2.16.2.395.g2e18187dfd-goog
>>
> Reviewed-by: Alexander Potapenko <glider@google.com>
>
>
>
>
> --
> Alexander Potapenko
> Software Engineer
>
> Google Germany GmbH
> Erika-Mann-Stra=C3=9Fe, 33
> 80636 M=C3=BCnchen
>
> Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
> Registergericht und -nummer: Hamburg, HRB 86891
> Sitz der Gesellschaft: Hamburg
