Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 8201E6B004F
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 18:42:38 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id BA8B23EE081
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 08:42:36 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A148D3A62FE
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 08:42:36 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8828E266DB3
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 08:42:36 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A8DC1DB803B
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 08:42:36 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 336641DB802F
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 08:42:36 +0900 (JST)
Date: Fri, 9 Dec 2011 08:41:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] oom: add tracepoints for oom_score_adj
Message-Id: <20111209084103.e3fea1f7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4EE0F4EF.4010301@jp.fujitsu.com>
References: <20111207095434.5f2fed4b.kamezawa.hiroyu@jp.fujitsu.com>
	<4EDF99B2.6040007@jp.fujitsu.com>
	<20111208104705.b2e50039.kamezawa.hiroyu@jp.fujitsu.com>
	<4EE0F4EF.4010301@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, rientjes@google.com, dchinner@redhat.com

On Thu, 08 Dec 2011 12:33:35 -0500
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> On 12/7/2011 8:47 PM, KAMEZAWA Hiroyuki wrote:
> > On Wed, 07 Dec 2011 11:52:02 -0500
> > KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > 
> >> On 12/6/2011 7:54 PM, KAMEZAWA Hiroyuki wrote:
> >>> >From 28189e4622fd97324893a0b234183f64472a54d6 Mon Sep 17 00:00:00 2001
> >>> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >>> Date: Wed, 7 Dec 2011 09:58:16 +0900
> >>> Subject: [PATCH] oom: trace point for oom_score_adj
> >>>
> >>> oom_score_adj is set to prevent a task from being killed by OOM-Killer.
> >>> Some daemons sets this value and their children inerit it sometimes.
> >>> Because inheritance of oom_score_adj is done automatically, users
> >>> can be confused at seeing the value and finds it's hard to debug.
> >>>
> >>> This patch adds trace point for oom_score_adj. This adds 3 trace
> >>> points. at
> >>> 	- update oom_score_adj
> >>
> >>
> >>> 	- fork()
> >>> 	- rename task->comm(typically, exec())
> >>
> >> I don't think they have oom specific thing. Can you please add generic fork and
> >> task rename tracepoint instead?
> >>
> > I think it makes oom-targeted debug difficult.
> > This tracehook using task->signal->oom_score_adj as filter.
> > This reduces traces much and makes debugging easier.
> >  
> > If you need another trace point for other purpose, another trace point
> > should be better. For generic purpose, oom_socre_adj filtering will not
> > be necessary.
> 
> see Documentation/trace/event.txt 5. Event filgtering
> 
> Now, both ftrace and perf have good filter feature. Isn't this enough?
> 

Could you make patch ? Then, I stop this and go other probelm.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
