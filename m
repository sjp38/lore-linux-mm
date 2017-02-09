Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3F55D28089F
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 02:05:26 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id y143so223393075pfb.6
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 23:05:26 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id b84si9308223pfl.88.2017.02.08.23.05.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 23:05:25 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id 75so17127166pgf.3
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 23:05:25 -0800 (PST)
Date: Thu, 9 Feb 2017 16:05:43 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2] mm/zsmalloc: fix comment in zsmalloc
Message-ID: <20170209070543.GA9995@jagdpanzerIV.localdomain>
References: <1486620822-36826-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1486620822-36826-1-git-send-email-xieyisheng1@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan@kernel.org, sergey.senozhatsky@gmail.com, ngupta@vflare.org, guohanjun@huawei.com

On (02/09/17 14:13), Yisheng Xie wrote:
> The class index and fullness group are not encoded in (first)page->mapping
> any more, after commit 3783689a1aa8 ("zsmalloc: introduce zspage
> structure"). Instead, they are store in struct zspage. Just delete this
> unneeded comment.
> 
> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
> Suggested-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Nitin Gupta <ngupta@vflare.org>
> Cc: Hanjun Guo <guohanjun@huawei.com>
> ---
> v2:
>  * just delete the comment for it is no need anymore, suggested by Sergey.

thanks for the patch.

my "suggestion" was just a side note, nothing more. I'm fine with the
"fix the comment" patch that Andrew has added to mmotm.
we need Minchan's opinion on this, until he speaks out let's have V1
("fix the comment") applied.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
