Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 5DDDA2802C9
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 20:19:42 -0400 (EDT)
Received: by igbij6 with SMTP id ij6so2016869igb.1
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 17:19:42 -0700 (PDT)
Received: from mail-ig0-x232.google.com (mail-ig0-x232.google.com. [2607:f8b0:4001:c05::232])
        by mx.google.com with ESMTPS id e80si4986864ioi.0.2015.07.15.17.19.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 17:19:41 -0700 (PDT)
Received: by igvi1 with SMTP id i1so2328504igv.1
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 17:19:41 -0700 (PDT)
Date: Wed, 15 Jul 2015 17:19:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/memblock: WARN_ON when flags differs from overlap
 region
In-Reply-To: <1436588376-25808-1-git-send-email-weiyang@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1507151719230.9230@chino.kir.corp.google.com>
References: <1436342488-19851-1-git-send-email-weiyang@linux.vnet.ibm.com> <1436588376-25808-1-git-send-email-weiyang@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, tj@kernel.org, linux-mm@kvack.org

On Sat, 11 Jul 2015, Wei Yang wrote:

> Each memblock_region has flags to indicates the Node ID of this range. For
> the overlap case, memblock_add_range() inserts the lower part and leave the
> upper part as indicated in the overlapped region.
> 

Memblock region flags do not specify node ids, so this is somewhat 
misleading.

> If the flags of the new range differs from the overlapped region, the
> information recorded is not correct.
> 
> This patch adds a WARN_ON when the flags of the new range differs from the
> overlapped region.
> 
> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
> ---
>  mm/memblock.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 95ce68c..bde61e8 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -569,6 +569,7 @@ repeat:
>  #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
>  			WARN_ON(nid != memblock_get_region_node(rgn));
>  #endif
> +			WARN_ON(flags != rgn->flags);
>  			nr_new++;
>  			if (insert)
>  				memblock_insert_region(type, i++, base,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
