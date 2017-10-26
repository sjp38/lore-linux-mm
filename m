Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id DE8926B0033
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 10:24:56 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 136so1928311wmu.10
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 07:24:56 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id x44si390120edb.125.2017.10.26.07.24.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 26 Oct 2017 07:24:55 -0700 (PDT)
Date: Thu, 26 Oct 2017 10:24:45 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RESEND v12 0/6] cgroup-aware OOM killer
Message-ID: <20171026142445.GA21147@cmpxchg.org>
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
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>

On Sun, Oct 22, 2017 at 05:24:51PM -0700, David Rientjes wrote:
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
> 
>  (2) the ability of users to completely evade the oom killer by attaching
>      all processes to child cgroups either purposefully or unpurposefully,
>      and
> 
>  (3) the inability of userspace to effectively control oom victim  
>      selection.

My apologies if my summary was too reductionist.

That being said, the arguments you repeat here have come up in
previous threads and been responded to. This doesn't change my
conclusion that your NAK is bogus.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
