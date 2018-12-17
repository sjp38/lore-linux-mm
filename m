Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id D18FB8E0033
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 15:39:14 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id c14so10002063pls.21
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 12:39:14 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h9si11872721pgb.319.2018.12.17.12.39.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 12:39:13 -0800 (PST)
Date: Mon, 17 Dec 2018 12:38:47 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v13 19/25] kasan: add hooks implementation for tag-based
 mode
Message-Id: <20181217123847.492b9ae4934bd0d95b0bbbdc@linux-foundation.org>
In-Reply-To: <CAAeHK+w2jppKbb26bBk6uP9ydZeHrtNc6b2CVv4xbvt6ecVooA@mail.gmail.com>
References: <cover.1544099024.git.andreyknvl@google.com>
	<bda78069e3b8422039794050ddcb2d53d053ed41.1544099024.git.andreyknvl@google.com>
	<2bf7415e-2724-b3c3-9571-20c8b6d43b92@arm.com>
	<CAAeHK+xc6R_p26-tu--9W1L1PvUAFb70J23ByiEukKz3uVC3EQ@mail.gmail.com>
	<b99b331d-22ca-b9db-8677-4896c427ef10@arm.com>
	<CAAeHK+w2jppKbb26bBk6uP9ydZeHrtNc6b2CVv4xbvt6ecVooA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Vincenzo Frascino <vincenzo.frascino@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Vishwath Mohan <vishwath@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Jann Horn <jannh@google.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Lee Smith <Lee.Smith@arm.com>, Kostya Serebryany <kcc@google.com>, Mark Brand <markbrand@google.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Evgenii Stepanov <eugenis@google.com>

On Mon, 17 Dec 2018 20:33:42 +0100 Andrey Konovalov <andreyknvl@google.com> wrote:

> > Curiosity, did you try your patches with SLUB red zoning enabled?
> > Since the area used for the Redzone is just after the payload, aligning the
> > object_size independently from the allocator could have side effects, at least
> > if I understand well how the mechanism works.
> >
> > Setting ARCH_SLAB_MINALIGN should avoid this as well.
> >
> > What do you think?
> 
> Sounds good to me.
> 
> Andrew, how should proceed with this? Send another fixup patch or
> resend the whole series?

It depends on how extensive the changes are.  I prefer a fixup, but at
some point it's time to drop it all and start again.
