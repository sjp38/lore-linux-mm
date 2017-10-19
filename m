Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A95BB6B0038
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 17:09:48 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v105so1127782wrc.11
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 14:09:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k6si1697485wme.199.2017.10.19.14.09.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 14:09:46 -0700 (PDT)
Date: Thu, 19 Oct 2017 23:09:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RESEND v12 0/6] cgroup-aware OOM killer
Message-ID: <20171019210945.b75znan5kkxy7zxl@dhcp22.suse.cz>
References: <20171019185218.12663-1-guro@fb.com>
 <20171019194534.GA5502@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171019194534.GA5502@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>

On Thu 19-10-17 15:45:34, Johannes Weiner wrote:
> On Thu, Oct 19, 2017 at 07:52:12PM +0100, Roman Gushchin wrote:
> > This patchset makes the OOM killer cgroup-aware.
> 
> Hi Andrew,
> 
> I believe this code is ready for merging upstream, and it seems Michal
> is in agreement. There are two main things to consider, however.
> 
> David would have really liked for this patchset to include knobs to
> influence how the algorithm picks cgroup victims. The rest of us
> agreed that this is beyond the scope of these patches, that the
> patches don't need it to be useful, and that there is nothing
> preventing anyone from adding configurability later on. David
> subsequently nacked the series as he considers it incomplete. Neither
> Michal nor I see technical merit in David's nack.

agreed

> Michal acked the implementation, but on the condition that the new
> behavior be opt-in, to not surprise existing users.

and just to make it clear I have also said I will _not_ nack if that is
not the case.

> I *think* we agree
> that respecting the cgroup topography during global OOM is what we
> should have been doing when cgroups were initially introduced;

We do not agree here though. I am not convinced that respecting the
cgroup topography is an universal win. It is true that there is no best
OOM victim selection strategy but what we have currently is the simplest
option and as such the most robust one. I can tell from the past year
experience that many of those clever heuristics actually contributed to
lockups and non-deterministic behavior.

> where
> we disagree is that I think users shouldn't have to opt in to
> improvements. We have done much more invasive changes to the victim
> selection without actual regressions in the past. Further, this change
> only applies to mounts of the new cgroup2.

which basically means that the behavior will change under many users
feet because the respecitve cgroup configuration is chosen by somebody
else (e.g. systemd) so I do not really buy "only v2 behavior"

> Tejun also wasn't convinced
> of the risk for regression, and too would prefer cgroup-awareness to
> be the default in cgroup2. I would ask for patch 5/6 to be dropped.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
