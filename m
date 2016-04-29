Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 61A316B0253
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 20:24:15 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id zy2so145190660pac.1
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 17:24:15 -0700 (PDT)
Received: from mail-pf0-x234.google.com (mail-pf0-x234.google.com. [2607:f8b0:400e:c00::234])
        by mx.google.com with ESMTPS id ff4si18762085pad.48.2016.04.28.17.24.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 17:24:14 -0700 (PDT)
Received: by mail-pf0-x234.google.com with SMTP id 77so7960918pfv.2
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 17:24:14 -0700 (PDT)
Date: Fri, 29 Apr 2016 09:25:47 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm/zswap: provide unique zpool name
Message-ID: <20160429002547.GB4920@swordfish>
References: <CALZtONArGwmaWNcHJODmY1uXm306NiqeZtRekfCFgZsMz_cngw@mail.gmail.com>
 <1461834803-5565-1-git-send-email-ddstreet@ieee.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1461834803-5565-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@redhat.com>, Yu Zhao <yuzhao@google.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Linux-MM <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dan Streetman <dan.streetman@canonical.com>

On (04/28/16 05:13), Dan Streetman wrote:
> Instead of using "zswap" as the name for all zpools created, add
> an atomic counter and use "zswap%x" with the counter number for each
> zpool created, to provide a unique name for each new zpool.
> 
> As zsmalloc, one of the zpool implementations, requires/expects a
> unique name for each pool created, zswap should provide a unique name.
> The zsmalloc pool creation does not fail if a new pool with a
> conflicting name is created, unless CONFIG_ZSMALLOC_STAT is enabled;
> in that case, zsmalloc pool creation fails with -ENOMEM.  Then zswap
> will be unable to change its compressor parameter if its zpool is
> zsmalloc; it also will be unable to change its zpool parameter back
> to zsmalloc, if it has any existing old zpool using zsmalloc with
> page(s) in it.  Attempts to change the parameters will result in
> failure to create the zpool.  This changes zswap to provide a
> unique name for each zpool creation.
> 
> Fixes: f1c54846ee45 ("zswap: dynamic pool creation")
> Reported-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Cc: Dan Streetman <dan.streetman@canonical.com>
> Signed-off-by: Dan Streetman <ddstreet@ieee.org>

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
