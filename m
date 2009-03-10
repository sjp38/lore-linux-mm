Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7367D6B003D
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 01:54:57 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2A5ssQq006030
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 10 Mar 2009 14:54:55 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7387445DE50
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 14:54:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4805D45DE51
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 14:54:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BAF31DB803A
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 14:54:54 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D3E4AE08007
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 14:54:53 +0900 (JST)
Date: Tue, 10 Mar 2009 14:53:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/4] memcg: add softlimit interface and utilitiy
 function.
Message-Id: <20090310145334.0473c3fe.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090309084844.GI24321@balbir.in.ibm.com>
References: <20090309163745.5e3805ba.kamezawa.hiroyu@jp.fujitsu.com>
	<20090309163907.a3cee183.kamezawa.hiroyu@jp.fujitsu.com>
	<20090309074449.GH24321@balbir.in.ibm.com>
	<20090309165507.9f57ad41.kamezawa.hiroyu@jp.fujitsu.com>
	<20090309084844.GI24321@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 9 Mar 2009 14:18:44 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-09 16:55:07]:
> 
> > On Mon, 9 Mar 2009 13:14:49 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-09 16:39:07]:
> > Hmm, them, moving mem->softlimit to res->softlimit is ok ?
> > 
> > If no more "branch" to res_counter_charge/uncharge(), moving this to
> > res_counter is ok to me.
> >
> 
> There is a branch, but the additional excessive checks are gone.
> It should be possible to reduce the overhead to comparisons though. 
> 

I'm now rewriting to use res_counter but do you have any good reason to
irq-off in res_counter ?
It seems there are no callers in irq path.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
