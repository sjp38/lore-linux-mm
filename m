Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id A01BD6B0069
	for <linux-mm@kvack.org>; Thu, 27 Nov 2014 03:08:08 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id vb8so3395412obc.21
        for <linux-mm@kvack.org>; Thu, 27 Nov 2014 00:08:08 -0800 (PST)
Received: from mail-ob0-x236.google.com (mail-ob0-x236.google.com. [2607:f8b0:4003:c01::236])
        by mx.google.com with ESMTPS id c82si4522025oia.85.2014.11.27.00.08.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 27 Nov 2014 00:08:07 -0800 (PST)
Received: by mail-ob0-f182.google.com with SMTP id m8so3387046obr.41
        for <linux-mm@kvack.org>; Thu, 27 Nov 2014 00:08:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141127011819.GA21891@bbox>
References: <201411270835.hrrJeFPX%fengguang.wu@intel.com>
	<20141127011819.GA21891@bbox>
Date: Thu, 27 Nov 2014 11:08:07 +0300
Message-ID: <CAMo8BfKOnLnDv6bpq4YqivQsonBjEQKm5+Ld+hOXGuXiURo4gw@mail.gmail.com>
Subject: Re: [mmotm:master 174/397] mm/madvise.c:42:7: error: 'MADV_FREE' undeclared
From: Max Filippov <jcmvbkbc@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Ralf Baechle <ralf@linux-mips.org>, Chris Zankel <chris@zankel.net>

On Thu, Nov 27, 2014 at 4:18 AM, Minchan Kim <minchan@kernel.org> wrote:
> From 5ca29f2f9ed96d1a0c9ac4209696839dcf5f0e49 Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan@kernel.org>
> Date: Thu, 27 Nov 2014 10:02:00 +0900
> Subject: [PATCH] mm: define MADV_FREE for some arches
>
> Most architectures use asm-generic, but alpha, mips, parisc, xtensa
> need their own definitions.
>
> This patch defines MADV_FREE for them so it should fix build break
> for their architectures.
>
> Maybe, I should split and feed piecies to arch maintainers but
> included here for mmotm convenience.
>
> Cc: Michael Kerrisk <mtk.manpages@gmail.com>
> Cc: Richard Henderson <rth@twiddle.net>
> Cc: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
> Cc: "James E.J. Bottomley" <jejb@parisc-linux.org>
> Cc: Helge Deller <deller@gmx.de>
> Cc: Ralf Baechle <ralf@linux-mips.org>
> Cc: Chris Zankel <chris@zankel.net>
> Cc: Max Filippov <jcmvbkbc@gmail.com>
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  arch/alpha/include/uapi/asm/mman.h  | 1 +
>  arch/mips/include/uapi/asm/mman.h   | 1 +
>  arch/parisc/include/uapi/asm/mman.h | 1 +
>  arch/xtensa/include/uapi/asm/mman.h | 1 +
>  4 files changed, 4 insertions(+)

Xtensa part:
Acked-by: Max Filippov <jcmvbkbc@gmail.com>

-- 
Thanks.
-- Max

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
