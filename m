Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7F0C78D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 00:40:47 -0500 (EST)
Date: Fri, 28 Jan 2011 14:36:54 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [BUGFIX][PATCH 1/4] memcg: fix limit estimation at reclaim for
 hugepage
Message-Id: <20110128143654.1aec8f8d.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20110128135839.d53422e8.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110128122229.6a4c74a2.kamezawa.hiroyu@jp.fujitsu.com>
	<20110128122449.e4bb0e5f.kamezawa.hiroyu@jp.fujitsu.com>
	<20110128134019.27abcfe2.nishimura@mxp.nes.nec.co.jp>
	<20110128135839.d53422e8.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 28 Jan 2011 13:58:39 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> How about this ?
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Current memory cgroup's code tends to assume page_size == PAGE_SIZE
> and arrangement for THP is not enough yet.
> 
> This is one of fixes for supporing THP. This adds
> mem_cgroup_check_margin() and checks whether there are required amount of
> free resource after memory reclaim. By this, THP page allocation
> can know whether it really succeeded or not and avoid infinite-loop
> and hangup.
> 
> Total fixes for do_charge()/reclaim memory will follow this patch.
> 
> Changelog v1->v2:
>  - style fix.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
