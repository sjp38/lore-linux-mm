Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B6E266B0005
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 10:12:30 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id p129so83157345wmp.3
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 07:12:30 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id jp9si31592189wjc.237.2016.08.01.07.12.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Aug 2016 07:12:29 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id i5so26365334wmg.2
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 07:12:29 -0700 (PDT)
Date: Mon, 1 Aug 2016 16:12:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg: put soft limit reclaim out of way if the excess
 tree is empty
Message-ID: <20160801141227.GI13544@dhcp22.suse.cz>
References: <1470045621-14335-1-git-send-email-mhocko@kernel.org>
 <20160801135757.GB19395@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160801135757.GB19395@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 01-08-16 16:57:57, Vladimir Davydov wrote:
> On Mon, Aug 01, 2016 at 12:00:21PM +0200, Michal Hocko wrote:
> ...
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index c265212bec8c..eb7e39c2d948 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -2543,6 +2543,11 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
> >  	return ret;
> >  }
> >  
> > +static inline bool soft_limit_tree_empty(struct mem_cgroup_tree_per_node *mctz)
> > +{
> > +	return rb_last(&mctz->rb_root) == NULL;
> > +}
> > +
> 
> I don't think traversing rb tree as rb_last() does w/o holding the lock
> is a good idea. Why is RB_EMPTY_ROOT() insufficient here?

Of course it is not. Dohh, forgot to refresh the patch! Sorry about
that.

Updated patch.
---
