Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 96AF76B0047
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 03:41:11 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0G8f84X022786
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 16 Jan 2009 17:41:08 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 20B2F45DE51
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 17:41:08 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B515245DE4F
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 17:41:07 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 80C961DB8042
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 17:41:07 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 33B151DB803E
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 17:41:07 +0900 (JST)
Date: Fri, 16 Jan 2009 17:40:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUG] memcg: panic when rmdir()
Message-Id: <20090116174003.45b88de7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <49704644.3020102@cn.fujitsu.com>
References: <497025E8.8050207@cn.fujitsu.com>
	<20090116170724.d2ad8344.kamezawa.hiroyu@jp.fujitsu.com>
	<49704644.3020102@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Fri, 16 Jan 2009 16:33:08 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > On Fri, 16 Jan 2009 14:15:04 +0800
> > Li Zefan <lizf@cn.fujitsu.com> wrote:
> > 
> >> Found this when testing memory resource controller, can be triggered
> >> with:
> >> - CONFIG_CGROUP_MEM_RES_CTLR_SWAP=n
> >> - or CONFIG_CGROUP_MEM_RES_CTLR_SWAP=y
> >> - or CONFIG_CGROUP_MEM_RES_CTLR_SWAP=y && boot with noswapaccount
> >>
> > 
> > Li-san, could you try this ? I myself can't reproduce the bug yet...
> 
> I've tested this patch, and the bug seems to disappear. :)
> 
> Tested-by: Li Zefan <lizf@cn.fujitsu.com>
> 
> I'm going to be off office, and I'll do more testing to confirm this
> next week.
> 

Thank you !

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
