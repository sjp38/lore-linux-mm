Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id E43436B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 04:25:22 -0500 (EST)
Received: by mail-we0-f182.google.com with SMTP id u57so5315948wes.13
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 01:25:22 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v4si9072762wjz.106.2014.02.11.01.25.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 01:25:21 -0800 (PST)
Date: Tue, 11 Feb 2014 09:25:14 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/4] hugetlb: add hugepagesnid= command-line option
Message-ID: <20140211092514.GH6732@suse.de>
References: <1392053268-29239-1-git-send-email-lcapitulino@redhat.com>
 <alpine.DEB.2.02.1402101851190.3447@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1402101851190.3447@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, mtosatti@redhat.com, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>

On Mon, Feb 10, 2014 at 06:54:20PM -0800, David Rientjes wrote:
> On Mon, 10 Feb 2014, Luiz Capitulino wrote:
> 
> > HugeTLB command-line option hugepages= allows the user to specify how many
> > huge pages should be allocated at boot. On NUMA systems, this argument
> > automatically distributes huge pages allocation among nodes, which can
> > be undesirable.
> > 
> 
> And when hugepages can no longer be allocated on a node because it is too 
> small, the remaining hugepages are distributed over nodes with memory 
> available, correct?
> 
> > The hugepagesnid= option introduced by this commit allows the user
> > to specify which NUMA nodes should be used to allocate boot-time HugeTLB
> > pages. For example, hugepagesnid=0,2,2G will allocate two 2G huge pages
> > from node 0 only. More details on patch 3/4 and patch 4/4.
> > 
> 
> Strange, it would seem better to just reserve as many hugepages as you 
> want so that you get the desired number on each node and then free the 
> ones you don't need at runtime.
> 

Or take a stab at allocating 1G pages at runtime. It would require
finding properly aligned 1Gs worth of contiguous MAX_ORDER_NR_PAGES at
runtime. I would expect it would only work very early in the lifetime of
the system but if the user is willing to use kernel parameters to
allocate them then it should not be an issue.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
