Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 545E18D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 22:08:19 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 208783EE0C7
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 11:08:16 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E7D9A45DE58
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 11:08:15 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CE82445DE51
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 11:08:15 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C0E151DB8046
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 11:08:15 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E0A41DB803E
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 11:08:15 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan,memcg: memcg aware swap token
In-Reply-To: <BANLkTikCZpCZdLV7M_38MvnRYbZFS5zQGQ@mail.gmail.com>
References: <20110425112333.2662.A69D9226@jp.fujitsu.com> <BANLkTikCZpCZdLV7M_38MvnRYbZFS5zQGQ@mail.gmail.com>
Message-Id: <20110426110945.F36D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 26 Apr 2011 11:08:14 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

> > The better approach is swap-token recognize memcg and behave clever? :)
> 
> Ok, this makes sense for memcg case. Maybe I missed something on the
> per-node balance_pgdat, where it seems it will blindly disable the
> swap_token_mm if there is a one.

That's design. 'disable' of disable_swap_token() mean blindly disable.
The intention is,
  priority != 0:   try to avoid swap storm
  priority == 0:  allow thrashing. it's better than false positive oom.


> Should I include this patch into the per-memcg kswapd patset?

Nope.
This is standalone patch. current memcg direct reclaim path has the same
problem.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
