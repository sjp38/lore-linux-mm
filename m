Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 88C6C6B01E3
	for <linux-mm@kvack.org>; Wed, 12 May 2010 16:03:47 -0400 (EDT)
Subject: Re: [PATCH 6/8] numa: slab: use numa_mem_id() for slab local
 memory node
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <4170.1273692351@localhost>
References: <20100415172950.8801.60358.sendpatchset@localhost.localdomain>
	 <20100415173030.8801.84836.sendpatchset@localhost.localdomain>
	 <20100512114900.a12c4b35.akpm@linux-foundation.org>
	 <1273691503.6985.142.camel@useless.americas.hpqcorp.net>
	 <4170.1273692351@localhost>
Content-Type: text/plain
Date: Wed, 12 May 2010 16:03:35 -0400
Message-Id: <1273694615.6985.153.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Valdis.Kletnieks@vt.edu
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-numa@vger.kernel.org, Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-05-12 at 15:25 -0400, Valdis.Kletnieks@vt.edu wrote:
> On Wed, 12 May 2010 15:11:43 EDT, Lee Schermerhorn said:
> > On Wed, 2010-05-12 at 11:49 -0700, Andrew Morton wrote:
> > > I have a note here that this patch "breaks slab.c".  But I don't recall what
> > > the problem was and I don't see a fix against this patch in your recently-sent
> > > fixup series?
> > 
> > Is that Valdis Kletnieks' issue?  That was an i386 build.  Happened
> > because the earlier patches didn't properly default numa_mem_id() to
> > numa_node_id() for the i386 build.  The rework to those patches has
> > fixed that.   I have successfully built mmotm with the rework patches
> > for i386+!NUMA.  Valdis tested the series and confirmed that it fixed
> > the problem.
> 
> I thought the problem was common to both i386 and X86_64 non-NUMA (which is
> where I hit the problem). In any case, builds OK for me now.

The x86_64 !NUMA issue was another one I introduced in the rework --
patch 1/7 first version you tested.   Fixed in the current version.

Happened because x86_64 defines it's own fallback for numa_node_id().
See the description of patch 1/7.  Turns out x86_64 builds fine with
NUMA or !NUMA if I just remove the !NUMA numa_node_id() definition.
I'll submit that patch shortly.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
