Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 58A588D003B
	for <linux-mm@kvack.org>; Sun, 24 Apr 2011 19:33:43 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 8FC0B3EE0C1
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 08:33:39 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 68B1445DE54
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 08:33:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 50FE845DE4F
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 08:33:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4527F1DB803F
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 08:33:39 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 113191DB8037
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 08:33:39 +0900 (JST)
Date: Mon, 25 Apr 2011 08:26:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V7 4/9] Add memcg kswapd thread pool
Message-Id: <20110425082642.034a5f64.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTikfsLB8kTFZe+qj_jK=psgtFMfBMA@mail.gmail.com>
References: <1303446260-21333-1-git-send-email-yinghan@google.com>
	<1303446260-21333-5-git-send-email-yinghan@google.com>
	<20110422133643.6a36d838.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTinkJC2-HiGtxgTTo8RvRjZqYuq2pA@mail.gmail.com>
	<20110422140023.949e5737.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTim91aHXjqfukn6rJxK0SDSSG2wrrg@mail.gmail.com>
	<20110422145943.a8f5a4ef.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTikRvjNR94tUf2p9UPQFGLUYp41Twg@mail.gmail.com>
	<20110422164622.a8350bc5.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTikfsLB8kTFZe+qj_jK=psgtFMfBMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Fri, 22 Apr 2011 00:59:26 -0700
Ying Han <yinghan@google.com> wrote:

> On Fri, Apr 22, 2011 at 12:46 AM, KAMEZAWA Hiroyuki <
> kamezawa.hiroyu@jp.fujitsu.com> wrote:

> > From this, I feel I need to use unbound workqueue. BTW, with patches for
> > current thread pool model, I think starvation problem by dirty pages
> > cannot be seen.
> > Anyway, I'll give a try.
> >
> 
> Then do you suggest me to wait for your patch for my next post?
> 

I used most of weekend for background reclaim on workqueue and I changed many
things based on your patch (but dropped most of kswapd descriptor...patches.)

I'll post it today after some tests on machines in my office. It worked well
on my laptop.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
