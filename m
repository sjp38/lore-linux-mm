Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3B36D6B0069
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 03:53:30 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id gf13so2641332lab.29
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 00:53:29 -0700 (PDT)
Received: from mail.efficios.com (mail.efficios.com. [78.47.125.74])
        by mx.google.com with ESMTP id a8si33545664lbg.75.2014.10.16.00.53.27
        for <linux-mm@kvack.org>;
        Thu, 16 Oct 2014 00:53:28 -0700 (PDT)
Date: Thu, 16 Oct 2014 09:52:51 +0200
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: [PATCH v11 01/21] axonram: Fix bug in direct_access
Message-ID: <20141016075251.GA18259@thinkos.etherlink>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
 <1411677218-29146-2-git-send-email-matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1411677218-29146-2-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On 25-Sep-2014 04:33:18 PM, Matthew Wilcox wrote:
> The 'pfn' returned by axonram was completely bogus, and has been since
> 2008.
> 
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> Reviewed-by: Jan Kara <jack@suse.cz>

This should also be submitted for stable kernels. (CC
stable@vger.kernel.org)

Reviewed-by: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>

> ---
>  arch/powerpc/sysdev/axonram.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/arch/powerpc/sysdev/axonram.c b/arch/powerpc/sysdev/axonram.c
> index 47b6b9f..830edc8 100644
> --- a/arch/powerpc/sysdev/axonram.c
> +++ b/arch/powerpc/sysdev/axonram.c
> @@ -156,7 +156,7 @@ axon_ram_direct_access(struct block_device *device, sector_t sector,
>  	}
>  
>  	*kaddr = (void *)(bank->ph_addr + offset);
> -	*pfn = virt_to_phys(kaddr) >> PAGE_SHIFT;
> +	*pfn = virt_to_phys(*kaddr) >> PAGE_SHIFT;
>  
>  	return 0;
>  }
> -- 
> 2.1.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> 

-- 
Mathieu Desnoyers
EfficiOS Inc.
http://www.efficios.com
Key fingerprint: 2A0B 4ED9 15F2 D3FA 45F5  B162 1728 0A97 8118 6ACF

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
