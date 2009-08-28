Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B62A56B004D
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 10:45:42 -0400 (EDT)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp07.in.ibm.com (8.14.3/8.13.1) with ESMTP id n7SEjfhC005251
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 20:15:41 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7SEjf912560204
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 20:15:41 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n7SEjfF1020181
	for <linux-mm@kvack.org>; Sat, 29 Aug 2009 00:45:41 +1000
Date: Fri, 28 Aug 2009 20:15:39 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 1/5] memcg: change for softlimit.
Message-ID: <20090828144539.GN4889@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090828132015.10a42e40.kamezawa.hiroyu@jp.fujitsu.com> <20090828132321.e4a497bb.kamezawa.hiroyu@jp.fujitsu.com> <20090828072007.GH4889@balbir.in.ibm.com> <20090828163523.e51678be.kamezawa.hiroyu@jp.fujitsu.com> <20090828132643.GM4889@balbir.in.ibm.com> <bfd50d44ff730c2720b882a81b7446c6.squirrel@webmail-b.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <bfd50d44ff730c2720b882a81b7446c6.squirrel@webmail-b.css.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-08-28 23:29:09]:

> Balbir Singh wrote:
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-08-28
> > 16:35:23]:
> >
> 
> >>
> >> Current soft-limit RB-tree will be easily broken i.e. not-sorted
> >> correctly
> >> if used under use_hierarchy=1.
> >>
> >
> > Not true, I think the sorted-ness is delayed and is seen when we pick
> > a tree for reclaim. Think of it as being lazy :)
> >
> plz explain how enexpectedly unsorted RB-tree can work sanely.
> 
>

There are two checks built-in

1. In the reclaim path (we see how much to reclaim, compared to the
soft limit)
2. In the dequeue path where we check if we really are over soft limit

I did lot of testing with the time based approach and found no broken
cases, I;ve been testing it with the mmotm (event based approach and I
am yet to see a broken case so far).

 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
