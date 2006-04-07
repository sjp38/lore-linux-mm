Message-ID: <44365DC2.1010806@yahoo.com.au>
Date: Fri, 07 Apr 2006 22:40:34 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: limit lowmem_reserve
References: <200604021401.13331.kernel@kolivas.org> <200604061110.35789.kernel@kolivas.org> <443605E1.7060203@yahoo.com.au> <200604071902.16011.kernel@kolivas.org>
In-Reply-To: <200604071902.16011.kernel@kolivas.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: Andrew Morton <akpm@osdl.org>, ck@vds.kolivas.org, linux list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Con Kolivas wrote:
> On Friday 07 April 2006 16:25, Nick Piggin wrote:
> 
>>Con Kolivas wrote:
>>
>>>It is possible with a low enough lowmem_reserve ratio to make
>>>zone_watermark_ok always fail if the lower_zone is small enough.
>>
>>I don't see how this would happen?
> 
> 
> 3GB lowmem and a reserve ratio of 180 is enough to do it.
> 

How would zone_watermark_ok always fail though?

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
