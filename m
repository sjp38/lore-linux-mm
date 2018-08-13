Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C9CEE6B0005
	for <linux-mm@kvack.org>; Mon, 13 Aug 2018 11:46:51 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id v24-v6so6347350wmh.5
        for <linux-mm@kvack.org>; Mon, 13 Aug 2018 08:46:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e17-v6sor6257161wri.46.2018.08.13.08.46.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 13 Aug 2018 08:46:50 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [PATCH v2 0/3] Refactoring for remove_memory_section/unregister_mem_sect_under_nodes
Date: Mon, 13 Aug 2018 17:46:36 +0200
Message-Id: <20180813154639.19454-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, jglisse@redhat.com, rafael@kernel.org, david@redhat.com, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, Jonathan.Cameron@huawei.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

This patchset does some cleanups and refactoring in the memory-hotplug code.

The first and the second patch are pretty straightforward, as they
only remove unused arguments/checks.

The third one refactors unregister_mem_sect_under_nodes.
This is needed to have a proper fallback in case we could not allocate
memory. (details can be seen in patch3).

Oscar Salvador (3):
  mm/memory-hotplug: Drop unused args from remove_memory_section
  mm/memory_hotplug: Drop mem_blk check from
    unregister_mem_sect_under_nodes
  mm/memory_hotplug: Refactor unregister_mem_sect_under_nodes

 drivers/base/memory.c |  5 ++---
 drivers/base/node.c   | 30 +++++++++++++++---------------
 include/linux/node.h  |  5 ++---
 3 files changed, 19 insertions(+), 21 deletions(-)

-- 
2.13.6
