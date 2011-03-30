Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D992C8D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 03:19:34 -0400 (EDT)
Date: Wed, 30 Mar 2011 16:18:00 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [trivial PATCH v2] Remove pointless next_mz nullification in
 mem_cgroup_soft_limit_reclaim
Message-Id: <20110330161800.2e7dc268.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20110330070203.GA15394@tiehlicka.suse.cz>
References: <20110329132800.GA3361@tiehlicka.suse.cz>
	<20110330110953.06ea3521.nishimura@mxp.nes.nec.co.jp>
	<20110330070203.GA15394@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

> From: Michal Hocko <mhocko@suse.cz>
> Subject: Remove pointless next_mz nullification in mem_cgroup_soft_limit_reclaim
> 
> next_mz is assigned to NULL if __mem_cgroup_largest_soft_limit_node selects
> the same mz. This doesn't make much sense as we assign to the variable
> right in the next loop.
> 
> Compiler will probably optimize this out but it is little bit confusing for
> the code reading.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
