Message-ID: <4020B05E.3080909@cyberone.com.au>
Date: Wed, 04 Feb 2004 19:42:06 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: More VM benchmarks
References: <40205908.4080600@cyberone.com.au> <40207B67.7040407@cyberone.com.au>
In-Reply-To: <40207B67.7040407@cyberone.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


Nick Piggin wrote:

>
>
> Nick Piggin wrote:
>
>> http://www.kerneltrap.org/~npiggin/vm/5/
>>


Sorry to keep replying to myself. I've done some runs
with my IO scheduler regression tests and these patches
don't make a significant difference one way or the other
although the results with the patches are generally a
bit better.

Tested OraSim pgbench nickbench tiobench and the read/ls
kernel tree during a streaming read/write. 256MB RAM
this time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
