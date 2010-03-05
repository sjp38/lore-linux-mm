Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F0BB06B00A1
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 20:26:07 -0500 (EST)
Subject: Re: [PATCH/RFC 0/8] Numa: Use Generic Per-cpu Variables for
 numa_*_id()
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20100305101912.f0a875df.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100304170654.10606.32225.sendpatchset@localhost.localdomain>
	 <20100305101912.f0a875df.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Thu, 04 Mar 2010 20:25:59 -0500
Message-Id: <1267752359.29020.260.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-numa@vger.kernel.org, Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, akpm@linux-foundation.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 2010-03-05 at 10:19 +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 04 Mar 2010 12:06:54 -0500
> Lee Schermerhorn <lee.schermerhorn@hp.com> wrote:
> 
> > >nid-04:
> > >
> > >* Isn't #define numa_mem numa_node a bit dangerous?  Someone might use
> > >  numa_mem as a local variable name.  Why not define it as a inline
> > >  function or at least a macro which takes argument.
> > 
> > numa_mem and numa_node are the names of the per cpu variables, referenced
> > by __this_cpu_read().  So, I suppose we can rename them both something like:
> > percpu_numa_*.  Would satisfy your concern?
> > 
> > What do others think?
> > 
> > Currently I've left them as numa_mem and numa_node.
> > 
> 
> Could you add some documentation to Documentation/vm/numa ?
> about
>   numa_node_id()
>   numa_mem_id()
>   topics on memory-less node
>   (cpu-less node)


Hmmm.  Good idea.  I'll see what I can come up with.

Thanks,
Lee

>   
> 
> Recently I see this kind of topics on list but I'm not sure whether
> I catch the issues/changes correctly....
> 
> Thanks,
> -Kame
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
