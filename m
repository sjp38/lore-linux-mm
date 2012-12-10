Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id B5DCB6B005A
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 05:13:18 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Mon, 10 Dec 2012 05:13:17 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id BF1CCC90026
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 05:13:14 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qBAADE1T306236
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 05:13:14 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qBAADEN8016806
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 05:13:14 -0500
Date: Mon, 10 Dec 2012 15:12:57 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 00/45] Automatic NUMA Balancing V7
Message-ID: <20121210094257.GB6348@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1353612353-1576-1-git-send-email-mgorman@suse.de>
 <20121126145800.GK8218@suse.de>
 <20121128134930.GB20087@suse.de>
 <20121207104539.GB22164@linux.vnet.ibm.com>
 <20121210090730.GF1009@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20121210090730.GF1009@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> > 
> > Got a chance to run autonuma-benchmark on a 8 node, 64 core machine. 
> > the results are as below. (for each kernel I ran 5 iterations of
> > autonuma-benchmark)
> > 
> 
> Thanks, a test of v10 would also be appreciated. The differences between
> V7 and V10 are small but do include a change in how migrate rate-limiting
> is handled. It is unlikely it'll make a difference to this test but I'd
> like to rule it out.
> 


Yes, have queued it for testing. Will report on completion.


> > KernelVersion: 3.7.0-rc3-mainline_v37rc7()

Please read it as 3.7-rc3 

> 
> What kernel is this? The name begins with 3.7-rc3 but then says
> v37rc7. v37rc7 of what? I thought it might be v3.7-rc7 but it already said
> it's 3.7-rc3 so I'm confused. Would it be possible to base the tests on
> a similar baseline kernel such as 3.7.0-rc7 or 3.7.0-rc8? The



> balancenuma patches should apply and the autonuma patches can be taken
> from the mm-autonuma-v28fastr4-mels-rebase branch in
> git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux-balancenuma.git
> 

Yes, for the next set of reports I have based autonuma branch on this
branch.

> Either way, the figures look bad. I'm trying to find a similar machine
> but initially at least I have not had much luck. Can you post the .config
> you used for balancenuma in case I can reproduce the problem on a 4-node
> machine please? Are all the nodes the same size?
> 

No all nodes are not of same size
There are 6 32 GB nodes and 2 64 GB nodes.

Will post the balancenuma config along with results.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
