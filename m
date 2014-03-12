Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id B77AC6B00B9
	for <linux-mm@kvack.org>; Wed, 12 Mar 2014 11:19:26 -0400 (EDT)
Received: by mail-we0-f179.google.com with SMTP id x48so11224254wes.24
        for <linux-mm@kvack.org>; Wed, 12 Mar 2014 08:19:26 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wu7si24021337wjb.140.2014.03.12.08.19.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 12 Mar 2014 08:19:25 -0700 (PDT)
Date: Wed, 12 Mar 2014 16:19:24 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 3/8] mm: memcg: inline mem_cgroup_charge_common()
Message-ID: <20140312151924.GH11831@dhcp22.suse.cz>
References: <1394587714-6966-1-git-send-email-hannes@cmpxchg.org>
 <1394587714-6966-4-git-send-email-hannes@cmpxchg.org>
 <20140312125213.GB11831@dhcp22.suse.cz>
 <20140312145300.GC14688@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140312145300.GC14688@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 12-03-14 10:53:00, Johannes Weiner wrote:
> On Wed, Mar 12, 2014 at 01:52:13PM +0100, Michal Hocko wrote:
> > On Tue 11-03-14 21:28:29, Johannes Weiner wrote:
> > [...]
> > > @@ -3919,20 +3919,21 @@ out:
> > >  	return ret;
> > >  }
> > >  
> > > -/*
> > > - * Charge the memory controller for page usage.
> > > - * Return
> > > - * 0 if the charge was successful
> > > - * < 0 if the cgroup is over its limit
> > > - */
> > > -static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
> > > -				gfp_t gfp_mask, enum charge_type ctype)
> > > +int mem_cgroup_newpage_charge(struct page *page,
> > > +			      struct mm_struct *mm, gfp_t gfp_mask)
> > 
> > s/mem_cgroup_newpage_charge/mem_cgroup_anon_charge/ ?
> > 
> > Would be a better name? The patch would be bigger but the name more
> > apparent...
> 
> I wouldn't be opposed to fixing those names at all, but I think that
> is out of the scope of this patch.

OK.

> Want to send one?

will do

> mem_cgroup_charge_anon() would be a good name, but then we should also
> rename mem_cgroup_cache_charge() to mem_cgroup_charge_file() to match.

Yes that sounds good to me.

> Or charge_private() vs. charge_shared()...

anon vs. file is easier to follow but I do not have any preference here.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
