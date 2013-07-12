Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id E89196B0032
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 00:58:12 -0400 (EDT)
Message-ID: <51DF8CDE.4010205@oracle.com>
Date: Fri, 12 Jul 2013 12:58:06 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] zswap: get swapper address_space by using swap_address_space
 macro
References: <1373604175-19562-1-git-send-email-sunghan.suh@samsung.com>
In-Reply-To: <1373604175-19562-1-git-send-email-sunghan.suh@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sunghan Suh <sunghan.suh@samsung.com>
Cc: sjenning@linux.vnet.ibm.com, linux-mm@kvack.org


On 07/12/2013 12:42 PM, Sunghan Suh wrote:
> Signed-off-by: Sunghan Suh <sunghan.suh@samsung.com>
> ---
>   mm/zswap.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/zswap.c b/mm/zswap.c
> index deda2b6..efed4c8 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -409,7 +409,7 @@ static int zswap_get_swap_cache_page(swp_entry_t entry,
>   				struct page **retpage)
>   {
>   	struct page *found_page, *new_page = NULL;
> -	struct address_space *swapper_space = &swapper_spaces[swp_type(entry)];
> +	struct address_space *swapper_space = swap_address_space(entry);
>   	int err;
>
>   	*retpage = NULL;
>

Reviewed-by: Bob Liu <bob.liu@oracle.com>

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
