Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 264326B0032
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 19:52:17 -0500 (EST)
Received: by mail-ie0-f169.google.com with SMTP id rl12so15507693iec.0
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 16:52:16 -0800 (PST)
Received: from resqmta-po-09v.sys.comcast.net (resqmta-po-09v.sys.comcast.net. [2001:558:fe16:19:96:114:154:168])
        by mx.google.com with ESMTPS id q3si4434730ign.27.2015.01.20.16.52.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 20 Jan 2015 16:52:15 -0800 (PST)
Date: Tue, 20 Jan 2015 18:52:13 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] mm/slub: fix typo
In-Reply-To: <20150120140142.cd2e32d83d66459562bd1717@freescale.com>
Message-ID: <alpine.DEB.2.11.1501201851300.10932@gentwo.org>
References: <20150120140142.cd2e32d83d66459562bd1717@freescale.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kim Phillips <kim.phillips@freescale.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

Acked-by: Christoph Lameter <cl@linux.com>

On Tue, 20 Jan 2015, Kim Phillips wrote:

>
> Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
> ---
>  mm/slub.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/slub.c b/mm/slub.c
> index fe376fe..a64cc1b 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2512,7 +2512,7 @@ EXPORT_SYMBOL(kmem_cache_alloc_node_trace);
>  #endif
>
>  /*
> - * Slow patch handling. This may still be called frequently since objects
> + * Slow path handling. This may still be called frequently since objects
>   * have a longer lifetime than the cpu slabs in most processing loads.
>   *
>   * So we still attempt to reduce cache line usage. Just take the slab
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
