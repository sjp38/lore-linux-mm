Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BF4D76B00EE
	for <linux-mm@kvack.org>; Wed, 31 Aug 2011 02:38:08 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id A30433EE0C8
	for <linux-mm@kvack.org>; Wed, 31 Aug 2011 15:38:04 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 755D245DE62
	for <linux-mm@kvack.org>; Wed, 31 Aug 2011 15:38:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D02045DE58
	for <linux-mm@kvack.org>; Wed, 31 Aug 2011 15:38:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F3DA1DB804E
	for <linux-mm@kvack.org>; Wed, 31 Aug 2011 15:38:04 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FF07E08005
	for <linux-mm@kvack.org>; Wed, 31 Aug 2011 15:38:04 +0900 (JST)
Date: Wed, 31 Aug 2011 15:30:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] Revert "memcg: add memory.vmscan_stat"
Message-Id: <20110831153025.895997bf.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110831062354.GA355@redhat.com>
References: <20110829155113.GA21661@redhat.com>
	<20110830101233.ae416284.kamezawa.hiroyu@jp.fujitsu.com>
	<20110830070424.GA13061@redhat.com>
	<20110830162050.f6c13c0c.kamezawa.hiroyu@jp.fujitsu.com>
	<20110830084245.GC13061@redhat.com>
	<20110830175609.4977ef7a.kamezawa.hiroyu@jp.fujitsu.com>
	<20110830101726.GD13061@redhat.com>
	<20110830193839.cf0fc597.kamezawa.hiroyu@jp.fujitsu.com>
	<20110830113221.GF13061@redhat.com>
	<20110831082924.f9b20959.kamezawa.hiroyu@jp.fujitsu.com>
	<20110831062354.GA355@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Andrew Brestic <abrestic@google.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 31 Aug 2011 08:23:54 +0200
Johannes Weiner <jweiner@redhat.com> wrote:

> On Wed, Aug 31, 2011 at 08:29:24AM +0900, KAMEZAWA Hiroyuki wrote:
> > On Tue, 30 Aug 2011 13:32:21 +0200
> > Johannes Weiner <jweiner@redhat.com> wrote:
> > 
> > > On Tue, Aug 30, 2011 at 07:38:39PM +0900, KAMEZAWA Hiroyuki wrote:
> > > > On Tue, 30 Aug 2011 12:17:26 +0200
> > > > Johannes Weiner <jweiner@redhat.com> wrote:
> > > > 
> > > > > On Tue, Aug 30, 2011 at 05:56:09PM +0900, KAMEZAWA Hiroyuki wrote:
> > > > > > On Tue, 30 Aug 2011 10:42:45 +0200
> > > > > > Johannes Weiner <jweiner@redhat.com> wrote:
>
> > I'm confused. 
> > 
> > If vmscan is scanning in C's LRU,
> > 	(memcg == root) : C_scan_internal ++
> > 	(memcg != root) : C_scan_external ++
> 
> Yes.
> 
> > Why A_scan_external exists ? It's 0 ?
> > 
> > I think we can never get numbers.
> 
> Kswapd/direct reclaim should probably be accounted as A_external,
> since A has no limit, so reclaim pressure can not be internal.
> 

hmm, ok. All memory pressure from memcg/system other than the memcg itsef
is all external.

> On the other hand, one could see the amount of physical memory in the
> machine as A's limit and account global reclaim as A_internal.
> 
> I think the former may be more natural.
> 
> That aside, all memcgs should have the same statistics, obviously.
> Scripts can easily deal with counters being zero.  If items differ
> between cgroups, that would suck a lot.

So, when I improve direct-reclaim path, I need to see score in scan_internal.

How do you think about background-reclaim-per-memcg ?
Should be counted into scan_internal ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
