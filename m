Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id 736FE6B0035
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 06:33:05 -0500 (EST)
Received: by mail-ee0-f44.google.com with SMTP id c13so3350039eek.31
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 03:33:04 -0800 (PST)
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com. [195.75.94.108])
        by mx.google.com with ESMTPS id e2si1743158eeg.198.2014.01.20.03.33.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 20 Jan 2014 03:33:04 -0800 (PST)
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <phacht@linux.vnet.ibm.com>;
	Mon, 20 Jan 2014 11:33:03 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 8896717D8059
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 11:33:15 +0000 (GMT)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0KBWmSa27132052
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 11:32:48 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0KBWrkk018377
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 04:32:59 -0700
From: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Subject: [PATCH V5 0/3] mm/memblock: Excluded memory
Date: Mon, 20 Jan 2014 12:32:36 +0100
Message-Id: <1390217559-14691-1-git-send-email-phacht@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, liuj97@gmail.com, santosh.shilimkar@ti.com, grygorii.strashko@ti.com, iamjoonsoo.kim@lge.com, robin.m.holt@gmail.com, tangchen@cn.fujitsu.com, yinghai@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Philipp Hachtmann <phacht@linux.vnet.ibm.com>

This all fits linux-next.

The first patch is a fix (not a replacement) to a patch that has already 
been put into linux-next. The original patch generates a warning for an
unused variable in case that CONFIG_ARCH_DISCARD_MEMBLOCK is not set.
It's now made the way Andrew suggested. 

The second patch adds support for exluded memory region handling in
memblock. This is needed by the current s390 development in conjunction
with kdump.
The patch is straightforward and adds some redundancy. This has been 
done to clarify that this patch does not intend to change any of
the current memblock API's behaviour.

The third patch does some cleanup and refactoring to memblock. It removes
the redundancies introduced by the patch before. It also is not intended
to change or break any behaviour or API of memblock.


Philipp Hachtmann (3):
  mm/nobootmem: Fix unused variable
  mm/memblock: Add support for excluded memory areas
  mm/memblock: Cleanup and refactoring after addition of nomap

 include/linux/memblock.h |  57 +++++++++---
 mm/Kconfig               |   3 +
 mm/memblock.c            | 233 +++++++++++++++++++++++++++++++++++------------
 mm/nobootmem.c           |  30 ++++--
 4 files changed, 243 insertions(+), 80 deletions(-)

-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
