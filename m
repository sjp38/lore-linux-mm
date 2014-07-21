Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 1AE306B003A
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 09:22:18 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id ho1so4063872wib.10
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 06:22:17 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fx6si27959923wjb.172.2014.07.21.06.22.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Jul 2014 06:22:16 -0700 (PDT)
Date: Mon, 21 Jul 2014 15:22:13 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH] memcg: export knobs for the defaul cgroup hierarchy
Message-ID: <20140721132213.GE8393@dhcp22.suse.cz>
References: <1405521578-19988-1-git-send-email-mhocko@suse.cz>
 <20140716155814.GZ29639@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140716155814.GZ29639@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Wed 16-07-14 11:58:14, Johannes Weiner wrote:
> On Wed, Jul 16, 2014 at 04:39:38PM +0200, Michal Hocko wrote:
[...]
> > +#ifdef CONFIG_MEMCG_KMEM
> > +	{
> > +		.name = "kmem.limit_in_bytes",
> > +		.private = MEMFILE_PRIVATE(_KMEM, RES_LIMIT),
> > +		.write = mem_cgroup_write,
> > +		.read_u64 = mem_cgroup_read_u64,
> > +	},
> 
> Does it really make sense to have a separate limit for kmem only?

It seems that needs furhter discussion so I will drop it in next version
of the patch and we can enable it or move to a single knob for U+K
later.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
