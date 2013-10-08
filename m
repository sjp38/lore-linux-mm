Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 363CA6B0031
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 16:48:30 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id lf10so618pab.3
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 13:48:29 -0700 (PDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjennings@medulla.variantweb.net>;
	Tue, 8 Oct 2013 14:48:27 -0600
Received: from b01cxnp22034.gho.pok.ibm.com (b01cxnp22034.gho.pok.ibm.com [9.57.198.24])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id AD4EA6E80A5
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 16:48:21 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp22034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r98KmLhI62324760
	for <linux-mm@kvack.org>; Tue, 8 Oct 2013 20:48:21 GMT
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r98KmL7i020412
	for <linux-mm@kvack.org>; Tue, 8 Oct 2013 17:48:21 -0300
Date: Tue, 8 Oct 2013 15:48:19 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 4/6] zbud: memset zbud_header to 0 during init
Message-ID: <20131008204819.GC8798@medulla.variantweb.net>
References: <1381238980-2491-1-git-send-email-k.kozlowski@samsung.com>
 <1381238980-2491-5-git-send-email-k.kozlowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1381238980-2491-5-git-send-email-k.kozlowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Dave Hansen <dave.hansen@intel.com>, Minchan Kim <minchan@kernel.org>

On Tue, Oct 08, 2013 at 03:29:38PM +0200, Krzysztof Kozlowski wrote:
> memset zbud_header to 0 during init instead of manually assigning 0 to
> members. Currently only two members needs to be initialized to 0 but
> further patches will add more of them.

Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>

> 
> Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>
> ---
>  mm/zbud.c |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/zbud.c b/mm/zbud.c
> index 6db0557..0edd880 100644
> --- a/mm/zbud.c
> +++ b/mm/zbud.c
> @@ -133,8 +133,7 @@ static int size_to_chunks(int size)
>  static struct zbud_header *init_zbud_page(struct page *page)
>  {
>  	struct zbud_header *zhdr = page_address(page);
> -	zhdr->first_chunks = 0;
> -	zhdr->last_chunks = 0;
> +	memset(zhdr, 0, sizeof(*zhdr));
>  	INIT_LIST_HEAD(&zhdr->buddy);
>  	INIT_LIST_HEAD(&zhdr->lru);
>  	return zhdr;
> -- 
> 1.7.9.5
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
