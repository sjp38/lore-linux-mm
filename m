Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 953906B0002
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 23:49:53 -0400 (EDT)
Received: by mail-da0-f50.google.com with SMTP id t1so1330746dae.37
        for <linux-mm@kvack.org>; Mon, 01 Apr 2013 20:49:52 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH 0/2] mm: swap: zswap/zcache writeback supporting
Date: Tue,  2 Apr 2013 11:49:46 +0800
Message-Id: <1364874586-833-1-git-send-email-bob.liu@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, minchan@kernel.org, sjenning@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com, ngupta@vflare.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, Bob Liu <bob.liu@oracle.com>

Hi Andrew,

Would you please consider to merge these patches.
It's from Seth Jennings and the original goal was supporting writeback a page
from frontswap backend to the swap device, so that pages can be evicted.

Now this identical patch is needed for zcache, the dependent code is
already in 3.9(marked as broken,see config ZCACHE_WRITEBACK in
drivers/staging/zcache).
So it would be nice to get this small mm changes to be merged in 3.10.

The original post from Seth:
https://lkml.org/lkml/2013/3/6/344
https://lkml.org/lkml/2013/3/6/392

I rebased them to mmotm-2013-03-26-15-09 plus fixing a small issue from
chechpatch.pl
WARNING: externs should be avoided in .c files
#56: FILE: mm/page_io.c:182:
+int __swap_writepage(struct page *page, struct writeback_control *wbc);

Seth Jennings (2):
  mm: break up swap_writepage() for frontswap backends
  mm: allow for outstanding swap writeback accounting

 include/linux/swap.h |    4 ++++
 mm/page_io.c         |   22 +++++++++++++++++-----
 mm/swap_state.c      |    2 +-
 3 files changed, 22 insertions(+), 6 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
