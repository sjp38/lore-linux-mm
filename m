Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B67C88D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 03:08:42 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id EEB703EE0AE
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 16:08:39 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CA6B32AEA92
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 16:08:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B17042E68C4
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 16:08:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A0CC21DB8049
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 16:08:39 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 650221DB803C
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 16:08:39 +0900 (JST)
Date: Thu, 21 Apr 2011 16:01:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] weight for memcg background reclaim (Was Re: [PATCH
 V6 00/10] memcg: per cgroup background reclaim
Message-Id: <20110421160152.5bc1c1b1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTi=Y7SfFv=LMmaspyTXXSHrO5LJaiQ@mail.gmail.com>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
	<20110421124059.79990661.kamezawa.hiroyu@jp.fujitsu.com>
	<20110421124836.16769ffc.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTimFASy=jsEk=1rZSH2o386-gDgvxA@mail.gmail.com>
	<20110421153804.6da5c5ea.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=Y7SfFv=LMmaspyTXXSHrO5LJaiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Wed, 20 Apr 2011 23:59:52 -0700
Ying Han <yinghan@google.com> wrote:

> On Wed, Apr 20, 2011 at 11:38 PM, KAMEZAWA Hiroyuki <
> kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Wed, 20 Apr 2011 23:11:42 -0700
> > Ying Han <yinghan@google.com> wrote:
> >
> > > On Wed, Apr 20, 2011 at 8:48 PM, KAMEZAWA Hiroyuki <
> > > kamezawa.hiroyu@jp.fujitsu.com> wrote:

> n general, memcg-kswapd can reduce memory down to high watermak only when
> > the system is not busy. So, this logic tries to remove more memory from busy
> > cgroup to reduce 'hit limit'.
> >
> 
> So, the "busy cgroup" here means the memcg has higher (usage - low)?
> 

  high < usage < low < limit

Yes, if background reclaim wins, usage - high decreases.
If tasks on cgroup uses more memory than reclaim, usage - high increases even
if background reclaim runs. So, if usage-high is large, cgroup is busy.



Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
