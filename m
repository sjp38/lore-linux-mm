Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 5DDF06B0255
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 05:01:27 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so17080595pdr.2
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 02:01:27 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id ew4si2742530pdb.33.2015.08.13.02.01.26
        for <linux-mm@kvack.org>;
        Thu, 13 Aug 2015 02:01:26 -0700 (PDT)
Date: Thu, 13 Aug 2015 10:01:19 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 0/2] x86/KASAN updates for 4.3
Message-ID: <20150813090119.GA10280@arm.com>
References: <1439444244-26057-1-git-send-email-ryabinin.a.a@gmail.com>
 <20150813065040.GA17983@gmail.com>
 <20150813081641.GA14402@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150813081641.GA14402@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Arnd Bergmann <arnd@arndb.de>, Linus Walleij <linus.walleij@linaro.org>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Alexey Klimov <klimov.linux@gmail.com>, Yury <yury.norov@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Hi Ingo,

On Thu, Aug 13, 2015 at 09:16:41AM +0100, Ingo Molnar wrote:
> * Ingo Molnar <mingo@kernel.org> wrote:
> > * Andrey Ryabinin <ryabinin.a.a@gmail.com> wrote:
> > 
> > > These 2 patches taken from v5 'KASAN for arm64' series.
> > > The only change is updated changelog in second patch.
> > > 
> > > I hope this is not too late to queue these for 4.3,
> > > as this allow us to merge arm64/KASAN patches in v4.4
> > > through arm64 tree.
> > > 
> > > Andrey Ryabinin (2):
> > >   x86/kasan: define KASAN_SHADOW_OFFSET per architecture
> > >   x86/kasan, mm: introduce generic kasan_populate_zero_shadow()
> > > 
> > >  arch/x86/include/asm/kasan.h |   3 +
> > >  arch/x86/mm/kasan_init_64.c  | 123 ++--------------------------------
> > >  include/linux/kasan.h        |  10 ++-
> > >  mm/kasan/Makefile            |   2 +-
> > >  mm/kasan/kasan_init.c        | 152 +++++++++++++++++++++++++++++++++++++++++++
> > >  5 files changed, 170 insertions(+), 120 deletions(-)
> > >  create mode 100644 mm/kasan/kasan_init.c
> > 
> > It's absolutely too late in the -rc cycle for v4.3!
> 
> Stupid me, I have read 'v4.2' ...
> 
> So yes, it's still good for v4.3, the development window is still open.
> 
> The rest still stands:
> 
> > I can create a stable topic tree for it, tip:mm/kasan or so, which arm64 could 
> > pull and base its own ARM specific work on, if that's OK with everyone.

Yes please, works for me! If we're targetting 4.3, then please can you base
on 4.2-rc4, as that's what our current arm64 queue is using?

Cheers,

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
