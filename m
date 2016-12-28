Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5B5A96B0069
	for <linux-mm@kvack.org>; Wed, 28 Dec 2016 10:30:41 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id xr1so90398196wjb.7
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 07:30:41 -0800 (PST)
Received: from mail-wj0-f193.google.com (mail-wj0-f193.google.com. [209.85.210.193])
        by mx.google.com with ESMTPS id q185si50693441wmb.94.2016.12.28.07.30.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Dec 2016 07:30:39 -0800 (PST)
Received: by mail-wj0-f193.google.com with SMTP id j10so54868422wjb.3
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 07:30:39 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/7] vm, vmscan: enahance vmscan tracepoints
Date: Wed, 28 Dec 2016 16:30:25 +0100
Message-Id: <20161228153032.10821-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

Hi,
while debugging [1] I've realized that there is some room for
improvements in the tracepoints set we offer currently. I had hard times
to make any conclusion from the existing ones. The resulting problem
turned out to be active list aging [2] and we are missing at least two
tracepoints to debug such a problem.

Some existing tracepoints could export more information to see _why_ the
reclaim progress cannot be made not only _how much_ we could reclaim.
The later could be seen quite reasonably from the vmstat counters
already. It can be argued that we are showing too many implementation
details in those tracepoints but I consider them way too lowlevel
already to be usable by any kernel independent userspace. I would be
_really_ surprised if anything but debugging tools have used them.

Any feedback is highly appreciated.

[1] http://lkml.kernel.org/r/20161215225702.GA27944@boerne.fritz.box
[2] http://lkml.kernel.org/r/20161223105157.GB23109@dhcp22.suse.cz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
