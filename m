Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 042A56B00E8
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 19:47:39 -0500 (EST)
Date: Wed, 12 Jan 2011 09:38:20 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 2/2] memcg: remove charge variable in unmap_and_move
Message-Id: <20110112093820.405fc115.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <f6f15f90ecf0df32586fcc103038fd7ea01acc16.1294735182.git.minchan.kim@gmail.com>
References: <41390917af25769cd59eb001370b80ef6520a8bb.1294735182.git.minchan.kim@gmail.com>
	<f6f15f90ecf0df32586fcc103038fd7ea01acc16.1294735182.git.minchan.kim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 11 Jan 2011 17:51:12 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> memcg charge/uncharge could be handled by mem_cgroup_[prepare/end]
> migration itself so charge local variable in unmap_and_move lost the role
> since we introduced 01b1ae63c2.
> 
> In addition, the variable name is not good like below.
> 
> int unmap_and_move()
> {
> 	charge = mem_cgroup_prepare_migration(xxx);
> 	..
> 		BUG_ON(charge); <-- BUG if it is charged?
> 		..
> uncharge:
> 		if (!charge)    <-- why do we have to uncharge !charge?
> 			mem_group_end_migration(xxx);
> 	..
> }
> 
> So let's remove unnecessary and confusing variable.
> 
> Suggested-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
