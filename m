Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id CF5D26B006C
	for <linux-mm@kvack.org>; Fri, 23 Nov 2012 05:36:16 -0500 (EST)
Received: by mail-vb0-f41.google.com with SMTP id v13so11430792vbk.14
        for <linux-mm@kvack.org>; Fri, 23 Nov 2012 02:36:15 -0800 (PST)
Date: Fri, 23 Nov 2012 11:36:12 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] cgroup: helper do determine group name
Message-ID: <20121123103612.GI24698@dhcp22.suse.cz>
References: <1353580190-14721-1-git-send-email-glommer@parallels.com>
 <1353580190-14721-2-git-send-email-glommer@parallels.com>
 <20121123085532.GC24698@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121123085532.GC24698@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>

On Fri 23-11-12 09:55:32, Michal Hocko wrote:
[...]
> Besides that rcu_read_{un}lock are not necessary if you keep the
> reference, right? The last dput happens only after the last css_put.

Stupid me. And of course rcu_dereference_check would tell me the truth
 
> > +const char *cgroup_name(const struct cgroup *cgrp)
> > +{
> > +	struct dentry *dentry;
> > +	rcu_read_lock();
> > +	dentry = rcu_dereference_check(cgrp->dentry, cgroup_lock_is_held());
> > +	rcu_read_unlock();
> > +	return dentry->d_name.name;
> > +}
> > +
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
