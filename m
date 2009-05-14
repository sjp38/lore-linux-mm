Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 679476B014E
	for <linux-mm@kvack.org>; Wed, 13 May 2009 20:25:16 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4E0PcAr020317
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 14 May 2009 09:25:38 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F1F245DE4F
	for <linux-mm@kvack.org>; Thu, 14 May 2009 09:25:38 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D7B1445DE51
	for <linux-mm@kvack.org>; Thu, 14 May 2009 09:25:37 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id ADD39E08007
	for <linux-mm@kvack.org>; Thu, 14 May 2009 09:25:37 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5CBF0E08005
	for <linux-mm@kvack.org>; Thu, 14 May 2009 09:25:37 +0900 (JST)
Date: Thu, 14 May 2009 09:24:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Low overhead patches for the memory resource controller
Message-Id: <20090514092405.1c3e6134.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090514090802.c5ac2246.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090513153218.GQ13394@balbir.in.ibm.com>
	<20090514090802.c5ac2246.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 14 May 2009 09:08:02 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 13 May 2009 21:02:18 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > Important: Not for inclusion, for discussion only
> > 
> > I've been experimenting with a version of the patches below. They add
> > a PCGF_ROOT flag for tracking pages belonging to the root cgroup and
> > disable LRU manipulation for them
> > 
> > Caveats:
> > 
> > 1. I've not checked accounting, accounting might be broken
> > 2. I've not made the root cgroup as non limitable, we need to disable
> > hard limits once we agree to go with this
> > 
> > 
> > Tests
> > 
> > Quick tests show an improvement with AIM9
> > 
> >                 mmotm+patch     mmtom-08-may-2009
> > AIM9            1338.57         1338.17
> > Dbase           18034.16        16021.58
> > New Dbase       18482.24        16518.54
> > Shared          9935.98         8882.11
> > Compute         16619.81        15226.13
> > 
> > Comments on the approach much appreciated
> > 
> > Feature: Remove the overhead associated with the root cgroup
> > 
> > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > 
> > This patch changes the memory cgroup and removes the overhead associated
> > with accounting all pages in the root cgroup. As a side-effect, we can
> > no longer set a memory hard limit in the root cgroup.
> > 
> > A new flag is used to track page_cgroup associated with the root cgroup
> > pages.
> 
> Hmm ? How about ignoring memcg completely when the thread belongs to ROOT
> cgroup rather than this halfway method ? 
> 
BTW, this will make softlimit much harder. Do you have any idea on softlimit after
this patch ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
