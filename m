Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1EECA6B00A5
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 00:34:25 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2N5WcEX021056
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 23 Mar 2009 14:32:39 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A896145DE53
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 14:32:38 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8485745DE4F
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 14:32:38 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E4981DB803E
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 14:32:38 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2282E1DB8037
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 14:32:38 +0900 (JST)
Date: Mon, 23 Mar 2009 14:31:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/5] Memory controller soft limit patches (v7)
Message-Id: <20090323143112.7f7302e2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090323052247.GJ24227@balbir.in.ibm.com>
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain>
	<20090323125005.0d8a7219.kamezawa.hiroyu@jp.fujitsu.com>
	<20090323052247.GJ24227@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Mar 2009 10:52:47 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> > please add text to explain the behaior, what happens in the following situation.
> > 
> > 
> >    /group_A .....softlimit=100M usage=ANON=1G,FILE=1M
> >    /group_B .....softlimit=200M usage=ANON=1G,FILE=1M
> >    /group_C .....softlimit=300M
> >    on swap-available/swap-less/swap-full system.
> > 
> >   And Run run "dd" or "cp" of big files under group_C.
> 
> That depends on the memory on the system, on my system with 4G, things
> run just fine.
> 
fine ?

> I tried the following
> 
>         /group_A soft_limit=100M, needed memory=3200M (allocate and touch)
>         /group_B soft_limit=200M, needed memory=3200M
>         /group_C soft_limit=300M, needed memory=1024M (dd in a while loop)
> 
> group_B and group_A had a difference of 200M in their allocations on
> average. group_C touched 800M as maximum usage in bytes and around
> 500M on the average.
> 
> With swap turned off
> 
> group_C was hit the most with a lot of reclaim taking place on it.
> group_A was OOM killed and immediately after group_B got all the
> memory it needed and completed successfully.

Hmm ? OOM-Kill seems to happen without "dd" in group C...

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
