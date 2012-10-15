Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 8E0DA6B005D
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 16:44:26 -0400 (EDT)
Date: Mon, 15 Oct 2012 20:44:25 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/2] SLUB: increase the range of slab sizes available to
 kmalloc, allowing a somewhat more effient use of memory.
In-Reply-To: <1350145885-6099-3-git-send-email-richard@rsk.demon.co.uk>
Message-ID: <0000013a662b9db5-1ea40fb2-3337-4cbc-8eca-5a610564dd75-000000@email.amazonses.com>
References: <1350145885-6099-1-git-send-email-richard@rsk.demon.co.uk> <1350145885-6099-2-git-send-email-richard@rsk.demon.co.uk> <1350145885-6099-3-git-send-email-richard@rsk.demon.co.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 13 Oct 2012, Richard Kennedy wrote:

> -extern struct kmem_cache *kmalloc_caches[SLUB_PAGE_SHIFT];
>
> -/*
> - * Sorry that the following has to be that ugly but some versions of GCC
> - * have trouble with constant propagation and loops.
> +static const short __slab_sizes[] = {0, 8, 12, 16, 24, 32, 48, 64, 96,
> +				     128, 192, 256, 384, 512, 768, 1024,
> +				     1536, 2048, 3072, 4096, 6144, 8192};
> +

Urg. No thanks. What is the exact benefit of this patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
