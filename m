Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id EAD978E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 05:12:21 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id c3so35176733eda.3
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 02:12:21 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t39si1157562edd.319.2019.01.04.02.12.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 02:12:20 -0800 (PST)
Date: Fri, 4 Jan 2019 11:12:16 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: memory cgroup pagecache and inode problem
Message-ID: <20190104101216.GM31793@dhcp22.suse.cz>
References: <15614FDC-198E-449B-BFAF-B00D6EF61155@bytedance.com>
 <20190104090441.GI31793@dhcp22.suse.cz>
 <E699E11E-32B9-4061-93BD-54FE52F972BA@bytedance.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <E699E11E-32B9-4061-93BD-54FE52F972BA@bytedance.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fam Zheng <zhengfeiran@bytedance.com>
Cc: cgroups@vger.kernel.org, Linux MM <linux-mm@kvack.org>, tj@kernel.org, Johannes Weiner <hannes@cmpxchg.org>, lizefan@huawei.com, Vladimir Davydov <vdavydov.dev@gmail.com>, duanxiongchun@bytedance.com, =?utf-8?B?5byg5rC46IKD?= <zhangyongsu@bytedance.com>

On Fri 04-01-19 18:02:19, Fam Zheng wrote:
> 
> 
> > On Jan 4, 2019, at 17:04, Michal Hocko <mhocko@kernel.org> wrote:
> > 
> > This is a natural side effect of shared memory, I am afraid. Isolated
> > memory cgroups should limit any shared resources to bare minimum. You
> > will get "who touches first gets charged" behavior otherwise and that is
> > not really deterministic.
> 
> I don’t quite understand your comment. I think the current behavior
> for the ext4_inode_cachep slab family is just “who touches first
> gets charged”, and later users of the same file from a different mem
> cgroup can benefit from the cache, keep it from being released, but
> doesn’t get charged.

Yes, this is exactly what I've said. And that leads to non-deterministic
behavior because users from other memcgs are keeping charges alive and
the isolation really doesn't work properly. Think of it as using memory
on behalf of other party that is supposed to be isolated from you.

Sure this can work reasonably well if the sharing is not really
predominated.
-- 
Michal Hocko
SUSE Labs
