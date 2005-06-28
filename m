Message-ID: <42C0E173.30406@yahoo.com.au>
Date: Tue, 28 Jun 2005 15:34:43 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 2] mm: speculative get_page
References: <42C0AAF8.5090700@yahoo.com.au>	<20050628040608.GQ3334@holomorphy.com>	<42C0D717.2080100@yahoo.com.au> <20050627.220827.21920197.davem@davemloft.net>
In-Reply-To: <20050627.220827.21920197.davem@davemloft.net>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@davemloft.net>
Cc: wli@holomorphy.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David S. Miller wrote:

>From: Nick Piggin <nickpiggin@yahoo.com.au>
>Subject: Re: [patch 2] mm: speculative get_page
>Date: Tue, 28 Jun 2005 14:50:31 +1000
>
>
>>William Lee Irwin III wrote:
>>
>>
>>>On Tue, Jun 28, 2005 at 11:42:16AM +1000, Nick Piggin wrote:
>>>
>>>spin_unlock() does not imply a memory barrier.
>>>
>>>
>>Intriguing...
>>
>
>BTW, I disagree with this assertion.  spin_unlock() does imply a
>memory barrier.
>
>All memory operations before the release of the lock must execute
>before the lock release memory operation is globally visible.
>

Yes, it appears that way from looking at a sample set of arch
code too (ie. those without strictly ordered stores put an
explicit barrier there).

I've always understood spin_unlock to imply a barrier.


Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
