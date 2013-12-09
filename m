Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id 423FE6B00AB
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 10:36:34 -0500 (EST)
Received: by mail-yh0-f47.google.com with SMTP id 29so2752632yhl.34
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 07:36:34 -0800 (PST)
Received: from mail-ob0-x236.google.com (mail-ob0-x236.google.com [2607:f8b0:4003:c01::236])
        by mx.google.com with ESMTPS id u45si10365453yhc.228.2013.12.09.07.36.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 07:36:33 -0800 (PST)
Received: by mail-ob0-f182.google.com with SMTP id wp4so3927056obc.27
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 07:36:32 -0800 (PST)
Date: Mon, 9 Dec 2013 09:36:26 -0600
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [PATCH] mm/zswap.c: add BUG() for default case in
 zswap_writeback_entry()
Message-ID: <20131209153626.GA3752@cerebellum.variantweb.net>
References: <52A53024.9090701@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52A53024.9090701@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen.5i5j@gmail.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, James Hogan <james.hogan@imgtec.com>

On Mon, Dec 09, 2013 at 10:51:16AM +0800, Chen Gang wrote:
> Recommend to add default case to avoid compiler's warning, although at
> present, the original implementation is still correct.
> 
> The related warning (with allmodconfig for metag):
> 
>     CC      mm/zswap.o
>   mm/zswap.c: In function 'zswap_writeback_entry':
>   mm/zswap.c:537: warning: 'ret' may be used uninitialized in this function
> 
> 
> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
> ---
>  mm/zswap.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/zswap.c b/mm/zswap.c
> index 5a63f78..bfd1807 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -585,6 +585,8 @@ static int zswap_writeback_entry(struct zbud_pool *pool, unsigned long handle)
>  
>  		/* page is up to date */
>  		SetPageUptodate(page);
> +	default:
> +		BUG();

Typically, the way you want to address this is initialize ret to 0
at declaration time if not every control path will set that value.

Seth

>  	}
>  
>  	/* move it to the tail of the inactive list after end_writeback */
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
