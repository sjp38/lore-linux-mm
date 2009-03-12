Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id DD3686B0047
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 04:47:10 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2C8l74n023498
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 12 Mar 2009 17:47:07 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id F089345DD78
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 17:47:06 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A494F45DD76
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 17:47:06 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AA403E18001
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 17:47:06 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E2C6E08008
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 17:47:06 +0900 (JST)
Date: Thu, 12 Mar 2009 17:45:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/5] memcg softlimit (Another one) v4
Message-Id: <20090312174544.536d562c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090312082646.GA5828@balbir.in.ibm.com>
References: <20090312095247.bf338fe8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090312034647.GA23583@balbir.in.ibm.com>
	<20090312133949.130b20ed.kamezawa.hiroyu@jp.fujitsu.com>
	<20090312050423.GI23583@balbir.in.ibm.com>
	<20090312143212.50818cd5.kamezawa.hiroyu@jp.fujitsu.com>
	<20090312082646.GA5828@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 12 Mar 2009 13:56:46 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-12 14:32:12]:
> 
> > On Thu, 12 Mar 2009 10:34:23 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > Not yet.. you just posted it. I am testing my v5, which I'll post
> > > soon. I am seeing very good results with v5. I'll test yours later
> > > today.
> > > 
> > 
> > If "hooks" to usual path doesn't exist and there are no global locks,
> > I don't have much concern with your version.
> 
> Good to know. I think it is always good to have competing patches and
> then collaborating and getting the best in.
> 
> > But 'sorting' seems to be overkill to me.
> > 
> 
> Sorting is very useful, specially if you have many cgroups. Without
> sorting, how do we select what group to select first.
> 
As I explained, if round-robin works well, ordering has no meaning.
That's just a difference of what is the fairness.

  1. In your method, recalaim at first from the user which exceeds the most
     is fair.
  2. In my method, reclaim from each cgroup in round robin is fair.

No big issue to users if the kernel policy is fixed.
Why I take "2" is that the usage of memcg doesn't mean the usage in the zone,
so, there are no big difference between 1 and 2 on NUMA.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
