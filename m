Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id B704A6B0038
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 16:24:27 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id 32so3909932qtp.3
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 13:24:27 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r63sor484004ybf.51.2017.10.02.13.24.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Oct 2017 13:24:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171002195601.3jeocmmzyf2jl3dw@dhcp22.suse.cz>
References: <CAAAKZws88uF2dVrXwRV0V6AH5X68rWy7AfJxTxYjpuiyiNJFWA@mail.gmail.com>
 <20170927074319.o3k26kja43rfqmvb@dhcp22.suse.cz> <CAAAKZws2CFExeg6A9AzrGjiHnFHU1h2xdk6J5Jw2kqxy=V+_YQ@mail.gmail.com>
 <20170927162300.GA5623@castle.DHCP.thefacebook.com> <CAAAKZwtApj-FgRc2V77nEb3BUd97Rwhgf-b-k0zhf1u+Y4fqxA@mail.gmail.com>
 <CALvZod7iaOEeGmDJA0cZvJWpuzc-hMRn3PG2cfzcMniJtAjKqA@mail.gmail.com>
 <20171002122434.llbaarb6yw3o3mx3@dhcp22.suse.cz> <CALvZod65LYZZYy6uE=DQaQRPXYAhAci=NMG_w=ZANPGATgRwfg@mail.gmail.com>
 <20171002192814.sad75tqklp3nmr4m@dhcp22.suse.cz> <CALvZod4=+GVg+hrT4ubp9P4b+LUZ+q9mz4ztC=Fc_cmTZmvpcw@mail.gmail.com>
 <20171002195601.3jeocmmzyf2jl3dw@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 2 Oct 2017 13:24:25 -0700
Message-ID: <CALvZod5qiF_7k=D7uiF=GwQEgc7Vztn-DNYMxsnmKGrk3DaYBQ@mail.gmail.com>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tim Hockin <thockin@hockin.org>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, David Rientjes <rientjes@google.com>, Linux MM <linux-mm@kvack.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Cgroups <cgroups@vger.kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Oct 2, 2017 at 12:56 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Mon 02-10-17 12:45:18, Shakeel Butt wrote:
>> > I am sorry to cut the rest of your proposal because it simply goes over
>> > the scope of the proposed solution while the usecase you are mentioning
>> > is still possible. If we want to compare intermediate nodes (which seems
>> > to be the case) then we can always provide a knob to opt-in - be it your
>> > oom_gang or others.
>>
>> In the Roman's proposed solution we can already force the comparison
>> of intermediate nodes using 'oom_group', I am just requesting to
>> separate the killall semantics from it.
>
> oom_group _is_ about killall semantic.  And comparing killable entities
> is just a natural thing to do. So I am not sure what you mean
>

I am saying decouple the notion of comparable entities and killable entities.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
