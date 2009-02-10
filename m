Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 523286B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 06:50:24 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1ABoMjK010810
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 10 Feb 2009 20:50:22 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1361145DD76
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 20:50:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E8F6245DD75
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 20:50:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DA8C01DB803E
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 20:50:21 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 990E21DB803A
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 20:50:18 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: remove mem_cgroup_reclaim_imbalance() perfectly
In-Reply-To: <20090210202939.6FEC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20090210110045.GE16317@balbir.in.ibm.com> <20090210202939.6FEC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20090210204913.6FFB.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 10 Feb 2009 20:50:17 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Hi Balbir,

> > * KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-02-10 18:50:39]:
> > 
> > > 
> > > commit 4f98a2fee8acdb4ac84545df98cccecfd130f8db (vmscan: 
> > > split LRU lists into anon & file sets) remove mem_cgroup_reclaim_imbalance().
> > > 
> > > but it isn't enough.
> > > memcontrol.h header file still have legacy parts.
> > > 
> > > 
> > > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> > > ---
> > >  include/linux/memcontrol.h |    6 ------
> > >  1 file changed, 6 deletions(-)
> > >
> > 
> > The calc_mapped_ratio prototype should also be removed from this file. 
> 
> ok, thanks.
> I'll do that soon.

I fixed this by "memcg: remove mem_cgroup_calc_mapped_ratio() take2".
Then, We don't need to change this patch.

Thanks!



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
