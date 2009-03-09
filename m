Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C583A6B00CE
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 03:56:29 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n297uRSn018351
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 9 Mar 2009 16:56:27 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0548445DE51
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 16:56:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C76B145DE50
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 16:56:26 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 83CF8E0800A
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 16:56:26 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 22A361DB8045
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 16:56:26 +0900 (JST)
Date: Mon, 9 Mar 2009 16:55:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/4] memcg: add softlimit interface and utilitiy
 function.
Message-Id: <20090309165507.9f57ad41.kamezawa.hiroyu@jp.fujitsu.com>
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

Hmm, them, moving mem->softlimit to res->softlimit is ok ?

If no more "branch" to res_counter_charge/uncharge(), moving this to
res_counter is ok to me.


Thanks,
-Kame


> 
> -- 
> 	Balbir
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
