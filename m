Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id A88E58D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 23:12:21 -0500 (EST)
Received: by pzk27 with SMTP id 27so400545pzk.14
        for <linux-mm@kvack.org>; Thu, 03 Feb 2011 20:12:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110203125611.GC2286@cmpxchg.org>
References: <1296482635-13421-1-git-send-email-hannes@cmpxchg.org>
	<1296482635-13421-3-git-send-email-hannes@cmpxchg.org>
	<20110131144131.6733aa3a.akpm@linux-foundation.org>
	<20110201000455.GB19534@cmpxchg.org>
	<20110131162448.e791f0ae.akpm@linux-foundation.org>
	<20110203125357.GA2286@cmpxchg.org>
	<20110203125611.GC2286@cmpxchg.org>
Date: Fri, 4 Feb 2011 09:42:19 +0530
Message-ID: <AANLkTinNoCO7x4yTU_dxe-gB918i-2S6iz2Wrr5zzN2h@mail.gmail.com>
Subject: Re: [patch 2/2] memcg: simplify the way memory limits are checked
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, minchan.kim@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Feb 3, 2011 at 6:26 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> Since transparent huge pages, checking whether memory cgroups are
> below their limits is no longer enough, but the actual amount of
> chargeable space is important.
>
> To not have more than one limit-checking interface, replace
> memory_cgroup_check_under_limit() and memory_cgroup_check_margin()
> with a single memory_cgroup_margin() that returns the chargeable space
> and leaves the comparison to the callsite.
>
> Soft limits are now checked the other way round, by using the already
> existing function that returns the amount by which soft limits are
> exceeded: res_counter_soft_limit_excess().
>
> Also remove all the corresponding functions on the res_counter side
> that are now no longer used.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
