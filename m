Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id F3D8C6B0038
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 07:12:07 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so53577715ioi.2
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 04:12:07 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g69si31235336ioe.134.2015.10.08.04.12.07
        for <linux-mm@kvack.org>;
        Thu, 08 Oct 2015 04:12:07 -0700 (PDT)
Date: Thu, 8 Oct 2015 12:11:44 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH v6 0/6] KASAN for arm64
Message-ID: <20151008111144.GC7275@leverpostej>
References: <1442482692-6416-1-git-send-email-ryabinin.a.a@gmail.com>
 <20151007100411.GG3069@e104818-lin.cambridge.arm.com>
 <CAPAsAGxR-yqtmFeo65Xw_0RQyEy=mN1uG=GKtqoMLr_x_N0u5w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPAsAGxR-yqtmFeo65Xw_0RQyEy=mN1uG=GKtqoMLr_x_N0u5w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Yury <yury.norov@gmail.com>, Alexey Klimov <klimov.linux@gmail.com>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Linus Walleij <linus.walleij@linaro.org>, LKML <linux-kernel@vger.kernel.org>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Mark Salter <msalter@redhat.com>, linux-efi@vger.kernel.org

On Thu, Oct 08, 2015 at 01:36:09PM +0300, Andrey Ryabinin wrote:
> 2015-10-07 13:04 GMT+03:00 Catalin Marinas <catalin.marinas@arm.com>:
> > On Thu, Sep 17, 2015 at 12:38:06PM +0300, Andrey Ryabinin wrote:
> >> As usual patches available in git
> >>       git://github.com/aryabinin/linux.git kasan/arm64v6
> >>
> >> Changes since v5:
> >>  - Rebase on top of 4.3-rc1
> >>  - Fixed EFI boot.
> >>  - Updated Doc/features/KASAN.
> >
> > I tried to merge these patches (apart from the x86 one which is already
> > merged) but it still doesn't boot on Juno as an EFI application.
> >
> 
> 4.3-rc1 was ok and 4.3-rc4 is not. Break caused by 0ce3cc008ec04
> ("arm64/efi: Fix boot crash by not padding between EFI_MEMORY_RUNTIME
> regions")
> It introduced sort() call in efi_get_virtmap().
> sort() is generic kernel function and it's instrumented, so we crash
> when KASAN tries to access shadow in sort().

I believe this is solved by Ard's stub isolation series [1,2], which
will build a stub-specific copy of sort() and various other functions
(see the arm-deps in [2]).

So long as the stub is not built with ASAN, that should work.

Mark.

[1] http://lists.infradead.org/pipermail/linux-arm-kernel/2015-October/373807.html
[2] http://lists.infradead.org/pipermail/linux-arm-kernel/2015-October/373808.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
