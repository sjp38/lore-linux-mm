Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 940C36B025F
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 01:30:51 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id x189so93564426pgb.11
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 22:30:51 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id p26si1533546pgn.196.2017.08.16.22.30.49
        for <linux-mm@kvack.org>;
        Wed, 16 Aug 2017 22:30:50 -0700 (PDT)
Date: Thu, 17 Aug 2017 14:30:48 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zsmalloc: zs_page_isolate: skip unnecessary loops but
 not return false if zspage is not inuse
Message-ID: <20170817053048.GA31165@blaptop>
References: <1502869794-29263-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1502869794-29263-1-git-send-email-zhuhui@xiaomi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hui Zhu <zhuhui@xiaomi.com>
Cc: ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, teawater@gmail.com

On Wed, Aug 16, 2017 at 03:49:54PM +0800, Hui Zhu wrote:
> Like [1], zs_page_isolate meet the same problem if zspage is not inuse.
> 
> After [2], zs_page_migrate can support empty zspage now.
> 
> Make this patch to let zs_page_isolate skip unnecessary loops but not
> return false if zspage is not inuse.
> 
> [1] zsmalloc-zs_page_migrate-skip-unnecessary-loops-but-not-return-ebusy-if-zspage-is-not-inuse-fix.patch
> [2] zsmalloc-zs_page_migrate-schedule-free_work-if-zspage-is-ZS_EMPTY.patch
> 
> Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
Acked-by: Minchan Kim <minchan@kernel.org>

Andrew,
Could you fold this to zsmalloc-zs_page_migrate-skip-unnecessary-loops-but-not-return-ebusy-if-zspage-is-not-inuse?

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
