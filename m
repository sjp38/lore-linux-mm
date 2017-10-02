Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5DDD26B0038
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 16:34:36 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 136so5066164wmu.3
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 13:34:36 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id g62si451258edd.241.2017.10.02.13.34.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 02 Oct 2017 13:34:35 -0700 (PDT)
Date: Mon, 2 Oct 2017 16:34:23 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
Message-ID: <20171002203423.GA19849@cmpxchg.org>
References: <CAAAKZws2CFExeg6A9AzrGjiHnFHU1h2xdk6J5Jw2kqxy=V+_YQ@mail.gmail.com>
 <20170927162300.GA5623@castle.DHCP.thefacebook.com>
 <CAAAKZwtApj-FgRc2V77nEb3BUd97Rwhgf-b-k0zhf1u+Y4fqxA@mail.gmail.com>
 <CALvZod7iaOEeGmDJA0cZvJWpuzc-hMRn3PG2cfzcMniJtAjKqA@mail.gmail.com>
 <20171002122434.llbaarb6yw3o3mx3@dhcp22.suse.cz>
 <CALvZod65LYZZYy6uE=DQaQRPXYAhAci=NMG_w=ZANPGATgRwfg@mail.gmail.com>
 <20171002192814.sad75tqklp3nmr4m@dhcp22.suse.cz>
 <CALvZod4=+GVg+hrT4ubp9P4b+LUZ+q9mz4ztC=Fc_cmTZmvpcw@mail.gmail.com>
 <20171002195601.3jeocmmzyf2jl3dw@dhcp22.suse.cz>
 <CALvZod5qiF_7k=D7uiF=GwQEgc7Vztn-DNYMxsnmKGrk3DaYBQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod5qiF_7k=D7uiF=GwQEgc7Vztn-DNYMxsnmKGrk3DaYBQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Tim Hockin <thockin@hockin.org>, Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, David Rientjes <rientjes@google.com>, Linux MM <linux-mm@kvack.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Cgroups <cgroups@vger.kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Oct 02, 2017 at 01:24:25PM -0700, Shakeel Butt wrote:
> On Mon, Oct 2, 2017 at 12:56 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Mon 02-10-17 12:45:18, Shakeel Butt wrote:
> >> > I am sorry to cut the rest of your proposal because it simply goes over
> >> > the scope of the proposed solution while the usecase you are mentioning
> >> > is still possible. If we want to compare intermediate nodes (which seems
> >> > to be the case) then we can always provide a knob to opt-in - be it your
> >> > oom_gang or others.
> >>
> >> In the Roman's proposed solution we can already force the comparison
> >> of intermediate nodes using 'oom_group', I am just requesting to
> >> separate the killall semantics from it.
> >
> > oom_group _is_ about killall semantic.  And comparing killable entities
> > is just a natural thing to do. So I am not sure what you mean
> >
> 
> I am saying decouple the notion of comparable entities and killable entities.

Feel free to send patches in a new thread.

We don't need this level of control for this series to be useful - to
us, and other users. It can easily be added on top of Roman's work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
