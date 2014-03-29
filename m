Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id 4B1F06B0036
	for <linux-mm@kvack.org>; Mon, 31 Mar 2014 06:28:15 -0400 (EDT)
Received: by mail-we0-f170.google.com with SMTP id w61so4610177wes.29
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 03:28:14 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c1si3005859wje.227.2014.03.31.03.28.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 31 Mar 2014 03:28:13 -0700 (PDT)
Date: Sat, 29 Mar 2014 17:22:16 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v7 03/22] axonram: Fix bug in direct_access
Message-ID: <20140329162216.GC1211@quack.suse.cz>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <e3ede380dd37d3cae604ee20198e568c9eb4fa00.1395591795.git.matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e3ede380dd37d3cae604ee20198e568c9eb4fa00.1395591795.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@linux.intel.com

On Sun 23-03-14 15:08:29, Matthew Wilcox wrote:
> The 'pfn' returned by axonram was completely bogus, and has been since
> 2008.
  Maybe time to drop the driver instead? When noone noticed for 6 years, it
seems pretty much dead... Or is there some possibility the driver can get
reused for new HW?

  Anyway the patch looks correct so feel free to add:
Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> 
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
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
> 1.9.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
