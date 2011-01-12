Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5F7536B00E9
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 19:54:14 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Postfix) with ESMTP id C68DD3EE0B6
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 09:54:11 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A6DE145DE58
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 09:54:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C6EB45DE52
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 09:54:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E2DB1DB8044
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 09:54:11 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 402A41DB803E
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 09:54:11 +0900 (JST)
Date: Wed, 12 Jan 2011 09:48:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] memcg: remove charge variable in unmap_and_move
Message-Id: <20110112094820.e8f5e443.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <f6f15f90ecf0df32586fcc103038fd7ea01acc16.1294735182.git.minchan.kim@gmail.com>
References: <41390917af25769cd59eb001370b80ef6520a8bb.1294735182.git.minchan.kim@gmail.com>
	<f6f15f90ecf0df32586fcc103038fd7ea01acc16.1294735182.git.minchan.kim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
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

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
