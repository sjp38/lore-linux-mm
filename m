Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 8BD2B6B004F
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 20:48:18 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 405B93EE0BC
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 10:48:16 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 26AD12E6944
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 10:48:16 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0DCA22E6942
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 10:48:16 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F1D8D1DB8051
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 10:48:15 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A68031DB804D
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 10:48:15 +0900 (JST)
Date: Thu, 8 Dec 2011 10:47:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] oom: add tracepoints for oom_score_adj
Message-Id: <20111208104705.b2e50039.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4EDF99B2.6040007@jp.fujitsu.com>
References: <20111207095434.5f2fed4b.kamezawa.hiroyu@jp.fujitsu.com>
	<4EDF99B2.6040007@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, rientjes@google.com, dchinner@redhat.com

On Wed, 07 Dec 2011 11:52:02 -0500
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> On 12/6/2011 7:54 PM, KAMEZAWA Hiroyuki wrote:
> >>From 28189e4622fd97324893a0b234183f64472a54d6 Mon Sep 17 00:00:00 2001
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Date: Wed, 7 Dec 2011 09:58:16 +0900
> > Subject: [PATCH] oom: trace point for oom_score_adj
> > 
> > oom_score_adj is set to prevent a task from being killed by OOM-Killer.
> > Some daemons sets this value and their children inerit it sometimes.
> > Because inheritance of oom_score_adj is done automatically, users
> > can be confused at seeing the value and finds it's hard to debug.
> > 
> > This patch adds trace point for oom_score_adj. This adds 3 trace
> > points. at
> > 	- update oom_score_adj
> 
> 
> > 	- fork()
> > 	- rename task->comm(typically, exec())
> 
> I don't think they have oom specific thing. Can you please add generic fork and
> task rename tracepoint instead?
> 
I think it makes oom-targeted debug difficult.
This tracehook using task->signal->oom_score_adj as filter.
This reduces traces much and makes debugging easier.
 
If you need another trace point for other purpose, another trace point
should be better. For generic purpose, oom_socre_adj filtering will not
be necessary.





> > 
> > Outputs will be following.
> >    bash-2404  [006]   199.620841: oom_score_adj_update: task 2404[bash] updates oom_score_ad  j=-1000
> 
> "task 2404[bash]" don't look good to me.
> 
> In almost case, we use either
> 
>  - [pid] comm
>  - pid:comm
>  - comm:pid
>  - comm-pid    (ftrace specific)
> 
> Why do we need to introduce alternative printing style?
> 

No reason. ok, I'll fix.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
