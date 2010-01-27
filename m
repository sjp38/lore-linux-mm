Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A52136B0099
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 19:20:21 -0500 (EST)
Date: Tue, 26 Jan 2010 16:19:52 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] oom-kill: add lowmem usage aware oom kill handling
Message-Id: <20100126161952.ee267d1c.akpm@linux-foundation.org>
In-Reply-To: <20100127085355.f5306e78.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com>
	<20100122152332.750f50d9.kamezawa.hiroyu@jp.fujitsu.com>
	<20100125151503.49060e74.kamezawa.hiroyu@jp.fujitsu.com>
	<20100126151202.75bd9347.akpm@linux-foundation.org>
	<20100127085355.f5306e78.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, rientjes@google.com, minchan.kim@gmail.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 27 Jan 2010 08:53:55 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> > Hardly anyone will know to enable
> > it so the feature won't get much testing and this binary decision
> > fractures the testing effort.  It would be much better if we can get
> > everyone running the same code.  I mean, if there are certain workloads
> > on certain machines with which the oom-killer doesn't behave correctly
> > then fix it!
> Yes, I think you're right. But "breaking current behaviro of our servers!"
> arguments kills all proposal to this area and this oom-killer or vmscan is
> a feature should be tested by real users. (I'll write fork-bomb detector
> and RSS based OOM again.)

Well don't break their servers then ;)

What I'm not understanding is: why is it not possible to improve the
behaviour on the affected machines without affecting the behaviour on
other machines?

What are these "servers" to which you refer?  x86_32 servers, I assume
- the patch shouldn't affect 64-bit machines.  Why don't they also want
this treatment and in what way does the patch "break" them?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
