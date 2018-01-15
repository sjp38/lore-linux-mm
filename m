Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D41B56B0038
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 06:54:35 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id h17so376397wmc.6
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 03:54:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i19si13604111wrf.104.2018.01.15.03.54.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 15 Jan 2018 03:54:34 -0800 (PST)
Date: Mon, 15 Jan 2018 12:54:33 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v13 0/7] cgroup-aware OOM killer
Message-ID: <20180115115433.GA22473@dhcp22.suse.cz>
References: <20171130152824.1591-1-guro@fb.com>
 <20171130123930.cf3217c816fd270fa35a40cb@linux-foundation.org>
 <alpine.DEB.2.10.1801091556490.173445@chino.kir.corp.google.com>
 <20180110131143.GB26913@castle.DHCP.thefacebook.com>
 <20180110113345.54dd571967fd6e70bfba68c3@linux-foundation.org>
 <20180111090809.GW1732@dhcp22.suse.cz>
 <20180111131845.GA13726@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.10.1801121331110.120129@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1801121331110.120129@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@vger.kernel.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 12-01-18 14:03:03, David Rientjes wrote:
> On Thu, 11 Jan 2018, Roman Gushchin wrote:
> 
> > Summarizing all this, following the hierarchy is good when it reflects
> > the "importance" of cgroup's memory for a user, and bad otherwise.
> > In generic case with unified hierarchy it's not true, so following
> > the hierarchy unconditionally is bad.
> > 
> > Current version of the patchset allows common evaluation of cgroups
> > by setting memory.groupoom to true. The only limitation is that it
> > also changes the OOM action: all belonging processes will be killed.
> > If we really want to preserve an option to evaluate cgroups
> > together without forcing "kill all processes" action, we can
> > convert memory.groupoom from being boolean to the multi-value knob.
> > For instance, "disabled" and "killall". This will allow to add
> > a third state ("evaluate", for example) later without breaking the API.
> > 
> 
> No, this isn't how kernel features get introduced.  We don't design a new 
> kernel feature with its own API for a highly specialized usecase and then 
> claim we'll fix the problems later.  Users will work around the 
> constraints of the new feature, if possible, and then we can end up 
> breaking them later.  Or, we can pollute the mem cgroup v2 filesystem with 
> even more tunables to cover up for mistakes in earlier designs.

This is a blatant misinterpretation of the proposed changes. I haven't
heard _any_ single argument against the proposed user interface except
for complaints for missing tunables. This is not how the kernel
development works and should work. The usecase was clearly described and
far from limited to a single workload or company.
 
> The key point to all three of my objections: extensibility.

And it has been argued that further _features_ can be added on top. I am
absolutely fed up discussing those things again and again without any
progress. You simply keep _ignoring_ counter arguments and that is a
major PITA to be honest with you. You are basically blocking a useful
feature because it doesn't solve your particular workload. This is
simply not acceptable in the kernel development.

> Both you and Michal have acknowledged blantently obvious shortcomings in 
> the design.

What you call blatant shortcomings we do not see affecting any
_existing_ workloads. If they turn out to be real issues then we can fix
them without deprecating any user APIs added by this patchset.

Look, I am not the one who is a heavy container user. The primary reason
I am supporting this is because a) it has a _real_ user and I can see
more to emerge and b) because it _makes_ sense in its current form and
it doesn't bring heavy maintenance burden in the OOM code base which I
do care about.

I am deliberately skipping the rest of your email because it is _yet_
_again_ a form of obstructing the current patchset which is what you
have been doing for quite some time. I will leave the final decision
for merging to Andrew. If you want to build a more fine grained control
on top, you are free to do so. I will be reviewing those like any other
upstream oom changes.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
