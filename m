Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id B466D6B0032
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 22:18:40 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id y13so6411388pdi.17
        for <linux-mm@kvack.org>; Mon, 08 Dec 2014 19:18:40 -0800 (PST)
Received: from out4133-130.mail.aliyun.com (out4133-130.mail.aliyun.com. [42.120.133.130])
        by mx.google.com with ESMTP id ne7si55671328pbc.49.2014.12.08.19.18.37
        for <linux-mm@kvack.org>;
        Mon, 08 Dec 2014 19:18:39 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <010b01d012ca$05244060$0f6cc120$@alibaba-inc.com> <35FD53F367049845BC99AC72306C23D103E688B313F9@CNBJMBX05.corpusers.net> <35FD53F367049845BC99AC72306C23D103E688B313FA@CNBJMBX05.corpusers.net>
In-Reply-To: <35FD53F367049845BC99AC72306C23D103E688B313FA@CNBJMBX05.corpusers.net>
Subject: Re: [PATCH V3] mm:add VM_BUG_ON_PAGE() for page_mapcount()
Date: Tue, 09 Dec 2014 11:18:32 +0800
Message-ID: <015701d0135e$d1980980$74c81c80$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'Wang, Yalin'" <Yalin.Wang@sonymobile.com>, 'linux-kernel' <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, 'Andrew Morton' <akpm@linux-foundation.org>

> 
> This patch add VM_BUG_ON_PAGE() for slab page,
> because _mapcount is an union with slab struct in struct page,
> avoid access _mapcount if this page is a slab page.
> Also remove the unneeded bracket.
> 
> Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  include/linux/mm.h | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index b464611..a117527 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -449,7 +449,8 @@ static inline void page_mapcount_reset(struct page *page)
> 
>  static inline int page_mapcount(struct page *page)
>  {
> -	return atomic_read(&(page)->_mapcount) + 1;
> +	VM_BUG_ON_PAGE(PageSlab(page), page);
> +	return atomic_read(&page->_mapcount) + 1;
>  }
> 
>  static inline int page_count(struct page *page)
> --
> 2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
