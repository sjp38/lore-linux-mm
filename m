Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 409CF6B025F
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 02:05:05 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id v25so1137874pfg.14
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 23:05:05 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b2sor3985051pga.345.2018.01.10.23.05.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 23:05:04 -0800 (PST)
Date: Thu, 11 Jan 2018 16:04:59 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v3] zswap: only save zswap header when necessary
Message-ID: <20180111070459.GH494@jagdpanzerIV>
References: <20180110224741.83751-1-yuzhao@google.com>
 <20180110225626.110330-1-yuzhao@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180110225626.110330-1-yuzhao@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu Zhao <yuzhao@google.com>
Cc: Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (01/10/18 14:56), Yu Zhao wrote:
[..]
> We waste sizeof(swp_entry_t) for zswap header when using zsmalloc
> as zpool driver because zsmalloc doesn't support eviction.
>
> Add zpool_evictable() to detect if zpool is potentially evictable,
> and use it in zswap to avoid waste memory for zswap header.
>
> Signed-off-by: Yu Zhao <yuzhao@google.com>

looks good to me.

FWIW,
Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
