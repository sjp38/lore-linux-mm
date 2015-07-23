Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 71FC49003C7
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 09:47:22 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so209336124wib.0
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 06:47:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id et10si30832750wib.62.2015.07.23.06.47.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Jul 2015 06:47:20 -0700 (PDT)
Date: Thu, 23 Jul 2015 15:47:14 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm/Kconfig: NEED_BOUNCE_POOL: clean-up condition
Message-ID: <20150723134714.GA29224@quack.suse.cz>
References: <1437650286-117629-1-git-send-email-valentinrothberg@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437650286-117629-1-git-send-email-valentinrothberg@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valentin Rothberg <valentinrothberg@gmail.com>
Cc: akpm@linux-foundation.org, jack@suse.cz, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, pebolle@tiscali.nl, stefan.hengelein@fau.de

On Thu 23-07-15 13:18:06, Valentin Rothberg wrote:
> commit 106542e7987c ("fs: Remove ext3 filesystem driver") removed ext3
> and JBD, hence remove the superfluous condition.
> 
> Signed-off-by: Valentin Rothberg <valentinrothberg@gmail.com>
> ---
> I detected the issue with undertaker-checkpatch
> (https://undertaker.cs.fau.de)

Thanks. I have added your patch into my tree. BTW, is the checker automated
enough that it could be made part of the 0-day tests Fengguang runs?

								Honza
 
>  mm/Kconfig | 8 +-------
>  1 file changed, 1 insertion(+), 7 deletions(-)
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> index e79de2bd12cd..d4e6495a720f 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -299,15 +299,9 @@ config BOUNCE
>  # On the 'tile' arch, USB OHCI needs the bounce pool since tilegx will often
>  # have more than 4GB of memory, but we don't currently use the IOTLB to present
>  # a 32-bit address to OHCI.  So we need to use a bounce pool instead.
> -#
> -# We also use the bounce pool to provide stable page writes for jbd.  jbd
> -# initiates buffer writeback without locking the page or setting PG_writeback,
> -# and fixing that behavior (a second time; jbd2 doesn't have this problem) is
> -# a major rework effort.  Instead, use the bounce buffer to snapshot pages
> -# (until jbd goes away).  The only jbd user is ext3.
>  config NEED_BOUNCE_POOL
>  	bool
> -	default y if (TILE && USB_OHCI_HCD) || (BLK_DEV_INTEGRITY && JBD)
> +	default y if TILE && USB_OHCI_HCD
>  
>  config NR_QUICK
>  	int
> -- 
> 1.9.1
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
