Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id B99B06B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 10:59:25 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so74914203wic.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 07:59:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fs1si3335927wib.90.2015.08.24.07.59.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 07:59:24 -0700 (PDT)
Subject: Re: [PATCHv3 1/5] mm: drop page->slab_page
References: <1439976106-137226-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1439976106-137226-2-git-send-email-kirill.shutemov@linux.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55DB3149.7040605@suse.cz>
Date: Mon, 24 Aug 2015 16:59:21 +0200
MIME-Version: 1.0
In-Reply-To: <1439976106-137226-2-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andi Kleen <ak@linux.intel.com>

On 08/19/2015 11:21 AM, Kirill A. Shutemov wrote:
> Since 8456a648cf44 ("slab: use struct page for slab management") nobody
> uses slab_page field in struct page.
>
> Let's drop it.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Acked-by: Christoph Lameter <cl@linux.com>
> Acked-by: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Andi Kleen <ak@linux.intel.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   include/linux/mm_types.h | 1 -
>   1 file changed, 1 deletion(-)
>
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 0038ac7466fd..58620ac7f15c 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -140,7 +140,6 @@ struct page {
>   #endif
>   		};
>
> -		struct slab *slab_page; /* slab fields */
>   		struct rcu_head rcu_head;	/* Used by SLAB
>   						 * when destroying via RCU
>   						 */
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
