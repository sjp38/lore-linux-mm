Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 1F9CD6B0002
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 09:01:43 -0400 (EDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sat, 13 Apr 2013 22:59:29 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id B2D502CE8052
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 23:01:38 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3DCm6ts7536688
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 22:48:06 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3DD1auW019164
	for <linux-mm@kvack.org>; Sat, 13 Apr 2013 23:01:37 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH PART3 v4 0/6] staging: zcache/ramster: fix and ramster/debugfs improvement
Date: Sat, 13 Apr 2013 21:01:26 +0800
Message-Id: <1365858092-21920-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

Changelog: 
 v3 -> v4:
  * fix compile issue 
 v2 -> v3:
  * update patch description of staging: ramster: Move debugfs code out of ramster.c file 
  * update patch title of staging: ramster/debug: Add RAMSTER_DEBUG Kconfig entry 
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
	
Wanpeng Li (5):
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
 drivers/staging/zcache/ramster/debug.h   |  145 +++++++++++++++++
 drivers/staging/zcache/ramster/ramster.c |  147 +++--------------
 7 files changed, 574 insertions(+), 145 deletions(-)
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
