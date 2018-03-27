Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 179F06B0012
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 12:23:30 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id w197so5668287iod.23
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 09:23:30 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w5-v6sor864711itb.70.2018.03.27.09.23.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Mar 2018 09:23:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180324084332.u6qik7lkdbenqbb2@gmail.com>
References: <cover.1521828273.git.andreyknvl@google.com> <1fb0a050a84d49f5c3b2210337339412475d1688.1521828273.git.andreyknvl@google.com>
 <20180324084332.u6qik7lkdbenqbb2@gmail.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 27 Mar 2018 18:23:27 +0200
Message-ID: <CAAeHK+za1Zg2+1_CFrQbdn_Hwa9o_nZkHuMLaekV18W380jAoQ@mail.gmail.com>
Subject: Re: [RFC PATCH v2 03/15] khwasan: add CONFIG_KASAN_CLASSIC and CONFIG_KASAN_TAGS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, Michael Weiser <michael.weiser@gmx.de>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Steve Capper <steve.capper@arm.com>, Tyler Baicar <tbaicar@codeaurora.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Stephen Boyd <stephen.boyd@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Paul Lawrence <paullawrence@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, David Woodhouse <dwmw@amazon.co.uk>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Herbert Xu <herbert@gondor.apana.org.au>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, kvmarm@lists.cs.columbia.edu, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On Sat, Mar 24, 2018 at 9:43 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
> * Andrey Konovalov <andreyknvl@google.com> wrote:
>
>> This commit splits the current CONFIG_KASAN config option into two:
>> 1. CONFIG_KASAN_CLASSIC, that enables the classic KASAN version (the one
>>    that exists now);
>> 2. CONFIG_KASAN_TAGS, that enables KHWASAN.
>
> Sorry, but this is pretty obscure naming scheme that doesn't explain the =
primary
> difference between these KASAN models to users: that the first one is a p=
ure
> software implementation and the other is hardware-assisted.
>
> Reminds me of the transparency of galactic buerocracy in "The Hitchhiker'=
s Guide
> to the Galaxy":
>
>   =E2=80=9CBut look, you found the notice, didn=E2=80=99t you?=E2=80=9D
>   =E2=80=9CYes,=E2=80=9D said Arthur, =E2=80=9Cyes I did. It was on displ=
ay in the bottom of a locked filing
>    cabinet stuck in a disused lavatory with a sign on the door saying =E2=
=80=98Beware of the
>    Leopard.=E2=80=9D
>
> I'd suggest something more expressive, such as:
>
>         CONFIG_KASAN
>           CONFIG_KASAN_GENERIC
>           CONFIG_KASAN_HW_ASSIST
>
> or so?
>
> The 'generic' variant will basically run on any CPU. The 'hardware assist=
ed' one
> needs support from the CPU.
>
> The following ones might also work:
>
>    CONFIG_KASAN_HWASSIST
>    CONFIG_KASAN_HW_TAGS
>    CONFIG_KASAN_HWTAGS
>
> ... or simply CONFIG_KASAN_SW/CONFIG_KASAN_HW.
>
> If other types of KASAN hardware acceleration are implemented in the futu=
re then
> the CONFIG_KASAN_HW namespace can be extended:
>
>         CONFIG_KASAN_HW_TAGS
>         CONFIG_KASAN_HW_KEYS
>         etc.

How about these two:

CONFIG_KASAN_GENERIC
CONFIG_KASAN_HW

?

Shorter config name looks better to me and I think it makes sense to
name the new config just HW, as there's only one HW implementation
right now. When (and if) there are more, we can expand the config name
as you suggested (CONFIG_KASAN_HW_TAGS, CONFIG_KASAN_HW_KEYS, etc).

>
>> Both CONFIG_KASAN_CLASSIC and CONFIG_KASAN_CLASSIC support both
>> CONFIG_KASAN_INLINE and CONFIG_KASAN_OUTLINE instrumentation modes.
>
> It would be very surprising if that wasn't so!
>
> Or did you mean 'Both CONFIG_KASAN_CLASSIC and CONFIG_KASAN_TAGS'! ;-)
>
> Thanks,
>
>         Ingo
