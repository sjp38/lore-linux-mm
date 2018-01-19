Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C52666B027A
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 10:31:36 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id e26so2034967pgv.16
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 07:31:36 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r6-v6si454480pls.684.2018.01.19.07.31.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Jan 2018 07:31:35 -0800 (PST)
Date: Fri, 19 Jan 2018 16:31:32 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5 2/2] mm/memcontrol.c: Reduce reclaim retries in
 mem_cgroup_resize_limit()
Message-ID: <20180119153132.GF6584@dhcp22.suse.cz>
References: <20171220102429.31601-1-aryabinin@virtuozzo.com>
 <20180119132544.19569-1-aryabinin@virtuozzo.com>
 <20180119132544.19569-2-aryabinin@virtuozzo.com>
 <20180119133510.GD6584@dhcp22.suse.cz>
 <CALvZod7HS6P0OU6Rps8JeMJycaPd4dF5NjxV8k1y2-yosF2bdA@mail.gmail.com>
 <20180119151118.GE6584@dhcp22.suse.cz>
 <CALvZod6q8ExRW-EkG_eMyJeGhhMcbSQZMQEqmHEHj7PhRYwJ1w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod6q8ExRW-EkG_eMyJeGhhMcbSQZMQEqmHEHj7PhRYwJ1w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Fri 19-01-18 07:24:08, Shakeel Butt wrote:
[...]
> Thanks for the explanation. Another query, we do not call
> drain_all_stock() in mem_cgroup_resize_limit() but memory_max_write()
> does call drain_all_stock(). Was this intentional or missed
> accidentally?

I think it is just an omission. I would have to look closer but I am
just leaving now and will be back on Tuesday. This is unrelated so I
would rather discuss it in a separate email thread.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
