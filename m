Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7ED306B0095
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 00:53:21 -0400 (EDT)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp09.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2P4orX8011939
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 10:20:53 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2P5F2Tc3670086
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 10:45:02 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2P5IWF8001533
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 16:18:33 +1100
Date: Wed, 25 Mar 2009 10:48:17 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/5] Memory controller soft limit organize cgroups (v7)
Message-ID: <20090325051816.GG24227@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain> <20090319165735.27274.96091.sendpatchset@localhost.localdomain> <20090325140752.01609cf5.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090325140752.01609cf5.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-25 14:07:52]:

> On Thu, 19 Mar 2009 22:27:35 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > @@ -938,16 +1031,17 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
> >  		int ret;
> >  		bool noswap = false;
> >  
> In logical, plz add
>   soft_fail_res = NULL, here.
>

As an optimization? OK, done!
 
> 
> > -		ret = res_counter_charge(&mem->res, PAGE_SIZE, &fail_res);
> > +		ret = res_counter_charge(&mem->res, PAGE_SIZE, &fail_res,
> > +						&soft_fail_res);
> 
> -Kame
> 
> 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
