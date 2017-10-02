Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7D37A6B0033
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 15:56:06 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id r83so13972542pfj.5
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 12:56:06 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r9si4358286pgp.132.2017.10.02.12.56.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 02 Oct 2017 12:56:05 -0700 (PDT)
Date: Mon, 2 Oct 2017 21:56:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
Message-ID: <20171002195601.3jeocmmzyf2jl3dw@dhcp22.suse.cz>
References: <CAAAKZws88uF2dVrXwRV0V6AH5X68rWy7AfJxTxYjpuiyiNJFWA@mail.gmail.com>
 <20170927074319.o3k26kja43rfqmvb@dhcp22.suse.cz>
 <CAAAKZws2CFExeg6A9AzrGjiHnFHU1h2xdk6J5Jw2kqxy=V+_YQ@mail.gmail.com>
 <20170927162300.GA5623@castle.DHCP.thefacebook.com>
 <CAAAKZwtApj-FgRc2V77nEb3BUd97Rwhgf-b-k0zhf1u+Y4fqxA@mail.gmail.com>
 <CALvZod7iaOEeGmDJA0cZvJWpuzc-hMRn3PG2cfzcMniJtAjKqA@mail.gmail.com>
 <20171002122434.llbaarb6yw3o3mx3@dhcp22.suse.cz>
 <CALvZod65LYZZYy6uE=DQaQRPXYAhAci=NMG_w=ZANPGATgRwfg@mail.gmail.com>
 <20171002192814.sad75tqklp3nmr4m@dhcp22.suse.cz>
 <CALvZod4=+GVg+hrT4ubp9P4b+LUZ+q9mz4ztC=Fc_cmTZmvpcw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod4=+GVg+hrT4ubp9P4b+LUZ+q9mz4ztC=Fc_cmTZmvpcw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Tim Hockin <thockin@hockin.org>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, David Rientjes <rientjes@google.com>, Linux MM <linux-mm@kvack.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Cgroups <cgroups@vger.kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon 02-10-17 12:45:18, Shakeel Butt wrote:
> > I am sorry to cut the rest of your proposal because it simply goes over
> > the scope of the proposed solution while the usecase you are mentioning
> > is still possible. If we want to compare intermediate nodes (which seems
> > to be the case) then we can always provide a knob to opt-in - be it your
> > oom_gang or others.
> 
> In the Roman's proposed solution we can already force the comparison
> of intermediate nodes using 'oom_group', I am just requesting to
> separate the killall semantics from it.

oom_group _is_ about killall semantic.  And comparing killable entities
is just a natural thing to do. So I am not sure what you mean

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
