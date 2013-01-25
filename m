Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id B2B446B0005
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 12:37:07 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id bg2so383131pad.18
        for <linux-mm@kvack.org>; Fri, 25 Jan 2013 09:37:06 -0800 (PST)
Date: Fri, 25 Jan 2013 09:37:01 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v4 0/6] replace cgroup_lock with memcg specific locking
Message-ID: <20130125173701.GH3081@htj.dyndns.org>
References: <1358862461-18046-1-git-send-email-glommer@parallels.com>
 <510258D0.6060407@parallels.com>
 <20130125101854.GC8876@dhcp22.suse.cz>
 <51025E2B.4080105@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51025E2B.4080105@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lord Glauber Costa of Sealand <glommer@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>

Hey,

On Fri, Jan 25, 2013 at 02:27:55PM +0400, Lord Glauber Costa of Sealand wrote:
> > I would vote to -mm. Or is there any specific reason to have it in
> > cgroup tree? It doesn't touch any cgroup core parts, does it?
> > 
> Copying Andrew (retroactively sorry you weren't directly CCd on this one
> as well).
> 
> I depend on css_online and the cgroup generic iterator. If they are
> already present @ -mm, then fine.
> (looking now, they seem to be...)

Yeah, they're all in cgroup/for-next so should be available in -mm, so
I think -mm probably is the better tree to route these.

Thanks!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
