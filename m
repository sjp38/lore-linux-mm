Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id EEABD6B0006
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 07:19:08 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id n8-v6so1014689wmh.0
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 04:19:08 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q18-v6sor3730839wre.70.2018.06.22.04.19.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Jun 2018 04:19:07 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [PATCH v2 0/4] Small cleanup for memoryhotplug
Date: Fri, 22 Jun 2018 13:18:35 +0200
Message-Id: <20180622111839.10071-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, pasha.tatashin@oracle.com, Jonathan.Cameron@huawei.com, arbab@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

Hi,

I this is a small cleanup for the memhotplug's code.
A lot more could be done, but it is better to start somewhere.
I tried to unify/remove duplicated code.

The following is what this patchset does:

1) add_memory_resource() has code to allocate a node in case it was offline.
   Since try_online_node has some code for that as well, I just made add_memory_resource() to
   use that so we can remove duplicated code..
   This is better explained in patch 1/4.

2) register_mem_sect_under_node() will be called only from link_mem_sections()

3) Make register_mem_sect_under_node() a callback of walk_memory_range()

4) Drop unnecessary checks from register_mem_sect_under_node()

I have done some tests and I could not see anything broken because of
this patchset.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
Tested-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>

Changes since v1:
- Address issues/suggestions in the provided feedback (Pavel Tatashin)
- Rebased

Oscar Salvador (4):
  mm/memory_hotplug: Make add_memory_resource use __try_online_node
  mm/memory_hotplug: Call register_mem_sect_under_node
  mm/memory_hotplug: Make register_mem_sect_under_node a cb of
    walk_memory_range
  mm/memory_hotplug: Drop unnecessary checks from
    register_mem_sect_under_node

 drivers/base/memory.c |  2 --
 drivers/base/node.c   | 49 ++++----------------------
 include/linux/node.h  | 12 ++++---
 mm/memory_hotplug.c   | 96 +++++++++++++++++++++++++--------------------------
 4 files changed, 60 insertions(+), 99 deletions(-)

-- 
2.13.6
