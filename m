Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 21E5F6B00BE
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 14:42:02 -0500 (EST)
Date: Mon, 16 Feb 2009 19:41:57 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch] SLQB slab allocator (try 2)
Message-ID: <20090216194157.GB31264@csn.ul.ie>
References: <20090123154653.GA14517@wotan.suse.de> <200902041748.41801.nickpiggin@yahoo.com.au> <20090204152709.GA4799@csn.ul.ie> <200902051459.30064.nickpiggin@yahoo.com.au> <20090216184200.GA31264@csn.ul.ie> <4999BBE6.2080003@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4999BBE6.2080003@cs.helsinki.fi>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Feb 16, 2009 at 09:17:58PM +0200, Pekka Enberg wrote:
> Hi Mel,
>
> Mel Gorman wrote:
>> I haven't done much digging in here yet. Between the large page bug and
>> other patches in my inbox, I haven't had the chance yet but that doesn't
>> stop anyone else taking a look.
>
> So how big does an improvement/regression have to be not to be  
> considered within noise? I mean, I randomly picked one of the results  
> ("x86-64 speccpu integer tests") and ran it through my "summarize"  
> script and got the following results:
>
> 		min      max      mean     std_dev
>   slub		0.96     1.09     1.01     0.04
>   slub-min	0.95     1.10     1.00     0.04
>   slub-rvrt	0.90     1.08     0.99     0.05
>   slqb		0.96     1.07     1.00     0.04
>

Well, it doesn't make a whole pile of sense to get the average of these ratios
or the deviation between them. Each of the tests behave very differently. I'd
consider anything over 0.5% significant but I also have to admit I wasn't
doing multiple runs this time due to the length of time it takes. In a
previous test, I ran them 3 times each and didn't spot large deviations.

> Apart from slub-rvrt (which seems to be regressing, interesting) all the  
> allocators seem to perform equally well. Hmm?
>

For this stuff, they are reasonably close but I don't believe thye are
allocator intensive either. SPEC CPU was brought up as a workload HPC people
would care about. Bear in mind it's also not testing NUMA or CPU scalability
really well. It's one data-point. netperf is a much more allocator intensive
workload.

> Btw, Yanmin, do you have access to the tests Mel is running (especially  
> the ones where slub-rvrt seems to do worse)? Can you see this kind of  
> regression? The results make we wonder whether we should avoid reverting  
> all of the page allocator pass-through and just add a kmalloc cache for  
> 8K allocations. Or not address the netperf regression at all. Double-hmm.
>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
