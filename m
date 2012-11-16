Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 459546B005D
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 11:22:30 -0500 (EST)
Message-ID: <50A66834.7010809@redhat.com>
Date: Fri, 16 Nov 2012 11:22:12 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 16/43] mm: mempolicy: Hide MPOL_NOOP and MPOL_MF_LAZY
 from userspace for now
References: <1353064973-26082-1-git-send-email-mgorman@suse.de> <1353064973-26082-17-git-send-email-mgorman@suse.de>
In-Reply-To: <1353064973-26082-17-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 11/16/2012 06:22 AM, Mel Gorman wrote:
> The use of MPOL_NOOP and MPOL_MF_LAZY to allow an application to
> explicitly request lazy migration is a good idea but the actual
> API has not been well reviewed and once released we have to support it.
> For now this patch prevents an application using the services. This
> will need to be revisited.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
