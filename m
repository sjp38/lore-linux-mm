Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 974346B01F1
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 03:01:56 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3N71sHu017831
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 23 Apr 2010 16:01:54 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 415A845DE60
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 16:01:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1AEA745DE4D
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 16:01:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 03B281DB8037
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 16:01:54 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A782B1DB803A
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 16:01:50 +0900 (JST)
Date: Fri, 23 Apr 2010 15:57:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] memcg rcu lock fix v3
Message-Id: <20100423155755.7a3761fe.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100423070011.GS3994@balbir.in.ibm.com>
References: <4BD10D59.9090504@cn.fujitsu.com>
	<20100423121424.ae47efcb.kamezawa.hiroyu@jp.fujitsu.com>
	<4BD118E2.7080307@cn.fujitsu.com>
	<4BD11A24.2070500@cn.fujitsu.com>
	<20100423125814.01e95bce.kamezawa.hiroyu@jp.fujitsu.com>
	<20100423130349.f320d0be.kamezawa.hiroyu@jp.fujitsu.com>
	<20100423070011.GS3994@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Li Zefan <lizf@cn.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 23 Apr 2010 12:30:11 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-04-23 13:03:49]:
> 
> > On Fri, 23 Apr 2010 12:58:14 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > On Fri, 23 Apr 2010 11:55:16 +0800
> > > Li Zefan <lizf@cn.fujitsu.com> wrote:
> > > 
> > > > Li Zefan wrote:
> > > > > KAMEZAWA Hiroyuki wrote:
> > > > >> On Fri, 23 Apr 2010 11:00:41 +0800
> > > > >> Li Zefan <lizf@cn.fujitsu.com> wrote:
> > > > >>
> > > > >>> with CONFIG_PROVE_RCU=y, I saw this warning, it's because
> > > > >>> css_id() is not under rcu_read_lock().
> > > > >>>
> > > > >> Ok. Thank you for reporting.
> > > > >> This is ok ? 
> > > > > 
> > > > > Yes, and I did some more simple tests on memcg, no more warning
> > > > > showed up.
> > > > > 
> > > > 
> > > > oops, after trigging oom, I saw 2 more warnings:
> > > > 
> > > 
> > > Thank you for good testing.
> > v3 here...sorry too rapid posting...
> > 
> 
> Looking at the patch we seem to be protecting the use of only css_*().
> I wonder if we should push down the rcu_read_*lock() semnatics to the
> css routines or is it just too instrusive to do it that way?
> 

Maybe worth to consider for future patches for clean up.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
