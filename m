Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 103486B0265
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 09:20:01 -0500 (EST)
Date: Tue, 13 Dec 2011 15:19:57 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: clean up soft_limit_tree properly new
Message-ID: <20111213141957.GC30440@tiehlicka.suse.cz>
References: <CAJd=RBB_AoJmyPd7gfHn+Kk39cn-+Wn-pFvU0ZWRZhw2fxoihw@mail.gmail.com>
 <alpine.LSU.2.00.1112111520510.2297@eggly>
 <20111212131118.GA15249@tiehlicka.suse.cz>
 <CAJd=RBAZT0zVnMm7i7P4J9Qg+LvTYh25RwFP7JZnN9dxwWp55g@mail.gmail.com>
 <20111212140750.GE14720@tiehlicka.suse.cz>
 <20111212140935.GF14720@tiehlicka.suse.cz>
 <20111213140844.GB1818@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111213140844.GB1818@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Balbir Singh <bsingharora@gmail.com>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 13-12-11 15:08:44, Johannes Weiner wrote:
> On Mon, Dec 12, 2011 at 03:09:35PM +0100, Michal Hocko wrote:
> > And a follow up patch for the proper clean up:
> > ---
> > >From 4b9f5a1e88496af9f336d1ef37cfdf3754a3ba48 Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.cz>
> > Date: Mon, 12 Dec 2011 15:04:18 +0100
> > Subject: [PATCH] memcg: clean up soft_limit_tree properly
> > 
> > If we are not able to allocate tree nodes for all NUMA nodes then we
> > should better clean up those that were allocated otherwise we will leak
> > a memory.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks

> 
> That being said, I think it's unlikely that the machine even boots
> properly if those allocations fail.  But the code looks better this
> way and one doesn't have to double take, wondering if anyone else is
> taking care of the already allocated objects.

Yes, that was the point of the patch - just a cleanup. I do not think we
want to push it into stable...

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
