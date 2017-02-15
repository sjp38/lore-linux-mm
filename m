Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4CBAC680FD0
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 02:13:52 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id z67so168114197pgb.0
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 23:13:52 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id y15si2901035pli.233.2017.02.14.23.13.50
        for <linux-mm@kvack.org>;
        Tue, 14 Feb 2017 23:13:51 -0800 (PST)
Date: Wed, 15 Feb 2017 16:13:44 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC] mm/zsmalloc: remove redundant SetPagePrivate2 in
 create_page_chain
Message-ID: <20170215071344.GA23887@bbox>
References: <1487076509-49270-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
In-Reply-To: <1487076509-49270-1-git-send-email-xieyisheng1@huawei.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>
Cc: akpm@linux-foundation.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, guohanjun@huawei.com

On Tue, Feb 14, 2017 at 08:48:29PM +0800, Yisheng Xie wrote:
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
Acked-by: Minchan Kim <minchan@kernel.org>

Thanks, Yisheng!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
