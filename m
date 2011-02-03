Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id ADED88D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 10:03:13 -0500 (EST)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp01.in.ibm.com (8.14.4/8.13.1) with ESMTP id p13F386N002291
	for <linux-mm@kvack.org>; Thu, 3 Feb 2011 20:33:08 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p13F2nUS1867988
	for <linux-mm@kvack.org>; Thu, 3 Feb 2011 20:32:49 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p13F2nR0013773
	for <linux-mm@kvack.org>; Thu, 3 Feb 2011 20:32:49 +0530
Date: Thu, 3 Feb 2011 20:32:47 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: memcg: save 20% of per-page memcg memory overhead
Message-ID: <20110203150247.GD16409@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1296743166-9412-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1296743166-9412-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

* Johannes Weiner <hannes@cmpxchg.org> [2011-02-03 15:26:01]:

> This patch series removes the direct page pointer from struct
> page_cgroup, which saves 20% of per-page memcg memory overhead (Fedora
> and Ubuntu enable memcg per default, openSUSE apparently too).
> 
> The node id or section number is encoded in the remaining free bits of
> pc->flags which allows calculating the corresponding page without the
> extra pointer.
> 
> I ran, what I think is, a worst-case microbenchmark that just cats a
> large sparse file to /dev/null, because it means that walking the LRU
> list on behalf of per-cgroup reclaim and looking up pages from
> page_cgroups is happening constantly and at a high rate.  But it made
> no measurable difference.  A profile reported a 0.11% share of the new
> lookup_cgroup_page() function in this benchmark.

Wow! defintely worth a deeper look.

> 
> 	Hannes

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
