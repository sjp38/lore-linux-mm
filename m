Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C70CA6B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 23:25:18 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 698163EE081
	for <linux-mm@kvack.org>; Tue, 31 May 2011 12:25:15 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E3C645DED0
	for <linux-mm@kvack.org>; Tue, 31 May 2011 12:25:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 31DB545DEC7
	for <linux-mm@kvack.org>; Tue, 31 May 2011 12:25:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 243F51DB8047
	for <linux-mm@kvack.org>; Tue, 31 May 2011 12:25:15 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DF833E08001
	for <linux-mm@kvack.org>; Tue, 31 May 2011 12:25:14 +0900 (JST)
Date: Tue, 31 May 2011 12:18:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm, vmstat: Use cond_resched only when !CONFIG_PREEMPT
Message-Id: <20110531121815.67523361.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTinTqijGxCpZ_nRwWZHYsR-u2zojZA@mail.gmail.com>
References: <1306774744.4061.5.camel@localhost.localdomain>
	<20110531083859.98e4ff43.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTinTqijGxCpZ_nRwWZHYsR-u2zojZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rakib Mullick <rakib.mullick@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Christoph Lameter <cl@linux.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Tue, 31 May 2011 09:13:47 +0600
Rakib Mullick <rakib.mullick@gmail.com> wrote:

> On Tue, May 31, 2011 at 5:38 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Mon, 30 May 2011 22:59:04 +0600
> > Rakib Mullick <rakib.mullick@gmail.com> wrote:
> >
> >> commit 468fd62ed9 (vmstats: add cond_resched() to refresh_cpu_vm_stats()) added cond_resched() in refresh_cpu_vm_stats. Purpose of that patch was to allow other threads to run in non-preemptive case. This patch, makes sure that cond_resched() gets called when !CONFIG_PREEMPT is set. In a preemptiable kernel we don't need to call cond_resched().
> >>
> >> Signed-off-by: Rakib Mullick <rakib.mullick@gmail.com>
> >
> > Hmm, what benefit do we get by adding this extra #ifdef in the code directly ?
> > Other cond_resched() callers are not guilty in !CONFIG_PREEMPT ?
> >
> Well, in preemptible kernel this context will get preempted if
> requires, so we don't need cond_resched(). If you checkout the git log
> of the mentioned commit, you'll find the explanation. It says:
>         "Adding a cond_resched() to allow other threads to run in the
> non-preemptive
>     case."
> 

IOW, my question is "why only this cond_resched() should be fixed ?"
What's bad with all cond_resched() in the kernel as no-op in CONFIG_PREEMPT ?

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
