Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B4AA78D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 18:50:39 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 93B7D3EE0BC
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 08:50:37 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7550845DE60
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 08:50:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C3C945DE5E
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 08:50:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B9EB1DB8038
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 08:50:37 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 15B6AE08004
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 08:50:37 +0900 (JST)
Date: Fri, 4 Feb 2011 08:44:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 2/2] memcg: simplify the way memory limits are checked
Message-Id: <20110204084433.c479a0af.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110203125611.GC2286@cmpxchg.org>
References: <1296482635-13421-1-git-send-email-hannes@cmpxchg.org>
	<1296482635-13421-3-git-send-email-hannes@cmpxchg.org>
	<20110131144131.6733aa3a.akpm@linux-foundation.org>
	<20110201000455.GB19534@cmpxchg.org>
	<20110131162448.e791f0ae.akpm@linux-foundation.org>
	<20110203125357.GA2286@cmpxchg.org>
	<20110203125611.GC2286@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, minchan.kim@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 3 Feb 2011 13:56:11 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

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

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
