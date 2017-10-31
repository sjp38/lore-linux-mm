Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 04CD56B025F
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 03:54:13 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id m72so7333214wmc.0
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 00:54:12 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g92si1218174ede.406.2017.10.31.00.54.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 Oct 2017 00:54:11 -0700 (PDT)
Date: Tue, 31 Oct 2017 08:54:08 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RESEND v12 0/6] cgroup-aware OOM killer
Message-ID: <20171031075408.67au22uk6dkpu7vv@dhcp22.suse.cz>
References: <20171019185218.12663-1-guro@fb.com>
 <20171019194534.GA5502@cmpxchg.org>
 <alpine.DEB.2.10.1710221715010.70210@chino.kir.corp.google.com>
 <20171026142445.GA21147@cmpxchg.org>
 <alpine.DEB.2.10.1710261359550.75887@chino.kir.corp.google.com>
 <20171027093107.GA29492@castle.dhcp.TheFacebook.com>
 <alpine.DEB.2.10.1710301430170.105449@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1710301430170.105449@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 30-10-17 14:36:39, David Rientjes wrote:
> On Fri, 27 Oct 2017, Roman Gushchin wrote:
> 
> > The thing is that the hierarchical approach (as in v8), which are you pushing,
> > has it's own limitations, which we've discussed in details earlier. There are
> > reasons why v12 is different, and we can't really simple go back. I mean if
> > there are better ideas how to resolve concerns raised in discussions around v8,
> > let me know, but ignoring them is not an option.
> > 
> 
> I'm not ignoring them, I have stated that we need the ability to protect 
> important cgroups on the system without oom disabling all attached 
> processes.  If that is implemented as a memory.oom_score_adj with the same 
> semantics as /proc/pid/oom_score_adj, i.e. a proportion of available 
> memory (the limit), it can also address the issues pointed out with the 
> hierarchical approach in v8.

No it cannot and it would be a terrible interface to have as well. You
do not want to permanently tune oom_score_adj to compensate for
structural restrictions on the hierarchy.

> If this is not the case, could you elaborate 
> on what your exact concern is and why we do not care that users can 
> completely circumvent victim selection by creating child cgroups for other 
> controllers?
> 
> Since the ability to protect important cgroups on the system may require a 
> heuristic change, I think it should be solved now rather than constantly 
> insisting that we can make this patchset complete later and in the 
> meantime force the user to set all attached processes to be oom disabled.

I believe, and Roman has pointed that out as well already, that further
improvements can be implemented without changing user visible behavior
as and add-on. If you disagree then you better come with a solid proof
that all of us wrong and reasonable semantic cannot be achieved that
way.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
