Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 09CB16B0033
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 16:31:22 -0400 (EDT)
Date: Fri, 2 Aug 2013 21:59:59 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [patch v2 0/3] mm: improve page aging fairness between
 zones/nodes
Message-ID: <20130802195959.GF26919@redhat.com>
References: <1375457846-21521-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375457846-21521-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@surriel.com>, Zlatko Calusic <zcalusic@bitsync.net>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Aug 02, 2013 at 11:37:23AM -0400, Johannes Weiner wrote:
> Changes in version 2:

v2 looks great to me.

                zone->alloc_batch -= 1U << order;
    3147:       d3 e0                   shl    %cl,%eax
    3149:       29 42 54                sub    %eax,0x54(%rdx)

gcc builds it as one asm insn too.

Considering we depend on gcc to be optimal and to update ptes in a
single insn (and if it doesn't we'll corrupt memory), keeping it in C
should always provide the update in a single insn.

I believe the error introduced when mulptiple CPUs of the same NUMA
node step on each other is going to be unmeasurable.

ACK the whole series.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
