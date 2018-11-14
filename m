Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id D828D6B0272
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 05:16:09 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id 18-v6so10290225pgn.4
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 02:16:09 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c11si23053904pgj.255.2018.11.14.02.16.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 02:16:08 -0800 (PST)
Date: Wed, 14 Nov 2018 11:16:04 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH v2 0/3] oom: rework oom_reaper vs. exit_mmap handoff
Message-ID: <20181114101604.GM23419@dhcp22.suse.cz>
References: <20181025082403.3806-1-mhocko@kernel.org>
 <20181108093224.GS27423@dhcp22.suse.cz>
 <9dfd5c87-ae48-8ffb-fbc6-706d627658ff@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9dfd5c87-ae48-8ffb-fbc6-706d627658ff@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: David Rientjes <rientjes@google.com>, Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 14-11-18 18:46:13, Tetsuo Handa wrote:
[...]
> There is always an invisible lock called "scheduling priority". You can't
> leave the MMF_OOM_SKIP to the exit path. Your approach is not ready for
> handling the worst case.

And that problem is all over the memory reclaim. You can get starved
to death and block other resources. And the memory reclaim is not the
only one. This is a fundamental issue of the locking without priority
inheritance and other real time techniques.

> Nacked-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

OK, if your whole point is to block any changes into this area unless
it is your solution to be merged then I guess I will just push patches
through with your explicit Nack on them. Your feedback was far fetched
at many times has distracted the discussion way too often. This is
especially sad because your testing and review was really helpful at
times. I do not really have energy to argue the same set of arguments
over and over again.

You have expressed unwillingness to understand the overall
picture several times. You do not care about a long term maintenance
burden of this code which is quite tricky already and refuse to
understand the cost/benefit part.

If this series works for the workload reported by David I will simply
push it through and let Andrew decide. If there is a lack of feedback
I will just keep it around because it seems that most users do not care
about these corner cases anyway.
-- 
Michal Hocko
SUSE Labs
