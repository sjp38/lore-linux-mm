Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1882D8E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 11:28:11 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id s200-v6so9963394oie.6
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:28:11 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d127-v6si3515801oia.329.2018.09.14.08.28.09
        for <linux-mm@kvack.org>;
        Fri, 14 Sep 2018 08:28:09 -0700 (PDT)
Date: Fri, 14 Sep 2018 16:28:26 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v6 00/18] khwasan: kernel hardware assisted address
 sanitizer
Message-ID: <20180914152825.GC6236@arm.com>
References: <cover.1535462971.git.andreyknvl@google.com>
 <20180905141032.b1ddaab53d1b2b3bada95415@linux-foundation.org>
 <20180906100543.GI3592@arm.com>
 <CAAeHK+wStsNwh2oKv-KCG4kx5538FuDMQ6Yw2X=sK5LPrw2DZg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+wStsNwh2oKv-KCG4kx5538FuDMQ6Yw2X=sK5LPrw2DZg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Lameter <cl@linux.com>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>

On Thu, Sep 06, 2018 at 01:06:23PM +0200, Andrey Konovalov wrote:
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

Ok, sorry, I completely misunderstood you earlier on then! For some reason
I thought you wanted this on by default.

In which case, I'm ok with the overall idea as long as we make the caveats
clear in the Kconfig text. In particular, that enabling this option may
introduce problems relating to pointer casting and comparison, but can
offer better coverage and lower memory consumption than a fully
software-based KASAN solution.

Will
