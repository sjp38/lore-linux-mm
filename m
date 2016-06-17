Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0325F6B025E
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 03:57:45 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a69so147568116pfa.1
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 00:57:44 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id a8si11078763pfj.35.2016.06.17.00.57.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 00:57:44 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id t190so5715842pfb.2
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 00:57:44 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v3 0/9] reduce memory usage by page_owner
Date: Fri, 17 Jun 2016 16:57:30 +0900
Message-Id: <1466150259-27727-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sasha Levin <sasha.levin@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Hello,

There was a bug reported by Sasha and minor fixes is needed
so I send v3.

o fix a bg reported by Sasha (mm/compaction: split freepages
without holding the zone lock)
o add code comment for todo list (mm/page_owner: use stackdepot
to store stacktrace) per Michal
o add 'inline' keyword (mm/page_alloc: introduce post allocation
processing on page allocator) per Vlastimil
o add a patch that clean-up code per Vlastimil

Joonsoo Kim (8):
  mm/compaction: split freepages without holding the zone lock
  mm/page_owner: initialize page owner without holding the zone lock
  mm/page_owner: copy last_migrate_reason in copy_page_owner()
  mm/page_owner: introduce split_page_owner and replace manual handling
  tools/vm/page_owner: increase temporary buffer size
  mm/page_owner: use stackdepot to store stacktrace
  mm/page_alloc: introduce post allocation processing on page allocator
  mm/page_isolation: clean up confused code

Sudip Mukherjee (1):
  mm/page_owner: avoid null pointer dereference

 include/linux/mm.h         |   1 -
 include/linux/page_ext.h   |   4 +-
 include/linux/page_owner.h |  12 ++--
 lib/Kconfig.debug          |   1 +
 mm/compaction.c            |  44 ++++++++----
 mm/internal.h              |   2 +
 mm/page_alloc.c            |  60 +++++------------
 mm/page_isolation.c        |  13 ++--
 mm/page_owner.c            | 163 +++++++++++++++++++++++++++++++++++++--------
 tools/vm/page_owner_sort.c |   9 ++-
 10 files changed, 205 insertions(+), 104 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
