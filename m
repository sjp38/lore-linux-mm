Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1C14A6B0005
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 18:01:53 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id p3-v6so3640856wmc.7
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 15:01:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l14-v6sor1104119wrw.79.2018.07.25.15.01.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Jul 2018 15:01:51 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [PATCH v3 0/5] Refactor free_area_init_core and add free_area_init_core_hotplug
Date: Thu, 26 Jul 2018 00:01:39 +0200
Message-Id: <20180725220144.11531-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, pasha.tatashin@oracle.com, mgorman@techsingularity.net, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.j.williams@intel.com, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

This patchset does three things:

 1) Clean ups/refactor free_area_init_core/free_area_init_node
    by moving the ifdefery out of the functions.
 2) Move the pgdat/zone initialization in free_area_init_core to its
    own function.
 3) Introduce free_area_init_core_hotplug, a small subset of free_area_init_core,
    which is only called from memhotlug code path.
    In this way, we have:

    free_area_init_core: called during early initialization
    free_area_init_core_hotplug: called whenever a new node was allocated (memhotplug path)

Oscar Salvador (4):
  mm/page_alloc: Move ifdefery out of free_area_init_core
  mm/page_alloc: Inline function to handle
    CONFIG_DEFERRED_STRUCT_PAGE_INIT
  mm/page_alloc: Move initialization of node and zones to an own
    function
  mm/page_alloc: Introduce memhotplug version of free_area_init_core

Pavel Tatashin (1):
  mm: access zone->node via zone_to_nid() and zone_set_nid()

 include/linux/mm.h     |  10 +---
 include/linux/mmzone.h |  26 +++++++---
 mm/memory_hotplug.c    |  23 ++++-----
 mm/mempolicy.c         |   4 +-
 mm/mm_init.c           |   9 +---
 mm/page_alloc.c        | 132 +++++++++++++++++++++++++++++++++++--------------
 6 files changed, 129 insertions(+), 75 deletions(-)

-- 
2.13.6
