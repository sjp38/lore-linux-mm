Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E23586B003D
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 04:27:42 -0500 (EST)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp04.au.ibm.com (8.14.3/8.13.1) with ESMTP id o079OEVe031495
	for <linux-mm@kvack.org>; Thu, 7 Jan 2010 20:24:14 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o079NCLx1347732
	for <linux-mm@kvack.org>; Thu, 7 Jan 2010 20:23:12 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o079Rc50012494
	for <linux-mm@kvack.org>; Thu, 7 Jan 2010 20:27:39 +1100
Date: Thu, 7 Jan 2010 14:57:36 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC] Shared page accounting for memory cgroup
Message-ID: <20100107092736.GW3059@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100104093528.04846521.kamezawa.hiroyu@jp.fujitsu.com>
 <20100104005030.GG16187@balbir.in.ibm.com>
 <20100106130258.a918e047.kamezawa.hiroyu@jp.fujitsu.com>
 <20100106070150.GL3059@balbir.in.ibm.com>
 <20100106161211.5a7b600f.kamezawa.hiroyu@jp.fujitsu.com>
 <20100107071554.GO3059@balbir.in.ibm.com>
 <20100107163610.aaf831e6.kamezawa.hiroyu@jp.fujitsu.com>
 <20100107083440.GS3059@balbir.in.ibm.com>
 <20100107174814.ad6820db.kamezawa.hiroyu@jp.fujitsu.com>
 <20100107180800.7b85ed10.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100107180800.7b85ed10.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-01-07 18:08:00]:

> On Thu, 7 Jan 2010 17:48:14 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > "How pages are shared" doesn't show good hints. I don't hear such parameter
> > > > is used in production's resource monitoring software.
> > > > 
> > > 
> > > You mean "How many pages are shared" are not good hints, please see my
> > > justification above. With Virtualization (look at KSM for example),
> > > shared pages are going to be increasingly important part of the
> > > accounting.
> > > 
> > 
> > Considering KSM, your cuounting style is tooo bad.
> > 
> > You should add 
> > 
> >  - MEM_CGROUP_STAT_SHARED_BY_KSM
> >  - MEM_CGROUP_STAT_FOR_TMPFS/SYSV_IPC_SHMEM
> > 

No.. I am just talking about shared memory being important and shared
accounting being useful, no counters for KSM in particular (in the
memcg context).

> > counters to memcg rather than scanning. I can help tests.
> > 
> > I have no objections to have above 2 counters. It's informative.
> > 

Apart from those two, I want to provide what Pss provides today or an
approximation of it.

> > But, memory reclaim can page-out pages even if pages are shared.
> > So, "how heavy memcg is" is an independent problem from above coutners.
> > 
> 
> In other words, above counters can show
> "What role the memcg play in the system" to some extent.
> 
> But I don't express it as "heavy" ....."importance or influence of cgroup" ?
> 
> Thanks,
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
