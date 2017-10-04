Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 51A576B0038
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 16:41:59 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 22so8472608wrb.7
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 13:41:59 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id h37si14502982ede.19.2017.10.04.13.41.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 04 Oct 2017 13:41:58 -0700 (PDT)
Date: Wed, 4 Oct 2017 16:41:53 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [v10 3/6] mm, oom: cgroup-aware OOM killer
Message-ID: <20171004204153.GA2696@cmpxchg.org>
References: <20171004154638.710-1-guro@fb.com>
 <20171004154638.710-4-guro@fb.com>
 <alpine.DEB.2.10.1710041322160.67374@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1710041322160.67374@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Oct 04, 2017 at 01:27:14PM -0700, David Rientjes wrote:
> By only considering leaf memcgs, does this penalize users if their memcg 
> becomes oc->chosen_memcg purely because it has aggregated all of its 
> processes to be members of that memcg, which would otherwise be the 
> standard behavior?
> 
> What prevents me from spreading my memcg with N processes attached over N 
> child memcgs instead so that memcg_oom_badness() becomes very small for 
> each child memcg specifically to avoid being oom killed?

It's no different from forking out multiple mm to avoid being the
biggest process.

It's up to the parent to enforce limits on that group and prevent you
from being able to cause global OOM in the first place, in particular
if you delegate to untrusted and potentially malicious users.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
