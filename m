Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 55D416B0253
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 04:48:58 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id a4so19460045wme.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 01:48:58 -0800 (PST)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id 2si39590479wmr.64.2016.02.17.01.48.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 01:48:57 -0800 (PST)
Received: by mail-wm0-f47.google.com with SMTP id b205so147521233wmb.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 01:48:56 -0800 (PST)
Date: Wed, 17 Feb 2016 10:48:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 6/5] oom, oom_reaper: disable oom_reaper for
Message-ID: <20160217094855.GC29196@dhcp22.suse.cz>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
 <1454505240-23446-6-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1454505240-23446-6-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi Andrew,
although this can be folded into patch 5
(mm-oom_reaper-implement-oom-victims-queuing.patch) I think it would be
better to have it separate and revert after we sort out the proper
oom_kill_allocating_task behavior or handle exclusion at oom_reaper
level.

Thanks!
---
