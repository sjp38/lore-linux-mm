Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8C5CF6B0006
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 17:44:27 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id u8-v6so9187820pfn.18
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 14:44:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 33-v6sor3651230plo.42.2018.08.06.14.44.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Aug 2018 14:44:26 -0700 (PDT)
Date: Mon, 6 Aug 2018 14:44:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 1/3] mm: introduce mem_cgroup_put() helper
In-Reply-To: <20180802003201.817-2-guro@fb.com>
Message-ID: <alpine.DEB.2.21.1808061444120.43071@chino.kir.corp.google.com>
References: <20180802003201.817-1-guro@fb.com> <20180802003201.817-2-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>

On Wed, 1 Aug 2018, Roman Gushchin wrote:

> Introduce the mem_cgroup_put() helper, which helps to eliminate guarding
> memcg css release with "#ifdef CONFIG_MEMCG" in multiple places.
> 
> Link: http://lkml.kernel.org/r/20180623000600.5818-2-guro@fb.com
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Reviewed-by: Shakeel Butt <shakeelb@google.com>
> Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Michal Hocko <mhocko@kernel.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

Acked-by: David Rientjes <rientjes@google.com>
