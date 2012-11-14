Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 174496B0087
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 13:46:31 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so620870pbc.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2012 10:46:30 -0800 (PST)
Date: Wed, 14 Nov 2012 10:46:25 -0800
From: Tejun Heo <htejun@gmail.com>
Subject: Re: [RFC] rework mem_cgroup iterator
Message-ID: <20121114184625.GE21185@mtj.dyndns.org>
References: <1352820639-13521-1-git-send-email-mhocko@suse.cz>
 <50A3C42F.9020901@parallels.com>
 <20121114184110.GD21185@mtj.dyndns.org>
 <50A45729.4000203@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50A45729.4000203@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>

Hello,

On Thu, Nov 15, 2012 at 06:44:57AM +0400, Glauber Costa wrote:
> Is there any particular reason why we can't do the other way around
> then, and use a for_each_*() for sched walks? Without even consider what
> I personally prefer, what I really don't like is to have two different
> cgroup walkers when it seems like we could very well have just one.

Ooh, sure thing, let's do that.  Will work on that.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
