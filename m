Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 544BF8E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 08:31:50 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id g7so11892970plp.10
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 05:31:50 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e19sor25566712pfb.55.2018.12.18.05.31.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Dec 2018 05:31:49 -0800 (PST)
MIME-Version: 1.0
References: <cover.1544099024.git.andreyknvl@google.com> <bda78069e3b8422039794050ddcb2d53d053ed41.1544099024.git.andreyknvl@google.com>
 <2bf7415e-2724-b3c3-9571-20c8b6d43b92@arm.com> <CAAeHK+xc6R_p26-tu--9W1L1PvUAFb70J23ByiEukKz3uVC3EQ@mail.gmail.com>
 <b99b331d-22ca-b9db-8677-4896c427ef10@arm.com> <CAAeHK+w2jppKbb26bBk6uP9ydZeHrtNc6b2CVv4xbvt6ecVooA@mail.gmail.com>
 <20181217123847.492b9ae4934bd0d95b0bbbdc@linux-foundation.org>
In-Reply-To: <20181217123847.492b9ae4934bd0d95b0bbbdc@linux-foundation.org>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 18 Dec 2018 14:31:37 +0100
Message-ID: <CAAeHK+yiGcu4u7rvugfY7wGUiHug7C1wvSuygXN6L5-wWMHtyw@mail.gmail.com>
Subject: Re: [PATCH v13 19/25] kasan: add hooks implementation for tag-based mode
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vincenzo Frascino <vincenzo.frascino@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Vishwath Mohan <vishwath@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Jann Horn <jannh@google.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Lee Smith <Lee.Smith@arm.com>, Kostya Serebryany <kcc@google.com>, Mark Brand <markbrand@google.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Evgenii Stepanov <eugenis@google.com>

On Mon, Dec 17, 2018 at 9:38 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Mon, 17 Dec 2018 20:33:42 +0100 Andrey Konovalov <andreyknvl@google.com> wrote:
>
> > > Curiosity, did you try your patches with SLUB red zoning enabled?
> > > Since the area used for the Redzone is just after the payload, aligning the
> > > object_size independently from the allocator could have side effects, at least
> > > if I understand well how the mechanism works.
> > >
> > > Setting ARCH_SLAB_MINALIGN should avoid this as well.
> > >
> > > What do you think?
> >
> > Sounds good to me.
> >
> > Andrew, how should proceed with this? Send another fixup patch or
> > resend the whole series?
>
> It depends on how extensive the changes are.  I prefer a fixup, but at
> some point it's time to drop it all and start again.

The fixup in only a few lines, so I just sent it as a separate patch
named "[PATCH mm] kasan, arm64: use ARCH_SLAB_MINALIGN instead of
manual aligning".

Thanks!
