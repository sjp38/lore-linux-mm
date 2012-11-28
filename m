Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id B60386B00A9
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 11:48:26 -0500 (EST)
Date: Wed, 28 Nov 2012 17:48:24 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -v2 -mm] memcg: do not trigger OOM from
 add_to_page_cache_locked
Message-ID: <20121128164824.GC22201@dhcp22.suse.cz>
References: <20121126013855.AF118F5E@pobox.sk>
 <20121126131837.GC17860@dhcp22.suse.cz>
 <50B403CA.501@jp.fujitsu.com>
 <20121127194813.GP24381@cmpxchg.org>
 <20121127205431.GA2433@dhcp22.suse.cz>
 <20121127205944.GB2433@dhcp22.suse.cz>
 <20121128152631.GT24381@cmpxchg.org>
 <20121128160447.GH12309@dhcp22.suse.cz>
 <20121128163736.GV24381@cmpxchg.org>
 <20121128164640.GB22201@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121128164640.GB22201@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>

On Wed 28-11-12 17:46:40, Michal Hocko wrote:
> On Wed 28-11-12 11:37:36, Johannes Weiner wrote:
> > On Wed, Nov 28, 2012 at 05:04:47PM +0100, Michal Hocko wrote:
> > > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > > index 095d2b4..5abe441 100644
> > > --- a/include/linux/memcontrol.h
> > > +++ b/include/linux/memcontrol.h
> > > @@ -57,13 +57,14 @@ extern int mem_cgroup_newpage_charge(struct page *page, struct mm_struct *mm,
> > >  				gfp_t gfp_mask);
> > >  /* for swap handling */
> > >  extern int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
> > > -		struct page *page, gfp_t mask, struct mem_cgroup **memcgp);
> > > +		struct page *page, gfp_t mask, struct mem_cgroup **memcgp,
> > > +		bool oom);
> > 
> > Ok, now I feel almost bad for asking, but why the public interface,
> > too?
> 
> Would it work out if I tell it was to double check that your review
> quality is not decreased after that many revisions? :P
> 
> Incremental update and the full patch in the reply
---
