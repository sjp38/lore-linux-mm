Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3339B8E00C9
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 17:22:20 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id 80so14498213qkd.0
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 14:22:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p6sor18808756qtc.0.2018.12.11.14.22.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 14:22:19 -0800 (PST)
Message-ID: <1544566937.18411.9.camel@lca.pw>
Subject: Re: [PATCH] arm64: increase stack size for KASAN_EXTRA
From: Qian Cai <cai@lca.pw>
Date: Tue, 11 Dec 2018 17:22:17 -0500
In-Reply-To: <CAK8P3a2kStKc8bB1cXh=PEaVUMcg01o5AqtGM5NyJ0RT0JLPuA@mail.gmail.com>
References: <721E7B42-2D55-4866-9C1A-3E8D64F33F9C@gmx.us>
	 <20181207223449.38808-1-cai@lca.pw>
	 <CAK8P3a20kRDrkS1YFLp6cYeKcUoC9s+O_tnYNbKEMWGukia1Tg@mail.gmail.com>
	 <1544548707.18411.3.camel@lca.pw>
	 <CAK8P3a3ghizoj5xwkQayuwu2Z1HppSqHLwHGPp97dUG4upv+LA@mail.gmail.com>
	 <1544565158.18411.5.camel@lca.pw>
	 <CAK8P3a0DiaeHtUKhWGniXQfrx3DOk9goSXp_d2-dcMunY8jRyg@mail.gmail.com>
	 <1544565572.18411.7.camel@lca.pw>
	 <CAK8P3a2kStKc8bB1cXh=PEaVUMcg01o5AqtGM5NyJ0RT0JLPuA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, 2018-12-11 at 23:12 +0100, Arnd Bergmann wrote:
> On Tue, Dec 11, 2018 at 10:59 PM Qian Cai <cai@lca.pw> wrote:
> > 
> > On Tue, 2018-12-11 at 22:56 +0100, Arnd Bergmann wrote:
> > > On Tue, Dec 11, 2018 at 10:52 PM Qian Cai <cai@lca.pw> wrote:
> > > > On Tue, 2018-12-11 at 22:43 +0100, Arnd Bergmann wrote:
> > > > > On Tue, Dec 11, 2018 at 6:18 PM Qian Cai <cai@lca.pw> wrote:
> > > > 
> > > > I am not too keen to do the version-check considering some LTS versions
> > > > could
> > > > just back-port those patches and the render the version-check
> > > > incorrectly.
> > > 
> > > I'm not following what the problem is. Do you mean distro versions gcc
> > > with the compiler bugfix, or LTS kernel versions?
> > > 
> > 
> > I mean distro versions of GCC where the version is still 8 but keep back-
> > porting
> > tons of patches.
> 
> Ok, but in that case, checking the version would still be no worse
> than your current patch, the only difference is that for users of a
> fixed older gcc, the kernel would use more stack than it needs.
> 

I am thinking about something it is probably best just waiting for those major
distors to complete upgrading to GCC9 or back-porting those stack reduction
patches first. Then, it is good time to tie up loose ends for those default
stack sizes in all combinations.
