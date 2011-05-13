Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 377D06B0022
	for <linux-mm@kvack.org>; Fri, 13 May 2011 02:31:32 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 6F58F3EE0B5
	for <linux-mm@kvack.org>; Fri, 13 May 2011 15:31:28 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A32E45DE95
	for <linux-mm@kvack.org>; Fri, 13 May 2011 15:31:28 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3FCCE45DE93
	for <linux-mm@kvack.org>; Fri, 13 May 2011 15:31:28 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 32C181DB803B
	for <linux-mm@kvack.org>; Fri, 13 May 2011 15:31:28 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id F32C41DB802F
	for <linux-mm@kvack.org>; Fri, 13 May 2011 15:31:27 +0900 (JST)
Date: Fri, 13 May 2011 15:24:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH][BUGFIX] memcg fix zone congestion
Message-Id: <20110513152426.cbb91a84.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110513131514.a7ec1328.nishimura@mxp.nes.nec.co.jp>
References: <20110513121030.08fcae08.kamezawa.hiroyu@jp.fujitsu.com>
	<20110513131514.a7ec1328.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>

On Fri, 13 May 2011 13:15:14 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Fri, 13 May 2011 12:10:30 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > 
> > ZONE_CONGESTED should be a state of global memory reclaim.
> > If not, a busy memcg sets this and give unnecessary throttoling in
> > wait_iff_congested() against memory recalim in other contexts. This makes
> > system performance bad.
> > 
> hmm, nice catch.
> 
> Just from my curiosity, is there any number of performance improvement by this patch?
> 

I guess impact of this patch is very limited. (And I've tested but cannot measure
the score. I need some special application/settings.)

I think, with small memcg, we'll see nr_dirty==nr_congested situaion often and
set ZONE_CONGESTED. But the effect of patch can be seen in the another place.

To see the effect of patch, the system need to reclaim memory eagerly with memory
shortage. In that situation, everything is slow. This patch just removes a extra
burden which is put on by mistake.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
