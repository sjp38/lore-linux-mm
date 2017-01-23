Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id A35A56B0033
	for <linux-mm@kvack.org>; Sun, 22 Jan 2017 20:15:50 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id w144so174512049oiw.0
        for <linux-mm@kvack.org>; Sun, 22 Jan 2017 17:15:50 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id i21si5360202otd.86.2017.01.22.17.15.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 22 Jan 2017 17:15:49 -0800 (PST)
Message-ID: <588558EB.2060505@huawei.com>
Date: Mon, 23 Jan 2017 09:14:19 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: do not export ioremap_page_range symbol for external
 module
References: <1485089881-61531-1-git-send-email-zhongjiang@huawei.com>
In-Reply-To: <1485089881-61531-1-git-send-email-zhongjiang@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, minchan@kernel.org, mhocko@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2017/1/22 20:58, zhongjiang wrote:
> From: zhong jiang <zhongjiang@huawei.com>
>
> Recently, I find the ioremap_page_range had been abusing. The improper
> address mapping is a issue. it will result in the crash. so, remove
> the symbol. It can be replaced by the ioremap_cache or others symbol.
>
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> ---
>  lib/ioremap.c | 1 -
>  1 file changed, 1 deletion(-)
>
> diff --git a/lib/ioremap.c b/lib/ioremap.c
> index 86c8911..a3e14ce 100644
> --- a/lib/ioremap.c
> +++ b/lib/ioremap.c
> @@ -144,4 +144,3 @@ int ioremap_page_range(unsigned long addr,
>  
>  	return err;
>  }
> -EXPORT_SYMBOL_GPL(ioremap_page_range);
self nack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
