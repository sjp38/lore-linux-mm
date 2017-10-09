Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id AADA56B025E
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 17:11:09 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id l188so50441055pfc.7
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 14:11:09 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r1sor1058897plb.147.2017.10.09.14.11.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Oct 2017 14:11:08 -0700 (PDT)
Date: Mon, 9 Oct 2017 14:11:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v11 2/6] mm: implement mem_cgroup_scan_tasks() for the root
 memory cgroup
In-Reply-To: <20171005130454.5590-3-guro@fb.com>
Message-ID: <alpine.DEB.2.10.1710091410550.59643@chino.kir.corp.google.com>
References: <20171005130454.5590-1-guro@fb.com> <20171005130454.5590-3-guro@fb.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, 5 Oct 2017, Roman Gushchin wrote:

> Implement mem_cgroup_scan_tasks() functionality for the root
> memory cgroup to use this function for looking for a OOM victim
> task in the root memory cgroup by the cgroup-ware OOM killer.
> 
> The root memory cgroup is treated as a leaf cgroup, so only tasks
> which are directly belonging to the root cgroup are iterated over.
> 
> This patch doesn't introduce any functional change as
> mem_cgroup_scan_tasks() is never called for the root memcg.
> This is preparatory work for the cgroup-aware OOM killer,
> which will use this function to iterate over tasks belonging
> to the root memcg.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
