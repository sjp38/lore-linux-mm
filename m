Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3E08E6B000D
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 13:29:13 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id u68-v6so17632353qku.5
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 10:29:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i16-v6sor9390807qti.122.2018.08.01.10.29.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Aug 2018 10:29:12 -0700 (PDT)
Date: Wed, 1 Aug 2018 13:32:06 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/3] mm, oom: refactor oom_kill_process()
Message-ID: <20180801173206.GB11386@cmpxchg.org>
References: <20180730180100.25079-1-guro@fb.com>
 <20180730180100.25079-3-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180730180100.25079-3-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, linux-kernel@vger.kernel.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Jul 30, 2018 at 11:00:59AM -0700, Roman Gushchin wrote:
> oom_kill_process() consists of two logical parts: the first one is
> responsible for considering task's children as a potential victim and
> printing the debug information.  The second half is responsible for
> sending SIGKILL to all tasks sharing the mm struct with the given victim.
> 
> This commit splits oom_kill_process() with an intention to re-use the the
> second half: __oom_kill_process().
> 
> The cgroup-aware OOM killer will kill multiple tasks belonging to the
> victim cgroup.  We don't need to print the debug information for the each
> task, as well as play with task selection (considering task's children),
> so we can't use the existing oom_kill_process().
> 
> Link: http://lkml.kernel.org/r/20171130152824.1591-2-guro@fb.com
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: David Rientjes <rientjes@google.com>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

This is pretty straight-forward.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>
