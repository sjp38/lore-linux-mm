Date: Fri, 26 Oct 2007 14:11:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: OOM notifications
Message-Id: <20071026141112.18af0fa6.akpm@linux-foundation.org>
In-Reply-To: <472256AB.6060109@mbligh.org>
References: <20071018201531.GA5938@dmt>
	<20071026140201.ae52757c.akpm@linux-foundation.org>
	<472256AB.6060109@mbligh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Bligh <mbligh@mbligh.org>
Cc: marcelo@kvack.org, linux-kernel@vger.kernel.org, drepper@redhat.com, riel@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 Oct 2007 14:05:47 -0700
Martin Bligh <mbligh@mbligh.org> wrote:

> > Martin was talking about some mad scheme wherin you'd create a bunch of
> > pseudo files (say, /proc/foo/0, /proc/foo/1, ..., /proc/foo/9) and each one
> > would become "ready" when the MM scanning priority reaches 10%, 20%, ... 
> > 100%.
> > 
> > Obviously there would need to be a lot of abstraction to unhook a permanent
> > userspace feature from a transient kernel implementation, but the basic
> > idea is that a process which wants to know when the VM is getting into the
> > orange zone would select() on the file "7" and a process which wants to
> > know when the VM is getting into the red zone would select on file "9".
> > 
> > It get more complicated with NUMA memory nodes and cgroup memory
> > controllers.
> 
> We ended up not doing that, but making a scanner that saw what
> percentage of the LRU was touched in the last n seconds, and
> printing that to userspace to deal with.
> 
> Turns out priority is a horrible metric to use for this - it
> stays at default for ages, then falls off a cliff far too
> quickly to react to.

Sure, but in terms of high-level userspace interface, being able to
select() on a group of priority buckets (spread across different nodes,
zones and cgroups) seems a lot more flexible than any signal-based
approach we could come up with.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
