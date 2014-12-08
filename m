Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 470CB6B0075
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 04:33:33 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so4938058pab.0
        for <linux-mm@kvack.org>; Mon, 08 Dec 2014 01:33:33 -0800 (PST)
Received: from out4133-82.mail.aliyun.com (out4133-82.mail.aliyun.com. [42.120.133.82])
        by mx.google.com with ESMTP id s4si59157416pdj.117.2014.12.08.01.33.30
        for <linux-mm@kvack.org>;
        Mon, 08 Dec 2014 01:33:32 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
Subject: Re: [PATCH] mm:add VM_BUG_ON() for page_mapcount()
Date: Mon, 08 Dec 2014 17:33:26 +0800
Message-ID: <010b01d012ca$05244060$0f6cc120$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yalin.Wang@sonymobile.com
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Andrew Morton <akpm@linux-foundation.org>, Hillf Danton <hillf.zj@alibaba-inc.com>

> 
> This patch add VM_BUG_ON() for slab page,
> because _mapcount is an union with slab struct in struct page,
> avoid access _mapcount if this page is a slab page.
> Also remove the unneeded bracket.
> 
> Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
> ---
>  include/linux/mm.h | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 11b65cf..34124c4 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -373,7 +373,8 @@ static inline void reset_page_mapcount(struct page *page)
> 
>  static inline int page_mapcount(struct page *page)
>  {
> -	return atomic_read(&(page)->_mapcount) + 1;
> +	VM_BUG_ON(PageSlab(page));

s/ VM_BUG_ON/ VM_BUG_ON_PAGE/ ?

> +	return atomic_read(&page->_mapcount) + 1;
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
