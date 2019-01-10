Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A96C28E0038
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 03:41:28 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id x15so4092102edd.2
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 00:41:28 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t4-v6si2226659eju.217.2019.01.10.00.41.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 00:41:27 -0800 (PST)
Date: Thu, 10 Jan 2019 09:41:25 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: memory cgroup pagecache and inode problem
Message-ID: <20190110084125.GF31793@dhcp22.suse.cz>
References: <15614FDC-198E-449B-BFAF-B00D6EF61155@bytedance.com>
 <97A4C2CA-97BA-46DB-964A-E44410BB1730@bytedance.com>
 <CAHbLzkouWtCQ3OVEK1FaJoG5ZbSkzsqmcAqmsb-TbuaO2myccQ@mail.gmail.com>
 <ADF3C74C-BE96-495F-911F-77DDF3368912@bytedance.com>
 <CAHbLzkpbVjtx+uxb1sq-wjBAAv_My6kq4c4bwqRKAmOTZ9dR8g@mail.gmail.com>
 <E2306860-760C-4EB2-92E3-057694971D69@bytedance.com>
 <CAHbLzkrE887hR_2o_1zJkBcReDt-KzezUE4Jug8zULdV7g17-w@mail.gmail.com>
 <9B56B884-8FDD-4BB5-A6CA-AD7F84397039@bytedance.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9B56B884-8FDD-4BB5-A6CA-AD7F84397039@bytedance.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fam Zheng <zhengfeiran@bytedance.com>
Cc: Yang Shi <shy828301@gmail.com>, cgroups@vger.kernel.org, Linux MM <linux-mm@kvack.org>, tj@kernel.org, Johannes Weiner <hannes@cmpxchg.org>, lizefan@huawei.com, Vladimir Davydov <vdavydov.dev@gmail.com>, duanxiongchun@bytedance.com, =?utf-8?B?5byg5rC46IKD?= <zhangyongsu@bytedance.com>, liuxiaozhou@bytedance.com

On Thu 10-01-19 16:30:42, Fam Zheng wrote:
[...]
> > 591edfb10a94 mm: drain memcg stocks on css offlining
> > d12c60f64cf8 mm: memcontrol: drain memcg stock on force_empty
> > bb4a7ea2b144 mm: memcontrol: drain stocks on resize limit
> > 
> > Not sure if they would help out.
> 
> These are all in 4.20, which is tested but not helpful.

I would recommend enabling vmscan tracepoints to see what is going on in
you case.
-- 
Michal Hocko
SUSE Labs
