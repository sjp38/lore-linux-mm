Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id DE9526B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 20:49:29 -0400 (EDT)
Received: by pacws9 with SMTP id ws9so160312996pac.0
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 17:49:29 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id rk5si11726204pab.62.2015.07.09.17.49.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 17:49:29 -0700 (PDT)
Received: by pacgz10 with SMTP id gz10so85426870pac.3
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 17:49:28 -0700 (PDT)
Date: Fri, 10 Jul 2015 09:49:21 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v7 7/7] zsmalloc: use shrinker to trigger auto-compaction
Message-ID: <20150710004921.GA10230@bgram>
References: <1436355113-12417-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1436355113-12417-8-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1436355113-12417-8-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

Hi Sergey,

On Wed, Jul 08, 2015 at 08:31:53PM +0900, Sergey Senozhatsky wrote:
> Perform automatic pool compaction by a shrinker when system
> is getting tight on memory.
> 
> User-space has a very little knowledge regarding zsmalloc fragmentation
> and basically has no mechanism to tell whether compaction will result
> in any memory gain. Another issue is that user space is not always
> aware of the fact that system is getting tight on memory. Which leads
> to very uncomfortable scenarios when user space may start issuing
> compaction 'randomly' or from crontab (for example). Fragmentation
> is not always necessarily bad, allocated and unused objects, after all,
> may be filled with the data later, w/o the need of allocating a new
> zspage. On the other hand, we obviously don't want to waste memory
> when the system needs it.
> 
> Compaction now has a relatively quick pool scan so we are able to
> estimate the number of pages that will be freed easily, which makes it
> possible to call this function from a shrinker->count_objects() callback.
> We also abort compaction as soon as we detect that we can't free any
> pages any more, preventing wasteful objects migrations.
> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Suggested-by: Minchan Kim <minchan@kernel.org>
Acked-by: Minchan Kim <minchan@kernel.org>

Thanks for great work!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
