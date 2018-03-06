Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 552CE6B0007
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 02:06:50 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id u3so8394321pgp.13
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 23:06:50 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r19sor4168662pfh.22.2018.03.05.23.06.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 23:06:49 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: [PATCHv2 0/2] zsmalloc/zram: drop zram's max_zpage_size
Date: Tue,  6 Mar 2018 16:06:37 +0900
Message-Id: <20180306070639.7389-1-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hello,

	ZRAM's max_zpage_size is a bad thing. It forces zsmalloc to
store normal objects as huge ones, which results in bigger zsmalloc
memory usage. Drop it and use actual zsmalloc huge-class value when
decide if the object is huge or not.

Sergey Senozhatsky (2):
  zsmalloc: introduce zs_huge_class_size() function
  zram: drop max_zpage_size and use zs_huge_class_size()

 drivers/block/zram/zram_drv.c |  9 ++++++++-
 drivers/block/zram/zram_drv.h | 16 ----------------
 include/linux/zsmalloc.h      |  2 ++
 mm/zsmalloc.c                 | 40 ++++++++++++++++++++++++++++++++++++++++
 4 files changed, 50 insertions(+), 17 deletions(-)

-- 
2.16.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
