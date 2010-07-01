Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1BA486B01B0
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 20:06:58 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o61073m1010146
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 1 Jul 2010 09:07:04 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C7CAD45DE55
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 09:07:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AA06245DE51
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 09:07:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B2151DB803C
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 09:07:03 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4BBA01DB803A
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 09:07:03 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 05/11] oom: /proc/<pid>/oom_score treat kernel thread honestly
In-Reply-To: <20100630140328.GC15644@barrios-desktop>
References: <20100630182922.AA56.A69D9226@jp.fujitsu.com> <20100630140328.GC15644@barrios-desktop>
Message-Id: <20100701085309.DA16.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Thu,  1 Jul 2010 09:07:02 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> On Wed, Jun 30, 2010 at 06:30:19PM +0900, KOSAKI Motohiro wrote:
> > If kernel thread are using use_mm(), badness() return positive value.
> > This is not big issue because caller care it correctly. but there is
> > one exception, /proc/<pid>/oom_score call badness() directly and
> > don't care the task is regular process.
> > 
> > another example, /proc/1/oom_score return !0 value. but it's unkillable.
> > This incorrectness makes confusing to admin a bit.
> 
> Hmm. If it is a really problem, Could we solve it in proc_oom_score itself?

probably, no good idea. For maintainance view, all oom related code should
be gathered in oom_kill.c.
If you dislike to add messy into badness(), I hope to make badness_for_oom_score()
or something like instead.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
