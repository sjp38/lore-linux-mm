Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 53F926B005D
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 12:49:26 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so472236eaa.14
        for <linux-mm@kvack.org>; Fri, 16 Nov 2012 09:49:24 -0800 (PST)
Date: Fri, 16 Nov 2012 18:49:18 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: Benchmark results: "Enhanced NUMA scheduling with adaptive
 affinity"
Message-ID: <20121116174918.GA4723@gmail.com>
References: <20121112160451.189715188@chello.nl>
 <20121112184833.GA17503@gmail.com>
 <20121115100805.GS8218@suse.de>
 <20121116155626.GA4271@gmail.com>
 <20121116162556.GD8218@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121116162556.GD8218@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>


* Mel Gorman <mgorman@suse.de> wrote:

> On Fri, Nov 16, 2012 at 04:56:26PM +0100, Ingo Molnar wrote:
> > 
> > * Mel Gorman <mgorman@suse.de> wrote:
> > 
> > > It is important to know how this was configured. I was running 
> > > one JVM per node and the JVMs were sized that they should fit 
> > > in the node. [...]
> > 
> > That is not what I tested: as I described it in the mail I 
> > tested 32 warehouses: i.e. spanning the whole system.
> > 
> 
> Good (sortof) [...]

Not just 'sortof' good but it appears it's unconditionally good: 
meanwhile other testers have reproduced the single-JVM speedup 
with the latest numa/core code as well, so the speedup is not 
just on my system.

Please post your kernel .config so I can check why the 4x JVM 
test does not perform so well on your system. Maybe there's 
something special to your system.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
