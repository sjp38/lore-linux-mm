Message-ID: <403C7DE4.6040304@cyberone.com.au>
Date: Wed, 25 Feb 2004 21:50:12 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: vm benchmarking
References: <20040224034036.22953169.akpm@osdl.org>	<403C76D8.3000302@cyberone.com.au> <20040224154347.2b1536ee.akpm@osdl.org>
In-Reply-To: <20040224154347.2b1536ee.akpm@osdl.org>
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
>>My machine doesn't touch swap at make -j4 with mem=64m. It is
>>dual CPU with a SMP kernel but I was using maxcpus=1.
>>
>
>It is light-to-moderate paging.
>
>
>>It compiles 2.4.21 with gcc-3.3.3 I think (I can tell you when I
>>get home).
>>
>
>gcc version 3.2.2 20030222 (Red Hat Linux 3.2.2-5)
>
>This is a 2.4.19 defconfig build.
>
>

So it should be pretty similar to what I've been doing.

>>I can't explain your results. Maybe you have other stuff running.
>>
>
>Only `vmstat 1'.
>
>

That shouldn't hurt. Maybe running two CPUs is a problem. I'd better
try that.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
