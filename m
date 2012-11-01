Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id E0B666B0071
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 06:58:43 -0400 (EDT)
Date: Thu, 1 Nov 2012 10:58:38 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 11/31] mm/mpol: Make MPOL_LOCAL a real policy
Message-ID: <20121101105838.GR3888@suse.de>
References: <20121025121617.617683848@chello.nl>
 <20121025124833.322016965@chello.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121025124833.322016965@chello.nl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Ingo Molnar <mingo@kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>

On Thu, Oct 25, 2012 at 02:16:28PM +0200, Peter Zijlstra wrote:
> Make MPOL_LOCAL a real and exposed policy such that applications that
> relied on the previous default behaviour can explicitly request it.
> 
> Requested-by: Christoph Lameter <cl@linux.com>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Signed-off-by: Ingo Molnar <mingo@kernel.org>

Seems reasonable but Michael Kerrisk should be cc'd because when the dust
settles on this there may be a manual page update required.

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
