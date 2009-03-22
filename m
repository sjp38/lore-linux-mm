Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3164E6B003D
	for <linux-mm@kvack.org>; Sun, 22 Mar 2009 19:01:46 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2MNsh0J005613
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 23 Mar 2009 08:54:43 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 75C8F45DE4F
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 08:54:43 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 57ACC45DD72
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 08:54:43 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 44EA11DB8037
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 08:54:43 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id EA1B31DB8038
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 08:54:39 +0900 (JST)
Date: Mon, 23 Mar 2009 08:53:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/5] Memory controller soft limit organize cgroups (v7)
Message-Id: <20090323085314.7cce6c50.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090322142105.GA24227@balbir.in.ibm.com>
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain>
	<20090319165735.27274.96091.sendpatchset@localhost.localdomain>
	<20090320124639.83d22726.kamezawa.hiroyu@jp.fujitsu.com>
	<20090322142105.GA24227@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sun, 22 Mar 2009 19:51:05 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> >         if (mem_cgroup_soft_limit_check(mem, &soft_fail_res)) {
> > 		mem_over_soft_limit =
> > 			mem_cgroup_from_res_counter(soft_fail_res, res);
> > 		mem_cgroup_update_tree(mem_over_soft_limit);
> > 	}
> > 
> > Then, we really do softlimit check once in interval.
> 
> OK, so the trade-off is - every once per interval,
> I need to walk up res_counters all over again, hold all locks and
> check. Like I mentioned earlier, with the current approach I've
> reduced the overhead significantly for non-users. Earlier I was seeing
> a small loss in output with reaim, but since I changed
> res_counter_uncharge to track soft limits, that difference is negligible
> now.
> 
> The issue I see with this approach is that if soft-limits were
> not enabled, even then we would need to walk up the hierarchy and do
> tests, where as embedding it in res_counter_charge, one simple check
> tells us we don't have more to do.
> 
Not at all.

just check softlimit is enabled or not in mem_cgroup_soft_limit_check() by some flag.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
