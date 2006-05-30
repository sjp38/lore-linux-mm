Message-ID: <447BD63D.2080900@yahoo.com.au>
Date: Tue, 30 May 2006 15:21:01 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [rfc][patch] remove racy sync_page?
References: <447AC011.8050708@yahoo.com.au> <20060529121556.349863b8.akpm@osdl.org> <447B8CE6.5000208@yahoo.com.au> <20060529183201.0e8173bc.akpm@osdl.org> <447BB3FD.1070707@yahoo.com.au> <Pine.LNX.4.64.0605292117310.5623@g5.osdl.org> <447BD31E.7000503@yahoo.com.au>
In-Reply-To: <447BD31E.7000503@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mason@suse.com, andrea@suse.de, hugh@veritas.com, axboe@suse.de
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Linus Torvalds wrote:
> 
>>
>> Why do you think the IO layer should get larger requests?
> 
> 
> For workloads where plugging helps (ie. lots of smaller, contiguous
> requests going into the IO layer), should be pretty good these days
> due to multiple readahead and writeback.

Let me try again.

For workloads where plugging helps (ie. lots of smaller, contiguous
requests going into the IO layer), the request pattern should be
pretty good without plugging these days, due to multiple page
readahead and writeback.


> 
>>
>> I really don't understand why people dislike plugging. It's obviously 
>> superior to non-plugged variants, exactly because it starts the IO 
>> only when _needed_,

Taken to its logical conclusion, you are saying readahead / dirty
page writeout throttling is obviously inferior, aren't you?

Non-rhetorically: Obviously there can be regressions in plugging,
because you are holding the disk idle when you know there is work to
be done.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
