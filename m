Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2AF536B0522
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 10:56:23 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id z17-v6so19717978iol.20
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 07:56:23 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g206-v6sor373891ioa.139.2018.11.07.07.56.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Nov 2018 07:56:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20181107153456.GE2623@brain-police>
References: <cover.1541525354.git.andreyknvl@google.com> <CAAeHK+yOsP7V0gPu7EpqCbJZqbGQMZbAp6q1+=0dNGC24reyWg@mail.gmail.com>
 <20181107145922.GD2623@brain-police> <CAAeHK+zNgv9WxRpf7N3gmsLYGL6oUALAnyerMzeYZUz1LhoUuA@mail.gmail.com>
 <20181107153456.GE2623@brain-police>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 7 Nov 2018 16:56:21 +0100
Message-ID: <CAAeHK+yRAVo5S1Fb__uzK=drpXRBuB8-KvL8yQL8sfUG-Tr1Mw@mail.gmail.com>
Subject: Re: [PATCH v10 00/22] kasan: add software tag-based mode for arm64
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Christoph Lameter <cl@linux.com>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>

On Wed, Nov 7, 2018 at 4:34 PM, Will Deacon <will.deacon@arm.com> wrote:
>
> I would like the patches that touch code under arch/arm64/ to be reviewed by
> somebody from the arm64 community. Since the core parts have already been
> reviewed, I was suggesting that you could split them out so that they are
> not blocked by the architecture code. Is it not possible to preserve the
> existing KASAN behaviour for arm64 with the core parts merged? I figured it
> must be, since you're not touching any other architectures here and they
> assumedly continue to function correctly.

It's possible to split out the core mm part, but it doesn't make much
sense to merge it separately from the arm64 changes.

> However, if you'd rather keep everything together, please can we give it a
> couple of weeks so we can at least get the architecture bits reviewed? Most
> people are out at LPC next week (and I'm at another conference this week).

OK, sounds good!

Catalin, could you take a look at the arm64 specific changes?
