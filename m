Message-ID: <400CB730.4010201@cyberone.com.au>
Date: Tue, 20 Jan 2004 16:05:52 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: Memory management in 2.6
References: <400CB3BD.4020601@cyberone.com.au> <20040119205855.37524811.akpm@osdl.org>
In-Reply-To: <20040119205855.37524811.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Andrew Morton wrote:

>Nick Piggin <piggin@cyberone.com.au> wrote:
>
>>loads should be runnable on about 64MB, preferably give decently
>> repeatable results in under an hour.
>>
>
>In under three minutes, IMO.
>

That would be nice, but sometimes hard, with multiple processes
and fairly heavy swapping load.

As you can see, kbuild time for example increases very quickly. It
would be preferable to "do something for 2 minutes and measure how
far we got", but kbuild doesn't lend itself particularly well to
that.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
