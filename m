Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id B43E76B0062
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 04:07:35 -0500 (EST)
Date: Mon, 10 Dec 2012 09:07:30 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/45] Automatic NUMA Balancing V7
Message-ID: <20121210090730.GF1009@suse.de>
References: <1353612353-1576-1-git-send-email-mgorman@suse.de>
 <20121126145800.GK8218@suse.de>
 <20121128134930.GB20087@suse.de>
 <20121207104539.GB22164@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121207104539.GB22164@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Dec 07, 2012 at 04:15:39PM +0530, Srikar Dronamraju wrote:
> 
> Got a chance to run autonuma-benchmark on a 8 node, 64 core machine. 
> the results are as below. (for each kernel I ran 5 iterations of
> autonuma-benchmark)
> 

Thanks, a test of v10 would also be appreciated. The differences between
V7 and V10 are small but do include a change in how migrate rate-limiting
is handled. It is unlikely it'll make a difference to this test but I'd
like to rule it out.

> KernelVersion: 3.7.0-rc3-mainline_v37rc7()

What kernel is this? The name begins with 3.7-rc3 but then says
v37rc7. v37rc7 of what? I thought it might be v3.7-rc7 but it already said
it's 3.7-rc3 so I'm confused. Would it be possible to base the tests on
a similar baseline kernel such as 3.7.0-rc7 or 3.7.0-rc8? The
balancenuma patches should apply and the autonuma patches can be taken
from the mm-autonuma-v28fastr4-mels-rebase branch in
git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux-balancenuma.git

Either way, the figures look bad. I'm trying to find a similar machine
but initially at least I have not had much luck. Can you post the .config
you used for balancenuma in case I can reproduce the problem on a 4-node
machine please? Are all the nodes the same size?

Thanks!

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
