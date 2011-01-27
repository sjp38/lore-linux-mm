Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 666DC8D0039
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 05:34:45 -0500 (EST)
Date: Thu, 27 Jan 2011 11:34:38 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 4/7] memcg : fix charge function of THP allocation.
Message-ID: <20110127103438.GC2401@cmpxchg.org>
References: <20110121153431.191134dd.kamezawa.hiroyu@jp.fujitsu.com>
 <20110121154430.70d45f15.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110121154430.70d45f15.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 21, 2011 at 03:44:30PM +0900, KAMEZAWA Hiroyuki wrote:
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
>  - distinguish THP allocaton from Bached allocation. 

This does too many things at once.  Can you split this into more
patches where each one has a single objective?  Thanks.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
