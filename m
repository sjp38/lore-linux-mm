Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 972146B007B
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 22:10:18 -0400 (EDT)
Date: Wed, 15 Sep 2010 19:16:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] oom: filter unkillable tasks from tasklist dump
Message-Id: <20100915191631.92892ea5.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1009151903560.6001@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1009011426260.28408@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1009151903560.6001@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 Sep 2010 19:04:45 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> On Wed, 1 Sep 2010, David Rientjes wrote:
> 
> > /proc/sys/vm/oom_dump_tasks is enabled by default, so it's necessary to
> > limit as much information as possible that it should emit.
> > 
> > The tasklist dump should be filtered to only those tasks that are
> > eligible for oom kill.  This is already done for memcg ooms, but this
> > patch extends it to both cpuset and mempolicy ooms as well as init.
> > 
> > In addition to suppressing irrelevant information, this also reduces
> > confusion since users currently don't know which tasks in the tasklist
> > aren't eligible for kill (such as those attached to cpusets or bound to
> > mempolicies with a disjoint set of mems or nodes, respectively) since
> > that information is not shown.
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> Andrew, did you have a chance to look at this and consider it for -mm?

Once the backlog gets too big I start working on it in reverse order :(
I'd have got onto Sep 1 tomorrow.

Got it now, scheduled it for 2.6.36.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
