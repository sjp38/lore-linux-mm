Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id F10FD6B0007
	for <linux-mm@kvack.org>; Mon, 28 May 2018 04:13:53 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id t195-v6so8067021wmt.9
        for <linux-mm@kvack.org>; Mon, 28 May 2018 01:13:53 -0700 (PDT)
Received: from techadventures.net (techadventures.net. [62.201.165.239])
        by mx.google.com with ESMTP id i17-v6si9586260wmc.190.2018.05.28.01.13.52
        for <linux-mm@kvack.org>;
        Mon, 28 May 2018 01:13:52 -0700 (PDT)
Date: Mon, 28 May 2018 10:13:52 +0200
From: osalvador@techadventures.net
Subject: [RFC PATCH 0/3] Small cleanup for hotplugmem
Message-ID: <20180528081352.GA14293@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, pasha.tatashin@oracle.com, akpm@linux-foundation.org

From: Oscar Salvador <osalvador@suse.de>

Hi guys,

I wanted to give it a chance a do a small cleanup in the hotplug memory code.
A lot more could be done, but I wanted to start somewhere.
I tried to unify/remove duplicated code.

Here I have just done three things

1) add_memory_resource() had code to allocate a node in case it was offline.
   Since try_online_node already does that, I just made add_memory_resource() to
   use that function.
   This is better explained in patch 1/3.

2) register_mem_sect_under_node() will be called only from link_mem_sections

3) Get rid of link_mem_sections() in favour of walk_memory_range with a callback to
   register_mem_sect_under_node()

I am posting this as a RFC because I could not see that these patches break anything,
but expert eyes might see something that I am missing here.

Oscar Salvador (3):
  mm/memory_hotplug: Make add_memory_resource use __try_online_node
  mm/memory_hotplug: Call register_mem_sect_under_node
  mm/memory_hotplug: Get rid of link_mem_sections

 drivers/base/memory.c |   2 -
 drivers/base/node.c   |  47 +++++------------------
 include/linux/node.h  |  21 +++++------
 mm/memory_hotplug.c   | 101 ++++++++++++++++++++++++++------------------------
 4 files changed, 71 insertions(+), 100 deletions(-)

Signed-off-by: Oscar Salvador <osalvador@suse.de>

-- 
2.13.6
