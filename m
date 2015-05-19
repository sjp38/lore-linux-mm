Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2E4FE6B00C3
	for <linux-mm@kvack.org>; Tue, 19 May 2015 10:51:02 -0400 (EDT)
Received: by wghq2 with SMTP id q2so21037874wgh.1
        for <linux-mm@kvack.org>; Tue, 19 May 2015 07:51:01 -0700 (PDT)
Received: from mail-wg0-x22f.google.com (mail-wg0-x22f.google.com. [2a00:1450:400c:c00::22f])
        by mx.google.com with ESMTPS id e3si21368599wjw.125.2015.05.19.07.51.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 May 2015 07:51:00 -0700 (PDT)
Received: by wgjc11 with SMTP id c11so21052104wgj.0
        for <linux-mm@kvack.org>; Tue, 19 May 2015 07:51:00 -0700 (PDT)
Date: Tue, 19 May 2015 16:53:40 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm, memcg: Optionally disable memcg by default using
 Kconfig
Message-ID: <20150519145340.GI6203@dhcp22.suse.cz>
References: <20150519104057.GC2462@suse.de>
 <20150519141807.GA9788@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150519141807.GA9788@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org

On Tue 19-05-15 10:18:07, Johannes Weiner wrote:
> CC'ing Tejun and cgroups for the generic cgroup interface part
> 
> On Tue, May 19, 2015 at 11:40:57AM +0100, Mel Gorman wrote:
[...]
> > /usr/src/linux-4.0-vanilla/mm/memcontrol.c                           6.6441   395842
> >   mem_cgroup_try_charge                                                        2.950%   175781
> 
> Ouch.  Do you have a way to get the per-instruction breakdown of this?
> This function really isn't doing much.  I'll try to reproduce it here
> too, I haven't seen such high costs with pft in the past.
> 
> >   try_charge                                                                   0.150%     8928
> >   get_mem_cgroup_from_mm                                                       0.121%     7184

Indeed! try_charge + get_mem_cgroup_from_mm which I would expect to be
the biggest consumers here are below 10% of the mem_cgroup_try_charge.
Other than that the function doesn't do much else than some flags
queries and css_put...

Do you have the full trace? Sorry for a stupid question but do inlines
from other header files get accounted to memcontrol.c?

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
