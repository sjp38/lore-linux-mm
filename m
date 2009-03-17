Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C2AF86B0047
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 02:59:33 -0400 (EDT)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id n2H6x1hc015444
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 17:59:01 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2H6xicn389486
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 17:59:44 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2H6xQGq002393
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 17:59:26 +1100
Date: Tue, 17 Mar 2009 12:29:15 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention
	(v6)
Message-ID: <20090317065915.GO16897@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090316121915.GB16897@balbir.in.ibm.com> <20090317124740.d8356d01.kamezawa.hiroyu@jp.fujitsu.com> <20090317044016.GG16897@balbir.in.ibm.com> <20090317134727.62efc14e.kamezawa.hiroyu@jp.fujitsu.com> <20090317045850.GJ16897@balbir.in.ibm.com> <20090317141714.0899baec.kamezawa.hiroyu@jp.fujitsu.com> <20090317055506.GM16897@balbir.in.ibm.com> <20090317150058.5b8a96b9.kamezawa.hiroyu@jp.fujitsu.com> <20090317062205.GN16897@balbir.in.ibm.com> <20090317153046.55820ddb.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090317153046.55820ddb.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-17 15:30:46]:

> On Tue, 17 Mar 2009 11:52:05 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-17 15:00:58]:
> > 
> > > On Tue, 17 Mar 2009 11:25:06 +0530
> > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > 
> > > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-17 14:17:14]:
> > > > > > That is not true..we don't track them to default cgroup unless
> > > > > > memory.use_hiearchy is enabled in the root cgroup. 
> > > > > What I want to say is "the task which is not attached to user's cgroup is
> > > > > also under defaut cgroup, so we don't need additional hook"
> > > > > Not talking about hierarchy.
> > > > >
> > > > 
> > > > Since all the user pages are tracked in one or the other cgroup, the
> > > > total accounting is equal to total_lru_pages across all zones/nodes.
> > > > Your suggestion boils down to if total_lru_pages reaches a threshold,
> > > > do soft limit reclaim, instead of doing reclaim when there is
> > > > contention.. right?
> > > >  
> > > Yes.
> > >
> > 
> > May I suggest that we first do the reclaim on contention and then
> > later on enhance it to add sysctl vm.soft_limit_ratio. I am not
> > proposing the soft limit patches for 2.6.30, but I would like to get
> > them in -mm for wider testing. If in that process the sysctl seems
> > more useful and applicable, we can consider adding it. Adding it right
> > now makes the reclaim logic more complex, having to check if we hit
> > the vm ratio quite often. Do you agree?
> >  
> If you can fix zone issues and can answer all Kosaki's request.
> But you said "this all is not for memory shortage but for softlimit".
> It seems strange for me to modify memory reclaim path.
>

Kame, the reason for modifying those paths is just to invoke the soft
limit reclaimer. At some point we need to make a decision on the soft
limit reclaim and where to invoke it from.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
