Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7A1269000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 20:41:03 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 991BC3EE0B5
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 09:41:00 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8043245DEA5
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 09:41:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6718545DEA0
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 09:41:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B1591DB803E
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 09:41:00 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 275311DB8038
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 09:41:00 +0900 (JST)
Date: Wed, 27 Apr 2011 09:34:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/7] memcg background reclaim , yet another one.
Message-Id: <20110427093422.7740aa21.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTi=PuQPz4tyj4M3bc--asanZd525cA@mail.gmail.com>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
	<20110425191437.d881ee68.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTikYeV8JpMHd1Lvh7kRXXpLyQEOw4w@mail.gmail.com>
	<20110426103859.05eb7a35.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=aoRhgu3SOKZ8OLRqTew67ciquFg@mail.gmail.com>
	<20110426164341.fb6c80a4.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=sSrrQCMXKJor95Cn-JmiQ=XUAkA@mail.gmail.com>
	<20110426174754.07a58f22.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=PuQPz4tyj4M3bc--asanZd525cA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>

On Tue, 26 Apr 2011 16:08:38 -0700
Ying Han <yinghan@google.com> wrote:

> On Tue, Apr 26, 2011 at 1:47 AM, KAMEZAWA Hiroyuki <
> kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > BTW, I think it's better to avoid the watermark reclaim work as kswapd.
> > It's confusing because we've talked about global reclaim at LSF.
> >
> 
> Can you clarify that?
> 

Maybe I should write "it's better to avoid calling watermark work as kswapd"

Many guys talk about soft-limit and removing LRU at talking about kswapd or
bacground reclaim ;)


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
