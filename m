Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3E4286B0264
	for <linux-mm@kvack.org>; Fri, 27 May 2016 10:46:00 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b124so198782568pfb.1
        for <linux-mm@kvack.org>; Fri, 27 May 2016 07:46:00 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0145.outbound.protection.outlook.com. [157.56.112.145])
        by mx.google.com with ESMTPS id et5si28769208pad.127.2016.05.27.07.45.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 27 May 2016 07:45:59 -0700 (PDT)
Date: Fri, 27 May 2016 17:45:49 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 2/2] mm: oom: deduplicate victim selection code for memcg
 and global oom
Message-ID: <20160527144549.GC26059@esperanza>
References: <40e03fd7aaf1f55c75d787128d6d17c5a71226c2.1464358556.git.vdavydov@virtuozzo.com>
 <3bbc7b70dae6ace0b8751e0140e878acfdfffd74.1464358556.git.vdavydov@virtuozzo.com>
 <20160527142626.GQ27686@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160527142626.GQ27686@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, May 27, 2016 at 04:26:26PM +0200, Michal Hocko wrote:
> On Fri 27-05-16 17:17:42, Vladimir Davydov wrote:
> > When selecting an oom victim, we use the same heuristic for both memory
> > cgroup and global oom. The only difference is the scope of tasks to
> > select the victim from. So we could just export an iterator over all
> > memcg tasks and keep all oom related logic in oom_kill.c, but instead we
> > duplicate pieces of it in memcontrol.c reusing some initially private
> > functions of oom_kill.c in order to not duplicate all of it. That looks
> > ugly and error prone, because any modification of select_bad_process
> > should also be propagated to mem_cgroup_out_of_memory.
> > 
> > Let's rework this as follows: keep all oom heuristic related code
> > private to oom_kill.c and make oom_kill.c use exported memcg functions
> > when it's really necessary (like in case of iterating over memcg tasks).
> 
> I am doing quite large changes in this area and this would cause many
> conflicts. Do you think you can postpone this after my patchset [1] gets
> sorted out please?

I'm fine with it.

> 
> I haven't looked at the patch carefully so I cannot tell much about it
> right now but just wanted to give a heads up for the conflicts.

I'd appreciate if you could take a look at this patch once time permits.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
