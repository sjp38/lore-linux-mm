Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 885CE6B0031
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 21:54:23 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id y10so6917637pdj.32
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 18:54:23 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id gj4si17343079pac.118.2014.02.10.18.54.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 10 Feb 2014 18:54:22 -0800 (PST)
Received: by mail-pa0-f43.google.com with SMTP id rd3so7046565pab.2
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 18:54:22 -0800 (PST)
Date: Mon, 10 Feb 2014 18:54:20 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 0/4] hugetlb: add hugepagesnid= command-line option
In-Reply-To: <1392053268-29239-1-git-send-email-lcapitulino@redhat.com>
Message-ID: <alpine.DEB.2.02.1402101851190.3447@chino.kir.corp.google.com>
References: <1392053268-29239-1-git-send-email-lcapitulino@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, mtosatti@redhat.com, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>

On Mon, 10 Feb 2014, Luiz Capitulino wrote:

> HugeTLB command-line option hugepages= allows the user to specify how many
> huge pages should be allocated at boot. On NUMA systems, this argument
> automatically distributes huge pages allocation among nodes, which can
> be undesirable.
> 

And when hugepages can no longer be allocated on a node because it is too 
small, the remaining hugepages are distributed over nodes with memory 
available, correct?

> The hugepagesnid= option introduced by this commit allows the user
> to specify which NUMA nodes should be used to allocate boot-time HugeTLB
> pages. For example, hugepagesnid=0,2,2G will allocate two 2G huge pages
> from node 0 only. More details on patch 3/4 and patch 4/4.
> 

Strange, it would seem better to just reserve as many hugepages as you 
want so that you get the desired number on each node and then free the 
ones you don't need at runtime.

That probably doesn't work because we can't free very large hugepages that 
are reserved at boot, would fixing that issue reduce the need for this 
patchset?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
