Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 26E576B0005
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 08:47:53 -0400 (EDT)
Received: by mail-wm0-f49.google.com with SMTP id f198so30620000wme.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 05:47:53 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id a129si19051017wmf.119.2016.04.05.05.47.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 05:47:52 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id a140so3981586wma.2
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 05:47:52 -0700 (PDT)
Date: Tue, 5 Apr 2016 14:47:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 00/11] oom detection rework v5
Message-ID: <20160405124750.GC24035@dhcp22.suse.cz>
References: <1459855533-4600-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1459855533-4600-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

One side note. I have promissed to provide some tracepoints which would
help us to see how the new code behaves. I have some basics but still
have to think more about that so I will send some more patches later on.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
