Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 54F5F8D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 00:41:27 -0500 (EST)
Date: Fri, 28 Jan 2011 14:37:28 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [BUGFIX][PATCH 2/4] memcg: fix charge path for THP and allow
 early retirement
Message-Id: <20110128143728.e3ee2dbc.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20110128122608.cf9be26b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110128122229.6a4c74a2.kamezawa.hiroyu@jp.fujitsu.com>
	<20110128122608.cf9be26b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 28 Jan 2011 12:26:08 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> When THP is used, Hugepage size charge can happen. It's not handled
> correctly in mem_cgroup_do_charge(). For example, THP can fallback
> to small page allocation when HUGEPAGE allocation seems difficult
> or busy, but memory cgroup doesn't understand it and continue to
> try HUGEPAGE charging. And the worst thing is memory cgroup
> believes 'memory reclaim succeeded' if limit - usage > PAGE_SIZE.
> 
> By this, khugepaged etc...can goes into inifinite reclaim loop
> if tasks in memcg are busy.
> 
> After this patch 
>  - Hugepage allocation will fail if 1st trial of page reclaim fails.
> 
> Changelog:
>  - make changes small. removed renaming codes.
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
