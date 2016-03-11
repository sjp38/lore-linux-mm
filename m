Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id B05876B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 07:39:09 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id tt10so97222768pab.3
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 04:39:09 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id fm6si6768723pab.122.2016.03.11.04.39.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 04:39:08 -0800 (PST)
Date: Fri, 11 Mar 2016 15:39:00 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] mm: memcontrol: zap
 task_struct->memcg_oom_{gfp_mask,order}
Message-ID: <20160311123900.GM1946@esperanza>
References: <1457691167-22756-1-git-send-email-vdavydov@virtuozzo.com>
 <20160311115450.GH27701@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160311115450.GH27701@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Mar 11, 2016 at 12:54:50PM +0100, Michal Hocko wrote:
> On Fri 11-03-16 13:12:47, Vladimir Davydov wrote:
> > These fields are used for dumping info about allocation that triggered
> > OOM. For cgroup this information doesn't make much sense, because OOM
> > killer is always invoked from page fault handler.
> 
> The oom killer is indeed invoked in a different context but why printing
> the original mask and order doesn't make any sense? Doesn't it help to
> see that the reclaim has failed because of GFP_NOFS?

I don't see how this can be helpful. How would you use it?

Wouldn't it be better to print err msg in try_charge anyway?

...
> So it doesn't even seem to save any space in the config I am using. Does
> it shrink the size of the structure for you?

There are several hundred bytes left in task_struct for its size to
exceed 2 pages threshold and hence increase slab order, but it doesn't
mean we don't need to be conservative and do our best to spare some
space for future users that can't live w/o adding new fields.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
