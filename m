Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A25FE6B0069
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 01:58:03 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id p1so1110351pfp.13
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 22:58:03 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s7sor1497726pgr.99.2018.01.10.22.58.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 22:58:02 -0800 (PST)
Date: Thu, 11 Jan 2018 15:57:57 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zswap: only save zswap header if zpool is shrinkable
Message-ID: <20180111065757.GG494@jagdpanzerIV>
References: <20180108225101.15790-1-yuzhao@google.com>
 <CALZtONCsC79jyCsFQcJOALhw=QrTeFMiYTpE+HRrVjMh-QeT-g@mail.gmail.com>
 <20180109224700.GA175231@google.com>
 <CALZtONDc3VkWg83y1Nv_q+yUmwuFWmPUrFQOTJQv6b_ZbOh49g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONDc3VkWg83y1Nv_q+yUmwuFWmPUrFQOTJQv6b_ZbOh49g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Yu Zhao <yuzhao@google.com>, Seth Jennings <sjenning@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

Hello,

Yu Zhao, Dan, sorry for the delay


On (01/10/18 15:06), Dan Streetman wrote:
[..]
> Well, I think shrink vs evict an implementation detail, isn't it?
> That is, from zswap's perspective, there should be:
> 
> zpool_evictable()
> if true, zswap needs to include the header on each compressed page,
> because the zpool may callback zpool->ops->evict() which calls
> zswap_writeback_entry() which expects the entry to start with a zswap
> header.
> if false, zswap doesn't need to include the header, because the zpool
> will never, ever call zpool->ops->evict
> 
> zpool_shrink()
> this will try to shrink the zpool, using whatever
> zpool-implementation-specific shrinking method.  If zpool_evictable()
> is true for this zpool, then zpool_shrink() *might* callback to
> zpool->ops->evict(), although it doesn't have to if it can shrink
> without evictions.  If zpool_evictable() is false, then zpool_shrink()
> will never callback to zpool->ops->evict().

ACK on this!

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
