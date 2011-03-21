Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 034348D0039
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 04:48:40 -0400 (EDT)
Message-ID: <4D87109A.1010005@redhat.com>
Date: Mon, 21 Mar 2011 10:47:22 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/17] mm: mmu_gather rework
References: <20110217162327.434629380@chello.nl>	 <20110217163234.823185666@chello.nl>  <20110310155032.GB32302@csn.ul.ie> <1300301742.2203.1899.camel@twins>
In-Reply-To: <1300301742.2203.1899.camel@twins>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Tony Luck <tony.luck@intel.com>, Hugh Dickins <hughd@google.com>

On 03/16/2011 08:55 PM, Peter Zijlstra wrote:
> On Thu, 2011-03-10 at 15:50 +0000, Mel Gorman wrote:
>
> >  >  +static inline void
> >  >  +tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned int full_mm_flush)
> >  >   {
> >
> >  checkpatch will bitch about line length.
>
> I did a s/full_mm_flush/fullmm/ which puts the line length at 81. At
> which point I'll ignore it ;-)

How about s/unsigned int/bool/?  IIRC you aren't a "bool was invented 
after 1971, therefore it is evil" type.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
