Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 194E28E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 11:47:22 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id x15so2639554edd.2
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 08:47:22 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z24-v6si2146011ejl.68.2019.01.16.08.47.19
        for <linux-mm@kvack.org>;
        Wed, 16 Jan 2019 08:47:20 -0800 (PST)
Date: Wed, 16 Jan 2019 16:47:13 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH] kasan: Remove use after scope bugs detection.
Message-ID: <20190116164712.GB1910@brain-police>
References: <20190111185842.13978-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190111185842.13978-1-aryabinin@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Qian Cai <cai@lca.pw>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>

On Fri, Jan 11, 2019 at 09:58:42PM +0300, Andrey Ryabinin wrote:
> Use after scope bugs detector seems to be almost entirely useless
> for the linux kernel. It exists over two years, but I've seen only
> one valid bug so far [1]. And the bug was fixed before it has been
> reported. There were some other use-after-scope reports, but they
> were false-positives due to different reasons like incompatibility
> with structleak plugin.
> 
> This feature significantly increases stack usage, especially with
> GCC < 9 version, and causes a 32K stack overflow. It probably
> adds performance penalty too.
> 
> Given all that, let's remove use-after-scope detector entirely.
> 
> While preparing this patch I've noticed that we mistakenly enable
> use-after-scope detection for clang compiler regardless of
> CONFIG_KASAN_EXTRA setting. This is also fixed now.
> 
> [1] http://lkml.kernel.org/r/<20171129052106.rhgbjhhis53hkgfn@wfg-t540p.sh.intel.com>
> 
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Qian Cai <cai@lca.pw>
> Cc: Alexander Potapenko <glider@google.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> ---
>  arch/arm64/include/asm/memory.h |  4 ----
>  lib/Kconfig.debug               |  1 -
>  lib/Kconfig.kasan               | 10 ----------
>  lib/test_kasan.c                | 24 ------------------------
>  mm/kasan/generic.c              | 19 -------------------
>  mm/kasan/generic_report.c       |  3 ---
>  mm/kasan/kasan.h                |  3 ---
>  scripts/Makefile.kasan          |  5 -----
>  scripts/gcc-plugins/Kconfig     |  4 ----
>  9 files changed, 73 deletions(-)

For the arm64 part:

Acked-by: Will Deacon <will.deacon@arm.com>

but I defer to you and Dmitry as to whether or not you go ahead with this.

Will
