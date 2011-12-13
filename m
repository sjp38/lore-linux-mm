Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 900256B0292
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 18:53:55 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id A72003EE0BB
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 08:53:53 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 910CA45DE50
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 08:53:53 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 78A7F45DE4F
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 08:53:53 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C1601DB8037
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 08:53:53 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D5AA81DB803E
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 08:53:52 +0900 (JST)
Date: Wed, 14 Dec 2011 08:52:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v4] oom: add trace points for debugging.
Message-Id: <20111214085236.42c02bda.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111213145851.c7e5d8fa.akpm@linux-foundation.org>
References: <20111213181225.673e19db.kamezawa.hiroyu@jp.fujitsu.com>
	<20111213145851.c7e5d8fa.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, rientjes@google.com

On Tue, 13 Dec 2011 14:58:51 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 13 Dec 2011 18:12:25 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > Changelog:
> >  - devided into oom tracepoint and task tracepoint.
> >  - task tracepoint traces fork/rename
> >  - oom tracepoint traces modification to oom_score_adj.
> > 
> > dropped acks because of total design changes.
> > 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Subject: [PATCH] tracepoint: add tracepoints for debugging oom_score_adj.
> > 
> > oom_score_adj is used for guarding processes from OOM-Killer. One of problem
> > is that it's inherited at fork(). When a daemon set oom_score_adj and
> > make children, it's hard to know where the value is set.
> 
> This sounds like a really thin justification for patching the kernel. 
> "Help! I don't know what my code is doing!".
> 
> Alternatives would include grepping your source code for
> "oom_score_adj", or running "strace -f"!
> 
> I suspect you did have a good reason for making this change, but it
> wasn't explained very well?
> 

Ah, one example is this thread.
- http://marc.info/?t=132273239800008&r=1&w=4
oom_score_adj was inherited by sshd by bug?

And IIUC, I saw other issues with other task launchers as Gnome.

If the problem is caused by some daemon, strace -f is not very good.
And the user will not have the source codes. So, I thought it's better
to have tracepoints to see what is wrong in application chains.


Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
