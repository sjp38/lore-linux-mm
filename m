Message-ID: <4535160E.2010908@yahoo.com.au>
Date: Wed, 18 Oct 2006 03:42:38 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] Remove temp_priority
References: <45351423.70804@google.com>
In-Reply-To: <45351423.70804@google.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Bligh <mbligh@google.com>
Cc: Andrew Morton <akpm@osdl.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Martin Bligh wrote:
> This is not tested yet. What do you think?
> 
> This patch removes temp_priority, as it is racy. We're setting
> prev_priority from it, and yet temp_priority could have been
> set back to DEF_PRIORITY by another reclaimer.

I like it. I wonder if we should get kswapd to stick its priority
into the zone at the point where zone_watermark_ok becomes true,
rather than setting all zones to the lowest priority? That would
require a bit more logic though I guess.

For that matter (going off the topic a bit), I wonder if
try_to_free_pages should have a watermark check there too? This
might help reduce the latency issue you brought up where one process
has reclaimed a lot of pages, but another isn't making any progress
and has to go through the full priority range? Maybe that's
statistically pretty unlikely?

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
