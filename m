Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id DC97A6B0292
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 03:35:20 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 21so756498wmt.15
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 00:35:20 -0700 (PDT)
Received: from mail-wr0-f196.google.com (mail-wr0-f196.google.com. [209.85.128.196])
        by mx.google.com with ESMTPS id 62si509476wmc.60.2017.06.29.00.35.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 00:35:19 -0700 (PDT)
Received: by mail-wr0-f196.google.com with SMTP id x23so36072663wrb.0
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 00:35:19 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 0/2] mm, memory_hotplug: remove zone onlining restriction
Date: Thu, 29 Jun 2017 09:35:07 +0200
Message-Id: <20170629073509.623-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Wei Yang <richard.weiyang@gmail.com>, LKML <linux-kernel@vger.kernel.org>

Hi,
I am sending this as an RFC because this hasn't seen a lot of testing
yet but I would like to see whether the semantic I came up with (see
patch 2) is sensible. This work should help Joonsoo with his CMA zone
based approach when reusing MOVABLE zone. I think it will also help to
remove more code from the memory hotplug (e.g. zone shrinking).

Patch 1 restores original memoryXY/valid_zones semantic wrt zone
ordering. This can be merged without patch 2 which removes the zone
overlap restriction and defines a semantic for the default onlining. See
more in the patch.

Questions, concerns, objections?

Shortlog
Michal Hocko (2):
      mm, memory_hotplug: display allowed zones in the preferred ordering
      mm, memory_hotplug: remove zone restrictions

Diffstat
 drivers/base/memory.c          | 30 ++++++++++-----
 include/linux/memory_hotplug.h |  2 +-
 mm/memory_hotplug.c            | 87 +++++++++++++++++-------------------------
 3 files changed, 55 insertions(+), 64 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
