Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3D9806B0085
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 08:03:48 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAUD3ijT026818
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 30 Nov 2010 22:03:44 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AC77645DE55
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 22:03:44 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 92C5C45DD74
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 22:03:44 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 865951DB803A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 22:03:44 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 517561DB803B
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 22:03:44 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [resend][PATCH 2/4] Revert "oom: deprecate oom_adj tunable"
In-Reply-To: <alpine.DEB.2.00.1011271737110.3764@chino.kir.corp.google.com>
References: <20101123160259.7B9C.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1011271737110.3764@chino.kir.corp.google.com>
Message-Id: <20101130220221.832B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 30 Nov 2010 22:03:43 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Tue, 23 Nov 2010, KOSAKI Motohiro wrote:
> 
> > > > No irrelevant. Your patch break their environment even though
> > > > they don't use oom_adj explicitly. because their application are using it.
> > > > 
> > > 
> > > The _only_ difference too oom_adj since the rewrite is that it is now 
> > > mapped on a linear scale rather than an exponential scale.  
> > 
> > _only_ mean don't ZERO different. Why do userland application need to rewrite?
> > 
> 
> Because NOTHING breaks with the new mapping.  Eight months later since 
> this was initially proposed on linux-mm, you still cannot show a single 
> example that depended on the exponential mapping of oom_adj.  I'm not 
> going to continue responding to your criticism about this point since your 
> argument is completely and utterly baseless.

No regression mean no break. Not single nor multiple. see?


> 
> > Again, IF you need to [0 .. 1000] range, you can calculate it by your
> > application. current oom score can be get from /proc/pid/oom_score and
> > total memory can be get from /proc/meminfo. You shouldn't have break
> > anything.
> > 
> 
> That would require the userspace tunable to be adjusted anytime a task's 
> mempolicy changes, its nodemask changes, it's cpuset attachment changes, 

All situation can be calculated on userland. User process can be know
their bindings.



> its mems change, a memcg limit changes, etc.  The only constant is the 
> task's priority, and the current oom_score_adj implementation preserves 
> that unless explicitly changed later by the user.  I completely understand 
> that you may not have a use for this.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
