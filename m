Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3E5B26B000C
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 09:27:47 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id v2-v6so3640310wrr.10
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 06:27:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c3-v6sor2825220wrn.20.2018.07.19.06.27.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Jul 2018 06:27:46 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [PATCH v2 0/5] Refactor free_area_init_node/free_area_init_core
Date: Thu, 19 Jul 2018 15:27:35 +0200
Message-Id: <20180719132740.32743-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: pasha.tatashin@oracle.com, mhocko@suse.com, vbabka@suse.cz, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

This patchset pretends to make free_area_init_core more readable by
moving the ifdefery to inline functions, and while we are at it,
it optimizes the function a little bit (better explained in patch 3).

Oscar Salvador (4):
  mm/page_alloc: Move ifdefery out of free_area_init_core
  mm/page_alloc: Optimize free_area_init_core
  mm/page_alloc: Inline function to handle
    CONFIG_DEFERRED_STRUCT_PAGE_INIT
  mm/page_alloc: Only call pgdat_set_deferred_range when the system
    boots

Pavel Tatashin (1):
  mm: access zone->node via zone_to_nid() and zone_set_nid()

 include/linux/mm.h     |   9 ---
 include/linux/mmzone.h |  26 ++++++--
 mm/mempolicy.c         |   4 +-
 mm/mm_init.c           |   9 +--
 mm/page_alloc.c        | 159 +++++++++++++++++++++++++++++--------------------
 5 files changed, 120 insertions(+), 87 deletions(-)

-- 
2.13.6
