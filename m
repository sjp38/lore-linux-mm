Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EEC446B0011
	for <linux-mm@kvack.org>; Mon,  9 May 2011 06:06:12 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C0DFD3EE0BB
	for <linux-mm@kvack.org>; Mon,  9 May 2011 19:06:09 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A6D8045DE55
	for <linux-mm@kvack.org>; Mon,  9 May 2011 19:06:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8912B45DE4F
	for <linux-mm@kvack.org>; Mon,  9 May 2011 19:06:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7BFE71DB8041
	for <linux-mm@kvack.org>; Mon,  9 May 2011 19:06:09 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 42B741DB8037
	for <linux-mm@kvack.org>; Mon,  9 May 2011 19:06:09 +0900 (JST)
Date: Mon, 9 May 2011 18:59:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/7] memcg: add high/low watermark to res_counter
Message-Id: <20110509185928.09dbbf9f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110509095804.GA16531@cmpxchg.org>
References: <20110503064945.GA18927@tiehlicka.suse.cz>
	<BANLkTimmpHcSJuO_8+P=GjYf+wB=Nyq=4w@mail.gmail.com>
	<20110503082550.GD18927@tiehlicka.suse.cz>
	<BANLkTikZtOdzsnjH=43AegLCpYc6ecfKsg@mail.gmail.com>
	<20110504085851.GC1375@tiehlicka.suse.cz>
	<BANLkTinxuSaCEvN4_vB=uA1rdGUwCpovog@mail.gmail.com>
	<20110505065901.GC11529@tiehlicka.suse.cz>
	<20110506142834.90e0b363.kamezawa.hiroyu@jp.fujitsu.com>
	<20110506142257.GI10278@cmpxchg.org>
	<20110509092112.7d8ae017.kamezawa.hiroyu@jp.fujitsu.com>
	<20110509095804.GA16531@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>

On Mon, 9 May 2011 11:58:04 +0200
Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Mon, May 09, 2011 at 09:21:12AM +0900, KAMEZAWA Hiroyuki wrote:
> > On Fri, 6 May 2011 16:22:57 +0200
> > Johannes Weiner <hannes@cmpxchg.org> wrote:

> Thanks a lot for the explanation, this certainly makes sense.
> 
> How about this: we put in memcg watermark reclaim first, as a pure
> best-effort latency optimization, without the watermark configurable
> from userspace.  It's not a new concept, we have it with kswapd on a
> global level.
> 
> And on top of that, as a separate changeset, userspace gets a knob to
> kick off async memcg reclaim when the system is idle.  With the
> justification you wrote above.  We can still discuss the exact
> mechanism, but the async memcg reclaim feature has value in itself and
> should not have to wait until this second step is all figured out.
> 
> Would this be acceptable?
> 

It's okay for me. I'll change the order patches and merge patches from
the core parts.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
