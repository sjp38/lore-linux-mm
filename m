Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1183328089F
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 03:12:08 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id d123so226148881pfd.0
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 00:12:08 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id w31si9442504pla.66.2017.02.09.00.12.05
        for <linux-mm@kvack.org>;
        Thu, 09 Feb 2017 00:12:07 -0800 (PST)
Date: Thu, 9 Feb 2017 17:09:17 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] mm/zsmalloc: fix comment in zsmalloc
Message-ID: <20170209080917.GA23016@bbox>
References: <1486620822-36826-1-git-send-email-xieyisheng1@huawei.com>
 <20170209070543.GA9995@jagdpanzerIV.localdomain>
MIME-Version: 1.0
In-Reply-To: <20170209070543.GA9995@jagdpanzerIV.localdomain>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky@gmail.com, ngupta@vflare.org, guohanjun@huawei.com

On Thu, Feb 09, 2017 at 04:05:43PM +0900, Sergey Senozhatsky wrote:
> On (02/09/17 14:13), Yisheng Xie wrote:
> > The class index and fullness group are not encoded in (first)page->mapping
> > any more, after commit 3783689a1aa8 ("zsmalloc: introduce zspage
> > structure"). Instead, they are store in struct zspage. Just delete this
> > unneeded comment.
> > 
> > Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
> > Suggested-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > Cc: Minchan Kim <minchan@kernel.org>
> > Cc: Nitin Gupta <ngupta@vflare.org>
> > Cc: Hanjun Guo <guohanjun@huawei.com>
Acked-by: Minchan Kim <minchan@kernel.org>

> > ---
> > v2:
> >  * just delete the comment for it is no need anymore, suggested by Sergey.
> 
> thanks for the patch.
> 
> my "suggestion" was just a side note, nothing more. I'm fine with the
> "fix the comment" patch that Andrew has added to mmotm.
> we need Minchan's opinion on this, until he speaks out let's have V1
> ("fix the comment") applied.

I agree on Sergey's opinion.

Andrew,
Please drop previous patch and replace it with this.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
