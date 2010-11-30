Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B31966B004A
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 22:36:42 -0500 (EST)
Subject: Re: [PATCH 09/21] powerpc: Preemptible mmu_gather
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1291086726.32570.341.camel@pasglop>
References: <20101126143843.801484792@chello.nl>
	 <20101126145410.771278578@chello.nl>  <1291086726.32570.341.camel@pasglop>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 30 Nov 2010 14:35:48 +1100
Message-ID: <1291088148.32570.342.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>
List-ID: <linux-mm.kvack.org>


> This breaks embedded 64-bit build. Replace CONFIG_PPC64 with
> CONFIG_PPC_BOOK3S_64 to only hit server when you access the
> ppc64_tlb_batch in process.c since it doesn't exist for BOOK3E.
> 
> This patch to fold into yours fixes it for me:

With this fix and the other Kconfig fix, it seems to boot fine and no
obvious breakage doing simple things on G5 and a power6 machine.

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
