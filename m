Message-ID: <40105D73.3070202@cyberone.com.au>
Date: Fri, 23 Jan 2004 10:32:03 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [BENCHMARKS] Namesys VM patches improve kbuild
References: <400F630F.80205@cyberone.com.au> <20040121223608.1ea30097.akpm@osdl.org> <400F738A.40505@cyberone.com.au> <20040121230408.7b8b9a92.akpm@osdl.org> <400F7965.5050605@cyberone.com.au> <20040122081623.GL1016@holomorphy.com>
In-Reply-To: <20040122081623.GL1016@holomorphy.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, Nikita@Namesys.COM
List-ID: <linux-mm.kvack.org>


William Lee Irwin III wrote:

>On Thu, Jan 22, 2004 at 06:19:01PM +1100, Nick Piggin wrote:
>
>>Hmm, I actually did misread it a bit. The ratio is:
>>nr_pages * zone->nr_active / (zone->nr_inactive * 2)
>>Which is nr_pages if the active list is size we want.
>>So its not so bad as I thought. Scaling by nr_pages would
>>seem to couple it strongly with free pages though. My
>>patch makes it more independent. No I don't know if thats
>>good or not, it would obviously need a lot of testing.
>>
>
>Could something symbolic be banged out to represent this "desired
>(in)active_list size" to reduce confusion? You're not the only one
>needing to review various calculations twice over or more at every
>turn.
>

That probably would help. I still don't like the ratio that much
but I guess it works. I'll see if I can get any improvements out
of my version.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
