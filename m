Message-ID: <46D1234D.4090300@yahoo.com.au>
Date: Sun, 26 Aug 2007 16:53:01 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] : mm : / Patch / code : Suggestion :snip  kswapd &  get_page_from_freelist()
  : No more no page failures.
References: <000601c7e6ae$db887680$6501a8c0@earthlink.net>
In-Reply-To: <000601c7e6ae$db887680$6501a8c0@earthlink.net>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mitchell Erblich <erblichs@earthlink.net>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, mingo@elte.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mitchell@kvack.org wrote:
> linux-mm@kvack.org
> Sent: Friday, August 24, 2007 3:11 PM
> Subject: Re: [RFC] : mm : / Patch / code : Suggestion :snip kswapd &
> get_page_from_freelist() : No more no page failures.
> 
> Mailer added a HTML subpart and chopped the earlier email.... :^(

Hi Mitchell,

Is it possible to send suggestions in the form of a unified diff, even
if you haven't even compiled it (just add a note to let people know).

Secondly, we already have a (supposedly working) system of asynch
reclaim, with buffering and hysteresis. I don't exactly understand
what problem you think it has that would be solved by rechecking
watermarks after allocating a page.

When we're in the (min,low) watermark range, we'll wake up kswapd
_before_ allocating anything, so what is better about the change to
wake up kswapd after allocating? Can you perhaps come up with an
example situation also to make this more clear?

Overhead of wakeup_kswapd isn't too much of a problem: if we _should_
be waking it up when we currently aren't, then we should be calling
it. However the extra checking in the allocator fastpath is something
we want to avoid if possible, because this can be a really hot path.

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
