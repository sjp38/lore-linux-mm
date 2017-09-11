Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 681756B02F2
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 16:51:20 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 188so18302079pgb.3
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 13:51:20 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a6sor4677749pln.69.2017.09.11.13.51.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Sep 2017 13:51:19 -0700 (PDT)
Date: Mon, 11 Sep 2017 13:51:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v8 1/4] mm, oom: refactor the oom_kill_process() function
In-Reply-To: <20170911131742.16482-2-guro@fb.com>
Message-ID: <alpine.DEB.2.10.1709111349321.102819@chino.kir.corp.google.com>
References: <20170911131742.16482-1-guro@fb.com> <20170911131742.16482-2-guro@fb.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 11 Sep 2017, Roman Gushchin wrote:

> The oom_kill_process() function consists of two logical parts:
> the first one is responsible for considering task's children as
> a potential victim and printing the debug information.
> The second half is responsible for sending SIGKILL to all
> tasks sharing the mm struct with the given victim.
> 
> This commit splits the oom_kill_process() function with
> an intention to re-use the the second half: __oom_kill_process().
> 
> The cgroup-aware OOM killer will kill multiple tasks
> belonging to the victim cgroup. We don't need to print
> the debug information for the each task, as well as play
> with task selection (considering task's children),
> so we can't use the existing oom_kill_process().
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: kernel-team@fb.com
> Cc: cgroups@vger.kernel.org
> Cc: linux-doc@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org

Acked-by: David Rientjes <rientjes@google.com>

https://marc.info/?l=linux-kernel&m=150274805412752

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
