Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 0EF326B0070
	for <linux-mm@kvack.org>; Sun, 25 Nov 2012 18:40:09 -0500 (EST)
Date: Sun, 25 Nov 2012 23:40:05 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Comparison between three trees (was: Latest numa/core release,
 v17)
Message-ID: <20121125234005.GE8218@suse.de>
References: <1353624594-1118-1-git-send-email-mingo@kernel.org>
 <20121123173205.GZ8218@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121123173205.GZ8218@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Fri, Nov 23, 2012 at 05:32:05PM +0000, Mel Gorman wrote:

> <SNIP>
> SPECJBB: Single JVMs (one per node, 4 nodes), THP is enabled
> 
> <SNIP>
> SPECJBB: Single JVMs (one per node, 4 nodes), THP is disabled

Just to clarify, the "JVMs (one per node, 4 nodes)" was a cut&paste
error. Single JVM meant that there was just one JVM running and it was
configured to use 80% of available RAM.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
