Message-ID: <4020C356.6070404@cyberone.com.au>
Date: Wed, 04 Feb 2004 21:03:02 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 5/5] mm improvements
References: <4020BDCB.8030707@cyberone.com.au> <4020BE94.1040001@cyberone.com.au>
In-Reply-To: <4020BE94.1040001@cyberone.com.au>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Nick Piggin wrote:

> Nick Piggin wrote:
>
>> 5/5: vm-tune-throttle.patch
>>     Try to allocate a bit harder before giving up / throttling on
>>     writeout.
>>
>

That would be "try to free a bit harder"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
