Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D28266B0047
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 19:59:01 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2UNxtDS026986
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 31 Mar 2009 08:59:55 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4862245DE54
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 08:59:55 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B2D845DD72
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 08:59:55 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 25CE2E18003
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 08:59:55 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A5C42E38003
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 08:59:54 +0900 (JST)
Date: Tue, 31 Mar 2009 08:58:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 4/8] memcg soft limit priority array queue.
Message-Id: <20090331085827.042fd4f1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090329165620.GB15608@balbir.in.ibm.com>
References: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com>
	<20090327140653.a12c6b1e.kamezawa.hiroyu@jp.fujitsu.com>
	<20090329165620.GB15608@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Sun, 29 Mar 2009 22:26:20 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-27 14:06:53]:
> 
> > I'm now search a way to reduce lock contention without complex...
> > -Kame
> > ==
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > +static void __mem_cgroup_requeue(struct mem_cgroup *mem)
> > +{
> > +	/* enqueue to softlimit queue */
> > +	int prio = mem->soft_limit_priority;
> > +
> > +	spin_lock(&softlimitq.lock);
> > +	list_del_init(&mem->soft_limit_anon);
> > +	list_add_tail(&mem->soft_limit_anon, &softlimitq.queue[prio][SL_ANON]);
> > +	list_del_init(&mem->soft_limit_file,ist[SL_FILE]);
> 
> Patch fails to build here, what is ist?
> 
Hm...my patech is broken ?
&softlimitq.queue[prio][SL_FILE]

-Kame.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
