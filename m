Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 2EF6F6B0006
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:31:40 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 12 Apr 2013 06:57:06 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id EDAB3E002D
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 07:03:23 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3C1VRki7012786
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 07:01:27 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3C1VW8n021446
	for <linux-mm@kvack.org>; Fri, 12 Apr 2013 11:31:32 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH PART2 v2 0/7] staging: zcache/ramster: fix and ramster/debugfs improvement
Date: Fri, 12 Apr 2013 09:31:20 +0800
Message-Id: <1365730287-16876-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Changelog: 
 v1 -> v2:  
 * fix bisect issue 
 * fix issue in patch staging: ramster: Provide accessory functions for counter decrease
 * drop patch staging: zcache: remove zcache_freeze 
 * Add Dan Acked-by

Fix bugs in zcache and rips out the debug counters out of ramster.c and 
sticks them in a debug.c file. Introduce accessory functions for counters 
increase/decrease, they are available when config RAMSTER_DEBUG, otherwise 
they are empty non-debug functions. Using an array to initialize/use debugfs 
attributes to make them neater. Dan Magenheimer confirm these works 
are needed. http://marc.info/?l=linux-mm&m=136535713106882&w=2

Patch 1~2 fix bugs in zcache

Patch 3~8 rips out the debug counters out of ramster.c and sticks them 
		  in a debug.c file 

Patch 9 fix coding style issue introduced in zcache2 cleanups 
        (s/int/bool + debugfs movement) patchset 

Patch 10 add how-to for ramster 

Dan Magenheimer (1):
	staging: ramster: add how-to for ramster
	
Wanpeng Li (6):
	staging: ramster: decrease foregin pers pages when count < 0
	staging: ramster: Move debugfs code out of ramster.c files
	staging: ramster/debug: Use an array to initialize/use debugfs attributes
	staging: ramster/debug: Add RAMSTER_DEBUG Kconfig entry
	staging: ramster: Add incremental accessory counters
	staging: zcache/debug: fix coding style

 drivers/staging/zcache/Kconfig           |    8 +
 drivers/staging/zcache/Makefile          |    1 +
 drivers/staging/zcache/debug.h           |   95 ++++++++---
 drivers/staging/zcache/ramster/HOWTO.txt |  257 ++++++++++++++++++++++++++++++
 drivers/staging/zcache/ramster/debug.c   |   66 ++++++++
 drivers/staging/zcache/ramster/debug.h   |  143 +++++++++++++++++
 drivers/staging/zcache/ramster/ramster.c |  148 +++--------------
 7 files changed, 573 insertions(+), 145 deletions(-)
 create mode 100644 drivers/staging/zcache/ramster/HOWTO.txt
 create mode 100644 drivers/staging/zcache/ramster/debug.c
 create mode 100644 drivers/staging/zcache/ramster/debug.h

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
