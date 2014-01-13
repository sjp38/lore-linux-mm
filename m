Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f178.google.com (mail-ea0-f178.google.com [209.85.215.178])
	by kanga.kvack.org (Postfix) with ESMTP id 52BEF6B0037
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 06:38:00 -0500 (EST)
Received: by mail-ea0-f178.google.com with SMTP id d10so3221160eaj.37
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 03:37:59 -0800 (PST)
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com. [195.75.94.106])
        by mx.google.com with ESMTPS id y48si28177584eew.121.2014.01.13.03.37.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 13 Jan 2014 03:37:59 -0800 (PST)
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <phacht@linux.vnet.ibm.com>;
	Mon, 13 Jan 2014 11:37:58 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id B12282190063
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 11:37:38 +0000 (GMT)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0DBbR0Y64290884
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 11:37:27 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0DBbbPI014551
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 04:37:39 -0700
From: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Subject: [PATCH 0/2] mm/memblock: Excluded memory, free_all_bootmem
Date: Mon, 13 Jan 2014 12:37:12 +0100
Message-Id: <1389613034-35196-1-git-send-email-phacht@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, qiuxishi@huawei.com, dhowells@redhat.com, daeseok.youn@gmail.com, liuj97@gmail.com, yinghai@kernel.org, phacht@linux.vnet.ibm.com, zhangyanfei@cn.fujitsu.com, santosh.shilimkar@ti.com, grygorii.strashko@ti.com, tangchen@cn.fujitsu.com, schwidefsky@de.ibm.com

These two patches fit (only) on top of linux-next!

The first patch changes back the behavior of free_all_bootmem() to
a more generic way: With CONFIG_DISCARD_MEMBLOCK memblock.memory
and memblock.reserved will be freed (if allocated, of course).
Removed the debugfs dependency. Think this is cleaner.

While further working on the s390 migration to memblock it is desirable
to have memblock support unmapped (i.e. completely forgotten and unused)
memory areas. The usual way of just forgetting about them by means of
truncating the memblocks does not work for us because we still need the
information about the real full memory structure at a later time.


Philipp Hachtmann (2):
  mm/nobootmem: free_all_bootmem again
  mm/memblock: Add support for excluded memory areas

 include/linux/memblock.h |  50 ++++++--
 mm/memblock.c            | 324 +++++++++++++++++++++++++++++++----------------
 mm/nobootmem.c           |  13 +-
 3 files changed, 271 insertions(+), 116 deletions(-)

-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
