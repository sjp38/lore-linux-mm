Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E4E706B0292
	for <linux-mm@kvack.org>; Sat, 24 Jun 2017 22:53:15 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id m188so62291645pgm.2
        for <linux-mm@kvack.org>; Sat, 24 Jun 2017 19:53:15 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id u127si6200401pgb.535.2017.06.24.19.53.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Jun 2017 19:53:15 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id d5so13282671pfe.1
        for <linux-mm@kvack.org>; Sat, 24 Jun 2017 19:53:14 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [RFC PATCH 0/4] mm/hotplug: make hotplug memory_block alligned
Date: Sun, 25 Jun 2017 10:52:23 +0800
Message-Id: <20170625025227.45665-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, linux-mm@kvack.org
Cc: Wei Yang <richard.weiyang@gmail.com>

Michal & all

Previously we found the hotplug range is mem_section aligned instead of
memory_block.

Here is several draft patches to fix that. To make sure I am getting your
point correctly, I post it here before further investigation.

Willing to see your comments. :-)

Wei Yang (4):
  mm/hotplug: aligne the hotplugable range with memory_block
  mm/hotplug: walk_memroy_range on memory_block uit
  mm/hotplug: make __add_pages() iterate on memory_block and split
    __add_section()
  base/memory: pass start_section_nr to init_memory_block()

 drivers/base/memory.c  | 34 ++++++++++++----------------------
 include/linux/memory.h |  4 +++-
 mm/memory_hotplug.c    | 48 +++++++++++++++++++++++++-----------------------
 3 files changed, 40 insertions(+), 46 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
