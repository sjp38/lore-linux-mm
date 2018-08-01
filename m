Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 18DC76B0006
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 18:56:08 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id h26-v6so176841eds.14
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 15:56:08 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id i20-v6si239344edj.108.2018.08.01.15.56.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Aug 2018 15:56:06 -0700 (PDT)
Date: Wed, 1 Aug 2018 15:55:40 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v13 0/7] cgroup-aware OOM killer
Message-ID: <20180801225539.GB32269@castle.DHCP.thefacebook.com>
References: <0d018c7e-a3de-a23a-3996-bed8b28b1e4a@i-love.sakura.ne.jp>
 <20180716220918.GA3898@castle.DHCP.thefacebook.com>
 <201807170055.w6H0tHn5075670@www262.sakura.ne.jp>
 <ede70c6a-620b-f835-d66c-b4608fe0ef54@i-love.sakura.ne.jp>
 <20180801163718.GA23539@castle>
 <de9a2bad-d80d-98a0-e155-613a34c0b7be@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <de9a2bad-d80d-98a0-e155-613a34c0b7be@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Aug 02, 2018 at 07:01:28AM +0900, Tetsuo Handa wrote:
> On 2018/08/02 1:37, Roman Gushchin wrote:
> > On Tue, Jul 31, 2018 at 11:14:01PM +0900, Tetsuo Handa wrote:
> >> Can we temporarily drop cgroup-aware OOM killer from linux-next.git and
> >> apply my cleanup patch? Since the merge window is approaching, I really want to
> >> see how next -rc1 would look like...
> > 
> > Hi Tetsuo!
> > 
> > Has this cleanup patch been acked by somebody?
> 
> Not yet. But since Michal considers this cleanup as "a nice shortcut"
> ( https://marc.info/?i=20180607112836.GN32433@dhcp22.suse.cz ), I assume that
> I will get an ACK regarding this cleanup.
> 
> > Which problem does it solve?
> 
> It simplifies tricky out_of_memory() return value decision, and
> it also fixes a bug in your series which syzbot is pointing out.
> 
> > Dropping patches for making a cleanup (if it's a cleanup) sounds a bit strange.
> 
> What I need is a git tree which I can use as a baseline for making this cleanup.
> linux.git is not suitable because it does not include Michal's fix, but
> linux-next.git is not suitable because Michal's fix is overwritten by your series.
> I want a git tree which includes Michal's fix and does not include your series.
> 
> > 
> > Anyway, there is a good chance that current cgroup-aware OOM killer
> > implementation will be replaced by a lightweight version (memory.oom.group).
> > Please, take a look at it, probably your cleanup will not conflict with it
> > at all.
> 
> Then, please drop current cgroup-aware OOM killer implementation from linux-next.git .
> I want to see how next -rc1 would look like (for testing purpose) and want to use
> linux-next.git as a baseline (for making this cleanup).

I'll post memory.oom.group v2 later today, and if there will be no objections,
I'll ask Andrew to drop current memcg-aware OOM killer and replace it
with lightweight memory.oom.group.

These changes will be picked by linux-next in few days.

Thanks!
