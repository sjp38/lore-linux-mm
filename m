Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 24E866B0887
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 03:39:48 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id s24-v6so16418721plp.12
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 00:39:48 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 32-v6si32788874plc.370.2018.11.16.00.39.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 00:39:46 -0800 (PST)
Date: Fri, 16 Nov 2018 09:39:42 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] slab: fix 'dubious: x & !y' warning from Sparse
Message-ID: <20181116083942.GA14767@dhcp22.suse.cz>
References: <1542346829-31063-1-git-send-email-yamada.masahiro@socionext.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1542346829-31063-1-git-send-email-yamada.masahiro@socionext.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 16-11-18 14:40:29, Masahiro Yamada wrote:
> Sparse reports:
> ./include/linux/slab.h:332:43: warning: dubious: x & !y

JFYI this has been discussed here http://lkml.kernel.org/r/20181105204000.129023-1-bvanassche@acm.org

> Signed-off-by: Masahiro Yamada <yamada.masahiro@socionext.com>
> ---
> 
>  include/linux/slab.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 918f374..d395c73 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -329,7 +329,7 @@ static __always_inline enum kmalloc_cache_type kmalloc_type(gfp_t flags)
>  	 * If an allocation is both __GFP_DMA and __GFP_RECLAIMABLE, return
>  	 * KMALLOC_DMA and effectively ignore __GFP_RECLAIMABLE
>  	 */
> -	return type_dma + (is_reclaimable & !is_dma) * KMALLOC_RECLAIM;
> +	return type_dma + (is_reclaimable && !is_dma) * KMALLOC_RECLAIM;
>  }
>  
>  /*
> -- 
> 2.7.4

-- 
Michal Hocko
SUSE Labs
