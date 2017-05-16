Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1D8A56B03A5
	for <linux-mm@kvack.org>; Tue, 16 May 2017 05:30:02 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y65so121211275pff.13
        for <linux-mm@kvack.org>; Tue, 16 May 2017 02:30:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p2si10380354pfg.78.2017.05.16.02.30.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 May 2017 02:30:01 -0700 (PDT)
Date: Tue, 16 May 2017 11:29:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: per-cgroup memory reclaim stats
Message-ID: <20170516092956.GF2481@dhcp22.suse.cz>
References: <1494530183-30808-1-git-send-email-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1494530183-30808-1-git-send-email-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 11-05-17 20:16:23, Roman Gushchin wrote:
> Track the following reclaim counters for every memory cgroup:
> PGREFILL, PGSCAN, PGSTEAL, PGACTIVATE, PGDEACTIVATE, PGLAZYFREE and
> PGLAZYFREED.

yes, those are definitely useful. I have an old patch to add them as
well but never managed to clean it up and post...

> These values are exposed using the memory.stats interface of cgroup v2.

Is there any reason to not add them to v1? This should be rather trivial
after recent changes from Johannes.

> The meaning of each value is the same as for global counters,
> available using /proc/vmstat.
> 
> Also, for consistency, rename mem_cgroup_count_vm_event() to
> count_memcg_event_mm().
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Li Zefan <lizefan@huawei.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: cgroups@vger.kernel.org
> Cc: linux-doc@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org

the patch itself looks good to me. I will have to double check it after
I am done with what I am doing currently and then will add my Acked-by
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
