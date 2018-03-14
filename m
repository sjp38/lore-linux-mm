Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6B9066B0005
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 04:18:44 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id b2-v6so1113037plz.17
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 01:18:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a100-v6sor213985pli.89.2018.03.14.01.18.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Mar 2018 01:18:43 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: [PATCHv3 0/2] zsmalloc/zram: drop zram's max_zpage_size
Date: Wed, 14 Mar 2018 17:18:31 +0900
Message-Id: <20180314081833.1096-1-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hello,

	ZRAM's max_zpage_size is a bad thing. It forces zsmalloc to
store normal objects as huge ones, which results in bigger zsmalloc
memory usage. Drop it and use actual zsmalloc huge-class value when
decide if the object is huge or not.

v3:
- add pool param to zs_huge_class_size() [Minchan]

Sergey Senozhatsky (2):
  zsmalloc: introduce zs_huge_class_size() function
  zram: drop max_zpage_size and use zs_huge_class_size()

 drivers/block/zram/zram_drv.c |  9 ++++++++-
 drivers/block/zram/zram_drv.h | 16 ----------------
 include/linux/zsmalloc.h      |  2 ++
 mm/zsmalloc.c                 | 41 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 51 insertions(+), 17 deletions(-)

-- 
2.16.2
