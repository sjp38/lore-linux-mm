Message-ID: <40111379.7060107@cyberone.com.au>
Date: Fri, 23 Jan 2004 23:28:41 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [BENCHMARKS] Namesys VM patches improve kbuild
References: <400F630F.80205@cyberone.com.au>	<20040121223608.1ea30097.akpm@osdl.org>	<16399.42863.159456.646624@laputa.namesys.com>	<40105633.4000800@cyberone.com.au> <16400.63379.453282.283117@laputa.namesys.com>
In-Reply-To: <16400.63379.453282.283117@laputa.namesys.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <Nikita@Namesys.COM>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Nikita Danilov wrote:

>Nick Piggin writes:
> > 
>
>[...]
>
> > 
> > But those cold mapped pages are basically ignored until the
> > reclaim_mapped threshold, however they do continue to have their
> > referenced bits cleared - hence page_referenced check should
> > become a better estimation when reclaim_mapped is reached, right?
>
>Right.
>
>By the way here lies another problem: refill_inactive_zone() never
>removes referenced mapped page from the active list. Which allows for
>the simple DoS:
>

Yeah you are right. I actually have a test program that triggers
the DoS. I think it is also related to the fairness issues in 2.4
(some still exist in 2.6).

Basically the more memory a process has allocated, the faster they
are able to touch it, so the more they are given, etc etc.

But all the same, that should not be hurting low memory performance
if you are trying to do real work.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
