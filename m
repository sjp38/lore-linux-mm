Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id CBDDE6B005D
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 13:56:48 -0400 (EDT)
Date: Thu, 27 Sep 2012 19:56:43 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3 04/13] kmem accounting basic infrastructure
Message-ID: <20120927175643.GA7777@dhcp22.suse.cz>
References: <50637298.2090904@parallels.com>
 <20120926221046.GA10453@mtj.dyndns.org>
 <506381B2.2060806@parallels.com>
 <20120926224235.GB10453@mtj.dyndns.org>
 <50638793.7060806@parallels.com>
 <20120926230807.GC10453@mtj.dyndns.org>
 <20120927142822.GG3429@suse.de>
 <20120927144942.GB4251@mtj.dyndns.org>
 <50646977.40300@parallels.com>
 <20120927174605.GA2713@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120927174605.GA2713@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Glauber Costa <glommer@parallels.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>

On Thu 27-09-12 10:46:05, Tejun Heo wrote:
[...]
> > > The part I nacked is enabling kmemcg on a populated cgroup and then
> > > starting accounting from then without any apparent indication that any
> > > past allocation hasn't been considered.  You end up with numbers which
> > > nobody can't tell what they really mean and there's no mechanism to
> > > guarantee any kind of ordering between populating the cgroup and
> > > configuring it and there's *no* way to find out what happened
> > > afterwards neither.  This is properly crazy and definitely deserves a
> > > nack.
> > > 
> > 
> > Mel suggestion of not allowing this to happen once the cgroup has tasks
> > takes care of this, and is something I thought of myself.
> 
> You mean Michal's?  It should also disallow switching if there are
> children cgroups, right?

Right.
 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
