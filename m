Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5FA705F0001
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 03:47:57 -0400 (EDT)
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp07.au.ibm.com (8.13.1/8.13.1) with ESMTP id n387mdm9026120
	for <linux-mm@kvack.org>; Wed, 8 Apr 2009 17:48:39 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n387mdLb1101884
	for <linux-mm@kvack.org>; Wed, 8 Apr 2009 17:48:39 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n387mcMr032406
	for <linux-mm@kvack.org>; Wed, 8 Apr 2009 17:48:39 +1000
Date: Wed, 8 Apr 2009 13:18:09 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFI] Shared accounting for memory resource controller
Message-ID: <20090408074809.GF7082@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090407071825.GR7082@balbir.in.ibm.com> <20090407163331.8e577170.kamezawa.hiroyu@jp.fujitsu.com> <20090407080355.GS7082@balbir.in.ibm.com> <20090407172419.a5f318b9.kamezawa.hiroyu@jp.fujitsu.com> <20090408052904.GY7082@balbir.in.ibm.com> <20090408151529.fd6626c2.kamezawa.hiroyu@jp.fujitsu.com> <20090408070401.GC7082@balbir.in.ibm.com> <20090408160733.4813cb8d.kamezawa.hiroyu@jp.fujitsu.com> <20090408071115.GD7082@balbir.in.ibm.com> <20090408161824.26f47077.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090408161824.26f47077.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, Rik van Riel <riel@surriel.com>, Bharata B Rao <bharata.rao@in.ibm.com>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-08 16:18:24]:

> On Wed, 8 Apr 2009 12:41:15 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-08 16:07:33]:
> > 1. First our rss in memory.stat is confusing, we should call it anon
> > RSS
> ok. but ....changing current interface ?
> 

No, lets just a new field called file_rss and make sure the
documentation reflects the correct information.

> > 2. We need to add file rss, this is sort of inline with the
> > information we export per process file_rss and anon_rss
> 
> maybe good. *but* active/incative ratio in lru file cache is good estimation for this.

Active/Inactive tell us about frequently a page is referenced rather
than what is mapped and what is not. We could get very bad results if
we make an assumption.

> 
> > 3. Using the above, we can then try to (using an algorithm you
> > proposed), try to do some work for figuring out the shared percentage.
> > 
> This is the point. At last. Why "# of shared pages" is important ?
> 

I posted this in my motivation yesterday. # of shared pages can help
plan the system better and the size of the cgroup. A cgroup might have
small usage_in_bytes but large number of shared pages. We need a
metric that can help figure out the fair usage of the cgroup.

> I wonder it's better to add new stat file as memory.cacheinfo which helps
> following kind of commands.
> 
>   #cacheinfo /cgroups/memory/group01/
>        /usr/lib/libc.so.1     30pages
>        /var/log/messages      1 pages
>        /tmp/xxxxxx            20 pages
>        .....
>        .....
>

But, what I need at the moment is shared usage information.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
