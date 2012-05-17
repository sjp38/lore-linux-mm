Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 9D30B6B0083
	for <linux-mm@kvack.org>; Thu, 17 May 2012 05:53:14 -0400 (EDT)
Date: Thu, 17 May 2012 10:51:24 +0100
From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: [RFC][PATCH 4/6] arm, mm: Convert arm to generic tlb
Message-ID: <20120517095124.GN23420@flint.arm.linux.org.uk>
References: <20110302175928.022902359@chello.nl> <20110302180259.109909335@chello.nl> <20120517030551.GA11623@linux-sh.org> <20120517093022.GA14666@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120517093022.GA14666@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Paul Mundt <lethal@linux-sh.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Thu, May 17, 2012 at 10:30:23AM +0100, Catalin Marinas wrote:
> Another minor thing is that on newer ARM processors (Cortex-A15) we
> need the TLB shootdown even on UP systems, so tlb_fast_mode should
> always return 0. Something like below (untested):

No Catalin, we need this for virtually all ARMv7 CPUs whether they're UP
or SMP, not just for A15, because of the speculative prefetch which can
re-load TLB entries from the page tables at _any_ time.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
