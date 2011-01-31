Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id CDB698D0039
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 05:02:35 -0500 (EST)
Received: from d06nrmr1507.portsmouth.uk.ibm.com (d06nrmr1507.portsmouth.uk.ibm.com [9.149.38.233])
	by mtagate6.uk.ibm.com (8.13.1/8.13.1) with ESMTP id p0VA2X7b005474
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 10:02:33 GMT
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by d06nrmr1507.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0VA2ZVp1269968
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 10:02:36 GMT
Received: from d06av06.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0VA2VFr000933
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 03:02:32 -0700
Date: Mon, 31 Jan 2011 11:02:37 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH 00/21] mm: Preemptibility -v6
Message-ID: <20110131110237.41d48000@mschwide.boeblingen.de.ibm.com>
In-Reply-To: <1295457039.28776.137.camel@laptop>
References: <20101126143843.801484792@chello.nl>
	<alpine.LSU.2.00.1101172301340.2899@sister.anvils>
	<1295457039.28776.137.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@kernel.dk>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 19 Jan 2011 18:10:39 +0100
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> On Mon, 2011-01-17 at 23:12 -0800, Hugh Dickins wrote:
> 
> > 11/21 s390-preemptible_mmu_gather.patch
> >       I'd prefer __tlb_alloc_page(), with __GFP_NOWARN as suggested above.
> >       mm/pgtable.c still has DEFINE_PER_CPU(struct mmu_gather, mmu_gathers).
> 
> Martin, while doing the below DEFINE_PER_CPU removal I saw you had a
> bunch of RCU table removal thingies in arch/s390/mm/pgtable.c, could
> s390 use the generic bits like sparc and powerpc (see patch 16)?

Maybe, I will have a look at it.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
