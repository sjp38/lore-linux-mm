Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B81076B0011
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 23:23:56 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 2A1633EE0BC
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 12:23:54 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FF3B45DEA0
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 12:23:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E82E945DEA2
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 12:23:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D6B3F1DB8038
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 12:23:53 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A0BA3E08001
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 12:23:53 +0900 (JST)
Date: Tue, 26 Apr 2011 12:17:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] use oom_killer_disabled in all oom pathes
Message-Id: <20110426121719.95894bc5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTino+9_GEb28gfZYSu-R0JW44M1mqQ@mail.gmail.com>
References: <20110426115902.F374.A69D9226@jp.fujitsu.com>
	<BANLkTimpidn07YRmm0gNDice3xo-tC8kow@mail.gmail.com>
	<20110426121555.F378.A69D9226@jp.fujitsu.com>
	<BANLkTino+9_GEb28gfZYSu-R0JW44M1mqQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <hidave.darkstar@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 26 Apr 2011 11:19:22 +0800
Dave Young <hidave.darkstar@gmail.com> wrote:

> On Tue, Apr 26, 2011 at 11:14 AM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> On Tue, Apr 26, 2011 at 10:57 AM, KOSAKI Motohiro
> >> <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> >> oom_killer_disable should be a global switch, also fit for oom paths
> >> >> other than __alloc_pages_slowpath
> >> >>
> >> >> Here add it to mem_cgroup_handle_oom and pagefault_out_of_memory as well.
> >> >
> >> > Can you please explain more? Why should? Now oom_killer_disabled is used
> >> > only hibernation path. so, Why pagefault and memcg allocation will be happen?
> >>
> >> Indeed I'm using it in virtio balloon test, oom killer triggered when
> >> memory pressure is high.
> >>
> >> literally oom_killer_disabled scope should be global, isn't it?
> >
> > ok. virtio baloon seems fair usage. if you add new usage of oom_killer_disabled
> > into the patch description, I'll ack this one.
> 
> Thanks, then I will resend the virtio balloon patch along with this.
> 

Amount of free memory doesn't affect memory cgroup's OOM because it just works
against the limit. So, the code for memcg isn't necessary.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
