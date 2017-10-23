Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 482C66B0033
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 07:49:52 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id o44so9958370wrf.0
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 04:49:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j7si3077035wmh.183.2017.10.23.04.49.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Oct 2017 04:49:51 -0700 (PDT)
Date: Mon, 23 Oct 2017 13:49:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RESEND v12 0/6] cgroup-aware OOM killer
Message-ID: <20171023114948.qzmo7emqbigfff7h@dhcp22.suse.cz>
References: <20171019185218.12663-1-guro@fb.com>
 <20171019194534.GA5502@cmpxchg.org>
 <alpine.DEB.2.10.1710221715010.70210@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1710221715010.70210@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>

On Sun 22-10-17 17:24:51, David Rientjes wrote:
> On Thu, 19 Oct 2017, Johannes Weiner wrote:
> 
> > David would have really liked for this patchset to include knobs to
> > influence how the algorithm picks cgroup victims. The rest of us
> > agreed that this is beyond the scope of these patches, that the
> > patches don't need it to be useful, and that there is nothing
> > preventing anyone from adding configurability later on. David
> > subsequently nacked the series as he considers it incomplete. Neither
> > Michal nor I see technical merit in David's nack.
> > 
> 
> The nack is for three reasons:
> 
>  (1) unfair comparison of root mem cgroup usage to bias against that mem 
>      cgroup from oom kill in system oom conditions,

Most users who are going to use this feature right now will have
most of the userspace in their containers rather than in the root
memcg. The root memcg will always be special and as such there will
never be a universal best way to handle it. We should to satisfy most of
usecases. I would consider this something that is an open for a further
discussion but nothing that should stand in the way.
 
>  (2) the ability of users to completely evade the oom killer by attaching
>      all processes to child cgroups either purposefully or unpurposefully,
>      and

This doesn't differ from the current state where a task can purposefully
or unpurposefully hide itself from the global memory killer by spawning
new processes.
 
>  (3) the inability of userspace to effectively control oom victim  
>      selection.

this is not requested by the current usecase and it has been pointed out
that this will be possible to implement on top of the foundation of this
patchset.

So again, nothing to nack the work as is.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
