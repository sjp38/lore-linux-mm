Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id 2F7B76B0038
	for <linux-mm@kvack.org>; Wed, 28 May 2014 07:33:38 -0400 (EDT)
Received: by mail-we0-f179.google.com with SMTP id q59so10839090wes.24
        for <linux-mm@kvack.org>; Wed, 28 May 2014 04:33:37 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w6si13018686wif.33.2014.05.28.04.33.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 28 May 2014 04:33:33 -0700 (PDT)
Date: Wed, 28 May 2014 13:33:28 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 7/9] mm: memcontrol: do not acquire page_cgroup lock for
 kmem pages
Message-ID: <20140528113328.GG9895@dhcp22.suse.cz>
References: <1398889543-23671-1-git-send-email-hannes@cmpxchg.org>
 <1398889543-23671-8-git-send-email-hannes@cmpxchg.org>
 <20140523133938.GC22135@dhcp22.suse.cz>
 <20140527195342.GD2878@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140527195342.GD2878@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 27-05-14 15:53:42, Johannes Weiner wrote:
> On Fri, May 23, 2014 at 03:39:38PM +0200, Michal Hocko wrote:
[...]
> > >  	if (!PageCgroupUsed(pc))
> > >  		return;
> > >  
> > > -	lock_page_cgroup(pc);
> > > -	if (PageCgroupUsed(pc)) {
> > > -		memcg = pc->mem_cgroup;
> > > -		ClearPageCgroupUsed(pc);
> > > -	}
> > > -	unlock_page_cgroup(pc);
> > 
> > maybe add
> > 	WARN_ON_ONCE(pc->flags != PCG_USED);
> > 
> > to check for an unexpected flags usage in the kmem path?
> 
> There is no overlap between page types that use PCG_USED and those
> that don't.  What would be the value of adding this?

I meant it as an early warning that something bad is going on.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
