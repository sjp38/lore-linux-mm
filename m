Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 3E43B6B005D
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 12:25:05 -0400 (EDT)
Date: Tue, 4 Sep 2012 18:25:01 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] memcg: first step towards hierarchical controller
Message-ID: <20120904162501.GE15683@dhcp22.suse.cz>
References: <1346687211-31848-1-git-send-email-glommer@parallels.com>
 <20120903170806.GA21682@dhcp22.suse.cz>
 <5045BD25.10301@parallels.com>
 <20120904130905.GA15683@dhcp22.suse.cz>
 <504601B8.2050907@parallels.com>
 <20120904143552.GB15683@dhcp22.suse.cz>
 <50461241.5010300@parallels.com>
 <20120904145414.GC15683@dhcp22.suse.cz>
 <50461610.30305@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50461610.30305@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Dave Jones <davej@redhat.com>, Ben Hutchings <ben@decadent.org.uk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lennart Poettering <lennart@poettering.net>, Kay Sievers <kay.sievers@vrfy.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>

On Tue 04-09-12 18:54:08, Glauber Costa wrote:
[...]
> >> I'd personally believe merging both our patches together would achieve a
> >> good result.
> > 
> > I am still not sure we want to add a config option for something that is
> > meant to go away. But let's see what others think.
> > 
> 
> So what you propose in the end is that we add a userspace tweak for
> something that could go away, instead of a Kconfig for something that go
> away.

The tweak is necessary only if you want to have use_hierarchy=1 for all
cgroups without taking care about that (aka setting the attribute for
the first level under the root). All the users that use only one level
bellow root don't have to do anything at all.

> Way I see it, Kconfig is better because it is totally transparent, under
> the hood, and will give us a single location to unpatch in case/when it
> really goes away.

I guess that by the single location you mean that no other user space
changes would have to be done, right? If yes then this is not true
because there will be a lot of configurations setting this up already
(either by cgconfig or by other scripts). All of them will have to be
fixed some day.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
