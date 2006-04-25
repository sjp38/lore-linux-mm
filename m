Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.6/8.13.6) with ESMTP id k3PEFHr4068254
	for <linux-mm@kvack.org>; Tue, 25 Apr 2006 14:15:17 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3PEGMKp122834
	for <linux-mm@kvack.org>; Tue, 25 Apr 2006 16:16:22 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id k3PEFGJH025738
	for <linux-mm@kvack.org>; Tue, 25 Apr 2006 16:15:17 +0200
Subject: Re: Page host virtual assist patches.
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <444E1253.9090302@yahoo.com.au>
References: <20060424123412.GA15817@skybase>
	 <20060424180138.52e54e5c.akpm@osdl.org>  <444DCD87.2030307@yahoo.com.au>
	 <1145953914.5282.21.camel@localhost>  <444DF447.4020306@yahoo.com.au>
	 <1145964531.5282.59.camel@localhost>  <444E1253.9090302@yahoo.com.au>
Content-Type: text/plain
Date: Tue, 25 Apr 2006 16:15:21 +0200
Message-Id: <1145974521.5282.89.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

On Tue, 2006-04-25 at 22:13 +1000, Nick Piggin wrote:
> >>If the guest isn't under memory pressure (it has been allocated a fixed
> >>amount of memory, and hasn't exceeded it), then you just don't call in.
> >>Nor should you be employing this virtual assist reclaim on them.
> > 
> > 
> > The guests have a fixed host-virtual memory size. They do not have a
> > fixed host-physical memory size.
> 
> That's just arguing semantics now. You are advocating to involve guests
> in cooperating with memory management with the host. Ergo, if there is
> memory pressure in the host then it is not a "layering violation" to ask
> guests to reclaim memory as if they were under memory pressure too.
> 
> No more a violation than having the host reclaim the guest's memory from
> under it.

I wouldn't call it a violation. But yes both ways of doing achieve the
same result. One of the guest pages is reclaimed. The million dollar
question is which way is faster.

> > Yes, we do heavy swapping in the hypervisor. For a purpose OS it is not
> > a good idea but then done set CONFIG_PAGE_HVA and all the hva code turns
> > into nops.
> 
> But anybody who modifies or tries to understand the code and races etc
> involved has to know about all this stuff. That is my problem with it.

Oh, yes, I perfectly understand this. The code is rather complex.

> I'm not worried about the overhead at all, because I presume you have
> made it zero for the !CONFIG_PAGE_HVA case.

Yes, we made sure of that.

> > Which simple approach do you mean? The guest ballooner? That works
> > reasonably well for a small number of guests. If you keep adding guests
> > the overhead for the guest calls increases. Ultimately we believe that a
> > combination of the ballooner method and the new hva method will yield
> > the best results.
> 
> Yes, that simple approach (presumably the guest ballooner allocates
> memory from the guest and frees it to the host or something similar).
> I'd be interested to see numbers from real workloads...
> 
> I don't think the hva method is reasonable as it is. Let's see if we
> can improve host->guest driven reclaiming first.

So you believe that the host->guest driven relaiming can be improved to
a point where hva is superfluous. I do not believe that. Lets agree to
disagree here. Any findings in the hva code itself?

Anyway, thanks for you insights.

-- 
blue skies,
  Martin.

Martin Schwidefsky
Linux for zSeries Development & Services
IBM Deutschland Entwicklung GmbH

"Reality continues to ruin my life." - Calvin.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
