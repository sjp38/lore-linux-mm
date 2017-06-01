Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 398C46B0317
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 12:52:53 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 62so49237528pft.3
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 09:52:53 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d82si910907pfl.148.2017.06.01.09.52.52
        for <linux-mm@kvack.org>;
        Thu, 01 Jun 2017 09:52:52 -0700 (PDT)
Date: Thu, 1 Jun 2017 17:52:06 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 3/4] arm64/kasan: don't allocate extra shadow memory
Message-ID: <20170601165205.GA8191@leverpostej>
References: <20170601162338.23540-1-aryabinin@virtuozzo.com>
 <20170601162338.23540-3-aryabinin@virtuozzo.com>
 <20170601163442.GC17711@leverpostej>
 <CACT4Y+aCKDF95mK2-nuiV0+XineHha3y+6PCW0-EorOaY=TFng@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+aCKDF95mK2-nuiV0+XineHha3y+6PCW0-EorOaY=TFng@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Alexander Potapenko <glider@google.com>, linux-arm-kernel@lists.infradead.org

On Thu, Jun 01, 2017 at 06:45:32PM +0200, Dmitry Vyukov wrote:
> On Thu, Jun 1, 2017 at 6:34 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> > On Thu, Jun 01, 2017 at 07:23:37PM +0300, Andrey Ryabinin wrote:
> >> We used to read several bytes of the shadow memory in advance.
> >> Therefore additional shadow memory mapped to prevent crash if
> >> speculative load would happen near the end of the mapped shadow memory.
> >>
> >> Now we don't have such speculative loads, so we no longer need to map
> >> additional shadow memory.
> >
> > I see that patch 1 fixed up the Linux helpers for outline
> > instrumentation.
> >
> > Just to check, is it also true that the inline instrumentation never
> > performs unaligned accesses to the shadow memory?
> 
> Inline instrumentation generally accesses only a single byte.

Sorry to be a little pedantic, but does that mean we'll never access the
additional shadow, or does that mean it's very unlikely that we will?

I'm guessing/hoping it's the former!

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
