Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 710726B004F
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 01:44:07 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 1ED883EE0AE
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 15:44:06 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 03C8845DF5A
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 15:44:06 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DB27945DF07
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 15:44:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C93051DB8042
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 15:44:05 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 832641DB802C
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 15:44:05 +0900 (JST)
Date: Mon, 26 Dec 2011 15:42:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/6] memcg: fix unused variable warning
Message-Id: <20111226154252.d3621532.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111226063652.GA13273@shutemov.name>
References: <1324695619-5537-1-git-send-email-kirill@shutemov.name>
	<20111226152531.e0335ec4.kamezawa.hiroyu@jp.fujitsu.com>
	<20111226063652.GA13273@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, containers@lists.linux-foundation.org, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, 26 Dec 2011 08:36:52 +0200
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Mon, Dec 26, 2011 at 03:25:31PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Sat, 24 Dec 2011 05:00:14 +0200
> > "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> > 
> > > From: "Kirill A. Shutemov" <kirill@shutemov.name>
> > > 
> > > mm/memcontrol.c: In function ‘memcg_check_events’:
> > > mm/memcontrol.c:784:22: warning: unused variable ‘do_numainfo’ [-Wunused-variable]
> > > 
> > > Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
> > 
> > Hmm ? Doesn't this fix cause a new Warning ?
> > 
> > mm/memcontrol.c: In function ?memcg_check_events?:
> > mm/memcontrol.c:789: warning: ISO C90 forbids mixed declarations and code
> 
> I don't see how. The result code is:
> 
> 	if (unlikely(mem_cgroup_event_ratelimit(memcg,
> 						MEM_CGROUP_TARGET_THRESH))) {
> 		bool do_softlimit;
> 
> #if MAX_NUMNODES > 1
> 		bool do_numainfo;
> 		do_numainfo = mem_cgroup_event_ratelimit(memcg,
> 						MEM_CGROUP_TARGET_NUMAINFO);
> #endif
> 		do_softlimit = mem_cgroup_event_ratelimit(memcg,
> 						MEM_CGROUP_TARGET_SOFTLIMIT);
> 		preempt_enable();
> 
> 		mem_cgroup_threshold(memcg);
> 

Ah. please see linux-next and rebase onto that.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
