Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 667896B025E
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 05:40:42 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id l81so40726078qke.3
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 02:40:42 -0700 (PDT)
Received: from mail-yw0-x243.google.com (mail-yw0-x243.google.com. [2607:f8b0:4002:c05::243])
        by mx.google.com with ESMTPS id m65si2194400ywf.152.2016.06.15.02.40.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 02:40:41 -0700 (PDT)
Received: by mail-yw0-x243.google.com with SMTP id w195so1850882ywd.3
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 02:40:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1465983258-3726-1-git-send-email-opensource.ganesh@gmail.com>
References: <1465983258-3726-1-git-send-email-opensource.ganesh@gmail.com>
From: Balbir Singh <bsingharora@gmail.com>
Date: Wed, 15 Jun 2016 19:40:40 +1000
Message-ID: <CAKTCnzk1GZ+=ijvOm=Tw1GNGLdefovvS5wsR9XqpLLmrSSx9=g@mail.gmail.com>
Subject: Re: [PATCH v2] mm/page_alloc: remove unnecessary order check in __alloc_pages_direct_compact
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, mhocko@suse.com, mina86@mina86.com, Minchan Kim <minchan@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>

On Wed, Jun 15, 2016 at 7:34 PM, Ganesh Mahendran
<opensource.ganesh@gmail.com> wrote:
> In the callee try_to_compact_pages(), the (order == 0) is checked,
> so remove check in __alloc_pages_direct_compact.
>
> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
> ---
> v2:
>   remove the check in __alloc_pages_direct_compact - Anshuman Khandual
> ---
>  mm/page_alloc.c | 3 ---
>  1 file changed, 3 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index b9ea618..2f5a82a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3173,9 +3173,6 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>         struct page *page;
>         int contended_compaction;
>
> -       if (!order)
> -               return NULL;
> -
>         current->flags |= PF_MEMALLOC;
>         *compact_result = try_to_compact_pages(gfp_mask, order, alloc_flags, ac,
>                                                 mode, &contended_compaction);

What is the benefit of this. Is an if check more expensive than
calling the function and returning from it? I don't feel strongly
about such changes, but its good to audit the overall code for reading
and performance.

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
