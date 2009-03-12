Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3ACA06B003D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 05:54:09 -0400 (EDT)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp08.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2C9Q2ul000451
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 14:56:02 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2C9op5G4260020
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 15:20:51 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2C9s3Ck006719
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 20:54:03 +1100
Date: Thu, 12 Mar 2009 15:23:59 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 0/5] memcg softlimit (Another one) v4
Message-ID: <20090312095359.GB4335@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090312095247.bf338fe8.kamezawa.hiroyu@jp.fujitsu.com> <20090312034647.GA23583@balbir.in.ibm.com> <20090312133949.130b20ed.kamezawa.hiroyu@jp.fujitsu.com> <20090312050423.GI23583@balbir.in.ibm.com> <20090312143212.50818cd5.kamezawa.hiroyu@jp.fujitsu.com> <20090312082646.GA5828@balbir.in.ibm.com> <20090312174544.536d562c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090312174544.536d562c.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-12 17:45:44]:

> On Thu, 12 Mar 2009 13:56:46 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-12 14:32:12]:
> > 
> > > On Thu, 12 Mar 2009 10:34:23 +0530
> > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > 
> > > > Not yet.. you just posted it. I am testing my v5, which I'll post
> > > > soon. I am seeing very good results with v5. I'll test yours later
> > > > today.
> > > > 
> > > 
> > > If "hooks" to usual path doesn't exist and there are no global locks,
> > > I don't have much concern with your version.
> > 
> > Good to know. I think it is always good to have competing patches and
> > then collaborating and getting the best in.
> > 
> > > But 'sorting' seems to be overkill to me.
> > > 
> > 
> > Sorting is very useful, specially if you have many cgroups. Without
> > sorting, how do we select what group to select first.
> > 
> As I explained, if round-robin works well, ordering has no meaning.
> That's just a difference of what is the fairness.
> 
>   1. In your method, recalaim at first from the user which exceeds the most
>      is fair.
>   2. In my method, reclaim from each cgroup in round robin is fair.
> 
> No big issue to users if the kernel policy is fixed.
> Why I take "2" is that the usage of memcg doesn't mean the usage in the zone,
> so, there are no big difference between 1 and 2 on NUMA.
>

Round robin can be bad for soft limits. If an application started up
way ahead of others, but had a small soft limit, we would like
resources to be properly allocated when the second application comes
up. As the number of cgroups increase, selecting the correct cgroup to
reclaim from is going to be a challenge without sorting.

Having said that, I need to do more testing with your patches. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
