Subject: Re: [PATCH] low-latency zap_page_range()
From: Robert Love <rml@tech9.net>
In-Reply-To: <3D6E844C.4E756D10@zip.com.au>
References: <1030635100.939.2551.camel@phantasy>
	<3D6E844C.4E756D10@zip.com.au>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 29 Aug 2002 16:40:02 -0400
Message-Id: <1030653602.939.2677.camel@phantasy>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2002-08-29 at 16:30, Andrew Morton wrote:

> However with your change, we'll only ever put 256 pages into the
> mmu_gather_t.  Half of that thing's buffer is unused and the
> invalidation rate will be doubled during teardown of large
> address ranges.

Agreed.  Go for it.

Hm, unless, since 507 vs 256 is not the end of the world and latency is
already low, we want to just make it always (FREE_PTE_NR*PAGE_SIZE)...

As long as the "cond_resched_lock()" is a preempt only thing, I also
agree with making ZAP_BLOCK_SIZE ~0 on !CONFIG_PREEMPT - unless we
wanted to unconditionally drop the locks and let preempt just do the
right thing and also reduce SMP lock contention in the SMP case.

	Robert Love

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
