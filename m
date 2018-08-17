Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D13666B0773
	for <linux-mm@kvack.org>; Fri, 17 Aug 2018 05:04:23 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id s18-v6so4173439wmc.5
        for <linux-mm@kvack.org>; Fri, 17 Aug 2018 02:04:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 110-v6sor9484wra.5.2018.08.17.02.00.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 Aug 2018 02:00:22 -0700 (PDT)
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [PATCH v4 0/4] Refactoring for remove_memory_section/unregister_mem_sect_under_nodes
Date: Fri, 17 Aug 2018 11:00:13 +0200
Message-Id: <20180817090017.17610-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, dan.j.williams@intel.com, yasu.isimatu@gmail.com, jonathan.cameron@huawei.com, david@redhat.com, Pavel.Tatashin@microsoft.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

v3 -> v4:
        - Make nodemask_t a stack variable
        - Added Reviewed-by from David and Pavel

v2 -> v3:
        - NODEMASK_FREE can deal with NULL pointers, so do not
          make it conditional (by David).
        - Split up node_online's check patch (David's suggestion)
        - Added Reviewed-by from Andrew and David
        - Fix checkpath.pl warnings

This patchset does some cleanups and refactoring in the memory-hotplug code.

The first and the second patch are pretty straightforward, as they
only remove unused arguments/checks.

The third patch refactors unregister_mem_sect_under_nodes a bit by re-defining
nodemask_t as a stack variable. (More details in Patch3's changelog)

The fourth patch removes a node_online check. (More details in Patch4's changelog)
Since this change has a patch for itself, we could quickly revert it
if we notice that something is wrong with it, or drop it if people
are concerned about it.

Oscar Salvador (4):
  mm/memory-hotplug: Drop unused args from remove_memory_section
  mm/memory_hotplug: Drop mem_blk check from
    unregister_mem_sect_under_nodes
  mm/memory_hotplug: Define nodemask_t as a stack variable
  mm/memory_hotplug: Drop node_online check in
    unregister_mem_sect_under_nodes

 drivers/base/memory.c |  5 ++---
 drivers/base/node.c   | 22 ++++++----------------
 include/linux/node.h  |  5 ++---
 3 files changed, 10 insertions(+), 22 deletions(-)

-- 
2.13.6
