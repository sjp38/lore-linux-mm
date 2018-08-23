Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9A6DE6B2A59
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 09:40:46 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id w185-v6so4819996oig.19
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 06:40:46 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h198-v6si3409879oic.192.2018.08.23.06.40.45
        for <linux-mm@kvack.org>;
        Thu, 23 Aug 2018 06:40:45 -0700 (PDT)
Date: Thu, 23 Aug 2018 14:40:41 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 2/4] mm/tlb: Remove tlb_remove_table() non-concurrent
 condition
Message-ID: <20180823134041.GB1496@brain-police>
References: <20180822153012.173508681@infradead.org>
 <20180822154046.772017055@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180822154046.772017055@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: torvalds@linux-foundation.org, luto@kernel.org, x86@kernel.org, bp@alien8.de, riel@surriel.com, jannh@google.com, ascannell@google.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nicholas Piggin <npiggin@gmail.com>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Wed, Aug 22, 2018 at 05:30:14PM +0200, Peter Zijlstra wrote:
> Will noted that only checking mm_users is incorrect; we should also
> check mm_count in order to cover CPUs that have a lazy reference to
> this mm (and could do speculative TLB operations).
> 
> If removing this turns out to be a performance issue, we can
> re-instate a more complete check, but in tlb_table_flush() eliding the
> call_rcu_sched().
> 
> Cc: stable@kernel.org
> Cc: Nicholas Piggin <npiggin@gmail.com>
> Cc: David Miller <davem@davemloft.net>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Fixes: 267239116987 ("mm, powerpc: move the RCU page-table freeing into generic code")
> Reported-by: Will Deacon <will.deacon@arm.com>
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> ---
>  mm/memory.c |    9 ---------
>  1 file changed, 9 deletions(-)

Acked-by: Will Deacon <will.deacon@arm.com>

Cheers,

Will
