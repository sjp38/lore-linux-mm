Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 414CC6B0099
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 03:20:13 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp09.in.ibm.com (8.14.3/8.13.1) with ESMTP id n7S7JYip019779
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 12:49:34 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7S7KApa999558
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 12:50:11 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n7S7K9Pt003211
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 17:20:10 +1000
Date: Fri, 28 Aug 2009 12:50:08 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 1/5] memcg: change for softlimit.
Message-ID: <20090828072007.GH4889@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090828132015.10a42e40.kamezawa.hiroyu@jp.fujitsu.com> <20090828132321.e4a497bb.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090828132321.e4a497bb.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-08-28 13:23:21]:

> This patch tries to modify softlimit handling in memcg/res_counter.
> There are 2 reasons in general.
> 
>  1. soft_limit can use only against sub-hierarchy root.
>     Because softlimit tree is sorted by usage, putting prural groups
>     under hierarchy (which shares usage) will just adds noise and unnecessary
>     mess. This patch limits softlimit feature only to hierarchy root.
>     This will make softlimit-tree maintainance better. 
> 
>  2. In these days, it's reported that res_counter can be bottleneck in
>     massively parallel enviroment. We need to reduce jobs under spinlock.
>     The reason we check softlimit at res_counter_charge() is that any member
>     in hierarchy can have softlimit.
>     But by chages in "1", only hierarchy root has soft_limit. We can omit
>     hierarchical check in res_counter.
> 
> After this patch, soft limit is avaliable only for root of sub-hierarchy.
> (Anyway, softlimit for hierarchy children just makes users confused, hard-to-use)
>


I need some time to digest this change, if the root is a hiearchy root
then only root can support soft limits? I think the change makes it
harder to use soft limits. Please help me understand better. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
