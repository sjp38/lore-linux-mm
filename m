Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0D1926B025F
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 12:07:52 -0400 (EDT)
Received: by mail-wm0-f51.google.com with SMTP id u206so111071594wme.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 09:07:51 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id j142si14440047wmg.70.2016.04.11.09.07.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 09:07:50 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id y144so22233356wmd.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 09:07:50 -0700 (PDT)
Date: Mon, 11 Apr 2016 18:07:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH] mm: use compaction feedback for thp backoff conditions
Message-ID: <20160411160748.GO23157@dhcp22.suse.cz>
References: <1459855533-4600-1-git-send-email-mhocko@kernel.org>
 <1459855533-4600-10-git-send-email-mhocko@kernel.org>
 <20160411154036.GN23157@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160411154036.GN23157@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>

On Mon 11-04-16 17:40:36, Michal Hocko wrote:
> Hi Andrew,
> Vlastimil has pointed out[1] that using compaction_withdrawn() for THP
> allocations has some non-trivial consequences. While I still think that
> the check is OK it is true we shouldn't sneak in a potential behavior
> change into something that basically provides an API. So can you fold
> the following partial revert into the original patch please?
> 
> [1] http://lkml.kernel.org/r/570BB719.2030007@suse.cz

This would be an RFC on top.
---
