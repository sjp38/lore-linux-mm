Message-ID: <41131732.7060606@yahoo.com.au>
Date: Fri, 06 Aug 2004 15:29:22 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] 1/4: rework alloc_pages
References: <41130FB1.5020001@yahoo.com.au> <20040805221958.49049229.akpm@osdl.org>
In-Reply-To: <20040805221958.49049229.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
>>Previously the ->protection[] logic was broken. It was difficult to follow
>> and basically didn't use the asynch reclaim watermarks properly.
> 
> 
> eh?
> 
> Broken how?
> 

min = (1<<order) + z->protection[alloc_type];

This value is used both as the condition for waking kswapd, and
whether or not to enter synch reclaim.

What should happen is kswapd gets woken at pages_low, and synch
reclaim is started at pages_min.

> What is an "asynch reclaim watermark"?
> 

pages_low and pages_high.

> 
>> This one uses ->protection only for lower-zone protection, and gives the
>> allocator flexibility to add the watermarks as desired.
> 
> 
> eh?
> 

pages_low + protection and pages_min + protection, etc.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
