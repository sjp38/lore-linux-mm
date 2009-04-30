Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 483F66B003D
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 05:42:20 -0400 (EDT)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id n3U9gtuf008169
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 15:12:55 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3U9grwa2232528
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 15:12:55 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id n3U9grSd017707
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 19:42:53 +1000
Date: Thu, 30 Apr 2009 15:12:52 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] memcg: fix stale swap cache leak v5
Message-ID: <20090430094252.GG4430@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090430161627.0ccce565.kamezawa.hiroyu@jp.fujitsu.com> <20090430163539.7a882cef.kamezawa.hiroyu@jp.fujitsu.com> <20090430180426.25ae2fa6.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090430180426.25ae2fa6.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-30 18:04:26]:

> On Thu, 30 Apr 2009 16:35:39 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Thu, 30 Apr 2009 16:16:27 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > This is v5 but all codes are rewritten.
> > > 
> > > After this patch, when memcg is used,
> > >  1. page's swapcount is checked after I/O (without locks). If the page is
> > >     stale swap cache, freeing routine will be scheduled.
> > >  2. vmscan.c calls try_to_free_swap() when __remove_mapping() fails.
> > > 
> > > Works well for me. no extra resources and no races.
> > > 
> > > Because my office will be closed until May/7, I'll not be able to make a
> > > response. Posting this for showing what I think of now.
> > > 
> > I found a hole immediately after posted this...sorry. plz ignore this patch/
> > see you again in the next month.
> > 
> I'm now wondering to disable "swapin readahed" completely when memcg is used...
> Then, half of the problems will go away immediately.
> And it's not so bad to try to free swapcache if swap writeback ends. Then, another
> half will go away...
>

Could you clarify? Will memcg not account for swapin readahead pages?
 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
