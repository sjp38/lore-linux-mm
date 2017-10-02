Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A0AF06B0033
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 15:28:22 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e26so500446pfd.4
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 12:28:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h90si8234028pfh.592.2017.10.02.12.28.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 02 Oct 2017 12:28:21 -0700 (PDT)
Date: Mon, 2 Oct 2017 21:28:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
Message-ID: <20171002192814.sad75tqklp3nmr4m@dhcp22.suse.cz>
References: <20170926133040.uupv3ibkt3jtbotf@dhcp22.suse.cz>
 <20170926172610.GA26694@cmpxchg.org>
 <CAAAKZws88uF2dVrXwRV0V6AH5X68rWy7AfJxTxYjpuiyiNJFWA@mail.gmail.com>
 <20170927074319.o3k26kja43rfqmvb@dhcp22.suse.cz>
 <CAAAKZws2CFExeg6A9AzrGjiHnFHU1h2xdk6J5Jw2kqxy=V+_YQ@mail.gmail.com>
 <20170927162300.GA5623@castle.DHCP.thefacebook.com>
 <CAAAKZwtApj-FgRc2V77nEb3BUd97Rwhgf-b-k0zhf1u+Y4fqxA@mail.gmail.com>
 <CALvZod7iaOEeGmDJA0cZvJWpuzc-hMRn3PG2cfzcMniJtAjKqA@mail.gmail.com>
 <20171002122434.llbaarb6yw3o3mx3@dhcp22.suse.cz>
 <CALvZod65LYZZYy6uE=DQaQRPXYAhAci=NMG_w=ZANPGATgRwfg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod65LYZZYy6uE=DQaQRPXYAhAci=NMG_w=ZANPGATgRwfg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Tim Hockin <thockin@hockin.org>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, David Rientjes <rientjes@google.com>, Linux MM <linux-mm@kvack.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Cgroups <cgroups@vger.kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon 02-10-17 12:00:43, Shakeel Butt wrote:
> > Yes and nobody is disputing that, really. I guess the main disconnect
> > here is that different people want to have more detailed control over
> > the victim selection while the patchset tries to handle the most
> > simplistic scenario when a no userspace control over the selection is
> > required. And I would claim that this will be a last majority of setups
> > and we should address it first.
> 
> IMHO the disconnect/disagreement is which memcgs should be compared
> with each other for oom victim selection. Let's forget about oom
> priority and just take size into the account. Should the oom selection
> algorithm, compare the leaves of the hierarchy or should it compare
> siblings? For the single user system, comparing leaves makes sense
> while in a multi user system, siblings should be compared for victim
> selection.

THis is simply not true. This is not about single vs. multi user
systems. This is about how the memcg hierarchy is organized (please
have a look at the example I've provided previously). I would dare to
claim that comparing siblings is a weaker semantic just because it puts
stronger constrains on how the hierarchy is organized. Especially when
the cgrou v2 is single hierarchy based (so we cannot create intermediate
cgroup nodes for other controllers because we would automatically get
a cumulative memory consumption).

I am sorry to cut the rest of your proposal because it simply goes over
the scope of the proposed solution while the usecase you are mentioning
is still possible. If we want to compare intermediate nodes (which seems
to be the case) then we can always provide a knob to opt-in - be it your
oom_gang or others.

I am sorry but I would really appreciate to focus on making the step
1  done before diverging into details about potential improvements and a
better control over the selection. This whole thing is an opt-in so
there is a no risk of a regression.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
