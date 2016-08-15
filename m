Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id A4D356B0261
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 11:33:59 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id n8so102535118ybn.2
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 08:33:59 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id d191si15827620wme.111.2016.08.15.08.33.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Aug 2016 08:33:58 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id i5so11715544wmg.2
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 08:33:58 -0700 (PDT)
Date: Mon, 15 Aug 2016 17:33:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH stable-4.4 1/3] mm: memcontrol: fix cgroup creation
 failure after many small jobs
Message-ID: <20160815153356.GI3360@dhcp22.suse.cz>
References: <1471273606-15392-1-git-send-email-mhocko@kernel.org>
 <1471273606-15392-2-git-send-email-mhocko@kernel.org>
 <20160815152236.GA10569@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160815152236.GA10569@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <greg@kroah.com>
Cc: Stable tree <stable@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Nikolay Borisov <kernel@kyup.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Mon 15-08-16 17:22:36, Greg KH wrote:
> On Mon, Aug 15, 2016 at 05:06:44PM +0200, Michal Hocko wrote:
[...]
> > diff --git a/mm/slab_common.c b/mm/slab_common.c
> > index 3c6a86b4ec25..312ef6f7b7b1 100644
> > --- a/mm/slab_common.c
> > +++ b/mm/slab_common.c
> > @@ -522,7 +522,7 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
> >  
> >  	cgroup_name(css->cgroup, memcg_name_buf, sizeof(memcg_name_buf));
> >  	cache_name = kasprintf(GFP_KERNEL, "%s(%d:%s)", root_cache->name,
> > -			       css->id, memcg_name_buf);
> > +			       css->serial_nr, memcg_name_buf);
> 
> You didn't pick up my change for the string here that the kbuild system
> found.  I'll edit it by hand...

Will repost with this fixed as well.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
