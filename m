Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9161D6B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 19:22:47 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id he10so1372583wjc.6
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 16:22:47 -0800 (PST)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id d18si532784wmd.16.2016.12.01.16.22.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Dec 2016 16:22:45 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id E4E4998B69
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 00:22:44 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 0/2] High-order per-cpu cache v5
Date: Fri,  2 Dec 2016 00:22:42 +0000
Message-Id: <20161202002244.18453-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

The following is two patches that implement a per-cpu cache for high-order
allocations, primarily aimed at SLUB. The first patch is a bug fix that
is technically unrelated but was discovered by review and so batched
together. The second is the patch that implements the cache.

 include/linux/mmzone.h |  20 +++++++-
 mm/page_alloc.c        | 122 +++++++++++++++++++++++++++++++------------------
 2 files changed, 96 insertions(+), 46 deletions(-)

-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
