Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 15C0B6B0007
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 03:01:55 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id l17-v6so1332717uak.9
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 00:01:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 9-v6sor2411816vkp.290.2018.06.28.00.01.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Jun 2018 00:01:53 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1530018818.git.andreyknvl@google.com> <20180627160800.3dc7f9ee41c0badbf7342520@linux-foundation.org>
 <CAN=P9pivApAo76Kjc0TUDE0kvJn0pET=47xU6e=ioZV2VqO0Rg@mail.gmail.com>
In-Reply-To: <CAN=P9pivApAo76Kjc0TUDE0kvJn0pET=47xU6e=ioZV2VqO0Rg@mail.gmail.com>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Thu, 28 Jun 2018 09:01:42 +0200
Message-ID: <CAMuHMdVVutxU3paxcjsuLVjCuooHqs61o0DEySkOK1zUeMj2tw@mail.gmail.com>
Subject: Re: [PATCH v4 00/17] khwasan: kernel hardware assisted address sanitizer
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kostya Serebryany <kcc@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Konovalov <andreyknvl@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Greg KH <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux MM <linux-mm@kvack.org>, linux-kbuild <linux-kbuild@vger.kernel.org>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, cpandya@codeaurora.org, vishwath@google.com

Hi Kostya,

On Thu, Jun 28, 2018 at 2:04 AM Kostya Serebryany <kcc@google.com> wrote:
> On Wed, Jun 27, 2018 at 4:08 PM Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Tue, 26 Jun 2018 15:15:10 +0200 Andrey Konovalov <andreyknvl@google.com> wrote:
> > > This patchset adds a new mode to KASAN [1], which is called KHWASAN
> > > (Kernel HardWare assisted Address SANitizer).
> > >
> > > The plan is to implement HWASan [2] for the kernel with the incentive,
> > > that it's going to have comparable to KASAN performance, but in the same
> > > time consume much less memory, trading that off for somewhat imprecise
> > > bug detection and being supported only for arm64.
> >
> > Why do we consider this to be a worthwhile change?
> >
> > Is KASAN's memory consumption actually a significant problem?  Some
> > data regarding that would be very useful.
>
> On mobile, ASAN's and KASAN's memory usage is a significant problem.
> Not sure if I can find scientific evidence of that.
> CC-ing Vishwath Mohan who deals with KASAN on Android to provide
> anecdotal evidence.
>
> There are several other benefits too:
> * HWASAN more reliably detects non-linear-buffer-overflows compared to
> ASAN (same for kernel-HWASAN vs kernel-ASAN)
> * Same for detecting use-after-free (since HWASAN doesn't rely on quarantine).
> * Much easier to implement stack-use-after-return detection (which
> IIRC KASAN doesn't have yet, because in KASAN it's too hard)
>
> > If it is a large problem then we still have that problem on x86, so the
> > problem remains largely unsolved?
>
> The problem is more significant on mobile devices than on desktop/server.
> I'd love to have [K]HWASAN on x86_64 as well, but it's less trivial since x86_64
> doesn't have an analog of aarch64's top-byte-ignore hardware feature.

This depends on your mobile devices and desktops and servers.
There exist mobile devices with more memory than some desktops or servers.

So actual numbers (O(KiB)? O(MiB)? O(GiB)?) would be nice to have.

Thanks!

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
