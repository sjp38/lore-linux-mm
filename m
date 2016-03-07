Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id CADE46B0253
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 11:08:43 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id p65so114648443wmp.1
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 08:08:43 -0800 (PST)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id e129si15042961wmd.1.2016.03.07.08.08.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Mar 2016 08:08:41 -0800 (PST)
Received: by mail-wm0-f66.google.com with SMTP id l68so11582140wml.3
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 08:08:41 -0800 (PST)
Date: Mon, 7 Mar 2016 17:08:38 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm, oom: protect !costly allocations some more (was: Re:
 [PATCH 0/3] OOM detection rework v4)
Message-ID: <20160307160838.GB5028@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160225092315.GD17573@dhcp22.suse.cz>
 <20160229210213.GX16930@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160229210213.GX16930@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <js1304@gmail.com>, Vlastimil Babka <vbabka@suse.cz>

On Mon 29-02-16 22:02:13, Michal Hocko wrote:
> Andrew,
> could you queue this one as well, please? This is more a band aid than a
> real solution which I will be working on as soon as I am able to
> reproduce the issue but the patch should help to some degree at least.

Joonsoo wasn't very happy about this approach so let me try a different
way. What do you think about the following? Hugh, Sergey does it help
for your load? I have tested it with the Hugh's load and there was no
major difference from the previous testing so at least nothing has blown
up as I am not able to reproduce the issue here.

Other changes in the compaction are still needed but I would like to not
depend on them right now.
---
