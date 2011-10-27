Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 321B06B002D
	for <linux-mm@kvack.org>; Thu, 27 Oct 2011 04:50:37 -0400 (EDT)
Date: Thu, 27 Oct 2011 10:50:25 +0200
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] cache align vm_stat
Message-ID: <20111027085008.GA6563@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dimitri Sivanich <sivanich@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@gentwo.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>

On Mon, Oct 24, 2011 at 11:10:35AM -0500, Dimitri Sivanich wrote:
> Avoid false sharing of the vm_stat array.
> 
> This was found to adversely affect tmpfs I/O performance.
> 

I think this fix is overly simplistic. It is moving each counter into
its own cache line. While I accept that this will help the preformance
of the tmpfs-based workload, it will adversely affect workloads that
touch a lot of counters because of the increased cache footprint.

1. Is it possible to rearrange the vmstat array such that two hot
   counters do not share a cache line?
2. Has Andrew's suggestion to alter the per-cpu threshold based on the
   value of the global counter to reduce conflicts been tried?

(I'm at Linux Con at the moment so will be even slower to respond than
usual)

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
