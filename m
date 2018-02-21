Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0DC296B0006
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 15:17:19 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 17so2344069wrm.10
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 12:17:19 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z192si16674446wmc.251.2018.02.21.12.17.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Feb 2018 12:17:17 -0800 (PST)
Date: Wed, 21 Feb 2018 12:17:15 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 2/2] mm/memcontrol.c: Reduce reclaim retries in
 mem_cgroup_resize_limit()
Message-Id: <20180221121715.0233d34dda330c56e1a9db5f@linux-foundation.org>
In-Reply-To: <20180119151118.GE6584@dhcp22.suse.cz>
References: <20171220102429.31601-1-aryabinin@virtuozzo.com>
	<20180119132544.19569-1-aryabinin@virtuozzo.com>
	<20180119132544.19569-2-aryabinin@virtuozzo.com>
	<20180119133510.GD6584@dhcp22.suse.cz>
	<CALvZod7HS6P0OU6Rps8JeMJycaPd4dF5NjxV8k1y2-yosF2bdA@mail.gmail.com>
	<20180119151118.GE6584@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Shakeel Butt <shakeelb@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Fri, 19 Jan 2018 16:11:18 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> And to be honest, I do not really see why keeping retrying from
> mem_cgroup_resize_limit should be so much faster than keep retrying from
> the direct reclaim path. We are doing SWAP_CLUSTER_MAX batches anyway.
> mem_cgroup_resize_limit loop adds _some_ overhead but I am not really
> sure why it should be that large.

Maybe restarting the scan lots of times results in rescanning lots of
ineligible pages at the start of the list before doing useful work?

Andrey, are you able to determine where all that CPU time is being spent?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
