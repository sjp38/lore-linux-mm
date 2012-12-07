Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id BB1676B0073
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 04:01:37 -0500 (EST)
Date: Fri, 7 Dec 2012 10:01:35 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v2 3/6] memcg: rework mem_cgroup_iter to use cgroup
 iterators
Message-ID: <20121207090135.GC31938@dhcp22.suse.cz>
References: <1353955671-14385-1-git-send-email-mhocko@suse.cz>
 <1353955671-14385-4-git-send-email-mhocko@suse.cz>
 <CALWz4ixQR0vHp+mGJdi2q77dMHaG8BZmb+iKfMmT=T0V8X8rAg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALWz4ixQR0vHp+mGJdi2q77dMHaG8BZmb+iKfMmT=T0V8X8rAg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

On Thu 06-12-12 19:39:41, Ying Han wrote:
[...]
> Michal,
> 
> I got some trouble while running this patch with my test. The test
> creates hundreds of memcgs which each runs some workload to generate
> global pressure. At the last, it removes all the memcgs by rmdir. Then
> the cmd "ls /dev/cgroup/memory/" hangs afterwards.
>
> I studied a bit of the patch, but not spending too much time on it
> yet. Looks like that the v2 has something different from your last
> post, where you replaces the mem_cgroup_get() with css_get() on the
> iter->last_visited. Didn't follow why we made that change, but after
> restoring the behavior a bit seems passed my test.

Hmm, strange. css reference counting should be stronger than mem_cgroup
one because it pins css thus cgroup which in turn keeps memcg alive.

> Here is the patch I applied on top of this one:

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
