Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 170636B0035
	for <linux-mm@kvack.org>; Thu, 21 Aug 2014 10:14:28 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kx10so14473597pab.6
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 07:14:27 -0700 (PDT)
Received: from qmta15.emeryville.ca.mail.comcast.net (qmta15.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:228])
        by mx.google.com with ESMTP id sk9si36679372pac.4.2014.08.21.07.14.26
        for <linux-mm@kvack.org>;
        Thu, 21 Aug 2014 07:14:27 -0700 (PDT)
Date: Thu, 21 Aug 2014 09:14:24 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/5] mm/slab_common: move kmem_cache definition to internal
 header
In-Reply-To: <1408608562-20339-1-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.11.1408210913370.32524@gentwo.org>
References: <1408608562-20339-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 21 Aug 2014, Joonsoo Kim wrote:

> We don't need to keep kmem_cache definition in include/linux/slab.h
> if we don't need to inline kmem_cache_size(). According to my
> code inspection, this function is only called at lc_create() in
> lib/lru_cache.c which may be called at initialization phase of something,
> so we don't need to inline it. Therfore, move it to slab_common.c and
> move kmem_cache definition to internal header.
>
> After this change, we can change kmem_cache definition easily without
> full kernel build. For instance, we can turn on/off CONFIG_SLUB_STATS
> without full kernel build.

Wow. I did not realize that we were already at that point.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
