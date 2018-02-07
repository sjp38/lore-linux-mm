Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8A3D66B02EC
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 04:29:31 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id b7so106880pga.12
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 01:29:31 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s12sor202171pgp.123.2018.02.07.01.29.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Feb 2018 01:29:30 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: [PATCH 0/2] zsmalloc/zram: drop zram's max_zpage_size
Date: Wed,  7 Feb 2018 18:29:17 +0900
Message-Id: <20180207092919.19696-1-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hello,

	ZRAM's max_zpage_size is a bad thing. It forces zsmalloc to
store normal objects as huge ones, which results in bigger zsmalloc
memory usage. Drop it and use actual zsmalloc huge-class value when
decide if the object is huge or not.

Sergey Senozhatsky (2):
  zsmalloc: introduce zs_huge_object() function
  zram: drop max_zpage_size and use zs_huge_object()

 drivers/block/zram/zram_drv.c |  6 +++---
 drivers/block/zram/zram_drv.h | 16 ----------------
 include/linux/zsmalloc.h      |  2 ++
 mm/zsmalloc.c                 | 17 +++++++++++++++++
 4 files changed, 22 insertions(+), 19 deletions(-)

-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
