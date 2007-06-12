Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5CMWDXA023798
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 18:32:13 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5CMWDoS212884
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 16:32:13 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5CMWC7q026936
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 16:32:13 -0600
Date: Tue, 12 Jun 2007 15:32:10 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 1/3] NUMA: introduce node_memory_map
Message-ID: <20070612223210.GK3798@us.ibm.com>
References: <20070612204843.491072749@sgi.com> <20070612205738.309078596@sgi.com> <alpine.DEB.0.99.0706121401060.5104@chino.kir.corp.google.com> <Pine.LNX.4.64.0706121407070.1850@schroedinger.engr.sgi.com> <alpine.DEB.0.99.0706121409170.5104@chino.kir.corp.google.com> <20070612213612.GH3798@us.ibm.com> <Pine.LNX.4.64.0706121437480.5196@schroedinger.engr.sgi.com> <20070612214249.GI3798@us.ibm.com> <Pine.LNX.4.64.0706121523470.6942@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706121523470.6942@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: David Rientjes <rientjes@google.com>, akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de, pj@sgi.com, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On 12.06.2007 [15:26:25 -0700], Christoph Lameter wrote:
> On Tue, 12 Jun 2007, Nishanth Aravamudan wrote:
> 
> > is not intuitive at all. And we've already admitted that a few of the
> > macros in there are inconsistent already :)
> 
> I do not want to add another inconsistency.
> 
> if (node_memory(node))
> 
> is pretty clear as far as I can tell.

Fair enough.

> Some of the macros in include/linux/nodemask.h are inconsistent. How
> can we make those consistent. Could you come up with a consistent
> naming scheme? Add the explanation for that scheme.

I'll think it over :)

> But that should be a separate patch. And the patch would have to
> change all uses of those macros in the kernel source tree.

Agreed, will be a down-the-road thing. In the meantime, I'm rebasing the
hugetlb pool patch and sysfs interface patch on top of your stack and
will repost.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
