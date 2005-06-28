Message-ID: <42C0D717.2080100@yahoo.com.au>
Date: Tue, 28 Jun 2005 14:50:31 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 2] mm: speculative get_page
References: <42BF9CD1.2030102@yahoo.com.au> <42BF9D67.10509@yahoo.com.au> <42BF9D86.90204@yahoo.com.au> <20050627141220.GM3334@holomorphy.com> <42C093B4.3010707@yahoo.com.au> <20050628012254.GO3334@holomorphy.com> <42C0AAF8.5090700@yahoo.com.au> <20050628040608.GQ3334@holomorphy.com>
In-Reply-To: <20050628040608.GQ3334@holomorphy.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:

>On Tue, Jun 28, 2005 at 11:42:16AM +1000, Nick Piggin wrote:
>
>>Well it switches between page and swap cache, but it seems to just
>>use the normal pagecache / swapcache functions for that. It could be
>>that I've got a big hole somewhere, but so far I don't think you've
>>pointed oen out.
>>
>
>Its radix tree movement bypasses the page allocator.
>
>

That should be fine. Net result is the page has been looked up.
What kind of atomicity did you imagine the locked find_get_page
provides that I haven't?

>
>On Tue, Jun 28, 2005 at 11:42:16AM +1000, Nick Piggin wrote:
>
>>Well what's the trouble with it?
>>
>
>hugetlb reallocation doesn't go through the page allocator either.
>
>

Ditto. Net result is that the page has been looked up. The
speculative get page will recheck that it is in the radix
tree after taking a reference, and if so then it assumes that
reference to be valid.

What is the hangup with the page allocator?

>On Tue, Jun 28, 2005 at 11:42:16AM +1000, Nick Piggin wrote:
>
>>I know what a memory barrier is and does, so you said the
>>necessary memory barriers aren't in place, so can you deal
>>with it?
>>
>
>spin_unlock() does not imply a memory barrier.
>
>

Intriguing...

>
>William Lee Irwin III wrote:
>
>>>The above is as much as I wanted to go into it. I need to direct my
>>>capacity for the grunt work of devising adversary arguments elsewhere.
>>>
>
>On Tue, Jun 28, 2005 at 11:42:16AM +1000, Nick Piggin wrote:
>
>>I don't think there is anything wrong with it. I would be very
>>keen to see real adversary arguments elsewhere though.
>>
>
>They take time to construct.
>
>

I can imagine. I don't think I've seen one yet.

>
>William Lee Irwin III wrote:
>
>>>You requested comments. I made some.
>>>
>
>On Tue, Jun 28, 2005 at 11:42:16AM +1000, Nick Piggin wrote:
>
>>Well yeah thanks, you did point out a thinko I made, and that was very
>>helpful and I value any time you spend looking at it. But just saying
>>"this is wrong, that won't work, that's crap, ergo the concept is
>>useless" without finding anything specifically wrong is not very
>>constructive.
>>
>
>I said nothing of that kind, and I did point out specific things.
>
>

You said "this RFC seems to have too far to go to use it to
conclude anything about the subject", after failing to find
any holes in the actual implementation.

And (parahprasing) "this needs memory barriers but I won't say
where or why, somebody else deal with it" doesn't count as a
specific thing.


Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
