Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 967A56B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 18:15:50 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so11290676pab.22
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 15:15:50 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id fi4si28256177pbb.193.2014.07.01.15.15.48
        for <linux-mm@kvack.org>;
        Tue, 01 Jul 2014 15:15:49 -0700 (PDT)
Date: Tue, 1 Jul 2014 15:15:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 5/9] slab: introduce alien_cache
Message-Id: <20140701151547.fa67354878399575c8eb4647@linux-foundation.org>
In-Reply-To: <1404203258-8923-6-git-send-email-iamjoonsoo.kim@lge.com>
References: <1404203258-8923-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1404203258-8923-6-git-send-email-iamjoonsoo.kim@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vladimir Davydov <vdavydov@parallels.com>

On Tue,  1 Jul 2014 17:27:34 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> -static struct array_cache **alloc_alien_cache(int node, int limit, gfp_t gfp)
> +static struct alien_cache *__alloc_alien_cache(int node, int entries,
> +						int batch, gfp_t gfp)
> +{
> +	int memsize = sizeof(void *) * entries + sizeof(struct alien_cache);

nit: all five memsizes in slab.c have type `int'.  size_t would be more
appropriate.

> +	struct alien_cache *alc = NULL;
> +
> +	alc = kmalloc_node(memsize, gfp, node);
> +	init_arraycache(&alc->ac, entries, batch);
> +	return alc;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
