Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 979E76B0005
	for <linux-mm@kvack.org>; Sun, 22 May 2016 23:03:51 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id yl2so248853114pac.2
        for <linux-mm@kvack.org>; Sun, 22 May 2016 20:03:51 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id o14si28115943pfi.82.2016.05.22.20.03.49
        for <linux-mm@kvack.org>;
        Sun, 22 May 2016 20:03:50 -0700 (PDT)
Date: Mon, 23 May 2016 12:03:58 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCHv2] mm/zsmalloc: don't fail if can't create debugfs info
Message-ID: <20160523030358.GA6266@bbox>
References: <CADAEsF-kaCQnNN_9gySw3J0UT4mGh8KFp75tGSJtaDAuN1T10A@mail.gmail.com>
 <1463671123-5479-1-git-send-email-ddstreet@ieee.org>
MIME-Version: 1.0
In-Reply-To: <1463671123-5479-1-git-send-email-ddstreet@ieee.org>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Ganesh Mahendran <opensource.ganesh@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Seth Jennings <sjenning@redhat.com>, Yu Zhao <yuzhao@google.com>, Linux-MM <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dan Streetman <dan.streetman@canonical.com>

On Thu, May 19, 2016 at 11:18:43AM -0400, Dan Streetman wrote:
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
> 
> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
> Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Cc: Dan Streetman <dan.streetman@canonical.com>
> Cc: Minchan Kim <minchan@kernel.org>
Acked-by: Minchan Kim <minchan@kernel.org>

However, Andrew already sent old version to upstream.

Andrew, Could you send revert patch of [1] in linus's tree and send
this instead of it if you have chance?

[1] d34f615720d1 mm/zsmalloc: don't fail if can't create debugfs info

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
