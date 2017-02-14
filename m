Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2BBE06B03AD
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 11:17:36 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id g13so203021265otd.5
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 08:17:36 -0800 (PST)
Received: from mail-ot0-x242.google.com (mail-ot0-x242.google.com. [2607:f8b0:4003:c0f::242])
        by mx.google.com with ESMTPS id g192si490195oib.32.2017.02.14.08.17.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 08:17:35 -0800 (PST)
Received: by mail-ot0-x242.google.com with SMTP id t47so2443771ota.0
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 08:17:35 -0800 (PST)
Date: Wed, 15 Feb 2017 01:16:53 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [RFC] mm/zsmalloc: remove redundant SetPagePrivate2 in
 create_page_chain
Message-ID: <20170214161653.GA10321@tigerII.localdomain>
References: <1487076509-49270-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1487076509-49270-1-git-send-email-xieyisheng1@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>
Cc: akpm@linux-foundation.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, guohanjun@huawei.com

On (02/14/17 20:48), Yisheng Xie wrote:
> We had used page->lru to link the component pages (except the first
> page) of a zspage, and used INIT_LIST_HEAD(&page->lru) to init it.
> Therefore, to get the last page's next page, which is NULL, we had to
> use page flag PG_Private_2 to identify it.
> 
> But now, we use page->freelist to link all of the pages in zspage and
> init the page->freelist as NULL for last page, so no need to use
> PG_Private_2 anymore.
> 
> This patch is to remove redundant SetPagePrivate2 in create_page_chain
> and ClearPagePrivate2 in reset_page(). Maybe can save few cycles for
> migration of zsmalloc page :)
> 
> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>

looks good to me.

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
