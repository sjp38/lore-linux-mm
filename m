Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
	by kanga.kvack.org (Postfix) with ESMTP id B017A6B0031
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 00:09:07 -0500 (EST)
Received: by mail-ee0-f46.google.com with SMTP id c13so3967671eek.5
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 21:09:07 -0800 (PST)
Received: from mail-wi0-x229.google.com (mail-wi0-x229.google.com [2a00:1450:400c:c05::229])
        by mx.google.com with ESMTPS id h9si36406853eev.168.2014.02.11.21.09.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 21:09:06 -0800 (PST)
Received: by mail-wi0-f169.google.com with SMTP id e4so972715wiv.2
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 21:09:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1392153265-14439-3-git-send-email-lauraa@codeaurora.org>
References: <1392153265-14439-1-git-send-email-lauraa@codeaurora.org>
	<1392153265-14439-3-git-send-email-lauraa@codeaurora.org>
Date: Wed, 12 Feb 2014 10:39:05 +0530
Message-ID: <CAL5jtJkrW4tY77C4Hk0XiAAKiQb5uU7oP=8JCNRS156csmmXkg@mail.gmail.com>
Subject: Re: [PATCHv3 2/2] arm: Get rid of meminfo
From: Kukjin Kim <kgene.kim@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Russell King <linux@arm.linux.org.uk>, David Brown <davidb@codeaurora.org>, Daniel Walker <dwalker@fifo99.com>, Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, Eric Miao <eric.y.miao@gmail.com>, Haojian Zhuang <haojian.zhuang@gmail.com>, Ben Dooks <ben-linux@fluff.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Courtney Cavin <courtney.cavin@sonymobile.com>, Grygorii Strashko <grygorii.strashko@ti.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-arm-msm@vger.kernel.org, Will Deacon <will.deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Leif Lindholm <leif.lindholm@linaro.org>, Grant Likely <grant.likely@secretlab.ca>, linux-mm@kvack.org, Catalin Marinas <catalin.marinas@arm.com>, Santosh Shilimkar <santosh.shilimkar@ti.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>

2014-02-12 2:44 GMT+05:30 Laura Abbott <lauraa@codeaurora.org>:
> memblock is now fully integrated into the kernel and is the prefered
> method for tracking memory. Rather than reinvent the wheel with
> meminfo, migrate to using memblock directly instead of meminfo as
> an intermediate.
>
> Acked-by: Jason Cooper <jason@lakedaemon.net>
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> Acked-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
> Tested-by: Leif Lindholm <leif.lindholm@linaro.org>
> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
> ---
>  arch/arm/include/asm/mach/arch.h         |    4 +-
>  arch/arm/include/asm/memblock.h          |    3 +-
>  arch/arm/include/asm/setup.h             |   23 ------
>  arch/arm/kernel/atags_parse.c            |    5 +-
>  arch/arm/kernel/devtree.c                |    5 --
>  arch/arm/kernel/setup.c                  |   30 ++------
>  arch/arm/mach-clps711x/board-clep7312.c  |    7 +-
>  arch/arm/mach-clps711x/board-edb7211.c   |   10 +--
>  arch/arm/mach-clps711x/board-p720t.c     |    2 +-
>  arch/arm/mach-footbridge/cats-hw.c       |    2 +-
>  arch/arm/mach-footbridge/netwinder-hw.c  |    2 +-
>  arch/arm/mach-msm/board-halibut.c        |    6 --
>  arch/arm/mach-msm/board-mahimahi.c       |   13 +---
>  arch/arm/mach-msm/board-msm7x30.c        |    3 +-
>  arch/arm/mach-msm/board-sapphire.c       |   13 ++--
>  arch/arm/mach-msm/board-trout.c          |    8 +--
>  arch/arm/mach-orion5x/common.c           |    3 +-
>  arch/arm/mach-orion5x/common.h           |    3 +-
>  arch/arm/mach-pxa/cm-x300.c              |    3 +-
>  arch/arm/mach-pxa/corgi.c                |   10 +--
>  arch/arm/mach-pxa/eseries.c              |    9 +--
>  arch/arm/mach-pxa/poodle.c               |    8 +--
>  arch/arm/mach-pxa/spitz.c                |    8 +--
>  arch/arm/mach-pxa/tosa.c                 |    8 +--
>  arch/arm/mach-realview/core.c            |   11 +--
>  arch/arm/mach-realview/core.h            |    3 +-
>  arch/arm/mach-realview/realview_pb1176.c |    8 +--
>  arch/arm/mach-realview/realview_pbx.c    |   17 ++---
>  arch/arm/mach-s3c24xx/mach-smdk2413.c    |    8 +--
>  arch/arm/mach-s3c24xx/mach-vstms.c       |    8 +--

For s3c24xx,
Acked-by: Kukjin Kim <kgene.kim@samsung.com>

>  arch/arm/mach-sa1100/assabet.c           |    2 +-
>  arch/arm/mm/init.c                       |   67 +++++++-----------
>  arch/arm/mm/mmu.c                        |  115 +++++++++---------------------
>  33 files changed, 136 insertions(+), 291 deletions(-)

Thanks,
Kukjin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
