Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 220EA6B0005
	for <linux-mm@kvack.org>; Tue, 17 May 2016 16:01:35 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id s63so16576350wme.2
        for <linux-mm@kvack.org>; Tue, 17 May 2016 13:01:35 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id wa2si5604671wjc.62.2016.05.17.13.01.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 May 2016 13:01:34 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id n129so7492569wmn.1
        for <linux-mm@kvack.org>; Tue, 17 May 2016 13:01:33 -0700 (PDT)
Date: Tue, 17 May 2016 22:01:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 00/13] make direct compaction more deterministic
Message-ID: <20160517200131.GA12220@dhcp22.suse.cz>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

Btw. I think that first three patches are nice cleanups and easy enough
so I would vote for merging them earlier.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
