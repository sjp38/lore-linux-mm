Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5B75A8D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 00:33:57 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 678DA3EE0C7
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 13:33:54 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4EEA945DE54
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 13:33:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 34D2745DE4E
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 13:33:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D9A9A1DB803E
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 13:33:53 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D63FB1DB8041
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 13:33:52 +0900 (JST)
Date: Thu, 21 Apr 2011 13:27:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V6 00/10] memcg: per cgroup background reclaim
Message-Id: <20110421132714.e5655c7e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTin7BDchrD_L+UFBwsyn2oAbuU03qA@mail.gmail.com>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
	<20110421124059.79990661.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTin7BDchrD_L+UFBwsyn2oAbuU03qA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Wed, 20 Apr 2011 21:22:43 -0700
Ying Han <yinghan@google.com> wrote:

> On Wed, Apr 20, 2011 at 8:40 PM, KAMEZAWA Hiroyuki <
> kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Mon, 18 Apr 2011 20:57:36 -0700
> > Ying Han <yinghan@google.com> wrote:
> >
> > > 1. there are one kswapd thread per cgroup. the thread is created when the
> > > cgroup changes its limit_in_bytes and is deleted when the cgroup is being
> > > removed. In some enviroment when thousand of cgroups are being configured
> > on
> > > a single host, we will have thousand of kswapd threads. The memory
> > consumption
> > > would be 8k*100 = 8M. We don't see a big issue for now if the host can
> > host
> > > that many of cgroups.
> > >
> >
> > I don't think no-fix to this is ok.
> >
> > Here is a thread pool patch on your set. (and includes some more).
> > 3 patches in following e-mails.
> > Any comments are welocme, but my response may be delayed.
> >
> > Thank you for making up the patch, and I will take a look. Do I apply the 3
> patches on top of my patchset or they comes separately?

Ah, sorry, I made patches on
mmotm-Apr15 + Your Patch 1-8. (not including 9,10)

I dropped 10 just because of HUNK (caused by dropping 9) but as David pointed out,
we should make a consolidation with count_vm_event() (in different patch set)...
And I think you already have v7.
For this time, you can pick usable parts up to your set. I'll make an add-on again.

What imporatant here will be discussion for better implemenation.

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
