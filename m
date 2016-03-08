Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 9B9F56B0253
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 08:42:50 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id l68so132175062wml.0
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 05:42:50 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id v68si4501847wmd.71.2016.03.08.05.42.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 05:42:49 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id n186so4162432wmn.0
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 05:42:49 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/2] oom rework: high order enahncements
Date: Tue,  8 Mar 2016 14:42:42 +0100
Message-Id: <1457444565-10524-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <20160307160838.GB5028@dhcp22.suse.cz>
References: <20160307160838.GB5028@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

The first two patches are cleanups for the compaction and the second
patch is updated as per Vlastimil's feedback. I didn't add his Acked-by
because I have added COMPACT_SHOULD_RETRY to make the retry logic in
the page allocator more robust for future changes.

Hugh has still reported this is not sufficient but I would prefer to
handle the issue he is seeing in a separate patch once we understand
what is going on there. The second patch sounds like a reasonable
starting point to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
