Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id C58FC6B0253
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 13:15:29 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id jz4so3978890wjb.5
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 10:15:29 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b11si1186049wra.299.2017.01.18.10.15.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 10:15:28 -0800 (PST)
Date: Wed, 18 Jan 2017 19:15:21 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Update][PATCH v5 7/9] mm/swap: Add cache for swap slots
 allocation
Message-ID: <20170118181520.GB17135@dhcp22.suse.cz>
References: <cover.1484082593.git.tim.c.chen@linux.intel.com>
 <35de301a4eaa8daa2977de6e987f2c154385eb66.1484082593.git.tim.c.chen@linux.intel.com>
 <87tw8ymm2z.fsf_-_@yhuang-dev.intel.com>
 <20170117214234.GA14383@linux.intel.com>
 <20170118124555.GQ7015@dhcp22.suse.cz>
 <20170118180327.GA24225@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170118180327.GA24225@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Tim C Chen <tim.c.chen@intel.com>

On Wed 18-01-17 10:03:27, Tim Chen wrote:
> On Wed, Jan 18, 2017 at 01:45:55PM +0100, Michal Hocko wrote:
> > On Tue 17-01-17 13:42:35, Tim Chen wrote:
> > [...]
> > > Logic wise, We do allow pre-emption as per cpu ptr cache->slots is
> > > protected by the mutex cache->alloc_lock.  We switch the
> > > inappropriately used this_cpu_ptr to raw_cpu_ptr for per cpu ptr
> > > access of cache->slots.
> > 
> > OK, that looks better. I would still appreciate something like the
> > following folded in
> > diff --git a/include/linux/swap_slots.h b/include/linux/swap_slots.h
> > index fb907346c5c6..0afe748453a7 100644
> > --- a/include/linux/swap_slots.h
> > +++ b/include/linux/swap_slots.h
> > @@ -11,6 +11,7 @@
> >  
> >  struct swap_slots_cache {
> >  	bool		lock_initialized;
> > +	/* protects slots, nr, cur */
> >  	struct mutex	alloc_lock;
> >  	swp_entry_t	*slots;
> >  	int		nr;
> > 
> 
> I've included here a patch for the comments.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
