Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 2AE8E6B005A
	for <linux-mm@kvack.org>; Mon,  3 Dec 2012 12:11:33 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so2116785eek.14
        for <linux-mm@kvack.org>; Mon, 03 Dec 2012 09:11:31 -0800 (PST)
Date: Mon, 3 Dec 2012 18:11:26 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/52] RFC: Unified NUMA balancing tree, v1
Message-ID: <20121203171126.GA18394@gmail.com>
References: <1354473824-19229-1-git-send-email-mingo@kernel.org>
 <50BCCAA3.6060604@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50BCCAA3.6060604@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>


* Rik van Riel <riel@redhat.com> wrote:

> >Rik van Riel (1):
> >   sched, numa, mm: Add credits for NUMA placement
> 
> Where did the TLB flush optimizations go? :)

They are still very much there, unchanged for a long time and 
acked by everyone - I thought I'd spare a few electrons by not 
doing a 60+ patches full resend.

Here is how it looks like in the full diffstat:

 Rik van Riel (6):
      mm/generic: Only flush the local TLB in ptep_set_access_flags()
      x86/mm: Only do a local tlb flush in ptep_set_access_flags()
      x86/mm: Introduce pte_accessible()
      mm: Only flush the TLB when clearing an accessible pte
      x86/mm: Completely drop the TLB flush from ptep_set_access_flags()
      sched, numa, mm: Add credits for NUMA placement

I'm really fond of these btw., they make a real difference.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
