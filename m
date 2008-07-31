Date: Wed, 30 Jul 2008 23:14:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] [PATCH 0/5 V2] Huge page backed user-space stacks
Message-Id: <20080730231428.a7bdcfa7.akpm@linux-foundation.org>
In-Reply-To: <200807311604.14349.nickpiggin@yahoo.com.au>
References: <cover.1216928613.git.ebmunson@us.ibm.com>
	<20080730172317.GA14138@csn.ul.ie>
	<20080730103407.b110afc2.akpm@linux-foundation.org>
	<200807311604.14349.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Mel Gorman <mel@csn.ul.ie>, Eric Munson <ebmunson@us.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, libhugetlbfs-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Thu, 31 Jul 2008 16:04:14 +1000 Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> > Do we expect that this change will be replicated in other
> > memory-intensive apps?  (I do).
> 
> Such as what? It would be nice to see some numbers with some HPC or java
> or DBMS workload using this. Not that I dispute it will help some cases,
> but 10% (or 20% for ppc) I guess is getting toward the best case, short
> of a specifically written TLB thrasher.

I didn't realise the STREAM is using vast amounts of automatic memory. 
I'd assumed that it was using sane amounts of stack, but the stack TLB
slots were getting zapped by all the heap-memory activity.  Oh well.

I guess that effect is still there, but smaller.

I agree that few real-world apps are likely to see gains of this
order.  More benchmarks, please :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
