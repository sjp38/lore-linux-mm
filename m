Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id 8B25C6B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 11:25:08 -0500 (EST)
Received: by mail-qa0-f42.google.com with SMTP id k4so12241619qaq.29
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 08:25:07 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id v8si12757370qab.65.2014.02.11.08.24.58
        for <linux-mm@kvack.org>;
        Tue, 11 Feb 2014 08:25:06 -0800 (PST)
Date: Tue, 11 Feb 2014 13:26:29 -0200
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [PATCH 0/4] hugetlb: add hugepagesnid= command-line option
Message-ID: <20140211152629.GA28210@amt.cnet>
References: <1392053268-29239-1-git-send-email-lcapitulino@redhat.com>
 <alpine.DEB.2.02.1402101851190.3447@chino.kir.corp.google.com>
 <20140211092514.GH6732@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140211092514.GH6732@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: David Rientjes <rientjes@google.com>, Luiz Capitulino <lcapitulino@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>

On Tue, Feb 11, 2014 at 09:25:14AM +0000, Mel Gorman wrote:
> On Mon, Feb 10, 2014 at 06:54:20PM -0800, David Rientjes wrote:
> > On Mon, 10 Feb 2014, Luiz Capitulino wrote:
> > 
> > > HugeTLB command-line option hugepages= allows the user to specify how many
> > > huge pages should be allocated at boot. On NUMA systems, this argument
> > > automatically distributes huge pages allocation among nodes, which can
> > > be undesirable.
> > > 
> > 
> > And when hugepages can no longer be allocated on a node because it is too 
> > small, the remaining hugepages are distributed over nodes with memory 
> > available, correct?
> > 
> > > The hugepagesnid= option introduced by this commit allows the user
> > > to specify which NUMA nodes should be used to allocate boot-time HugeTLB
> > > pages. For example, hugepagesnid=0,2,2G will allocate two 2G huge pages
> > > from node 0 only. More details on patch 3/4 and patch 4/4.
> > > 
> > 
> > Strange, it would seem better to just reserve as many hugepages as you 
> > want so that you get the desired number on each node and then free the 
> > ones you don't need at runtime.

You have to know the behaviour of the allocator, and rely on that 
to allocate the exact number of 1G hugepages on a particular node.

Is that desired in constrast with specifying the exact number, and
location, of hugepages to allocated?

> Or take a stab at allocating 1G pages at runtime. It would require
> finding properly aligned 1Gs worth of contiguous MAX_ORDER_NR_PAGES at
> runtime. I would expect it would only work very early in the lifetime of
> the system but if the user is willing to use kernel parameters to
> allocate them then it should not be an issue.

Can be an improvement on top of the current patchset? Certain use-cases
require allocation guarantees (even if that requires kernel parameters).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
