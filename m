Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0BAE96B00F8
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 19:47:02 -0400 (EDT)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp [192.51.44.35])
	by fgwmail9.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7P8j7gv005027
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 25 Aug 2009 17:45:07 +0900
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7P8iVN1007740
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 25 Aug 2009 17:44:32 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B753645DE4F
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 17:44:31 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9675A45DE4D
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 17:44:31 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 767321DB803A
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 17:44:31 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 72A59E08009
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 17:44:27 +0900 (JST)
Date: Tue, 25 Aug 2009 17:42:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][preview] memcg: reduce lock contention at uncharge by
 batching
Message-Id: <20090825174240.f925d924.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090825082526.GB29572@balbir.in.ibm.com>
References: <20090825112547.c2692965.kamezawa.hiroyu@jp.fujitsu.com>
	<20090825082526.GB29572@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 25 Aug 2009 13:55:26 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-08-25 11:25:47]:
> 
> > Hi,
> > 
> > This is a preview of a patch for reduce lock contention for memcg->res_counter.
> > This makes series of uncharge in batch and reduce critical lock contention in
> > res_counter. This is still under developement and based on 2.6.31-rc7.
> > I'll rebase this onto mmotm if I'm ready.
> > 
> > I have only 8cpu(4core/2socket) system now. no significant speed up but good lock_stat.
> >
> 
> 
> I'll test this on a 24 way that I have and check. I think these
> patches + resource counter per cpu locking should give good results.
>  
Thank you.

yes. I'm trying re-considering res_counter-percpu, too.
But, hmm, accuracy of counter trade-off is our final trouble if we select it.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
