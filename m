Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 856696B0005
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 10:38:01 -0500 (EST)
Received: by mail-ob0-f178.google.com with SMTP id xk3so19487331obc.2
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 07:38:01 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id s185si2201350oia.89.2016.02.17.07.37.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 17 Feb 2016 07:38:00 -0800 (PST)
Date: Thu, 18 Feb 2016 00:37:59 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zsmalloc: drop unused member 'mapping_area->huge'
Message-ID: <20160217153759.GA30705@bbox>
References: <1455674199-6227-1-git-send-email-xuyiping@huawei.com>
MIME-Version: 1.0
In-Reply-To: <1455674199-6227-1-git-send-email-xuyiping@huawei.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: YiPing Xu <xuyiping@huawei.com>
Cc: ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, suzhuangluan@hisilicon.com, puck.chen@hisilicon.com, dan.zhao@hisilicon.com

On Wed, Feb 17, 2016 at 09:56:39AM +0800, YiPing Xu wrote:
> When unmapping a huge class page in zs_unmap_object, the page will
> be unmapped by kmap_atomic. the "!area->huge" branch in
> __zs_unmap_object is alway true, and no code set "area->huge" now,
> so we can drop it.
> 
> Signed-off-by: YiPing Xu <xuyiping@huawei.com>
Acked-by: Minchan Kim <minchan@kernel.org>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
