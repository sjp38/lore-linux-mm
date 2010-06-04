Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D1B8B6B01AD
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 21:27:02 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o541R0ZG008070
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 4 Jun 2010 10:27:00 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3484445DE56
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 10:27:00 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 12CED45DE51
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 10:27:00 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E67EE1DB805D
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 10:26:59 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9737C1DB8043
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 10:26:59 +0900 (JST)
Date: Fri, 4 Jun 2010 10:22:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] memcg fix wake up in oom wait queue
Message-Id: <20100604102246.c37858fb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100604100811.31c45828.nishimura@mxp.nes.nec.co.jp>
References: <20100603172353.b5375879.kamezawa.hiroyu@jp.fujitsu.com>
	<20100604100811.31c45828.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 4 Jun 2010 10:08:11 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Thu, 3 Jun 2010 17:23:53 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > Very sorry that my test wasn't enough and delayed.
> > 
> > ==
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > OOM-waitqueue should be waken up when oom_disable is canceled.
> > This is a fix for
> >  memcg-oom-kill-disable-and-oom-status.patch
> > 
> > How to test:
> >  Create a cgroup A...
> >  1. set memory.limit and memory.memsw.limit to be small value
> >  2. echo 1 > /cgroup/A/memory.oom_control, this disables oom-kill.
> >  3. run a program which must cause OOM.
> > 
> > A program executed in 3 will sleep by oom_waiqueue in memcg.
> > Then, how to wake it up is problem.
> > 
> >  1. echo 0 > /cgroup/A/memory.oom_control (enable OOM-killer)
> >  2. echo big mem > /cgroup/A/memory.memsw.limit_in_bytes(allow more swap)
> > etc..
> > 
> > Without the patch, a task in slept can not be waken up.
> > 
> 
> Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
Thanks. I'll try to rebase this onto the latest mmotm.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
