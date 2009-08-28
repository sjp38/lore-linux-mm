Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E38D46B0092
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 00:35:46 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7S4ZkDC018956
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 28 Aug 2009 13:35:46 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7885545DE60
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 13:35:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 581E445DE4D
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 13:35:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 14D9EE08003
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 13:35:46 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B676A1DB8037
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 13:35:45 +0900 (JST)
Date: Fri, 28 Aug 2009 13:33:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/5] memcg: reduce lock conetion
Message-Id: <20090828133355.6b935757.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090828042836.GD4889@balbir.in.ibm.com>
References: <20090828132015.10a42e40.kamezawa.hiroyu@jp.fujitsu.com>
	<20090828042836.GD4889@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 28 Aug 2009 09:58:36 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-08-28 13:20:15]:
> 
> > Hi,
> > 
> > Recently, memcg's res_counter->lock contention on big server is reported and
> > Balbir wrote a workaround for root memcg.
> > It's good but we need some fix for children, too.
> > 
> > This set is for reducing lock conetion of memcg's children cgroup based on mmotm-Aug27.
> > 
> > I'm sorry I have only 8cpu machine and can't reproduce very troublesome lock conention.
> > Here is lock_stat of make -j 12 on my 8cpu box, befre-after this patch series.
> >
> 
> Kamezawa-San,
> 
> I've been unable to get mmotm to boot (24th August, I'll try the 27th
> Aug and debug). Once that is done, I'll test on a large machine.
>  
yep, take it easy. I'm now very active in this weekend, anyway.

BTW, have you tried this ?

http://marc.info/?l=linux-kernel&m=125136796932491&w=2

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
