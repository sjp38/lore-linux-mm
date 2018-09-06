Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 249156B79A9
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 12:40:05 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id bh1-v6so5752388plb.15
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 09:40:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a66-v6sor1367213pla.133.2018.09.06.09.40.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Sep 2018 09:40:03 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1535462971.git.andreyknvl@google.com> <20180905141032.b1ddaab53d1b2b3bada95415@linux-foundation.org>
 <20180906100543.GI3592@arm.com> <CAAeHK+wStsNwh2oKv-KCG4kx5538FuDMQ6Yw2X=sK5LPrw2DZg@mail.gmail.com>
In-Reply-To: <CAAeHK+wStsNwh2oKv-KCG4kx5538FuDMQ6Yw2X=sK5LPrw2DZg@mail.gmail.com>
From: Nick Desaulniers <ndesaulniers@google.com>
Date: Thu, 6 Sep 2018 09:39:51 -0700
Message-ID: <CAKwvOdk=F=kja-ZznrifTO8EASmPF0CoTPWbFxpMqLk-_KGEEQ@mail.gmail.com>
Subject: Re: [PATCH v6 00/18] khwasan: kernel hardware assisted address sanitizer
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Lameter <cl@linux.com>, Mark Rutland <mark.rutland@arm.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg KH <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgenii Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>

On Thu, Sep 6, 2018 at 4:06 AM Andrey Konovalov <andreyknvl@google.com> wrote:
>
> On Thu, Sep 6, 2018 at 12:05 PM, Will Deacon <will.deacon@arm.com> wrote:
> > On Wed, Sep 05, 2018 at 02:10:32PM -0700, Andrew Morton wrote:
> >> On Wed, 29 Aug 2018 13:35:04 +0200 Andrey Konovalov <andreyknvl@google.com> wrote:
> >>
> >> > This patchset adds a new mode to KASAN [1], which is called KHWASAN
> >> > (Kernel HardWare assisted Address SANitizer).
> >>
> >> We're at v6 and there are no reviewed-by's or acked-by's to be seen.
> >> Is that a fair commentary on what has been happening, or have people
> >> been remiss in sending and gathering such things?
> >
> > I still have concerns about the consequences of merging this as anything
> > other than a debug option [1]. Unfortunately, merging it as a debug option
> > defeats the whole point, so I think we need to spend more effort on developing
> > tools that can help us to find and fix the subtle bugs which will arise from
> > enabling tagged pointers in the kernel.
>
> I totally don't mind calling it a debug option. Do I need to somehow
> specify it somewhere?
>
> Why does it defeat the point? The point is to ease KASAN-like testing
> on devices with limited memory.

I don't disagree with using it strictly for debug.  When I say I want
the series for Pixel phones, I should have been clearer that my intent
is for a limited pool of internal testers to walk around with KHWASAN
enabled devices; not general end users.  It's hard enough today to get
anyone to test KASAN/ASAN on their "daily driver" due to the memory
usage and resulting performance.

We don't ship KASAN or KUBSAN on by default to end users (nor plan
to); it's used strictly for fuzzing through syzkaller (or by brave
"dogfooders" on the internal kernel teams).  KHWASAN would let these
dogfooders go from being brave to fearless.

-- 
Thanks,
~Nick Desaulniers
