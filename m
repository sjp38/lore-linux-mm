Message-ID: <403C6906.9070808@cyberone.com.au>
Date: Wed, 25 Feb 2004 20:21:10 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: More vm benchmarking
References: <403C66D2.6010302@cyberone.com.au>
In-Reply-To: <403C66D2.6010302@cyberone.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, Nikita Danilov <Nikita@Namesys.COM>
List-ID: <linux-mm.kvack.org>


Nick Piggin wrote:

> Well you can imagine my surprise to see your numbers so I've started
> redoing some benchmarks to see what is going wrong.
>
> This first set are 2.6.3, 2.6.3-mm2, 2.6.3-mm3. All SMP kernels
> compiled with the same compiler and using the same .config (where


Sorry, the 2.6.3, 2.6.3-mm2 and 2.6.3-mm3 I tested were all UP compiled
kernels.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
