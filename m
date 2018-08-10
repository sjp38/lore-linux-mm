Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5781E6B0003
	for <linux-mm@kvack.org>; Fri, 10 Aug 2018 11:29:37 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id d10-v6so7330571wrw.6
        for <linux-mm@kvack.org>; Fri, 10 Aug 2018 08:29:37 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c11-v6sor3977445wrp.19.2018.08.10.08.29.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 Aug 2018 08:29:35 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [PATCH 0/3] Refactor/cleanup for remove_memory_section/unregister_mem_sect_under_nodes
Date: Fri, 10 Aug 2018 17:29:28 +0200
Message-Id: <20180810152931.23004-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, dan.j.williams@intel.com, yasu.isimatu@gmail.com, jonathan.cameron@huawei.com, david@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

This patchset is about cleaning up/refactoring a few functions
from the memory-hotplug code.

The first and the second patch are pretty straightforward, as they
only remove unused arguments/checks.
The third one change the layout of the unregister_mem_sect_under_nodes a bit.

Oscar Salvador (3):
  mm/memory_hotplug: Drop unused args from remove_memory_section
  mm/memory_hotplug: Drop unneeded check from
    unregister_mem_sect_under_nodes
  mm/memory_hotplug: Cleanup unregister_mem_sect_under_nodes

 drivers/base/memory.c |  5 ++---
 drivers/base/node.c   | 34 +++++++++++-----------------------
 2 files changed, 13 insertions(+), 26 deletions(-)

-- 
2.13.6
