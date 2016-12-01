Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2F1EA28025A
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 10:25:27 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id s63so57513227wms.7
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 07:25:27 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id ya10si640809wjb.40.2016.12.01.07.25.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 07:25:26 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id u144so34653778wmu.0
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 07:25:25 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/2] GFP_NOFAIL cleanups
Date: Thu,  1 Dec 2016 16:25:15 +0100
Message-Id: <20161201152517.27698-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi,
I have posted this as an RFC previously [1] as there was no fundamental
disagreement I would like to ask for inclusion.

Tetsuo has noticed [2] that recent changes have changed GFP_NOFAIL
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

[1] http://lkml.kernel.org/r/20161123064925.9716-1-mhocko@kernel.org
[2] http://lkml.kernel.org/r/1479387004-5998-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
