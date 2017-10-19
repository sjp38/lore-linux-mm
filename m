Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id B62876B0038
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 15:45:43 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k7so4516729wre.22
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 12:45:43 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id i3si900862edc.271.2017.10.19.12.45.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 19 Oct 2017 12:45:42 -0700 (PDT)
Date: Thu, 19 Oct 2017 15:45:34 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RESEND v12 0/6] cgroup-aware OOM killer
Message-ID: <20171019194534.GA5502@cmpxchg.org>
References: <20171019185218.12663-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171019185218.12663-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>

On Thu, Oct 19, 2017 at 07:52:12PM +0100, Roman Gushchin wrote:
> This patchset makes the OOM killer cgroup-aware.

Hi Andrew,

I believe this code is ready for merging upstream, and it seems Michal
is in agreement. There are two main things to consider, however.

David would have really liked for this patchset to include knobs to
influence how the algorithm picks cgroup victims. The rest of us
agreed that this is beyond the scope of these patches, that the
patches don't need it to be useful, and that there is nothing
preventing anyone from adding configurability later on. David
subsequently nacked the series as he considers it incomplete. Neither
Michal nor I see technical merit in David's nack.

Michal acked the implementation, but on the condition that the new
behavior be opt-in, to not surprise existing users. I *think* we agree
that respecting the cgroup topography during global OOM is what we
should have been doing when cgroups were initially introduced; where
we disagree is that I think users shouldn't have to opt in to
improvements. We have done much more invasive changes to the victim
selection without actual regressions in the past. Further, this change
only applies to mounts of the new cgroup2. Tejun also wasn't convinced
of the risk for regression, and too would prefer cgroup-awareness to
be the default in cgroup2. I would ask for patch 5/6 to be dropped.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
