Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 3D9FA6B0038
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 22:21:59 -0400 (EDT)
Received: by payp3 with SMTP id p3so23744660pay.1
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 19:21:59 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id xg5si17869128pab.13.2015.10.14.19.21.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Oct 2015 19:21:58 -0700 (PDT)
Received: by pabrc13 with SMTP id rc13so71630986pab.0
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 19:21:58 -0700 (PDT)
Date: Thu, 15 Oct 2015 11:24:47 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zsmalloc: use preempt.h for in_interrupt()
Message-ID: <20151015022430.GA2840@bbox>
References: <1444828400-4067-1-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1444828400-4067-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Wed, Oct 14, 2015 at 10:13:20PM +0900, Sergey Senozhatsky wrote:
> A cosmetic change.
> 
> Commit c60369f01125 ("staging: zsmalloc: prevent mappping
> in interrupt context") added in_interrupt() check to
> zs_map_object() and 'hardirq.h' include; but in_interrupt()
> macro is defined in 'preempt.h' not in 'hardirq.h', so include
> it instead.
> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Acked-by: Minchan Kim <minchan@kernel.org>
 
Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
