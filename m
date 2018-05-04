Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 58D7A6B000C
	for <linux-mm@kvack.org>; Fri,  4 May 2018 02:40:48 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id c10-v6so19261317iob.11
        for <linux-mm@kvack.org>; Thu, 03 May 2018 23:40:48 -0700 (PDT)
Received: from dev31.localdomain ([103.244.59.4])
        by mx.google.com with ESMTP id v3-v6si12958713ioe.281.2018.05.03.23.40.47
        for <linux-mm@kvack.org>;
        Thu, 03 May 2018 23:40:47 -0700 (PDT)
From: Huaisheng Ye <yehs1@lenovo.com>
Subject: [PATCH 0/3] Some fixes for mm code optimization
Date: Fri,  4 May 2018 14:52:06 +0800
Message-Id: <1525416729-108201-1-git-send-email-yehs1@lenovo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, pasha.tatashin@oracle.com, alexander.levin@verizon.com, hannes@cmpxchg.org, penguin-kernel@I-love.SAKURA.ne.jp, colyli@suse.de, chengnt@lenovo.com, linux-kernel@vger.kernel.org, Huaisheng Ye <yehs1@lenovo.com>

These patches try to optimize existing code of mm.

First patch, removes the useless parameter order of function
finalise_ac. This function is just used by __alloc_pages_nodemask
in mm/page_alloc.c.

Second patch, modifies the local variable bit's type to unsigned int
in function gfp_zone.

Third patch, fixes a typo in debug message to avoid confusion.

All patches have been tested on Lenovo Purley product.


Huaisheng Ye (3):
  mm/page_alloc: Remove useless parameter of finalise_ac
  include/linux/gfp.h: use unsigned int in gfp_zone
  mm/page_alloc: Fix typo in debug info of calculate_node_totalpages

 include/linux/gfp.h | 2 +-
 mm/page_alloc.c     | 7 +++----
 2 files changed, 4 insertions(+), 5 deletions(-)

-- 
1.8.3.1
