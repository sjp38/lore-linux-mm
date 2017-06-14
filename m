Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F123C6B0279
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 20:12:14 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c75so79463388pfk.3
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 17:12:14 -0700 (PDT)
Received: from mail-pg0-x232.google.com (mail-pg0-x232.google.com. [2607:f8b0:400e:c05::232])
        by mx.google.com with ESMTPS id d4si935877pgc.141.2017.06.13.17.12.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 17:12:13 -0700 (PDT)
Received: by mail-pg0-x232.google.com with SMTP id f185so67316425pgc.0
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 17:12:13 -0700 (PDT)
Date: Wed, 14 Jun 2017 09:12:03 +0900
From: Joonsoo Kim <js1304@gmail.com>
Subject: Re: [PATCH v1 00/11] mm/kasan: support per-page shadow memory to
 reduce memory consumption
Message-ID: <20170614001200.GA12324@js1304-desktop>
References: <20170524074539.GA9697@js1304-desktop>
 <CACT4Y+ZwL+iTMvF5NpsovThQrdhunCc282ffjqQcgZg3tAQH4w@mail.gmail.com>
 <20170525004104.GA21336@js1304-desktop>
 <CACT4Y+YV7Rf93NOa1yi0NiELX7wfwkfQmXJ67hEVOrG7VkuJJg@mail.gmail.com>
 <CACT4Y+ZrUi_YGkwmbuGV2_6wC7Q54at1_xyYeT3dQQ=cNm1NsQ@mail.gmail.com>
 <CACT4Y+bT=aaC+XTMwoON-Rc5gOheAj702anXKJMXDJ5FtLDRMw@mail.gmail.com>
 <3a7664a9-e360-ab68-610a-1b697a4b00b5@virtuozzo.com>
 <CACT4Y+at_NESQ8qq4zouArnu5yySQHxC2oW+RuXzqX8hyspZ_g@mail.gmail.com>
 <20170608024014.GB27998@js1304-desktop>
 <9d64af04-cee5-25dd-4353-1aef4c69f980@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9d64af04-cee5-25dd-4353-1aef4c69f980@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com

On Tue, Jun 13, 2017 at 07:49:47PM +0300, Andrey Ryabinin wrote:
> On 06/08/2017 05:40 AM, Joonsoo Kim wrote:
> >>>
> >>> I don't understand why we trying to invent some hacky/complex schemes when we already have
> >>> a simple one - scaling shadow to 1/32. It's easy to implement and should be more performant comparing
> >>> to suggested schemes.
> >>
> >>
> >> If 32-bits work with the current approach, then I would also prefer to
> >> keep things simpler.
> >> FWIW clang supports settings shadow scale via a command line flag
> >> (-asan-mapping-scale).
> > 
> > Hello,
> > 
> > To confirm the final consensus, I did a quick comparison of scaling
> > approach and mine. Note that scaling approach can be co-exist with
> > mine. And, there is an assumption that we can disable quarantine and
> > other optional feature of KASAN.
> > 
> > Scaling vs Mine
> > 
> > Memory usage: 1/32 of total memory. vs can be far less than 1/32.
> > Slab object layout: should be changed. vs none.
> > Usability: hard. vs simple. (Updating compiler is not required)
> > Implementation complexity: simple. vs complex.
> > Porting to other ARCH: simple. vs hard (But, not mandatory)
> 
> 
> My main concern is a huge amount of complex and fragile code that comes with this patchset.
> Basically you are building a completely new algorithm on the fundamentals that were designed
> for the current algorithm. Hence you have to do these hacks with black shadow, tlb flushing, etc.
> 
> Yes, it does consume less memory, but I'm not convinced that such aggressive memory saving
> are mandatory. I guess that for the most of the users (if not all) that currently unsatisfied with 1/8 shadow
> 1/32 will be good enough.
> FWIW I did run sanitized kernel (1/8 shadow) on the smart TVs with 1Gb of ram.
> 
> > So, do both you disagree to merge my per-page shadow? If so, I will
> > not submit v2. Please let me know your decision.
> > 
> 
> Sorry, but it's a nack from me.

I understand your decision. Thanks for looking this.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
