Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 461E26B0092
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 21:53:41 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id BEE413EE0C0
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 11:53:37 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A53D745DE6C
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 11:53:37 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7FBFC45DE67
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 11:53:37 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 73FA71DB8042
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 11:53:37 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 324E71DB803E
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 11:53:37 +0900 (JST)
Date: Wed, 19 Jan 2011 11:47:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/5] Add per cgroup reclaim watermarks.
Message-Id: <20110119114735.aea5698f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1101181831110.25382@chino.kir.corp.google.com>
References: <1294956035-12081-1-git-send-email-yinghan@google.com>
	<1294956035-12081-3-git-send-email-yinghan@google.com>
	<20110114091119.2f11b3b9.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTimo7c3pwFoQvE140o6uFDOaRvxdq6+r3tQnfuPe@mail.gmail.com>
	<alpine.DEB.2.00.1101181227220.18781@chino.kir.corp.google.com>
	<AANLkTi=oFTf9pLKdBU4wXm4tTsWjH+E2q9d5_nm_7gt9@mail.gmail.com>
	<20110119095650.02db87e0.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1101181831110.25382@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Ying Han <yinghan@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Jan 2011 18:38:42 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Wed, 19 Jan 2011, KAMEZAWA Hiroyuki wrote:
> 
> > > so something like per-memcg min_wmark which also needs to be reserved upfront?
> > > 
> > 
> > I think the variable name 'min_free_kbytes' is the source of confusion...
> > It's just a watermark to trigger background reclaim. It's not reservation.
> > 
> 
> min_free_kbytes alters the min watermark of zones, meaning it can increase 
> or decrease the amount of memory that is reserved for GFP_ATOMIC 
> allocations, those in irq context, etc.  Since oom killed tasks don't 
> allocate from any watermark, it also can increase or decrease the amount 
> of memory available to oom killed tasks.  In that case, it _is_ a 
> reservation of memory.
> 
I know.

THIS PATCH's min_free_kbytes is not the same to ZONE's one. It's just a
trigger. This patch's one is not used to limit charge() or for handling
gfp_mask.
(We can assume it's always GFP_HIGHUSER_MOVABLE or GFP_USER in some cases.)

So, I wrote the name of 'min_free_kbytes' in _this_ patch is a source of
confusion. I don't recommend to use such name in _this_ patch.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
