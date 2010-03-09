Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AAE256B00AF
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 03:46:54 -0500 (EST)
Message-ID: <4B960AD0.8010709@kernel.org>
Date: Tue, 09 Mar 2010 17:46:08 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH/RFC 1/8] numa: prep:  move generic percpu interface definitions
 to percpu-defs.h
References: <20100304170654.10606.32225.sendpatchset@localhost.localdomain> <20100304170702.10606.85808.sendpatchset@localhost.localdomain>
In-Reply-To: <20100304170702.10606.85808.sendpatchset@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-numa@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, akpm@linux-foundation.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

Hello,

On 03/05/2010 02:07 AM, Lee Schermerhorn wrote:
> To use the generic percpu infrastructure for the numa_node_id() interface,
> defined in linux/topology.h, we need to break the circular header dependency
> that results from including <linux/percpu.h> in <linux/topology.h>.  The
> circular dependency:
> 
> 	percpu.h -> slab.h -> gfp.h -> topology.h
> 
> percpu.h includes slab.h to obtain the definition of kzalloc()/kfree() for
> inlining __alloc_percpu() and free_percpu() in !SMP configurations.  One could
> un-inline these functions in the !SMP case, but a large number of files depend
> on percpu.h to include slab.h.  Tejun Heo suggested moving the definitions to
> percpu-defs.h and requested that this be separated from the remainder of the
> generic percpu numa_node_id() preparation patch.

Hmmm... I think uninlining !SMP case would be much cleaner.  Sorry
that you had to do it twice.  I'll break the dependency in the percpu
devel branch and let you know.

For other patches, except for what Christoph has already pointed out,
everything looks good to me.

Thank you.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
