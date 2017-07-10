Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D666744084A
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 09:41:32 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g46so24368038wrd.3
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 06:41:32 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e21si6722023wmc.198.2017.07.10.06.41.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Jul 2017 06:41:31 -0700 (PDT)
Date: Mon, 10 Jul 2017 15:41:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/mremap: Document MREMAP_FIXED dependency on
 MREMAP_MAYMOVE
Message-ID: <20170710134130.GA19645@dhcp22.suse.cz>
References: <20170710113211.31394-1-khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170710113211.31394-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mike.kravetz@oracle.com

On Mon 10-07-17 17:02:11, Anshuman Khandual wrote:
> In the header file, just specify the dependency of MREMAP_FIXED
> on MREMAP_MAYMOVE and make it explicit for the user space.

I really fail to see a point of this patch. The depency belongs to the
code and it seems that we already enforce it
	if (flags & MREMAP_FIXED && !(flags & MREMAP_MAYMOVE))
		return ret;

So what is the point here?

> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> ---
>  include/uapi/linux/mman.h | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/include/uapi/linux/mman.h b/include/uapi/linux/mman.h
> index ade4acd..8cae3f6 100644
> --- a/include/uapi/linux/mman.h
> +++ b/include/uapi/linux/mman.h
> @@ -3,8 +3,10 @@
>  
>  #include <asm/mman.h>
>  
> -#define MREMAP_MAYMOVE	1
> -#define MREMAP_FIXED	2
> +#define MREMAP_MAYMOVE	1 /* VMA can move after remap and resize */
> +#define MREMAP_FIXED	2 /* VMA can remap at particular address */
> +
> +/* NOTE: MREMAP_FIXED must be set with MREMAP_MAYMOVE, not alone */
>  
>  #define OVERCOMMIT_GUESS		0
>  #define OVERCOMMIT_ALWAYS		1
> -- 
> 1.8.5.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
