Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 16AA86B0038
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 01:11:40 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id jt11so6530275pbb.36
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 22:11:39 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id sa6si10874967pbb.23.2013.12.16.22.11.37
        for <linux-mm@kvack.org>;
        Mon, 16 Dec 2013 22:11:38 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 0/5] zram/zsmalloc copyright and maintainers
Date: Tue, 17 Dec 2013 15:11:58 +0900
Message-Id: <1387260723-15817-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nitin Gupta <ngupta@vflare.org>, linux-kernel@vger.kernel.org, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

I and Nitin discussed how to maintain zsmalloc and zram.
Nitin wanted me to maintain zram because he doesn't have enough
bandwidth to quickly handle any issues that might arise and
I have maintained zram/zsmalloc during last two years so he
will be listed as co-maintainer.

Minchan Kim (5):
  zram: remove old private project comment
  zram: add copyright
  zsmalloc: add copyright
  zram: add zram maintainers
  zsmalloc: add maintainers

 Documentation/blockdev/zram.txt |    6 ------
 MAINTAINERS                     |   16 ++++++++++++++++
 drivers/block/zram/Kconfig      |    1 -
 drivers/block/zram/zram_drv.c   |    2 +-
 drivers/block/zram/zram_drv.h   |    2 +-
 include/linux/zsmalloc.h        |    1 +
 mm/zsmalloc.c                   |    1 +
 7 files changed, 20 insertions(+), 9 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
