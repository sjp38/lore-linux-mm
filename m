Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9EB098E00C9
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 16:56:30 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id v74so14270251qkb.21
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 13:56:30 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q6sor17260178qvn.67.2018.12.11.13.56.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 13:56:30 -0800 (PST)
MIME-Version: 1.0
References: <721E7B42-2D55-4866-9C1A-3E8D64F33F9C@gmx.us> <20181207223449.38808-1-cai@lca.pw>
 <CAK8P3a20kRDrkS1YFLp6cYeKcUoC9s+O_tnYNbKEMWGukia1Tg@mail.gmail.com>
 <1544548707.18411.3.camel@lca.pw> <CAK8P3a3ghizoj5xwkQayuwu2Z1HppSqHLwHGPp97dUG4upv+LA@mail.gmail.com>
 <1544565158.18411.5.camel@lca.pw>
In-Reply-To: <1544565158.18411.5.camel@lca.pw>
From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 11 Dec 2018 22:56:12 +0100
Message-ID: <CAK8P3a0DiaeHtUKhWGniXQfrx3DOk9goSXp_d2-dcMunY8jRyg@mail.gmail.com>
Subject: Re: [PATCH] arm64: increase stack size for KASAN_EXTRA
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cai@lca.pw
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Dec 11, 2018 at 10:52 PM Qian Cai <cai@lca.pw> wrote:
> On Tue, 2018-12-11 at 22:43 +0100, Arnd Bergmann wrote:
> > On Tue, Dec 11, 2018 at 6:18 PM Qian Cai <cai@lca.pw> wrote:

> I am not too keen to do the version-check considering some LTS versions could
> just back-port those patches and the render the version-check incorrectly.

I'm not following what the problem is. Do you mean distro versions gcc
with the compiler bugfix, or LTS kernel versions?

For backported kernel fixes, this doesn't seem to be any different
from other kernel changes that might be incorrect, but a straight
backport of that kernel patch should still do the right thing in older
kernels, and set the frame size higher for old compilers but not
new ones.

    Arnd
