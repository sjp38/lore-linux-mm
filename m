Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6B8816B007E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 13:25:09 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id o70so60716075lfg.1
        for <linux-mm@kvack.org>; Fri, 27 May 2016 10:25:09 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id n66si13730198wmg.5.2016.05.27.10.25.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 10:25:08 -0700 (PDT)
Date: Fri, 27 May 2016 13:23:04 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/2] mm: oom: deduplicate victim selection code for memcg
 and global oom
Message-ID: <20160527172304.GD2531@cmpxchg.org>
References: <40e03fd7aaf1f55c75d787128d6d17c5a71226c2.1464358556.git.vdavydov@virtuozzo.com>
 <3bbc7b70dae6ace0b8751e0140e878acfdfffd74.1464358556.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3bbc7b70dae6ace0b8751e0140e878acfdfffd74.1464358556.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, May 27, 2016 at 05:17:42PM +0300, Vladimir Davydov wrote:
> When selecting an oom victim, we use the same heuristic for both memory
> cgroup and global oom. The only difference is the scope of tasks to
> select the victim from. So we could just export an iterator over all
> memcg tasks and keep all oom related logic in oom_kill.c, but instead we
> duplicate pieces of it in memcontrol.c reusing some initially private
> functions of oom_kill.c in order to not duplicate all of it. That looks
> ugly and error prone, because any modification of select_bad_process
> should also be propagated to mem_cgroup_out_of_memory.
> 
> Let's rework this as follows: keep all oom heuristic related code
> private to oom_kill.c and make oom_kill.c use exported memcg functions
> when it's really necessary (like in case of iterating over memcg tasks).
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Cool work!

I'll do a full review after the rebase on top of Michal's stuff.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
