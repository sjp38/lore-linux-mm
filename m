Message-ID: <4020C659.9090407@cyberone.com.au>
Date: Wed, 04 Feb 2004 21:15:53 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 2/5] mm improvements
References: <4020BDCB.8030707@cyberone.com.au>	<4020BE25.9050908@cyberone.com.au> <20040204021035.2a6ca8a2.akpm@osdl.org>
In-Reply-To: <20040204021035.2a6ca8a2.akpm@osdl.org>
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
>> > 2/5: vm-dont-rotate-active-list.patch
>> >     Nikita's patch to keep more page ordering info in the active list.
>> >     Also should improve system time due to less useless scanning
>> >     Helps swapping loads significantly.
>>
>
>It bugs me that this improvement is also applicable to 2.4.  if it makes
>the same improvement there, we're still behind.
>
>
>

Yeah that bugs me too. If someone wants to backport it to 2.4 it
would be interesting to measure. I'm not sure if it will get
included, but if it did and if it helps as much as it helped 2.6
then it makes my job a lot harder.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
