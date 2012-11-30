Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id AB6B08D0001
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 10:45:10 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so538217pbc.14
        for <linux-mm@kvack.org>; Fri, 30 Nov 2012 07:45:10 -0800 (PST)
Date: Fri, 30 Nov 2012 07:45:04 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/4] cgroup: warn about broken hierarchies only after
 css_online
Message-ID: <20121130154504.GD3873@htj.dyndns.org>
References: <1354282286-32278-1-git-send-email-glommer@parallels.com>
 <1354282286-32278-2-git-send-email-glommer@parallels.com>
 <20121130151158.GB3873@htj.dyndns.org>
 <50B8CD32.4080807@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50B8CD32.4080807@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

Hello, Glauber.

On Fri, Nov 30, 2012 at 07:13:54PM +0400, Glauber Costa wrote:
> > Applied to cgroup/for-3.8.  Thanks!
> > 
> 
> We just need to be careful because when we merge it with morton's, more
> bits will need converting.

This one is in cgrou proper and I think it should be safe, right?
Other ones will be difficult.  Not sure how to handle them ATM.  An
easy way out would be deferring to the next merge window as it's so
close anyway.  Michal?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
