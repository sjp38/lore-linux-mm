Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 127FF6B0261
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 05:19:52 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u144so83063426wmu.1
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 02:19:52 -0800 (PST)
Received: from mail-wj0-f194.google.com (mail-wj0-f194.google.com. [209.85.210.194])
        by mx.google.com with ESMTPS id r129si77277364wmr.61.2017.01.04.02.19.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jan 2017 02:19:50 -0800 (PST)
Received: by mail-wj0-f194.google.com with SMTP id hb5so41766166wjc.2
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 02:19:50 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/7 v2] vm, vmscan: enahance vmscan tracepoints
Date: Wed,  4 Jan 2017 11:19:35 +0100
Message-Id: <20170104101942.4860-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi,
this is the second version of the patchset [1]. I hope I've addressed all
the review feedback.

While debugging [2] I've realized that there is some room for
improvements in the tracepoints set we offer currently. I had hard times
to make any conclusion from the existing ones. The resulting problem
turned out to be active list aging [3] and we are missing at least two
tracepoints to debug such a problem.

Some existing tracepoints could export more information to see _why_ the
reclaim progress cannot be made not only _how much_ we could reclaim.
The later could be seen quite reasonably from the vmstat counters
already. It can be argued that we are showing too many implementation
details in those tracepoints but I consider them way too lowlevel
already to be usable by any kernel independent userspace. I would be
_really_ surprised if anything but debugging tools have used them.

Any feedback is highly appreciated.

[1] http://lkml.kernel.org/r/20161228153032.10821-1-mhocko@kernel.org
[2] http://lkml.kernel.org/r/20161215225702.GA27944@boerne.fritz.box
[3] http://lkml.kernel.org/r/20161223105157.GB23109@dhcp22.suse.cz


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
