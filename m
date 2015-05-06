Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id A6E8C6B0038
	for <linux-mm@kvack.org>; Wed,  6 May 2015 09:46:24 -0400 (EDT)
Received: by wizk4 with SMTP id k4so203067273wiz.1
        for <linux-mm@kvack.org>; Wed, 06 May 2015 06:46:24 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v3si2276197wix.97.2015.05.06.06.46.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 06 May 2015 06:46:22 -0700 (PDT)
Date: Wed, 6 May 2015 15:46:20 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] gfp: add __GFP_NOACCOUNT
Message-ID: <20150506134620.GM14550@dhcp22.suse.cz>
References: <fdf631b3fa95567a830ea4f3e19d0b3b2fc99662.1430819044.git.vdavydov@parallels.com>
 <20150506115941.GH14550@dhcp22.suse.cz>
 <20150506131622.GA4629@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150506131622.GA4629@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 06-05-15 09:16:22, Johannes Weiner wrote:
> On Wed, May 06, 2015 at 01:59:41PM +0200, Michal Hocko wrote:
> > On Tue 05-05-15 12:45:42, Vladimir Davydov wrote:
> > > Not all kmem allocations should be accounted to memcg. The following
> > > patch gives an example when accounting of a certain type of allocations
> > > to memcg can effectively result in a memory leak.
> > 
> > > This patch adds the __GFP_NOACCOUNT flag which if passed to kmalloc
> > > and friends will force the allocation to go through the root
> > > cgroup. It will be used by the next patch.
> > 
> > The name of the flag is way too generic. It is not clear that the
> > accounting is KMEMCG related.
> 
> The memory controller is the (primary) component that accounts
> physical memory allocations in the kernel, so I don't see how this
> would be ambiguous in any way.

What if a high-level allocator wants to do some accounting as well?
E.g. slab allocator accounts {un}reclaimable pages. It is a different
thing because the accounting is per-cache rather than gfp based but I
just wanted to point out that accounting is rather a wide term.

> > __GFP_NO_KMEMCG sounds better?
> 
> I think that's much worse.  I would prefer communicating the desired
> behavior directly instead of having to derive it from a subsystem
> name.
> (And KMEMCG should not even be a term, it's all just the memory
> controller, i.e. memcg.)

I do not mind __GFP_NO_MEMCG either.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
