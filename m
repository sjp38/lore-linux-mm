Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 65C636B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 01:53:05 -0400 (EDT)
Received: by mail-ie0-f175.google.com with SMTP id c12so126026ieb.20
        for <linux-mm@kvack.org>; Mon, 18 Mar 2013 22:53:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1363670161-9214-3-git-send-email-iamjoonsoo.kim@lge.com>
References: <1363670161-9214-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1363670161-9214-3-git-send-email-iamjoonsoo.kim@lge.com>
Date: Mon, 18 Mar 2013 22:53:04 -0700
Message-ID: <CAE9FiQU-yCanj_jRSL2Pwdfg7L+832XYnsgR8m2gB=PJdTM_xw@mail.gmail.com>
Subject: Re: [PATCH 3/3] mm, nobootmem: do memset() after memblock_reserve()
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Jiang Liu <liuj97@gmail.com>

On Mon, Mar 18, 2013 at 10:16 PM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> Currently, we do memset() before reserving the area.
> This may not cause any problem, but it is somewhat weird.
> So change execution order.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> diff --git a/mm/nobootmem.c b/mm/nobootmem.c
> index 589c673..f11ec1c 100644
> --- a/mm/nobootmem.c
> +++ b/mm/nobootmem.c
> @@ -46,8 +46,8 @@ static void * __init __alloc_memory_core_early(int nid, u64 size, u64 align,
>                 return NULL;
>
>         ptr = phys_to_virt(addr);
> -       memset(ptr, 0, size);
>         memblock_reserve(addr, size);
> +       memset(ptr, 0, size);

move down ptr = ... too ?

>         /*
>          * The min_count is set to 0 so that bootmem allocated blocks
>          * are never reported as leaks.
> --
> 1.7.9.5
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
