Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 49B206B0078
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 12:26:26 -0500 (EST)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp08.au.ibm.com (8.14.3/8.13.1) with ESMTP id o28HQIvM016517
	for <linux-mm@kvack.org>; Tue, 9 Mar 2010 04:26:18 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o28HQIii1847548
	for <linux-mm@kvack.org>; Tue, 9 Mar 2010 04:26:18 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o28HQHe6003394
	for <linux-mm@kvack.org>; Tue, 9 Mar 2010 04:26:18 +1100
Date: Mon, 8 Mar 2010 22:56:09 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 0/2]  memcg: oom notifier and handling oom by user
Message-ID: <20100308172609.GS3073@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100308162414.faaa9c5f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100308162414.faaa9c5f.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-03-08 16:24:14]:

> This 2 patches is for memcg's oom handling.
> 
> At first, memcg's oom doesn't mean "no more resource" but means "we hit limit."
> Then, daemons/user shells out of a memcg can work even if it's under oom.
> So, if we have notifier and some more features, we can do something moderate
> rather than killing at oom. 
> 
> This patch includes
> [1/2] oom notifier for memcg (using evetfd framework of cgroups.)
> [2/2] oom killer disalibing and hooks for waitq and wake-up.
> 
> When memcg's oom-killer is disabled, all tasks which request accountable memory
> will sleep in waitq. It will be waken up by user's action as
>  - enlarge limit. (memory or memsw)
>  - kill some tasks
>  - move some tasks (account migration is enabled.)
> 

Hmm... I've not seen the waitq and wake-up patches, but does that mean
user space will control resumtion of tasks?


-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
