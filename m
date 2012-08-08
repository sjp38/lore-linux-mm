Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 64BD26B004D
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 02:10:51 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 0/7] zram/zsmalloc promotion
Date: Wed,  8 Aug 2012 15:12:13 +0900
Message-Id: <1344406340-14128-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>

This patchset promotes zram/zsmalloc from staging.
Both are very clean and zram is used by many embedded product
for a long time.

[1-3] are patches not merged into linux-next yet but needed
it as base for [4-5] which promotes zsmalloc.
Greg, if you merged [1-3] already, skip them.

Seth Jennings (5):
  1. zsmalloc: s/firstpage/page in new copy map funcs
  2. zsmalloc: prevent mappping in interrupt context
  3. zsmalloc: add page table mapping method
  4. zsmalloc: collapse internal .h into .c
  5. zsmalloc: promote to mm/

Minchan Kim (2):
  6. zram: promote zram from staging
  7. zram: select ZSMALLOC when ZRAM is configured

 drivers/block/Kconfig                              |    1 +
 drivers/block/Makefile                             |    1 +
 drivers/{staging => block}/zram/Kconfig            |    3 +-
 drivers/{staging => block}/zram/Makefile           |    0
 drivers/{staging => block}/zram/zram.txt           |    0
 drivers/{staging => block}/zram/zram_drv.c         |    0
 drivers/{staging => block}/zram/zram_drv.h         |    3 +-
 drivers/{staging => block}/zram/zram_sysfs.c       |    0
 drivers/staging/Kconfig                            |    4 -
 drivers/staging/Makefile                           |    2 -
 drivers/staging/zcache/zcache-main.c               |    4 +-
 drivers/staging/zsmalloc/Kconfig                   |   10 -
 drivers/staging/zsmalloc/Makefile                  |    3 -
 drivers/staging/zsmalloc/zsmalloc_int.h            |  155 ----------
 .../staging/zsmalloc => include/linux}/zsmalloc.h  |    0
 mm/Kconfig                                         |   18 ++
 mm/Makefile                                        |    1 +
 .../zsmalloc/zsmalloc-main.c => mm/zsmalloc.c      |  323 +++++++++++++++++---
 18 files changed, 299 insertions(+), 229 deletions(-)
 rename drivers/{staging => block}/zram/Kconfig (94%)
 rename drivers/{staging => block}/zram/Makefile (100%)
 rename drivers/{staging => block}/zram/zram.txt (100%)
 rename drivers/{staging => block}/zram/zram_drv.c (100%)
 rename drivers/{staging => block}/zram/zram_drv.h (98%)
 rename drivers/{staging => block}/zram/zram_sysfs.c (100%)
 delete mode 100644 drivers/staging/zsmalloc/Kconfig
 delete mode 100644 drivers/staging/zsmalloc/Makefile
 delete mode 100644 drivers/staging/zsmalloc/zsmalloc_int.h
 rename {drivers/staging/zsmalloc => include/linux}/zsmalloc.h (100%)
 rename drivers/staging/zsmalloc/zsmalloc-main.c => mm/zsmalloc.c (73%)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
