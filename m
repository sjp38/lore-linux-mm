Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 987516B0092
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 03:32:32 -0500 (EST)
Date: Tue, 25 Jan 2011 17:31:23 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 3/3] memcg: fix race at move_parent around
 compound_order()
Message-Id: <20110125173123.08359210.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20110125150516.fb2f5e06.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110125145720.cd0cbe16.kamezawa.hiroyu@jp.fujitsu.com>
	<20110125150516.fb2f5e06.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 25 Jan 2011 15:05:16 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Based on 
> 2.6.38-rc2 + 
>  mm-memcontrolc-fix-uninitialized-variable-use-in-mem_cgroup_move_parent.patch
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> A fix up mem_cgroup_move_parent() which use compound_order() in
> asynchrnous manner. This compound_order() may return unknown value
> because we don't take lock. Use PageTransHuge() and HPAGE_SIZE instead of
> it.
> 
> Also clean up for mem_cgroup_move_parent(). 
>  - remove unnecessary initialization of local variable.
>  - rename charge_size -> page_size
>  - remove unnecessary (wrong) comment.
>  - added a comment about THP.
> 
> Changelog:
>  - fixed page size calculation for avoiding race.
> 
> Note:
>  Current design take compound_page_lock() in caller of move_account().
>  This should be revisited when we implement direct move_task of hugepage
>  without splitting.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
