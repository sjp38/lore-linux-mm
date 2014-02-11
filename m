Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 09B966B0037
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 20:37:31 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa1so10013782pad.14
        for <linux-mm@kvack.org>; Wed, 12 Feb 2014 17:37:31 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id xf4si181046pab.191.2014.02.12.17.37.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 12 Feb 2014 17:37:31 -0800 (PST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so10024568pab.4
        for <linux-mm@kvack.org>; Wed, 12 Feb 2014 17:37:30 -0800 (PST)
Message-ID: <52F999F8.8070808@samsung.com>
Date: Tue, 11 Feb 2014 12:33:12 +0900
From: Kukjin Kim <kgene.kim@samsung.com>
MIME-Version: 1.0
Subject: Re: [PATCHv3 2/2] arm: Get rid of meminfo
References: <1392153265-14439-1-git-send-email-lauraa@codeaurora.org> <1392153265-14439-3-git-send-email-lauraa@codeaurora.org>
In-Reply-To: <1392153265-14439-3-git-send-email-lauraa@codeaurora.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Russell King <linux@arm.linux.org.uk>, David Brown <davidb@codeaurora.org>, Daniel Walker <dwalker@fifo99.com>, Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, Eric Miao <eric.y.miao@gmail.com>, Haojian Zhuang <haojian.zhuang@gmail.com>, Ben Dooks <ben-linux@fluff.org>, Kukjin Kim <kgene.kim@samsung.com>, linux-arm-kernel@lists.infradead.org, Nicolas Pitre <nicolas.pitre@linaro.org>, Courtney Cavin <courtney.cavin@sonymobile.com>, Grygorii Strashko <grygorii.strashko@ti.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-arm-msm@vger.kernel.org, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, Leif Lindholm <leif.lindholm@linaro.org>, Grant Likely <grant.likely@secretlab.ca>, linux-mm@kvack.org, Catalin Marinas <catalin.marinas@arm.com>, Santosh Shilimkar <santosh.shilimkar@ti.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>

On 02/12/14 06:14, Laura Abbott wrote:
> memblock is now fully integrated into the kernel and is the prefered
> method for tracking memory. Rather than reinvent the wheel with
> meminfo, migrate to using memblock directly instead of meminfo as
> an intermediate.
>
> Acked-by: Jason Cooper<jason@lakedaemon.net>
> Acked-by: Catalin Marinas<catalin.marinas@arm.com>
> Acked-by: Santosh Shilimkar<santosh.shilimkar@ti.com>
> Tested-by: Leif Lindholm<leif.lindholm@linaro.org>
> Signed-off-by: Laura Abbott<lauraa@codeaurora.org>
> ---
>   arch/arm/include/asm/mach/arch.h         |    4 +-
>   arch/arm/include/asm/memblock.h          |    3 +-
>   arch/arm/include/asm/setup.h             |   23 ------
>   arch/arm/kernel/atags_parse.c            |    5 +-
>   arch/arm/kernel/devtree.c                |    5 --
>   arch/arm/kernel/setup.c                  |   30 ++------
>   arch/arm/mach-clps711x/board-clep7312.c  |    7 +-
>   arch/arm/mach-clps711x/board-edb7211.c   |   10 +--
>   arch/arm/mach-clps711x/board-p720t.c     |    2 +-
>   arch/arm/mach-footbridge/cats-hw.c       |    2 +-
>   arch/arm/mach-footbridge/netwinder-hw.c  |    2 +-
>   arch/arm/mach-msm/board-halibut.c        |    6 --
>   arch/arm/mach-msm/board-mahimahi.c       |   13 +---
>   arch/arm/mach-msm/board-msm7x30.c        |    3 +-
>   arch/arm/mach-msm/board-sapphire.c       |   13 ++--
>   arch/arm/mach-msm/board-trout.c          |    8 +--
>   arch/arm/mach-orion5x/common.c           |    3 +-
>   arch/arm/mach-orion5x/common.h           |    3 +-
>   arch/arm/mach-pxa/cm-x300.c              |    3 +-
>   arch/arm/mach-pxa/corgi.c                |   10 +--
>   arch/arm/mach-pxa/eseries.c              |    9 +--
>   arch/arm/mach-pxa/poodle.c               |    8 +--
>   arch/arm/mach-pxa/spitz.c                |    8 +--
>   arch/arm/mach-pxa/tosa.c                 |    8 +--
>   arch/arm/mach-realview/core.c            |   11 +--
>   arch/arm/mach-realview/core.h            |    3 +-
>   arch/arm/mach-realview/realview_pb1176.c |    8 +--
>   arch/arm/mach-realview/realview_pbx.c    |   17 ++---
>   arch/arm/mach-s3c24xx/mach-smdk2413.c    |    8 +--
>   arch/arm/mach-s3c24xx/mach-vstms.c       |    8 +--

For s3c24xx,
Acked-by: Kukjin Kim <kgene.kim@samsung.com>

>   arch/arm/mach-sa1100/assabet.c           |    2 +-
>   arch/arm/mm/init.c                       |   67 +++++++-----------
>   arch/arm/mm/mmu.c                        |  115 +++++++++---------------------
>   33 files changed, 136 insertions(+), 291 deletions(-)

Thanks,
Kukjin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
