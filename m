Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
	by kanga.kvack.org (Postfix) with ESMTP id 522806B0038
	for <linux-mm@kvack.org>; Fri,  2 May 2014 05:46:25 -0400 (EDT)
Received: by mail-ee0-f46.google.com with SMTP id d49so235713eek.5
        for <linux-mm@kvack.org>; Fri, 02 May 2014 02:46:24 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 43si1135800eer.57.2014.05.02.02.46.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 02 May 2014 02:46:23 -0700 (PDT)
Date: Fri, 2 May 2014 11:46:22 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 4/4] memcg: Document memory.low_limit_in_bytes
Message-ID: <20140502094622.GE3446@dhcp22.suse.cz>
References: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
 <1398688005-26207-5-git-send-email-mhocko@suse.cz>
 <20140430225748.GE26041@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140430225748.GE26041@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed 30-04-14 18:57:48, Johannes Weiner wrote:
> On Mon, Apr 28, 2014 at 02:26:45PM +0200, Michal Hocko wrote:
> > Describe low_limit_in_bytes and its effect.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > ---
> >  Documentation/cgroups/memory.txt | 9 +++++++++
> >  1 file changed, 9 insertions(+)
> > 
> > diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> > index add1be001416..a52913fe96fb 100644
> > --- a/Documentation/cgroups/memory.txt
> > +++ b/Documentation/cgroups/memory.txt
> > @@ -57,6 +57,7 @@ Brief summary of control files.
> >   memory.memsw.usage_in_bytes	 # show current res_counter usage for memory+Swap
> >  				 (See 5.5 for details)
> >   memory.limit_in_bytes		 # set/show limit of memory usage
> > + memory.low_limit_in_bytes	 # set/show low limit for memory reclaim
> >   memory.memsw.limit_in_bytes	 # set/show limit of memory+Swap usage
> >   memory.failcnt			 # show the number of memory usage hits limits
> >   memory.memsw.failcnt		 # show the number of memory+Swap hits limits
> > @@ -249,6 +250,14 @@ is the objective of the reclaim. The global reclaim aims at balancing
> >  zones' watermarks while the limit reclaim frees some memory to allow new
> >  charges.
> >  
> > +Groups might be also protected from both global and limit reclaim by
> > +low_limit_in_bytes knob. If the limit is non-zero the reclaim logic
> > +doesn't include groups (and their subgroups - see 6. Hierarchy support)
> > +which are bellow the low limit if there is other eligible cgroup in the
> 
> 'below' :-) Although I really like that spello.

ups
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
