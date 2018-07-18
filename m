Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id BBF516B000A
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 08:47:38 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id q24-v6so713176wmq.9
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 05:47:38 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o20-v6sor501232wmc.74.2018.07.18.05.47.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Jul 2018 05:47:37 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [PATCH 0/3] Re-structure free_area_init_node / free_area_init_core
Date: Wed, 18 Jul 2018 14:47:19 +0200
Message-Id: <20180718124722.9872-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: pasha.tatashin@oracle.com, mhocko@suse.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, aaron.lu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

When free_area_init_node()->free_area_init_core() get called
from memhotplug path, there are some things that we do need to run.

This patchset __pretends__ to make more clear what things get executed
when those two functions get called depending on the context (non-/memhotplug path).


I tested it on x86_64 / powerpc and I did not see anything wrong there.
But some feedback would be appreciated.

We might come up with the conclusion that we can live with the code as it is now.

Oscar Salvador (3):
  mm/page_alloc: Move ifdefery out of free_area_init_core
  mm/page_alloc: Refactor free_area_init_core
  mm/page_alloc: Split context in free_area_init_node

 mm/page_alloc.c | 181 +++++++++++++++++++++++++++++++++++---------------------
 1 file changed, 114 insertions(+), 67 deletions(-)

-- 
2.13.6
