Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E41E8900001
	for <linux-mm@kvack.org>; Thu, 12 May 2011 13:36:40 -0400 (EDT)
Date: Thu, 12 May 2011 19:36:28 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 3/3] mm: slub: Default slub_max_order to 0
Message-ID: <20110512173628.GJ11579@random.random>
References: <1305127773-10570-1-git-send-email-mgorman@suse.de>
 <1305127773-10570-4-git-send-email-mgorman@suse.de>
 <alpine.DEB.2.00.1105111314310.9346@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1105111314310.9346@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Wed, May 11, 2011 at 01:38:47PM -0700, David Rientjes wrote:
> kswapd and doing compaction for the higher order allocs before falling 

Note that patch 2 disabled compaction by clearing __GFP_WAIT.

What you describe here would be patch 2 without the ~__GFP_WAIT
addition (so keeping only ~GFP_NOFAIL).

Not clearing __GFP_WAIT when compaction is enabled is possible and
shouldn't result in bad behavior (if compaction is not enabled with
current SLUB it's hard to imagine how it could perform decently if
there's fragmentation). You should try to benchmark to see if it's
worth it on the large NUMA systems with heavy network traffic (for
normal systems I doubt compaction is worth it but I'm not against
trying to keep it enabled just in case).

On a side note, this reminds me to rebuild with slub_max_order in .bss
on my cellphone (where I can't switch to SLAB because of some silly
rfs vfat-on-steroids proprietary module).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
