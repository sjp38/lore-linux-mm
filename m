Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E1D4F6B0005
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 18:16:49 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 203so167681295pfy.2
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 15:16:49 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 186si12335955pfg.67.2016.04.28.15.16.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 15:16:49 -0700 (PDT)
Date: Thu, 28 Apr 2016 15:16:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/zswap: provide unique zpool name
Message-Id: <20160428151647.8bbf279a7d937a1b017ca003@linux-foundation.org>
In-Reply-To: <1461834803-5565-1-git-send-email-ddstreet@ieee.org>
References: <CALZtONArGwmaWNcHJODmY1uXm306NiqeZtRekfCFgZsMz_cngw@mail.gmail.com>
	<1461834803-5565-1-git-send-email-ddstreet@ieee.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Seth Jennings <sjenning@redhat.com>, Yu Zhao <yuzhao@google.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Linux-MM <linux-mm@kvack.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dan Streetman <dan.streetman@canonical.com>

On Thu, 28 Apr 2016 05:13:23 -0400 Dan Streetman <ddstreet@ieee.org> wrote:

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

September 2015.  I added a cc:stable to this one.

> Reported-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Cc: Dan Streetman <dan.streetman@canonical.com>
> Signed-off-by: Dan Streetman <ddstreet@ieee.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
