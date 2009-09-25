Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C1A336B0055
	for <linux-mm@kvack.org>; Sat, 26 Sep 2009 00:56:01 -0400 (EDT)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp06.au.ibm.com (8.14.3/8.13.1) with ESMTP id n8Q4u5va026352
	for <linux-mm@kvack.org>; Sat, 26 Sep 2009 14:56:05 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8Q4rq7e1482910
	for <linux-mm@kvack.org>; Sat, 26 Sep 2009 14:53:52 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n8Q4u5YX030335
	for <linux-mm@kvack.org>; Sat, 26 Sep 2009 14:56:05 +1000
Date: Fri, 25 Sep 2009 13:55:47 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 0/10] memcg  clean up and some fixes for softlimit
 (Sep25)
Message-ID: <20090925082547.GA4160@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090925171721.b1bbbbe2.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090925171721.b1bbbbe2.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-09-25 17:17:21]:

> 
> As I posted Sep/18, I'm now planning to make memcontrol.c cleaner.
> I'll post this to Andrew in the next week if no objections.
> (IOW, I'll post this again. So, review itself is not very urgent.)
>

Sure, please do, personally I would like to see the
batched-charge/uncharge patches first, due to their impact on users
and potential gain.
 
> In this version, I dropped batched-charge/uncharge set.
> They includes something delicate and should not be discussed in this thread.
> The patches are organized as..
> 
> Clean up/ fix softlimit charge/uncharge under hierarchy.
> 1. softlimit uncharge fix
> 2. softlimit charge fix
> These 2 are not changed for 3 weeks.
> 
> Followings are new (no functional changes.)
> 3.  reorder layout in memcontrol.c
> 4.  memcg_charge_cancel.patch from Nishimura's one
> 5.  clean up for memcg's percpu statistics
> 6.  removing unsued macro
> 7.  rename "cont" to "cgroup"
> 8.  remove unused check in charge/uncharge
> 9.  clean up for memcg's perzone statistics
> 10. Add commentary.
> 
> Because my commentary is tend to be not very good, review
> for 10. is helpful ;)
> 
> I think this kind of fixes should be done while -mm queue is empty.
> Then, do this first.
> 
> 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
