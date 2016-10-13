Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 40CB96B0253
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 11:43:01 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id n3so51820186lfn.5
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 08:43:01 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o7si18431265wjz.64.2016.10.13.08.42.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 13 Oct 2016 08:43:00 -0700 (PDT)
Date: Thu, 13 Oct 2016 17:42:57 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v6 17/17] dax: remove "depends on BROKEN" from FS_DAX_PMD
Message-ID: <20161013154257.GC30680@quack2.suse.cz>
References: <20161012225022.15507-1-ross.zwisler@linux.intel.com>
 <20161012225022.15507-18-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161012225022.15507-18-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Wed 12-10-16 16:50:22, Ross Zwisler wrote:
> Now that DAX PMD faults are once again working and are now participating in
> DAX's radix tree locking scheme, allow their config option to be enabled.
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/Kconfig | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/fs/Kconfig b/fs/Kconfig
> index 2bc7ad7..b6f0fce 100644
> --- a/fs/Kconfig
> +++ b/fs/Kconfig
> @@ -55,7 +55,6 @@ config FS_DAX_PMD
>  	depends on FS_DAX
>  	depends on ZONE_DEVICE
>  	depends on TRANSPARENT_HUGEPAGE
> -	depends on BROKEN
>  
>  endif # BLOCK
>  
> -- 
> 2.9.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
