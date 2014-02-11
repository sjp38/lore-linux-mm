Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id 857166B0037
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 13:58:53 -0500 (EST)
Received: by mail-qa0-f42.google.com with SMTP id k4so12582745qaq.29
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 10:58:53 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 9si13177315qgl.24.2014.02.11.10.58.52
        for <linux-mm@kvack.org>;
        Tue, 11 Feb 2014 10:58:53 -0800 (PST)
Date: Tue, 11 Feb 2014 10:36:24 -0500
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH 0/4] hugetlb: add hugepagesnid= command-line option
Message-ID: <20140211103624.7edf1423@redhat.com>
In-Reply-To: <alpine.DEB.2.02.1402101851190.3447@chino.kir.corp.google.com>
References: <1392053268-29239-1-git-send-email-lcapitulino@redhat.com>
	<alpine.DEB.2.02.1402101851190.3447@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, mtosatti@redhat.com, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>

On Mon, 10 Feb 2014 18:54:20 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

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

No. hugepagesnid= tries to obey what was specified by the uses as much as
possible. So, if you specify that 10 1G huge pages should be allocated from
node0 but only 7 1G pages can actually be allocated, then hugepagesnid= will
do just that.

> > The hugepagesnid= option introduced by this commit allows the user
> > to specify which NUMA nodes should be used to allocate boot-time HugeTLB
> > pages. For example, hugepagesnid=0,2,2G will allocate two 2G huge pages
> > from node 0 only. More details on patch 3/4 and patch 4/4.
> > 
> 
> Strange, it would seem better to just reserve as many hugepages as you 
> want so that you get the desired number on each node and then free the 
> ones you don't need at runtime.

You mean, for example, if I have a 2 node system and want 2 1G huge pages
from node 1, then I have to allocate 4 1G huge pages and then free 2 pages
on node 0 after boot? That seems very cumbersome to me. Besides, what if
node0 needs this memory during boot?

> That probably doesn't work because we can't free very large hugepages that 
> are reserved at boot, would fixing that issue reduce the need for this 
> patchset?

I don't think so.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
