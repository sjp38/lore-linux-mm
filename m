Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id B5E5B8E0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 10:21:13 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id v11so16452585ply.4
        for <linux-mm@kvack.org>; Thu, 27 Dec 2018 07:21:13 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m8sor60345901pgv.85.2018.12.27.07.21.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Dec 2018 07:21:12 -0800 (PST)
MIME-Version: 1.0
References: <20181226020550.63712-1-cai@lca.pw>
In-Reply-To: <20181226020550.63712-1-cai@lca.pw>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 27 Dec 2018 16:21:00 +0100
Message-ID: <CAAeHK+zj0LcjhcQFd4H9CfRbyzz8u+HuhA4-c-pjnDobkDGRJQ@mail.gmail.com>
Subject: Re: [PATCH -mmotm] arm64: skip kmemleak for KASAN again
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Dmitry Vyukov <dvyukov@google.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 26, 2018 at 3:06 AM Qian Cai <cai@lca.pw> wrote:
>
> Due to 871ac3d540f (kasan: initialize shadow to 0xff for tag-based
> mode), kmemleak is broken again with KASAN. It needs a similar fix
> from e55058c2983 (mm/memblock.c: skip kmemleak for kasan_init()).
>
> Signed-off-by: Qian Cai <cai@lca.pw>

Hi Qian,

Sorry, didn't see your first kmemleak fix. I can merge this fix into
my series if I end up resending it.

In any case:

Acked-by: Andrey Konovalov <andreyknvl@google.com>

Thanks!

> ---
>  arch/arm64/mm/kasan_init.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
> index 48d8f2fa0d14..4b55b15707a3 100644
> --- a/arch/arm64/mm/kasan_init.c
> +++ b/arch/arm64/mm/kasan_init.c
> @@ -47,8 +47,7 @@ static phys_addr_t __init kasan_alloc_raw_page(int node)
>  {
>         void *p = memblock_alloc_try_nid_raw(PAGE_SIZE, PAGE_SIZE,
>                                                 __pa(MAX_DMA_ADDRESS),
> -                                               MEMBLOCK_ALLOC_ACCESSIBLE,
> -                                               node);
> +                                               MEMBLOCK_ALLOC_KASAN, node);
>         return __pa(p);
>  }
>
> --
> 2.17.2 (Apple Git-113)
>
