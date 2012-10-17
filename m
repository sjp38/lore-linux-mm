Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 40ADD6B002B
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 08:03:19 -0400 (EDT)
From: wency@cn.fujitsu.com
Subject: [PATCH v2 0/5] bugfix for memory hotplug
Date: Wed, 17 Oct 2012 20:08:50 +0800
Message-Id: <1350475735-26136-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, Wen Congyang <wency@cn.fujitsu.com>

From: Wen Congyang <wency@cn.fujitsu.com>

Wen Congyang (5):
  memory-hotplug: skip HWPoisoned page when offlining pages
  memory-hotplug: update mce_bad_pages when removing the memory
  memory-hotplug: auto offline page_cgroup when onlining memory block
    failed
  memory-hotplug: fix NR_FREE_PAGES mismatch
  memory-hotplug: allocate zone's pcp before onlining pages

 include/linux/page-isolation.h |   10 ++++++----
 mm/memory-failure.c            |    2 +-
 mm/memory_hotplug.c            |   14 ++++++++------
 mm/page_alloc.c                |   37 ++++++++++++++++++++++++++++---------
 mm/page_cgroup.c               |    3 +++
 mm/page_isolation.c            |   27 ++++++++++++++++++++-------
 mm/sparse.c                    |   21 +++++++++++++++++++++
 7 files changed, 87 insertions(+), 27 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
