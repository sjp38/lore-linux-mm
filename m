Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 85CEB8D0001
	for <linux-mm@kvack.org>; Sat, 27 Nov 2010 20:42:06 -0500 (EST)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id oAS1g44Q010644
	for <linux-mm@kvack.org>; Sat, 27 Nov 2010 17:42:04 -0800
Received: from pvg12 (pvg12.prod.google.com [10.241.210.140])
	by wpaz1.hot.corp.google.com with ESMTP id oAS1g2Cx007325
	for <linux-mm@kvack.org>; Sat, 27 Nov 2010 17:42:03 -0800
Received: by pvg12 with SMTP id 12so957106pvg.26
        for <linux-mm@kvack.org>; Sat, 27 Nov 2010 17:42:02 -0800 (PST)
Date: Sat, 27 Nov 2010 17:41:58 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [resend][PATCH 2/4] Revert "oom: deprecate oom_adj tunable"
In-Reply-To: <20101123160259.7B9C.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1011271737110.3764@chino.kir.corp.google.com>
References: <20101114135323.E00D.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1011141333330.22262@chino.kir.corp.google.com> <20101123160259.7B9C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 23 Nov 2010, KOSAKI Motohiro wrote:

> > > No irrelevant. Your patch break their environment even though
> > > they don't use oom_adj explicitly. because their application are using it.
> > > 
> > 
> > The _only_ difference too oom_adj since the rewrite is that it is now 
> > mapped on a linear scale rather than an exponential scale.  
> 
> _only_ mean don't ZERO different. Why do userland application need to rewrite?
> 

Because NOTHING breaks with the new mapping.  Eight months later since 
this was initially proposed on linux-mm, you still cannot show a single 
example that depended on the exponential mapping of oom_adj.  I'm not 
going to continue responding to your criticism about this point since your 
argument is completely and utterly baseless.

> Again, IF you need to [0 .. 1000] range, you can calculate it by your
> application. current oom score can be get from /proc/pid/oom_score and
> total memory can be get from /proc/meminfo. You shouldn't have break
> anything.
> 

That would require the userspace tunable to be adjusted anytime a task's 
mempolicy changes, its nodemask changes, it's cpuset attachment changes, 
its mems change, a memcg limit changes, etc.  The only constant is the 
task's priority, and the current oom_score_adj implementation preserves 
that unless explicitly changed later by the user.  I completely understand 
that you may not have a use for this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
