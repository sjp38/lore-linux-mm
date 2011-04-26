Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D21038D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 20:42:35 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 800363EE0AE
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 09:42:33 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5AABF45DE4E
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 09:42:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4014945DE53
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 09:42:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2998DE78002
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 09:42:33 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BB4951DB8045
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 09:42:32 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH V2 1/2] change the shrink_slab by passing shrink_control
In-Reply-To: <1303752134-4856-2-git-send-email-yinghan@google.com>
References: <1303752134-4856-1-git-send-email-yinghan@google.com> <1303752134-4856-2-git-send-email-yinghan@google.com>
Message-Id: <20110426094356.F341.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 26 Apr 2011 09:42:31 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Nick Piggin <nickpiggin@yahoo.com.au>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

> This patch consolidates existing parameters to shrink_slab() to
> a new shrink_control struct. This is needed later to pass the same
> struct to shrinkers.
> 
> changelog v2..v1:
> 1. define a new struct shrink_control and only pass some values down
> to the shrinker instead of the scan_control.
> 
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
>  fs/drop_caches.c   |    6 +++++-
>  include/linux/mm.h |   13 +++++++++++--
>  mm/vmscan.c        |   30 ++++++++++++++++++++++--------
>  3 files changed, 38 insertions(+), 11 deletions(-)

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
