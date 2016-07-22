Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4844A6B0253
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 04:18:31 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id w207so186478536oiw.1
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 01:18:31 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id l15si8783157wmi.0.2016.07.22.01.18.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jul 2016 01:18:30 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id i5so4975890wmg.2
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 01:18:30 -0700 (PDT)
Date: Fri, 22 Jul 2016 10:18:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] update sc->nr_reclaimed after each shrink_slab
Message-ID: <20160722081828.GE794@dhcp22.suse.cz>
References: <1469159010-5636-1-git-send-email-zhouchengming1@huawei.com>
 <20160722074913.GD794@dhcp22.suse.cz>
 <20160722081259.GE26049@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160722081259.GE26049@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Zhou Chengming <zhouchengming1@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, riel@redhat.com, guohanjun@huawei.com

On Fri 22-07-16 11:12:59, Vladimir Davydov wrote:
> On Fri, Jul 22, 2016 at 09:49:13AM +0200, Michal Hocko wrote:
> > On Fri 22-07-16 11:43:30, Zhou Chengming wrote:
> > > In !global_reclaim(sc) case, we should update sc->nr_reclaimed after each
> > > shrink_slab in the loop. Because we need the correct sc->nr_reclaimed
> > > value to see if we can break out.
> > 
> > Does this actually change anything? Maybe I am missing something but
> > try_to_free_mem_cgroup_pages which is the main entry for the memcg
> > reclaim doesn't set reclaim_state. I don't remember why... Vladimir?
> 
> We don't set reclaim_state on memcg reclaim, because there might be a
> lot of unrelated slab objects freed from the interrupt context (e.g.
> RCU freed) while we're doing memcg reclaim. Obviously, we don't want
> them to contribute to nr_reclaimed.
> 
> Link to the thread with the problem discussion:
> 
>   http://marc.info/?l=linux-kernel&m=142132698209680&w=2

Ohh, now I rememeber again. Thanks for the refresh ;)

So the patch doesn't make any difference in the end.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
