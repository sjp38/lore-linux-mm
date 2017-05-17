Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 558C56B02EE
	for <linux-mm@kvack.org>; Wed, 17 May 2017 11:35:13 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 123so12282488pge.14
        for <linux-mm@kvack.org>; Wed, 17 May 2017 08:35:13 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id d74si2363047pfk.262.2017.05.17.08.35.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 08:35:12 -0700 (PDT)
Subject: Re: [PATCH] Correct spelling and grammar for notification text
References: <20170517133842.5733-1-mdeguzis@gmail.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <d55eeeee-76ed-b171-d1df-643b36bb17b9@infradead.org>
Date: Wed, 17 May 2017 08:35:11 -0700
MIME-Version: 1.0
In-Reply-To: <20170517133842.5733-1-mdeguzis@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael DeGuzis <mdeguzis@gmail.com>, linux-mm@kvack.org
Cc: trivial@kernel.org

On 05/17/17 06:38, Michael DeGuzis wrote:
> From: professorkaos64 <mdeguzis@gmail.com>
> 
> This patch fixes up some grammar and spelling in the information
> block for huge_memory.c.

Missing Signed-off-by: <real name and email address>

> ---
>  mm/huge_memory.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index a84909cf20d3..af137fc0ca09 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -38,12 +38,12 @@
>  #include "internal.h"
>  
>  /*
> - * By default transparent hugepage support is disabled in order that avoid
> - * to risk increase the memory footprint of applications without a guaranteed
> - * benefit. When transparent hugepage support is enabled, is for all mappings,
> - * and khugepaged scans all mappings.
> + * By default, transparent hugepage support is disabled in order to avoid
> + * risking an increased memory footprint for applications that are not 
> + * guaranteed to benefit from it. When transparent hugepage support is 
> + * enabled, it is for all mappings, and khugepaged scans all mappings.
>   * Defrag is invoked by khugepaged hugepage allocations and by page faults
> - * for all hugepage allocations.
> + * for all hugepage allocations. 

Several of the new (+) patch lines end with a space character. Not good.

>   */
>  unsigned long transparent_hugepage_flags __read_mostly =
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS
> 


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
