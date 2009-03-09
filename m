Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7B0806B00D1
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 04:30:34 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n298UVa5001062
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 9 Mar 2009 17:30:31 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EF5E645DD74
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 17:30:30 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B8D7B45DD72
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 17:30:30 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A7EC1DB8015
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 17:30:30 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4EB42E08003
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 17:30:30 +0900 (JST)
Date: Mon, 9 Mar 2009 17:29:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/4] memcg: add softlimit interface and utilitiy
 function.
Message-Id: <20090309172911.312b0634.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090309074449.GH24321@balbir.in.ibm.com>
References: <20090309163745.5e3805ba.kamezawa.hiroyu@jp.fujitsu.com>
	<20090309163907.a3cee183.kamezawa.hiroyu@jp.fujitsu.com>
	<20090309074449.GH24321@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 9 Mar 2009 13:14:49 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-09 16:39:07]:
> 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Adds an interface for defining sotlimit per memcg. (no handler in this patch.)
> > softlimit.priority and queue for softlimit is added in the next patch.
> > 
> > 
> > Changelog v1->v2:
> >  - For refactoring, divided a patch into 2 part and this patch just
> >    involves memory.softlimit interface.
> >  - Removed governor-detect routine, it was buggy in design.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  mm/memcontrol.c |   62 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--
> >  1 file changed, 60 insertions(+), 2 deletions(-)
> 
> 
> This patch breaks the semantics of resource counters. We would like to
> use resource counters to track all overhead. I've refined my tracking
> to an extent that the overhead does not show up at all, unless soft
> limits kick in. I oppose keeping soft limits outside of resource
> counters.
> 

BTW, any other user of res_counter than memcg in future ?
I'm afraid that res_counter is decolated as chocolate-cake and will not taste
good for people who wants simple counter as simple pancake...

Thanks,
-Kame

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
