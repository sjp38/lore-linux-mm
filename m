Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 364FD6B00CA
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 04:44:16 -0400 (EDT)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2N9kNci029314
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 15:16:23 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2N9kVCV4018324
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 15:16:31 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2N9kMZe008851
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 20:46:22 +1100
Date: Mon, 23 Mar 2009 15:16:10 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/5] Memory controller soft limit patches (v7)
Message-ID: <20090323094610.GS24227@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain> <20090323125005.0d8a7219.kamezawa.hiroyu@jp.fujitsu.com> <20090323052247.GJ24227@balbir.in.ibm.com> <20090323151245.d6430aaa.kamezawa.hiroyu@jp.fujitsu.com> <20090323151703.de2bf9db.kamezawa.hiroyu@jp.fujitsu.com> <20090323083506.GN24227@balbir.in.ibm.com> <20090323175223.94b644a0.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090323175223.94b644a0.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-23 17:52:23]:

> On Mon, 23 Mar 2009 14:05:06 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-23 15:17:03]:
> > Kame, if you dislike it please don't enable
> > memory.soft_limit_in_bytes. After having sent several revisions of
> > your own patchset and helping me with review of several revisions, your
> > sudden dislike comes as a surprise.
> 
> I can't think
>   - we need hook in mem_cgroup_charge/uncharge.
>   - RB-tree is good.
>   - don't taking care of kswad is enough
> 
> and memcg should be independent from global memory reclaim AMAP.
> 
> > Please NOTE: I am not saying we'll never see any of the reclaim
> > changes you are suggesting, all I am saying is lets do enough test to
> > prove it is needed. Lets get the functionality right and then optimize
> > if we have to.
> > 
> 
> But this itself is problem for me.
> 
> When we added
>   - hierarchy
>   - swap handling
>   - etc...
> 
> Almost all bug reports are from Nishimura and Li Zefan, not from *us*.
>

As long as we fix them, I don't care who reports bugs. I've been
testing the patches I have with various configurations, but not hard
enough at times. The advantage of -mm is that we get enough testing
through the contribution of folks like Li and Nishimura (which is very
much appreciated). I am not asking for these patches to go into
mainline, but for wider testing in -mm. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
