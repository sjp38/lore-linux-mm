Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1E2B96B0253
	for <linux-mm@kvack.org>; Mon,  8 Jan 2018 21:35:32 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id o9so7681565pgv.3
        for <linux-mm@kvack.org>; Mon, 08 Jan 2018 18:35:32 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f22sor4533269plk.98.2018.01.08.18.35.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jan 2018 18:35:31 -0800 (PST)
Date: Tue, 9 Jan 2018 11:35:26 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zswap: only save zswap header if zpool is shrinkable
Message-ID: <20180109023526.GA6953@jagdpanzerIV>
References: <20180108225101.15790-1-yuzhao@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180108225101.15790-1-yuzhao@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu Zhao <yuzhao@google.com>
Cc: Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (01/08/18 14:51), Yu Zhao wrote:
> We waste sizeof(swp_entry_t) for zswap header when using zsmalloc
> as zpool driver because zsmalloc doesn't support eviction.
> 
> Add zpool_shrinkable() to detect if zpool is shrinkable, and use
> it in zswap to avoid waste memory for zswap header.
> 
> Signed-off-by: Yu Zhao <yuzhao@google.com>

at a glance, looks good to me
Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
