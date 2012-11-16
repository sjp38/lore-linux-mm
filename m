Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 2C4E46B0078
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 10:56:33 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id jg9so1452093bkc.14
        for <linux-mm@kvack.org>; Fri, 16 Nov 2012 07:56:31 -0800 (PST)
Date: Fri, 16 Nov 2012 16:56:26 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: Benchmark results: "Enhanced NUMA scheduling with adaptive
 affinity"
Message-ID: <20121116155626.GA4271@gmail.com>
References: <20121112160451.189715188@chello.nl>
 <20121112184833.GA17503@gmail.com>
 <20121115100805.GS8218@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121115100805.GS8218@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>


* Mel Gorman <mgorman@suse.de> wrote:

> It is important to know how this was configured. I was running 
> one JVM per node and the JVMs were sized that they should fit 
> in the node. [...]

That is not what I tested: as I described it in the mail I 
tested 32 warehouses: i.e. spanning the whole system.

You tested 4 parallel JVMs running one per node, right?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
