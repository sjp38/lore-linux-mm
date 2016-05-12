Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3100F6B0005
	for <linux-mm@kvack.org>; Thu, 12 May 2016 07:14:43 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id tb5so10617752lbb.3
        for <linux-mm@kvack.org>; Thu, 12 May 2016 04:14:43 -0700 (PDT)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id u64si16137507wmd.74.2016.05.12.04.14.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 May 2016 04:14:42 -0700 (PDT)
Received: by mail-wm0-f47.google.com with SMTP id n129so254812660wmn.1
        for <linux-mm@kvack.org>; Thu, 12 May 2016 04:14:41 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/2] oom detection fixups
Date: Thu, 12 May 2016 13:14:35 +0200
Message-Id: <1463051677-29418-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi Andrew,
these two patches are follow-up fixups for the oom detection rework.
The first patch should be folded into mm-oom-rework-oom-detection.patch.
I haven't noticed classzone_idx vs high_zoneidx only when working on
the second patch which is a fix for !CONFIG_COMPACTION where Joonsoo
reported a premature OOM killer. I didn't pay attention to this
configuration before but I have tested a heavy fork load on a small
machine and the patch helps as it restores the original behavior more or
less for !costly high order requests.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
