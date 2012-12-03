Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id CC5186B002B
	for <linux-mm@kvack.org>; Mon,  3 Dec 2012 10:53:35 -0500 (EST)
Message-ID: <50BCCAA3.6060604@redhat.com>
Date: Mon, 03 Dec 2012 10:52:03 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/52] RFC: Unified NUMA balancing tree, v1
References: <1354473824-19229-1-git-send-email-mingo@kernel.org>
In-Reply-To: <1354473824-19229-1-git-send-email-mingo@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On 12/02/2012 01:42 PM, Ingo Molnar wrote:

> Most of the outstanding objections against numa/core centered around
> Mel and Rik objecting to the PROT_NONE approach Peter implemented in
> numa/core. To settle that question objectively I've performed performance
> testing of those differences, by picking up the minimum number of
> essentials needed to be able to remove the PROT_NONE approach and use
> the PTE_NUMA approach Mel took from the AutoNUMA tree and elsewhere.

For the record, I have no objection to either of
the pte marking approaches.

> Rik van Riel (1):
>    sched, numa, mm: Add credits for NUMA placement

Where did the TLB flush optimizations go? :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
