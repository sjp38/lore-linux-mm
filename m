Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6479D6B003D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 01:04:40 -0400 (EDT)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2C54YdF021281
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 10:34:34 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2C54grs1732762
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 10:34:42 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2C54XF9001890
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 16:04:34 +1100
Date: Thu, 12 Mar 2009 10:34:23 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 0/5] memcg softlimit (Another one) v4
Message-ID: <20090312050423.GI23583@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090312095247.bf338fe8.kamezawa.hiroyu@jp.fujitsu.com> <20090312034647.GA23583@balbir.in.ibm.com> <20090312133949.130b20ed.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090312133949.130b20ed.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-12 13:39:49]:

> On Thu, 12 Mar 2009 09:16:47 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-12 09:52:47]:
> > I've tested so far by
> > 
> > Creating two cgroups and then 
> > 
> > a. Assigning limits of 1G and 2G and run memory allocation and touch
> > test
> softlimit ?
>

Yes
 
> > b. Same as (a) with 1G and 1G
> > c. Same as (a) with 0 and 1G
> > d. Same as (a) with 0 and 0
> > 
> > More comments in induvidual patches.
> > 
> Then,
>   1. what's the number of active threads ?

One for each process in the two groups

>   2. what's the number of cpus ?

4

>   3. what's the numa configuration, if numa ?

Fake NUMA with nodes = 4, I have DMA, DMA32 and NORMAL split across
nodes.

>   4. what's the zone configuration ?
>   5. what's arch ?
>   6. what's amount of total memory ?

I have 4GB on x86-64 system (Quad Core)

>   7. Do you find difference in behavior with and without softlimit ?

Very much so.. I see the resources being shared as defined by soft
limits.

>   8. Do you tested *this* version ?
> 

Not yet.. you just posted it. I am testing my v5, which I'll post
soon. I am seeing very good results with v5. I'll test yours later
today.

> Thanks,
> -Kame

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
