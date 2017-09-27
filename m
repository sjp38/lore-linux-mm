Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8FDD06B025F
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 03:43:22 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 188so25601763pgb.3
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 00:43:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v41si7167449plg.597.2017.09.27.00.43.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Sep 2017 00:43:21 -0700 (PDT)
Date: Wed, 27 Sep 2017 09:43:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
Message-ID: <20170927074319.o3k26kja43rfqmvb@dhcp22.suse.cz>
References: <20170925122400.4e7jh5zmuzvbggpe@dhcp22.suse.cz>
 <20170925170004.GA22704@cmpxchg.org>
 <20170925181533.GA15918@castle>
 <20170925202442.lmcmvqwy2jj2tr5h@dhcp22.suse.cz>
 <20170926105925.GA23139@castle.dhcp.TheFacebook.com>
 <20170926112134.r5eunanjy7ogjg5n@dhcp22.suse.cz>
 <20170926121300.GB23139@castle.dhcp.TheFacebook.com>
 <20170926133040.uupv3ibkt3jtbotf@dhcp22.suse.cz>
 <20170926172610.GA26694@cmpxchg.org>
 <CAAAKZws88uF2dVrXwRV0V6AH5X68rWy7AfJxTxYjpuiyiNJFWA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAAKZws88uF2dVrXwRV0V6AH5X68rWy7AfJxTxYjpuiyiNJFWA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Hockin <thockin@hockin.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Cgroups <cgroups@vger.kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue 26-09-17 20:37:37, Tim Hockin wrote:
[...]
> I feel like David has offered examples here, and many of us at Google
> have offered examples as long ago as 2013 (if I recall) of cases where
> the proposed heuristic is EXACTLY WRONG.

I do not think we have discussed anything resembling the current
approach. And I would really appreciate some more examples where
decisions based on leaf nodes would be EXACTLY WRONG.

> We need OOM behavior to kill in a deterministic order configured by
> policy.

And nobody is objecting to this usecase. I think we can build a priority
policy on top of leaf-based decision as well. The main point we are
trying to sort out here is a reasonable semantic that would work for
most workloads. Sibling based selection will simply not work on those
that have to use deeper hierarchies for organizational purposes. I
haven't heard a counter argument for that example yet.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
