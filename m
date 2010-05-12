Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EB0DF6B01EF
	for <linux-mm@kvack.org>; Wed, 12 May 2010 15:12:57 -0400 (EDT)
Subject: Re: [PATCH 6/8] numa: slab:  use numa_mem_id() for slab local
 memory node
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20100512114900.a12c4b35.akpm@linux-foundation.org>
References: <20100415172950.8801.60358.sendpatchset@localhost.localdomain>
	 <20100415173030.8801.84836.sendpatchset@localhost.localdomain>
	 <20100512114900.a12c4b35.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Wed, 12 May 2010 15:11:43 -0400
Message-Id: <1273691503.6985.142.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Valdis.Kletnieks@vt.edu
List-ID: <linux-mm.kvack.org>

On Wed, 2010-05-12 at 11:49 -0700, Andrew Morton wrote:
> I have a note here that this patch "breaks slab.c".  But I don't recall what
> the problem was and I don't see a fix against this patch in your recently-sent
> fixup series?

Is that Valdis Kletnieks' issue?  That was an i386 build.  Happened
because the earlier patches didn't properly default numa_mem_id() to
numa_node_id() for the i386 build.  The rework to those patches has
fixed that.   I have successfully built mmotm with the rework patches
for i386+!NUMA.  Valdis tested the series and confirmed that it fixed
the problem.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
