Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8467D8D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 20:54:39 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 388D53EE0C3
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 09:54:36 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 04A8945DE50
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 09:54:36 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C8B1F1EF083
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 09:54:35 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BBA5A1DB803F
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 09:54:35 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 86D5F1DB8037
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 09:54:35 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/3] pass the scan_control into shrinkers
In-Reply-To: <BANLkTikJfOevEUqivf8b1XkL1vTmL6RBEQ@mail.gmail.com>
References: <20110420092003.45EB.A69D9226@jp.fujitsu.com> <BANLkTikJfOevEUqivf8b1XkL1vTmL6RBEQ@mail.gmail.com>
Message-Id: <20110420095429.45FD.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 20 Apr 2011 09:54:34 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Nick Piggin <nickpiggin@yahoo.com.au>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

> On Tue, Apr 19, 2011 at 5:20 PM, KOSAKI Motohiro <
> kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > > This patch changes the shrink_slab and shrinker APIs by consolidating
> > existing
> > > parameters into scan_control struct. This simplifies any further attempts
> > to
> > > pass extra info to the shrinker. Instead of modifying all the shrinker
> > files
> > > each time, we just need to extend the scan_control struct.
> > >
> >
> > Ugh. No, please no.
> > Current scan_control has a lot of vmscan internal information. Please
> > export only you need one, not all.
> >
> > Otherwise, we can't change any vmscan code while any shrinker are using it.
> >
> 
> So, are you suggesting maybe add another struct for this purpose?

Yes. And please explain which member do you need.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
