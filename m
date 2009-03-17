Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D95B76B003D
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 02:32:13 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2H6WBbe003339
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 17 Mar 2009 15:32:11 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 35DED45DD7D
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 15:32:11 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 863E445DD7F
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 15:32:09 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 62F22E18004
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 15:32:09 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E3C61DB8014
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 15:32:08 +0900 (JST)
Date: Tue, 17 Mar 2009 15:30:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention
 (v6)
Message-Id: <20090317153046.55820ddb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090317062205.GN16897@balbir.in.ibm.com>
References: <20090316113853.GA16897@balbir.in.ibm.com>
	<969730ee419be9fbe4aca3ec3249650e.squirrel@webmail-b.css.fujitsu.com>
	<20090316121915.GB16897@balbir.in.ibm.com>
	<20090317124740.d8356d01.kamezawa.hiroyu@jp.fujitsu.com>
	<20090317044016.GG16897@balbir.in.ibm.com>
	<20090317134727.62efc14e.kamezawa.hiroyu@jp.fujitsu.com>
	<20090317045850.GJ16897@balbir.in.ibm.com>
	<20090317141714.0899baec.kamezawa.hiroyu@jp.fujitsu.com>
	<20090317055506.GM16897@balbir.in.ibm.com>
	<20090317150058.5b8a96b9.kamezawa.hiroyu@jp.fujitsu.com>
	<20090317062205.GN16897@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Mar 2009 11:52:05 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-17 15:00:58]:
> 
> > On Tue, 17 Mar 2009 11:25:06 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-17 14:17:14]:
> > > > > That is not true..we don't track them to default cgroup unless
> > > > > memory.use_hiearchy is enabled in the root cgroup. 
> > > > What I want to say is "the task which is not attached to user's cgroup is
> > > > also under defaut cgroup, so we don't need additional hook"
> > > > Not talking about hierarchy.
> > > >
> > > 
> > > Since all the user pages are tracked in one or the other cgroup, the
> > > total accounting is equal to total_lru_pages across all zones/nodes.
> > > Your suggestion boils down to if total_lru_pages reaches a threshold,
> > > do soft limit reclaim, instead of doing reclaim when there is
> > > contention.. right?
> > >  
> > Yes.
> >
> 
> May I suggest that we first do the reclaim on contention and then
> later on enhance it to add sysctl vm.soft_limit_ratio. I am not
> proposing the soft limit patches for 2.6.30, but I would like to get
> them in -mm for wider testing. If in that process the sysctl seems
> more useful and applicable, we can consider adding it. Adding it right
> now makes the reclaim logic more complex, having to check if we hit
> the vm ratio quite often. Do you agree?
>  
If you can fix zone issues and can answer all Kosaki's request.
But you said "this all is not for memory shortage but for softlimit".
It seems strange for me to modify memory reclaim path.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
