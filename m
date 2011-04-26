Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E3C289000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 04:54:41 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E201B3EE0C3
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 17:54:37 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C43B445DE54
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 17:54:37 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A4F3145DE4D
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 17:54:37 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 94917E78005
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 17:54:37 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 570731DB803E
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 17:54:37 +0900 (JST)
Date: Tue, 26 Apr 2011 17:47:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/7] memcg background reclaim , yet another one.
Message-Id: <20110426174754.07a58f22.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTi=sSrrQCMXKJor95Cn-JmiQ=XUAkA@mail.gmail.com>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
	<20110425191437.d881ee68.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTikYeV8JpMHd1Lvh7kRXXpLyQEOw4w@mail.gmail.com>
	<20110426103859.05eb7a35.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=aoRhgu3SOKZ8OLRqTew67ciquFg@mail.gmail.com>
	<20110426164341.fb6c80a4.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=sSrrQCMXKJor95Cn-JmiQ=XUAkA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>

On Tue, 26 Apr 2011 01:43:17 -0700
Ying Han <yinghan@google.com> wrote:

> On Tue, Apr 26, 2011 at 12:43 AM, KAMEZAWA Hiroyuki <
> kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Tue, 26 Apr 2011 00:19:46 -0700
> > Ying Han <yinghan@google.com> wrote:
> >
> > > On Mon, Apr 25, 2011 at 6:38 PM, KAMEZAWA Hiroyuki
> > > <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > On Mon, 25 Apr 2011 15:21:21 -0700
> > > > Ying Han <yinghan@google.com> wrote:

> 
> > To clarify a bit, my question was meant to account it but not necessary to
> > limit it. We can use existing cpu cgroup to do the cpu limiting, and I am
> >
> just wondering how to configure it for the memcg kswapd thread.
> 
>    Let's say in the per-memcg-kswapd model, i can echo the kswapd thread pid
> into the cpu cgroup ( the same set of process of memcg, but in a cpu
> limiting cgroup instead).  If the kswapd is shared, we might need extra work
> to account the cpu cycles correspondingly.
> 

Hm ? statistics of elapsed_time isn't enough ?

Now, I think limiting scan/sec interface is more promissing rather than time
or thread controls. It's easier to understand.

BTW, I think it's better to avoid the watermark reclaim work as kswapd.
It's confusing because we've talked about global reclaim at LSF.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
