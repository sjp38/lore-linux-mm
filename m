Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 396026B0031
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 14:00:43 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Fri, 12 Jul 2013 19:00:42 +0100
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 98DC038C8042
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 14:00:38 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6CI0daR9044420
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 14:00:39 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6CI0D9f006323
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 14:00:14 -0400
Date: Fri, 12 Jul 2013 13:00:06 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCH] zswap: get swapper address_space by using
 swap_address_space macro
Message-ID: <20130712180006.GB3784@cerebellum>
References: <1373604175-19562-1-git-send-email-sunghan.suh@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373604175-19562-1-git-send-email-sunghan.suh@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sunghan Suh <sunghan.suh@samsung.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Fri, Jul 12, 2013 at 01:42:55PM +0900, Sunghan Suh wrote:
> Signed-off-by: Sunghan Suh <sunghan.suh@samsung.com>
> ---
>  mm/zswap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/zswap.c b/mm/zswap.c
> index deda2b6..efed4c8 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -409,7 +409,7 @@ static int zswap_get_swap_cache_page(swp_entry_t entry,
>  				struct page **retpage)
>  {
>  	struct page *found_page, *new_page = NULL;
> -	struct address_space *swapper_space = &swapper_spaces[swp_type(entry)];
> +	struct address_space *swapper_space = swap_address_space(entry);
>  	int err;
> 
>  	*retpage = NULL;

Thanks Sunghan!

Please add a simple commit message and resend with Andrew Morton on Cc:
Andrew Morton <akpm@linux-foundation.org>

When you resend, include the Reviewed-by tags from Wanpeng and Bob,
as well as my:

Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
