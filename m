Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f175.google.com (mail-vc0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id E54FB6B0035
	for <linux-mm@kvack.org>; Sun, 31 Aug 2014 07:36:19 -0400 (EDT)
Received: by mail-vc0-f175.google.com with SMTP id lf12so4286288vcb.6
        for <linux-mm@kvack.org>; Sun, 31 Aug 2014 04:36:19 -0700 (PDT)
Received: from mail-vc0-x22e.google.com (mail-vc0-x22e.google.com [2607:f8b0:400c:c03::22e])
        by mx.google.com with ESMTPS id d9si2932997vdi.28.2014.08.31.04.36.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 31 Aug 2014 04:36:19 -0700 (PDT)
Received: by mail-vc0-f174.google.com with SMTP id hy4so4288667vcb.5
        for <linux-mm@kvack.org>; Sun, 31 Aug 2014 04:36:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <54012D74.7010302@infradead.org>
References: <5400fba1.732YclygYZprDXeI%akpm@linux-foundation.org>
	<54012D74.7010302@infradead.org>
Date: Sun, 31 Aug 2014 15:36:18 +0400
Message-ID: <CAPAsAGz4458YgHN0b04Z4fTwvo-guh+ESNAXy7j=c-bc7v4gcA@mail.gmail.com>
Subject: Re: [PATCH -mmotm] mm: fix kmemcheck.c build errors
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, Pekka Enberg <penberg@kernel.org>, Vegard Nossum <vegardno@ifi.uio.no>

2014-08-30 5:48 GMT+04:00 Randy Dunlap <rdunlap@infradead.org>:
> From: Randy Dunlap <rdunlap@infradead.org>
>
> Add header file to fix kmemcheck.c build errors:
>
> ../mm/kmemcheck.c:70:7: error: dereferencing pointer to incomplete type
> ../mm/kmemcheck.c:83:15: error: dereferencing pointer to incomplete type
> ../mm/kmemcheck.c:95:8: error: dereferencing pointer to incomplete type
> ../mm/kmemcheck.c:95:21: error: dereferencing pointer to incomplete type
>
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
> ---
>  mm/kmemcheck.c |    1 +
>  1 file changed, 1 insertion(+)
>
> Index: mmotm-2014-0829-1515/mm/kmemcheck.c
> ===================================================================
> --- mmotm-2014-0829-1515.orig/mm/kmemcheck.c
> +++ mmotm-2014-0829-1515/mm/kmemcheck.c
> @@ -2,6 +2,7 @@
>  #include <linux/mm_types.h>
>  #include <linux/mm.h>
>  #include <linux/slab.h>
> +#include <linux/slab_def.h>

This will work only for CONFIG_SLAB=y. struct kmem_cache definition
was moved to internal header [*],
so you need to include it here:
#include "slab.h"

[*] http://ozlabs.org/~akpm/mmotm/broken-out/mm-slab_common-move-kmem_cache-definition-to-internal-header.patch

>  #include <linux/kmemcheck.h>
>
>  void kmemcheck_alloc_shadow(struct page *page, int order, gfp_t flags, int node)
>


-- 
Best regards,
Andrey Ryabinin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
