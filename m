Message-ID: <43EC281B.2030000@yahoo.com.au>
Date: Fri, 10 Feb 2006 16:43:55 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Implement Swap Prefetching v23
References: <200602101355.41421.kernel@kolivas.org> <200602101626.12824.kernel@kolivas.org> <43EC2572.7010100@yahoo.com.au> <200602101637.57821.kernel@kolivas.org>
In-Reply-To: <200602101637.57821.kernel@kolivas.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, ck@vds.kolivas.org, pj@sgi.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Con Kolivas wrote:
> On Friday 10 February 2006 16:32, Nick Piggin wrote:
> 
>>Con Kolivas wrote:
>>
>>>Just so it's clear I understand, is this what you (both) had in mind?
>>>Inline so it's not built for !CONFIG_SWAP_PREFETCH
>>
>>Close...
> 
> 
>>>+inline void lru_cache_add_tail(struct page *page)
>>
>>Is this inline going to do what you intend?
> 
> 
> I don't care if it's actually inlined, but the subtleties of compilers is way 
> beyond me. All it positively achieves is silencing the unused function 
> warning so I had hoped it meant that function was not built. I tend to be 
> wrong though...
> 

I don't think it can because it is not used in the same file.
You'd have to put it into the header file.

Not sure why it silences the unused function warning. You didn't
replace a 'static' with the inline? I don't think there is any
other way the compiler can know the function isn't used externally.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
