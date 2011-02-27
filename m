Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id AEAF08D0039
	for <linux-mm@kvack.org>; Sun, 27 Feb 2011 16:10:03 -0500 (EST)
Date: Sun, 27 Feb 2011 22:09:51 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg: clean up migration
Message-ID: <20110227210951.GZ25382@cmpxchg.org>
References: <1298821765-3167-1-git-send-email-minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1298821765-3167-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, Feb 28, 2011 at 12:49:25AM +0900, Minchan Kim wrote:
> This patch cleans up unncessary BUG_ON check and confusing
> charge variable.
> 
> That's because memcg charge/uncharge could be handled by
> mem_cgroup_[prepare/end] migration itself so charge local variable
> in unmap_and_move lost the role since we introduced 01b1ae63c2.
> 
> And mem_cgroup_prepare_migratio return 0 if only it is successful.
> Otherwise, it jumps to unlock label to clean up so BUG_ON(charge)
> isn;t meaningless.
> 
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks, Minchan!

	Hannes

PS: Btw, people sometimes refer to commits by hashes from trees other
than Linus's, so it's nice to include the subject as well:

	01b1ae6 memcg: simple migration handling

You get this easily by taking the first line of

	git show --oneline <commithash>

though there are probably other ways.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
