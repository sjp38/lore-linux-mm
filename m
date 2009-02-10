Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id AAD946B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 06:30:13 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1ABUBZD015687
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 10 Feb 2009 20:30:11 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C0DAE45DD85
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 20:30:10 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 86CE145DD7D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 20:30:10 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 15B06E08002
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 20:30:10 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 53CD61DB803C
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 20:30:07 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: remove mem_cgroup_reclaim_imbalance() perfectly
In-Reply-To: <20090210110045.GE16317@balbir.in.ibm.com>
References: <20090210184538.6FCF.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090210110045.GE16317@balbir.in.ibm.com>
Message-Id: <20090210202939.6FEC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 10 Feb 2009 20:30:06 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

> * KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-02-10 18:50:39]:
> 
> > 
> > commit 4f98a2fee8acdb4ac84545df98cccecfd130f8db (vmscan: 
> > split LRU lists into anon & file sets) remove mem_cgroup_reclaim_imbalance().
> > 
> > but it isn't enough.
> > memcontrol.h header file still have legacy parts.
> > 
> > 
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> > ---
> >  include/linux/memcontrol.h |    6 ------
> >  1 file changed, 6 deletions(-)
> >
> 
> The calc_mapped_ratio prototype should also be removed from this file. 

ok, thanks.
I'll do that soon.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
