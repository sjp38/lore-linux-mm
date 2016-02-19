Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id CA1336B0005
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 13:34:22 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id c200so88818237wme.0
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 10:34:22 -0800 (PST)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id m3si14469347wmb.52.2016.02.19.10.34.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Feb 2016 10:34:21 -0800 (PST)
Received: by mail-wm0-f51.google.com with SMTP id g62so83263077wme.0
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 10:34:21 -0800 (PST)
Date: Fri, 19 Feb 2016 19:34:19 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 6/5] oom, oom_reaper: disable oom_reaper for
Message-ID: <20160219183419.GA30059@dhcp22.suse.cz>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
 <1454505240-23446-6-git-send-email-mhocko@kernel.org>
 <20160217094855.GC29196@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160217094855.GC29196@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 17-02-16 10:48:55, Michal Hocko wrote:
> Hi Andrew,
> although this can be folded into patch 5
> (mm-oom_reaper-implement-oom-victims-queuing.patch) I think it would be
> better to have it separate and revert after we sort out the proper
> oom_kill_allocating_task behavior or handle exclusion at oom_reaper
> level.

An alternative would be something like the following. It is definitely
less hackish but it steals one bit in mm->flags. We do not seem to be
in shortage there now but who knows. Does this sound better? Later
changes might even consider the flag for the victim selection and ignore
those which already have the flag set. But I didn't think about it more
to form a patch yet.
---
