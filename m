Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6D35B6B007D
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 04:04:25 -0500 (EST)
Date: Tue, 16 Feb 2010 20:04:08 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/7 -mm] oom: filter tasks not sharing the same cpuset
Message-ID: <20100216090408.GL5723@laptop>
References: <20100215115154.727B.A69D9226@jp.fujitsu.com>
 <alpine.DEB.2.00.1002151401280.26927@chino.kir.corp.google.com>
 <20100216110859.72C6.A69D9226@jp.fujitsu.com>
 <20100216070344.GF5723@laptop>
 <alpine.DEB.2.00.1002160047340.17122@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1002160047340.17122@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 16, 2010 at 12:49:14AM -0800, David Rientjes wrote:
> On Tue, 16 Feb 2010, Nick Piggin wrote:
> 
> > Yes we do need to explain the downside of the patch. It is a
> > heuristic and we can't call either approach perfect.
> > 
> > The fact is that even if 2 tasks are on completely disjoint
> > memory policies and never _allocate_ from one another's nodes,
> > you can still have one task pinning memory of the other task's
> > node.
> > 
> > Most shared and userspace-pinnable resources (pagecache, vfs
> > caches and fds files sockes etc) are allocated by first-touch
> > basically.
> > 
> > I don't see much usage of cpusets and oom killer first hand in
> > my experience, so I am happy to defer to others when it comes
> > to heuristics. Just so long as we are all aware of the full
> > story :)
> > 
> 
> Unless you can present a heuristic that will determine how much memory 
> usage a given task has allocated on nodes in current's zonelist, we must 
> exclude tasks from cpusets with a disjoint set of nodes, otherwise we 
> cannot determine the optimal task to kill.  There's a strong possibility 
> that killing a task on a disjoint set of mems will never free memory for 
> current, making it a needless kill.  That's a much more serious 
> consequence than not having the patch, in my opinion, than rather simply 
> killing current.

I don't really agree with your black and white view. We equally
can't tell a lot of cases about who is pinning memory where. The
fact is that any task can be pinning memory and the heuristic
was specifically catering for that.

It's not an issue of yes/no, but of more/less probability. Anyway
I wasn't really arguing against your patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
