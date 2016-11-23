Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 62B386B0261
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 01:49:36 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id w13so2570526wmw.0
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 22:49:36 -0800 (PST)
Received: from mail-wj0-f193.google.com (mail-wj0-f193.google.com. [209.85.210.193])
        by mx.google.com with ESMTPS id k5si29745696wjo.179.2016.11.22.22.49.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 22:49:35 -0800 (PST)
Received: by mail-wj0-f193.google.com with SMTP id jb2so310893wjb.3
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 22:49:35 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC 0/2] GFP_NOFAIL cleanups
Date: Wed, 23 Nov 2016 07:49:23 +0100
Message-Id: <20161123064925.9716-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hi,
Tetsuo has noticed [1] that recent changes have changed GFP_NOFAIL
semantic for costly order requests. I believe that the primary reason
why this happened is that our GFP_NOFAIL checks are too scattered
and it is really easy to forget about adding one. That's why I am
proposing patch 1 which consolidates all the nofail handling at a single
place. This should help to make this code better maintainable.

Patch 2 on top is a further attempt to make GFP_NOFAIL semantic less
surprising. As things stand currently GFP_NOFAIL overrides the oom killer
prevention code which is both subtle and not really needed. The patch 2
has more details about issues this might cause.

I would consider both patches more a cleanup than anything else. Any
feedback is highly appreciated.

[1] http://lkml.kernel.org/r/1479387004-5998-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
