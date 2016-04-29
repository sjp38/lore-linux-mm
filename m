Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id DC8986B0005
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 20:36:51 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id xm6so126161981pab.3
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 17:36:51 -0700 (PDT)
Received: from mail-pf0-x22c.google.com (mail-pf0-x22c.google.com. [2607:f8b0:400e:c00::22c])
        by mx.google.com with ESMTPS id u86si12903952pfa.250.2016.04.28.17.36.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 17:36:51 -0700 (PDT)
Received: by mail-pf0-x22c.google.com with SMTP id c189so41091298pfb.3
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 17:36:51 -0700 (PDT)
Date: Fri, 29 Apr 2016 09:38:24 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm/zsmalloc: don't fail if can't create debugfs info
Message-ID: <20160429003824.GC4920@swordfish>
References: <1461857808-11030-1-git-send-email-ddstreet@ieee.org>
 <20160428150709.2eef0506d84cd37ac6b61d12@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160428150709.2eef0506d84cd37ac6b61d12@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Streetman <ddstreet@ieee.org>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Seth Jennings <sjenning@redhat.com>, Yu Zhao <yuzhao@google.com>, Linux-MM <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dan Streetman <dan.streetman@canonical.com>

On (04/28/16 15:07), Andrew Morton wrote:
> Needed a bit of tweaking due to
> http://ozlabs.org/~akpm/mmotm/broken-out/zsmalloc-reordering-function-parameter.patch

Thanks.

> From: Dan Streetman <ddstreet@ieee.org>
> Subject: mm/zsmalloc: don't fail if can't create debugfs info
> 
> Change the return type of zs_pool_stat_create() to void, and
> remove the logic to abort pool creation if the stat debugfs
> dir/file could not be created.
> 
> The debugfs stat file is for debugging/information only, and doesn't
> affect operation of zsmalloc; there is no reason to abort creating
> the pool if the stat file can't be created.  This was seen with
> zswap, which used the same name for all pool creations, which caused
> zsmalloc to fail to create a second pool for zswap if
> CONFIG_ZSMALLOC_STAT was enabled.

no real objections from me. given that both zram and zswap now provide
unique names for zsmalloc stats dir, this patch does not fix any "real"
(observed) problem /* ENOMEM in debugfs_create_dir() is a different
case */.  so it's more of a cosmetic patch.

FWIW,
Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
