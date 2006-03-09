Message-ID: <440F99AF.8050706@yahoo.com.au>
Date: Thu, 09 Mar 2006 13:57:51 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: yield during swap prefetching
References: <200603081013.44678.kernel@kolivas.org> <20060308222404.GA4693@elf.ucw.cz> <440F9154.2080909@yahoo.com.au> <200603091330.14396.kernel@kolivas.org>
In-Reply-To: <200603091330.14396.kernel@kolivas.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: Pavel Machek <pavel@ucw.cz>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ck@vds.kolivas.org
List-ID: <linux-mm.kvack.org>

Con Kolivas wrote:

>On Thu, 9 Mar 2006 01:22 pm, Nick Piggin wrote:
>
>>
>>So as much as a major fault costs in terms of performance, the tiny
>>chance that prefetching will avoid it means even the CPU usage is
>>questionable. Using sched_yield() seems like a hack though.
>>
>
>Yeah it's a hack alright. Funny how at last I find a place where yield does 
>exactly what I want and because we hate yield so much noone wants me to use 
>it all.
>
>

AFAIKS it is a hack for the same reason using it for locking is a hack,
it's just that prefetch doesn't care if it doesn't get the CPU back for
a while.

Given a yield implementation which does something completely different
for SCHED_OTHER tasks, you code may find it doesn't work so well anymore.
This is no different to the java folk using it with decent results for
locking. Just because it happened to work OK for them at the time didn't
mean it was the right thing to do.

I have always maintained that a SCHED_OTHER task calling sched_yield
is basically a bug because it is utterly undefined behaviour.

But being an in-kernel user that "knows" the implementation sort of does
the right thin, maybe you justify it that way.

--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
