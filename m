Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 31CCD6B0099
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 00:59:01 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2P5OL4T014108
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 25 Mar 2009 14:24:22 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9647645DE51
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 14:24:21 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 45AAB45DE4E
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 14:24:21 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 262C3E08002
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 14:24:21 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D6C0B1DB8037
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 14:24:20 +0900 (JST)
Date: Wed, 25 Mar 2009 14:22:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/5] Memory controller soft limit organize cgroups (v7)
Message-Id: <20090325142255.09e20c6e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090325051816.GG24227@balbir.in.ibm.com>
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain>
	<20090319165735.27274.96091.sendpatchset@localhost.localdomain>
	<20090325140752.01609cf5.kamezawa.hiroyu@jp.fujitsu.com>
	<20090325051816.GG24227@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Mar 2009 10:48:17 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-25 14:07:52]:
> 
> > On Thu, 19 Mar 2009 22:27:35 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > @@ -938,16 +1031,17 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
> > >  		int ret;
> > >  		bool noswap = false;
> > >  
> > In logical, plz add
> >   soft_fail_res = NULL, here.
> >
> 
> As an optimization? OK, done!
>  
Ah, sorry....I missed that pointer was automatically initilized to NULL in
res_counter_charge().
plz ignore..

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
