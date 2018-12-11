Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4F1C38E00C9
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 16:59:35 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id j5so15920101qtk.11
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 13:59:35 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q14sor18692061qta.2.2018.12.11.13.59.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 13:59:34 -0800 (PST)
Message-ID: <1544565572.18411.7.camel@lca.pw>
Subject: Re: [PATCH] arm64: increase stack size for KASAN_EXTRA
From: Qian Cai <cai@lca.pw>
Date: Tue, 11 Dec 2018 16:59:32 -0500
In-Reply-To: <CAK8P3a0DiaeHtUKhWGniXQfrx3DOk9goSXp_d2-dcMunY8jRyg@mail.gmail.com>
References: <721E7B42-2D55-4866-9C1A-3E8D64F33F9C@gmx.us>
	 <20181207223449.38808-1-cai@lca.pw>
	 <CAK8P3a20kRDrkS1YFLp6cYeKcUoC9s+O_tnYNbKEMWGukia1Tg@mail.gmail.com>
	 <1544548707.18411.3.camel@lca.pw>
	 <CAK8P3a3ghizoj5xwkQayuwu2Z1HppSqHLwHGPp97dUG4upv+LA@mail.gmail.com>
	 <1544565158.18411.5.camel@lca.pw>
	 <CAK8P3a0DiaeHtUKhWGniXQfrx3DOk9goSXp_d2-dcMunY8jRyg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, 2018-12-11 at 22:56 +0100, Arnd Bergmann wrote:
> On Tue, Dec 11, 2018 at 10:52 PM Qian Cai <cai@lca.pw> wrote:
> > On Tue, 2018-12-11 at 22:43 +0100, Arnd Bergmann wrote:
> > > On Tue, Dec 11, 2018 at 6:18 PM Qian Cai <cai@lca.pw> wrote:
> > I am not too keen to do the version-check considering some LTS versions
> > could
> > just back-port those patches and the render the version-check incorrectly.
> 
> I'm not following what the problem is. Do you mean distro versions gcc
> with the compiler bugfix, or LTS kernel versions?
> 

I mean distro versions of GCC where the version is still 8 but keep back-porting 
tons of patches.
