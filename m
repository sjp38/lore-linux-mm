Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id E7D1A6B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 06:50:36 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so68210914wid.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 03:50:36 -0700 (PDT)
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com. [209.85.212.178])
        by mx.google.com with ESMTPS id t4si20758861wiz.31.2015.08.24.03.50.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 03:50:35 -0700 (PDT)
Received: by widdq5 with SMTP id dq5so46034696wid.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 03:50:35 -0700 (PDT)
Date: Mon, 24 Aug 2015 12:50:33 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] mm/memblock: fix memblock comment
Message-ID: <20150824105032.GK17078@dhcp22.suse.cz>
References: <1440229212-8737-1-git-send-email-bywxiaobai@163.com>
 <1440229212-8737-3-git-send-email-bywxiaobai@163.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1440229212-8737-3-git-send-email-bywxiaobai@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yaowei Bai <bywxiaobai@163.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, js1304@gmail.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat 22-08-15 15:40:12, Yaowei Bai wrote:
> 's/amd/and/'

Is this really worth it? It doesn't help grepability and just churns the
history.

> 
> Signed-off-by: Yaowei Bai <bywxiaobai@163.com>
> ---
>  include/linux/memblock.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index cc4b019..273aad7 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -304,7 +304,7 @@ static inline void __init memblock_set_bottom_up(bool enable) {}
>  static inline bool memblock_bottom_up(void) { return false; }
>  #endif
>  
> -/* Flags for memblock_alloc_base() amd __memblock_alloc_base() */
> +/* Flags for memblock_alloc_base() and __memblock_alloc_base() */
>  #define MEMBLOCK_ALLOC_ANYWHERE	(~(phys_addr_t)0)
>  #define MEMBLOCK_ALLOC_ACCESSIBLE	0
>  
> -- 
> 1.9.1
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
