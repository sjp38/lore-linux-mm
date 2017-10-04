Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D42426B0038
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 15:15:56 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id u78so11450219wmd.4
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 12:15:56 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 35si5324690edh.444.2017.10.04.12.15.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 04 Oct 2017 12:15:55 -0700 (PDT)
Date: Wed, 4 Oct 2017 15:15:52 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [v10 2/6] mm: implement mem_cgroup_scan_tasks() for the root
 memory cgroup
Message-ID: <20171004191552.GB1501@cmpxchg.org>
References: <20171004154638.710-1-guro@fb.com>
 <20171004154638.710-3-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171004154638.710-3-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Oct 04, 2017 at 04:46:34PM +0100, Roman Gushchin wrote:
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
> Acked-by: Michal Hocko <mhocko@suse.com>
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

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
