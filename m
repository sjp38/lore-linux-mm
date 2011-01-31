Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C30108D0039
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 04:03:54 -0500 (EST)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp02.au.ibm.com (8.14.4/8.13.1) with ESMTP id p0V8waUj002231
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 19:58:36 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0V93f9C2547728
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 20:03:42 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0V93eej016162
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 20:03:40 +1100
Date: Mon, 31 Jan 2011 10:07:08 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/3] Provide control over unmapped pages (v4)
Message-ID: <20110131043708.GF5054@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20110125051003.13762.35120.stgit@localhost6.localdomain6>
 <20110125051015.13762.13429.stgit@localhost6.localdomain6>
 <AANLkTikHLw0Qg+odOB-bDtBSB-5UbTJ5ZOM-ZAdMqXgh@mail.gmail.com>
 <AANLkTi=qXsDjN5Jp4m3QMgVnckoAM7uE9_Hzn6CajP+c@mail.gmail.com>
 <AANLkTinfxXc04S9VwQcJ9thFff=cP=icroaiVLkN-GeH@mail.gmail.com>
 <20110128064851.GB5054@balbir.in.ibm.com>
 <AANLkTikw_j0JJVqEsj1xThoashiOARg+8BgcLKrvkV3U@mail.gmail.com>
 <20110128165605.3cbe5208.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1101280917570.1194@router.home>
 <20110131085853.b09aef2d.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110131085853.b09aef2d.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2011-01-31 08:58:53]:

> On Fri, 28 Jan 2011 09:20:02 -0600 (CST)
> Christoph Lameter <cl@linux.com> wrote:
> 
> > On Fri, 28 Jan 2011, KAMEZAWA Hiroyuki wrote:
> > 
> > > > > I see it as a tradeoff of when to check? add_to_page_cache or when we
> > > > > are want more free memory (due to allocation). It is OK to wakeup
> > > > > kswapd while allocating memory, somehow for this purpose (global page
> > > > > cache), add_to_page_cache or add_to_page_cache_locked does not seem
> > > > > the right place to hook into. I'd be open to comments/suggestions
> > > > > though from others as well.
> > >
> > > I don't like add hook here.
> > > AND I don't want to run kswapd because 'kswapd' has been a sign as
> > > there are memory shortage. (reusing code is ok.)
> > >
> > > How about adding new daemon ? Recently, khugepaged, ksmd works for
> > > managing memory. Adding one more daemon for special purpose is not
> > > very bad, I think. Then, you can do
> > >  - wake up without hook
> > >  - throttle its work.
> > >  - balance the whole system rather than zone.
> > >    I think per-node balance is enough...
> > 
> > 
> > I think we already have enough kernel daemons floating around. They are
> > multiplying in an amazing way. What would be useful is to map all
> > the memory management background stuff into a process. May call this memd
> > instead? Perhaps we can fold khugepaged into kswapd as well etc.
> > 
> 
> Making kswapd slow for whis "additional", "requested by user, not by system"
> work is good thing ? I think workqueue works enough well, it's scale based on
> workloads, if using thread is bad.
>

Making it slow is a generic statement, kswapd
is supposed to do background reclaim, in this case a special request
for unmapped pages, specifically and deliberately requested by the
admin via a boot option.
 
-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
