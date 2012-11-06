Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 795546B0044
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 13:33:10 -0500 (EST)
Message-ID: <5099586B.6050300@redhat.com>
Date: Tue, 06 Nov 2012 13:35:23 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 04/19] mm: numa: define _PAGE_NUMA
References: <1352193295-26815-1-git-send-email-mgorman@suse.de> <1352193295-26815-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1352193295-26815-5-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 11/06/2012 04:14 AM, Mel Gorman wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
>
> The objective of _PAGE_NUMA is to be able to trigger NUMA hinting page
> faults to identify the per NUMA node working set of the thread at
> runtime.
>
> Arming the NUMA hinting page fault mechanism works similarly to
> setting up a mprotect(PROT_NONE) virtual range: the present bit is
> cleared at the same time that _PAGE_NUMA is set, so when the fault
> triggers we can identify it as a NUMA hinting page fault.
>
> _PAGE_NUMA on x86 shares the same bit number of _PAGE_PROTNONE (but it
> could also use a different bitflag, it's up to the architecture to
> decide).
>
> It would be confusing to call the "NUMA hinting page faults" as
> "do_prot_none faults". They're different events and _PAGE_NUMA doesn't
> alter the semantics of mprotect(PROT_NONE) in any way.
>
> Sharing the same bitflag with _PAGE_PROTNONE in fact complicates
> things: it requires us to ensure the code paths executed by
> _PAGE_PROTNONE remains mutually exclusive to the code paths executed
> by _PAGE_NUMA at all times, to avoid _PAGE_NUMA and _PAGE_PROTNONE to
> step into each other toes.
>
> Because we want to be able to set this bitflag in any established pte
> or pmd (while clearing the present bit at the same time) without
> losing information, this bitflag must never be set when the pte and
> pmd are present, so the bitflag picked for _PAGE_NUMA usage, must not
> be used by the swap entry format.
>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
