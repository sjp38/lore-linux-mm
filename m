Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DC0D56B0078
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 08:42:32 -0400 (EDT)
Date: Tue, 28 Sep 2010 07:42:30 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [S+Q Cleanup3 4/6] slub: Dynamically size kmalloc cache
 allocations
In-Reply-To: <alpine.DEB.2.00.1009280305100.6773@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1009280740470.4144@router.home>
References: <20100819203324.549566024@linux.com> <20100819203438.745611155@linux.com> <alpine.DEB.2.00.1008191405230.18994@chino.kir.corp.google.com> <alpine.DEB.2.00.1008191627100.5611@router.home> <alpine.DEB.2.00.1008191600240.25634@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1008191819420.7903@router.home> <alpine.DEB.2.00.1008191638390.29676@chino.kir.corp.google.com> <alpine.DEB.2.00.1008201206390.32757@router.home> <alpine.DEB.2.00.1008201231520.32757@router.home>
 <alpine.DEB.2.00.1009280305100.6773@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 28 Sep 2010, David Rientjes wrote:

> > Draft patch to drop SMP particularities.
> s/SMP/NUMA/

No its the special code for SMP. The local_node field is the main issue.

> I really like this direction and I hope you push an updated version to
> Pekka because it cleans up a lot of the recently added init code without
> sacrificing any footprint for UMA.

Ok. I have another 2 cleanup patches here. Will update this and push all 3
all out today.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
