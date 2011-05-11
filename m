Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5F5386B0012
	for <linux-mm@kvack.org>; Wed, 11 May 2011 16:38:48 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id p4BKcigf002663
	for <linux-mm@kvack.org>; Wed, 11 May 2011 13:38:44 -0700
Received: from pwj8 (pwj8.prod.google.com [10.241.219.72])
	by kpbe11.cbf.corp.google.com with ESMTP id p4BKcA4D009874
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 11 May 2011 13:38:43 -0700
Received: by pwj8 with SMTP id 8so543399pwj.13
        for <linux-mm@kvack.org>; Wed, 11 May 2011 13:38:42 -0700 (PDT)
Date: Wed, 11 May 2011 13:38:40 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3] mm: slub: Do not wake kswapd for SLUBs speculative
 high-order allocations
In-Reply-To: <1305127773-10570-2-git-send-email-mgorman@suse.de>
Message-ID: <alpine.DEB.2.00.1105111304590.9346@chino.kir.corp.google.com>
References: <1305127773-10570-1-git-send-email-mgorman@suse.de> <1305127773-10570-2-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Wed, 11 May 2011, Mel Gorman wrote:

> To avoid locking and per-cpu overhead, SLUB optimisically uses
> high-order allocations and falls back to lower allocations if they
> fail.  However, by simply trying to allocate, kswapd is woken up to
> start reclaiming at that order. On a desktop system, two users report
> that the system is getting locked up with kswapd using large amounts
> of CPU.  Using SLAB instead of SLUB made this problem go away.
> 
> This patch prevents kswapd being woken up for high-order allocations.
> Testing indicated that with this patch applied, the system was much
> harder to hang and even when it did, it eventually recovered.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
