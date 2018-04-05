Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 00B3F6B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 15:32:19 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id i3so2627274wmf.7
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 12:32:19 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 22si1645507edt.374.2018.04.05.12.32.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 05 Apr 2018 12:32:18 -0700 (PDT)
Date: Thu, 5 Apr 2018 15:32:13 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v3 1/4] mm: rename page_counter's count/limit into
 usage/max
Message-ID: <20180405193213.GA27918@cmpxchg.org>
References: <20180405185921.4942-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180405185921.4942-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Apr 05, 2018 at 07:59:18PM +0100, Roman Gushchin wrote:
> This patch renames struct page_counter fields:
>   count -> usage
>   limit -> max
> 
> and the corresponding functions:
>   page_counter_limit() -> page_counter_set_max()
>   mem_cgroup_get_limit() -> mem_cgroup_get_max()
>   mem_cgroup_resize_limit() -> mem_cgroup_resize_max()
>   memcg_update_kmem_limit() -> memcg_update_kmem_max()
>   memcg_update_tcp_limit() -> memcg_update_tcp_max()
> 
> The idea behind this renaming is to have the direct matching
> between memory cgroup knobs (low, high, max) and page_counters API.
> 
> This is pure renaming, this patch doesn't bring any functional change.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: kernel-team@fb.com
> Cc: linux-mm@kvack.org
> Cc: cgroups@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org

Acked-by: Johannes Weiner <hannes@cmpxchg.org>
