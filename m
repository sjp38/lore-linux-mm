Message-ID: <4020C7F3.8030004@cyberone.com.au>
Date: Wed, 04 Feb 2004 21:22:43 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 5/5] mm improvements
References: <4020BDCB.8030707@cyberone.com.au>	<4020BE94.1040001@cyberone.com.au> <20040204021823.24eb1c79.akpm@osdl.org>
In-Reply-To: <20040204021823.24eb1c79.akpm@osdl.org>
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
>>It allows two scans at the two lowest priorities before breaking out or
>> doing a blk_congestion_wait, for both try_to_free_pages and balance_pgdat.
>>
>
>This seems to be fairly equivalent to simply subtracting one from
>DEF_PRIORITY.
>
>

Sort of - except in the case where nr_inactive >> priority
is less than nr_pages*2. Oh and this also allows another
shot at refilling the inactive list.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
