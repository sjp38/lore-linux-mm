Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id A917F6B007D
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 13:41:15 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so535920pad.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2012 10:41:14 -0800 (PST)
Date: Wed, 14 Nov 2012 10:41:10 -0800
From: Tejun Heo <htejun@gmail.com>
Subject: Re: [RFC] rework mem_cgroup iterator
Message-ID: <20121114184110.GD21185@mtj.dyndns.org>
References: <1352820639-13521-1-git-send-email-mhocko@suse.cz>
 <50A3C42F.9020901@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50A3C42F.9020901@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>

Hello, Glauber.

On Wed, Nov 14, 2012 at 05:17:51PM +0100, Glauber Costa wrote:
> Why can't we reuse the scheduler iterator and move it to kernel/cgroup.c
> ? It already exists, provide sane ordering, and only relies on parent
> information - which cgroup core already have - to do the walk.

Hmmm... we can but I personally much prefer for_each_*() iterators
over callback based ones.  It's just much easier to share states
across an iteration and follow the logic.  walk_tg_tree_from() does
have the benefit of being able to combine pre and post visits in the
same walk, which doesn't seem to have any user at the moment.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
