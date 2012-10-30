Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 3C7556B0068
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 11:28:24 -0400 (EDT)
Date: Tue, 30 Oct 2012 08:28:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00/31] numa/core patches
Message-Id: <20121030082810.b9576441.akpm@linux-foundation.org>
In-Reply-To: <20121030122032.GC3888@suse.de>
References: <20121025121617.617683848@chello.nl>
	<20121030122032.GC3888@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>


On Tue, 30 Oct 2012 12:20:32 +0000 Mel Gorman <mgorman@suse.de> wrote:

> ...

Useful testing - thanks.  Did I miss the description of what
autonumabench actually does?  How representitive is it of real-world
things?

> I also expect autonuma is continually scanning where as schednuma is
> reacting to some other external event or at least less frequently scanning.

Might this imply that autonuma is consuming more CPU in kernel threads,
the cost of which didn't get included in these results?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
