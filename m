Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 26D786B0169
	for <linux-mm@kvack.org>; Wed, 13 May 2009 22:57:08 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n4E2sELv023866
	for <linux-mm@kvack.org>; Wed, 13 May 2009 20:54:14 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4E2w0kj227094
	for <linux-mm@kvack.org>; Wed, 13 May 2009 20:58:00 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4E2vx7M007027
	for <linux-mm@kvack.org>; Wed, 13 May 2009 20:58:00 -0600
Date: Thu, 14 May 2009 08:09:30 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC] Low overhead patches for the memory resource controller
Message-ID: <20090514023930.GT13394@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090513153218.GQ13394@balbir.in.ibm.com> <20090514090802.c5ac2246.kamezawa.hiroyu@jp.fujitsu.com> <20090514092405.1c3e6134.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090514092405.1c3e6134.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-05-14 09:24:05]:

> On Thu, 14 May 2009 09:08:02 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Wed, 13 May 2009 21:02:18 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > Important: Not for inclusion, for discussion only
> > > 
> > > I've been experimenting with a version of the patches below. They add
> > > a PCGF_ROOT flag for tracking pages belonging to the root cgroup and
> > > disable LRU manipulation for them
> > > 
> > > Caveats:
> > > 
> > > 1. I've not checked accounting, accounting might be broken
> > > 2. I've not made the root cgroup as non limitable, we need to disable
> > > hard limits once we agree to go with this
> > > 
> > > 
> > > Tests
> > > 
> > > Quick tests show an improvement with AIM9
> > > 
> > >                 mmotm+patch     mmtom-08-may-2009
> > > AIM9            1338.57         1338.17
> > > Dbase           18034.16        16021.58
> > > New Dbase       18482.24        16518.54
> > > Shared          9935.98         8882.11
> > > Compute         16619.81        15226.13
> > > 
> > > Comments on the approach much appreciated
> > > 
> > > Feature: Remove the overhead associated with the root cgroup
> > > 
> > > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > > 
> > > This patch changes the memory cgroup and removes the overhead associated
> > > with accounting all pages in the root cgroup. As a side-effect, we can
> > > no longer set a memory hard limit in the root cgroup.
> > > 
> > > A new flag is used to track page_cgroup associated with the root cgroup
> > > pages.
> > 
> > Hmm ? How about ignoring memcg completely when the thread belongs to ROOT
> > cgroup rather than this halfway method ? 
> > 
> BTW, this will make softlimit much harder. Do you have any idea on softlimit after
> this patch ?
>

Why would this make soft limit much harder? Since we charge up
hierarchially even now we ignore a cgroup if its soft limit is not
set. I am not sure I understand why. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
