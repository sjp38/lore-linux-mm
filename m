Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 594C08E00E5
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 22:54:41 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id u32so16997704qte.1
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 19:54:41 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i64sor8684583qke.133.2018.12.11.19.54.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 19:54:40 -0800 (PST)
Subject: Re: [PATCH] arm64: increase stack size for KASAN_EXTRA
References: <721E7B42-2D55-4866-9C1A-3E8D64F33F9C@gmx.us>
 <20181207223449.38808-1-cai@lca.pw>
 <CAK8P3a20kRDrkS1YFLp6cYeKcUoC9s+O_tnYNbKEMWGukia1Tg@mail.gmail.com>
 <1544548707.18411.3.camel@lca.pw>
 <CAK8P3a3ghizoj5xwkQayuwu2Z1HppSqHLwHGPp97dUG4upv+LA@mail.gmail.com>
 <1544565158.18411.5.camel@lca.pw>
 <CAK8P3a0DiaeHtUKhWGniXQfrx3DOk9goSXp_d2-dcMunY8jRyg@mail.gmail.com>
 <1544565572.18411.7.camel@lca.pw>
 <CAK8P3a2kStKc8bB1cXh=PEaVUMcg01o5AqtGM5NyJ0RT0JLPuA@mail.gmail.com>
 <1544566937.18411.9.camel@lca.pw>
 <CAK8P3a2T-DDfmpN_KcLB8cZKTszE4tohR8ChtktP3-du76hJog@mail.gmail.com>
From: Qian Cai <cai@lca.pw>
Message-ID: <9248f272-4b8f-183d-73eb-28fed1debcd2@lca.pw>
Date: Tue, 11 Dec 2018 22:54:37 -0500
MIME-Version: 1.0
In-Reply-To: <CAK8P3a2T-DDfmpN_KcLB8cZKTszE4tohR8ChtktP3-du76hJog@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>



On 12/11/18 6:06 PM, Arnd Bergmann wrote:
>> I am thinking about something it is probably best just waiting for those major
>> distors to complete upgrading to GCC9 or back-porting those stack reduction
>> patches first. Then, it is good time to tie up loose ends for those default
>> stack sizes in all combinations.
> 
> I was basically trying to make sure we don't forget it when it gets to that.

I added a reminder in my calendar to check the GCC9 adoption in Q2 FY19.

> 
> Another alternative would be to just disable KASAN_EXTRA now
> for gcc versions before 9, which essentially means for everyone,
> but then we get it back once a working version gets released. As
> I understand, this kasan option is actually fairly useless given its
> cost, so very few people would miss it.
> 
> On a related note, I think we have to turn off asan-stack entirely
> on all released clang versions. asan-stack in general is much more
> useful than the use-after-scope check, but we clang produces some
> very large stack frames with it and we probably can't even work
> around it with KASAN_THREAD_SHIFT=2 but would need even
> more than that otherwise.
> 
>          Arnd
> 
