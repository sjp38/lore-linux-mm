Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D80186B03C2
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 10:11:33 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id w67so6354668wmd.3
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 07:11:33 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id u39si2807054wrc.200.2017.02.28.07.11.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 07:11:32 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id u63so2881761wmu.2
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 07:11:32 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH stable-4.9 0/2] mm: follow up oom fixes for 32b
Date: Tue, 28 Feb 2017 16:11:06 +0100
Message-Id: <20170228151108.20853-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable tree <stable@vger.kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Johannes Weiner <hannes@cmpxchg.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, Trevor Cordes <trevor@tecnopolis.ca>

Hi,
later in the 4.10 release cycle it turned out that b4536f0c829c ("mm,
memcg: fix the active list aging for lowmem requests when memcg is
enabled") was not sufficient to fully close the regression introduced by
f8d1a31163fc ("mm: consider whether to decivate based on eligible zones
inactive ratio") [1]. mmotm tree behaved properly and it turned out the
Linus tree was missing 71ab6cfe88dc ("mm, vmscan: consider eligible
zones in get_scan_count") merged in 4.11 merge window. The patch heavily
depends on 4a9494a3d827 ("mm, vmscan: cleanup lru size claculations")
which has been backported as well (patch 1).

Please add these two to 4.9+ trees (they should apply to 4.10 as they
are).  4.8 tree will need them as well but I do not see this stable tree
being maintained.

[1] http://lkml.kernel.org/r/20170201032928.5d58a7c5@pog.tecnopolis.ca

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
