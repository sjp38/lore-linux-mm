Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 471C26B006C
	for <linux-mm@kvack.org>; Sun, 30 Sep 2012 04:02:57 -0400 (EDT)
Received: by padfa10 with SMTP id fa10so3925247pad.14
        for <linux-mm@kvack.org>; Sun, 30 Sep 2012 01:02:56 -0700 (PDT)
Date: Sun, 30 Sep 2012 17:02:49 +0900
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 04/13] kmem accounting basic infrastructure
Message-ID: <20120930080249.GF10383@mtj.dyndns.org>
References: <506381B2.2060806@parallels.com>
 <20120926224235.GB10453@mtj.dyndns.org>
 <50638793.7060806@parallels.com>
 <20120926230807.GC10453@mtj.dyndns.org>
 <20120927142822.GG3429@suse.de>
 <20120927144942.GB4251@mtj.dyndns.org>
 <50646977.40300@parallels.com>
 <20120927174605.GA2713@localhost>
 <50649EAD.2050306@parallels.com>
 <20120930075700.GE10383@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120930075700.GE10383@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>

On Sun, Sep 30, 2012 at 04:57:00PM +0900, Tejun Heo wrote:
> On Thu, Sep 27, 2012 at 10:45:01PM +0400, Glauber Costa wrote:
> > > Can you please give other examples of cases where this type of issue
> > > exists (plenty of shared kernel data structure which is inherent to
> > > the workload at hand)?  Until now, this has been the only example for
> > > this type of issues.
> > 
> > Yes. the namespace related caches (*), all kinds of sockets and network
> > structures, other file system structures like file struct, vm areas, and
> > pretty much everything a full container does.
> > 
> > (*) we run full userspace, so we have namespaces + cgroups combination.
> 
> This is probably me being dumb but wouldn't resources used by full
> namespaces be mostly independent?  Which parts get shared?  Also, if
> you do full namespace, isn't it more likely that you would want fuller
> resource isolation too?

Just a thought about dentry/inode.  Would it make sense to count total
number of references per cgroup and charge the total amount according
to that?  Reference counts are how the shared ownership is represented
after all.  Counting total per cgroup isn't accurate and pathological
cases could be weird tho.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
