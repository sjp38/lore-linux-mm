Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1BDF36B01EF
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 09:29:28 -0400 (EDT)
Subject: Re: [PATCH 0/8] Numa: Use Generic Per-cpu Variables for numa_*_id()
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <4BCA7A26.9040208@kernel.org>
References: <20100415172950.8801.60358.sendpatchset@localhost.localdomain>
	 <4BCA7A26.9040208@kernel.org>
Content-Type: text/plain
Date: Mon, 19 Apr 2010 09:29:20 -0400
Message-Id: <1271683760.10937.35.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, andi@firstfloor.org, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Sun, 2010-04-18 at 12:19 +0900, Tejun Heo wrote:
> On 04/16/2010 02:29 AM, Lee Schermerhorn wrote:
> > Use Generic Per cpu infrastructure for numa_*_id() V4
> > 
> > Series Against: 2.6.34-rc3-mmotm-100405-1609
> 
> Other than the minor nitpicks, the patchset looks great to me.
> Through which tree should this be routed?  If no one else is gonna
> take it, I can route it through percpu after patchset refresh.

Andrew has merged this set into the -mm tree.  I think that's fine and
will proceed to address all of the comments there as incremental
patches.

I have comments/requests from yourself:

2/8:  seconding Christoph's suggestion re: generic function to add
generic function to set per cpu node id; plus suggestion to use
numa_node_id() in common.c::cpu_init().

4/8:  lose the "#define numa_mem numa_node".  I'll need to rework this.
Currently, one can access the per cpu variable 'numa_node' directly as
such.  I added 'numa_mem' [actually got it from Christoph's starter
patch] as an analog to numa_node.  I/Christoph wanted to eliminate the
redundant variable when it wasn't needed, but not break code that
directly accesses it.  Maybe better to not provide it at all?  

5/8:  wording error in patch description.

Randy D and Kamezawa-san:  comments on documentation patch

Kame-san:  request for clarification in 3/8

Thanks,
Lee





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
