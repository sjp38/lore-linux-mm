Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 84F6A6B00BC
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 09:07:15 -0500 (EST)
Date: Tue, 17 Jan 2012 15:07:12 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: memcg: remove checking reclaim order in soft limit
 reclaim
Message-ID: <20120117140712.GC14907@tiehlicka.suse.cz>
References: <CAJd=RBBdDriMhfetM2AWGzgxiJ1DDs-W4Ff9_1Z8DUgbyQmSkA@mail.gmail.com>
 <20120117131601.GB14907@tiehlicka.suse.cz>
 <CAJd=RBBcL5RuW1wC_Yh=gy2Ja8wqJ6jhf28zNi1n6MJ=+0=m2Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBBcL5RuW1wC_Yh=gy2Ja8wqJ6jhf28zNi1n6MJ=+0=m2Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 17-01-12 21:29:52, Hillf Danton wrote:
> On Tue, Jan 17, 2012 at 9:16 PM, Michal Hocko <mhocko@suse.cz> wrote:
> > Hi,
> >
> > On Tue 17-01-12 20:47:59, Hillf Danton wrote:
> >> If async order-O reclaim expected here, it is settled down when setting up scan
> >> control, with scan priority hacked to be zero. Other than that, deny of reclaim
> >> should be removed.
> >
> > Maybe I have misunderstood you but this is not right. The check is to
> > protect from the _global_ reclaim with order > 0 when we prevent from
> > memcg soft reclaim.
> >
> need to bear mm hog in this way?

Could you be more specific? Are you trying to fix any particular
problem?

Global reclaim should take are of the global memory pressure. Soft
reclaim is intended just to make its job easier. Btw. softlimit reclaim
is on its way out of the kernel but this will not happen in 3.3.

> 
> Thanks
> Hillf
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

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
