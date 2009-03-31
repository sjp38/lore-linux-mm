Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8663C6B003D
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 02:56:53 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2V6vjO5015206
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 31 Mar 2009 15:57:45 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5501F45DE4F
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 15:57:45 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A27045DD72
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 15:57:45 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3640E1DB8037
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 15:57:45 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E95E4E18001
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 15:57:41 +0900 (JST)
Date: Tue, 31 Mar 2009 15:56:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] memcg soft limit (yet another new design) v1
Message-Id: <20090331155614.8ad0c9b2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090331064901.GK16497@balbir.in.ibm.com>
References: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com>
	<20090328181100.GB26686@balbir.in.ibm.com>
	<20090328182747.GA8339@balbir.in.ibm.com>
	<20090331085538.2aaa5e2b.kamezawa.hiroyu@jp.fujitsu.com>
	<20090331050055.GF16497@balbir.in.ibm.com>
	<20090331140502.813993cc.kamezawa.hiroyu@jp.fujitsu.com>
	<20090331061010.GJ16497@balbir.in.ibm.com>
	<20090331152843.e1db942b.kamezawa.hiroyu@jp.fujitsu.com>
	<20090331064901.GK16497@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 31 Mar 2009 12:19:02 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> > 
> > > > Nothing special boot options. My test was on VMware 2cpus/1.6GB memory.
> > > > 
> > > > I wonder why swapout can be 0 on your test. Do you add some extra hooks to
> > > > kswapd ?
> > > >
> > > 
> > > Nope.. no special hooks to kswapd. B never enters the RB-Tree and thus
> > > never hits the memcg soft limit reclaim path. kswapd can reclaim from
> > > it, but it grows back quickly.
> > Why grows back ? tasks in B sleeps ?
> 
> Since B continuously consumes memory
> 
Not sleep ?

In my test
 1. malloc 1GB and touch all and sleep in B. Wait until the memory usage in B
    goes up to 1024MB. This never wake up until 3. 
 2. run make in group A.
 3. kill malloc program.

Then why why continuously consumes memory ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
