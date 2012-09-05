Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 4612F6B005A
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 16:12:44 -0400 (EDT)
Received: by dadi14 with SMTP id i14so649840dad.14
        for <linux-mm@kvack.org>; Wed, 05 Sep 2012 13:12:43 -0700 (PDT)
Date: Wed, 5 Sep 2012 13:12:38 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2] memcg: first step towards hierarchical controller
Message-ID: <20120905201238.GE13737@google.com>
References: <5045BD25.10301@parallels.com>
 <20120904130905.GA15683@dhcp22.suse.cz>
 <504601B8.2050907@parallels.com>
 <20120904143552.GB15683@dhcp22.suse.cz>
 <50461241.5010300@parallels.com>
 <20120904145414.GC15683@dhcp22.suse.cz>
 <50461610.30305@parallels.com>
 <20120904162501.GE15683@dhcp22.suse.cz>
 <504709D4.2010800@parallels.com>
 <20120905144942.GH5388@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120905144942.GH5388@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@parallels.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Dave Jones <davej@redhat.com>, Ben Hutchings <ben@decadent.org.uk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lennart Poettering <lennart@poettering.net>, Kay Sievers <kay.sievers@vrfy.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

Hello, Michal.

On Wed, Sep 05, 2012 at 04:49:42PM +0200, Michal Hocko wrote:
> Can we settle on the following 3 steps?
> 1) warn about "flat" hierarchies (give it X releases) - I will push it
>    to as many Suse code streams as possible (hope other distributions
>    could do the same)

I think I'm just gonna trigger WARN from cgroup core if anyone tries
to create hierarchy with a controller which doesn't support full
hierarchy.  WARN_ON_ONCE() at first and then WARN_ON() on each
creation later on.

> 2) flip the default on the root cgroup & warn when somebody tries to
>    change it to 0 (give it another X releases) that the knob will be
>    removed
> 3) remove the knob and the whole nonsese
> 4) revert 3 if somebody really objects

If we can get to 3, I don't think 4 would be a problem.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
