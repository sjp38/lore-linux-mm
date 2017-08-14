Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1A1256B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 18:00:51 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id y129so158711484pgy.1
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 15:00:51 -0700 (PDT)
Received: from mail-pg0-x231.google.com (mail-pg0-x231.google.com. [2607:f8b0:400e:c05::231])
        by mx.google.com with ESMTPS id d9si5289931pln.943.2017.08.14.15.00.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 15:00:45 -0700 (PDT)
Received: by mail-pg0-x231.google.com with SMTP id u185so55161564pgb.1
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 15:00:45 -0700 (PDT)
Date: Mon, 14 Aug 2017 15:00:43 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v5 1/4] mm, oom: refactor the oom_kill_process() function
In-Reply-To: <20170814183213.12319-1-guro@fb.com>
Message-ID: <alpine.DEB.2.10.1708141500260.129178@chino.kir.corp.google.com>
References: <20170814183213.12319-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 14 Aug 2017, Roman Gushchin wrote:

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
> Cc: Tejun Heo <tj@kernel.org>
> Cc: kernel-team@fb.com
> Cc: cgroups@vger.kernel.org
> Cc: linux-doc@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
