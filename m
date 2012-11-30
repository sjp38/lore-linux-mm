Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 8F1B96B00C3
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 10:49:15 -0500 (EST)
Date: Fri, 30 Nov 2012 16:49:12 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/4] cgroup: warn about broken hierarchies only after
 css_online
Message-ID: <20121130154912.GM29317@dhcp22.suse.cz>
References: <1354282286-32278-1-git-send-email-glommer@parallels.com>
 <1354282286-32278-2-git-send-email-glommer@parallels.com>
 <20121130151158.GB3873@htj.dyndns.org>
 <50B8CD32.4080807@parallels.com>
 <20121130154504.GD3873@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121130154504.GD3873@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>

On Fri 30-11-12 07:45:04, Tejun Heo wrote:
> Hello, Glauber.
> 
> On Fri, Nov 30, 2012 at 07:13:54PM +0400, Glauber Costa wrote:
> > > Applied to cgroup/for-3.8.  Thanks!
> > > 
> > 
> > We just need to be careful because when we merge it with morton's, more
> > bits will need converting.
> 
> This one is in cgrou proper and I think it should be safe, right?
> Other ones will be difficult.  Not sure how to handle them ATM.  An
> easy way out would be deferring to the next merge window as it's so
> close anyway.  Michal?

yes, I think so as well. I guess the window will open soon.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
