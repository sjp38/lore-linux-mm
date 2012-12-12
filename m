Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 8872F6B002B
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 14:24:45 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so381634eaa.14
        for <linux-mm@kvack.org>; Wed, 12 Dec 2012 11:24:43 -0800 (PST)
Date: Wed, 12 Dec 2012 20:24:41 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v2 3/6] memcg: rework mem_cgroup_iter to use cgroup
 iterators
Message-ID: <20121212192441.GD10374@dhcp22.suse.cz>
References: <1353955671-14385-1-git-send-email-mhocko@suse.cz>
 <1353955671-14385-4-git-send-email-mhocko@suse.cz>
 <CALWz4ixPmvguxQO8s9mqH+OLEXC5LDfzEVFx_qqe2hBaRcsXiA@mail.gmail.com>
 <20121211155432.GC1612@dhcp22.suse.cz>
 <CALWz4izL7fEuQhEvKa7mUqi0sa25mcFP-xnTnL3vU3Z17k7VHg@mail.gmail.com>
 <20121212090652.GB32081@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121212090652.GB32081@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

On Wed 12-12-12 10:06:52, Michal Hocko wrote:
> On Tue 11-12-12 14:36:10, Ying Han wrote:
[...]
> > One exception is mem_cgroup_iter_break(), where the loop terminates
> > with *leaked* refcnt and that is what the iter_break() needs to clean
> > up. We can not rely on the next caller of the loop since it might
> > never happen.
> 
> Yes, this is true and I already have a half baked patch for that. I
> haven't posted it yet but it basically checks all node-zone-prio
> last_visited and removes itself from them on the way out in pre_destroy
> callback (I just need to cleanup "find a new last_visited" part and will
> post it).

And a half baked patch - just compile tested
---
