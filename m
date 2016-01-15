Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id B7702828DF
	for <linux-mm@kvack.org>; Fri, 15 Jan 2016 00:06:12 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id ho8so127906343pac.2
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 21:06:12 -0800 (PST)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id p22si13954597pfi.94.2016.01.14.21.06.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jan 2016 21:06:12 -0800 (PST)
Received: by mail-pf0-x22b.google.com with SMTP id n128so111661560pfn.3
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 21:06:12 -0800 (PST)
Date: Fri, 15 Jan 2016 14:07:22 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zsmalloc: fix migrate_zspage-zs_free race condition
Message-ID: <20160115050722.GE1993@swordfish>
References: <1452818184-2994-1-git-send-email-junil0814.lee@lge.com>
 <20160115023518.GA10843@bbox>
 <20160115032712.GC1993@swordfish>
 <20160115044916.GB11203@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160115044916.GB11203@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Junil Lee <junil0814.lee@lge.com>, Andrew Morton <akpm@linux-foundation.org>, ngupta@vflare.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (01/15/16 13:49), Minchan Kim wrote:
[..]
> > 
> > or zs_free() can take spin_lock(&class->lock) earlier, it cannot free the
> 
> Earlier? What do you mean? For getting right class, we should get a stable
> handle so we couldn't get class lock first than handle lock.
> If I misunderstand, please elaborate a bit.

ohh... you're right. I didn't really check the code when I was writing
this. please forget what I said.


yeah, agree, record_obj() better be doing this.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
