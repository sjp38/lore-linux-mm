Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 448A96B00E7
	for <linux-mm@kvack.org>; Sun, 23 Jan 2011 19:35:26 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 0C1CA3EE0BD
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 09:35:23 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E305845DE61
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 09:35:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C1D7845DE68
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 09:35:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AE4A61DB803A
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 09:35:22 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6EC5C1DB8042
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 09:35:22 +0900 (JST)
Date: Mon, 24 Jan 2011 09:29:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/7] memcg : more fixes and clean up for 2.6.28-rc
Message-Id: <20110124092922.0fb50ada.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110121153431.191134dd.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110121153431.191134dd.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Jan 2011 15:34:31 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> 
> This is a set of patches which I'm now testing, and it seems it passed
> small test. So I post this.
> 
> Some are bug fixes and other are clean ups but I think these are for 2.6.38.
> 
> Brief decription
> 
> [1/7] remove buggy comment and use better name for mem_cgroup_move_parent()
>       The fixes for mem_cgroup_move_parent() is already in mainline, this is
>       an add-on.
> 
> [2/7] a bug fix for a new function mem_cgroup_split_huge_fixup(),
>       which was recently merged.
> 
> [3/7] prepare for fixes in [4/7],[5/7]. This is an enhancement of function
>       which is used now.
> 
> [4/7] fix mem_cgroup_charge() for THP. By this, memory cgroup's charge function
>       will handle THP request in sane way.
> 
> [5/7] fix khugepaged scan condition for memcg.
>       This is a fix for hang of processes under small/buzy memory cgroup.
> 
> [6/7] rename vairable names to be page_size, nr_pages, bytes rather than
>       ambiguous names.
> 
> [7/7] some memcg function requires the caller to initialize variable
>       before call. It's ugly and fix it.
> 
> 
> I think patch 1,2,3,4,5 is urgent ones. But I think patch "5" needs some
> good review. But without "5", stress-test on small memory cgroup will not
> run succesfully.
> 

I'll rebase this set to onto http://marc.info/?l=linux-mm&m=129559263207634&w=2
and post v2.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
