Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5ACC3280753
	for <linux-mm@kvack.org>; Sat, 20 May 2017 15:15:28 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id l188so5983932lfg.2
        for <linux-mm@kvack.org>; Sat, 20 May 2017 12:15:28 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id i3si6540478ljd.148.2017.05.20.12.15.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 May 2017 12:15:26 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id q24so2317858lfb.1
        for <linux-mm@kvack.org>; Sat, 20 May 2017 12:15:26 -0700 (PDT)
Date: Sat, 20 May 2017 22:15:22 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH] mm: per-cgroup memory reclaim stats
Message-ID: <20170520191522.GA7065@esperanza>
References: <1494530183-30808-1-git-send-email-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1494530183-30808-1-git-send-email-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, May 11, 2017 at 08:16:23PM +0100, Roman Gushchin wrote:
> Track the following reclaim counters for every memory cgroup:
> PGREFILL, PGSCAN, PGSTEAL, PGACTIVATE, PGDEACTIVATE, PGLAZYFREE and
> PGLAZYFREED.
> 
> These values are exposed using the memory.stats interface of cgroup v2.
> 
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

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
