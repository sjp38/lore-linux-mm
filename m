Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 00E4D6B0033
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 07:12:34 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id p5so36168789pgn.7
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 04:12:33 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t3si151286pfb.114.2017.10.05.04.12.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Oct 2017 04:12:32 -0700 (PDT)
Date: Thu, 5 Oct 2017 13:12:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v10 3/6] mm, oom: cgroup-aware OOM killer
Message-ID: <20171005111230.i7am3patptvalcat@dhcp22.suse.cz>
References: <20171004154638.710-1-guro@fb.com>
 <20171004154638.710-4-guro@fb.com>
 <CALvZod6bwyoSWTv139y0wMidpZm5HcDu8RzVjF8U7GHxAzxSQw@mail.gmail.com>
 <20171004201524.GA4174@castle>
 <CALvZod45ObeQwq-pKeqyLe2bNwfKAr0majCbNfqPOEJL+AeiNw@mail.gmail.com>
 <20171005102707.GA12982@castle.dhcp.TheFacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171005102707.GA12982@castle.dhcp.TheFacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Shakeel Butt <shakeelb@google.com>, Linux MM <linux-mm@kvack.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, Cgroups <cgroups@vger.kernel.org>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Thu 05-10-17 11:27:07, Roman Gushchin wrote:
> On Wed, Oct 04, 2017 at 02:24:26PM -0700, Shakeel Butt wrote:
[...]
> > Sorry about the confusion. There are two things. First, should we do a
> > css_get on the newly selected memcg within the for loop when we still
> > have a reference to it?
> 
> We're holding rcu_read_lock, it should be enough. We're bumping css counter
> just before releasing rcu lock.

yes

> > 
> > Second, for the OFFLINE memcg, you are right oom_evaluate_memcg() will
> > return 0 for offlined memcgs. Maybe no need to call
> > oom_evaluate_memcg() for offlined memcgs.
> 
> Sounds like a good optimization, which can be done on top of the current
> patchset.

You could achive this by checking whether a memcg has tasks rather than
explicitly checking for children memcgs as I've suggested already.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
