Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5691C6B0038
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 06:30:04 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id o3so44386405wjo.1
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 03:30:04 -0800 (PST)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id e27si2586678wmi.0.2016.12.02.03.30.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Dec 2016 03:30:02 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 66DF11C25AA
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 11:30:02 +0000 (GMT)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 0/2] High-order per-cpu cache v6
Date: Fri,  2 Dec 2016 11:29:49 +0000
Message-Id: <20161202112951.23346-1-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Changelog since v5
o Changelog clarification in patch 1
o Additional comments in patch 2

Changelog since v4
o Avoid pcp->count getting out of sync if struct page gets corrupted

Changelog since v3
o Allow high-order atomic allocations to use reserves

Changelog since v2
o Correct initialisation to avoid -Woverflow warning

The following is two patches that implement a per-cpu cache for high-order
allocations, primarily aimed at SLUB. The first patch is a bug fix that
is technically unrelated but was discovered by review and so batched
together. The second is the patch that implements the high-order pcpu cache.

 include/linux/mmzone.h |  20 +++++++-
 mm/page_alloc.c        | 129 ++++++++++++++++++++++++++++++++-----------------
 2 files changed, 103 insertions(+), 46 deletions(-)

-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
