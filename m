Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7CB766B025F
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 08:58:23 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id n88so1171995wrb.0
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 05:58:23 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id u62si1233928wmb.159.2017.08.15.05.58.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 05:58:22 -0700 (PDT)
Date: Tue, 15 Aug 2017 13:57:50 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v5 2/4] mm, oom: cgroup-aware OOM killer
Message-ID: <20170815125750.GB15892@castle.dhcp.TheFacebook.com>
References: <20170814183213.12319-1-guro@fb.com>
 <20170814183213.12319-3-guro@fb.com>
 <alpine.DEB.2.10.1708141532300.63207@chino.kir.corp.google.com>
 <20170815121558.GA15892@castle.dhcp.TheFacebook.com>
 <f769d03d-5743-b794-a249-bb52b408ab0e@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <f769d03d-5743-b794-a249-bb52b408ab0e@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aleksa Sarai <asarai@suse.de>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Aug 15, 2017 at 10:20:18PM +1000, Aleksa Sarai wrote:
> On 08/15/2017 10:15 PM, Roman Gushchin wrote:
> > Generally, oom_score_adj should have a meaning only on a cgroup level,
> > so extending it to the system level doesn't sound as a good idea.
> 
> But wasn't the original purpose of oom_score (and oom_score_adj) to work on
> a system level, aka "normal" OOM? Is there some peculiarity about memcg OOM
> that I'm missing?

I'm sorry, if it wasn't clear from my message, it's not about
the system-wide OOM vs the memcg-wide OOM, it's about the isolation.

In general, decision is made on memcg level first (based on oom_priority
and size), and only then on a task level (based on size and oom_score_adj).

Oom_score_adj affects which task inside the cgroup will be killed,
but we never compare tasks from different cgroups. This is what I mean,
when I'm saying, that oom_score_adj should not have a system-wide meaning.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
