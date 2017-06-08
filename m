Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0C0036B02FD
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 22:43:13 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u8so11013137pgo.11
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 19:43:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 10sor1833732pfh.8.2017.06.07.19.43.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Jun 2017 19:43:12 -0700 (PDT)
Date: Thu, 8 Jun 2017 11:43:05 +0900
From: Joonsoo Kim <js1304@gmail.com>
Subject: Re: [PATCH v1 00/11] mm/kasan: support per-page shadow memory to
 reduce memory consumption
Message-ID: <20170608024303.GC27998@js1304-desktop>
References: <CACT4Y+YREmHViSMsH84bwtEqbUsqsgzaa76eWzJXqmSgqKbgvg@mail.gmail.com>
 <20170524074539.GA9697@js1304-desktop>
 <CACT4Y+ZwL+iTMvF5NpsovThQrdhunCc282ffjqQcgZg3tAQH4w@mail.gmail.com>
 <20170525004104.GA21336@js1304-desktop>
 <CACT4Y+YV7Rf93NOa1yi0NiELX7wfwkfQmXJ67hEVOrG7VkuJJg@mail.gmail.com>
 <CACT4Y+ZrUi_YGkwmbuGV2_6wC7Q54at1_xyYeT3dQQ=cNm1NsQ@mail.gmail.com>
 <CACT4Y+bT=aaC+XTMwoON-Rc5gOheAj702anXKJMXDJ5FtLDRMw@mail.gmail.com>
 <3a7664a9-e360-ab68-610a-1b697a4b00b5@virtuozzo.com>
 <20170531055047.GA21606@js1304-desktop>
 <80f2f6f7-0a37-53dc-843e-1adbed4377fa@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <80f2f6f7-0a37-53dc-843e-1adbed4377fa@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com

On Wed, May 31, 2017 at 07:31:53PM +0300, Andrey Ryabinin wrote:
> On 05/31/2017 08:50 AM, Joonsoo Kim wrote:
> >>> But the main win as I see it is that that's basically complete support
> >>> for 32-bit arches. People do ask about arm32 support:
> >>> https://groups.google.com/d/msg/kasan-dev/Sk6BsSPMRRc/Gqh4oD_wAAAJ
> >>> https://groups.google.com/d/msg/kasan-dev/B22vOFp-QWg/EVJPbrsgAgAJ
> >>> and probably mips32 is relevant as well.
> >>
> >> I don't see how above is relevant for 32-bit arches. Current design
> >> is perfectly fine for 32-bit arches. I did some POC arm32 port couple years
> >> ago - https://github.com/aryabinin/linux/commits/kasan/arm_v0_1
> >> It has some ugly hacks and non-critical bugs. AFAIR it also super-slow because I (mistakenly) 
> >> made shadow memory uncached. But otherwise it works.
> > 
> > Could you explain that where is the code to map shadow memory uncached?
> > I don't find anything related to it.
> > 
> 
> I didn't set set any cache policy (L_PTE_MT_*) on shadow mapping (see set_pte_at() calls )
> which means it's L_PTE_MT_UNCACHED 

Thanks for pointing it out.

I did some quick tests and found that it's not super(?) slow on my
QEMU. Maybe, it would be different with real machine.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
