Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 711C36B003D
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 02:16:03 -0500 (EST)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp05.au.ibm.com (8.14.3/8.13.1) with ESMTP id o077Cj7I012934
	for <linux-mm@kvack.org>; Thu, 7 Jan 2010 18:12:45 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o077BZ9B868546
	for <linux-mm@kvack.org>; Thu, 7 Jan 2010 18:11:36 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o077Fvar015419
	for <linux-mm@kvack.org>; Thu, 7 Jan 2010 18:15:58 +1100
Date: Thu, 7 Jan 2010 12:45:54 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC] Shared page accounting for memory cgroup
Message-ID: <20100107071554.GO3059@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20091229182743.GB12533@balbir.in.ibm.com>
 <20100104085108.eaa9c867.kamezawa.hiroyu@jp.fujitsu.com>
 <20100104000752.GC16187@balbir.in.ibm.com>
 <20100104093528.04846521.kamezawa.hiroyu@jp.fujitsu.com>
 <20100104005030.GG16187@balbir.in.ibm.com>
 <20100106130258.a918e047.kamezawa.hiroyu@jp.fujitsu.com>
 <20100106070150.GL3059@balbir.in.ibm.com>
 <20100106161211.5a7b600f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100106161211.5a7b600f.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-01-06 16:12:11]:

> On Wed, 6 Jan 2010 12:31:50 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > No. If it takes long time, locking fork()/exit() for such long time is the bigger
> > > issue.
> > > I recommend you to add memacct subsystem to sum up RSS of all processes's RSS counting
> > > under a cgroup.  Althoght it may add huge costs in page fault path but implementation
> > > will be very simple and will not hurt realtime ops.
> > > There will be no terrible race, I guess.
> > >
> > 
> > But others hold that lock as well, simple thing like listing tasks and
> > moving tasks, etc. I expect the usage of shared to be in the same
> > range.
> > 
> 
> And piles up costs ? I think cgroup guys should pay attention to fork/exit
> costs more. Now, it gets slower and slower.
> In that point, I never like migrate-at-task-move work in cpuset and memcg.
> 
> My 1st objection to this patch is this "shared" doesn't mean "shared between
> cgroup" but means "shared between processes".
> I think it's of no use and no help to users.
>

So what in your opinion would help end users? My concern is that as
we make progress with memcg, we account only for privately used pages
with no hint/data about the real usage (shared within or with other
cgroups). How do we decide if one cgroup is really heavy?
 
> And implementation is 2nd thing.
> 

More details on your concern, please!

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
