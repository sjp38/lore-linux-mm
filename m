Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 57DFD6B0260
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 09:09:29 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p41so73364287lfi.0
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 06:09:29 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id m194si633076wmb.2.2016.07.15.06.09.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jul 2016 06:09:26 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 4CFEB1C26B1
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 14:09:26 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 0/5] Follow-up fixes to node-lru series v2
Date: Fri, 15 Jul 2016 14:09:20 +0100
Message-Id: <1468588165-12461-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

This is another round of fixups to the node-lru series. The most
important patch is the last one which prevents a warning in memcg
from being triggered.

 include/linux/memcontrol.h |  2 +-
 include/linux/mm_inline.h  |  5 ++---
 mm/memcontrol.c            |  5 +----
 mm/page_alloc.c            |  6 +++---
 mm/swap.c                  | 20 ++++++++++----------
 mm/vmscan.c                | 43 +++++++++++++++++++++++++++++++++++--------
 6 files changed, 52 insertions(+), 29 deletions(-)

-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
